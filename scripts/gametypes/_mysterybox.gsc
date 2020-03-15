#include scripts\_utils;

init()
{
	// Round limit per map
	level.mysteryBoxPrice = cvarDef("int", "scr_botmod_mysteryBoxPrice", 800, 1, 10000);
	level.mysterybox = getEntArray("mysterybox", "targetname");

	[[level.r_precacheString]](&"BZ_LUCKEY_CRATE");

	for (i = 0; i < level.mysterybox.size; i++)
	{
		level.mysterybox[ i ] thread mysteryBox();
	}

	updateHintsForAllCrates();
	thread checkCvar();
}

checkMoney(money)
{
	if (!isDefined(self.pers["money"])|| self.pers["money"] < money)
		return false;

	return true;
}

checkCvar()
{
	for (;;)
	{
		wait 5;

		newPrice = getCvarInt("scr_botmod_mysteryBoxPrice");
		
		if (newPrice != level.mysteryBoxPrice)
		{
			level.mysteryBoxPrice = newPrice;
			iPrintln("^6The mystery box's price has been changed. The new price is: " + level.mysteryBoxPrice + "$");

			updateHintsForAllCrates();
		}
	}
}

updateHintsForAllCrates()
{
	for (i = 0; i < level.mysterybox.size; i++)
		level.mysterybox[i] SetHintString(&"BZ_LUCKEY_CRATE", level.mysteryBoxPrice);
}

mysteryBox()
{
	orig = getEnt(self.target, "targetname");
	cap = getEnt(orig.target, "targetname");
	cap notSolid();

	for (;;)
	{
		self waittill("trigger", other);

		if (!other checkMoney(level.mysteryBoxPrice))
			continue;
		
		other notify("update_money", level.mysteryBoxPrice * -1);

		// Play SFXs
		other playLocalSound("cling");
		orig playSound("mysterybox");

		wpnModel = spawn("script_model", orig.origin);
		wpnModel.angles = orig.angles + (0,90,0);

		direction = cap.origin - orig.origin;
		direction = (direction[0] * 10, 0, direction[1] * -10);
		cap rotateVelocity(direction, 1, 0.5, 0.5);

		time = 5;
		rnd = 20;
		d = (time * 2 / rnd) / (rnd - 1);

		wpnModel moveTo(wpnModel.origin + (0,0,42), time, 0, 5);
		weaponname = undefined;

		for (i = 1; i <= rnd + 1; i++)
		{
			wait (i - 1) * d;

			if (i == rnd + 1)
			{
				weaponname = scripts\gametypes\_weapons::getWeightedRandomWeapon();
			}
			else
			{
				weaponname = scripts\gametypes\_weapons::getRandomWeapon();
			}

			wpnModel setModel(level.weapons[weaponname].worldModel);
		}

		note = "pickup_end";

		self thread waitForPickUp( other, note );
		self thread delay(5, note);
		self waittill(note, player);

		if (isDefined( player ))
		{
			player scripts\gametypes\_weapons::addWeapon(weaponname);
		}
		else
		{
			wpnModel moveTo(orig.origin, 1, 0, .5);
			wpnModel waittill("movedone");
		}
		wpnModel delete();

		cap rotateTo((0,0,0), 1, .5, .5);
		cap waittill("rotatedone");
		wait 1;
	}
}

waitForPickUp( player, note )
{
	self endon( note );

	for (;;)
	{
		self waittill( "trigger", other );
		if (other == player)
			self notify( note, other );
	}
}

delay( time, note )
{
	self endon( note );
	wait time;
	self notify( note );
}