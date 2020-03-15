init()
{
	[[level.r_precacheShader]]("hud_rounds_bg");

	level thread updateRoundStats();
}

updateRoundStats()
{
	level.hud_roundsback = newHudElem();
	level.hud_roundsback.horzAlign = "left";
	level.hud_roundsback.vertAlign = "top";
	level.hud_roundsback.x = 10;
	level.hud_roundsback.y = 10;
	level.hud_roundsback.alpha = 1;
	level.hud_roundsback setShader("hud_rounds_bg", 64, 64);

	level.hud_rounds = newHudElem();
	level.hud_rounds.horzAlign = "left";
	level.hud_rounds.vertAlign = "top";
	level.hud_rounds.alignx = "center";
	level.hud_rounds.aligny = "middle";
	level.hud_rounds.x = 42;
	level.hud_rounds.y = 39;
	level.hud_rounds.fontscale = 2.5;
	level.hud_rounds.color = (1,1,1);
	level.hud_rounds.alpha = 1;
	level.hud_rounds.sort = 10;

	for (;;)
	{
		level.hud_rounds fadeOverTime(0.5);
		level.hud_rounds.alpha = 0;
		wait 0.5;

		if (isDefined(level.roundslimit))
			level.hud_rounds setValue(level.roundslimit - game["roundsplayed"]);
		else
			level.hud_rounds setValue(game["roundsplayed"]);

		level.hud_rounds fadeOverTime(0.5);
		level.hud_rounds.alpha = 1;
		wait 0.5;

		level waittill("round_ended");
	}
}