#include scripts\_utils;

init()
{
	level.weapons = [];
	
	// Pistols
	[[level.r_precacheItem]]("colt_mp");
	[[level.r_precacheItem]]("beretta_mp");
	[[level.r_precacheItem]]("usp_mp");
	[[level.r_precacheItem]]("deagle_mp");

	// ww2
	_addWeapon("greasegun_mp", &"WEAPON_GREASEGUN", "xmodel/weapon_greasegun", 3, 1.0);
	_addWeapon("thompson_mp", &"WEAPON_THOMPSON", "xmodel/weapon_thompson", 3, 1.0);
	_addWeapon("bar_mp", &"WEAPON_BAR", "xmodel/weapon_bar", 3, 1.0);
	_addWeapon("ppsh_mp", &"WEAPON_PPSH", "xmodel/weapon_ppsh", 4, 1.0);
	_addWeapon("pps42_mp", &"WEAPON_PPS42", "xmodel/weapon_pps43", 3, 1.0);
	_addWeapon("mp40_mp", &"WEAPON_MP40", "xmodel/weapon_mp40", 3, 1.0);
	_addWeapon("mp44_mp", &"WEAPON_MP44", "xmodel/weapon_mp44", 3, 1.0);
	_addWeapon("enfield_mp", &"WEAPON_LEEENFIELD", "xmodel/weapon_enfield", 2, 1.0);
	_addWeapon("enfield_scope_mp", &"WEAPON_SCOPEDLEEENFIELD", "xmodel/weapon_enfield_scope", 3, 1.0);
	_addWeapon("springfield_mp", &"WEAPON_SPRINGFIELD", "xmodel/weapon_springfield", 3, 1.0);
	_addWeapon("shotgun_mp", &"WEAPON_SHOTGUN", "xmodel/weapon_trenchgun", 3, 1.0);
	_addWeapon("m1garand_mp", &"WEAPON_M1GARAND", "xmodel/weapon_m1garand", 3, 1.0);
	_addWeapon("g43_mp", &"WEAPON_G43", "xmodel/weapon_g43", 2, 1.0);
	_addWeapon("svt40_mp", &"WEAPON_SVT40", "xmodel/weapon_svt40", 2, 1.0);
	_addWeapon("bren_mp", &"WEAPON_BREN", "xmodel/weapon_bren", 3, 1.0);
	_addWeapon("mosin_nagant_mp", &"WEAPON_MOSINNAGANT", "xmodel/weapon_mosinnagant", 3, 1.0);
	_addWeapon("m1carbine_mp", &"WEAPON_M1A1CARBINE", "xmodel/weapon_m1carbine", 3, 1.0);
	_addWeapon("mg42_mp", &"WEAPON_MG42", "xmodel/weapon_ger_mg42", 3, 1.0);

	// modern
	_addWeapon("ak47_mp", &"WEAPON_AK47", "xmodel/ak47_w", 3, 1.0);
	_addWeapon("ak74_mp", &"WEAPON_AK74", "xmodel/ak74_w", 3, 1.0);
	_addWeapon("barrett_mp", &"WEAPON_BARRETT", "xmodel/m82_w", 3, 1.0);
	_addWeapon("g36_mp", &"WEAPON_G36C", "xmodel/g36_w", 3, 1.0);
	_addWeapon("m1014_mp", &"WEAPON_M1014", "xmodel/benelli_w", 3, 1.0);
	_addWeapon("m249_mp", &"WEAPON_SAW", "xmodel/weapon_m249", 3, 1.0);
	_addWeapon("rpd_mp", &"WEAPON_RPD", "xmodel/rpd_w", 3, 1.0);
	_addWeapon("mp5_mp", &"WEAPON_MP5", "xmodel/mp5_v", 4, 1.0);
	_addWeapon("m40a3_mp", &"WEAPON_M40A3", "xmodel/m40a3_w", 3, 1.0);
	_addWeapon("m14_mp", &"WEAPON_M14", "xmodel/m14_w", 3, 1.0);
	_addWeapon("m60_mp", &"WEAPON_M60", "xmodel/weapon_m60", 2, 1.0);
	
	// future
	_addWeapon("m8a1_mp", &"WEAPON_M8A1", "xmodel/oma_m8a1_w", 3, 1.0);
	_addWeapon("pdw57_mp", &"WEAPON_PDW57", "xmodel/oma_pdw57_w", 4, 1.0);
	_addWeapon("aa12_mp", &"WEAPON_AA12", "xmodel/oma_aa12_w", 3, 1.0);
	_addWeapon("dsr50_mp", &"WEAPON_DSR50", "xmodel/oma_dsr50_w", 2, 1.0);
	_addWeapon("wa2000_mp", &"WEAPON_WA2000", "xmodel/oma_wa2000_w", 2, 1.0);

	// special
	_addWeapon("minigun_mp", &"WEAPON_MINIGUN", "xmodel/weapon_minigun", 3, 0.8);
	_addWeapon("raygun_mp", &"WEAPON_RAYGUN", "xmodel/ray_gun_w", 4, 1.0, ::slowingDown);
	_addWeapon("raygun_mark2_mp", &"WEAPON_RAYGUNM2", "xmodel/weapon_raygun_mark_2", 3, 1.0);
	_addWeapon("wunderwaffe_mp", &"WEAPON_WUNDERWAFFE", "xmodel/weapon_wunderwaffe_dg2", 3, 1.0, ::hitElectroShock);
	_addWeapon("bow_mp", &"WEAPON_BOW", "xmodel/weapon_bow", 4, 1.0, ::scaledDamage);
	_addWeapon("flamethrower_mp", &"WEAPON_FLAMETHROWER", "xmodel/tc_flamethrower_w", 3, 1.0);
	_addWeapon("panzerschreck_mp", &"WEAPON_PANZERSCHRECK", "xmodel/weapon_panzerschreck", 1, 0.5, undefined, ::projectile);

	[[level.addCallback]]("onPlayerSpawned", ::RunOnSpawn);
	[[level.addCallback]]("onZombieDamage", ::RunOnZombieDamage);

	[[level.r_precacheFX]]("wunderwaffe_shock", "fx/misc/electric_shock.efx");
}

RunOnSpawn()
{
	self thread MonitorWeaponSlots();
	self thread MonitorShooting();
}

RunOnZombieDamage(eAttacker, iDamage, argument)
{
	if (isPlayer(eAttacker))
	{
		sWeapon = eAttacker getCurrentWeapon();

		if (isDefined(level.weapons[sWeapon]) && isDefined(level.weapons[sWeapon].callbackOnHit))
			eAttacker thread [[level.weapons[sWeapon].callbackOnHit]](self, iDamage, sWeapon, argument);
	}
}

MonitorWeaponSlots()
{
	self endon("disconnect");
	self endon("killed_player");

	for (;;)
	{
		currentWeapon = self getCurrentWeapon();
		primaryWeapon = self getWeaponSlotWeapon("primary");
		secondaryWeapon = self getWeaponSlotWeapon("primaryb");

		if (isDefined(level.weapons[primaryWeapon]) && isDefined(level.weapons[primaryWeapon].callbackOnOwning))
			self thread [[level.weapons[primaryWeapon].callbackOnOwning]](currentWeapon == primaryWeapon);

		if (isDefined(level.weapons[secondaryWeapon]) && isDefined(level.weapons[secondaryWeapon].callbackOnOwning))
			self thread [[level.weapons[secondaryWeapon].callbackOnOwning]](currentWeapon == secondaryWeapon);

		wait 0.05;
	}
}

MonitorShooting()
{
	self endon("disconnect");
	self endon("killed_player");

	for (;;)
	{
		oldweap = self getCurrentWeapon();
		oldammo = self getWeaponSlotClipAmmo(self getCurrentWeaponSlot());

		wait 0.05;

		curweap = self getCurrentWeapon();
		curammo = self getWeaponSlotClipAmmo(self getCurrentWeaponSlot());

		if (oldweap == curweap && curammo < oldammo)
		{
			self notify("player_shot", curweap);

			if (isDefined(level.weapons[curweap]) && isDefined(level.weapons[curweap].callbackOnShoot))
				self thread [[level.weapons[curweap].callbackOnShoot]](curammo, oldammo);
		}
	}
}

_addWeapon(weapon, weaponName, worldModel, dropChance, moneyMultiplier, callbackOnHit, callbackOnShoot, callbackOnOwning)
{
	if (!isDefined(level.weaponNames))
		level.weaponNames = [];

	if (!isDefined(moneyMultiplier))
	{
		iPrintln("^1ERROR: Couldn't add weapon. Some mandatory arguments are undefined.");
		return;
	}

	level.weaponNames[level.weaponNames.size] = weapon;

	level.weapons[weapon] = spawnStruct();
	level.weapons[weapon].weaponName = weaponName;
	level.weapons[weapon].worldModel = worldModel;
	level.weapons[weapon].dropChance = dropChance;
	level.weapons[weapon].moneyMultiplier = moneyMultiplier;
	level.weapons[weapon].callbackOnOwning = callbackOnOwning;
	level.weapons[weapon].callbackOnShoot = callbackOnShoot;
	level.weapons[weapon].callbackOnHit = callbackOnHit;

	[[level.r_precacheItem]](weapon);

	if (isDefined(worldModel) && worldModel != "")
		[[level.r_precacheModel]](worldModel);
}

getWeightedRandomWeapon()
{
	range = 0;
	for (i = 0; i < level.weaponNames.size; i++)
		range += level.weapons[level.weaponNames[i]].dropChance;

	rnd = randomInt(range);
	range = 0;
	for (i = 0; i < level.weaponNames.size; i++)
	{
		range += level.weapons[level.weaponNames[i]].dropChance;

		if (rnd <= range)
			return level.weaponNames[i];
	}
}

getRandomWeapon()
{
	return level.weaponNames[randomInt(level.weaponNames.size)];
}

givePistol()
{
	weapon2 = self getweaponslotweapon("primaryb");
	if (weapon2 == "none")
	{
		if (self.pers["rank"] < 5)
			pistoltype = "colt_mp";
		else if (self.pers["rank"] < 10)
			pistoltype = "beretta_mp";
		else if (self.pers["rank"] < 15)
			pistoltype = "usp_mp";
		else
			pistoltype = "deagle_mp";

		self takeWeapon(pistoltype);
		self setWeaponSlotWeapon("primaryb", pistoltype);
		self giveMaxAmmo(pistoltype);
	}
}

dropWeapon()
{
	current = self getcurrentweapon();
	if(current != "none")
	{
		weapon1 = self getweaponslotweapon("primary");
		weapon2 = self getweaponslotweapon("primaryb");

		if(current == weapon1)
			currentslot = "primary";
		else
		{
			assert(current == weapon2);
			currentslot = "primaryb";
		}

		clipsize = self getweaponslotclipammo(currentslot);
		reservesize = self getweaponslotammo(currentslot);

		if(clipsize || reservesize)
			self dropItem(current);
	}
}

dropOffhand()
{
	current = self getcurrentoffhand();
	if(current != "none")
	{
		ammosize = self getammocount(current);

		if(ammosize)
			self dropItem(current);
	}
}

getFragGrenadeCount()
{
	if(self.pers["team"] == "allies")
		grenadetype = "frag_grenade_" + game["allies"] + "_mp";
	else
	{
		assert(self.pers["team"] == "axis");
		grenadetype = "frag_grenade_" + game["axis"] + "_mp";
	}

	count = self getammocount(grenadetype);
	return count;
}

getSmokeGrenadeCount()
{
	if(self.pers["team"] == "allies")
		grenadetype = "smoke_grenade_" + game["allies"] + "_mp";
	else
	{
		assert(self.pers["team"] == "axis");
		grenadetype = "smoke_grenade_" + game["axis"] + "_mp";
	}

	count = self getammocount(grenadetype);
	return count;
}

getWeaponName(weapon)
{
	for (i = 0; i < level.weaponNames.size; i++)
	{
		if (level.weaponNames[i] == weapon)
			return level.weapons[weapon].weaponName;
	}

	return &"WEAPON_UNKNOWNWEAPON";
}

saveWeapons()
{
	self endon("disconnect");

	if (level.sprint)
	{
		while (isDefined(self._sprintweapon) && self hasWeapon(self._sprintweapon))
			wait 0.05;
	}

	self.pers["weapon1"]		= self getWeaponSlotWeapon("primary");
	self.pers["weapon1_ammo"]	= self getWeaponSlotAmmo("primary");
	self.pers["weapon1_clip"]	= self getWeaponSlotClipAmmo("primary");
	self.pers["weapon2"]		= self getWeaponSlotWeapon("primaryb");
	self.pers["weapon2_ammo"]	= self getWeaponSlotAmmo("primaryb");
	self.pers["weapon2_clip"]	= self getWeaponSlotClipAmmo("primaryb");
	self.pers["spawnweapon"]	= self getCurrentWeapon();
}

loadWeapons()
{
	self endon("disconnect");

	if (level.sprint)
	{
		while (isDefined(self._sprintweapon) && self hasWeapon(self._sprintweapon))
			wait 0.05;
	}

	self setWeaponSlotWeapon("primary", self.pers["weapon1"]);
	self setWeaponSlotAmmo("primary", self.pers["weapon1_ammo"]);
	self setWeaponSlotClipAmmo("primary", self.pers["weapon1_clip"]);
	self setWeaponSlotWeapon("primaryb", self.pers["weapon2"]);
	self setWeaponSlotAmmo("primaryb", self.pers["weapon2_ammo"]);
	self setWeaponSlotClipAmmo("primaryb", self.pers["weapon2_clip"]);

	if (isDefined(self.pers["spawnweapon"]) && self.pers["spawnweapon"] != "none")
		self switchToWeapon(self.pers["spawnweapon"]);
}

cleanWeapons()
{
	self.pers["weapon1"]		= undefined;
	self.pers["weapon1_ammo"]	= undefined;
	self.pers["weapon1_clip"]	= undefined;
	self.pers["weapon2"]		= undefined;
	self.pers["weapon2_ammo"]	= undefined;
	self.pers["weapon2_clip"]	= undefined;
	self.pers["spawnweapon"]	= undefined;
}

addWeapon(weapon)
{
	if (! isDefined(self.pers["team"]) || (self.pers["team"] != "allies" && self.pers["team"] != "axis"))
		return;

	// If already have this weapon, give max ammo
	if (isDefined(self.pers["weapon1"]) && self.pers["weapon1"] == weapon)
	{
		self giveMaxAmmo(self.pers["weapon1"]);
		self switchToWeapon(self.pers["weapon1"]);
		return;
	}
	else if (isDefined(self.pers["weapon2"]) && self.pers["weapon2"] == weapon)
	{
		self giveMaxAmmo(self.pers["weapon2"]);
		self switchToWeapon(self.pers["weapon2"]);
		return;
	}

	// Check the current weapon slot
	currentslot = self getCurrentWeaponSlot();
	if (currentslot == "primary")
	{
		slotweaponb = self getWeaponSlotWeapon("primaryb");
		// If primaryb is none then set the weapon as primaryb
		if (slotweaponb == "none")
		{
			self setWeaponSlotWeapon("primaryb", weapon);
			self.pers["weapon2"] = weapon;
		}
		else
		{
			self setWeaponSlotWeapon(currentslot, weapon);
			self.pers["weapon1"] = weapon;
		}
	}
	else
	{
		slotweapon = self getWeaponSlotWeapon("primary");
		// If primary is none then set the weapon as primary
		if (slotweapon == "none")
		{
			self setWeaponSlotWeapon("primary", weapon);
			self.pers["weapon1"] = weapon;
		}
		else
		{
			self setWeaponSlotWeapon(currentslot, weapon);
			self.pers["weapon2"] = weapon;
		}
	}
	self.pers["spawnweapon"] = self.pers["weapon1"];
	self switchToWeapon(weapon);
}

hitElectroShock(zombie, damage, weapon, argument)
{
	orig = zombie.origin;

	if (isDefined(argument) && argument == "noshock")
		return;

	maxHitCount = 5; // hits max 5 zombies
	counter = 0;
	for (i = 0; i < level.AIs.size && counter < maxHitCount; i++)
	{
		zom = level.AIs[i];

		if (zom == zombie)
			continue;

		if (distanceSquared(zom.origin, orig) < 10000)
		{
			playFx(level.FXs["wunderwaffe_shock"], zom.origin);
			self thread scripts\_ai::Attack(zom, damage * 0.75, "noshock");

			counter++;
		}
	}
}

slowingDown(zombie, damage, weapon, argument)
{
	if (!isDefined(level.AItype[zombie.type].canHitSpecial) || level.AItype[zombie.type].canHitSpecial)
		zombie.speed = level.AItype[zombie.type].speed * 0.5;
}

scaledDamage(zombie, damage, weapon, argument)
{
	if (isDefined(argument) && argument == "bow")
		return;
	
	damage *= (game["difficulty"] - 1) * 0.5;
	self thread scripts\_ai::Attack(zombie, damage, "bow");
}

projectile(curammo, oldammo)
{
	self endon("disconnect");
	self endon("killed_player");

	minDamage = 200;
	maxDamage = 1500;
	minDamageRange = 400;
	maxDamageRange = 200;

	rockets = getEntArray("rocket", "classname");
	myRocket = undefined;
	myRocketOrigin = undefined;

	for (i = 0; i < rockets.size; i++)
	{
		if (!isDefined(rockets[i].parent) && rockets[i] isTouching(self))
		{
			myRocket = rockets[i];
			myRocket.parent = self;
			break;
		}
	}

	while (isDefined(myRocket))
	{
		myRocketOrigin = myRocket.origin;
		wait 0.05;
	}

	if (!isDefined(myRocketOrigin))
		return;
	
	for (i = 0; i < level.AIs.size; i++)
	{
		zom = level.AIs[i];

		if (distanceSquared(zom.origin, myRocketOrigin) <= minDamageRange * minDamageRange)
		{
			dist = distance(zom.origin, myRocketOrigin);
			damage = (maxDamage - minDamage) / (minDamageRange - maxDamageRange) * (maxDamageRange - dist) + maxDamage;
			damage = clamp(damage, minDamage, maxDamage);

			self thread scripts\_ai::Attack(zom, damage);
		}
	}
}

getWeaponClipSize(weapon)
{
	switch (weapon)
	{
		case "ak47_mp": return 30;
		case "ak74_mp": return 30;
		case "barrett_mp": return 10;
		case "dragunov_mp": return 10;
		case "g36s_mp": return 30;
		case "g36_mp": return 30;
		case "g3_mp": return 20;
		case "m1014_mp": return 4;
		case "m14_mp": return 20;
		case "m16_mp": return 30;
		case "m21_mp": return 10;
		case "m249_mp": return 100;
		case "m40a3_mp": return 5;
		case "m4_mp": return 30;
		case "m60_mp": return 150;
		case "mini_uzi_mp": return 32;
		case "mp5_mp": return 30;
		case "p90_mp": return 50;
		case "r700_mp": return 4;
		case "rpd_mp": return 100;
		case "scorpion_mp": return 20;
		case "winchester_mp": return 7;
		case "mg42_mp": return 100;
		case "minigun_mp": return 999;
		case "raygun_mark2_mp": return 21;
		case "wunderwaffe_mp": return 8;
		case "raygun_mp": return 20;
		case "aa12_mp": return 8;
		case "dsr50_mp": return 5;
		case "m8a1_mp": return 30;
		case "pdw57_mp": return 25;
		case "wa2000_mp": return 10;
		case "bow_mp": return 1;
		case "flamethrower_mp": return 600;
		case "panzerschreck_mp": return 1;
		case "deagle_mp": return 7;
		case "beretta_mp": return 15;
		case "usp_mp": return 12;
		case "bar_mp": return 20;
		case "bren_mp": return 30;
		case "colt_mp": return 7;
		case "enfield_mp": return 10;
		case "enfield_scope_mp": return 10;
		case "g43_mp": return 10;
		case "greasegun_mp": return 32;
		case "kar98k_mp": return 5;
		case "kar98k_sniper_mp": return 5;
		case "luger_mp": return 8;
		case "m1carbine_mp": return 15;
		case "m1garand_mp": return 8;
		case "mosin_nagant_mp": return 5;
		case "mosin_nagant_sniper_mp": return 5;
		case "mp40_mp": return 32;
		case "mp44_mp": return 30;
		case "pps42_mp": return 35;
		case "ppsh_mp": return 71;
		case "shotgun_mp": return 6;
		case "springfield_mp": return 5;
		case "sten_mp": return 32;
		case "svt40_mp": return 10;
		case "thompson_mp": return 20;
		case "tt30_mp": return 8;
		case "webley_mp": return 6;
		default:
			return 0;
	}
}

getWeaponReloadTime(weapon)
{
	switch (weapon)
	{
		case "ak47_mp": return 2;
		case "ak74_mp": return 2.4;
		case "barrett_mp": return 2.75;
		case "dragunov_mp": return 3.26;
		case "g36s_mp": return 2.9;
		case "g36_mp": return 1.9;
		case "g3_mp": return 3.26;
		case "m1014_mp": return 0.6;
		case "m14_mp": return 3.2;
		case "m16_mp": return 2;
		case "m21_mp": return 3.26;
		case "m249_mp": return 3.5;
		case "m40a3_mp": return 0.4;
		case "m4_mp": return 1.9;
		case "m60_mp": return 9.7;
		case "mini_uzi_mp": return 2.4;
		case "mp5_mp": return 1.83;
		case "p90_mp": return 2.6;
		case "r700_mp": return 0.6;
		case "rpd_mp": return 3;
		case "scorpion_mp": return 1.83;
		case "winchester_mp": return 0.5;
		case "mg42_mp": return 5.03;
		case "minigun_mp": return 2;
		case "raygun_mark2_mp": return 2.9;
		case "wunderwaffe_mp": return 3.6;
		case "raygun_mp": return 3.5;
		case "aa12_mp": return 1.83;
		case "dsr50_mp": return 2.67;
		case "m8a1_mp": return 2;
		case "pdw57_mp": return 1.8;
		case "wa2000_mp": return 2.2;
		case "bow_mp": return 1.2;
		case "flamethrower_mp": return 2.4;
		case "panzerschreck_mp": return 4;
		case "deagle_mp": return 1.96;
		case "beretta_mp": return 2.1;
		case "usp_mp": return 2.1;
		case "bar_mp": return 3.63;
		case "bren_mp": return 3.7;
		case "colt_mp": return 2.1;
		case "enfield_mp": return 0.7;
		case "enfield_scope_mp": return 0.7;
		case "g43_mp": return 3.26;
		case "greasegun_mp": return 2.4;
		case "kar98k_mp": return 2.5;
		case "kar98k_sniper_mp": return 0.6;
		case "luger_mp": return 2.1;
		case "m1carbine_mp": return 2.9;
		case "m1garand_mp": return 1.6;
		case "mosin_nagant_mp": return 2.3;
		case "mosin_nagant_sniper_mp": return 0.6;
		case "mp40_mp": return 2.6;
		case "mp44_mp": return 2;
		case "pps42_mp": return 2.66;
		case "ppsh_mp": return 1.83;
		case "shotgun_mp": return 0.6;
		case "springfield_mp": return 0.6;
		case "sten_mp": return 2.5;
		case "svt40_mp": return 3.26;
		case "thompson_mp": return 1.83;
		case "tt30_mp": return 2.25;
		case "webley_mp": return 5;
		default: return 0;
	}
}

getWeaponReloadEmptyTime(weapon)
{
	switch (weapon)
	{
		case "ak47_mp": return 2.67;
		case "ak74_mp": return 2.5;
		case "barrett_mp": return 3.5;
		case "dragunov_mp": return 3.26;
		case "g36s_mp": return 3.7;
		case "g36_mp": return 2.5;
		case "g3_mp": return 3.26;
		case "m1014_mp": return 0.6;
		case "m14_mp": return 3.2;
		case "m16_mp": return 2.365;
		case "m21_mp": return 3.26;
		case "m249_mp": return 4.5;
		case "m40a3_mp": return 0.4;
		case "m4_mp": return 2.5;
		case "m60_mp": return 9.7;
		case "mini_uzi_mp": return 2.4;
		case "mp5_mp": return 2.2;
		case "p90_mp": return 3.2;
		case "r700_mp": return 0.6;
		case "rpd_mp": return 4;
		case "scorpion_mp": return 1.83;
		case "winchester_mp": return 0.5;
		case "mg42_mp": return 5.03;
		case "minigun_mp": return 2;
		case "raygun_mark2_mp": return 3.7;
		case "wunderwaffe_mp": return 3.6;
		case "raygun_mp": return 3.5;
		case "aa12_mp": return 2.2;
		case "dsr50_mp": return 2.67;
		case "m8a1_mp": return 2.3;
		case "pdw57_mp": return 2.5;
		case "wa2000_mp": return 3;
		case "bow_mp": return 1.2;
		case "flamethrower_mp": return 3.2;
		case "panzerschreck_mp": return 4;
		case "deagle_mp": return 2.1;
		case "beretta_mp": return 2.5;
		case "usp_mp": return 2.5;
		case "colt_mp": return 2.5;
		case "bar_mp": return 3.8;
		case "bren_mp": return 3.7;
		case "enfield_mp": return 0.7;
		case "enfield_scope_mp": return 0.7;
		case "g43_mp": return 3.26;
		case "greasegun_mp": return 3.2;
		case "kar98k_mp": return 2.5;
		case "kar98k_sniper_mp": return 0.6;
		case "luger_mp": return 2.5;
		case "m1carbine_mp": return 3.7;
		case "m1garand_mp": return 1.6;
		case "mosin_nagant_mp": return 2.3;
		case "mosin_nagant_sniper_mp": return 0.6;
		case "mp40_mp": return 3.3;
		case "mp44_mp": return 2.67;
		case "pps42_mp": return 3.2;
		case "ppsh_mp": return 2.57;
		case "shotgun_mp": return 0.6;
		case "springfield_mp": return 0.6;
		case "sten_mp": return 3;
		case "svt40_mp": return 3.26;
		case "thompson_mp": return 2.2;
		case "tt30_mp": return 2.35;
		case "webley_mp": return 5;
		default: return 0;
	}
}

getWeaponReloadQuickTime(weapon)
{
	return getWeaponReloadEmptyTime(weapon) * 0.5;
}