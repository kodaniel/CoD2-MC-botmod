#include scripts\_utils;

init()
{
    level.planeHalfDistance = 24000;
	level.planeSpeed = 6000;
    level.planeDamage = 1000;
    level.planeDamageRadius = 500;

	level.planeSound["loop"] = "mig29loop_mid";
	level.planeSound["short"] = "mig29short";
	level.planeSound["bomb"] = "artillery_explosion";

	game["model_airstrike"] = "xmodel/mig29_desert";
	game["model_airstrike_bomb"] = "xmodel/mig29_missle_archer";

	[[level.r_precacheModel]](game["model_airstrike"]);
	[[level.r_precacheModel]](game["model_airstrike_bomb"]);
    [[level.r_precacheFX]]("bomb", "fx/mig29/mig29_bomb_explosion.efx");
    [[level.r_precacheFX]]("burn", "fx/mig29/mig29_after_burner.efx");
    [[level.r_precacheFX]]("wing", "fx/mig29/mig29_wing_tip.efx");
	[[level.r_precacheFX]]("smoke_red", "fx/smoke/red_smoke_5sec.efx");
}

IsAllowed()
{
    return isDefined(level.skyorigin);
}

RunOnUse()
{
    player = self;

	if (is_true(player.airstrike) || is_true(player.instrike))
	{
        player iPrintlnBold("Can't deploy airstrike");
		return false;
    }

	target = player getOrigin();
	dir = (0, bestDirection(target), 0);

	start = target + vectorScale(anglesToForward(dir), -1 * level.planeHalfDistance);
	start = (start[0], start[1], level.skyorigin[2] - 200);

    end = target + vectorScale(anglesToForward(dir), level.planeHalfDistance);
	end = (end[0], end[1], level.skyorigin[2] - 200);

	dist = length(end - start);
	speed = (dist / level.planeSpeed);

	level thread spawnPlane(game["model_airstrike"], start, end, dir, speed, 3, target, player);

	return true;
}

spawnPlane(xmodel, origin, endorigin, angles, time, count, targetpos, owner)
{
	playFx(level.FXs["smoke_red"], targetpos);

    owner.airstrike = true;
	plane = spawnModel(xmodel, origin, (0, angles[1], 0));

	plane thread playPlaneSound(targetpos);
	plane thread dropBombs(count, targetpos, owner);

	plane moveTo(endorigin, time);
	plane waittill("movedone");

	plane notify("end_airstrike");
	plane delete();

    owner.airstrike = undefined;
}

dropBombs(count, targetpos, owner)
{
	while (isDefined(self))
	{
		if (distance(self.origin, targetpos) < (level.skyorigin[2] - targetpos[2]) * 2)
		{
			bombs = [];
			for (i = 0; i < count; i++)
			{
				size = bombs.size;
				bombs[size] = spawnModel(game["model_airstrike_bomb"], self.origin, self.angles);
				bombs[size].parent = owner;
				bombs[size] moveGravity(targetpos - self.origin, 1.5);
				bombs[size] thread explodeBomb(3);

				self notify("dropped_bomb");
				wait 0.25;
			}

			break;
		}
		wait 0.05;
	}
}

explodeBomb(explodetime)
{
	trace = undefined;
	while (explodetime > 0)
	{
		oldorig = self.origin;
		wait 0.05;

		forward = vectorScale((self.origin - oldorig), 3);
		trace = bulletTrace(self.origin, self.origin + forward, false, self);
		if (trace["fraction"] < 1)
			break;

		explodetime -= 0.05;
	}

	if (isDefined(trace))
		origin = trace["position"];
	else
		origin = self.origin;

	owner = self.parent;
	if (isDefined(owner))
	{
		owner scripts\_ai::RadiusDamage(origin, level.planeDamageRadius, level.planeDamage);
	}

	playFx(level.FXs["bomb"], origin);
	earthquake(0.5, 3, origin, 1200);
	self playSound(level.planeSound["bomb"]);

	self delete();
}

playPlaneSound(targetpos)
{
	self playLoopSound(level.planeSound["loop"]);

	while (isDefined(self))
	{
		dist = distance(self.origin, targetpos);
		if (dist < (level.planeSpeed / 2) + level.skyorigin[2] - 200)
		{
			self playSound(level.planeSound["short"], "stopsound", true);
			break;
		}
		wait 0.5;
	}
}

playPlaneEffect()
{
	while (isDefined(self))
	{
		playFxOnTag(level.FXs["burn"], self, "tag_engine_left");
		playFxOnTag(level.FXs["burn"], self, "tag_engine_right");

		playFxOnTag(level.FXs["wing"], self, "tag_left_wingtip");
		playFxOnTag(level.FXs["wing"], self, "tag_right_wingtip");
		wait 0.05;
	}
}

bestDirection(targetpos)
{
	checkPitch = -25;
	numChecks = 15;

	startpos = targetpos + (0,0,64);

	bestangle = randomFloat(360);
	bestanglefrac = 0;

	fullTraceResults = [];

	for (i = 0; i < numChecks; i++)
	{
		yaw     = ((i * 1.0 + randomFloat(1)) / numChecks) * 360.0;
		angle   = (checkPitch, yaw + 180, 0);
		dir     = anglesToForward(angle);

		endpos = startpos + vectorScale(dir, 1500);

		trace = bulletTrace(startpos, endpos, false, undefined);

		if (trace["fraction"] > bestanglefrac)
		{
			bestanglefrac   = trace["fraction"];
			bestangle       = yaw;

			if (trace["fraction"] >= 1)
			{
				fullTraceResults[fullTraceResults.size] = yaw;
            }
		}

		if (i % 3 == 0)
            wait 0.05;
	}

	if (fullTraceResults.size > 0)
	{
		return fullTraceResults[randomInt(fullTraceResults.size)];
    }

	return bestangle;
}