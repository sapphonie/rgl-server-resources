#pragma semicolon 1
#include <sourcemod>
#include <updater>
#include <morecolors>

#define REQUIRE_EXTENSIONS
#include <SteamWorks>

#define PLUGIN_NAME         "RGL.gg Server Resources Updater"
#define PLUGIN_VERSION      "1.1.2"
#define UPDATE_URL          "https://stephanielgbt.github.io/rgl-server-resources/updatefile.txt"

new bool:gameIsLive;                // yes this is the same variable name from tf2Halftime
new bool:CfgExecuted;
new antiTroll;
new formatVal;
new slotVal;

ConVar g_Cvar_rglCast;

public Plugin:myinfo =
{
    name        =  PLUGIN_NAME,
    author      = "Aad, Stephanie",
    description = "Automatically updates RGL.gg plugins and files",
    version     =  PLUGIN_VERSION,
    url         = "https://github.com/stephanieLGBT/rgl-server-resources"
};

public OnPluginStart()
{
    CPrintToChatAll("{lightsalmon}[RGLUpdater]{white} has been {green}loaded{default}.");
    if (LibraryExists("updater"))                                               // this is the actual "updater" part of this plugin
    {
        Updater_AddPlugin(UPDATE_URL);
    }
    HookEvent("teamplay_round_start", EventRoundStart);                         // hooks round start events
    HookEvent("player_disconnect", EventPlayerLeft);                            // hooks player fully disconnected events
    HookEvent("teamplay_round_win", EventRoundEnd);                             // hooks round win events for determining auto restart
    CreateConVar                                                                // creates cvar for the antitrolling stuff
        (
        "rgl_cast",
        "0.0",
        "controls antitroll function of rglupdater",
        FCVAR_NOTIFY,                                                           // notify clients of cvar change
        true,
        0.0,
        true,
        1.0
        );
    g_Cvar_rglCast = FindConVar("rgl_cast");
    g_Cvar_rglCast.AddChangeHook(OnConVarChanged);
}

public Action EventRoundStart(Handle event, const char[] name, bool dontBroadcast)
{
    CPrintToChatAll("{lightsalmon}[RGLUpdater]{white} This server is running RGL Updater version {lightsalmon}%s{default}", PLUGIN_VERSION);
    autoStuff();
}

public void OnClientPostAdminCheck(client)
{
    PrintToChat(client, "[RGLUpdater] This server is running RGL Updater version %s", PLUGIN_VERSION);
}

public void EventRoundEnd(Event event, const char[] name, bool dontBroadcast)   // hook the round end event for making sure that a game has occured before restarting the server
{
    gameIsLive = true;                                                          // sets gamelive bool to true
}

public OnLibraryAdded(const String:name[])
{
    if (StrEqual(name, "updater"))
    {
        Updater_AddPlugin(UPDATE_URL);                                          // does updater stuff as well
    }
}

public Action EventPlayerLeft(Handle event, const char[] name, bool dontBroadcast)
{
    LogMessage("[RGLUpdater] Player left. Checking if server is empty.");
    for (
        new i = 1;
        i <= MaxClients;
        i++
        )
        {
            if  (                                                               // are there any real people connected to the server? yes? ok don't do anything
                IsClientConnected(i) &&
                !IsFakeClient(i)     &&
                !IsClientSourceTV(i)
                )
            {
                LogMessage("[RGLUpdater] At least 1 player on server. Not restarting.");
                return;
            }
        }
                                                                                // if we got this far the server's empty
    if (!CfgExecuted || !gameIsLive)                                            // but if a round hasnt been won OR the rgl config hasnt been execed then
        {
            LogMessage("[RGLUpdater] RGL config not executed and/or a round has not yet ended. Not restarting.");
            return;
        }
                                                                                // ok all conditions have been met if we got this far. time to yeet the server
    LogMessage("[RGLUpdater] Server empty. Waiting ~95 seconds for stv and issuing sv_shutdown.");
    CreateTimer(95.0, yeetServ);                                                // wait 90 seconds + 5 (just in case the server is really  slow) for stv
}

public Action yeetServ(Handle timer)                                            // yeet
{
    LogMessage("[RGLUpdater] Issuing sv_shutdown.");
    SetConVarInt(FindConVar("sv_shutdown_timeout_minutes"), 0, false);          // set the server to never shut down here unless it's FULLY empty with this convar...
    ServerCommand("sv_shutdown");                                               // ...and actually send an sv_shutdown. if MY player-on-server logic somehow fails...tf2's HOPEFULLY shouldn't
}

public void OnConVarChanged(ConVar convar, char[] oldValue, char[] newValue)
{
    antiTroll = GetConVarInt(FindConVar("rgl_cast"));
    if (antiTroll == 1)
    {
        autoStuff();
    }
    else if (antiTroll == 0)
    {
        SetConVarInt(FindConVar("sm_reserved_slots"), 0, true);                 // zeros reserved slots value
        ServerCommand("sm plugins unload reservedslots");                       // unloads reserved slots
        ServerCommand("sm plugins unload disabled/reservedslots");              // ^
        SetConVarInt(FindConVar("sv_visiblemaxplayers"), -1, true);             // resets visible slots
    }
}

public void autoStuff()
{
    char cfgVal[32];
    GetConVarString(FindConVar("servercfgfile"), cfgVal, 32);
    if ((SimpleRegexMatch(cfgVal, "^rgl_.*$", 3)) > 0)
    {
        CfgExecuted = true;
    }
    else if ((SimpleRegexMatch(cfgVal, "^server.*$", 3)) > 0)
    {
        CfgExecuted = false;
    }
    else
    {
        CfgExecuted = false;
    }

    // ANTI CAST TROLLING STUFF

    antiTroll = GetConVarInt(FindConVar("rgl_cast"));

    if (antiTroll == 1)
    {
        if ((SimpleRegexMatch(cfgVal, "^.*_(6s|mm)_.*$", 3)) > 0)
        {
            formatVal = 12;
        }
        else if ((SimpleRegexMatch(cfgVal, "^.*_HL_.*$", 3)) > 0)
        {
            formatVal = 18;
        }
        else if ((SimpleRegexMatch(cfgVal, "^.*_7s_.*$", 3)) > 0)
        {
            formatVal = 14;
        }
        else
        {
            formatVal = 0;
        }
    }

    if (CfgExecuted && antiTroll == 1 && formatVal != 0)
    {
        // math time !
        slotVal = ((MaxClients - formatVal) - 1);                               // this calculates reserved slots to leave just enough space for 12/12, 14/14 or 18/18 players on server

        ServerCommand("sm plugins load reservedslots");                         // loads reserved slots because it gets unloaded by soap tournament (thanks lange... -_-)
        ServerCommand("sm plugins load disabled/reservedslots");                // loads it from disabled/ just in case it's disabled by the server owner
        SetConVarInt(FindConVar("sm_reserve_type"), 0, true);                   // set type 0 so as to not kick anyone ever
        SetConVarInt(FindConVar("sm_hide_slots"), 0, true);                     // hide slots is broken with stv so disable it
        SetConVarInt(FindConVar("sm_reserved_slots"), slotVal, true);           // sets reserved slots with above calculated value
        SetConVarInt(FindConVar("sv_visiblemaxplayers"), formatVal, true);      // manually override this because hide slots is broken

        // players can still join if they have password and connect thru console but they will be instantly kicked due to the slot reservation we just made
        // obviously this can backfire if there's an collaborative effort by a player and a troll where the player leaves, and the troll joins in their place...
        // ...but if that's happening the player will almost certainly face severe punishments and a probable league ban.
    }
}

public void OnPluginEnd()
{
    CPrintToChatAll("{lightsalmon}[RGLUpdater]{white} has been {red}unloaded{default}.");
}
