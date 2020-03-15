#include scripts\_utils;

init()
{
    // do not change on the server!
    level.rank_a = 15;
    level.rank_b = 5;
    level.rank_c = 200;
    level.maxlevel = 19; // means 20, because [0-19]

    [[level.addCallback]]("onConnect", ::RunOnConnect);
    [[level.addCallback]]("onPlayerSpawned", ::RunOnSpawn);
	[[level.addCallback]]("onPlayerLogin", ::RunOnLogin);

    //[[level.r_precacheString]](&"BZ_LEVELUP");
    [[level.r_precacheShader]]("rndl_icon_levelup");
}

RunOnConnect()
{
    self UpdateRankInfo();
}

RunOnLogin()
{
    self UpdateRankInfo();
}

RunOnSpawn()
{
    self UpdateScoreBar();
}

AddScore(score)
{
    if (self.account["scores"] < self.pers["nextRankScoreLimit"])
    {
        self.account["scores"] = min(self.account["scores"] + score, self.pers["nextRankScoreLimit"]);
    }

    self LevelUp();
    self UpdateScoreBar();
}

LevelUp()
{
    // no more ranks
    if (self.pers["rank"] == self.pers["nextRank"])
        return;
    
    // not enough score or boss kills
    if (self.account["scores"] < self.pers["nextRankScoreLimit"] || self.account["boss_kills"] < self.pers["nextRankBossKills"])
        return;

    self UpdateRankInfo();
    self notify("levelup");
    
    self scripts\player\_notification::Notification(undefined, "rndl_icon_levelup", "levelup");
}

UpdateRankInfo()
{
    score = self.account["scores"];
    rank = (-1 * level.rank_b + sqrt(level.rank_b * level.rank_b + 4 * level.rank_a * score / level.rank_c)) / (2 * level.rank_a);
    rank = clamp(int(rank), 0, level.maxlevel);

    while (rank > 0 && self.account["boss_kills"] < GetRankBossKills(rank))
        rank--;

    self.pers["rank"] = rank;
    self.pers["currentRankScoreLimit"] = GetRankScoreLimit(rank);
    self.pers["currentRankBossKills"] = GetRankBossKills(rank);
    self.pers["nextRank"] = min(rank + 1, level.maxlevel);
    self.pers["nextRankScoreLimit"] = GetRankScoreLimit(self.pers["nextRank"]);
    self.pers["nextRankBossKills"] = GetRankBossKills(self.pers["nextRank"]);

    self setClientCvar("hud_rank_text", "Rank " + (self.pers["rank"] + 1));
}

UpdateScoreBar()
{
    if (!isDefined(self.scorebar))
    {
        self.scorebar = newClientHudElem(self);
        self.scorebar.color = (.92, .90, .20);
        self.scorebar.alpha = 0.95;
        self.scorebar.alignX = "left";
        self.scorebar.alignY = "top";
        self.scorebar.horzAlign = "center";
        self.scorebar.vertAlign = "bottom";
        self.scorebar.x = -99;
        self.scorebar.y = -15;
        self.scorebar.sort = 1;
    }

    if (self.account["scores"] > self.pers["nextRankScoreLimit"])
        width = 198;
    else
        width = int((self.account["scores"] - self.pers["currentRankScoreLimit"]) / (self.pers["nextRankScoreLimit"] - self.pers["currentRankScoreLimit"]) * 198);

    if (width < 1)
        width = 1;

    self.scorebar setShader("gfx/hud/hud@health_bar.tga", width, 4);

    // Rank text
    if (self.account["scores"] < self.pers["nextRankScoreLimit"])
    {
        self setClientCvar("hud_rank_text", "Rank " + (self.pers["rank"] + 1));
    }
    else if (self.pers["rank"] == self.pers["nextRank"])
    {
        self setClientCvar("hud_rank_text", "^3Maximum level");
    }
    else if (self.account["boss_kills"] < self.pers["nextRankBossKills"])
    {
        needBossKills = self.pers["nextRankBossKills"] - self.account["boss_kills"];
        if (needBossKills > 1)
            self setClientCvar("hud_rank_text", "^3Kill " + needBossKills + " boss(es) to level up");
        else
            self setClientCvar("hud_rank_text", "^3Kill " + needBossKills + " boss to level up");
    }
}

// Returns the lower score limit of the rank.
GetRankScoreLimit(rank)
{
    if (rank == 0)
        return 0;

    return int(level.rank_a * rank * rank + level.rank_b * rank) * level.rank_c;
}

GetRankBossKills(rank)
{
    r = strtok("0,0,0,0,0,1,2,3,4,5,7,9,11,13,15,18,21,24,27,30", ",");
    if (rank >= r.size)
        return int(r[r.size - 1]);
    return int(r[rank]);
}