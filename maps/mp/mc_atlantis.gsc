main()
{
	maps\mp\_load::main();

	setExpFog(0.0005, 0, 0.55, 0.76, 5);

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
		[[level.addobj]](0);
		[[level.addobj]](1);
		[[level.addobj]](2);
		[[level.addobj]](3);
	}

	level.skyorigin = (-236, -580, 1841);
	level.skyradius = 3000;
}