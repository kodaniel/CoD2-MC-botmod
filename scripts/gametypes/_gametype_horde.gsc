#include scripts\_utils;
#include scripts\helpers\_string;

main()
{
	level.callbackStartGameType = ::Callback_StartGameType;
	level.callbackPlayerConnect = ::Callback_PlayerConnect;
	level.callbackPlayerDisconnect = ::Callback_PlayerDisconnect;
	level.callbackPlayerDamage = ::Callback_PlayerDamage;
	level.callbackPlayerKilled = ::Callback_PlayerKilled;
	level.callbackAIDamage = ::Callback_ZombieDamage;
	level.callbackAIKilled = ::Callback_ZombieKilled;
	maps\mp\gametypes\_callbacksetup::SetupCallbacks();

	level.login = ::menuLogin;
	level.register = ::menuRegister;
	level.logout = ::menuLogout;
	level.autoassign = ::menuAutoAssign;
	level.joinclass = ::menuJoinClass;
	level.spectator = ::menuSpectator;
	level.endgameconfirmed = ::EndMap;
	level.reborn = ::reborn;

	level.addobj = scripts\missions\_missions::AddMissionToMap;

	scripts\_main::main();
}

Callback_StartGameType()
{
	level.splitscreen = isSplitScreen();

	// defaults if not defined in level script
	if(!isDefined(game["allies"]))
		game["allies"] = "american";
	if(!isDefined(game["axis"]))
		game["axis"] = "german";

	// server cvar overrides
	if(getCvar("scr_allies") != "")
		game["allies"] = getCvar("scr_allies");
	if(getCvar("scr_axis") != "")
		game["axis"] = getCvar("scr_axis");

	precacheStatusIcon("rndl_statusicon_dead");
	precacheStatusIcon("hud_status_connecting");
	precacheRumble("damage_heavy");
	precacheString(&"PLATFORM_PRESS_TO_SPAWN");
	[[level.r_precacheString]](&"BZ_CANT_JOIN");
	[[level.r_precacheString]](&"BZ_FINAL_ROUND");
	[[level.r_precacheString]](&"BZ_PLAYER_FALLEN");
	[[level.r_precacheString]](&"BZ_ROUND_STARTS");
	[[level.r_precacheString]](&"BZ_ROUND_SURVIVED");
	[[level.r_precacheString]](&"BZ_ROUND_LOST");
	[[level.r_precacheString]](&"REVIVING");
	[[level.r_precacheShader]]("white");
	[[level.r_precacheShader]]("black");
	[[level.r_precacheShader]]("rndl_hud_dead");


	level.xenon = (getcvar("xenonGame") == "true");

	thread scripts\gametypes\_menus::init();
	thread maps\mp\gametypes\_serversettings::init();
	thread maps\mp\gametypes\_clientids::init();
	thread scripts\gametypes\_teams::init();
	thread scripts\gametypes\_weapons::init();
	thread maps\mp\gametypes\_scoreboard::init();
	thread maps\mp\gametypes\_killcam::init();
	thread maps\mp\gametypes\_shellshock::init();
	//thread maps\mp\gametypes\_deathicons::init();
	thread maps\mp\gametypes\_damagefeedback::init();
	//thread maps\mp\gametypes\_healthoverlay::init();
	thread maps\mp\gametypes\_spectating::init();
	thread maps\mp\gametypes\_grenadeindicators::init();
	thread scripts\gametypes\_quickmessages::init();
	thread scripts\missions\_missions::init();
	thread scripts\gametypes\_mysterybox::init();
	thread scripts\gametypes\_adservice::init();
	//thread scripts\gametypes\_maprecordservice::init();
	thread scripts\gametypes\_accsys::init();
	thread scripts\gametypes\_endmapvote::init();
	thread scripts\player\_headicons::init();
	thread scripts\player\_hud::init();
	thread scripts\player\_rank::init();
	thread scripts\player\_money::init();
	thread scripts\player\_smartshout::init();
	thread scripts\player\_reviving::init();
	thread scripts\player\_playerinfo::init();
	thread scripts\player\_quickreload::init();
	thread scripts\killstreaks\_killstreaks::init();

	setClientNameMode("auto_change");

	spawnpointname = "mp_bz_playerspawn";
	spawnpoints = getentarray(spawnpointname, "classname");

	if(!spawnpoints.size)
	{
		maps\mp\gametypes\_callbacksetup::AbortLevel();
		return;
	}

	for(i = 0; i < spawnpoints.size; i++)
		spawnpoints[i] placeSpawnpoint();

	// Time limit per round
	/*level.timelimit		= cvarDef("float", "scr_botmod_timelimit", 2, 0.1, 30);
	setCvar("scr_botmod_timelimit", level.timelimit);
	makeCvarServerInfo("scr_botmod_timelimit", "5");*/
	// Grace period
	level.readyupTime	= cvarDef("int", "scr_horde_readyuptime", 15, 0, 300);
	// AI limit
	if (!isDefined(level.ai_max))
		level.ai_max = 64;
	level.AIlimit		= cvarDef("int", "scr_horde_npclimit", 64, 1, level.ai_max);
	// Round limit per map
	level.bossRoundNum	= cvarDef("int", "scr_horde_bossroundnum", 10, 0, 100);
	// Level difficulty
	level.difficulty	= cvarDef("float", "scr_horde_difficulty", 10, 0.1, 50);
	level.healthMultiplier = cvarDef("float", "scr_horde_healthmultiplier", 1, 0.1, 10);

	if (! isDefined(game["state"]))
		game["state"] = "readyup";
	if (! isDefined(game["roundsplayed"]))
		game["roundsplayed"] = 0;
	if (! isDefined(game["matchstarted"]))
		game["matchstarted"] = false;

	level.doublepoint = 1;
	level.mapended = false;

	level.team["allies"] = 0;
	level.team["axis"] = 0;

	game["roundsuccess"] = "none";
	game["aiKillCount"] = 0;
	game["sound_startround"] = "match_startround";
	game["sound_endround"] = "match_endround";
	game["sound_won"] = "match_win";
	game["sound_lost"] = "match_defeat";

	thread updateServerHostname();
	thread startGame();
	thread scripts\gametypes\_teams::addTestClients();
	thread scripts\gametypes\_hud_roundscore::init();

	// Add every mission type to the game by default
	for (i = 0; i < level.obj.size; i++)
		[[level.addobj]](i);
}

updateServerHostname()
{
	if (getCvar("sv_servername") != "")
		level.hostname = getCvar("sv_servername");
	else
		level.hostname = "^1BOT^7ZOMBIE | rounds: &&1/&&2";

	hostname = level.hostname;
	placeholders = [];

	for (;;)
	{
		placeholders[0] = "?"; // num of max rounds &&1
		placeholders[1] = game["roundsplayed"]; // actual round &&2
		placeholders[2] = "Horde"; // gametype &&3
		placeholders[3] = "HORDE"; // gametype capital &&4

		setCvar("sv_hostname", format(hostname, placeholders));

		wait 10;
	}
}

dummy()
{
	waittillframeend;

	if(isdefined(self))
		level notify("connecting", self);
}

Callback_PlayerConnect()
{
	thread dummy();

	self.statusicon = "hud_status_connecting";
	self waittill("begin");
	self.statusicon = "";

	level notify("connected", self);

	iprintln(&"MP_CONNECTED", self);

	lpselfnum = self getEntityNumber();
	lpGuid = self getGuid();
	logPrint("J;" + lpGuid + ";" + lpselfnum + ";" + self.name + "\n");

	if(game["state"] == "intermission")
	{
		spawnIntermission();
		return;
	}

	level endon("intermission");

	scriptMainMenu = game["menu_ingame"];

	self setClientCvar("ui_allow_weaponchange", "0");

	self.pers["team"] = "spectator";
	self.sessionteam = "spectator";
	self.pers["class"] = "none";
	self.maxhealth = 100;

	spawnSpectator();

	self openMenu(game["menu_auth"]);
	self setClientCvar("g_scriptMainMenu", scriptMainMenu);
}

Callback_PlayerDisconnect()
{
	if (isDefined(self.isLogined))
		self scripts\gametypes\_accsys::Logout();

	iprintln(&"MP_DISCONNECTED", self);

	if(isDefined(self.pers["team"]))
	{
		if(self.pers["team"] == "allies")
			setplayerteamrank(self, 0, 0);
		else if(self.pers["team"] == "axis")
			setplayerteamrank(self, 1, 0);
		else if(self.pers["team"] == "spectator")
			setplayerteamrank(self, 2, 0);
	}
	
	lpselfnum = self getEntityNumber();
	lpGuid = self getGuid();
	logPrint("Q;" + lpGuid + ";" + lpselfnum + ";" + self.name + "\n");
}

Callback_PlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime)
{
	if(self.sessionteam == "spectator")
		return;

	// Don't do knockback if the damage direction was not specified
	if(!isDefined(vDir))
		iDFlags |= level.iDFLAGS_NO_KNOCKBACK;

	// check for completely getting out of the damage
	if(!(iDFlags & level.iDFLAGS_NO_PROTECTION))
	{
		if(isPlayer(eAttacker) && (self != eAttacker) && (self.pers["team"] == eAttacker.pers["team"]))
		{
			if(level.friendlyfire == "0")
			{
				return;
			}
			else if(level.friendlyfire == "1")
			{
				// Make sure at least one point of damage is done
				if(iDamage < 1)
					iDamage = 1;

				self finishPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);

				// Shellshock/Rumble
				self thread maps\mp\gametypes\_shellshock::shellshockOnDamage(sMeansOfDeath, iDamage);
				self playrumble("damage_heavy");
			}
		}
		else
		{
			// Make sure at least one point of damage is done
			if(iDamage < 1)
				iDamage = 1;

			self finishPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime);

			// Shellshock/Rumble
			self thread maps\mp\gametypes\_shellshock::shellshockOnDamage(sMeansOfDeath, iDamage);
			self playrumble("damage_heavy");
		}

		if(isdefined(eAttacker) && eAttacker != self)
			eAttacker thread maps\mp\gametypes\_damagefeedback::updateDamageFeedback();
	}

	self notify("update_healthbar");
}

Callback_PlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration)
{
	self endon("spawned");
	self notify("killed_player");

	if(self.sessionteam == "spectator")
		return;

	// If the player was killed by a head shot, let players know it was a head shot kill
	if(sHitLoc == "head" && sMeansOfDeath != "MOD_MELEE")
		sMeansOfDeath = "MOD_HEAD_SHOT";

	// send out an obituary message to all clients about the kill
	obituary(self, attacker, sWeapon, sMeansOfDeath);

	self.sessionstate = "dead";
	self.statusicon = "rndl_statusicon_dead";

	if (!isDefined(self.switching_class))
		self.deaths++;

	lpselfnum = self getEntityNumber();
	lpselfname = self.name;
	lpselfguid = self getGuid();
	lpselfteam = self.pers["team"];

	if(isPlayer(attacker))
	{
		if (attacker == self) // kill himself
		{
			if (! isDefined(self.switching_class) && sWeapon != "zom_mp")
				attacker.score--;
		}
		else
		{
			if(self.pers["team"] == attacker.pers["team"]) // killed by a friendly
				attacker.score--;
			else
				attacker.score++;
		}
	}
	else // If you weren't killed by a player, you were in the wrong place at the wrong time
	{
		self.score--;
	}

	level notify("update_allhud_score");

	logPrint("K;" + lpselfguid + ";" + lpselfnum + ";" + lpselfteam + ";" + lpselfname + ";" + sWeapon + ";" + iDamage + ";" + sMeansOfDeath + ";" + sHitLoc + "\n");

	// Stop thread if map ended on this death
	if(level.mapended)
		return;

	if (! isDefined(self.switching_class) && game["state"] == "playing")
		sendNotificationToAll(&"BZ_PLAYER_FALLEN", "rndl_hud_dead");

	self.switching_class = undefined;

	body = self cloneplayer(deathAnimDuration);
	//thread maps\mp\gametypes\_deathicons::addDeathicon(body, self.clientid, self.pers["team"], 5);

	delay = 1;	// Delay the player becoming a spectator till after he's done dying
	wait delay;	// ?? Also required for Callback_PlayerKilled to complete before respawn/killcam can execute

	self thread respawn();
}

Callback_ZombieDamage(eAttacker, iDamage, argument)
{
	if (!isDefined(eAttacker) || !isPlayer(eAttacker))
		return;

	if (eAttacker.sessionteam == "spectator")
		return;

	sWeapon = eAttacker getCurrentWeapon();

	if (iDamage < 1)
		iDamage = 1;

	multiplier = 0.066; // default multiplier is 6.6% of the damage
	if (isDefined(level.weapons[sWeapon]))
		multiplier *= level.weapons[sWeapon].moneyMultiplier;
	
	score = int(min(iDamage, self.health) * multiplier);
	money = int(eAttacker scripts\player\_classes::AddMoneyBonus(score * level.doublepoint));

	if (money < 1)
		money = 1;

	eAttacker thread scripts\player\_rank::AddScore(score);
	
	// hunter gives plus damage
	dmg = eAttacker scripts\player\_classes::AddDamageBonus(iDamage);

	self.health -= int(dmg);

	// instakill
	if (isDefined(level.instakill) && (!isDefined(level.AItype[self.type].canHitSpecial) || level.AItype[self.type].canHitSpecial))
	{
		self.health = 0;
	}
	
	eAttacker thread maps\mp\gametypes\_damagefeedback::updateDamageFeedback();
	eAttacker thread updateBotHealthHud(self);

	eAttacker notify("update_money", money);
}

Callback_ZombieKilled(eAttacker, iDamage, argument)
{
	level thread scripts\gametypes\_powerup::GivePowerupRandomly(self.origin, self.angles);

	if (isPlayer(eAttacker))
	{
		eAttacker.score++;
		eAttacker.account["kills"]++;

		game["aiKillCount"]++; // for records
	}
}

updateBotHealthHud( AIent )
{
	self notify("updateAI_healthbar");
	self endon("updateAI_healthbar");
	self endon("disconnect");

	if (! game["show_AIhealth"])
		return;

	level.AIhealthbarsize = 100;

	// Hud Settings
		currhealth = AIent.health;
		maxhealth = AIent.maxhealth;

		if (currhealth < 0)
			currhealth = 0;

		width = (currhealth / maxhealth * 100);

		// Color settings
		g = width / 100;
		color = (1 - g, g, 0);
		// Barsize
		width = int(level.AIhealthbarsize * width / 100);
		if (width == 0)
			width = 1;


	if (! isDefined(self.AIhealth_bg))
	{
		self.AIhealth_bg = newClientHudElem(self);
		self.AIhealth_bg.horzAlign = "center_safearea";
		self.AIhealth_bg.vertAlign = "center_safearea";
		self.AIhealth_bg.alignX = "center";
		self.AIhealth_bg.alignY = "middle";
		self.AIhealth_bg.x = 0;
		self.AIhealth_bg.y = 152;
		self.AIhealth_bg.alpha = 0;
		self.AIhealth_bg.color = (0,0,0);
		self.AIhealth_bg setShader("white", (level.AIhealthbarsize + 4), 10);
	}
	if (! isDefined(self.AIhealth))
	{
		self.AIhealth = newClientHudElem(self);
		self.AIhealth.horzAlign = "center_safearea";
		self.AIhealth.vertAlign = "center_safearea";
		self.AIhealth.alignX = "left";
		self.AIhealth.alignY = "middle";
		self.AIhealth.x = int(level.AIhealthbarsize / (-2.0));
		self.AIhealth.y = 152;
		self.AIhealth.alpha = 0;
	}

	self.AIhealth_bg.alpha = .5;
	self.AIhealth.alpha = 1;
	self.AIhealth.color = color;
	self.AIhealth setShader("white", width, 6);

	wait 1;
	self.AIhealth_bg fadeOverTime(.5);
	self.AIhealth_bg.alpha = 0;
	self.AIhealth fadeOverTime(.5);
	self.AIhealth.alpha = 0;
}

sendNotificationToAll(string, icon, sound)
{
	players = getEntArray("player", "classname");
	for (i = 0; i < players.size; i++)
	{
		player = players[i];

		player scripts\player\_notification::Notification(string, icon, sound);
	}
}

spawnPlayer(origin, angles)
{
	self endon("disconnect");
	self notify("spawned");

	resettimeout();

	// Stop shellshock and rumble
	self stopShellshock();
	self stoprumble("damage_heavy");

	self.sessionteam = self.pers["team"];
	self.sessionstate = "playing";
	self.spectatorclient = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;
	self.health = self.maxhealth;
	self.statusicon = level.classIcons[self.pers["class"]];

	if (!isDefined(origin) || !isDefined(angles))
	{
		spawnpointname = "mp_bz_playerspawn";
		spawnpoints = getentarray(spawnpointname, "classname");
		spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam(spawnpoints);

		if(isDefined(spawnpoint))
		{
			origin = spawnpoint.origin;
			angles = spawnpoint.angles;
		}
		else
		{
			maps\mp\_utility::error("NO " + spawnpointname + " SPAWNPOINTS IN MAP");
		}
	}

	if(isDefined(origin) && isDefined(angles))
		self spawn(origin, angles);

	if (!isDefined(self.pers["savedmodel"]))
		scripts\gametypes\_teams::model();
	else
		maps\mp\_utility::loadModel(self.pers["savedmodel"]);

	if (isDefined(self.pers["weapon1"]) && isDefined(self.pers["weapon2"]))
	{
	 	self setWeaponSlotWeapon("primary", self.pers["weapon1"]);
		self setWeaponSlotAmmo("primary", 999);
		self setWeaponSlotClipAmmo("primary", 999);

	 	self setWeaponSlotWeapon("primaryb", self.pers["weapon2"]);
		self setWeaponSlotAmmo("primaryb", 999);
		self setWeaponSlotClipAmmo("primaryb", 999);

		self setSpawnWeapon(self.pers["spawnweapon"]);
	}
	else
	{
		self setWeaponSlotWeapon("primary", self.pers["weapon"]);
		self setWeaponSlotAmmo("primary", 999);
		self setWeaponSlotClipAmmo("primary", 999);

		self setSpawnWeapon(self.pers["weapon"]);
	}

	scripts\gametypes\_weapons::givePistol();
	scripts\gametypes\_weapons::saveWeapons();

	lpselfnum = self getEntityNumber();
	lpGuid = self getGuid();
	logPrint("S;" + lpGuid + ";" + lpselfnum + ";" + self.name + "\n");

	waittillframeend;
	self notify("spawned_player");
}

spawnSpectator(origin, angles)
{
	self notify("spawned");

	resettimeout();

	// Stop shellshock and rumble
	self stopShellshock();
	self stoprumble("damage_heavy");

	self.sessionstate = "spectator";
	self.spectatorclient = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;

	if(self.pers["team"] == "spectator")
		self.statusicon = "";

	maps\mp\gametypes\_spectating::setSpectatePermissions();

	if(isDefined(origin) && isDefined(angles))
		self spawn(origin, angles);
	else
	{
		spawnpointname = "mp_global_intermission";
		spawnpoints = getentarray(spawnpointname, "classname");
		spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(spawnpoints);

		if(isDefined(spawnpoint))
			self spawn(spawnpoint.origin, spawnpoint.angles);
		else
			maps\mp\_utility::error("NO " + spawnpointname + " SPAWNPOINTS IN MAP");
	}
}

spawnIntermission()
{
	self notify("spawned");

	resettimeout();

	// Stop shellshock and rumble
	self stopShellshock();
	self stoprumble("damage_heavy");

	self.sessionstate = "intermission";
	self.spectatorclient = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;

	spawnpointname = "mp_global_intermission";
	spawnpoints = getentarray(spawnpointname, "classname");
	spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(spawnpoints);

	if(isDefined(spawnpoint))
		self spawn(spawnpoint.origin, spawnpoint.angles);
	else
		maps\mp\_utility::error("NO " + spawnpointname + " SPAWNPOINTS IN MAP");
}

respawn()
{
	//self endon("disconnect");
	origin = self.origin;
	angles = self.angles;

	if (game["state"] == "readyup")
	{
		spawnPlayer();
	}
	else
	{
		spawnSpectator(origin, angles);

		self.wounded = true;
		self thread scripts\player\_reviving::reviving(origin, angles);

		self waittill("player_revived", success, reviving_player);
		self.wounded = undefined;

		lpselfnum = self getEntityNumber();
		lpGuid = self getGuid();
		logPrint("F;" + lpGuid + ";" + lpselfnum + ";" + self.name + ";" + success + "\n");

		if (success)
		{
			spawnPlayer(origin, angles);
		}
		else
		{
			// clean weapons
			self scripts\gametypes\_weapons::cleanWeapons();
			// clear buyed perks
			self scripts\gametypes\_shop::clearAll();

			self.account["deaths"]++;
		}
	}
}

forceSpawn()
{
	players = getEntArray("player", "classname");
	for (i = 0; i < players.size; i++)
	{
		player = players[i];

		if (isDefined(player.pers["class"]) && player.pers["class"] != "none")
		{
			if (player.sessionstate != "playing")
				player spawnPlayer();
			else
				player setHealth(player.maxhealth);
		}
	}
}

reborn()
{
	if (isDefined(self.pers["class"]) && self.pers["class"] != "none" && self.sessionstate != "playing")
	{
		if (isDefined(self.wounded) && self.wounded)
			self notify("player_revived", true, undefined);
		else
			self spawnPlayer();
	}
}

HasPlayingPlayer()
{
	players = getEntArray("player", "classname");
	for (i = 0; i < players.size; i++)
	{
		player = players[i];

		if (isDefined(player.pers["team"]) && player.pers["team"] == "allies" && player.sessionstate == "playing")
			return true;
	}

	return false;
}

StartGame()
{
	level endon("intermission");

	if (level.workAI)
	{
		while (!HasPlayingPlayer()) // wait for a player to enter the game
			wait 1;

		game["matchstarted"] = true;
		game["roundsplayed"] = 0;
		game["difficulty"] = 1;

		level.startTime = GetTime();

		for (i = 1; true; i++)
		{
			game["difficulty"] = 1 + (game["roundsplayed"] / level.difficulty);

			// Start the ready-up
			StartReadyUp(i);

			// Notification about the round start
			sendNotificationToAll(&"BZ_ROUND_STARTS", "", "MP_announcer_startround");

			// Start the mission
			StartRound(i);

			[[level.killAIs]](); // make sure to kill every AI

			wait .05;

			if (game["roundsuccess"] == "victory")
			{
				game["roundsplayed"] = i;
				sendNotificationToAll(&"BZ_ROUND_SURVIVED", "", "MP_announcer_endround");

				score = int(100 * game["difficulty"]);
				players = getEntArray("player", "classname");

				for (j = 0; j < players.size; j++)
				{
					player = players[j];
					
					if (isDefined(player.pers["team"]) && player.pers["team"] != "spectator" && player.sessionstate == "playing")
					{
						player.account["survived_rounds"]++;

						// give money and score on the end of the round
						player thread scripts\player\_rank::AddScore(score);
						
						// save weapons, so if the player die in the ready up period, the weapons won't lost
						player thread scripts\gametypes\_weapons::saveWeapons();
						
						player notify("update_money", score);
					}

					if (!(game["roundsplayed"] % level.bossRoundNum)) // last round survived, so increment the boss kills
					{
						player.account["boss_kills"]++;
						player thread scripts\player\_rank::AddScore(0);
					}
				}
			}
			else
			{
				sendNotificationToAll(&"BZ_ROUND_LOST", "", "MP_announcer_endround");
				break;
			}

			logPrint("R;" + game["roundsplayed"] + ";" + game["roundsuccess"] + "\n");
		}

		// Print and save game records
		game["time"] = int((GetTime() - level.startTime) * 0.001);
		//thread scripts\gametypes\_maprecordservice::CheckRecord();
	
		wait 10;
		// vote for next map
		level scripts\gametypes\_endmapvote::startVote();

		level thread EndMap();
	}
	else
	{
		for (;;)
		{
			iPrintln("^1ERROR Starting game");
			wait 5;
		}
	}
}

StartReadyUp(roundNum)
{
	game["state"] = "readyup";
	musicPlay("music");

	thread forceSpawn(); // spawn dead players and give max health for living players

	level.clock = newHudElem();
	level.clock.horzAlign = "center_safearea";
    level.clock.vertAlign = "top";
    level.clock.alignX = "center";
    level.clock.alignY = "top";
    level.clock.x = 0;
    level.clock.y = 10;
    level.clock.font = "default";
	level.clock.fontscale = 2.5;
	level.clock SetTimer(level.readyupTime);

	dt = 1;
	for (i = level.readyupTime; i > 0; i -= dt)
	{
		level.clock.alpha = 1;

		if (i < 10)
		{
			musicStop(5);

			level.clock fadeOverTime(dt * 1.5);
			level.clock.alpha = 0;

			playSoundOnPlayers("bomb_tick");
		}

		wait dt;
	}

	level.clock destroy();
}

StartRound(roundNum)
{
	game["roundsuccess"] = "none";
	game["state"] = "playing";
	level.startRoundTime = GetTime();
	
	if (!HasPlayingPlayer())
		return;

	// Start mission
	isBossRound = !(roundNum % level.bossRoundNum);
    missionIndex = 10; // horde mission index, see _missions.gsc
	
	/*if (isBossRound)
	{
		iPrintlnBold(&"BZ_FINAL_ROUND");
		musicPlay("bossmusic");
	}*/

	scripts\missions\_missions::StartMission(missionIndex);

	// Clear the mission objectives
	scripts\player\_hud::ClearObjectives();

	/*if (isBossRound)
		musicStop(5);*/

	level notify("round_ended");
}

EndMap()
{
	game["state"] = "intermission";
	level notify("intermission");

	if(game["roundsuccess"] == "victory")
	{
		winningteam = "survivors";
		losingteam = "zombies";
		text = &"BZ_SURVIVERS_WIN";
	}
	else
	{
		winningteam = "zombies";
		losingteam = "survivors";
		text = &"BZ_ZOMBIES_WIN";
	}

	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];

		player closeMenu();
		player closeInGameMenu();
	
		player scripts\gametypes\_accsys::Logout();
		player spawnIntermission();
	}

	if((winningteam == "survivors") || (winningteam == "zombies"))
	{
		logPrint("W;" + winningteam + "\n");
		logPrint("L;" + losingteam + "\n");
	}

	wait 15;
	exitLevel(false);
}

printJoinedClass(class)
{
	if(class == "hunter")
		iprintln(&"BZ_JOINED_HUNTER", self);
	else if(class == "medic")
		iprintln(&"BZ_JOINED_MEDIC", self);
	else if(class == "banker")
		iprintln(&"BZ_JOINED_BANKER", self);
}

getClassDefaultWeapon(class)
{
	switch (class)
	{
		case "hunter":
			return "mp5_mp";
		case "medic":
			return "m14_mp";
		case "banker":
			return "m1014_mp";
		default:
			return undefined;
	}
}

menuLogin()
{
	statusCode = self scripts\gametypes\_accsys::Login();

	if (!statusCode)
		self setClientCvar("g_scriptMainMenu", game["menu_team"]);

	return statusCode;
}

menuRegister()
{
	statusCode = self scripts\gametypes\_accsys::Register();
	
	if (!statusCode)
		self setClientCvar("g_scriptMainMenu", game["menu_team"]);

	return statusCode;
}

menuLogout()
{
	statusCode = self scripts\gametypes\_accsys::Logout();
	
	self menuSpectator();
	self setClientCvar("g_scriptMainMenu", game["menu_ingame"]);

	return statusCode;
}

menuAutoAssign()
{
	numonclass["hunter"] = 0;
	numonclass["medic"] = 0;
	numonclass["banker"] = 0;

	players = getEntArray("player", "classname");
	for (i = 0; i < players.size; i++)
	{
		player = players[i];

		if (!isDefined(player.pers["class"]) || player.pers["class"] == "none" || player == self)
			continue;
		
		numonclass[player.pers["class"]]++;
	}

	min = numonclass["hunter"];
	leastIndices = [];
	for (i = 0; i < level.classnames.size; i++)
	{
		if (numonclass[level.classnames[i]] <= min)
		{
			if (numonclass[level.classnames[i]] < min)
				leastIndices = [];

			leastIndices[leastIndices.size] = i;
			min = numonclass[level.classnames[i]];
		}
	}

	menuJoinClass(level.classnames[array_randomItem(leastIndices)]);
}

menuJoinClass(classname)
{
	if (self.pers["class"] == classname || !self.isLogined)
		return;

	if (game["state"] == "readyup" || self.pers["class"] == "none")
	{
		if (self.sessionstate == "playing")
		{
			self.switching_class = true;
			self suicide();
		}
		
		self.pers["team"] = "allies";
		self.pers["class"] = classname;
		self.pers["weapon"] = getClassDefaultWeapon(classname);
		self.pers["savedmodel"] = undefined;

		self setClientCvar("ui_allow_autoassign", "0");
		self setClientCvar("g_scriptMainMenu", game["menu_team"]);

		if (game["state"] == "readyup")
			spawnPlayer();

		printJoinedClass(self.pers["class"]);

		self notify("joined_team");
	}
	else
	{
		self iPrintlnBold(&"BZ_CANT_JOIN");
	}
}

menuSpectator()
{
	if(self.pers["team"] != "spectator")
	{
		if(isAlive(self))
		{
			self.switching_class = true;
			self suicide();
		}

		self.pers["team"] = "spectator";
		self.pers["class"] = "none";
		self.pers["weapon"] = undefined;
		self.pers["savedmodel"] = undefined;

		self.sessionteam = "spectator";
		self setClientCvar("ui_allow_autoassign", "1");
		self setClientCvar("g_scriptMainMenu", game["menu_team"]);

		spawnSpectator();

		self notify("joined_spectators");
	}
}

playSoundOnPlayers(sound, team)
{
	players = getentarray("player", "classname");

	if(isdefined(team))
	{
		for(i = 0; i < players.size; i++)
		{
			if((isdefined(players[i].pers["team"])) && (players[i].pers["team"] == team))
				players[i] playLocalSound(sound);
		}
	}
	else
	{
		for(i = 0; i < players.size; i++)
			players[i] playLocalSound(sound);
	}
}