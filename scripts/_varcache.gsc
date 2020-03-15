#include scripts\_utils;

init()
{
	// Precache
	level.r_precacheString			= scripts\_utils::randall_precacheString;
	level.r_precacheShader			= scripts\_utils::randall_precacheShader;
	level.r_precacheItem			= scripts\_utils::randall_precacheItem;
	level.r_precacheStatusIcon		= scripts\_utils::randall_precacheStatusIcon;
	level.r_precacheHeadIcon		= scripts\_utils::randall_precacheHeadIcon;
	level.r_precacheMenu			= scripts\_utils::randall_precacheMenu;
	level.r_precacheModel			= scripts\_utils::randall_precacheModel;
	level.r_precacheFX				= scripts\_utils::randall_precacheFX;
	level.r_precacheShock			= scripts\_utils::randall_precacheShellShock;

	game["bz_sprint"]					= cvarDef( "int",	"bz_sprint", 1, 0, 1 );
	game["bz_sprint_time"]				= cvarDef( "int",	"bz_sprint_time", 5, 1, 1000 );
	game["bz_sprint_recovertime"]		= cvarDef( "int",	"bz_sprint_recovertime", 10, 1, 1000 );

	game["show_AIhealth"]				= cvarDef( "int",	"bz_show_aihealth", 1, 0, 1 );
	game["bz_healthbar"]				= cvarDef( "int",	"bz_show_healthbar", 1, 0, 1 );
}