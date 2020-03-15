#include scripts\_utils;

init()
{
	level.woundedTime = 30;
	level.revivingTime = 5;
    level.revivingTimeFast = 2.5;
    level.revivebarsize = 150;

    game["tombstone_model"] = "xmodel/prop_tombstone2";
    game["tombstone_hudicon"] = "rndl_hud_dead";

    [[level.r_precacheString]](&"BZ_HOLD_MELEE_TO_REVIVE");
	[[level.r_precacheShader]]("white");
	[[level.r_precacheShader]]("black");
    [[level.r_precacheShader]](game["tombstone_hudicon"]);
    [[level.r_precacheModel]](game["tombstone_model"]);

    [[level.addCallback]]("onConnect", ::RunOnConnect);
}

RunOnConnect()
{
    self.revivingTime = level.revivingTime;
}

reviving(origin, angles)
{
    self endon("disconnect");
    self endon("spawned");
    self endon("player_revived");

    self thread roundEnd();
    self thread setTombstone(origin, angles);
    
    reviveDistanceSquared = 1500;
    timeLeft = 0;

    while (timeLeft <= level.woundedTime)
    {
        players = getEntArray("player", "classname");
		for (i = 0; i < players.size; i++)
		{
			player = players[i];
            isbot = false; // = isSubStr(player.name, "bot"); // debugging with bots
            
            // can't revive himself
            if (player == self)
                continue;
            // can player revive only when: 1. alive, 2. still nobody is reviving the victim, 3. player is not reviving someone else
            if (!player isValidRevivingPlayer() || isDefined(self.revivingPlayer) || isDefined(player.reviving))
                continue;
            // player have to press the melee button
            if (!isbot && !player meleeButtonPressed())
                continue;
            // player too far
            if (distanceSquared(player.origin, origin) > reviveDistanceSquared)
                continue;
            
            revivingElapsedTime = 0;
            revivingTime = player.revivingTime;
            while (revivingElapsedTime < revivingTime && player isValidRevivingPlayer() && (player meleeButtonPressed() || isbot))
            {
                if (!isDefined(player.reviveProgressBar_bg))
                {
                    player.reviveProgressBar_bg = newClientHudElem(player);
                    player.reviveProgressBar_bg.x = 0;
                    player.reviveProgressBar_bg.y = 104;
                    player.reviveProgressBar_bg.alignX = "center";
                    player.reviveProgressBar_bg.alignY = "middle";
                    player.reviveProgressBar_bg.horzAlign = "center_safearea";
                    player.reviveProgressBar_bg.vertAlign = "center_safearea";
                    player.reviveProgressBar_bg.alpha = 0.5;
                    player.reviveProgressBar_bg.color = (0, 0, 0);
                    player.reviveProgressBar_bg SetShader("white", level.revivebarsize, 6);
                    
                    player.reviveProgressBar = newClientHudElem(player);
                    player.reviveProgressBar.x = int(level.revivebarsize / (-2.0));
                    player.reviveProgressBar.y = 104;
                    player.reviveProgressBar.alignX = "left";
                    player.reviveProgressBar.alignY = "middle";
                    player.reviveProgressBar.horzAlign = "center_safearea";
                    player.reviveProgressBar.vertAlign = "center_safearea";
                    player.reviveProgressBar.sort = 10;
                    player.reviveProgressBar SetShader("white", 0, 6);
				    player.reviveProgressBar ScaleOverTime(revivingtime, level.revivebarsize, 6);
                }

                self.revivingPlayer = player;
                player.reviving = true;
                player disableWeapon();
				player linkTo(self.tombstone);

                wait 0.1;
                revivingElapsedTime += 0.1;
            }

            self.revivingPlayer = undefined;

            if (isDefined(player))
            {
                if (isDefined(player.reviveProgressBar_bg))
                    player.reviveProgressBar_bg destroy();
                if (isDefined(player.reviveProgressBar))
                    player.reviveProgressBar destroy();

                player.reviving = undefined;
                player enableWeapon();
                player unLink();
            }

            if (revivingElapsedTime >= revivingTime)
            {
                self notify("player_revived", true, player);
            }
        }

        wait 0.1;
        timeLeft += 0.1;
    }

    self notify("player_revived", false, undefined);
}

roundEnd()
{
    self endon("player_revived");
    level waittill("round_ended");
    self notify("player_revived", false, undefined);
}

setTombstone(origin, angles)
{
    self.tombstone = spawn("script_model", origin);
    self.tombstone.angles = angles;
	self.tombstone SetModel(game["tombstone_model"]);

    self.tombstone.hud = newHudElem();
    self.tombstone.hud.x = origin[0];
    self.tombstone.hud.y = origin[1];
    self.tombstone.hud.z = origin[2] + 48;
    self.tombstone.hud.alpha = 1;
    self.tombstone.hud SetShader(game["tombstone_hudicon"], 6, 6);
    self.tombstone.hud SetWaypoint(true);

    self waittill_any("disconnect", "spawned", "round_ended", "player_revived");

    if (isDefined(self.revivingPlayer))
    {
        player = self.revivingPlayer;

        if (isDefined(player.reviveProgressBar_bg))
            player.reviveProgressBar_bg destroy();
        if (isDefined(player.reviveProgressBar))
            player.reviveProgressBar destroy();

        player.reviving = undefined;
        player enableWeapon();
        player unLink();
    }

    self.revivingPlayer = undefined;
    self.tombstone.hud destroy();
    self.tombstone delete();
}

isValidRevivingPlayer()
{
    return isDefined(self) && isAlive(self) && self.sessionstate == "playing";
}