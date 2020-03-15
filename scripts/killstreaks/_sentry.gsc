#include scripts\_utils;

init()
{
    level.sentrytime = 90;
	level.sentryrange = 1000;
    level.sentrydamage = 35;

    game["model_sentry_head"] = "xmodel/oma_future_sentrygun_head";
	game["model_sentry_legs"] = "xmodel/oma_future_sentrygun_4pod";

	[[level.r_precacheModel]](game["model_sentry_head"]);
	[[level.r_precacheModel]](game["model_sentry_legs"]);
    [[level.r_precacheFX]]("muzzleflash_sentry", "fx/muzzleflashes/heavy.efx");
}

IsAllowed()
{
    return true;
}

RunOnUse()
{
    player = self;

    // player already deployed a sentry or use another strike, eg. ac130
    if (is_true(player.sentry) || is_true(player.instrike))
    {
        player iPrintlnBold("Can't deploy sentry gun");
		return false;
    }

    // player is not on ground
    if (!player isOnGround())
    {
        player iPrintlnBold("You must be on ground");
        return false;
    }

    origin = player getOrigin();
	angledir = player getPlayerAngles()[1];
	forward = vectorScale(anglesToForward((0, angledir, 0)), 40);
	startPoint = origin + (0, 0, 24);
	endPoint = startPoint + forward;

    // too close to the wall
    if (!bulletTracePassed(startPoint, endPoint, false, undefined))
		return false;
    
    player.sentry = true;
    player thread scripts\player\_hud::AddTimer(level.sentrytime, (.91, .64, .05));

    sentry = [];
	sentry[0] = spawnModel(game["model_sentry_legs"], origin, (0, angledir, 0));
	sentry[1] = spawnModel(game["model_sentry_head"], origin + (0, 0, 33), (0, angledir, 0));
	sentry[1].baseangles = (0, angledir, 0);
	sentry[1].parent = player;
	sentry[1] thread rotatingHead();
    sentry[1] thread monitorTargets();
    sentry[1] thread shooting();

    player thread deleteSentry(sentry);

	return true;
}

deleteSentry(sentry)
{
	self thread timer("end_sentry", level.sentrytime);

	self waittill_any("disconnect", "end_sentry");
	self notify("end_sentry");
	self.sentry = undefined;

	for (i = 0; i < sentry.size; i++)
	{
		sentry[i] delete();
	}
}

rotatingHead()
{
	sentry = self;
	owner = sentry.parent;

	owner endon("end_sentry");

	for (i = 0; true; i++)
	{
		if (isDefined(sentry.targetAI))
		{
			wait 1;
			continue;
		}

		if(i & 1)
			sentry rotateTo(sentry.baseangles + (0,75,0), 3, 0.5, 0.5);
		else
			sentry rotateTo(sentry.baseangles - (0,75,0), 3, 0.5, 0.5);

		sentry waittill("rotatedone");
	}
}

monitorTargets()
{
	sentry = self;
	owner = sentry.parent;
	sentry.maxRange = level.sentryrange;

	owner endon("disconnect");
	owner endon("joined_spectators");
	owner endon("end_sentry");

	while (1)
	{
		sentry.targetAI = sentry getBestTarget();
		wait 0.5;
	}
}

shooting()
{
    sentry = self;
	owner = sentry.parent;
	sentry.maxRange = level.sentryrange;

	owner endon("disconnect");
	owner endon("joined_spectators");
	owner endon("end_sentry");

    while (1)
    {
        if (isDefined(sentry.targetAI) && sentry.targetAI.health > 0)
		{
			target_pos = sentry.targetAI.origin + (0, 0, 33);
            angle_dir = vectorToAngles(target_pos - sentry.origin);
			anglediff = angle_dif(sentry.angles, angle_dir);

			rotateSpeed = anglediff / 50;
			rotateSpeed = clamp(rotateSpeed, 1, 0.1);
			sentry rotateTo(angle_dir, rotateSpeed);

			if (anglediff < 15)
			{
				// Firing
				playFxOnTag(level.FXs["muzzleflash_sentry"], sentry, "tag_flash");
				sentry playSound("weap_bren_fire");

                owner thread scripts\_ai::Attack(sentry.targetAI, level.sentrydamage);
				
				wait 0.1;
				continue;
			}
		}

        wait 0.5;
    }
}

getBestTarget()
{
	bestDist = undefined;
	bestAngle = undefined;
	bestTarget = undefined;

	for (i = 0; i < level.AIs.size; i++)
	{
		target = level.AIs[i];

		if (!level.AItype[target.type].canFriendAttack)
			continue;

        // can't see the target
		if (!bulletTracePassed(self.origin + (0, 0, 64), target.origin + (0, 0, 64), false, self))
			continue;

		vec = (target.origin - self.origin);
		vec_angle = vectorToAngles(vec);

        // horizontal degree is too large
		if (abs(angle_dif((0, self.baseangles[1], 0), (0, vec_angle[1], 0))) > 70)
			continue;
        // vertical degree is too large
		if (abs(angle_dif((self.baseangles[0], 0, 0), (vec_angle[0], 0, 0))) > 30)
			continue;

		dist = lengthSquared(vec);
		if (dist > self.maxRange * self.maxRange) // too far
			continue;

		angle = angle_dif(self.angles, vec_angle);

		if (!isDefined(bestDist) || dist < bestDist)
			bestDist = dist;
		if (!isDefined(bestAngle) || dist < bestAngle)
			bestAngle = angle;

		targ1 = dist * angle;
		targ2 = bestDist * bestAngle;

		if (!isDefined(bestTarget) || targ1 < targ2)
			bestTarget = target;
	}

	return bestTarget;
}