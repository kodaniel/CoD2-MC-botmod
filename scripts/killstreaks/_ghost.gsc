#include scripts\_utils;

init()
{
    level.ghosttime = 20;
}

IsAllowed()
{
    return true;
}

RunOnUse()
{
    // player currently using the ghost killstreak
    if (is_in_array(self.invisibilities, "ghost"))
		return false;

    self thread doGhost();

	return true;
}

doGhost()
{
    self endon("disconnect");

    self thread scripts\player\_hud::AddTimer(level.ghosttime, (.8, .8, .8));
    self thread timer("end_ghost", level.ghosttime);

    self.invisibilities = add_to_array(self.invisibilities, "ghost", false);
	self waittill_any("killed_player", "end_ghost");
	self.invisibilities = array_remove(self.invisibilities, "ghost");
}