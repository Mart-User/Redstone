#include <sourcemod>
#include <sdktools>
#include <nd_gskill>
#include <nd_stats>
#include <nd_stocks>
#include <nd_rounds>
#include <nd_redstone>
#include <nd_com_eng>
#include <nd_aweight>
//#include <nd_entities>
#include <smlib/math>

#define _DEBUG 0

#define CONSORT_aIDX 0
#define EMPIRE_aIDX 1

float GameME_PlayerSkill[MAXPLAYERS+1] = {-1.0,...};
float GameME_CommanderSkill[MAXPLAYERS+1] = {-1.0,...};

float lastAverage = 0.0;
float lastMedian = 0.0;

/* These two things much be accessible ealier than spm logic */
bool g_isSkilledRookie[MAXPLAYERS+1] = {false, ...};
bool g_isWeakVeteran[MAXPLAYERS+1] = {false, ...};

enum Bools
{
	bool tdChange;
	bool adjustedRookie;
}
Bools g_Bool;

/* Include various plugin modules */
#include "nd_ply_skill/convars.sp"
#include "nd_ply_skill/ply_level.sp"
#include "nd_ply_skill/prediction.sp"
#include "nd_ply_skill/spm_logic.sp"
#include "nd_ply_skill/skill_calc.sp"
#include "nd_ply_skill/extras.sp"
#include "nd_ply_skill/natives.sp"

/* Include test commands */
#include "nd_ply_skill/commands.sp"

public Plugin myinfo =
{
	name = "[ND] Player Skill Management",
	author = "Stickz",
	description = "Finalizes a player's skill level",
	version = "dummy",
	url = "https://github.com/stickz/Redstone"
};

/* Auto-Updater Support */
#define UPDATE_URL  "https://github.com/stickz/Redstone/raw/build/updater/nd_player_skill/nd_player_skill.txt"
#include "updater/standard.sp"

public void OnPluginStart()
{
	CreatePluginConvars();
	RegisterCommands();
	
	AddUpdaterLibrary(); //auto-updater
	
	if (ND_MapStarted())
		ReloadGameMeSkill();
	
	if (ND_RoundStarted())
		startSPMTimer();
}

public void GameME_OnSkillCalculated(int client, float base, float skill) {
	GameME_PlayerSkill[client] = skill;	
	GameME_CommanderSkill[client] = base;
}

public void ND_OnRoundStarted() {
	startSPMTimer();	
}

public void ND_OnRoundEndedEX() 
{
	// If the round ended & started this map, reset the client varriables
	for (int client = 1; client <= MaxClients; client++)
		resetVarriables(client, false);
	
	// If the round ended & started this map, stop the SPM logic timer
	if (hTimerSPM != INVALID_HANDLE && IsValidHandle(hTimerSPM))
	{
		KillTimer(hTimerSPM);
		hTimerSPM = INVALID_HANDLE;
	}
}

public void OnClientConnected(int client) {
	resetVarriables(client);
}

public void OnClientDisconnect(int client) {
	resetVarriables(client);
}

void resetVarriables(int client, bool skill = true)
{
	g_isSkilledRookie[client] = false;
	g_isWeakVeteran[client] = false;
	connectionTime[client] = -1;
	scorePerMinute[client] = -1;
	previousTeam[client] = -1;
	newPlayerSkill[client] = -1.0;
	
	if (skill)
	{
		LevelCacheArray[client] = -1;
		GameME_PlayerSkill[client] = -1.0;
		GameME_CommanderSkill[client] = -1.0;
	}
}

void ReloadGameMeSkill()
{
	if (!GM_GFS_LOADED() || !GM_GSB_LOADED())
		return;
	
	RED_LOOP_CLIENTS(client) {
		GameME_PlayerSkill[client] = GameME_GetFinalSkill(client);	
		GameME_CommanderSkill[client] = GameME_GetSkillBase(client);
	}
}