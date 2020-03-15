#include scripts\_utils;

init()
{
	Settings();
	[[level.addCallback]]("onConnect", ::onPlayerConnect);
}

Settings()
{
	game["menu_shop"] = "shop";

	[[level.r_precacheMenu]](game["menu_shop"]);
	[[level.r_precacheString]](&"BZ_SHOP");

	level.shopnames = [];
	level.shop = [];

	addShopItem("ammo", 300, "buy_ammo", "ui_allow_buyammo", ::buy_ammo);
	addShopItem("health", 3000, "buy_health", "ui_allow_buyhealth", ::buy_health, ::clear_health);
	addShopItem("sprint", 2500, "buy_sprint", "ui_allow_buysprint", ::buy_sprint, ::clear_sprint);
	addShopItem("revive", 1500, "buy_revive", "ui_allow_buyrevive", ::buy_revive, ::clear_revive);
	addShopItem("bonus", 2750, "buy_bonus", "ui_allow_buybonus", ::buy_bonus, ::clear_bonus);
	addShopItem("quickreload", 2500, "buy_quickreload", "ui_allow_buyquickreload", ::buy_quickreload);
	addShopItem("pet", 2000, "buy_pet", "ui_allow_buypet", ::buy_pet, ::clear_pet);

	level.markets = getEntArray("ammobox", "targetname");
	for (i = 0; i < level.markets.size; i++)
		level.markets[i] thread shop();
}

addShopItem(name, price, menureponse, uiallow, onBuy, onClear)
{
	level.shopnames[level.shopnames.size] = name;

	level.shop[name]			= spawnStruct();
	level.shop[name].price		= price;
	level.shop[name].buy		= onBuy;
	level.shop[name].clear		= onClear;
	level.shop[name].resp		= menureponse;
	level.shop[name].uiallow	= uiallow;
}

ClearAll()
{
	// clear buyed items
	for (i = 0; i < level.shopnames.size; i++)
	{
		bonusname = level.shopnames[i];

		if (isDefined(level.shop[bonusname].clear))
			[[level.shop[bonusname].clear]](bonusname);

		self.buyed[bonusname] = false;
	}
}

shop()
{
	self SetHintString(&"BZ_SHOP");

	for (;;)
	{
		self waittill("trigger", player);

		player openMenu(game["menu_shop"]);
	}
}

onPlayerConnect()
{
	self.buyed = [];
	for (i = 0; i < level.shopnames.size; i++)
	{
		bonusname = level.shopnames[i];
		self.buyed[bonusname] = false;
	}

	self thread updateUIAllowes();
	self thread onMenuResponse();
}

onMenuResponse()
{
	self endon("disconnect");

	for (;;)
	{
		self waittill("menuresponse", menu, response);

		if ( menu == game["menu_shop"] )
		{
			touchtrigger = false;
			for (i = 0; i < level.markets.size; i++)
			{
				if ( self isTouching( level.markets[ i ] ) )
					touchtrigger = true;
			}

			if ( ! touchtrigger )
				continue;

			for (i = 0; i < level.shopnames.size; i++)
			{
				if ( level.shop[ level.shopnames[ i ] ].resp == response )
				{
					if (!self.buyed[level.shopnames[i]] && checkMoney(level.shop[level.shopnames[i]].price))
					{
						self notify("update_money", level.shop[level.shopnames[i]].price * -1);

						self thread [[level.shop[level.shopnames[i]].buy]](level.shopnames[i]);
					}
				}
			}

			self closeMenu();
			self closeIngameMenu();
		}
	}
}

// call on player
updateUIAllowes()
{
	self endon("disconnect");

	for (;;)
	{
		for (i = 0; i < level.shopnames.size; i++)
		{
			if (!checkMoney(level.shop[level.shopnames[i]].price) || self.buyed[level.shopnames[i]] )
				self setClientCvar(level.shop[level.shopnames[i]].uiallow, "0");
			else
				self setClientCvar(level.shop[level.shopnames[i]].uiallow, "1");
		}

		self waittill_any("update_money", "spawned_player");
		wait 1;
	}
}

checkMoney(money)
{
	if (!isDefined(self.pers["money"]) || self.pers["money"] < money)
		return false;

	return true;
}

// Max ammo

buy_ammo(bonusname)
{
	if ( level.sprint )
	{
		self endon("disconnect");

		while ( isDefined( self._sprintweapon ) && self hasWeapon( self._sprintweapon ) )
			wait 0.05;
	}

	// Add max ammo
	if (isDefined(self.pers["weapon1"]) && self.pers["weapon1"] != "none")
		self giveMaxAmmo(self.pers["weapon1"]);
	if (isDefined(self.pers["weapon2"]) && self.pers["weapon2"] != "none")
		self giveMaxAmmo(self.pers["weapon2"]);
}

// Double health

buy_health(bonusname)
{
	self.buyed[bonusname] = true;
	self.maxhealth = 200;
	self setHealth(self.maxhealth);
}

clear_health(bonusname)
{
	self.maxhealth = 100;
}

// Faster sprint

buy_sprint(bonusname)
{
	self.buyed[bonusname] = true;
	self._sprintweapon = level.sprintweapon_fast;
}

clear_sprint(bonusname)
{
	self._sprintweapon = level.sprintweapon_slow;
}

// Faster revive

buy_revive(bonusname)
{
	self.buyed[bonusname] = true;
	self.revivingTime = level.revivingTimeFast;
}

clear_revive(bonusname)
{
	self.revivingTime = level.revivingTime;
}

// Bonus area

buy_bonus(bonusname)
{
	self.buyed[bonusname] = true;
	self.bonusdist *= 4;
}

clear_bonus(bonusname)
{
	self.bonusdist = level.bonusdist;
}

// Quick reload

buy_quickreload(bonusname)
{
	self.buyed[bonusname] = true;
}

// Pet

buy_pet(bonusname)
{
	self endon("disconnect");
	self.buyed[bonusname] = true;

	self.pet = self scripts\_friendlyai::spawnFriendlyAI("dog");

	self notify("update_doghealthbar");
	self.pet waittill("killed_ai");
	self notify("update_doghealthbar");

	self.buyed[bonusname] = false;
}

clear_pet(bonusname)
{
	if (isDefined(self.pet))
	{
		self.pet notify("killed_ai");
	}
}