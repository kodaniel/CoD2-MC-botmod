#include scripts\_utils;

init()
{
	level.startMoney = 800;

	[[level.addCallback]]("onPlayerLogin", ::RunOnLogin);
	[[level.addCallback]]("onPlayerSpawned", ::RunOnSpawn);
	[[level.addCallback]]("onPlayerKilled", ::RunOnKilled);

	[[level.r_precacheString]](&"BZ_CHAR_DOLLAR_PLUS");
	[[level.r_precacheString]](&"BZ_CHAR_DOLLAR");
}

RunOnLogin()
{
	sumDiff = 0;
	for (i = 0; i < game["roundsplayed"]; i++)
		sumDiff += 1 + (i / level.difficulty);

	self.pers["money"] = level.startMoney + 200 * sumDiff;
}

RunOnSpawn()
{
	if (!isDefined(self.moneyhud))
	{
		self.moneyhud = newClientHudElem(self);
		self.moneyhud.horzAlign = "left";
		self.moneyhud.vertAlign = "top";
		self.moneyhud.alignX = "left";
		self.moneyhud.alignY = "top";
		self.moneyhud.x = 72;
		self.moneyhud.y = 20;
		self.moneyhud.sort = 10;
		self.moneyhud.alpha = 1;
		self.moneyhud.color = (1,1,1);
		self.moneyhud.font = "default";
		self.moneyhud.fontscale = 1.25;
		self.moneyhud.label = &"BZ_CHAR_DOLLAR";
	}

	thread UpdateMoney();
}

RunOnKilled(eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration)
{
    if (isDefined(self.moneyhud))
        self.moneyhud destroy();
	if (isDefined(self.scorebar))
        self.scorebar destroy();
}

UpdateMoney()
{
	self endon("disconnect");
    self endon("killed_player");
	self endon("player_logged_out");

	for (;;)
	{
		self.moneyhud setValue(self.pers["money"]);

		self waittill("update_money", score);

		self.pers["money"] += score;
		self thread UpdateScoreHUD(score);
	}
}

UpdateScoreHUD(score)
{
    self notify("end_scorehud");
    self endon("end_scorehud");
    self endon("disconnect");

    fontscale = 1.2;

    if (!isDefined(self.scorehud))
    {
        self.scorehud = newClientHudElem(self);
        self.scorehud.horzAlign = "center_safearea";
		self.scorehud.vertAlign = "center_safearea";
		self.scorehud.alignX = "center";
		self.scorehud.alignY = "middle";
		self.scorehud.x = 0;
		self.scorehud.y = -36;
    }

    if (!isDefined(self.old_score))
        self.old_score = 0;
    self.old_score += score;

	if (self.old_score < 0)
	{
		self.scorehud.color = (.92, 0, 0);
		self.scorehud.label = &"BZ_CHAR_DOLLAR";
	}
	else
	{
		self.scorehud.color = (.92, .90, .20);
		self.scorehud.label = &"BZ_CHAR_DOLLAR_PLUS";
	}

    self.scorehud SetValue(self.old_score);
    self.scorehud.fontScale = 0.2;
    self.scorehud.alpha = 1;

    while (self.scorehud.fontScale < fontscale)
    {
        self.scorehud.fontscale += 0.35;
        wait 0.05;
    }
    while (self.scorehud.fontscale > fontscale)
	{
		self.scorehud.fontscale -= 0.05;
		wait 0.05;
	}

    wait 1.5;

	self.scorehud fadeOverTime(0.5);
	self.scorehud.alpha = 0;

    self.old_score = undefined;
}