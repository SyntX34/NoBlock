#include <sourcemod>
#include <sdktools>
#include <morecolors>

#pragma newdecls required

#define PLUGIN_VERSION "1.00"

public Plugin myinfo =
{
    name = "NoBlock",
    author = "+SyntX",
    description = "Removes player collision entirely, allowing movement through each other at all times.",
    version = PLUGIN_VERSION,
    url = "https://steamcommunity.com/id/SyntX34"
};

int g_CollisionOffset;
ConVar sm_zstuck_enabled;

public void OnPluginStart()
{
    g_CollisionOffset = FindSendPropInfo("CBaseEntity", "m_CollisionGroup");
    PrintToServer("[ZStuck] Collision Group Offset: %d", g_CollisionOffset);

    if (g_CollisionOffset == -1)
    {
        SetFailState("ERROR: m_CollisionGroup not found! Plugin will not run.");
    }
    sm_zstuck_enabled = CreateConVar("sm_zstuck_enabled", "1", "Enable (1) or Disable (0) NoBlock globally.");
    
    AutoExecConfig(true, "sm_zstuck");
    
    HookEvent("player_spawn", Event_PlayerSpawn);
}

public Action Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    if (GetConVarInt(sm_zstuck_enabled) == 1)
    {
        int client = GetClientOfUserId(GetEventInt(event, "userid"));
        if (client && IsClientInGame(client))
        {
            EnableNoBlock(client);
        }
    }
    return Plugin_Continue;
}

public void OnConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
    if (convar == sm_zstuck_enabled)
    {
        bool enabled = GetConVarBool(sm_zstuck_enabled);
        
        for (int i = 1; i <= MaxClients; i++)
        {
            if (IsClientInGame(i))
            {
                if (enabled)
                {
                    EnableNoBlock(i);
                }
                else
                {
                    EnableBlock(i);
                }
            }
        }
    }
}

void EnableNoBlock(int client)
{
    if (g_CollisionOffset == -1) return;
    SetEntData(client, g_CollisionOffset, 2, 4, true);
}

void EnableBlock(int client)
{
    if (g_CollisionOffset == -1) return;
    SetEntData(client, g_CollisionOffset, 5, 4, true);
}
