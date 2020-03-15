#include scripts\_utils;
#include scripts\helpers\_player;

init()
{
    level.adminMenuListSize = 10;

    game["menu_admin"] = "admin";
    game["menu_admin_list"] = "admin_listcontrol";
    game["menu_admin_players"] = "clientcontrol_menu";
    game["menu_admin_maps"] = "mapcontrol_menu";

    [[level.r_precacheMenu]](game["menu_admin"]);
    [[level.r_precacheMenu]](game["menu_admin_list"]);
    [[level.r_precacheMenu]](game["menu_admin_players"]);
    [[level.r_precacheMenu]](game["menu_admin_maps"]);

    [[level.addCallback]]("onConnect", ::onPlayerConnect);
}

onPlayerConnect()
{
    self.adminMenu = [];
    self.adminMenu["currentList"] = [];
    self.adminMenu["list_currentPage"] = 0;
    self.adminMenu["list_selectedItemIndex"] = -1;

    self thread onAdminMenuResponse();

    self setList("control_players");
    self updateListCvars();
    self setClientCvar("admin_selectedItem", "");
}

onAdminMenuResponse()
{
    self endon("disconnect");

    for (;;)
    {
        self waittill("menuresponse", menu, response);

        if (!self isAdmin())
            continue;

        if (response == "openadmin")
        {

            self closeMenu();
			self closeInGameMenu();
			self openMenu(game["menu_admin"]); 
            continue;
        }

        if (menu == game["menu_admin"])
        {
            switch (response)
            {
                case "control_players":
                case "control_maps":
                    self.adminMenu["list_currentPage"] = 0;

                    self setList(response);
                    self updateListCvars();
                    self setClientCvar("admin_selectedItem", "");
                break;
            }
        }
        else if (menu == game["menu_admin_list"])
        {
            switch (response)
            {
                case "list_page_prev":
                case "list_page_next":
                    if (response == "list_page_prev")
                        i = -1;
                    else
                        i = 1;

                    self.adminMenu["list_currentPage"] = clamp(self.adminMenu["list_currentPage"] + i, 0, int(self.adminMenu["currentList"].size / level.adminMenuListSize));
                    self updateListCvars();
                break;
                case "select_item_0":
                case "select_item_1":
                case "select_item_2":
                case "select_item_3":
                case "select_item_4":
                case "select_item_5":
                case "select_item_6":
                case "select_item_7":
                case "select_item_8":
                case "select_item_9":
                    i = strtok(response, "_");
                    if (i.size == 3)
                        self setSelectionIndex(int(i[2]));
                    else
                        self setSelectionIndex(-1);

                    selectedItem = getCurrentSelectedItem();
                    if (!isDefined(selectedItem))
                        selectedItemName = "";
                    else
                        selectedItemName = selectedItem.label;

                    self setClientCvar("admin_selectedItem", selectedItemName);
                break;
            }
        }
        else if (menu == game["menu_admin_players"])
        {
            item = getCurrentSelectedItem();
            if (!isDefined(item) /*|| !isDefined(item.object)*/)
                continue;
            
            player = item.object;
            switch (response)
            {
                case "admin_kick":
                    self closeMenu();
                    self closeInGameMenu();
                    player iPrintlnBold("^5The admin kicked you!");
                    wait 3;
                    if (isDefined(player))
                        kick(player getEntityNumber());
                break;
                case "admin_kill":
                    self closeMenu();
                    self closeInGameMenu();
                    if (player.sessionstate == "playing")
                    {
                        player iPrintlnBold("^5The admin killed you!");
                        player suicide();
                    }
                break;
                case "admin_revive":
                    self closeMenu();
                    self closeInGameMenu();
                    if (player.sessionstate != "playing")
                    {
                        player iPrintlnBold("^5The admin revived you!");
                        player [[level.reborn]]();
                    }
                break;
                case "admin_addmoney":
                    self closeMenu();
                    self closeInGameMenu();
                    player iPrintlnBold("^5The admin gave you money!");
                    player notify("update_money", 1000);
                break;
                case "admin_invisible":
                    self closeMenu();
                    self closeInGameMenu();
                    if (player.sessionstate == "playing")
                    {
                        player iPrintlnBold("^5The admin made you invisible for 30secs!");
                        player thread makePlayerInvisible();
                    }
                break;
                case "admin_randomweapon":
                    self closeMenu();
                    self closeInGameMenu();
                    if (player.sessionstate == "playing")
                    {
                        weaponname = level.weaponNames[randomInt(level.weaponNames.size)];

                        self iPrintlnBold("^5Added &&1^5 to ^7" + player.name, level.weapons[weaponname].weaponName);
                        player iPrintlnBold("^5The admin gave you a random weapon!");

                        player scripts\gametypes\_weapons::addWeapon(weaponname);
                    }
                break;
            }
        }
        else if (menu == game["menu_admin_maps"])
        {
            switch (response)
            {
                case "admin_changemap":
                    item = getCurrentSelectedItem();
                    if (isDefined(item))
                    {
                        self closeMenu();
                        self closeInGameMenu();

                        iPrintlnBold("^5The admin is changing the map to " + item.object);
                        wait 3;

                        // set the next map
                        gametype = getCvar("g_gametype");
                        setCvar("sv_mapRotationCurrent", "gametype " + gametype + " map " + item.object);
                        level thread [[level.endgameconfirmed]]();
                    }
                break;
                case "admin_rotatemap":
                    self closeMenu();
                    self closeInGameMenu();

                    iPrintlnBold("^5The admin is changing to the next map!");
                    wait 3;

                    level thread [[level.endgameconfirmed]]();
                break;
                case "admin_restartmap":
                    self closeMenu();
                    self closeInGameMenu();

                    iPrintlnBold("^5The admin is restarting the map!");
                    wait 3;

                    gametype = getCvar("g_gametype");
                    currentMap = getCvar("mapname");
                    setCvar("sv_mapRotationCurrent", "gametype " + gametype + " map " + currentMap);
                    level thread [[level.endgameconfirmed]]();
                break;
            }
        }
    }
}

setList(response)
{
    self.adminMenu["currentList"] = [];
    self.adminMenu["list_selectedItemIndex"] = -1;

    if (response == "control_players")
    {
        players = getEntArray("player", "classname");
        for (i = 0; i < players.size; i++)
        {
            self.adminMenu["currentList"][i] = spawnStruct();
            self.adminMenu["currentList"][i].label = players[i].name;
            self.adminMenu["currentList"][i].object = players[i];
        }
    }
    else if (response == "control_maps")
    {
        maps = parseMaps(getCvar("sv_mapRotation"));
        for (i = 0; i < maps.size; i++)
        {
            self.adminMenu["currentList"][i] = spawnStruct();
            self.adminMenu["currentList"][i].label = maps[i];
            self.adminMenu["currentList"][i].object = maps[i];
        }
    }
}

setSelectionIndex(i)
{
    self.adminMenu["list_selectedItemIndex"] = (level.adminMenuListSize * self.adminMenu["list_currentPage"]) + i;
    self.adminMenu["list_selectedItemIndex"] = clamp(self.adminMenu["list_selectedItemIndex"], -1, self.adminMenu["currentList"].size - 1);
}

updateListCvars()
{
    for (i = 0; i < level.adminMenuListSize; i++)
    {
        index = (level.adminMenuListSize * self.adminMenu["list_currentPage"]) + i;

        if (index < self.adminMenu["currentList"].size)
            item = self.adminMenu["currentList"][index].label;
        else
            item = "";

        self setClientCvar("admin_listitem" + i, item);
    }
}

getCurrentSelectedItem()
{
    if (self.adminMenu["list_selectedItemIndex"] >= 0 && self.adminMenu["list_selectedItemIndex"] < self.adminMenu["currentList"].size)
        return self.adminMenu["currentList"][self.adminMenu["list_selectedItemIndex"]];
    else
        return undefined;
}

makePlayerInvisible()
{
    self endon("disconnect");
    self thread scripts\player\_hud::AddTimer(30, (0.27,0.4,0.78));

	self.invisibilities = add_to_array(self.invisibilities, "stinky", false);
	wait 30;
	self.invisibilities = array_remove(self.invisibilities, "stinky");
}