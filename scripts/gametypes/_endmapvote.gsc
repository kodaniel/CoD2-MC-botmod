#include scripts\_utils;

init()
{
    level.voteMaps = [];
    level.voteMapCount = cvarDef("int", "scr_botmod_vote_mapcount", 6, 0, 6);
    level.endmapvoteTime = cvarDef("int", "scr_botmod_vote_time", 10, 0, 60);

    game["menu_mapvote"] = "mapvote";
    [[level.r_precacheMenu]](game["menu_mapvote"]);

    // just for test
    //setCvar("sv_mapRotation", "gametype mcbot map mc_skyville gametype mcbot map mc_babylon gametype mcbot map mc_bridge gametype mcbot map mc_library gametype mcbot map mc_atlantis gametype mcbot map mc_survivalwest gametype mcbot map mc_fos gametype mcbot map mc_village  gametype mcbot map mc_underworld gametype mcbot map mc_burgundy gametype mcbot map mc_skyscraper gametype mcbot map mc_snowmaze gametype mcbot map mc_case");
}

startVote()
{
    // if the time is 0, then voting is disabled
    if (!level.endmapvoteTime)
        return;

    gametype = getCvar("g_gametype");
    allMaps = getCvar("sv_mapRotation");
    currentMap = getCvar("mapname");

    level.endmapvoteStartTime = getTime();
    maps = parseMaps(allMaps);

    // Pick random next maps
    for (i = 0; i < level.voteMapCount && i < maps.size; i++)
    {
        mapname = array_randomItem(maps);
        maps = array_remove(maps, mapname);

        level.voteMaps[i] = spawnStruct();
        level.voteMaps[i].mapname = mapname;
        level.voteMaps[i].votes = 0;
    }

    if (!level.voteMaps.size)
        return;

    // Close everything and open the voting menu
    players = getentarray("player", "classname");
	for (i = 0; i < players.size; i++)
	{
		player = players[i];

		player closeMenu();
		player closeInGameMenu();
        player openMenu(game["menu_mapvote"]);

        player thread onMenuResponse();
    }

    updateVoteMenuForEveryone();
    thread countTime(); // updates the timer

    wait level.endmapvoteTime;
    level notify("vote_end");

    // Close the voting menu for everyone
    players = getentarray("player", "classname");
	for (i = 0; i < players.size; i++)
	{
		player = players[i];
		player closeMenu();
		player closeInGameMenu();
    }

    level.voteMaps = array_shuffle(level.voteMaps); // shuffle, so the map will be random if the votes are equal
    level.voteMaps = sortMapsByVotes(level.voteMaps); // most votes are first

    // set the next map
    setCvar("sv_mapRotationCurrent", "gametype " + gametype + " map " + level.voteMaps[0].mapname);

    iPrintlnBold("The next map is:");
    iPrintlnBold("^1" + level.voteMaps[0].mapname);

    wait 5;
}

onMenuResponse()
{
    level endon("vote_end");
    self endon("disconnect");

    for (;;)
    {
        self waittill("menuresponse", menu, response);

        if (menu == game["menu_mapvote"])
        {
            n = int(response);
            if (n >= 0 && n < level.voteMaps.size)
            {
                if (isDefined(self.voted))
                    level.voteMaps[self.voted].votes--;
                
                self.voted = n;
                level.voteMaps[self.voted].votes++;

                updateVoteMenuForEveryone();
            }
        }
    }
}

countTime()
{
    level endon("vote_end");
    while (true)
    {
        wait 1;
        updateVoteMenuForEveryone();
    }
}

updateVoteMenuForEveryone()
{
    t = level.endmapvoteTime - int((getTime() - level.endmapvoteStartTime) / 1000);
    players = getentarray("player", "classname");
	for (i = 0; i < players.size; i++)
	{
        players[i] setClientCvar("ui_votemap_time", t);

        for (j = 0; j < level.voteMaps.size; j++)
            players[i] setClientCvar("ui_votemap" + (j + 1), getVoteText(level.voteMaps[j]));
    }
}

getVoteText(voteMap)
{
    return voteMap.mapname + " (" + voteMap.votes + ")";
}

sortMapsByVotes(array)
{
    temp = array;
    for (i = 0; i < temp.size - 1; i++)
	{
		for (j = i + 1; j < temp.size; j++)
		{
			if (temp[i].votes < temp[j].votes)
			{
				var = temp[i];
				temp[i] = temp[j];
				temp[j] = var;
			}
		}
	}
    return temp;
}