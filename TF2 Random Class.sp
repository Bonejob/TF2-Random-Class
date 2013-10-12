#pragma semicolon 1;

#include <sourcemod>
#include <tf2>
#include <tf2_stocks>

#define PLUGIN_VERSION "0.0.1"

public Plugin:myinfo =
{
	name = "TF2 Random Class Every Death",
	author = "Nahoom",
	description = "Randomizes class every time a player dies",
	version = PLUGIN_VERSION,
};

new Handle:hRandom = INVALID_HANDLE;

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	new String:Game[32];
	GetGameFolderName(Game, sizeof(Game));
	if(!StrEqual(Game, "tf"))
	{
		Format(error, err_max, "This plugin only works for Team Fortress 2");
		return APLRes_Failure;
	}
	return APLRes_Success;
}

public OnPluginStart()
{
  LoadTranslations("common.phrases");
  RegAdminCmd("sm_random_timed",Command_random_timed,ADMFLAG_ROOT,"Toggles timed randomization");
  CreateConVar("sm_random_version", PLUGIN_VERSION, "Random classes on death", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
  hRandom = CreateConVar("sm_random", "1", "Enable/Disable(1/0) Randomize classes on death", FCVAR_PLUGIN|FCVAR_NOTIFY);
  HookEvent("player_spawn", Event_PlayerSpawn);
}

public Event_PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (GetConVarBool(hRandom)){
    new user = GetClientOfUserId(GetEventInt(event, "userid"));
    new TFClassType:class;
    class = TFClassType:GetRandomInt(1, 9);
    TF2_SetPlayerClass(user, class);
    SetEntityHealth(user, 25);
    TF2_RegeneratePlayer(user);
    SetEntPropEnt(user, Prop_Send, "m_hActiveWeapon", GetPlayerWeaponSlot(user, TFWeaponSlot_Primary));
	}
}

public Action:Command_random_timed(client, args)
{
  for (new i=1; i<=MaxClients; i++)
  {
    if (!IsClientConnected(i))
    {
      continue;
    }
    new user = GetClientOfUserId(GetClientUserId(i));
    new TFClassType:class;
    class = TFClassType:GetRandomInt(1,9);
    TF2_SetPlayerClass(user, class);
    SetEntityHealth(user, 25);
    TF2_RegeneratePlayer(user);
    SetEntPropEnt(user, Prop_Send, "m_hActiveWeapon", GetPlayerWeaponSlot(user, TFWeaponSlot_Primary));
  }
  return Plugin_Handled;
}
