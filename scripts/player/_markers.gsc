init()
{
	[[level.addCallback]]("onDisconnect", ::RunOnDisconnect);
	[[level.addCallback]]("onPlayerSpawned", ::RunOnSpawn);
	[[level.addCallback]]("onPlayerKilled", ::RunOnKilled);
}

RunOnDisconnect()
{
	if ( isDefined( self.spinemarker ) )
		self.spinemarker delete();
}

RunOnKilled(eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration)
{
	if ( isDefined( self.spinemarker ) )
		self.spinemarker delete();
}

RunOnSpawn()
{
	wait 0.01;
	self.spinemarker = spawn("script_origin", self.origin);
	self.spinemarker linkTo(self, "J_Spine4", (0,0,0), (0,0,0));
}