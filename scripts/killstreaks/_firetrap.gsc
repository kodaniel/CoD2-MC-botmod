#include scripts\_utils;

init()
{
    level.firetrapTime = 60;
    level.firetrapDamage = 250;
    level.firetrapDamageRadius = 60;

    [[level.r_precacheFX]]("firetrap", "fx/fire/ground_firetrap.efx");
}

IsAllowed()
{
    return true;
}

RunOnUse()
{
    if (is_true(self.instrike))
		return false;

    if (!self isOnGround())
    {
        self iPrintlnBold("You must be on ground");
        return false;
    }

    origin = self getOrigin();

    self thread scripts\player\_hud::AddTimer(level.firetrapTime, (.1, .9, .1));
    self thread doTrapEffect(origin);
    self thread doTrapDamage(origin);

	return true;
}

doTrapEffect(origin)
{
    self endon("disconnect");

    dt = 2;
    for (i = level.firetrapTime; i > 0; i -= dt)
    {
        playFx(level.FXs["firetrap"], origin);
        wait dt;
    }
}

doTrapDamage(origin)
{
    self endon("disconnect");

    dt = 0.25;
    for (i = level.firetrapTime; i > 0; i -= dt)
    {
        self scripts\_ai::RadiusDamage(origin, level.firetrapDamageRadius, level.firetrapTime);
        wait dt;
    }
}