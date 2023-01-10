#include <sourcemod>
#include <cstrike>

ConVar um_rage_quit;
ConVar um_reset_score;

public Plugin:myinfo = 
{ 
	name = "unmatched.gg HvH Public", 
	author = "imi-tat0r", 
	description = "Core functionality for unmatched.gg public servers", 
	version = "1.0"
};

public void OnPluginStart()
{	
	um_rage_quit = CreateConVar("um_rage_quit", "1", "If this cvar is enabled, rage quit is enabled", FCVAR_NOTIFY | FCVAR_REPLICATED);
	um_reset_score = CreateConVar("um_reset_score", "1", "If this cvar is enabled, reset score is enabled", FCVAR_NOTIFY | FCVAR_REPLICATED);

	ServerCommand("mp_backup_round_file \"\"");
	ServerCommand("mp_backup_round_file_last \"\"");
	ServerCommand("mp_backup_round_file_pattern \"\"");
	ServerCommand("mp_backup_round_auto 0");

	RegConsoleCmd("rq", Command_RageQuit);
	RegConsoleCmd("ragequit", Command_RageQuit);
	
	RegConsoleCmd("rs", Command_ResetScore);
	RegConsoleCmd("resetscore", Command_ResetScore);
}

public void OnMapStart()
{
	ServerCommand("mp_backup_round_file \"\"");
	ServerCommand("mp_backup_round_file_last \"\"");
	ServerCommand("mp_backup_round_file_pattern \"\"");
	ServerCommand("mp_backup_round_auto 0");
}

public Action Command_RageQuit(int client, int args) 
{
	// feature disabled
	if (!GetConVarBool(um_rage_quit))
		return Plugin_Handled;
	
	// invalid client
	if (!IsValidClient(client)) 
		return Plugin_Handled;
	
	// get client name
	char name[MAX_NAME_LENGTH];
	GetClientName(client, name, sizeof(name));
	
	// public shame
	PrintToChatAll("[unmatched.\x10gg\x01] \x04%s\x01 just rage quit.", name)
	
	// kick message
	KickClient(client, "Rage quit!");
	return Plugin_Handled;
}

public Action Command_ResetScore(int client, int args)
{
	// feature disabled
	if (!GetConVarBool(um_reset_score))
		return Plugin_Handled;
	
	// invalid client
	if (!IsValidClient(client))
		return Plugin_Handled;

	// get client name
	char name[MAX_NAME_LENGTH];
	GetClientName(client, name, sizeof(name));
	
	// check if already 0
	if(GetClientDeaths(client) == 0 && GetClientFrags(client) == 0 && CS_GetClientAssists(client) == 0 && CS_GetMVPCount(client) == 0)
	{
		PrintToChat(client, "[unmatched.\x10gg\x01] Your score already is 0.")
		return Plugin_Continue;
	}
	
	// reset stats
	SetEntProp(client, Prop_Data, "m_iFrags", 0);
	SetEntProp(client, Prop_Data, "m_iDeaths", 0);
	CS_SetMVPCount(client, 0);
	CS_SetClientAssists(client, 0);
	CS_SetClientContributionScore(client, 0);
	
	// public shame
	PrintToChatAll("[unmatched.\x10gg\x01] Player \x04%s\x01 just reset their score.", name)
	return Plugin_Handled;
}

stock bool IsValidClient(int client)
{
	if(client <= 0 ) return false;
	if(client > MaxClients) return false;
	if(!IsClientConnected(client)) return false;
	return IsClientInGame(client);
}