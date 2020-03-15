#include scripts\_utils;

init()
{
    level.c4Damage = 1000;
    level.c4DamageRadius = 200;

    game["model_c4"] = "xmodel/tc_c4_plastic";

	[[level.r_precacheModel]](game["model_c4"]);
    [[level.r_precacheFX]]("c4_exp", "fx/explosions/c4_explosion.efx");
}

IsAllowed()
{
    return true;
}

RunOnUse()
{
    if (is_true(self.instrike))
    {
        self iPrintlnBold("Can't drop C4");
		return false;
    }

    if (!isDefined(self.c4))
        self.c4 = 0;

    if (self.c4 >= 3)
    {
        self iPrintlnBold("Can't plant more C4");
		return false;
    }

    self thread doC4();

	return true;
}

doC4()
{
    plantDistSquared = 400;
    maxtime = 5;
    
    if (isDefined(self.spinemarker))
        origin = self.spinemarker.origin;
    else
        origin = self getOrigin() + (0, 0, 48);

    angles = self getPlayerAngles();
    vec = vectorScale(anglesToForward(angles), 500);

    c4 = spawnModel(game["model_c4"], origin, (0, angles[1], 0));
    c4.oldorigin = c4.origin;
	c4 moveGravity(vec, 15);
    c4 endon("delete");

    for (i = maxtime; true; i -= 0.05)
    {
        vec = c4.origin - c4.oldorigin;
		vec = vectorScale(vec, 500);

        traceF = bulletTrace(c4.origin, c4.origin + vec, false, c4); // forward vector
		traceD = bulletTrace(c4.origin, c4.origin + (0, 0, -500), false, c4); // down vector

        if (traceF["fraction"] < 1 && distanceSquared(traceF["position"], c4.origin) < plantDistSquared)
        {
            c4 moveTo(traceF["position"], 0.01);
            c4.angles = vectorToAngles(vectorNormalize(traceF["normal"])) + (90,0,0);
            break;
        }
        else if (traceD["fraction"] < 1 && distanceSquared(traceD["position"], c4.origin) < plantDistSquared)
        {
            c4 moveTo(traceD["position"], 0.01);
            c4.angles = vectorToAngles(vectorNormalize(traceD["normal"])) + (90,0,0);
            break;
        }

        c4.oldorigin = c4.origin;
        wait 0.05;

        if (i <= 0)
        {
            c4 delete();
            c4 notify("delete");
        }
    }

    if (isDefined(self))
        self explodeC4(c4);
    else
        c4 delete();
}

explodeC4(c4)
{
    self.c4++;
    self iPrintlnBold("Press [Melee] to explode the C4");

    while (isDefined(self) && !self meleeButtonPressed())
        wait 0.05;

    if (isDefined(self))
    {
        self scripts\_ai::RadiusDamage(c4.origin, level.c4DamageRadius, level.c4Damage);
        self.c4--;
    }

    playFx(level.FXs["c4_exp"], c4.origin);
    c4 playSound("grenade_explode_layer");
    c4 delete();
}