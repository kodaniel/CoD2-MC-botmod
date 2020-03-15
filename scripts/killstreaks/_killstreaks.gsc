#include scripts\_utils;

init()
{
    scripts\killstreaks\_ghost::init();
    scripts\killstreaks\_sentry::init();
    scripts\killstreaks\_airstrike::init();
    scripts\killstreaks\_firetrap::init();
    scripts\killstreaks\_c4::init();

    defineKillstreak("c4", 75, 1, scripts\killstreaks\_c4::RunOnUse, scripts\killstreaks\_c4::IsAllowed, "rndl_hud_ks_c4", &"C4", "ks_default", "ui_allowed_c4");
    defineKillstreak("ghost", 100, 3, scripts\killstreaks\_ghost::RunOnUse, scripts\killstreaks\_ghost::IsAllowed, "rndl_hud_ks_ghost", &"Invisibility", "ks_default", "ui_allowed_ghost");
    defineKillstreak("firetrap", 150, 5, scripts\killstreaks\_firetrap::RunOnUse, scripts\killstreaks\_firetrap::IsAllowed, "rndl_hud_ks_firetrap", &"Fire trap", "ks_default", "ui_allowed_firetrap");
    defineKillstreak("airstrike", 200, 7, scripts\killstreaks\_airstrike::RunOnUse, scripts\killstreaks\_airstrike::IsAllowed, "rndl_hud_ks_airstrike", &"Airstrike", "ks_airstrike", "ui_allowed_airstrike");
    defineKillstreak("sentrygun", 250, 9, scripts\killstreaks\_sentry::RunOnUse, scripts\killstreaks\_sentry::IsAllowed, "rndl_hud_ks_sentrygun", &"Sentry gun", "ks_sentrygun", "ui_allowed_sentrygun");

    game["menu_quickstrikes"] = "quickstrikes";
    [[level.r_precacheMenu]](game["menu_quickstrikes"]);
    [[level.r_precacheString]](&"BZ_KILLSCORES");

    [[level.addCallback]]("onPlayerLogin", ::onPlayerLogin);
    [[level.addCallback]]("onPlayerSpawned", ::onPlayerSpawned);
    [[level.addCallback]]("onPlayerKilled", ::onPlayerKilled);
    [[level.addCallback]]("onZombieKilled", ::onZombieKilled);
}

defineKillstreak(name, score, rank, startFunc, enabledFunc, hudicon, hudtext, sound, uiallowed)
{
    if (!isDefined(level.killStreakNames))
        level.killStreakNames = [];

    level.killStreakNames[level.killStreakNames.size] = name;

    if (!isDefined(level.killStreak))
        level.killStreak = [];

    level.killStreak[name] = spawnStruct();
    level.killStreak[name].score = score;
    level.killStreak[name].rank = rank;
    level.killStreak[name].enabled = enabledFunc;
    level.killStreak[name].start = startFunc;
    level.killStreak[name].icon = hudicon;
    level.killStreak[name].text = hudtext;
    level.killStreak[name].sound = sound;
    level.killStreak[name].uiallowed = uiallowed;

    if (isDefined(hudicon)) [[level.r_precacheShader]](hudicon);
    if (isDefined(hudtext)) [[level.r_precacheString]](hudtext);
}

onPlayerLogin()
{
    self.achievedList = [];
    for (i = 0; i < level.killStreakNames.size; i++)
    {
        if (self.account["killscore"] >= level.killStreak[level.killStreakNames[i]].score)
            self.achievedList = array_add(self.achievedList, level.killStreakNames[i]);
    }
}

onPlayerSpawned()
{
    if (!isDefined(self.killstreakScores))
    {
        self.killstreakScores = newClientHudElem(self);
        self.killstreakScores.horzAlign = "left";
        self.killstreakScores.vertAlign = "top";
        self.killstreakScores.alignX = "left";
        self.killstreakScores.alignY = "top";
        self.killstreakScores.x = 72;
        self.killstreakScores.y = 35;
        self.killstreakScores.sort = 10;
        self.killstreakScores.font = "default";
		self.killstreakScores.fontscale = 1.25;
        self.killstreakScores.label = &"BZ_KILLSCORES";
    }

    self thread updateKillstreakScore();
}

onPlayerKilled(eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration)
{
	if (isDefined(self.killstreakScores))
        self.killstreakScores destroy();

    self notify("update_streakscore");
}

onZombieKilled(eAttacker, iDamage, argument)
{
    if (isPlayer(eAttacker))
    {
        eAttacker.account["killscore"]++;
        eAttacker notify("update_streakscore");
    }
}

updateKillstreakScore()
{
    self endon("disconnect");
    self endon("killed_player");

    for (;;)
    {
        self.killstreakScores SetValue(self.account["killscore"]);

        for (i = 0; i < level.killStreakNames.size; i++)
        {
            ks = level.killStreak[level.killStreakNames[i]];

            if (![[ks.enabled]]()) // killstreak is not available
            {
                self setClientCvar(level.killStreak[level.killStreakNames[i]].uiallowed, "0");
            }
            else if (self.pers["rank"] < ks.rank) // the rank is too low to use this killstreak
            {
                self setClientCvar(level.killStreak[level.killStreakNames[i]].uiallowed, "1");
                continue;
            }
            else // killstreak is available
            {
                self setClientCvar(level.killStreak[level.killStreakNames[i]].uiallowed, "2");
            }

            if (!is_in_array(self.achievedList, level.killStreakNames[i]) && self.account["killscore"] >= ks.score)
            {
                self.achievedList = array_add(self.achievedList, level.killStreakNames[i]);
                // play notification
                self scripts\player\_notification::Notification(ks.text, ks.icon, ks.sound);
            }
        }

        self waittill("update_streakscore");
    }
}

quickstrikes(response)
{
    if (is_in_array(level.killStreakNames, response))
    {
        ks = level.killStreak[response];
        if (![[ks.enabled]]())
            return;
        
        if (self.pers["rank"] < ks.rank)
        {
            self iPrintlnBold("^1This killstreak is available from rank " + (ks.rank + 1));
            return;
        }

        if (self.account["killscore"] < ks.score)
        {
            self iPrintlnBold("^1You have to gain " + (ks.score - self.account["killscore"]) + " kills");
            return;
        }

        success = self [[ks.start]]();
        if (is_true(success))
        {
            self.account["killscore"] -= ks.score;
            self.achievedList = array_remove(self.achievedList, response);

            self notify("update_streakscore");
        }
    }
}