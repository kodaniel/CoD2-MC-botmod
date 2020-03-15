main()
{
	level._effect["lightning"] = loadfx("fx/misc/lightning.efx");
	level._effect["rain"] = loadfx("fx/misc/rain_3.efx");
	
	maps\mp\_load::main();

	setExpFog(0.0002, 0.65, 0.55, 0.6, 0);

	game["allies"] = "american";
	game["axis"] = "german";
	game["attackers"] = "allies";
	game["defenders"] = "axis";
	game["russian_soldiertype"] = "normandy";
	game["german_soldiertype"] = "normandy";

	setCvar("r_glowbloomintensity0", ".25");
	setCvar("r_glowbloomintensity1", ".25");
	setcvar("r_glowskybleedintensity0",".3");

	if (getCvar("g_gametype") == "mcbot")
	{
		level.ai_max = 24;
	}

	level.skyorigin = (-1024, -1024, 2000);
	level.skyradius = 3500;

	ambientPlay("ambient_untoten");

	level thread thunder();
	level thread rain();
}

thunder()
{
	maps\mp\_fx::loopfx("lightning", (-2744, -1816, 1600), 9.0);
	maps\mp\_fx::loopfx("lightning", (-2360, -280, 1600), 10.0);
	maps\mp\_fx::loopfx("lightning", (-2168, 1896, 1600), 12.0);
    maps\mp\_fx::loopfx("lightning", (-376, 872, 1600), 18.0);
	maps\mp\_fx::loopfx("lightning", (-120, 488, 1600), 10.0);
	maps\mp\_fx::loopfx("lightning", (392, 2216, 1600), 16.0);
    maps\mp\_fx::loopfx("lightning", (2440, -1048, 1600), 15.0);
    maps\mp\_fx::loopfx("lightning", (2312, 1576, 1600), 8.0);
    maps\mp\_fx::loopfx("lightning", (-376, -1240, 1600), 10.0);
    maps\mp\_fx::loopfx("lightning", (1736, -2392, 1600), 23.0);
}

rain()
{
	for (;;)
	{
		players = getEntArray("player", "classname");
		if(players.size > 0) 
		{
			max_nodes = 10; 
        	max_nodes_per_player = max_nodes / players.size;

			for (ii = 0; ii < max_nodes_per_player; ii++)
			{
				for(i = 0; i < players.size; i++)
				{
					player = players[i];

					if(isAlive(player)) 
					{
                 		x = 350 - randomfloat(350);
            			y = 350 - randomfloat(350);

                		origin = player.origin + (x, y, 600); 
 	  					playfx(level._effect["rain"], origin);
                  		wait 0.2; 
					}
				}
			}
		}

		wait .05;
	}
}