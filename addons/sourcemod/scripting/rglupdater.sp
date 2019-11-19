#pragma semicolon 1
#include <sourcemod>
#include <updater>
#include <morecolors>

#define REQUIRE_EXTENSIONS
#include <SteamWorks>

#define PLUGIN_NAME         "RGL.gg Server Resources Updater"
#define PLUGIN_VERSION      "1.1"
#define UPDATE_URL          "https://stephanielgbt.github.io/rgl-server-resources/updatefile.txt"

new bool:CfgExecuted = false;
new antiTroll;
new formatVal;
new slotVal;

public Plugin:myinfo =
{
    name        =  PLUGIN_NAME,
    author      = "Aad, Stephanie",
    description = "Automatically updates RGL.gg plugins and files",
    version     =  PLUGIN_VERSION,
    url         = "https://github.com/stephanieLGBT/rgl-server-resources"
};

ConVar g_Cvar_rglCast;

public OnPluginStart()
{
    CPrintToChatAll("{lightsalmon}[RGLUpdater]{white} has been {green}loaded{default}.");
    if (LibraryExists("updater"))                                       // this is the actual "updater" part of this plugin
    {
        Updater_AddPlugin(UPDATE_URL);
    }
    HookEvent("teamplay_round_start", EventRoundStart);
    HookEvent("player_disconnect", EventPlayerLeft);
    CreateConVar                                                        // creates cvar for the antitrolling stuff
        (
        "rgl_cast",
        "0.0",
        "controls antitroll function of rglupdater",
        FCVAR_NOTIFY,                                                   // Notify clients
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

public OnClientPutInServer(client)
{
    PrintToChat(client, "[RGLUpdater] This server is running RGL Updater version %s", PLUGIN_VERSION);
}

public OnLibraryAdded(const String:name[])
{
    if (StrEqual(name, "updater"))
    {
        Updater_AddPlugin(UPDATE_URL);                                  // does updater stuff as well
    }
}

public Action EventPlayerLeft(Handle event, const char[] name, bool dontBroadcast)
{
    LogMessage("[RGLUpdater] Player left. Checking if server is empty.");
    for (                                                               // iterates thru remaining clients on server
        new i = 1;
        i <= MaxClients;
        i++
        )
        {
            if (IsClientConnected(i) && !IsFakeClient(i) && IsClientSourceTV(i))
            {                                                           // are there any real people connected to the server? yes? ok don't do anything
                LogMessage("[RGLUpdater] At least 1 player on server. Not restarting.");
                return;
            }
        }
                                                                        // ok so the servers empty, is it running the cfg?
    if (!CfgExecuted)                                                   // if it doesn't have an rgl cfg exec'd than cancel because the server would infinitely reboot otherwise
        {
            LogMessage("[RGLUpdater] RGL config not executed. Not restarting.");
            return;
        }
                                                                        // ok then yeet the server
    LogMessage("[RGLUpdater] Server empty. Issuing sv_shutdown.");
    SetConVarInt(FindConVar("sv_shutdown_timeout_minutes"), 0, false);  // set the server to never shut down here unless it's fully empty with this convar
    ServerCommand("sv_shutdown");                                       // and actually send an sv_shutdown. if MY logic somehow fails...tf2's HOPEFULLY shouldn't
}

public void OnConVarChanged(ConVar convar, char[] oldValue, char[] newValue)
{
    antiTroll = GetConVarInt(FindConVar("rgl_cast"));
    if (antiTroll == 1)
    {
        autoStuff();
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
            /*
            FAIL SAFE!
            i'd rather have this plugin bug out, and
            *not* restart a server with nobody on it, and
            have it be a minor inconvience instead of having
            this plugin bug out and it then restarting a server
            with ppl on it, screwing things up real badly
            */
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

        slotVal = ((MaxClients - formatVal) - 1);                           // this calculates reserved slots to leave just enough space for 12/12 or 14/14 or 18/18 players on server

        ServerCommand("sm plugins load reservedslots");                     // loads reserved slots because it gets unloaded by soap tournament (thanks lange... -_-)
        ServerCommand("sm plugins load disabled/reservedslots");            // loads it from disabled/ just in case it's disabled by the server owner
        SetConVarInt(FindConVar("sm_reserve_type"), 0, true);               // set type 0 so as to not kick anyone ever
        SetConVarInt(FindConVar("sm_hide_slots"), 0, true);                 // hide slots is broken with stv so disable it
        SetConVarInt(FindConVar("sm_reserved_slots"), slotVal, true);       // sets reserved slots with above calculated value
        SetConVarInt(FindConVar("sv_visiblemaxplayers"), formatVal, true);  // manually override this because hide slots is broken

        // players can still join if they have password and connect thru console but they will be instantly kicked due to the slot reservation we just made
        // obviously this can backfire if there's an collaborative effort by a player and a troll where the player leaves, and the troll joins in their place...
        // ...but if that's happening the player will almost certainly face severe punishments and a probable league ban.

    }
}

public void OnPluginEnd()
{
    CPrintToChatAll("{lightsalmon}[RGLUpdater]{white} has been {red}unloaded{default}.");
}
