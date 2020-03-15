#include scripts\_utils;

init()
{
    [[level.addCallback]]("onPlayerSpawned", ::RunOnSpawn);
	[[level.addCallback]]("onPlayerKilled", ::RunOnKilled);

    level.objectiveHuds = [];
    level.objectiveHudX = -10;
    level.objectiveHudY = 140;

    [[level.r_precacheShader]]("gfx/hud/hud@health_back.tga");
    [[level.r_precacheShader]]("gfx/hud/hud@health_bar.tga");
}

RunOnSpawn()
{
    self thread UpdateHealth();
    self thread UpdatDogHealth();
}

RunOnKilled(eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration)
{
	if (isDefined(self.healthbar))
        self.healthbar destroy();

    if (isDefined(self.doghealthbar))
        self.doghealthbar destroy();

    if (isDefined(self.scorebar))
        self.scorebar destroy();
}

UpdateHealth()
{
    self endon("disconnect");
    self endon("killed_player");

    for (;;)
    {
        if (!isDefined(self.healthbar))
        {
            self.healthbar = newClientHudElem(self);
            self.healthbar.alpha = 0.9;
            self.healthbar.alignX = "left";
            self.healthbar.alignY = "top";
            self.healthbar.horzAlign = "left";
            self.healthbar.vertAlign = "bottom";
            self.healthbar.x = 11;
            self.healthbar.y = -15;
            self.healthbar.sort = 10;
        }

        maxwidth = 126;
        healthbarWidth = int(self.health / self.maxhealth * maxwidth);

        if (healthbarWidth < 1)
            healthbarWidth = 1;

        // healthbar color
        if (self.health < 30)
            self.healthbar.color = (1.0, 0.0, 0.0);
        else
            self.healthbar.color = (0.0, 1.0, 0.0);

        self.healthbar setShader("gfx/hud/hud@health_bar.tga", healthbarWidth, 4);

        self waittill("update_healthbar");
    }
}

UpdatDogHealth()
{
    self endon("disconnect");
    self endon("killed_player");

    for (;;)
    {

        dog = undefined;
        for (i = 0; i < level.friendlyAIs.size; i++)
        {
            if (level.friendlyAIs[i].parent == self)
            {
                dog = level.friendlyAIs[i];
                break;
            }
        }

        if (isDefined(dog))
        {
            if (!isDefined(self.doghealthbar))
            {
                self.doghealthbar = newClientHudElem(self);
                self.doghealthbar.alpha = 0.9;
                self.doghealthbar.alignX = "left";
                self.doghealthbar.alignY = "top";
                self.doghealthbar.horzAlign = "left";
                self.doghealthbar.vertAlign = "bottom";
                self.doghealthbar.x = 11;
                self.doghealthbar.y = -25;
                self.doghealthbar.sort = 10;
                self.doghealthbar.color = (1.0, 1.0, 0.0);
            }

            maxwidth = 126;
            healthbarWidth = int(dog.health / dog.maxhealth * maxwidth);

            if (healthbarWidth < 1)
                healthbarWidth = 1;

            self.doghealthbar setShader("gfx/hud/hud@health_bar.tga", healthbarWidth, 4);

            self setClientCvar("ui_allow_doghealth", 1);
        }
        else
        {
            if (isDefined(self.doghealthbar))
                self.doghealthbar destroy();

            self setClientCvar("ui_allow_doghealth", 0);
        }

        self waittill("update_doghealthbar");
    }
}

SetRank(rank)
{
    self setClientCvar("hud_rank_text", rank);
}

SetRound(roundNumber)
{
    players = getAllPlayers();
    for (i = 0; i < players.size; i++)
        players[i] setClientCvar("hud_round", roundNumber);
}

SetBossHealth(maxHealth, currentHealth, label)
{
    if (!isDefined(level.bosshealthbarbg))
    {
        level.bosshealthbarbg = newHudElem();
        level.bosshealthbarbg.horzAlign = "center_safearea";
        level.bosshealthbarbg.vertAlign = "top";
        level.bosshealthbarbg.alignX = "left";
        level.bosshealthbarbg.alignY = "top";
        level.bosshealthbarbg.x = -200;
        level.bosshealthbarbg.y = 20;
        level.bosshealthbarbg setShader("gfx/hud/hud@health_back.tga", 400, 10);
    }
    if (!isDefined(level.bosshealthbar))
    {
        level.bosshealthbar = newHudElem();
        level.bosshealthbar.horzAlign = "center_safearea";
        level.bosshealthbar.vertAlign = "top";
        level.bosshealthbar.alignX = "left";
        level.bosshealthbar.alignY = "top";
        level.bosshealthbar.x = -199;
        level.bosshealthbar.y = 21;
        level.bosshealthbar.color = (1.0, 0.0, 0.0);
        level.bosshealthbar.alpha = 0.9;
        level.bosshealthbar.sort = 10;
    }
    if (isDefined(label) && !isDefined(level.bossname))
    {
        level.bossname = newHudElem();
        level.bossname.horzAlign = "center_safearea";
        level.bossname.vertAlign = "top";
        level.bossname.alignX = "left";
        level.bossname.alignY = "top";
        level.bossname.x = -200;
        level.bossname.y = 32;
        level.bossname.color = (1, 1, 1);
        level.bossname.font = "default";
        level.bossname.fontscale = 1.25;
    }

    width = int(currentHealth / maxHealth * 398);
    if (width < 1)
        width = 1;

    level.bosshealthbar setShader("gfx/hud/hud@health_bar.tga", width, 8);

    if (isDefined(label))
        level.bossname setText(label);
}

DeleteBossHealth()
{
    if (isDefined(level.bosshealthbar))
        level.bosshealthbar destroy();
    if (isDefined(level.bosshealthbarbg))
        level.bosshealthbarbg destroy();
    if (isDefined(level.bossname))
        level.bossname destroy();
}

AddObjective(type, label, value)
{
    i = level.objectiveHuds.size;

    level.objectiveHuds[i] = newHudElem();
    level.objectiveHuds[i].horzAlign = "right";
    level.objectiveHuds[i].vertAlign = "top";
    level.objectiveHuds[i].alignX = "right";
    level.objectiveHuds[i].alignY = "top";
    level.objectiveHuds[i].x = level.objectiveHudX;
    level.objectiveHuds[i].y = level.objectiveHudY + (i * 12);
    level.objectiveHuds[i].font = "default";
	level.objectiveHuds[i].fontscale = .9;
    level.objectiveHuds[i].label = label;
    level.objectiveHuds[i].type = type;
    
    if (isDefined(value))
        SetObjective(i, value);

    return i;
}

SetObjective(index, value)
{
    assert(index >= 0 && index < level.objectiveHuds.size);

    switch (level.objectiveHuds[index].type)
    {
        case "value":
            level.objectiveHuds[index] SetValue(value);
        break;
        case "timer":
            level.objectiveHuds[index] SetTimer(value);
        break;
        case "timerup":
            level.objectiveHuds[index] SetTimerUp(value);
        break;
        case "text":
            level.objectiveHuds[index] SetText(value);
        break;
        case "playername":
            level.objectiveHuds[index] SetPlayerNameString(value);
        break;
        case "none":
        default:
        break;
    }
}

ClearObjective(index)
{
    assert(index >= 0 && index < level.objectiveHuds.size);

    level.objectiveHuds[index] destroy();
    level.objectiveHuds = array_removeAt(level.objectiveHuds, index);

    // reposition objective huds
    for (i = index; i < level.objectiveHuds[i].size; i++)
    {
        level.objectiveHuds[i].x = level.objectiveHudX;
        level.objectiveHuds[i].y = level.objectiveHudY + (i * 12);
    }
}

ClearObjectives()
{
    for (i = 0; i < level.objectiveHuds.size; i++)
        level.objectiveHuds[i] destroy();

    level.objectiveHuds = [];
}

AddTimer(time, color)
{
	if (!isDefined(self.timerhuds))
		self.timerhuds = [];

	size = self.timerhuds.size;
	self.timerhuds[size] = newClientHudElem( self );
	self.timerhuds[size].alignX = "center";
	self.timerhuds[size].alignY = "middle";
	self.timerhuds[size].horzAlign = "center";
	self.timerhuds[size].vertAlign = "middle";
	self.timerhuds[size].fontscale = 1.5;
	self.timerhuds[size].foreground = 1;
	self.timerhuds[size].alpha = 1;
	self.timerhuds[size].color = color;
	self.timerhuds[size] SetTimer( time );

	self thread updateTimer(self.timerhuds[size], time );
	self thread deleteTimer(self.timerhuds[size] );
}

updateTimer(hud, time)
{
	self endon("disconnect");

	for (i = 0; i < time * 2; i++)
	{
		size = 0;
		for (j = 0; j < self.timerhuds.size; j++)
			if (self.timerhuds[j] == hud)
				size = j;

		hud.x = 0;
		hud.y = 128 - size * 24;

		wait 0.5;
	}

	hud notify("kill_hud");
}

deleteTimer(hud)
{
	self endon("disconnect");

	hud waittill_any("kill_hud", "killed_player");
	self.timerhuds = array_remove(self.timerhuds, hud);
	hud destroy();
}