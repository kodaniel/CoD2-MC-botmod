main()
{
	maps\mp\_load::main();

	setExpFog(0.0001, 0.65, 0.55, 0.6, 0);

	game["allies"] = "american";
	game["axis"] = "german";
	game["attackers"] = "allies";
	game["defenders"] = "axis";
	game["russian_soldiertype"] = "normandy";
	game["german_soldiertype"] = "normandy";

	setCvar("r_glowbloomintensity0", ".25");
	setCvar("r_glowbloomintensity1", ".25");
	setcvar("r_glowskybleedintensity0",".3");

	level.skyorigin = (560, -640, 2000);
	level.skyradius = 2500;

    thread mill();
}

mill()
{
	windmill = getEnt("windmill", "targetname");
	speed = 20;
	
	for (;;)
	{
		windmill rotatePitch(360, speed);
		wait speed * 0.5;
	}
}