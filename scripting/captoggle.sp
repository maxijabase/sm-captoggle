#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdktools_entinput>
#include <tf2>
#include <tf2_stocks>

#define PLUGIN_NAME "[TF2] Capture Toggle"
#define PLUGIN_VERSION "1.1"
#define PLUGIN_AUTHOR "AW 'Swixel' Stanley"
#define PLUGIN_URL "https://forums.alliedmods.net"
#define PLUGIN_DESCRIPTION "Enables or Disables the Capturing Objectives."

bool g_CapEnabled;
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
    
    // Default to enabled state initially
    g_CapEnabled = true;
    
    // If there are any flags already disabled, set our state to disabled
    int ent = -1;
    while((ent = FindEntityByClassname(ent, "item_teamflag")) != INVALID_ENT_REFERENCE)
    {
        char targetname[64];
        GetEntPropString(ent, Prop_Data, "m_iName", targetname, sizeof(targetname));
        
        // Try to enable the flag - if it's already enabled, this won't change anything
        AcceptEntityInput(ent, "Enable");
        
        // Now try to get the flag - if we can't, it means it's disabled
        if (!IsValidEntity(ent) || !IsValidEdict(ent))
        {
            g_CapEnabled = false;
            break;
        }
    }
}

public void Event_ArenaRoundStart(Event event, const char[] name, bool dontBroadcast)
{
    if (GetConVarBool(g_hArenaAutoDisable))
    {
        ToggleObjectiveState(false);
        g_CapEnabled = false;
    }
}

public Action Command_ToggleObjectives(int client, int args)
{
    g_CapEnabled = !g_CapEnabled;
    ToggleObjectiveState(g_CapEnabled);
    PrintToChatAll("[SM] Objective %s.", g_CapEnabled ? "enabled" : "disabled");
    return Plugin_Handled;
}

void ToggleObjectiveState(bool newState)
{
    int ent = -1;
    while((ent = FindEntityByClassname(ent, "item_teamflag")) != INVALID_ENT_REFERENCE)
    {
        if (!newState)
        {
            AcceptEntityInput(ent, "ForceDrop");
            AcceptEntityInput(ent, "ForceReset");
            AcceptEntityInput(ent, "Disable");
        }
        else
        {
            AcceptEntityInput(ent, "Enable");
        }
    }
}