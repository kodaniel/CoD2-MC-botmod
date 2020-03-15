#include scripts\_utils;

init()
{
    level.showInfoDistance = 200;

    game["playerinfo_label_rank"] = &"Rank &&1";
    game["playerinfo_label_money"] = &"Money: &&1$";
    game["playerinfo_label_killscore"] = &"KS: &&1";
    game["playerinfo_label_boss"] = &"Boss kills: &&1";

    [[level.r_precacheShader]]("rndl_hud_playerinfobg");
    [[level.r_precacheString]](game["playerinfo_label_rank"]);
    [[level.r_precacheString]](game["playerinfo_label_money"]);
    [[level.r_precacheString]](game["playerinfo_label_killscore"]);
    [[level.r_precacheString]](game["playerinfo_label_boss"]);

    [[level.addCallback]]("onPlayerSpawned", ::RunOnSpawn);
	[[level.addCallback]]("onPlayerKilled", ::RunOnKilled);
}

RunOnSpawn()
{
    self endon("disconnect");
    self endon("killed_player");

    self.playerInfoHuds = [];
    self.playerInfoPlayer = undefined;

    while (true)
    {
        wait 0.5;

        if (!isDefined(self.spinemarker))
            continue;

        angles = self getPlayerAngles();
        fvec = vectorScale(anglesToForward(angles), level.showInfoDistance);
        hit = bulletTrace(self.spinemarker.origin, self.spinemarker.origin + fvec, true, self);
        
        if (isPlayer(hit["entity"]))
        {
            player = hit["entity"];
            popupDelay = 0.5;

            while (popupDelay > 0)
            {
                wait 0.1;
                hit = bulletTrace(self.spinemarker.origin, self.spinemarker.origin + fvec, true, self);

                if (isPlayer(hit["entity"]) && hit["entity"] == player)
                    popupDelay -= 0.1;
                else
                    break;
            }

            if (popupDelay <= 0)
            {
                self thread playerInfo(player);
            }
        }
    }
}

RunOnKilled(eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration)
{
    // clear hud elements
	self deletePlayerInfo();

    self.playerInfoPlayer = undefined;
}

playerInfo(player)
{
    if (isDefined(self.playerInfoPlayer))
    {
        if (self.playerInfoPlayer == player)
            self notify("end_playerinfo");
        else
            return;
    }

    self endon("disconnect");
    self endon("killed_player");
    self endon("end_playerinfo");

    self.playerInfoPlayer = player;

    if (!self.playerInfoHuds.size)
    {
        self.playerInfoHuds[0] = self createPlayerInfoHudElem(0, 0, true); // bg
        self.playerInfoHuds[1] = self createPlayerInfoHudElem(4, 4); // player name
        self.playerInfoHuds[2] = self createPlayerInfoHudElem(124, 4); // rank
        self.playerInfoHuds[3] = self createPlayerInfoHudElem(4, 24); // money
        self.playerInfoHuds[4] = self createPlayerInfoHudElem(4, 36); // killscores
        self.playerInfoHuds[5] = self createPlayerInfoHudElem(4, 48); // boss kills
    }

    // background
    self.playerInfoHuds[0].alpha = 0.9;
    self.playerInfoHuds[0] setShader("rndl_hud_playerinfobg", 128, 64);
    // player name
    self.playerInfoHuds[1].fontscale = 1.2;
    self.playerInfoHuds[1] setPlayerNameString(player);
    // player rank
    self.playerInfoHuds[2].alignX = "right";
    self.playerInfoHuds[2].color = (.92, .90, .20);
    self.playerInfoHuds[2].fontscale = .75;
    self.playerInfoHuds[2].label = game["playerinfo_label_rank"];
    self.playerInfoHuds[2] setValue(player.pers["rank"] + 1);
    // player money
    self.playerInfoHuds[3].label = game["playerinfo_label_money"];
    self.playerInfoHuds[3] setValue(player.pers["money"]);
    // player killscores
    self.playerInfoHuds[4].label = game["playerinfo_label_killscore"];
    self.playerInfoHuds[4] setValue(player.account["killscore"]);
    // boss kills
    self.playerInfoHuds[5].label = game["playerinfo_label_boss"];
    self.playerInfoHuds[5] setValue(player.account["boss_kills"]);

    self showPlayerInfo();
    wait 3;
    self hidePlayerInfo();
    wait .1;
    self deletePlayerInfo();

    self.playerInfoPlayer = undefined;
}

showPlayerInfo()
{
    for (i = 0; i < self.playerInfoHuds.size; i++)
    {
        self.playerInfoHuds[i] moveOverTime(.2);
        self.playerInfoHuds[i].x = self.playerInfoHuds[i].basex - 138;
    }
    wait .2;
}

hidePlayerInfo()
{
    for (i = 0; i < self.playerInfoHuds.size; i++)
    {
        self.playerInfoHuds[i] moveOverTime(.2);
        self.playerInfoHuds[i].x = self.playerInfoHuds[i].basex;
    }
    wait .2;
}

deletePlayerInfo()
{
    for (i = 0; i < self.playerInfoHuds.size; i++)
        self.playerInfoHuds[i] destroy();

    self.playerInfoHuds = [];
}

createPlayerInfoHudElem(relx, rely, isbg)
{
    h = newClientHudElem(self);
    h.alignX = "left";
    h.alignY = "top";
    h.horzAlign = "right";
    h.vertAlign = "bottom";
    h.sort = 11;
    h.basex = 0 + relx;
    h.basey = -214 + rely;
    h.x = h.basex;
    h.y = h.basey;

    if (is_true(isbg))
        h.sort = 10;
    
    return h;
}