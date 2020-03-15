#include scripts\_utils;

init()
{
	level.AItypes = [];
	level.AItypes[level.AItypes.size] = "default";
	level.AItypes[level.AItypes.size] = "creeper";
	level.AItypes[level.AItypes.size] = "chicken";
	level.AItypes[level.AItypes.size] = "boss";
	level.AItypes[level.AItypes.size] = "blaze";
	level.AItypes[level.AItypes.size] = "wolf";
	level.AItypes[level.AItypes.size] = "skeleton";
	level.AItypes[level.AItypes.size] = "enderman";
	level.AItypes[level.AItypes.size] = "smoke";
	level.AItypes[level.AItypes.size] = "blaze_boss";
	level.AItypes[level.AItypes.size] = "legolas_boss";
	level.AItypes[level.AItypes.size] = "cow_boss";
	level.AItypes[level.AItypes.size] = "zombie_boss";
	level.AItypes[level.AItypes.size] = "chicken_healer";

	level.AItype = [];
	level.AItype["default"]					= spawnStruct();
	level.AItype["default"].nameprefix		= "zombie"; // name prefix for debug
	level.AItype["default"].spawnpointname	= "mp_bz_aispawn"; // spawnpoint
	level.AItype["default"].spawnrate		= 60; // chance of spawn
	level.AItype["default"].targettype		= "player"; // target: player/random
	level.AItype["default"].canFriendAttack	= true; // can hit by friendly AI or not
	level.AItype["default"].speed			= 100; // move speed
	level.AItype["default"].health			= 200; // max health
	level.AItype["default"].animtree		= "zombie"; // animation
	level.AItype["default"].hitboxtype		= "default"; // hitbox type
	level.AItype["default"].hitDMG			= 15; // damage
	level.AItype["default"].hitMOD			= "MOD_MELEE"; // damage type
	level.AItype["default"].hitDIST			= 54; // damage from this distance
	level.AItype["default"].SFX_grumble		= "zombie_grumble"; // grumble sound fx, plays randomly
	level.AItype["default"].SFX_attack		= "zombie_attack"; // sound fx on attack
	level.AItype["default"].SFX_death		= "zombie_death"; // sound fx on death
	level.AItype["default"].FX_death		= undefined; // death graphic effect
	level.AItype["default"].onAttack		= ::hitDefault; // callback function on attack
	level.AItype["default"].onDamaged		= ::dmgSpeedUp; // callback function on damage
	level.AItype["default"].onKilled		= ::deathDefault; // callback function on death

	level.AItype["creeper"]					= spawnStruct();
	level.AItype["creeper"].nameprefix		= "creeper";
	level.AItype["creeper"].spawnpointname	= "mp_bz_aispawn";
	level.AItype["creeper"].spawnrate		= 25;
	level.AItype["creeper"].targettype		= "player";
	level.AItype["creeper"].canFriendAttack	= true;
	level.AItype["creeper"].speed			= 80;
	level.AItype["creeper"].health			= 150;
	level.AItype["creeper"].animtree		= "creeper";
	level.AItype["creeper"].hitboxtype		= "default";
	level.AItype["creeper"].hitDMG			= 45;
	level.AItype["creeper"].hitMOD			= "MOD_PROJECTILE";
	level.AItype["creeper"].hitDIST			= 64;
	level.AItype["creeper"].SFX_grumble		= "creeper_grumble";
	level.AItype["creeper"].SFX_attack		= "creeper_fuse";
	level.AItype["creeper"].SFX_death		= "creeper_death";
	level.AItype["creeper"].FX_death		= undefined;
	level.AItype["creeper"].onAttack		= ::hitCreeper;
	level.AItype["creeper"].onDamaged		= ::dmgDefault;
	level.AItype["creeper"].onKilled		= ::deathDefault;

	level.AItype["chicken"]					= spawnStruct();
	level.AItype["chicken"].nameprefix		= "chicken";
	level.AItype["chicken"].spawnpointname	= "mp_bz_aispawn";
	level.AItype["chicken"].spawnrate		= 15;
	level.AItype["chicken"].targettype		= "player";
	level.AItype["chicken"].canFriendAttack	= true;
	level.AItype["chicken"].speed			= 200;
	level.AItype["chicken"].health			= 100;
	level.AItype["chicken"].animtree		= "chicken";
	level.AItype["chicken"].hitboxtype		= "default";
	level.AItype["chicken"].hitDMG			= 10;
	level.AItype["chicken"].hitMOD			= "MOD_MELEE";
	level.AItype["chicken"].hitDIST			= 54;
	level.AItype["chicken"].SFX_grumble		= "chicken_grumble";
	level.AItype["chicken"].SFX_attack		= "chicken_attack";
	level.AItype["chicken"].SFX_death		= "chicken_death";
	level.AItype["chicken"].FX_death		= undefined;
	level.AItype["chicken"].onAttack		= ::hitDefault;
	level.AItype["chicken"].onDamaged		= ::dmgDefault;
	level.AItype["chicken"].onKilled		= ::deathDefault;

	level.AItype["boss"]					= spawnStruct();
	level.AItype["boss"].nameprefix			= "cow";
	level.AItype["boss"].spawnpointname		= "mp_bz_aispawn";
	level.AItype["boss"].spawnrate			= 0;
	level.AItype["boss"].targettype			= "player";
	level.AItype["boss"].canFriendAttack	= true;
	level.AItype["boss"].canHitSpecial		= false; // can hit by special damages, like bomb
	level.AItype["boss"].speed				= 100;
	level.AItype["boss"].health				= 3000;
	level.AItype["boss"].animtree			= "cow";
	level.AItype["boss"].hitboxtype			= "default";
	level.AItype["boss"].hitDMG				= 25;
	level.AItype["boss"].hitMOD				= "MOD_MELEE";
	level.AItype["boss"].hitDIST			= 54;
	level.AItype["boss"].SFX_grumble		= "cow_grumble";
	level.AItype["boss"].SFX_attack			= "cow_attack";
	level.AItype["boss"].SFX_death			= "cow_death";
	level.AItype["boss"].FX_death			= undefined;
	level.AItype["boss"].onAttack			= ::hitDefault;
	level.AItype["boss"].onDamaged			= ::dmgDefault;
	level.AItype["boss"].onKilled			= ::deathDefault;

	level.AItype["blaze"]					= spawnStruct();
	level.AItype["blaze"].nameprefix		= "blaze";
	level.AItype["blaze"].spawnpointname	= "mp_bz_aispawn";
	level.AItype["blaze"].spawnrate			= 5;
	level.AItype["blaze"].targettype		= "player";
	level.AItype["blaze"].canFriendAttack	= true;
	level.AItype["blaze"].speed				= 110;
	level.AItype["blaze"].health			= 550;
	level.AItype["blaze"].animtree			= "blaze";
	level.AItype["blaze"].hitboxtype		= "default";
	level.AItype["blaze"].hitDMG			= 35;
	level.AItype["blaze"].hitMOD			= "MOD_MELEE";
	level.AItype["blaze"].hitDIST			= 220;
	level.AItype["blaze"].SFX_grumble		= "blaze_grumble";
	level.AItype["blaze"].SFX_attack		= "blaze_attack";
	level.AItype["blaze"].SFX_death			= "blaze_death";
	level.AItype["blaze"].FX_death			= undefined;
	level.AItype["blaze"].onAttack			= ::hitBlaze;
	level.AItype["blaze"].onDamaged			= ::dmgDefault;
	level.AItype["blaze"].onKilled			= ::deathDefault;
	level.AItype["blaze"].onSpawned			= ::loopSmoke;

	level.AItype["wolf"]					= spawnStruct();
	level.AItype["wolf"].nameprefix			= "wolf";
	level.AItype["wolf"].spawnpointname		= "mp_bz_aispawn";
	level.AItype["wolf"].spawnrate			= 15;
	level.AItype["wolf"].targettype			= "player";
	level.AItype["wolf"].canFriendAttack	= true;
	level.AItype["wolf"].speed				= 150;
	level.AItype["wolf"].health				= 200;
	level.AItype["wolf"].animtree			= "wolf";
	level.AItype["wolf"].hitboxtype			= "default";
	level.AItype["wolf"].hitDMG				= 30;
	level.AItype["wolf"].hitMOD				= "MOD_MELEE";
	level.AItype["wolf"].hitDIST			= 54;
	level.AItype["wolf"].SFX_grumble		= "wolf_grumble";
	level.AItype["wolf"].SFX_attack			= "wolf_attack";
	level.AItype["wolf"].SFX_death			= "wolf_death";
	level.AItype["wolf"].FX_death			= undefined;
	level.AItype["wolf"].onAttack			= ::hitDefault;
	level.AItype["wolf"].onDamaged			= ::dmgDefault;
	level.AItype["wolf"].onKilled			= ::deathDefault;

	level.AItype["skeleton"]				= spawnStruct();
	level.AItype["skeleton"].nameprefix		= "skeleton";
	level.AItype["skeleton"].spawnpointname	= "mp_bz_aispawn";
	level.AItype["skeleton"].spawnrate		= 10;
	level.AItype["skeleton"].targettype		= "player";
	level.AItype["skeleton"].canFriendAttack	= true;
	level.AItype["skeleton"].speed			= 100;
	level.AItype["skeleton"].health			= 175;
	level.AItype["skeleton"].animtree		= "skeleton";
	level.AItype["skeleton"].hitboxtype		= "default";
	level.AItype["skeleton"].hitDMG			= 15;
	level.AItype["skeleton"].hitMOD			= "MOD_MELEE";
	level.AItype["skeleton"].hitDIST		= 500;
	level.AItype["skeleton"].SFX_grumble	= "skeleton_grumble";
	level.AItype["skeleton"].SFX_attack		= "skeleton_attack";
	level.AItype["skeleton"].SFX_death		= "skeleton_death";
	level.AItype["skeleton"].FX_death		= undefined;
	level.AItype["skeleton"].onAttack		= ::hitSkeleton;
	level.AItype["skeleton"].onDamaged		= ::dmgDefault;
	level.AItype["skeleton"].onKilled		= ::deathDefault;

	level.AItype["enderman"]				= spawnStruct();
	level.AItype["enderman"].nameprefix		= "enderman"; // name prefix for debug
	level.AItype["enderman"].angleoffset	= (270, 90, 0);
	level.AItype["enderman"].spawnpointname	= "mp_bz_aispawn"; // spawnpoint
	level.AItype["enderman"].spawnrate		= 5; // chance of spawn
	level.AItype["enderman"].targettype		= "player"; // target: player/random
	level.AItype["enderman"].canFriendAttack	= true; // can hit by friendly AI or not
	level.AItype["enderman"].speed			= 100; // move speed
	level.AItype["enderman"].health			= 400; // max health
	level.AItype["enderman"].animtree		= "enderman"; // animation
	level.AItype["enderman"].hitboxtype		= "default"; // hitbox type
	level.AItype["enderman"].hitDMG			= 20; // damage
	level.AItype["enderman"].hitMOD			= "MOD_MELEE"; // damage type
	level.AItype["enderman"].hitDIST		= 54; // damage from this distance
	level.AItype["enderman"].SFX_grumble	= "enderman_grumble"; // grumble sound fx, plays randomly
	level.AItype["enderman"].SFX_attack		= "enderman_attack"; // sound fx on attack
	level.AItype["enderman"].SFX_death		= "enderman_death"; // sound fx on death
	level.AItype["enderman"].FX_death		= undefined; // death graphic effect
	level.AItype["enderman"].onAttack		= ::hitDefault; // callback function on attack
	level.AItype["enderman"].onKilled		= ::deathDefault; // callback function on death
	level.AItype["enderman"].onSpawned		= ::teleport;
	
	level.AItype["dog"]						= spawnStruct();
	level.AItype["dog"].nameprefix			= "wolf";
	level.AItype["dog"].spawnpointname		= "mp_bz_aispawn";
	level.AItype["dog"].spawnrate			= 0;
	level.AItype["dog"].targettype			= "player";
	level.AItype["dog"].canFriendAttack		= false;
	level.AItype["dog"].speed				= 175;
	level.AItype["dog"].health				= 200;
	level.AItype["dog"].animtree			= "wolf";
	level.AItype["dog"].hitboxtype			= "default";
	level.AItype["dog"].hitDMG				= 100;
	level.AItype["dog"].hitMOD				= "MOD_MELEE";
	level.AItype["dog"].hitDIST				= 54;
	level.AItype["dog"].SFX_grumble			= "wolf_grumble";
	level.AItype["dog"].SFX_attack			= "wolf_attack";
	level.AItype["dog"].SFX_death			= "wolf_death";
	level.AItype["dog"].FX_death			= undefined;
	level.AItype["dog"].onAttack			= ::hitFriendlyDefault;
	level.AItype["dog"].onDamaged			= ::dmgDefault;
	level.AItype["dog"].onKilled			= ::deathDefault;

	level.AItype["smoke"]					= spawnStruct();
	level.AItype["smoke"].nameprefix		= "dangerzone";
	level.AItype["smoke"].spawnpointname	= "mp_bz_aispawn";
	level.AItype["smoke"].spawnrate			= 0;
	level.AItype["smoke"].targettype		= "random";
	level.AItype["smoke"].canFriendAttack	= false;
	level.AItype["smoke"].canHitSpecial		= false;
	level.AItype["smoke"].speed				= 50;
	level.AItype["smoke"].health			= 0;
	level.AItype["smoke"].animtree			= undefined;
	level.AItype["smoke"].hitboxtype		= undefined;
	level.AItype["smoke"].hitDMG			= 5;
	level.AItype["smoke"].hitMOD			= "MOD_MELEE";
	level.AItype["smoke"].hitDIST			= 150;
	level.AItype["smoke"].onAttack			= ::hitDefaultNoDelay;
	level.AItype["smoke"].onSpawned			= ::hitzone;

	level.AItype["blaze_boss"]					= spawnStruct();
	level.AItype["blaze_boss"].nameprefix		= "blaze_boss";
	level.AItype["blaze_boss"].spawnpointname	= "mp_bz_aispawn";
	level.AItype["blaze_boss"].spawnrate		= 0;
	level.AItype["blaze_boss"].targettype		= "player";
	level.AItype["blaze_boss"].canFriendAttack	= true;
	level.AItype["blaze_boss"].canHitSpecial	= false;
	level.AItype["blaze_boss"].speed			= 130;
	level.AItype["blaze_boss"].health			= 10000;
	level.AItype["blaze_boss"].animtree			= "blaze";
	level.AItype["blaze_boss"].hitboxtype		= "default";
	level.AItype["blaze_boss"].hitDMG			= 35;
	level.AItype["blaze_boss"].hitMOD			= "MOD_MELEE";
	level.AItype["blaze_boss"].hitDIST			= 250;
	level.AItype["blaze_boss"].SFX_grumble		= "blaze_grumble";
	level.AItype["blaze_boss"].SFX_attack		= "blaze_attack";
	level.AItype["blaze_boss"].SFX_death		= "blaze_death";
	level.AItype["blaze_boss"].FX_death			= undefined;
	level.AItype["blaze_boss"].onAttack			= ::hitBlaze;
	level.AItype["blaze_boss"].onDamaged		= ::dmgDefault;
	level.AItype["blaze_boss"].onKilled			= ::deathDefault;
	level.AItype["blaze_boss"].onSpawned		= ::loopSmoke;

	level.AItype["legolas_boss"]				= spawnStruct();
	level.AItype["legolas_boss"].nameprefix		= "legolas";
	level.AItype["legolas_boss"].spawnpointname	= "mp_bz_aispawn";
	level.AItype["legolas_boss"].spawnrate		= 0;
	level.AItype["legolas_boss"].targettype		= "player";
	level.AItype["legolas_boss"].canFriendAttack= true;
	level.AItype["legolas_boss"].canHitSpecial	= false;
	level.AItype["legolas_boss"].speed			= 120;
	level.AItype["legolas_boss"].health			= 10000;
	level.AItype["legolas_boss"].animtree		= "skeleton";
	level.AItype["legolas_boss"].hitboxtype		= "default";
	level.AItype["legolas_boss"].hitDMG			= 20;
	level.AItype["legolas_boss"].hitMOD			= "MOD_MELEE";
	level.AItype["legolas_boss"].hitDIST		= 500;
	level.AItype["legolas_boss"].SFX_grumble	= "skeleton_grumble";
	level.AItype["legolas_boss"].SFX_attack		= "skeleton_attack";
	level.AItype["legolas_boss"].SFX_death		= "skeleton_death";
	level.AItype["legolas_boss"].FX_death		= undefined;
	level.AItype["legolas_boss"].onAttack		= ::hitLegolas;
	level.AItype["legolas_boss"].onDamaged		= ::dmgDefault;
	level.AItype["legolas_boss"].onKilled		= ::deathDefault;

	level.AItype["cow_boss"]					= spawnStruct();
	level.AItype["cow_boss"].nameprefix			= "cow_boss";
	level.AItype["cow_boss"].spawnpointname		= "mp_bz_aispawn";
	level.AItype["cow_boss"].spawnrate			= 0;
	level.AItype["cow_boss"].targettype			= "player";
	level.AItype["cow_boss"].canFriendAttack	= true;
	level.AItype["cow_boss"].canHitSpecial		= false;
	level.AItype["cow_boss"].speed				= 110;
	level.AItype["cow_boss"].health				= 10000;
	level.AItype["cow_boss"].animtree			= "cow";
	level.AItype["cow_boss"].hitboxtype			= "default";
	level.AItype["cow_boss"].hitDMG				= 50;
	level.AItype["cow_boss"].hitMOD				= "MOD_MELEE";
	level.AItype["cow_boss"].hitDIST			= 54;
	level.AItype["cow_boss"].SFX_attack			= "cow_attack";
	level.AItype["cow_boss"].SFX_death			= "cow_death";
	level.AItype["cow_boss"].onAttack			= ::hitDefault;
	level.AItype["cow_boss"].onDamaged			= ::dmgDefault;
	level.AItype["cow_boss"].onKilled			= ::deathDefault;
	level.AItype["cow_boss"].onSpawned			= ::howl;

	level.AItype["zombie_boss"]					= spawnStruct();
	level.AItype["zombie_boss"].nameprefix		= "zombie_boss";
	level.AItype["zombie_boss"].spawnpointname	= "mp_bz_aispawn";
	level.AItype["zombie_boss"].spawnrate		= 0;
	level.AItype["zombie_boss"].targettype		= "player";
	level.AItype["zombie_boss"].canFriendAttack	= true;
	level.AItype["zombie_boss"].canHitSpecial	= false;
	level.AItype["zombie_boss"].speed			= 120;
	level.AItype["zombie_boss"].health			= 10000;
	level.AItype["zombie_boss"].animtree		= "zombie";
	level.AItype["zombie_boss"].hitboxtype		= "default";
	level.AItype["zombie_boss"].hitDMG			= 50;
	level.AItype["zombie_boss"].hitMOD			= "MOD_MELEE";
	level.AItype["zombie_boss"].hitDIST			= 54;
	level.AItype["zombie_boss"].SFX_grumble		= "zombie_grumble"; // grumble sound fx, plays randomly
	level.AItype["zombie_boss"].SFX_attack		= "zombie_attack"; // sound fx on attack
	level.AItype["zombie_boss"].SFX_death		= "zombie_death"; // sound fx on death
	level.AItype["zombie_boss"].onAttack		= ::hitDefault;
	level.AItype["zombie_boss"].onDamaged		= ::dmgDefault;
	level.AItype["zombie_boss"].onKilled		= ::deathDefault;

	level.AItype["chicken_healer"]					= spawnStruct();
	level.AItype["chicken_healer"].nameprefix		= "chicken_healer";
	level.AItype["chicken_healer"].spawnpointname	= "mp_bz_aispawn";
	level.AItype["chicken_healer"].spawnrate		= 0;
	level.AItype["chicken_healer"].targettype		= "ai";
	level.AItype["chicken_healer"].canFriendAttack	= true;
	level.AItype["chicken_healer"].speed			= 250;
	level.AItype["chicken_healer"].health			= 100;
	level.AItype["chicken_healer"].animtree			= "chicken";
	level.AItype["chicken_healer"].hitboxtype		= "default";
	level.AItype["chicken_healer"].hitDMG			= 800;
	level.AItype["chicken_healer"].hitMOD			= "MOD_MELEE";
	level.AItype["chicken_healer"].hitDIST			= 64;
	level.AItype["chicken_healer"].SFX_death		= "chicken_death";
	level.AItype["chicken_healer"].onAttack			= ::healTargetAndDie;
	level.AItype["chicken_healer"].onDamaged		= ::dmgDefault;
	level.AItype["chicken_healer"].onKilled			= ::deathDefault;

	Precache();

	for (i = 0; i < level.AItypes.size; i++)
	{
		typename = level.AItypes[ i ];

		if ( isDefined( level.AItype[ typename ].FX_death ) )
			[[level.r_precacheFX]]( "death_" + typename, level.AItype[ typename ].FX_death );
	}
}

Precache()
{
	// Precache
	[[level.r_precacheModel]]("xmodel/oma_mc_arrow");
	[[level.r_precacheFX]]("explo_creeper", "fx/rndl/rndl_expl_creeper.efx");
	[[level.r_precacheFX]]("fireball", "fx/rndl/rndl_fireball.efx");
	[[level.r_precacheFX]]("firepuff", "fx/rndl/rndl_firepuff.efx");
	[[level.r_precacheFX]]("blaze_smoke", "fx/rndl/rndl_smoke_blaze.efx");
	[[level.r_precacheFX]]("dangerzone_smoke", "fx/rndl/rndl_smoke_dangerzone.efx");
	[[level.r_precacheFX]]("enderman_flash", "fx/rndl/rndl_enderflash.efx");
	[[level.r_precacheFX]]("health_buff", "fx/rndl/hpbuff.efx");
	[[level.r_precacheShock]]("moomoo");
}

/*---------------------
// Player hit function types
---------------------*/

hitDefaultNoDelay(player)
{
	damage	= level.AItype[ self.type ].hitDMG;
	mod		= level.AItype[ self.type ].hitMOD;

	player thread [[level.callbackPlayerDamage]](player, player, damage, 0, mod, "zom_mp", self.origin, (0,0,0), "none", 0);
}

hitDefault(player)
{
	self hitDefaultNoDelay(player);
	wait (1.0);
}

hitCreeper( player )
{
	maxdmg		= int(level.AItype[ self.type ].hitDMG);
	mindmg		= int(level.AItype[ self.type ].hitDMG / 10);
	orig		= self.origin;
	radius = 200;

	wait (0.3);

	earthquake(1, 3, orig, radius);
	playFx( level.FXs[ "explo_creeper" ], orig );
	self playSound("creeper_explo");
	thread radiusDMG( orig + (0,0,16), radius, maxdmg, mindmg, 0.05 );

	self notify("killed_ai");
}

radiusDMG( origin, radius, max_damage, min_damage, delay )
{
	wait ( delay );
	radiusDamage( origin, radius, max_damage, min_damage );
}

healTargetAndDie(target)
{
	if (!isDefined(target))
		return;

	damage	= level.AItype[self.type].hitDMG;
	playFx(level.FXs["health_buff"], target.origin);

	if (isPlayer(target))
	{
		target setHealth(target.health + damage);
	}
	else if (is_in_array(level.AIs, target))
	{
		target.health = clamp(target.health + damage, 0, target.maxhealth);
	}
	
	target notify("damaged", self, damage * -1);
	self notify("killed_ai");
}

hitBlaze( player )
{
	origin	= self.origin;
	angles	= self.angles;
	damage	= level.AItype[ self.type ].hitDMG;
	radius	= 120;

	orig = throwBomb( origin, angles, player.origin );

	playFx( level.FXs[ "firepuff" ], orig );
	radiusDMG( orig, radius, damage, damage / 2, 0 );

	wait (1.5);
}

throwBomb( origin, angles, origin2 )
{
	forward = maps\mp\_utility::vectorScale( anglesToForward( angles ), 32 );
	origin += forward;
	origin2 += (0,0,32);
	vector = maps\mp\_utility::vectorScale( origin2 - origin, length( origin2 - origin ) / 80 );
	time = 3;

	entity = spawn("script_origin", origin + (0,0,48));
	entity.angles = angles;
	entity moveGravity( vector, time );
	self thread deleteEntity( entity );

	oldorig = entity.origin;
	for (i = 0; i < time * 20; i++)
	{
		wait (0.05);

		playFx( level.FXs[ "fireball" ], entity.origin );
		vec = maps\mp\_utility::vectorScale( ( entity.origin - oldorig ), 1 );
		trace = bulletTrace( entity.origin, entity.origin + vec, false, self );

		if ( trace["fraction"] < 1 )
			break;

		oldorig = entity.origin;
	}
	orig = entity.origin;
	self notify("delete_entity");

	return orig;
}

hitSkeleton( player )
{
	damage	= level.AItype[ self.type ].hitDMG;
	mod		= level.AItype[ self.type ].hitMOD;
	origin	= self.origin + (0,0,48);
	angles	= self.angles;

	if ( isDefined( player.spinemarker ) )
	{
		forward = anglesToForward( angles );
		origin += maps\mp\_utility::vectorScale( forward, 32 );

		entity = spawn("script_model", origin);
		entity setModel( "xmodel/oma_mc_arrow" );
		self thread deleteEntity( entity );

		target = player.spinemarker.origin;
		vec = maps\mp\_utility::vectorScale((target + (0,0,10)) - origin, 0.3 ); // arrow speed
		entity.angles = vectorToAngles( vec );

		for (i = 0; i < 150; i++)
		{
			oldorig = entity.origin;
			wait 0.05;

			//vec = maps\mp\_utility::vectorScale( ( entity.origin - oldorig ), 15 ); // arrow speed
			trace = bulletTrace( entity.origin, entity.origin + vec, true, self );
			entity moveTo( trace["position"], 0.05 );

			if ( trace["fraction"] != 1 )
			{
				if ( isPlayer( trace["entity"] ) )
				{
					player = trace["entity"];
					player thread [[level.callbackPlayerDamage]](player, player, damage, 0, mod, "zom_mp", origin, vec, "none", 0);
				}
				else
				{
					wait (0.5);
				}
				break;
			}
		}
		self notify("delete_entity");
	}

	wait (1.0);
}

hitLegolas(targetPlayer)
{
	damage	= level.AItype[self.type].hitDMG;
	mod		= level.AItype[self.type].hitMOD;
	origin	= self.origin + (0,0,48);
	angles	= self.angles;
	arrowSpeed = 0.3;

	// shot arrow to the player
	if (isDefined(targetPlayer.spinemarker))
	{
		currStartPos = origin + vectorScale(anglesToForward(angles), 32);
		currTargetPos = targetPlayer.spinemarker.origin + (0,0,10);
		
		self thread shotArrow(currStartPos, vectorScale(currTargetPos - currStartPos, arrowSpeed), damage, mod);

		wait 0.25;
	}

	// shot arrows in different directions
	for (i = -180; i < 180; i += 20)
	{
		currAngles = angles + (0, i, 0);
		currStartPos = origin + vectorScale(anglesToForward(currAngles), 32);
		currTargetPos = origin + vectorScale(anglesToForward(currAngles), 500);

		self thread shotArrow(currStartPos, vectorScale(currTargetPos - currStartPos, arrowSpeed), damage, mod);
	}

	wait 0.25;
}

shotArrow(startOrigin, moveVector, damage, damageMod)
{
	arrow = spawn("script_model", startOrigin);
	arrow setModel("xmodel/oma_mc_arrow");
	arrow.angles = vectorToAngles(moveVector);

	for (i = 0; i < 50; i++)
	{
		trace = bulletTrace(arrow.origin, arrow.origin + moveVector, true, self);
		arrow moveTo(trace["position"], 0.05);

		if (trace["fraction"] < 1)
		{
			if (isPlayer(trace["entity"]))
			{
				player = trace["entity"];
				player thread [[level.callbackPlayerDamage]](player, player, damage, 0, damageMod, "zom_mp", startOrigin, moveVector, "none", 0);
			}
			else
			{
				wait 0.5; // hit the wall or other ai
			}

			break;
		}

		wait 0.05;
	}

	arrow delete();
}

// call on AI
deleteEntity( entity )
{
	self waittill_any("killed_ai", "delete_entity");
	entity delete();
}

/*---------------------
// AI Damage function types
---------------------*/

dmgDefault(attacker, damage)
{
}

dmgSpeedUp(attacker, damage)
{
	if (random_percentage(35))
		self.speed = min(self.speed * 1.5, level.AItype[self.type].speed * 2);
}

/*---------------------
// Death function types
---------------------*/

deathDefault()
{
	self playSound( self.SFXdeath );
}

deathPlayFx()
{
	self playSound( self.SFXdeath );
	playFx( level.FXs[ "death_" + self.type ], self.origin, anglesToForward(self.angles), anglesToUp(self.angles) );
}

/*---------------------
// Secondary functions
---------------------*/

loopSmoke()
{
	for (;;)
	{
		wait 0.25;
		playFx( level.FXs[ "blaze_smoke" ], self.origin );
	}
}

teleport()
{
	for (;;)
	{
		wait 1;

		// only teleport if can't see the target
		if (!isDefined(self.targetp) && !randomInt(10))
		{
			playFx(level.FXs["enderman_flash"], self.origin);
			self playSound("enderman_teleport_off");

			// get a waypoint near to a random player
			playersAlive = getPlayingPlayers();
			if (playersAlive.size > 0)
			{
				randomPlayer = playersAlive[randomInt(playersAlive.size)];
				node = randomPlayer.closestnode;
			}
			else
			{
				node = undefined;
			}

			// only teleport to player's node if there is nobody on it
			if (isDefined(node))
			{
				wpBusy = false;
				for (i = 0; i < playersAlive.size; i++)
				{
					if (distanceSquared(node.origin, playersAlive[i].origin) < 2500)
					{
						wpBusy = true;
						break;
					}
				}

				if (!wpBusy)
					waypoint = node;
				else
					waypoint = level.waypoints[randomInt(level.waypoints.size)];
			}
			else
			{
				waypoint = level.waypoints[randomInt(level.waypoints.size)];
			}

			self.origin = waypoint.origin;
			self scripts\_ai::stopMove();

			playFx(level.FXs["enderman_flash"], self.origin);
			self playSound("enderman_teleport_on");

			wait 5;
		}
	}
}

hitzone()
{
	for (;;)
	{
		playFx(level.FXs["dangerzone_smoke"], self.origin);

		wait 0.5;

		if (!isDefined(level.AItype[self.type].onAttack))
			continue;

		players = getPlayingPlayers();
		for (i = 0; i < players.size; i++)
		{
			player = players[i];
			if (distanceSquared(player.origin, self.origin) > pow(level.AItype[ self.type ].hitDIST, 2))
				continue;
			
			self [[level.AItype[self.type].onAttack]](player);
		}
	}
}

howl()
{
	for (;;)
	{
		wait randomIntRange(10, 18);

		self playSound("howl");
		wait 1.5;

		players = getPlayingPlayers();
		for (i = 0; i < players.size; i++)
		{
			player = players[i];
			player shellShock("moomoo", 5);
		}
	}
}

/*---------------------
// Friendly AI hit functions
---------------------*/
hitFriendlyDefault( target )
{
	if (isDefined(target.hitbox.trig))
	{
		damage		= int(level.AItype[ self.type ].hitDMG);
		attacker	= self.parent;
		target.hitbox.trig notify("damage", damage, attacker);

		wait (1.0);
	}
}