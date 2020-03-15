#include scripts\_utils;

init()
{
	level.refreshTimeMin = 0.5;
	level.refreshTimeMax = 1.0;

	level.AIs = [];
	level.spawnAI = scripts\_ai::SpawnAI;
	level.killAIs = scripts\_ai::KillAIs;

	level thread onPlayerConnect();
	thread scripts\_friendlyai::init();
}

onPlayerConnect()
{
	level endon("intermission");

	for (;;)
	{
		level waittill("connecting", player);

		player.invisibilities = [];
		player thread onPlayerSpawned();
	}
}

onPlayerSpawned()
{
	self endon("disconnect");

	for (;;)
	{
		self waittill("spawned_player");
		self updateClosestNode();
	}
}

updateClosestNode()
{
	self endon("disconnect");
	self endon("killed_player");

	for (;;)
	{
		self.closestNode = getClosestNode( self.origin );
		
		t = RandomFloatRange(level.refreshTimeMin, level.refreshTimeMax);
		wait t;
	}
}

RadiusDamage(origin, radius, damage, argument)
{
	for (i = 0; i < level.AIs.size; i++)
	{
		if (level.AItype[level.AIs[i].type].canFriendAttack && distanceSquared(level.AIs[i].origin, origin) <= radius * radius)
			self Attack(level.AIs[i], damage, argument);
	}
}

Attack(ai, damage, argument)
{
	if (!isDefined(ai.hitbox))
		return;
	
	ai.hitbox.trig notify("damage", damage, self, argument);
}

GetTypeStruct(ai)
{
	return level.AItype[ai.type];
}

hasFreeHitbox(type)
{
	if (!isDefined(type) || type == "")
		return true;

	for (i = 0; i < level.hitbox[type].size; i++)
	{
		if (!level.hitbox[type][i].use)
			return true;
	}

	return false;
}

KillAIs(AItype)
{
	array = level.AIs;

	for ( i = 0; i < array.size; i++ )
	{
		if (isDefined( AItype ) && array[i].type != AItype)
			continue;

		array[i] notify("killed_ai");
	}
}

SpawnAI(bottype, spawnorigin)
{
	if (!isDefined(bottype))
		bottype = "default";

	while (!hasFreeHitbox(level.AItype[bottype].hitboxtype)) // wait for a hitbox
		wait randomFloatRange(level.refreshTimeMin, level.refreshTimeMax);

	if (isDefined(spawnorigin))
	{
		origin = spawnorigin;
		angles = (0, 0, 0);
	}
	else
	{
		spawnpointname	= level.AItype[bottype].spawnpointname;
		spawnpoints		= getEntArray(spawnpointname, "classname");
		spawnpoint		= maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(spawnpoints);

		origin = spawnpoint.origin;
		angles = spawnpoint.angles;
	}

	if (isDefined(level.AItype[bottype].angleoffset))
		angleoffset = level.AItype[bottype].angleoffset;
	else
		angleoffset = (0, 0, 0);

	count = level.AIs.size;

	level.AIs[count]			= spawn("script_model", origin);
	level.AIs[count].angles		= angles + angleoffset;
	level.AIs[count].type		= bottype;
	level.AIs[count].state		= "idle";
	level.AIs[count].name		= (level.AItype[bottype].nameprefix + "_" + count);
	level.AIs[count].speed		= level.AItype[bottype].speed;
	level.AIs[count].maxhealth	= int(level.AItype[bottype].health * game["difficulty"] * level.healthMultiplier);
	level.AIs[count].health		= level.AIs[count].maxhealth;
	level.AIs[count].animtree	= level.AItype[bottype].animtree;
	level.AIs[count].SFXgrumble	= level.AItype[bottype].SFX_grumble;
	level.AIs[count].SFXattack	= level.AItype[bottype].SFX_attack;
	level.AIs[count].SFXdeath	= level.AItype[bottype].SFX_death;

	level.AIs[count] thread loopAnim();

	if (isDefined(level.AItype[bottype].hitboxtype) && level.AItype[bottype].hitboxtype != "")
	{
		for ( i = 0; i < level.hitbox[ level.AItype[bottype].hitboxtype ].size; i++ )
		{
			if ( level.hitbox[ level.AItype[bottype].hitboxtype ][ i ].use )
				continue;

			level.AIs[count].hitbox = level.hitbox[level.AItype[bottype].hitboxtype][i];
			level.AIs[count].hitbox.use = true;

			if (is_in_array(level.hasnoTagOrigin, level.AItype[bottype].animtree))
			{
				level.AIs[count].hitbox.origin = level.AIs[count].origin;
				level.AIs[count].hitbox.angles = angles;
				level.AIs[count].hitbox linkTo(level.AIs[count]);
			}
			else
			{
				level.AIs[count].hitbox linkTo(level.AIs[count], "tag_origin", (0,0,0), angleoffset);
			}

			break;
		}
	}
	else
	{
		level.AIs[count].hitbox = undefined;
	}

	level.AIs[count] thread deleteAI();
	level.AIs[count] thread monitorDamage();
	level.AIs[count] thread movePath();
	level.AIs[count] thread hitPlayer();
	level.AIs[count] thread grumble();
	level.AIs[count] thread loopPathSearching();
	level.AIs[count] thread sideFunction();

	level notify("spawned_ai", level.AIs[count]);

	return level.AIs[count];
}

sideFunction()
{
	if (!isDefined(level.AItype[self.type].onSpawned))
		return;

	self endon("killed_ai");

	[[level.AItype[self.type].onSpawned]]();
}

respawn()
{
	if (isDefined(level.AItype[self.type].angleoffset))
		angleoffset = level.AItype[self.type].angleoffset;
	else
		angleoffset = (0, 0, 0);

	spawnpointname	= level.AItype[self.type].spawnpointname;
	spawnpoints		= getEntArray(spawnpointname, "classname");
	spawnpoint		= maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(spawnpoints);

	self.origin = spawnpoint.origin;
	self.angles = spawnpoint.angles + angleoffset;
}

grumble()
{
	if (!isDefined(self.SFXgrumble))
		return;

	self endon("killed_ai");

	for (;;)
	{
		wait 1.25;
		if (random_percentage( 4 ))
			self playSound( self.SFXgrumble );
	}
}

deleteAI()
{
	self waittill("killed_ai", attacker, damage, argument);

	self [[level.callbackAIKilled]](attacker, damage, argument);

	if (isDefined(level.AItype[self.type].onKilled))
		self [[level.AItype[self.type].onKilled]]();

	if (isDefined(self.hitbox)) // free the hitbox
	{
		self unLink();
		self.hitbox.use = false;
		self.hitbox.origin = (0,0,10000);
	}

	level.AIs = array_remove(level.AIs, self);
	self delete();

	level notify("ai_destroyed");
}

monitorDamage()
{
	if (!isDefined(self.hitbox))
		return;

	self endon("killed_ai");
	
	wait (1.0); // spawn protection

	for (;;)
	{
		self.hitbox.trig waittill("damage", damage, attacker, argument);

		if (isDefined(level.AItype[self.type].onDamaged))
			self thread [[level.AItype[self.type].onDamaged]](attacker, damage);
		
		self thread [[level.callbackAIDamage]](attacker, damage, argument);
		self notify("damaged", attacker, damage);

		if (self.health <= 0)
		{
			self notify("killed_ai", attacker, damage, argument);
		}
	}
}

loopAnim()
{
	if (!isDefined(self.animtree))
		return;

	self endon("killed_ai");

	for (;;)
	{
		for ( i = 0; i < level.animtree[ self.animtree ][ self.state ].size; i++ )
		{
			self setModel( level.animtree[ self.animtree ][ self.state ][ i ] );
			wait 0.05;
		}
	}
}

loopPathSearching()
{
	self endon("killed_ai");

	for (;;)
	{
		// more common path refresh if the target is visible
		if (isDefined(self.targetp))
			t = RandomFloatRange(level.refreshTimeMin * 0.5, level.refreshTimeMax * 0.5);
		else
			t = RandomFloatRange(level.refreshTimeMin, level.refreshTimeMax);

		self timer("path_refresh", t);
	}
}

movePath()
{
	self endon("killed_ai");

	for (;;)
	{
		self waittill("path_refresh");

		nextNodeORG	= undefined;

		if (level.AItype[self.type].targettype == "player")
			path = self pathToClosestPlayer();
		else if (level.AItype[self.type].targettype == "random")
			path = self pathToRandomWaypoint();
		else if (level.AItype[self.type].targettype == "ai")
			path = self pathToAI();
		else
			path = undefined;


		if (!isDefined(path))
		{
			self.targetp = undefined;
			self stopMove();

			continue;
		}

		self thread moving(path[0]);
	}
}

moving(nextEnt)
{
	self endon("killed_ai");
	self endon("path_refresh");
	self endon("stopmove");

	if (!isDefined(self.debug))
		self.debug = 0;

	// Get the next target point
	if (isPlayer(nextEnt))
		nextPoint = plantOrigin(nextEnt.origin);
	else
		nextPoint = nextEnt.origin;

	nextPoint = calcEdgePoint(self.origin, nextPoint);
	nextPoint = (nextPoint[0], nextPoint[1], int(nextPoint[2]) + 1);
	vector = nextPoint - self.origin;

	// Avoid collision, but only if the AI has a hitbox
	if (isDefined(self.hitbox))
	{
		forward	= maps\mp\_utility::vectorscale(vectorNormalize(vector), 48);
		trace = bulletTrace(self.origin + level.offset2, self.origin + level.offset2 + forward, false, self);
		
		if (trace["fraction"] != 1 && isDefined(trace["entity"]) && is_true(trace["entity"].use)) // the entity should be the hitbox
			self.debug++;
		else
			self.debug = 0;

		if (self.debug >= 3)
		{
			wait randomFloatRange(0.25, 0.5);

			self.debug = 0;
			self stopMove();
			return;
		}
	}

	// t = s / v
	s = length(vector);
	time = s / self.speed;
	if (time < 0.01)
		time = 0.01;
	
	// Get the target
	if (isPlayer(nextEnt) && time < level.AItype[self.type].hitDIST * 0.04)
		self.targetp = nextEnt;
	else if (level.AItype[self.type].targettype == "ai" && is_in_array(level.AIs, nextEnt) && time < level.AItype[self.type].hitDIST * 0.04)
		self.targetp = nextEnt;
	else
		self.targetp = undefined;

	// Movement
	if (isDefined(level.AItype[self.type].angleoffset))
		self rotateTo((0, vectorToAngles(vector)[1], 0) + level.AItype[self.type].angleoffset, 0.25);
	else
		self rotateTo((0, vectorToAngles(vector)[1], 0), 0.25);

	if (!self.enableMoving)
		self notify("stopmove");

	self.state = "move";
	self moveTo(nextPoint, time);

	self waittill("movedone");
	self notify("path_refresh");
}

stopMove()
{
	self.state = "idle";
	
	self moveTo(self.origin, 0.01);
	self notify("stopmove");
}

hitPlayer()
{
	self endon("killed_ai");

	self.enableMoving = true;
	self.targetp = undefined;

	if (!isDefined(level.AItype[ self.type ].onAttack))
		return;

	for (;;)
	{
		wait 0.05;

		self.enableMoving = true;

		if ( ! isDefined( self.targetp ) )
			continue;

		currentDist = distanceSquared( self.origin, self.targetp.origin );
		if ( currentDist < pow(level.AItype[ self.type ].hitDIST, 2) )
		{
			self.enableMoving = false;
			self stopMove();
			self.state = "hurt";

			if (isDefined(self.SFXattack))
				self playSound(self.SFXattack);

			self [[ level.AItype[ self.type ].onAttack ]]( self.targetp );
		}
		else
		{
			self.enableMoving = true;
		}
	}
}

pathToClosestPlayer()
{
	shortestDist = undefined;
	shortestPath = undefined;

	players = getEntArray("player", "classname");

	for (i = 0; i < players.size; i++)
	{
		player = players[i];

		if (player.sessionstate != "playing" || player.invisibilities.size > 0)
			continue;

		vec		= maps\mp\_utility::vectorScale( anglesToRight( vectorToAngles( player.origin - self.origin) ), 16);
		right	= sightTracePassed(self.origin + level.offset2 + vec, player.origin + level.offset2, false, undefined);
		left	= sightTracePassed(self.origin + level.offset2 - vec, player.origin + level.offset2, false, undefined);

		// Ha l�tja a j�t�kost, akkor nem keres �tvonalat
		if ( right && left )
		{
			path = array( player );
			dist = distanceSquared( self.origin, player.origin );
		}
		else
		{
			arr = self getPathToPlayer( player );

			if ( ! isDefined( arr ) )
				continue;

			path = arr[0];
			dist = arr[1];
		}

		if ( ! isDefined( path ) || ! isDefined( dist ) )
		{
			//iPrintln( "^1ERROR: Undefined path from " + self.name + " to " + player.name );
			wait 3;
			continue;
		}

		if ( ! isDefined( shortestDist ) || dist < shortestDist )
		{
			shortestDist = dist;
			shortestPath = path;
		}
	}

	return shortestPath;
}

pathToAI()
{
	ai = self.targetAI;
	if (!isDefined(ai))
		return;

	vec		= maps\mp\_utility::vectorScale( anglesToRight( vectorToAngles(ai.origin - self.origin)), 16);
	right	= sightTracePassed(self.origin + level.offset2 + vec, ai.origin + level.offset2, false, undefined);
	left	= sightTracePassed(self.origin + level.offset2 - vec, ai.origin + level.offset2, false, undefined);

	if ( right && left )
	{
		path = array(ai);
		dist = distanceSquared(self.origin, ai.origin);
	}
	else
	{
		arr = self getPathToAI(ai);

		if (!isDefined(arr))
			return;

		path = arr[0];
		dist = arr[1];
	}

	if (!isDefined(path) || !isDefined(dist))
		return;

	return path;
}

pathToRandomWaypoint()
{
	startNode = getClosestNode(self.origin);

	if (!isDefined(startNode))
		return;

	if (!isDefined(self.endNode)) // only get a new random endNode if the previous one is reached
		self.endNode = level.waypoints[randomInt(level.waypoints.size)];

	arr = self getPathToNode(startNode, self.endNode);

	if (!isDefined(arr))
		return;

	if (arr[1] < 1)
		self.endNode = undefined;

	return arr[0];
}

getPathToPlayer( player )
{
	startNode = getClosestNode( self.origin );
	endNode = player.closestNode;

	if ( ! isDefined( startNode ) )
	{
		self respawn();
		return;
	}
	else if ( ! isDefined( endNode ) )
	{
		return;
	}

	if ( startNode == endNode )
	{
		path = array( endNode, player );

		dist = distanceSquared( endNode.origin, player.origin );
	}
	else
	{
		path = level.paths[ startNode.id ][ endNode.id ].path;
		path = array_add( path, player );

		dist = level.paths[ startNode.id ][ endNode.id ].dist;
		dist += distanceSquared( endNode.origin, player.origin );
	}

	path = self simplifyPath( path ); // l�that� node-ok t�rl�se

	return array(path, dist);
}

getPathToAI(ai)
{
	startNode = getClosestNode(self.origin);
	endNode = getClosestNode(ai.origin);

	if (!isDefined(startNode))
	{
		self respawn();
		return;
	}
	else if (!isDefined(endNode))
	{
		return;
	}

	if (startNode == endNode)
	{
		path = array(endNode, ai);

		dist = distanceSquared(endNode.origin, ai.origin);
	}
	else
	{
		path = level.paths[startNode.id][endNode.id].path;
		path = array_add(path, ai);

		dist = level.paths[startNode.id][endNode.id].dist;
		dist += distanceSquared(endNode.origin, ai.origin);
	}

	path = self simplifyPath(path);

	return array(path, dist);
}

getPathToNode(startNode, endNode)
{
	if ( startNode == endNode )
	{
		path = array(endNode);
		dist = 0;
	}
	else
	{
		path = level.paths[ startNode.id ][ endNode.id ].path;
		dist = level.paths[ startNode.id ][ endNode.id ].dist;
	}

	path = self simplifyPath( path ); // l�that� node-ok t�rl�se

	return array(path, dist);
}

simplifyPath( path )
{
	while ( isDefined( path[ 1 ] ) && ! isPlayer( path[ 1 ] ) )
	{
		if ( sightTracePassed(self.origin + level.offset, path[ 1 ].origin + level.offset, false, undefined) )
			path = array_remove( path, path[ 0 ] );
		else
			break;
	}

	return path;
}

calcEdgePoint( startPoint, endPoint )
{
	// bot-node szakasz egyenes
	x1 = startPoint[0];
	y1 = startPoint[1];
	z1 = startPoint[2];
	x2 = endPoint[0];
	y2 = endPoint[1];
	z2 = endPoint[2];

	if ( x1 == x2 && y1 == y2 ) // ha a bot-node s�kbeli szakasz hossza 0
		return endPoint;

	segments = [];

	for (i = 0; i < level.edges.size; i++)
	{
		// sarok szakasz egyenes
		x3 = level.edges[i].origin[0];
		y3 = level.edges[i].origin[1];
		z3 = level.edges[i].origin[2];
		x4 = level.edges[i].pair.origin[0];
		y4 = level.edges[i].pair.origin[1];
		z4 = level.edges[i].pair.origin[2];

		temp = segmentVectors( int(x1), int(y1), int(z1), int(x2), int(y2), int(z2), int(x3), int(y3), int(z3), int(x4), int(y4), int(z4) );

		if ( ! temp[1] ) // ha nem metszi a k�t szakasz egym�st
			continue;

		if ( distanceSquared( temp[0], startPoint ) < 4 ) // ha �pp rajta �ll egy �len, azt nem adja hozz�
			continue;

		segments[ segments.size ] = temp[0];
	}



	edgePoint = undefined;
	shortestDist = undefined;
	if ( segments.size > 1 ) // Ha t�bb �lt elmetszett, akkor kisz�molja a legk�zelebbit
	{
		for (i = 0; i < segments.size; i++)
		{
			dist = distanceSquared( startPoint, segments[ i ] );

			if ( (! isDefined( shortestDist ) || dist < shortestDist) )
			{
				shortestDist = dist;
				edgePoint = segments[ i ];
			}
		}
	}
	else if ( segments.size ) // Ha csak egy �lt metszett el
	{
		edgePoint = segments[ 0 ];
	}
	else // Ha egy �lt sem metszett el, vagy nem l�tja
	{
		edgePoint = endPoint;
	}

	return edgePoint;
}

getClosestNode( origin )
{
	closestDist = undefined;
	closestNode = undefined;

	for (i = 0; i < level.waypoints.size; i++)
	{
		if ( ! sightTracePassed(origin + level.offset, level.waypoints[i].origin + level.offset, false, undefined) )
			continue;

		if ( ! isDefined( closestNode ) || closer( origin, level.waypoints[i].origin, closestNode.origin ) )
			closestNode = level.waypoints[i];
	}

	return closestNode;
}

segmentVectors( e1X, e1Y, e1Z, e2X, e2Y, e2Z, e3X, e3Y, e3Z, e4X, e4Y, e4Z )
{
	// v�gpontokhoz sz�m�tott relat�v poz�ci�
	A1 = e2Y - e1Y; // ha A1 == 0, akkor B1 != 0
	B1 = (e2X - e1X) * -1;
	A2 = e4Y - e3Y;
	B2 = (e4X - e3X) * -1;

	if ( A1 == A2 || B1 == B2 ) // p�rhuzamosak
		return array((0, 0, 0), false);

	// kezd�pontok �s az elt�r�s szorzata
	c = A1 * e1X + B1 * e1Y;
	f = A2 * e3X + B2 * e3Y;

	X = ((B2 * c - B1 * f) / (B2 * A1 - B1 * A2));
	Y = ((A2 * c - A1 * f) / (A2 * B1 - A1 * B2));

	if (e3Z != e4Z)
	{
		if (e4X != e3X)
			Z = ((e4Z - e3Z) / (e4X - e3X) * X + e3Z);
		else
			Z = ((e4Z - e3Z) / (e4Y - e3Y) * Y + e3Z);
	}
	else
	{
		Z = e3Z;
	}

	isCovering = cover( e1X, e1Y, e2X, e2Y, e3X, e3Y, e4X, e4Y, X, Y );

	return array((X, Y, Z), isCovering);
}

cover( e1X, e1Y, e2X, e2Y, e3X, e3Y, e4X, e4Y, mX, mY )
{
	// Elv: megvizsg�lom, hogy a metsz�spont a befoglal� t�glalapon bel�lre esik-e

	// Els� szakasz v�gpontjai
	x1 = min(e1X, e2X);
	x2 = max(e1X, e2X);
	y1 = min(e1Y, e2Y);
	y2 = max(e1Y, e2Y);

    // M�sodik szakasz v�gpontjai
	x3 = min(e3X, e4X);
	x4 = max(e3X, e4X);
	y3 = min(e3Y, e4Y);
	y4 = max(e3Y, e4Y);

	if ( mX < x1 || mX > x2 || mY < y1 || mY > y2 || mX < x3 || mX > x4 || mY < y3 || mY > y4 ) // a metsz�spont rajta van-e a szakaszokon
		return false; // nem!
	else
		return true; // igen!
}