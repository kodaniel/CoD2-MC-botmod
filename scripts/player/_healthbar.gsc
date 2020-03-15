init()
{
	Settings();
	
	[[level.addCallback]]("onPlayerSpawned", ::RunOnSpawn);
	[[level.addCallback]]("onPlayerKilled", ::RunOnKilled);
}

Settings()
{
	// Show healthbar
	level.showhealthbar				= game["bz_healthbar"];
	if (! level.showhealthbar)		return;

	// Precache healthbar
	[[level.r_precacheShader]]("gfx/hud/hud@health_back.tga");
	[[level.r_precacheShader]]("gfx/hud/hud@health_bar.tga");
	[[level.r_precacheShader]]("gfx/hud/hud@health_cross.tga");
}

RunOnKilled(eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration)
{
	if (! level.showhealthbar)		return;

	if (isDefined(self.healthbar))			self.healthbar destroy();
	if (isDefined(self.healthbar_back))		self.healthbar_back destroy();
	if (isDefined(self.healthbar_cross))	self.healthbar_cross destroy();
}

RunOnSpawn()
{
	if(! level.showhealthbar)		return;

	// Create healtbar
	x = 502;
	y = 471;
	maxwidth = 128;

	self.healthbar_back = newClientHudElem( self );
	self.healthbar_back setShader("gfx/hud/hud@health_back.tga", maxwidth + 2, 7);
	self.healthbar_back.alignX = "left";
	self.healthbar_back.alignY = "top";
	self.healthbar_back.horzAlign = "right";
	self.healthbar_back.x = x - 640;
	self.healthbar_back.y = y;

	self.healthbar_cross = newClientHudElem( self );
	self.healthbar_cross setShader("gfx/hud/hud@health_cross.tga", 7, 7);
	self.healthbar_cross.alignX = "right";
	self.healthbar_cross.alignY = "top";
	self.healthbar_cross.horzAlign = "right";
	self.healthbar_cross.x = x - 1 - 640;
	self.healthbar_cross.y = y;

	self.healthbar = newClientHudElem( self );
	self.healthbar setShader("gfx/hud/hud@health_bar.tga", maxwidth, 5);
	self.healthbar.color = ( 0, 1, 0);
	self.healthbar.alignX = "left";
	self.healthbar.alignY = "top";
	self.healthbar.horzAlign = "right";
	self.healthbar.x = x + 1 - 640;
	self.healthbar.y = y + 1;

	self thread updateHealthBar();
}

updateHealthBar()
{
	self endon("disconnect");
	self endon("killed_player");

	for (;;)
	{
		self waittill("update_healtbar");

		health = self.health / self.maxhealth;
		maxwidth = 128;
		hud_width = int(health * maxwidth);

		if ( hud_width < 1 )
			hud_width = 1;

		self.healthbar setShader("gfx/hud/hud@health_bar.tga", hud_width, 5);
		self.healthbar.color = ( 1.0 - health, health, 0);
	}
}