#include <sourcemod>

ConVar um_restrict_untrusted_angles;
ConVar um_restrict_body_lean;
ConVar um_restrict_extended_angles;
ConVar um_restrict_fake_duck;
ConVar um_matchmaking;

public Plugin:myinfo = 
{ 
	name = "unmatched.gg HvH Essentials", 
	author = "imi-tat0r", 
	description = "Essentials for HvH servers", 
	version = "1.2"
};

public void OnPluginStart()
{
	// setup cvars
	um_restrict_untrusted_angles = CreateConVar("um_restrict_untrusted_angles", "1", "If this cvar is enabled, untrusted angles will be normalized/clamped", FCVAR_NOTIFY | FCVAR_REPLICATED);
	um_restrict_body_lean = CreateConVar("um_restrict_body_lean", "1", "If this cvar is enabled, body lean will be disabled", FCVAR_NOTIFY | FCVAR_REPLICATED);
	um_restrict_extended_angles = CreateConVar("um_restrict_extended_angles", "1", "If this cvar is enabled, extended angles will be disabled", FCVAR_NOTIFY | FCVAR_REPLICATED);
	um_restrict_fake_duck = CreateConVar("um_restrict_fake_duck", "1", "If this cvar is enabled, fake duck will be disabled", FCVAR_NOTIFY | FCVAR_REPLICATED);
	um_matchmaking = CreateConVar("um_matchmaking", "0", "If this cvar is enabled, m_bIsValveDS will be spoofed", 8448, false, 0.0, false, 0.0);
	
	// show ad every 10 minutes
	CreateTimer(600.0, Advertising, _, TIMER_REPEAT);
}

public void OnMapStart()
{
	GameRules_SetProp("m_bIsValveDS", GetConVarBool(um_matchmaking), 4, 0, false);
}

public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon, &subtype, &cmdnum, &tickcount, &seed, mouse[2])
{
	// player is dead, continue
	new bool:alive = IsPlayerAlive(client);
	if(!alive)
		return Plugin_Continue;

	// fake duck fix
	if (GetConVarBool(um_restrict_fake_duck))
	{
		if( buttons & IN_BULLRUSH )
			buttons &= ~IN_BULLRUSH;
	}

	// untrusted angles fix
	if (GetConVarBool(um_restrict_untrusted_angles))
	{
		// pitch clamp
		if (angles[0] > 89.0)
			angles[0] = 89.0;
		else if (angles[0] < -89.0)
			angles[0] = -89.0;

		// yaw clamp
		if (angles[1] > 180.0)
			angles[1] = 180.0;
		if(angles[1] < -180.0)
			angles[1] = -180.0;
		
		// roll clamp
		if (angles[2] > 90.0)
			angles[2] = 90.0;
		else if (angles[2] < -90.0)
			angles[2] = -90.0;
	}
	
	// roll disable
	if (GetConVarBool(um_restrict_body_lean))
	{
		if(angles[2] != 0.0)
			angles[2] = 0.0;
	}

	return Plugin_Changed;
}

// primordial fix - credits: https://github.com/r4klatif/extended-angle-fix
public void OnPlayerRunCmdPost(int client, int buttons, int impulse, const float vel[3], const float angles[3], int weapon, int subtype, int cmdnum, int tickcount, int seed, const int mouse[2])
{
	if (!GetConVarBool(um_restrict_extended_angles))
		return;
	
	float eye_angles[3];
	float v_angle[3];

	GetEntPropVector(client, Prop_Data, "v_angle", v_angle);

	eye_angles[0] = GetEntPropFloat(client, Prop_Send, "m_angEyeAngles[0]");
	eye_angles[1] = GetEntPropFloat(client, Prop_Send, "m_angEyeAngles[1]");
	eye_angles[2] = v_angle[2];

	SetEntPropVector(client, Prop_Data, "v_angle", eye_angles);
}

// advertising running every 10 minutes. Keep this in to comply with the license
public Action:Advertising(Handle timer)
{
	PrintToChatAll("[unmatched.\x10gg\x01] Competitive HvH League")
	PrintToChatAll("[unmatched.\x10gg\x01] Play for \x10free\x01 at unmatched.\x10gg\x01.")
	PrintToChatAll("[unmatched.\x10gg\x01] Get premium for even more content and awesome rewards.")
	
	return Plugin_Continue;
}