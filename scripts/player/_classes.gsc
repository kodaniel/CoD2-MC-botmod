#include scripts\_utils;

init()
{
	[[level.addCallback]]("onConnect", ::RunOnConnect);
	[[level.addCallback]]("onPlayerSpawned", ::RunOnSpawn);

	level.classnames = [];
	level.classnames[0] = "hunter";
	level.classnames[1] = "medic";
	level.classnames[2] = "banker";

	level.classIcons = [];
	level.classIcons["hunter"]	= "rndl_statusicon_swordman";
	level.classIcons["medic"]	= "rndl_statusicon_doctor";
	level.classIcons["banker"]	= "rndl_statusicon_banker";

	for (i = 0; i < level.classnames.size; i++)
	{
		classname = level.classnames[i];

		if (level.classIcons[classname] != "")
			[[level.r_precacheStatusIcon]](level.classIcons[classname]);
	}

	[[level.r_precacheFX]]("health_buff", "fx/rndl/hpbuff.efx");

	level.bonus_addhealth = 2;
	level.bonus_adddamage = 1.5;
	level.bonus_addmoney = 1.25;
	level.bonusdist = 62500; // 250

	thread medicHealing();
}

RunOnConnect()
{
	self.healing = undefined;
	self.bonusdist = level.bonusdist;
}

RunOnSpawn()
{
	self endon("disconnect");
	self endon("killed_player");

	for (;;)
	{
		self.pers["hasbonus_hunter"] = false;
		self.pers["hasbonus_medic"] = false;
		self.pers["hasbonus_banker"] = false;

		// check bonuses
		players = getEntArray("player", "classname");
		for (i = 0; i < players.size; i++)
		{
			player = players[i];

			if (player.sessionstate != "playing" || !isDefined(player.pers["class"]) || player.pers["class"] == "none")
				continue;

			if (self.pers["hasbonus_" + player.pers["class"]])
				continue;

			self.pers["hasbonus_" + player.pers["class"]] = distanceSquared(self.origin, player.origin) <= player.bonusdist;
		}

		self setClientCvar("ui_allow_bonus_hunter", self.pers["hasbonus_hunter"]);
		self setClientCvar("ui_allow_bonus_medic", self.pers["hasbonus_medic"]);
		self setClientCvar("ui_allow_bonus_banker", self.pers["hasbonus_banker"]);
		
		wait 1;
	}
}

medicHealing()
{
	for (;;)
	{
		medicCount = 0;
		players = getEntArray("player", "classname");
		alivePlayers = [];
		for (i = 0; i < players.size; i++)
		{
			if (players[i].sessionstate == "playing")
			{
				alivePlayers[alivePlayers.size] = players[i];

				if (players[i].pers["class"] == "medic")
					medicCount++;
			}
		}

		alivePlayers = sortPlayersByHealth(alivePlayers);
		for (i = 0; i < alivePlayers.size && medicCount > 0; i++)
		{
			player = alivePlayers[i];

			if (player.sessionstate != "playing" || player.health >= player.maxhealth)
				continue;

			if (player.pers["hasbonus_medic"])
			{
				medicCount--;

				player setHealth(player.health + level.bonus_addhealth);
				playFx(level.FXs["health_buff"], player.origin);
			}
		}

		wait 1;
	}
}

sortPlayersByHealth(players)
{
	temp = players;
	for (i = 0; i < temp.size - 1; i++)
	{
		for (j = i + 1; j < temp.size; j++)
		{
			if (temp[i].health > temp[j].health)
			{
				var = temp[i];
				temp[i] = temp[j];
				temp[j] = var;
			}
		}
	}

	return temp;
}

AddDamageBonus(damage)
{
	if (self.pers["hasbonus_hunter"])
		damage *= level.bonus_adddamage;

	return damage;
}

AddMoneyBonus(money)
{
	if (self.pers["hasbonus_banker"])
		money *= level.bonus_addmoney;

	return money;
}