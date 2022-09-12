#include <autoexecconfig>
/* The convar mess starts here! */

/* Enumerated values for accessing ConVar arrays */
enum multREDs:
{
	red_bunker_mult = 0,
	red_assembler_mult,
	red_transport_mult,
	red_artillery_mult,
	red_ft_turret_mult,
	red_wall_mult,
	red_barrier_mult,
	red_supply_mult,
	red_ib1_base_mult,
	red_ib2_base_mult,
	red_ib3_base_mult,
	multREDsSize
}
enum multBullets:
{
	bullet_bunker_mult = 0,
	bullet_assembler_mult,
	bullet_transport_mult,
	bullet_artillery_mult,
	bullet_ft_turret_mult,
	bullet_power_plant_mult,
	bullet_armoury_mult,
	bullet_radar_mult,
	bullet_mg_turret_mult,
	bullet_rocket_turret_mult,
	bullet_supply_station_mult,
	multBulletsSize
}
enum multSiege:
{
	// Siegers (m95 & x01)
	siege_ib0_base_mult = 0,
	siege_ib1_base_mult,
	siege_ib2_base_mult,
	siege_ib3_base_mult,
	multSiegeSize
}

enum multGL:
{
	gl_bunker_mult = 0,
	gl_assembler_mult,
	gl_transport_mult,
	gl_ft_turret_mult,
	gl_ib1_base_mult,
	gl_ib2_base_mult,
	gl_ib3_base_mult,
	multGLSize
}

enum multOther:
{
	nx300_ib1_base_mult = 0,
	nx300_ib2_base_mult,
	nx300_ib3_base_mult,
	nx300_bunker_mult,
	artillery_ib1_base_mult,
	artillery_ib2_base_mult,
	artillery_ib3_base_mult,
	multOtherSize
}

/* ConVar and float arrays for the different types */
ConVar gCvar_Red[multREDsSize];
ConVar gCvar_Bullet[multBulletsSize];
ConVar gCvar_Siege[multSiegeSize];
ConVar gCvar_GL[multGLSize];
ConVar gCvar_Other[multOtherSize];
ConVar cvarNoWarmupBunkerDamage;

ConVar gCvarMinThresholdX01;
ConVar gCvarMinIncreaseX01;
ConVar gCvarMinWallDamageX01;

float gFloat_Red[multREDsSize];
float gFloat_Bullet[multBulletsSize];
float gFloat_Siege[multSiegeSize];
float gFloat_GL[multGLSize];
float gFloat_Other[multOtherSize];

int iMinThresholdX01;
float fMinWallDamageX01;
float fMinIncreaseX01;

/* Functions for creating covnars */
void CreatePluginConVars()
{
	// Tell the wrapper to create the files. Required for multiples.
	AutoExecConfig_SetCreateFile(true);
	
	CreateRedConVars();
	CreateBulletConVars();
	CreateSiegeConVars();
	CreateGLConVars();
	CreateOtherConVars();
	
	AutoExecConfig_SetFile("nd_mult");	
	cvarNoWarmupBunkerDamage	= AutoExecConfig_CreateConVar("sm_warmup_protect_bunker", "1", "Disable bunker damage during the warmup round.");
	gCvarMinThresholdX01		= AutoExecConfig_CreateConVar("sm_mult_x01_threshold", "25", "Sets amount to multiply x01 damage by a percentage.");
	gCvarMinIncreaseX01			= AutoExecConfig_CreateConVar("sm_mult_x01_damage", "150", "Sets percentage to multiply x01 damage by when threshold reached.");
	gCvarMinWallDamageX01		= AutoExecConfig_CreateConVar("sm_mult_x01_wall", "35", "Sets the min damage the x01 must deal to a wall.");
	AutoExecConfig_EC_File();
}

void CreateRedConVars()
{
	AutoExecConfig_SetFile("nd_mult_reds");
	
	char convarName[multREDsSize][] = {
		// RED Structure Damage
		"sm_mult_bunker_red",
		"sm_mult_assembler_red",
		"sm_mult_transport_red",
		"sm_mult_artillery_red",
		"sm_mult_ft_turret_red",
		"sm_mult_wall_red",
		"sm_mult_barrier_red",
		"sm_mult_supply_red",
		
		// RED Base Damage		
		"sm_mult_baseIB1_red",
		"sm_mult_baseIB2_red",
		"sm_mult_baseIB3_red"	
	};
	
	char convarDesc[multREDsSize][] = {
		// RED Structure Damage
		"Percentage of normal damage REDs deal to the bunker",
		"Percentage of normal damage REDs deal to assemblers",
		"Percentage of normal damage REDs deal to transport gates",
		"Percentage of normal damage REDs deal to artillery",
		"Percentage of normal damage REDs deal to ft/sonic turrets",
		"Percentage of normal damage REDs deal to walls",
		"Percentage of normal damage REDs deal to barriers",
		"Percentage of normal damage REDs deal to supply stations",
		
		// RED Base Damage
		"Percentage of normal damage REDs deal after Infantry Boost 1",
		"Percentage of normal damage REDs deal after Infantry Boost 2",
		"Percentage of normal damage REDs deal after Infantry Boost 3"
	};
	
	char convarDef[multREDsSize][] = { 
		// RED Structure Damage
		"130", "110", "130", "110", "125", "130", "115", "105",
		
		// RED Base Damage
		"103", "108", "115"	
	};
	
	for (int convar = 0; convar < view_as<int>(multREDsSize); convar++) {
		gCvar_Red[convar] = AutoExecConfig_CreateConVar(convarName[convar], convarDef[convar], convarDesc[convar]);	
	}
	
	AutoExecConfig_EC_File();
}
void CreateBulletConVars()
{
	AutoExecConfig_SetFile("nd_mult_bullet");
	
	char convarName[multBulletsSize][] = {	
		"sm_mult_bunker_bullet",
		"sm_mult_assembler_bullet",
		"sm_mult_transport_bullet",
		"sm_mult_artillery_bullet",
		"sm_mult_ft_turret_bullet",
		"sm_mult_power_plant_bullet",
		"sm_mult_armoury_bullet",
		"sm_mult_radar_bullet",
		"sm_mult_mg_turret_bullet",
		"sm_mult_rocket_turret_bullet",
		"sm_mult_supply_station_bullet"
	};
	
	char convarDef[multBulletsSize][] = { "150", "140", "135", "95", "115", "125", "115", "100", "115", "100", "75" };
	
	char convarDesc[multBulletsSize][] = {
		"Percentage of normal damage bullets deal to the bunker",
		"Percentage of normal damage bullets deal to assemblers",
		"Percentage of normal damage bullets deal to transport gates",
		"Percentage of normal damage bullets deal to artillery",
		"Percentage of normal damage bullets deal to ft/sonic turrets",
		"Percentage of normal damage bullets deal to power plants",
		"Percentage of normal damage bullets deal to armouries",
		"Percentage of normal damage bullets deal to radars",
		"Percentage of normal damage bullets deal to mg turrets",
		"Percentage of normal damage bullets deal to rocket turrets",
		"Percentage of normal damage bullets deal to supply stations"
	};
	
	for (int convar = 0; convar < view_as<int>(multBulletsSize); convar++) {
		gCvar_Bullet[convar] = AutoExecConfig_CreateConVar(convarName[convar], convarDef[convar], convarDesc[convar]);	
	}
	
	AutoExecConfig_EC_File();	
}

void CreateSiegeConVars()
{
	AutoExecConfig_SetFile("nd_mult_siege");
	
	// Siegers (m95 & x01)
	char convarName[multSiegeSize][] = {	
		// Siege Base Damage
		"sm_mult_baseIB0_siege",
		"sm_mult_baseIB1_siege",
		"sm_mult_baseIB2_siege",
		"sm_mult_baseIB3_siege"
	};
	char convarDesc[multSiegeSize][] = {
		// Siege Base Damage
		"Percentage of normal damage Siegers deal at Infantry Boost 0",
		"Percentage of normal damage Siegers deal after Infantry Boost 1",
		"Percentage of normal damage Siegers deal after Infantry Boost 2",
		"Percentage of normal damage Siegers deal after Infantry Boost 3"
	};	
	char convarDef[multSiegeSize][] = { 
		// Siege Base Damage
		"95", "100", "105", "110"
	};	

	for (int convar = 0; convar < view_as<int>(multSiegeSize); convar++) {
		gCvar_Siege[convar] = AutoExecConfig_CreateConVar(convarName[convar], convarDef[convar], convarDesc[convar]);	
	}
	
	AutoExecConfig_EC_File();
}

void CreateGLConVars()
{
	AutoExecConfig_SetFile("nd_mult_gl");
	
	// GLs (Grenade Launchers)
	char convarName[multGLSize][] = {		
		// GL Structure Damage
		"sm_mult_bunker_gl",
		"sm_mult_assembler_gl",
		"sm_mult_transport_gl",
		"sm_mult_ft_turret_gl",
		
		// GL Base Damage
		"sm_mult_baseIB1_gl",
		"sm_mult_baseIB2_gl",
		"sm_mult_baseIB3_gl"
	};
	char convarDesc[multGLSize][] = {		
		// GL Structure Damage
		"Percentage of normal damage GLs deal to the bunker",
		"Percentage of normal damage GLs deal to assemblers",
		"Percentage of normal damage GLs deal to transport gates",
		"Percentage of normal damage GLs deal to ft/sonic turrets",
		
		// GL Base Damage
		"Percentage of normal damage GLs deal to after Infantry Boost 1",
		"Percentage of normal damage GLs deal to after Infantry Boost 2",
		"Percentage of normal damage GLs deal to after Infantry Boost 3"
	};
	char convarDef[multGLSize][] = { 	"120", "110", "125", "110",
					"103", "106", "109" };
	
	for (int convar = 0; convar < view_as<int>(multGLSize); convar++) {
		gCvar_GL[convar] = AutoExecConfig_CreateConVar(convarName[convar], convarDef[convar], convarDesc[convar]);	
	}
	
	AutoExecConfig_EC_File();
}

void CreateOtherConVars()
{
	AutoExecConfig_SetFile("nd_mult_other");
	
	char convarName[multOtherSize][] = {	
		"sm_mult_baseIB1_nx300",
		"sm_mult_baseIB2_nx300",
		"sm_mult_baseIB3_nx300",
		"sm_mult_bunker_nx300",
		"sm_mult_baseSR1_artillery",
		"sm_mult_baseSR2_artillery",
		"sm_mult_baseSR3_artillery"
	};
	char convarDesc[multOtherSize][] = {
		"Percentage of normal damage nx300 does after IB1",
		"Percentage of normal damage nx300 does after IB2",
		"Percentage of normal damage nx300 does after IB3",
		"Percentage of normal damage nx300 does to bunker",
		"Percentage of normal damage artillery does after SR1",
		"Percentage of normal damage artillery does after SR2",
		"Percentage of normal damage artillery does after SR13",
	};	
	char convarDef[multOtherSize][] = { 
		// nx300 ib 1-3 base damage
		"103", "105", "107", 
		"85", // nx300 bunker damage
		// artillery sr 1-3 base damage
		"95", "90", "85"
	};		
	
	for (int convar = 0; convar < view_as<int>(multOtherSize); convar++) {
		gCvar_Other[convar] = AutoExecConfig_CreateConVar(convarName[convar], convarDef[convar], convarDesc[convar]);	
	}
	
	AutoExecConfig_EC_File();	
}

/* Manage when ConVars change mid-game */
void UpdateConVarCache()
{
	for (int r = 0; r < view_as<int>(multREDsSize); r++) {
		gFloat_Red[r] = gCvar_Red[r].FloatValue / 100.0;
	}
	
	for (int b = 0; b < view_as<int>(multBulletsSize); b++) {
		gFloat_Bullet[b] = gCvar_Bullet[b].FloatValue / 100.0;
	}
	
	for (int s = 0; s < view_as<int>(multSiegeSize); s++) {
		gFloat_Siege[s] = gCvar_Siege[s].FloatValue / 100.0;
	}
	
	for (int g = 0; g < view_as<int>(multGLSize); g++) {
		gFloat_GL[g] = gCvar_GL[g].FloatValue / 100.0;
	}
	
	for (int o = 0; o < view_as<int>(multOtherSize); o++) {
		gFloat_Other[o] = gCvar_Other[o].FloatValue / 100.0;
	}
	
	iMinThresholdX01 = gCvarMinThresholdX01.IntValue;
	fMinIncreaseX01 = gCvarMinIncreaseX01.FloatValue / 100.0;
	fMinWallDamageX01 = gCvarMinWallDamageX01.FloatValue;
}
void HookConVarChanges()
{
	for (int r = 0; r < view_as<int>(multREDsSize); r++) {
		HookConVarChange(gCvar_Red[r], OnConfigPercentChange);
	}
	
	for (int b = 0; b < view_as<int>(multBulletsSize); b++) {
		HookConVarChange(gCvar_Bullet[b], OnConfigPercentChange);
	}
	
	for (int s = 0; s < view_as<int>(multSiegeSize); s++) {
		HookConVarChange(gCvar_Siege[s], OnConfigPercentChange);
	}
	
	for (int g = 0; g < view_as<int>(multGLSize); g++) {
		HookConVarChange(gCvar_GL[g], OnConfigPercentChange);
	}
	
	for (int o = 0; o < view_as<int>(multOtherSize); o++) {
		HookConVarChange(gCvar_Other[o], OnConfigPercentChange);
	}
	
	HookConVarChange(gCvarMinThresholdX01, OnConfigPercentChange);
	HookConVarChange(gCvarMinIncreaseX01, OnConfigPercentChange);
	HookConVarChange(gCvarMinWallDamageX01, OnConfigPercentChange);
}
public void OnConfigPercentChange(ConVar convar, char[] oldValue, char[] newValue) {	
	UpdateConVarCache();
}
