#include scripts\_utils;

init()
{
    [[level.addCallback]]("onPlayerSpawned", ::RunOnSpawn);

    level.lastShoutTime = getTime();
    level.shoutDelay = 1000; // delay between two shouts
}

RunOnSpawn()
{
    self endon("disconnect");
    self endon("killed_player");

    oldstates = [];
    curstates = [];

    curstates[0] = false;
    curstates[1] = false;
    curstates[2] = false;
    curstates[3] = false;
    curstates[4] = false;
    curstates[5] = false;
    curstates[6] = false;

    oldweap1 = "none";
    oldweap2 = "none";

    for (;;)
    {
        oldmoney = self.pers["money"];
        oldgamestate = game["state"];

        // copy current states to the old
        for (i = 0; i < curstates.size; i++)
            oldstates[i] = curstates[i];

        wait randomFloatRange(2, 5); // minimum delay between two shouts

        curstates[0] = getAmmoStatePrimary(oldstates[0]);
        curstates[1] = getAmmoStateSecondary(oldstates[1]);
        curstates[2] = getHealthState(oldstates[2]);
        curstates[3] = getReviveState(oldstates[3]); // never go true, because the notify stops the script
        curstates[4] = getMoneyLostState(oldstates[4], oldmoney);
        curstates[5] = getLaughState(oldstates[5]);
        curstates[6] = getEndRoundState(oldstates[6], oldgamestate);

        // watch rising and falling edges

        if ((curstates[0] && !oldstates[0]) || (curstates[1] && !oldstates[1]))
        {
            self shout("need_ammo", "Need ammo!");
        }
        else if (curstates[3] && !oldstates[3])
        {
            self shout("need_medic_down", "1 hp!");
        }
        else if (curstates[2] && !oldstates[2])
        {
            self shout("need_medic", "Medic!");
        }
        else if (curstates[4] && !oldstates[4])
        {
            self shout("nomoney");
        }
        else if (curstates[5] && !oldstates[5])
        {
            self shout("laughing");
        }
        else if (curstates[6] && !oldstates[6])
        {
            self shout("goodjob");
        }
        else if ((!curstates[0] && oldstates[0]) || (!curstates[1] && oldstates[1]))
        {
            self shout("thanks", "Thanks!");
        }
        else if (game["state"] == "playing" && !curstates[2] && oldstates[2])
        {
            self shout("thanks", "Thanks!");
        }
        else if (game["state"] == "playing" && !curstates[3] && oldstates[3])
        {
            self shout("thanks_revived", "Thanks bro!");
        }
    }
}

getAmmoStatePrimary(oldValue)
{
    if (self getWeaponSlotWeapon("primary") == self._sprintweapon)
        return oldValue;

    return self getWeaponSlotAmmo("primary") < 20;
}

getAmmoStateSecondary(oldValue)
{
    if (self getWeaponSlotWeapon("primaryb") == self._sprintweapon)
        return oldValue;

    return self getWeaponSlotAmmo("primaryb") < 20;
}

getHealthState(oldValue)
{
    return game["state"] == "playing" && self.health < 40;
}

getReviveState(oldValue)
{
    return game["state"] == "playing" && self.health < 10;
}

getMoneyLostState(oldValue, oldMoney)
{
    return oldMoney - self.pers["money"] >= 1000 || self.pers["money"] < 200;
}

getEndRoundState(oldValue, oldGameState)
{
    return oldGameState == "playing" && game["state"] == "readyup";
}

getLaughState(oldValue)
{
    return isDefined(self.old_score) && self.old_score > 100 && !randomInt(5);
}

shout(soundalias, saytext)
{
    currTime = getTime();
    if (currTime - level.lastShoutTime < level.shoutDelay)
        return;

    if (isDefined(saytext) && saytext != "")
        self sayTeam(saytext);

    self playSound(soundalias);
    self pingPlayer();

    level.lastShoutTime = currTime;
}