#include scripts\_utils;

init()
{
    [[level.addCallback]]("onPlayerSpawned", ::RunOnSpawn);
}

RunOnSpawn()
{
    self endon("disconnect");
    self endon("killed_player");

    for (;;)
    {
        wait 0.05;

        if (!self.buyed["quickreload"])
            continue;

        weaponSlot = self getCurrentWeaponSlot();
        ammo = self getWeaponSlotAmmo(weaponSlot);
        clipammo = self getWeaponSlotClipAmmo(weaponSlot);

        if (!clipammo && ammo > 0)
        {
            weapon = self getCurrentWeapon();
            clipsize = scripts\gametypes\_weapons::getWeaponClipSize(weapon);

            if (clipsize > 0)
            {
                quickReloadTime = scripts\gametypes\_weapons::getWeaponReloadQuickTime(weapon);
                while (quickReloadTime > 0 && weapon == self getCurrentWeapon()) // does switch weapon under reloading?
                {
                    wait 0.05;
                    quickReloadTime -= 0.05;
                }

                if (quickReloadTime <= 0)
                {
                    ammo = self getWeaponSlotAmmo(weaponSlot); // if the player would get max ammo while reloading
                    newammo = max(0, ammo - clipsize);
                    newclipammo = min(clipsize, ammo);

                    self takeWeapon(weapon);
                    self setWeaponSlotWeapon(weaponSlot, weapon);
                    self setWeaponSlotAmmo(weaponSlot, newammo);
                    self setWeaponSlotClipAmmo(weaponSlot, newclipammo);
                }
            }
        }
    }
}