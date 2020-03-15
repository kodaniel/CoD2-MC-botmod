#include scripts\_utils;

init()
{
	cvarDef("int", "scr_botmod_forceboss", -1, -1, 999);
	level.prevObjNum = undefined;

	level.obj = [];
	// Stay alive
	level.obj[0]		= spawnStruct();
	level.obj[0].func	= ::StayAlive;
	level.obj[0].mindif	= 1.2;
	level.obj[0].type	= "time";
	// Kill zombies
	level.obj[1]		= spawnStruct();
	level.obj[1].func	= ::JustKill;
	level.obj[1].mindif	= 0;
	level.obj[1].type	= "kill";
	// Cow
	level.obj[2]		= spawnStruct();
	level.obj[2].func	= ::Cows;
	level.obj[2].mindif	= 1.2;
	level.obj[2].type	= "cows";
	// VIP
	level.obj[3]		= spawnStruct();
	level.obj[3].func	= ::ProtectTheVIP;
	level.obj[3].mindif	= 1.4;
	level.obj[3].type	= "time";
	// Chicken
	level.obj[4]		= spawnStruct();
	level.obj[4].func	= ::ChickenDinner;
	level.obj[4].mindif	= 1.6;
	level.obj[4].type	= "chickens";
	// Stay alive with smoke
	level.obj[5]		= spawnStruct();
	level.obj[5].func	= ::StayAliveWithSmoke;
	level.obj[5].mindif	= 1.5;
	level.obj[5].type	= "time";
	// Blaze boss
	level.obj[6]		= spawnStruct();
	level.obj[6].func	= ::Mainboss_Blaze;
	level.obj[6].mindif	= 999;
	level.obj[6].type	= "boss"; // the boss is a special type name
	// Skeleton boss
	level.obj[7]		= spawnStruct();
	level.obj[7].func	= ::Mainboss_Skeleton;
	level.obj[7].mindif	= 999;
	level.obj[7].type	= "boss";
	// Cow boss
	level.obj[8]		= spawnStruct();
	level.obj[8].func	= ::Mainboss_Cow;
	level.obj[8].mindif	= 999;
	level.obj[8].type	= "boss";
	// Zombie boss
	level.obj[9]		= spawnStruct();
	level.obj[9].func	= ::Mainboss_Zombie;
	level.obj[9].mindif	= 999;
	level.obj[9].type	= "boss";
	// Horde mode
	level.obj[10]		= spawnStruct();
	level.obj[10].func	= ::Horde;
	level.obj[10].mindif	= 999;
	level.obj[10].type	= "kill";

	game["headicon_vip"] = "rndl_headicon_vip";
	[[level.r_precacheHeadIcon]](game["headicon_vip"]);

	// Precache objective labels
	[[level.r_precacheString]](&"BZ_KILL_ALL_ZOMBIES");
	[[level.r_precacheString]](&"BZ_KILL_ALL_COWS");
	[[level.r_precacheString]](&"BZ_KILL_BOSS");
	[[level.r_precacheString]](&"BZ_STAY_ALIVE");
	[[level.r_precacheString]](&"BZ_PROTECT_THE_VIP");
	[[level.r_precacheString]](&"BZ_COMPLETE_IN_TIME");
	[[level.r_precacheString]](&"BZ_ELAPSED_TIME");

	[[level.r_precacheString]](&"Blaster");
	[[level.r_precacheString]](&"Legolas");
	[[level.r_precacheString]](&"Moo Moo");
	[[level.r_precacheString]](&"Frankenstein's kitty");
}

AddMissionToMap(objnum)
{
	if (!isDefined(level.objective))
		level.objective = [];
	
	level.objective = add_to_array(level.objective, objnum, false);
}

StartMission(index)
{
	assert(index >= 0 && index < level.obj.size);

	[[level.obj[index].func]]();
}

StartRandomMission(lastRound)
{
	nextObjNum = undefined;
	// contains the valid objective indices
	valid_objectives = [];

	for (i = 0; i < level.objective.size; i++)
	{
		if (lastRound)
		{
			if (level.obj[level.objective[i]].type == "boss")
			{
				forceIndex = getCvarInt("scr_botmod_forceboss");
				if (forceIndex < 0 || forceIndex == i)
					valid_objectives[valid_objectives.size] = level.objective[i];
			}
		}
		else
		{
			if (level.obj[level.objective[i]].type != "boss" && level.obj[level.objective[i]].mindif <= game["difficulty"])
				valid_objectives[valid_objectives.size] = level.objective[i];
		}
	}

	if (valid_objectives.size == 0)
	{
		valid_objectives = level.objective;
	}

	for (i = 0; i < 5; i++)
	{
		nextObjNum = valid_objectives[randomInt(valid_objectives.size)];
		isTypeSame = isDefined(level.prevObjNum) && level.obj[level.prevObjNum].type == level.obj[nextObjNum].type;

		if (!isDefined(level.prevObjNum) || (nextObjNum != level.prevObjNum && !isTypeSame))
			break;
	}

	[[level.obj[nextObjNum].func]]();

	level.prevObjNum = nextObjNum;
}

SpawnZombiesInfinitely(max, type)
{
	level endon("round_ended");

	for (;;)
	{
		if (isDefined(max))
		{
			if (level.AIs.size < max)
				spawnZombie(type);
		}
		else
		{
			spawnZombie(type);
		}

		wait (randomFloatRange(0.05, 0.5));
	}
}

SpawnZombiesNumber(count, zomtype)
{
	level endon("round_ended");

	while (count > 0)
	{
		count--;
		if (isDefined(zomtype))
			spawnZombie(zomtype);
		else
			spawnZombie();

		wait (randomFloatRange(0.05, 0.5));
	}
}

SpawnZombie(zomtype, forcespawn, origin)
{
	level endon("round_ended");

	if (!isDefined(forcespawn))
		forcespawn = false;

	if (!forcespawn)
	{
		while (isDefined(level.AIs) && level.AIs.size >= level.ailimit)
			wait 0.05;
	}

	zombie = undefined;

	if (isDefined(zomtype))
	{
		zombie = [[level.spawnAI]](zomtype, origin);
	}
	else
	{
		sum = 0;
		newarray = [];
		for (i = 0; i < level.AItypes.size; i++)
		{
			sum += level.AItype[level.AItypes[i]].spawnrate;
			newarray[i] = sum;
		}

		num = randomInt(sum) + 1;
		for (i = 0; i < newarray.size; i++)
		{
			if (num <= newarray[i])
			{
				zombie = [[level.spawnAI]](level.AItypes[i], origin);
				break;
			}
		}
	}

	level notify("spawned_zombie");
	return zombie;
}

RoundFailedIfPlayersAreDead()
{
	level endon("round_ended");

	for (;;)
	{
		if (!CountPlayers("allies", "playing"))
			break;
		wait 1;
	}

	game["roundsuccess"] = "defeat";
	level notify("players_dead");
}

RoundFailedIfTimeRunsOut(time)
{
	level endon("round_ended");

	wait time;

	game["roundsuccess"] = "defeat";
	level notify("time_runs_out");
}

RoundFailedIfPlayerDead(player)
{
	level endon("round_ended");

	player waittill_any("killed_player", "disconnect");

	game["roundsuccess"] = "defeat";
	level notify("player_dead");
}

CountPlayers( team, state )
{
	result = 0;

	players = getEntArray("player", "classname");
	for (i = 0; i < players.size; i++)
	{
		player = players[i];

		if (isDefined(player.pers["team"]) && player.pers["team"] == team && player.sessionstate == state)
			result++;
	}

	return result;
}

addHeadIcon(material, team)
{
	if (level.drawfriend && is_in_array(level.precacheheadicon, material))
	{
		self.headicon = material;

		if (team == "allies" || team == "axis" || team == "spectator")
			self.headiconteam = team;
		else
			self.headiconteam = "none";
	}
}

deleteHeadIcon()
{
	self.headicon = "";
	self.headiconteam = "none";
}

/*
=============
Feladat Le�r�sa
"Megnevez�s: Objective_1"
"Feladat: X ideig t�l kell �lni a zombik t�mad�s�t"
"Gy?zelem: Ha a id? leteltekor legal�bb 1 j�t�kos �letben van"
"Veres�g: Ha az �sszes j�t�kos meghal"
"D�ntetlen: -"
=============
*/
StayAlive()
{
	level endon("round_ended");
	level endon("players_dead");

	level.obj_maxscore = level.timelimit * 60;
	level.obj_score = 0;
	maxZombieCount = int(CountPlayers("allies", "playing") * game["difficulty"] * 2) + 10;

	// Print objectives
	scripts\player\_hud::AddObjective("timer", &"BZ_STAY_ALIVE", level.timelimit * 60);

	thread RoundFailedIfPlayersAreDead(); // fail mission if everyone is dead
	thread SpawnZombiesInfinitely(maxZombieCount);
	
	wait level.timelimit * 60;

	game["roundsuccess"] = "victory";
}

/*
=============
Feladat Le�r�sa
"Megnevez�s: Objective_2"
"Feladat: X zombit meg kell �lni az id? letelt�ig"
"Gy?zelem: Ha az id? v�g�ig siker�l meg�lni a zombikat"
"Veres�g: Ha az �sszes j�t�kos meghal vagy nem siker�l meg�lni az id? letelt�ig a zombikat"
"D�ntetlen: -"
=============
*/
JustKill()
{
	level endon("round_ended");
	level endon("players_dead");
	level endon("time_runs_out");

	level.obj_maxscore = int(sqrt(game["difficulty"] * CountPlayers("allies", "playing")) * level.timelimit * 10);
	level.obj_score = 0;

	// Print objectives
	scripts\player\_hud::AddObjective("value", &"BZ_KILL_ALL_ZOMBIES", level.obj_maxscore);
	scripts\player\_hud::AddObjective("timer", &"BZ_COMPLETE_IN_TIME", level.timelimit * 60);

	thread RoundFailedIfPlayersAreDead(); // fail mission if everyone is dead
	thread RoundFailedIfTimeRunsOut(level.timelimit * 60);
	thread SpawnZombiesNumber(level.obj_maxscore);

	while (level.obj_score < level.obj_maxscore)
	{
		level waittill("ai_destroyed");
		level.obj_score++;

		scripts\player\_hud::SetObjective(0, level.obj_maxscore - level.obj_score);
	}

	game["roundsuccess"] = "victory";
}

/*
=============
Feladat Le�r�sa
"Megnevez�s: Objective_3"
"Feladat: X zombiboss-t meg kell �lni"
"Gy?zelem: Ha az id? v�g�ig siker�l meg�lni a zombiboss-okat"
"Veres�g: Ha az �sszes j�t�kos meghal vagy nem siker�l meg�lni az id? letelt�ig a zombiboss-okat"
"D�ntetlen: -"
=============
*/
Cows()
{
	level endon("round_ended");
	level endon("players_dead");
	level endon("time_runs_out");

	playerCount = CountPlayers("allies", "playing");
	// old calculation
	//level.obj_maxscore = int(CountPlayers("allies", "playing") * game["difficulty"] * level.timelimit / 8) + 1;
	// new calculation
	level.obj_maxscore = min(int(level.timelimit * sqrt(game["difficulty"] * playerCount) * 0.2) + 1, level.timelimit * 2);
	level.obj_score = 0;
	maxZombieCount = int(playerCount * game["difficulty"] * 2) + 5;

	// Print objectives
	scripts\player\_hud::AddObjective("value", &"BZ_KILL_ALL_COWS", level.obj_maxscore);
	scripts\player\_hud::AddObjective("timer", &"BZ_COMPLETE_IN_TIME", level.timelimit * 60);

	thread RoundFailedIfPlayersAreDead(); // fail mission if everyone is dead
	thread RoundFailedIfTimeRunsOut(level.timelimit * 60);
	thread SpawnZombiesInfinitely(maxZombieCount);

	while (level.obj_score < level.obj_maxscore)
	{
		cow = SpawnZombie("boss", true);
		cow waittill("killed_ai");

		level.obj_score++;

		scripts\player\_hud::SetObjective(0, level.obj_maxscore - level.obj_score);
	}

	game["roundsuccess"] = "victory";
}

/*
=============
Feladat Le�r�sa
"Megnevez�s: Objective_4"
"Feladat: V�dd meg a VIP szem�lyt"
"Gy?zelem: Ha megmenek�l a VIP szem�ly"
"Veres�g: Ha az �sszes j�t�kos meghal vagy elesik a VIP szem�ly"
"D�ntetlen: -"
=============
*/
ProtectTheVIP()
{
	level endon("round_ended");
	level endon("players_dead");
	level endon("player_dead");

	level.obj_maxscore = level.timelimit * 60;
	level.obj_score = 0;
	maxZombieCount = int(CountPlayers("allies", "playing") * game["difficulty"] * 2) + 10;

	// Print objectives
	objIndex = scripts\player\_hud::AddObjective("playername", &"BZ_PROTECT_THE_VIP");
	scripts\player\_hud::AddObjective("timer", &"BZ_STAY_ALIVE", level.timelimit * 60);

	thread RoundFailedIfPlayersAreDead(); // fail mission if everyone is dead
	thread RoundFailedIfVIPDead(objIndex); // fail if the VIP is dead
	thread SpawnZombiesInfinitely(maxZombieCount);

	wait level.timelimit * 60;

	players = getEntArray("player", "classname");
	for (i = 0; i < players.size; i++)
		players[i] deleteHeadIcon();

	game["roundsuccess"] = "victory";
}

RoundFailedIfVIPDead(objIndex)
{
	level endon("round_ended");

	while (true)
	{
		newPlayers = [];
		players = getEntArray("player", "classname");
		for (i = 0; i < players.size; i++)
		{
			if (players[i].sessionstate == "playing")
				newPlayers[newPlayers.size] = players[i];
		}

		if (!newPlayers.size)
			break;

		vipPlayer = newPlayers[randomInt(newPlayers.size)];
		vipPlayer addHeadIcon(game["headicon_vip"], "none");
		vipPlayer iPrintlnBold("^1You are the VIP, don't die!");

		scripts\player\_hud::SetObjective(objIndex, vipPlayer);

		vipPlayer waittill_any("killed_player", "disconnect");
		wait 0.5;

		if (isDefined(vipPlayer))
			break;
	}

	game["roundsuccess"] = "defeat";
	level notify("player_dead");
}

/*
=============
Feladat Le�r�sa
"Megnevez�s: Objective_5, Csirke k�r"
"Feladat: X zombit meg kell �lni az id? letelt�ig"
"Gy?zelem: Ha az id? v�g�ig siker�l meg�lni a zombikat"
"Veres�g: Ha az �sszes j�t�kos meghal vagy nem siker�l meg�lni az id? letelt�ig a zombikat"
"D�ntetlen: -"
=============
*/
ChickenDinner()
{
	level endon("round_ended");
	level endon("players_dead");
	level endon("time_runs_out");

	level.obj_maxscore = int(sqrt(CountPlayers("allies", "playing") * game["difficulty"] * 2) * level.timelimit * 15);
	level.obj_score = 0;

	// Print objectives
	scripts\player\_hud::AddObjective("value", &"BZ_KILL_ALL_ZOMBIES", level.obj_maxscore);
	scripts\player\_hud::AddObjective("timer", &"BZ_COMPLETE_IN_TIME", level.timelimit * 60);

	thread RoundFailedIfPlayersAreDead(); // fail mission if everyone is dead
	thread RoundFailedIfTimeRunsOut(level.timelimit * 60);
	thread SpawnZombiesNumber(level.obj_maxscore, "chicken");

	iPrintlnBold("Winner winner...");
	iPrintlnBold("Chicken dinner?");

	while (level.obj_score < level.obj_maxscore)
	{
		level waittill("ai_destroyed");
		level.obj_score++;

		scripts\player\_hud::SetObjective(0, level.obj_maxscore - level.obj_score);
	}

	game["roundsuccess"] = "victory";
}

/*
=============
Feladat Le�r�sa
"Megnevez�s: Danger Zone"
"Le�r�s: V�letlenszer?en mozog a p�ly�n egy Danger Zone-nak nevezett k�d, ami sebzi a j�t�kosokat."
"Gy?zelem: Ha az id? v�g�ig siker�l t�l�lni"
"Veres�g: Ha az �sszes j�t�kos meghal"
"D�ntetlen: -"
=============
*/
StayAliveWithSmoke()
{
	level endon("round_ended");
	level endon("players_dead");

	level.obj_maxscore = level.timelimit * 60;
	level.obj_score = 0;
	maxZombieCount = int(CountPlayers("allies", "playing") * game["difficulty"] * 2) + 10;

	// Print objectives
	scripts\player\_hud::AddObjective("timer", &"BZ_STAY_ALIVE", level.timelimit * 60);

	thread RoundFailedIfPlayersAreDead(); // fail mission if everyone is dead
	smoke1 = thread SpawnZombie("smoke", true);
	smoke2 = thread SpawnZombie("smoke", true);
	smoke3 = thread SpawnZombie("smoke", true);

	thread SpawnZombiesInfinitely(maxZombieCount);

	smoke1.speed *= 1.0;
	smoke2.speed *= 1.5;
	smoke3.speed *= 2.0;
	
	wait level.timelimit * 60;

	game["roundsuccess"] = "victory";
}

// ********************************
// Horde mode objective
// ********************************
Horde()
{
	level endon("round_ended");
	level endon("players_dead");

	level.obj_maxscore = int(10 * game["roundsplayed"] * game["roundsplayed"] + 20);
	level.obj_score = 0;

	// Print objectives
	scripts\player\_hud::AddObjective("value", &"BZ_KILL_ALL_ZOMBIES", level.obj_maxscore);

	thread RoundFailedIfPlayersAreDead(); // fail mission if everyone is dead
	thread SpawnZombiesNumber(level.obj_maxscore);

	while (level.obj_score < level.obj_maxscore)
	{
		level waittill("ai_destroyed");
		level.obj_score++;

		scripts\player\_hud::SetObjective(0, level.obj_maxscore - level.obj_score);
	}

	game["roundsuccess"] = "victory";
}

Mainboss_Blaze()
{
	level endon("round_ended");
	level endon("players_dead");

	setExpFog(0.0025, 40/255, 20/255, 20/255, 5);

	level.obj_maxscore = 1;
	level.obj_score = 0;

	// Print objectives
	scripts\player\_hud::AddObjective("none", &"BZ_KILL_BOSS");
	scripts\player\_hud::AddObjective("timerup", &"BZ_ELAPSED_TIME", 0);

	thread RoundFailedIfPlayersAreDead(); // fail mission if everyone is dead

	for (i = 0; i < 5; i++)
		thread SpawnZombie("smoke");

	boss = thread SpawnZombie("blaze_boss", true);
	boss.maxhealth *= getPlayingPlayersCount();
	boss.health = boss.maxhealth;

	thread UpdateBossHealth(boss, &"Blaster");

	boss waittill("killed_ai");

	game["roundsuccess"] = "victory";
}

Mainboss_Skeleton()
{
	level endon("round_ended");
	level endon("players_dead");

	setExpFog(0.0025, 40/255, 20/255, 20/255, 5);

	level.obj_maxscore = 1;
	level.obj_score = 0;

	// Print objectives
	scripts\player\_hud::AddObjective("none", &"BZ_KILL_BOSS");
	scripts\player\_hud::AddObjective("timerup", &"BZ_ELAPSED_TIME", 0);

	thread RoundFailedIfPlayersAreDead(); // fail mission if everyone is dead

	boss = thread SpawnZombie("legolas_boss", true);
	boss.maxhealth *= getPlayingPlayersCount();
	boss.health = boss.maxhealth;

	thread UpdateBossHealth(boss, &"Legolas");

	boss waittill("killed_ai");

	game["roundsuccess"] = "victory";
}

Mainboss_Cow()
{
	level endon("round_ended");
	level endon("players_dead");

	setExpFog(0.0025, 40/255, 20/255, 20/255, 5);
	
	level.obj_maxscore = 1;
	level.obj_score = 0;
	playerCount = getPlayingPlayersCount();

	// Print objectives
	scripts\player\_hud::AddObjective("none", &"BZ_KILL_BOSS");
	scripts\player\_hud::AddObjective("timerup", &"BZ_ELAPSED_TIME", 0);

	thread RoundFailedIfPlayersAreDead(); // fail mission if everyone is dead

	boss = thread SpawnZombie("cow_boss", true);
	boss.maxhealth *= playerCount;
	boss.health = boss.maxhealth;

	thread SpawnZombiesInfinitely(playerCount * 4, "default");
	thread UpdateBossHealth(boss, &"Moo Moo");

	boss waittill("killed_ai");

	game["roundsuccess"] = "victory";
}

Mainboss_Zombie()
{
	level endon("round_ended");
	level endon("players_dead");

	setExpFog(0.0025, 40/255, 20/255, 20/255, 5);
	
	level.obj_maxscore = 1;
	level.obj_score = 0;
	playerCount = getPlayingPlayersCount();

	// Print objectives
	scripts\player\_hud::AddObjective("none", &"BZ_KILL_BOSS");
	scripts\player\_hud::AddObjective("timerup", &"BZ_ELAPSED_TIME", 0);

	thread RoundFailedIfPlayersAreDead(); // fail mission if everyone is dead

	boss = thread SpawnZombie("zombie_boss", true);
	boss.maxhealth *= playerCount;
	boss.health = boss.maxhealth;

	thread MainBoss_Zombie_Chickens(boss);
	thread SpawnZombiesInfinitely(playerCount * 5, "chicken_healer");
	thread UpdateBossHealth(boss, &"Frankenstein's kitty");

	boss waittill("killed_ai");

	game["roundsuccess"] = "victory";
}

MainBoss_Zombie_Chickens(boss)
{
	level endon("round_ended");
	level endon("players_dead");

	for (;;)
	{
		level waittill("spawned_ai", ai);
		if (ai.type == "chicken_healer")
			ai.targetAI = boss;
	}
}

// Boss health bar on the top of the screen
UpdateBossHealth(boss, name)
{
	level endon("round_ended");
	thread RemoveBossHealth();

	for (;;)
	{
		scripts\player\_hud::SetBossHealth(boss.maxhealth, boss.health, name);
		boss waittill("damaged");
	}
}

RemoveBossHealth()
{
	level waittill_any("round_ended");
	scripts\player\_hud::DeleteBossHealth();
}