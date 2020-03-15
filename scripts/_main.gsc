#include scripts\_utils;

main()
{
	level.default_CallbackAIDamage	= level.callbackAIDamage;
	level.default_CallbackAIKilled	= level.callbackAIKilled;

	level.callbackStartGameType = ::ScriptCallback_StartGameType;
	level.callbackPlayerConnect = ::ScriptCallback_PlayerConnect;
	level.callbackPlayerDisconnect = ::ScriptCallback_PlayerDisconnect;
	level.callbackPlayerDamage = ::ScriptCallback_PlayerDamage;
	level.callbackPlayerKilled = ::ScriptCallback_PlayerKilled;
	level.callbackAIDamage = ::ScriptCallback_ZombieDamage;
	level.callbackAIKilled = ::ScriptCallback_ZombieKilled;

	level.functions = [];
	level.functions["onConnect"] = [];
	level.functions["onDisconnect"] = [];
	level.functions["onPlayerSpawned"] = [];
	level.functions["onPlayerDamage"] = [];
	level.functions["onPlayerKilled"] = [];
	level.functions["onPlayerLogin"] = [];
	level.functions["onPlayerLogout"] = [];
	level.functions["onZombieDamage"] = [];
	level.functions["onZombieKilled"] = [];

	level.addCallback = ::AddCallback;

	setup();
}

setup()
{
	scripts\_varcache::init();
	scripts\_ai_setup::init();

	scripts\player\_markers::init();
	scripts\player\_classes::init();
	scripts\player\_sprinting::init();
	//scripts\player\_healthbar::init();
	//scripts\player\_money::init();
	scripts\player\_notification::init();

	scripts\gametypes\_powerup::init();
	scripts\gametypes\_shop::init();
	scripts\gametypes\_admin::init();
}

AddCallback(type, function)
{
	level.functions[type][level.functions[type].size] = function;
}

ScriptCallback_StartGameType()
{
	[[ level.default_CallbackStartGameType ]]();
}

ScriptCallback_PlayerConnect()
{
	[[ level.default_CallbackPlayerConnect ]]();

	for (i = 0; i < level.functions["onConnect"].size; i++)
	{
		self thread [[ level.functions["onConnect"][ i ] ]]();
	}

	self thread PlayerSpawned();
	self thread PlayerLogin();
	self thread PlayerLogout();
}

ScriptCallback_PlayerDisconnect()
{
	for (i = 0; i < level.functions["onDisconnect"].size; i++)
	{
		self thread [[ level.functions["onDisconnect"][ i ] ]]();
	}

	[[ level.default_CallbackPlayerDisconnect ]]();
}

ScriptCallback_PlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset)
{
	for (i = 0; i < level.functions["onPlayerDamage"].size; i++)
	{
		self thread [[ level.functions["onPlayerDamage"][ i ] ]](eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset);
	}

	[[ level.default_CallbackPlayerDamage ]](eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset);
}

ScriptCallback_PlayerKilled(eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration)
{
	for (i = 0; i < level.functions["onPlayerKilled"].size; i++)
	{
		self thread [[ level.functions["onPlayerKilled"][ i ] ]](eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration);
	}

	[[ level.default_CallbackPlayerKilled ]](eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration);
}

ScriptCallback_ZombieDamage(eAttacker, iDamage, argument)
{
	for (i = 0; i < level.functions["onZombieDamage"].size; i++)
	{
		self thread [[ level.functions["onZombieDamage"][ i ] ]](eAttacker, iDamage, argument);
	}

	[[ level.default_CallbackAIDamage ]](eAttacker, iDamage, argument);
}

ScriptCallback_ZombieKilled(eAttacker, iDamage, argument)
{
	for (i = 0; i < level.functions["onZombieKilled"].size; i++)
	{
		self thread [[ level.functions["onZombieKilled"][ i ] ]](eAttacker, iDamage, argument);
	}

	[[ level.default_CallbackAIKilled ]](eAttacker, iDamage, argument);
}

PlayerSpawned()
{
	for (;;)
	{
		self waittill("spawned_player");

		for (i = 0; i < level.functions["onPlayerSpawned"].size; i++)
			self thread [[level.functions["onPlayerSpawned"][i]]]();
	}
}

PlayerLogin()
{
	for (;;)
	{
		self waittill("player_logged_in");

		for (i = 0; i < level.functions["onPlayerLogin"].size; i++)
			self thread [[level.functions["onPlayerLogin"][i]]]();
	}
}

PlayerLogout()
{
	for (;;)
	{
		self waittill("player_logged_out");

		for (i = 0; i < level.functions["onPlayerLogout"].size; i++)
			self thread [[level.functions["onPlayerLogout"][i]]]();
	}
}