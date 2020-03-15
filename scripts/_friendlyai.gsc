#include scripts\_utils;

init()
{
	level.friendlyAIs = [];

	[[level.addCallback]]("onDisconnect", ::RunOnDisconnect);
	[[level.addCallback]]("onPlayerDamage", ::RunOnDamage);
	[[level.addCallback]]("onPlayerKilled", ::RunOnKilled);
}

RunOnKilled(eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration)
{
	self KillPlayerAIs();
}

RunOnDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset)
{
	if (isPlayer(eAttacker) && eAttacker != self)
		return;
	
	for (i = 0; i < level.friendlyAIs.size; i++)
	{
		if (level.friendlyAIs[i].parent == self)
		{
			level.friendlyAIs[i] notify("damage", 10);
		}
	}
}

RunOnDisconnect()
{
	self KillPlayerAIs();
}

KillPlayerAIs()
{
	for (i = 0; i < level.friendlyAIs.size; i++)
	{
		if (level.friendlyAIs[i].parent == self)
		{
			level.friendlyAIs[i] notify("killed_ai");
		}
	}
}

spawnFriendlyAI( bottype )
{
	parent = self;

	spawnorigin = parent.origin;
	spawnangles = (0,randomInt(360),0);

	count = level.friendlyAIs.size;

	level.friendlyAIs[count]			= spawn("script_model", spawnorigin);
	level.friendlyAIs[count].angles		= spawnangles;
	level.friendlyAIs[count].parent		= parent;
	level.friendlyAIs[count].type		= bottype;
	level.friendlyAIs[count].state		= "idle";
	level.friendlyAIs[count].name		= (level.AItype[bottype].nameprefix + "_" + count);
	level.friendlyAIs[count].speed		= level.AItype[bottype].speed;
	level.friendlyAIs[count].maxhealth	= level.AItype[bottype].health;
	level.friendlyAIs[count].health		= level.friendlyAIs[count].maxhealth;
	level.friendlyAIs[count].animtree	= level.AItype[bottype].animtree;
	level.friendlyAIs[count].SFXgrumble	= level.AItype[bottype].SFX_grumble;
	level.friendlyAIs[count].SFXattack	= level.AItype[bottype].SFX_attack;
	level.friendlyAIs[count].SFXdeath	= level.AItype[bottype].SFX_death;

	level.friendlyAIs[count] thread loopAnim();
	level.friendlyAIs[count] thread deleteAI();
	level.friendlyAIs[count] thread monitorDamage();
	level.friendlyAIs[count] thread movePath();
	level.friendlyAIs[count] thread hitAIs();
	level.friendlyAIs[count] thread grumble();
	level.friendlyAIs[count] thread loopPathSearching();
	level.friendlyAIs[count] thread sideFunction();

	return level.friendlyAIs[count];
}

sideFunction()
{
	self endon("killed_ai");

	if ( isDefined( level.AItype[ self.type ].onSpawned ) )
		[[ level.AItype[ self.type ].onSpawned ]]();
}

grumble()
{
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
	parent = self.parent;

	self waittill("killed_ai");

	self [[level.AItype[ self.type ].onKilled]]();

	level.friendlyAIs = array_remove( level.friendlyAIs, self );
	self delete();

	parent notify("update_doghealthbar");
}

monitorDamage()
{
	self endon("killed_ai");

	wait (1.0);

	while (self.health > 0)
	{
		self waittill("damage", damage);

		if (damage < 1)
			damage = 1;

		self.health -= int(damage);
		self.parent notify("update_doghealthbar");
	}

	self notify("killed_ai");
}

loopAnim()
{
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
		t = RandomFloatRange(level.refreshTimeMin, level.refreshTimeMax);
		self delay(t, "path_refresh");
	}
}

delay( time, note )
{
	self endon( note );
	wait time;
	self notify( note );
}

movePath()
{
	self endon("killed_ai");
	self.debug = 0;
	
	for (;;)
	{
		self waittill("path_refresh");

		path = self getPath();

		if ( ! isDefined( path ) )
		{
			self thread moveToParent();
		}
		else
		{
			self thread moving( path[ 0 ] );
		}
	}
}

moveToParent()
{
	self endon("killed_ai");

	vec		= maps\mp\_utility::vectorScale( anglesToRight( vectorToAngles( self.parent.origin - self.origin) ), 16);
	right	= sightTracePassed(self.origin + level.offset2 + vec, self.parent.origin + level.offset2, false, undefined);
	left	= sightTracePassed(self.origin + level.offset2 - vec, self.parent.origin + level.offset2, false, undefined);

	// Ha l�tja a j�t�kost, akkor nem keres �tvonalat
	if ( right && left )
	{
		path = array( self.parent );
		dist = distanceSquared( self.origin, self.parent.origin );
	}
	else
	{
		arr = self getPathToTarget( self.parent );

		if (! isDefined(arr))
		{
			if (self.debug >= 5)
				self notify("killed_ai");

			self.debug++;
			return;
		}

		path = arr[0];
		dist = arr[1];
	}

	self.debug = 0;
	if (dist < 20000)
	{
		self.state = "idle";
		self stopMove();
	}
	else
	{
		self thread moving( path[0] );
	}
}

moving( nextEnt )
{
	self endon("killed_ai");
	self endon("path_refresh");
	self endon("stopmove");

	// K�vetkez� pont kisz�mol�sa -->
	if ( isPlayer( nextEnt ) )
		nextPoint = plantOrigin( nextEnt.origin );
	else
		nextPoint = nextEnt.origin;

	nextPoint = calcEdgePoint( self.origin, nextPoint );
	nextPoint = (nextPoint[0], nextPoint[1], int(nextPoint[2]) + 1);
	// <--



	// Id� kisz�mol�sa -->
	vector = ( nextPoint - self.origin );
	time = length( vector ) / self.speed;
	if ( time <= 0 ) time = 0.01;
	// <--

	// Sebezhet�s�g -->
	if ( is_in_array( level.AIs, nextEnt ) && time < level.AItype[ self.type ].hitDIST / 25 )
		self.targetp = nextEnt;
	else
		self.targetp = undefined;
	// <--

	// Mozg�sok -->
	self rotateTo( (0, vectorToAngles( vector )[1], 0), 0.25 );

	if ( ! self.enableMoving )
		self notify("stopmove");

	self.state = "move";
	self moveTo( nextPoint, time );
	// <--

	self waittill("movedone");
	self notify("path_refresh");
}

stopMove()
{
	self moveTo( self.origin, 0.01 );
	self notify("stopmove");
}

hitAIs()
{
	self endon("killed_ai");

	self.enableMoving = true;
	self.targetp = undefined;

	for (;;)
	{
		wait 0.05;

		self.enableMoving = true;

		if (!isDefined(self.targetp) || !level.AItype[self.targetp.type].canFriendAttack)
			continue;

		currentDist = distanceSquared( self.origin, self.targetp.origin );
		if ( currentDist < pow(level.AItype[ self.type ].hitDIST, 2) )
		{
			self.enableMoving = false;
			self stopMove();
			self.state = "hurt";

			self playSound(self.SFXattack);
			self [[level.AItype[self.type].onAttack]](self.targetp);
		}
		else
		{
			self.enableMoving = true;
		}
	}
}

getPath()
{
	shortestDist = undefined;
	shortestPath = undefined;

	for (i = 0; i < level.AIs.size; i++)
	{
		if (!level.AItype[level.AIs[i].type].canFriendAttack)
			continue;
			
		// a t�l t�voli botokhoz ne sz�molja ki feleslegesen az utat
		if (distanceSquared(self.parent.origin, level.AIs[ i ].origin) > 1000000)
			continue;

		vec		= maps\mp\_utility::vectorScale( anglesToRight( vectorToAngles( level.AIs[ i ].origin - self.origin) ), 16);
		right	= sightTracePassed(self.origin + level.offset2 + vec, level.AIs[ i ].origin + level.offset2, false, undefined);
		left	= sightTracePassed(self.origin + level.offset2 - vec, level.AIs[ i ].origin + level.offset2, false, undefined);

		// Ha l�tja a j�t�kost, akkor nem keres �tvonalat
		if ( right && left )
		{
			path = array( level.AIs[ i ] );
			dist = distanceSquared( self.origin, level.AIs[ i ].origin );
		}
		else
		{
			arr = self getPathToTarget( level.AIs[ i ] );

			if ( ! isDefined( arr ) )
				continue;

			path = arr[0];
			dist = arr[1];
		}

		if ( ! isDefined( path ) || ! isDefined( dist ) )
		{
			wait 3;
			continue;
		}

		if ( ! isDefined( shortestDist ) || (dist < shortestDist && dist < 1000000 ) )
		{
			shortestDist = dist;
			shortestPath = path;
		}
	}

	return shortestPath;
}

getPathToTarget( target )
{
	startNode = getClosestNode( self.origin );
	endNode = getClosestNode( target.origin );

	if ( ! isDefined( startNode ) )
	{
		logPrint("Pet;startNode undefined\n");
		return;
	}
	else if ( ! isDefined( endNode ) )
	{
		logPrint("Pet;endNode undefined\n");
		return;
	}

	if ( startNode == endNode )
	{
		path = array( endNode, target );

		dist = distanceSquared( endNode.origin, target.origin );
	}
	else
	{
		path = level.paths[ startNode.id ][ endNode.id ].path;
		path = array_add( path, target );

		dist = level.paths[ startNode.id ][ endNode.id ].dist;
		dist += distanceSquared( endNode.origin, target.origin );
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

		// iprintln(level.edges[i].id + " - " + level.edges[i].pair.id); // debug
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