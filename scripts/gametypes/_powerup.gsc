#include scripts\_utils;

init()
{
	game["model_skull"] = "xmodel/oma_skull_";
	[[level.r_precacheModel]](game["model_skull"]);

	level.odds = cvarDef("int", "scr_botmod_powerup_odds", 5, 0, 100);

	definePowerUp("ammo", 24, "rndl_hud_powerup_ammo", &"Max ammo", "powerup_ammo", ::powerup_maxAmmo);
	definePowerUp("bomb", 5, "rndl_hud_powerup_bomb", &"Kaboom", "powerup_bomb", ::powerup_bomb);
	definePowerUp("toss", 10, "rndl_hud_powerup_stinky", &"Ewww...", "powerup_stinky", ::powerup_stinky);
	definePowerUp("health", 20, "rndl_hud_powerup_health", &"Bandage", "powerup_health", ::powerup_playerMaxHealth);
	definePowerUp("doghealth", 10, "rndl_hud_powerup_dog", &"Dogeee", "powerup_health", ::powerup_dogMaxHealth, ::check_dogs);
	definePowerUp("doublepoint", 10, "rndl_hud_powerup_point", &"Double point", "powerup_doublepoint", ::powerup_doublePoint);
	definePowerUp("reborn", 10, "rndl_hud_powerup_reborn", &"Resurrect the dead", "powerup_reborn", ::powerup_resurrectDead, ::check_dead);
	definePowerUp("randomweapon", 1, "rndl_hud_powerup_random", &"Random weapon", "powerup_random", ::powerup_randomWeapon);
	definePowerUp("instakill", 5, "rndl_hud_powerup_instakill", &"Instakill", "powerup_instakill", ::powerup_instakill);
	definePowerUp("killscores", 5, "rndl_hud_powerup_100ks", &"Kill scores", "powerup_100ks", ::powerup_killscores);

	thread UpdateCvar();
}

definePowerUp(name, odds, hudicon, hudtext, sound, startFunc, checkFunc)
{
	if (!isDefined(level.powerups))
		level.powerups = [];
	
	i = level.powerups.size;
	level.powerups[i]		= spawnStruct();
	level.powerups[i].name	= name;
	level.powerups[i].odds	= odds;
	level.powerups[i].icon	= hudicon;
	level.powerups[i].text	= hudtext;
	level.powerups[i].snd	= sound;
	level.powerups[i].func	= startFunc;
	level.powerups[i].check	= checkFunc;

	if (isDefined(hudicon))
		[[level.r_precacheShader]](hudicon);
	if (isDefined(hudtext))
		[[level.r_precacheString]](hudtext);
}

UpdateCvar()
{
	for (;;)
	{
		wait 10;
		level.odds = getCvarInt("scr_botmod_powerup_odds");
	}
}

GivePowerupRandomly(origin, angles)
{
	if (!random_percentage(level.odds))
		return;

	sum = 0;
	newarray = [];
	for (i = 0; i < level.powerups.size; i++)
	{
		if (!isDefined(level.powerups[i].check) || [[level.powerups[i].check]]())
			sum += level.powerups[ i ].odds;
		newarray[ i ] = sum;
	}

	num = randomInt( sum ) + 1;
	powerup = undefined;
	for (i = 0; i < newarray.size; i++)
	{
		if (num < newarray[ i ])
		{
			powerup = level.powerups[ i ];
			break;
		}
	}

	if (isDefined(powerup))
		thread [[powerup.func]](origin, angles, powerup);
}

sendNotificationToAll(string, icon, sound)
{
	players = getAllPlayers();
	for (i = 0; i < players.size; i++)
	{
		player = players[i];

		player scripts\player\_notification::Notification(string, icon, sound);
	}
}

watchPlayers( point )
{
	self endon("destroy_powerup");

	for (;;)
	{
		players = getEntArray("player", "classname");
		for (i = 0; i < players.size; i++)
		{
			player = players[i];
			if (player.sessionstate != "playing")
				continue;

			if (distanceSquared(player.origin, point) > 2304)
				continue;

			return player;
		}
		wait 0.1;
	}
}

delay(time, note)
{
	self endon(note);
	wait time;
	self notify(note);
}

spawnPowerUp(origin, material)
{
	// model
	powerup = spawn("script_model", origin + (0,0,16));
	powerup setModel(game["model_skull"]);
	// hud image
	powerup.objpoint		= newHudElem();
	powerup.objpoint.x		= origin[0];
	powerup.objpoint.y		= origin[1];
	powerup.objpoint.z		= origin[2] + 32;
	powerup.objpoint.alpha	= 1;
	powerup.objpoint SetShader(material, 6, 6);
	powerup.objpoint SetWaypoint(true);

	return powerup;
}

destroyPowerUp()
{
	self waittill("destroy_powerup");

	self.objpoint destroy();
	self delete();
}

powerUpAnimation(time)
{
	self endon("destroy_powerup");
	self rotateYaw(180 * time, time);

	frequency = 5;
	for (t = time * frequency; t > 0; t --)
	{
		if (t <= 3 * frequency && !(t & 2))
			self.objpoint.alpha = 0;
		else
			self.objpoint.alpha = 1;

		wait 1 / frequency;
	}
}

powerup_maxAmmo(origin, angles, powerupType)
{
	aliveTime = 10;

	powerup = spawnPowerUp(origin, powerupType.icon);
	powerup thread destroyPowerUp();
	powerup thread powerUpAnimation(aliveTime);
	powerup thread delay(aliveTime, "destroy_powerup");

	// wait for picking up by a player
	player = powerup watchPlayers(origin);
	powerup notify("destroy_powerup");

	if (!isDefined(player))
		return;

	player scripts\player\_notification::Notification(powerupType.text, powerupType.icon, powerupType.snd);

	if (level.sprint)
	{
		player endon("disconnect");

		while (isDefined(player._sprintweapon) && player hasWeapon(player._sprintweapon))
			wait 0.05;
	}

	// Add max ammo
	if (isDefined(player.pers["weapon1"]) && player.pers["weapon1"] != "none")
		player giveMaxAmmo(player.pers["weapon1"]);
	if (isDefined(player.pers["weapon2"]) && player.pers["weapon2"] != "none")
		player giveMaxAmmo(player.pers["weapon2"]);
}

powerup_bomb(origin, angles, powerupType)
{
	aliveTime = 10;

	powerup = spawnPowerUp(origin, powerupType.icon);
	powerup thread destroyPowerUp();
	powerup thread powerUpAnimation(aliveTime);
	powerup thread delay(aliveTime, "destroy_powerup");

	// wait for picking up by a player
	player = powerup watchPlayers(origin);
	powerup notify("destroy_powerup");

	if (!isDefined(player))
		return;

	for (i = 0; i < level.AItypes.size; i++)
	{
		typeName = level.AItypes[i];
		
		if (isDefined(level.AIType[typeName].canHitSpecial) && !level.AIType[typeName].canHitSpecial)
			continue;

		scripts\_ai::KillAIs(typeName);
	}

	sendNotificationToAll(powerupType.text, powerupType.icon, powerupType.snd);
}

powerup_stinky(origin, angles, powerupType)
{
	aliveTime = 10;

	powerup = spawnPowerUp(origin, powerupType.icon);
	powerup thread destroyPowerUp();
	powerup thread powerUpAnimation(aliveTime);
	powerup thread delay(aliveTime, "destroy_powerup");

	// wait for picking up by a player
	player = powerup watchPlayers(origin);
	powerup notify("destroy_powerup");

	if (!isDefined(player))
		return;

	player notify("pickedup_stinky");
	player endon("pickedup_stinky");
	player endon("disconnect");

	player scripts\player\_notification::Notification(powerupType.text, powerupType.icon, powerupType.snd);
	player thread scripts\player\_hud::AddTimer(10, (0.27,0.4,0.78));

	player.invisibilities = add_to_array(player.invisibilities, "stinky", false);
	wait 10;
	player.invisibilities = array_remove(player.invisibilities, "stinky");
}

powerup_playerMaxHealth(origin, angles, powerupType)
{
	aliveTime = 10;

	powerup = spawnPowerUp(origin, powerupType.icon);
	powerup thread destroyPowerUp();
	powerup thread powerUpAnimation(aliveTime);
	powerup thread delay(aliveTime, "destroy_powerup");

	// wait for picking up by a player
	player = powerup watchPlayers(origin);
	powerup notify("destroy_powerup");

	if (!isDefined(player))
		return;

	player scripts\player\_notification::Notification(powerupType.text, powerupType.icon, powerupType.snd);
	player SetHealth(player.maxhealth);
}

powerup_dogMaxHealth(origin, angles, powerupType)
{
	aliveTime = 10;

	powerup = spawnPowerUp(origin, powerupType.icon);
	powerup thread destroyPowerUp();
	powerup thread powerUpAnimation(aliveTime);
	powerup thread delay(aliveTime, "destroy_powerup");

	// wait for picking up by a player
	player = powerup watchPlayers(origin);
	powerup notify("destroy_powerup");

	if (!isDefined(player))
		return;

	player scripts\player\_notification::Notification(powerupType.text, powerupType.icon, powerupType.snd);

	// set the bonus
	if (player.buyed["pet"])
	{
		playerUbul = undefined;
		for (i = 0; i < level.friendlyAIs.size; i++)
		{
			if (level.friendlyAIs[i].parent == player)
			{
				playerUbul = level.friendlyAIs[i];
				break;
			}
		}

		if (!isDefined(playerUbul))
			return;
		
		playerUbul.health = playerUbul.maxhealth;
		player notify("update_doghealthbar");
	}
}

powerup_doublePoint(origin, angles, powerupType)
{
	aliveTime = 10;

	powerup = spawnPowerUp(origin, powerupType.icon);
	powerup thread destroyPowerUp();
	powerup thread powerUpAnimation(aliveTime);
	powerup thread delay(aliveTime, "destroy_powerup");

	// wait for picking up by a player
	player = powerup watchPlayers(origin);
	powerup notify("destroy_powerup");

	if (!isDefined(player))
		return;

	level notify("pickedup_doublepoint");
	level endon("pickedup_doublepoint");

	players = getAllPlayers();
	for (i = 0; i < players.size; i++)
	{
		player = players[i];

		if (player.sessionstate == "playing")
			player thread scripts\player\_hud::AddTimer(30, (.92, .90, .20));

		player scripts\player\_notification::Notification(powerupType.text, powerupType.icon, powerupType.snd);
	}

	level.doublepoint = 2;
	wait 30;
	level.doublepoint = 1;
}

powerup_resurrectDead(origin, angles, powerupType)
{
	aliveTime = 10;

	powerup = spawnPowerUp(origin, powerupType.icon);
	powerup thread destroyPowerUp();
	powerup thread powerUpAnimation(aliveTime);
	powerup thread delay(aliveTime, "destroy_powerup");

	// wait for picking up by a player
	player = powerup watchPlayers(origin);
	powerup notify("destroy_powerup");

	if (!isDefined(player))
		return;
	
	players = getEntArray("player", "classname");
	for (i = 0; i < players.size; i++)
	{
		players[i] [[level.reborn]]();
	}
	
	sendNotificationToAll(powerupType.text, powerupType.icon, powerupType.snd);
}

powerup_randomWeapon(origin, angles, powerupType)
{
	aliveTime = 10;

	powerup = spawnPowerUp(origin, powerupType.icon);
	powerup thread destroyPowerUp();
	powerup thread powerUpAnimation(aliveTime);
	powerup thread delay(aliveTime, "destroy_powerup");

	// wait for picking up by a player
	player = powerup watchPlayers(origin);
	powerup notify("destroy_powerup");

	if (!isDefined(player))
		return;

	player scripts\player\_notification::Notification(powerupType.text, powerupType.icon, powerupType.snd);

	if (level.sprint)
	{
		player endon("disconnect");

		while (isDefined(player._sprintweapon) && player hasWeapon(player._sprintweapon))
			wait 0.05;
	}

	randomWeapons[0] = "minigun_mp";
	randomWeapons[1] = "flamethrower_mp";
	randomWeapons[2] = "raygun_mark2_mp";
	randomWeapons[3] = "wunderwaffe_mp";
	randomWeapons[4] = "mg42_mp";
	randomWeapons[5] = "barrett_mp";
	randomWeapons[6] = "bow_mp";

	player scripts\gametypes\_weapons::addWeapon(randomWeapons[randomInt(randomWeapons.size)]);
}

powerup_instakill(origin, angles, powerupType)
{
	aliveTime = 10;
	activeTime = 8;

	powerup = spawnPowerUp(origin, powerupType.icon);
	powerup thread destroyPowerUp();
	powerup thread powerUpAnimation(aliveTime);
	powerup thread delay(aliveTime, "destroy_powerup");

	// wait for picking up by a player
	player = powerup watchPlayers(origin);
	powerup notify("destroy_powerup");

	if (!isDefined(player))
		return;

	level notify("pickedup_instakill");
	level endon("pickedup_instakill");

	players = getAllPlayers();
	for (i = 0; i < players.size; i++)
	{
		player = players[i];

		if (player.sessionstate == "playing")
			player thread scripts\player\_hud::AddTimer(activeTime, (.9, .1, .1));

		player scripts\player\_notification::Notification(powerupType.text, powerupType.icon, powerupType.snd);
	}

	level.instakill = true;
	wait activeTime;
	level.instakill = undefined;
}

powerup_killscores(origin, angles, powerupType)
{
	aliveTime = 10;

	powerup = spawnPowerUp(origin, powerupType.icon);
	powerup thread destroyPowerUp();
	powerup thread powerUpAnimation(aliveTime);
	powerup thread delay(aliveTime, "destroy_powerup");

	// wait for picking up by a player
	player = powerup watchPlayers(origin);
	powerup notify("destroy_powerup");

	if (!isDefined(player))
		return;

	player scripts\player\_notification::Notification(powerupType.text, powerupType.icon, powerupType.snd);
	
	player.account["killscore"] += 100;
	player notify("update_streakscore");
}

check_dogs()
{
	return level.friendlyAIs.size > 0;
}

check_dead()
{
	players = getEntArray("player", "classname");
	for (i = 0; i < players.size; i++)
	{
		player = players[i];
		if (player.sessionstate != "playing" && isDefined(player.pers["class"]) && player.pers["class"] != "none")
			return true;
	}

	return false;
}