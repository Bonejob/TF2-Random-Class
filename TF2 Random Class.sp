#pragma semicolon 1;

#include <sourcemod>
#include <tf2>
#include <tf2_stocks>

#define PLUGIN_VERSION "0.0.3"

public Plugin:myinfo =
{
	name = "TF2 Random Class Every Death",
	author = "Nahoom",
	description = "Randomizes class every time a player dies",
	version = PLUGIN_VERSION,
};

new Handle:hRandom = INVALID_HANDLE;
new Handle:sm_random_timed_enabled;
new Handle:sm_random_timed_time;
new Handle:time_handle;
new Float:timez;

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
  RegAdminCmd("sm_random_force_all",Command_random_force_all,ADMFLAG_ROOT,"Force randomization for all clients");
  sm_random_timed_enabled = CreateConVar("sm_random_timed_enabled", "1", "Enable timed randomization \n1=Enabled\n0=Disabled", FCVAR_NONE, true, 0.0, true, 1.0);
  sm_random_timed_time = CreateConVar("sm_random_time", "10", "Time increment to randomize classes");
  timez = GetConVarFloat(sm_random_timed_time);
  HookConVarChange(sm_random_timed_time, timeCVarChanged);
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

public Action:Command_random_force_all(client, args)
{
  for (new i=1; i<=MaxClients; i++)
  {
    if (!IsClientConnected(i))
    {
      continue;
    }
    if (!IsClientInGame(i))
    {
      continue;
    }
    new user = GetClientOfUserId(GetClientUserId(i));
    new TFClassType:class;
    class = TFClassType:GetRandomInt(1,9);
    TF2_RemoveCondition(user, TFCond:TFCond_Zoomed);
    TF2_SetPlayerClass(user, class);
    SetEntityHealth(user, 25);
    TF2_RegeneratePlayer(user);
    SetEntPropEnt(user, Prop_Send, "m_hActiveWeapon", GetPlayerWeaponSlot(user, TFWeaponSlot_Primary));
  }
  return Plugin_Handled;
}

stock ClearTimer(&Handle:timer)
{
  if (timer != INVALID_HANDLE)
  {
    KillTimer(timer);
    timer = INVALID_HANDLE;
  }
}

public OnMapStart()
{
  time_handle = CreateTimer(timez, execute, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

public OnMapEnd()
{
  KillTimer(time_handle);
}

public Action:execute(Handle:timer)
{
  if(GetConVarInt(sm_random_timed_enabled) == 1)
  {
    Command_random_force_all(1,1);
  }
}

public timeCVarChanged(Handle:cvar, const String:oldVal[], const String:newVal[])
{
  timez = GetConVarFloat(cvar);
  KillTimer(time_handle);
  {
    time_handle = CreateTimer(timez, execute, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
  }
}
