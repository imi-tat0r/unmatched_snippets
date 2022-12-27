#include <sourcemod>
#include <sdkhooks>
#include <sdktools>

public Plugin myinfo =
{
	name = "unmatched.gg Friendly Fire settings",
	author = "imi-tat0r",
	description = "Manage the damage of friendly fire.",
	version = "1.2",
};

ConVar um_friendlyfire_utility;
ConVar um_friendlyfire_weapon;

public void OnPluginStart()
{
	um_friendlyfire_utility = CreateConVar("um_friendlyfire_utility", "1", "If this cvar is enabled, friendly utility will deal damage", FCVAR_NOTIFY | FCVAR_REPLICATED);
	um_friendlyfire_weapon = CreateConVar("um_friendlyfire_weapon", "1", "If this cvar is enabled, friendly fire will deal damage", FCVAR_NOTIFY | FCVAR_REPLICATED);

	for (int i = 1; i <= MaxClients; i++)
		if (IsClientInGame(i))
			OnClientPutInServer(i);
}

public void OnConfigsExecuted()
{
	SetConVar("ff_damage_reduction_grenade", "1");
	SetConVar("ff_damage_reduction_grenade_self", "1");
	SetConVar("ff_damage_reduction_other", "1");
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_TraceAttack, SDK_OnTraceAttack);
	SDKHook(client, SDKHook_OnTakeDamage, SDK_OnTakeDamage);
}

public Action SDK_OnTraceAttack(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &ammotype, int hitbox, int hitgroup)
{
	if (!IsClientInGame(victim) ||
		!IsEntityClient(attacker) ||
		!IsClientInGame(attacker) ||
		GetClientTeam(attacker) != GetClientTeam(victim))
		return Plugin_Continue;
	
	if (!GetConVarBool(um_friendlyfire_weapon) &&
		(view_as<bool>(damagetype & DMG_BULLET) ||
		view_as<bool>(damagetype & DMG_SLASH) ||
		view_as<bool>(damagetype & DMG_SHOCK))) {
		damage = 0.0;
		return Plugin_Changed;
	}
	
	if (!GetConVarBool(um_friendlyfire_utility) &&
		(view_as<bool>(damagetype & DMG_BURN) ||
		view_as<bool>(damagetype & DMG_BLAST))) {
		damage = 0.0;
		return Plugin_Changed;
	}
	
	return Plugin_Continue;
}

public Action SDK_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3])
{
	if (!IsClientInGame(victim) ||
	!IsEntityClient(attacker) ||
	!IsClientInGame(attacker) ||
	IsEntityClient(inflictor) ||
	GetClientTeam(attacker) != GetClientTeam(victim) ||
	GetConVarBool(um_friendlyfire_utility))
		return Plugin_Continue;
	
	
	char classname[256];
	GetEntityClassname(inflictor, classname, sizeof(classname));
	
	if (StrEqual(classname, "inferno", true))
	{
		if (attacker != victim)
		{
			damage = 0.0;
			return Plugin_Changed;
		}
	}
	
	return Plugin_Continue;
}

void SetConVar(const char[] cvarName, const char[] value)
{
	ConVar cvar = FindConVar(cvarName);
	if (cvar)
		cvar.SetString(value);
}

bool IsEntityClient(int client)
{
	return (client > 0 && client <= MaxClients);
}