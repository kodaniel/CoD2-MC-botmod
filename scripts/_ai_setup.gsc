init()
{
	Settings();
}

Settings()
{
	level.workAI = false;

	level.offset = (0,0,2);
	level.offset2 = (0,0,32);

	if ( ! scripts\_buildupmap::buildWaypoints() )
	{
		iPrintln("^1ERROR: Couldn't build waypoints.");
		return;
	}

	if ( ! scripts\_buildupmap::buildPaths() )
	{
		iPrintln("^1ERROR: Couldn't build paths.");
		return;
	}

	// Setting up the bots
	scripts\_buildupmap::buildEdges();
	scripts\_buildupmap::buildHitbox();

	scripts\_animtree::init();
	scripts\_aitypes::init();
	scripts\_ai::init();

	level.workAI = true;
}