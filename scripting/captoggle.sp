#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdktools_entinput>

#define PLUGIN_NAME "[TF2] Capture Toggle"
#define PLUGIN_VERSION "0.0.3"
#define PLUGIN_AUTHOR "AW 'Swixel' Stanley"
#define PLUGIN_URL "https://forums.alliedmods.net"
#define PLUGIN_DESCRIPTION "Enables or Disables the Capturing Objectives."

bool g_CapEnabled = true;

Handle g_hArenaAutoDisable;

public Plugin myinfo = 
{
  name = PLUGIN_NAME, 
  author = PLUGIN_AUTHOR, 
  description = PLUGIN_DESCRIPTION, 
  version = PLUGIN_VERSION, 
  url = PLUGIN_URL, 
};

public void OnPluginStart()
{
  CreateConVar("sm_tf_captoggle", PLUGIN_VERSION, PLUGIN_NAME);
  g_hArenaAutoDisable = CreateConVar("sm_cap_auto_arena", "0", "Sets whether or not Arena capture points are automatically disabled on round start");
  
  RegAdminCmd("sm_cap", Command_ToggleObjectives, ADMFLAG_GENERIC, "Enable Objectives");
  
  HookEvent("arena_round_start", Event_ArenaRoundStart, EventHookMode_PostNoCopy);
}

public void Event_ArenaRoundStart(Event event, const char[] name, bool dontBroadcast)
{
  if (g_hArenaAutoDisable)
  {
    ToggleObjectiveState(false);
  }
}

public Action Command_ToggleObjectives(int client, int args)
{
  ToggleObjectiveState(!g_CapEnabled);
  g_CapEnabled = !g_CapEnabled;
  PrintToChatAll("[SM] Objective %s.", g_CapEnabled ? "enabled" : "disabled");
  return Plugin_Handled;
}

void ToggleObjectiveState(bool newState)
{
  char targets[5][32] = { "team_control_point_master", "team_control_point", "trigger_capture_area", "item_teamflag", "func_capturezone" };
  char input[16];
  Format(input, sizeof(input), "%s", newState ? "Enable" : "Disable");
  
  int ent = 0;
  for (int i = 0; i < 5; i++)
  {
    ent = MaxClients + 1;
    while ((ent = FindEntityByClassname(ent, targets[i])) != -1)
    {
      AcceptEntityInput(ent, input);
    }
  }
}