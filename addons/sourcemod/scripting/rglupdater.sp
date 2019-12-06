#pragma semicolon 1
#include <sourcemod>
#include <updater>
#include <morecolors>
#include <nextmap>

#define REQUIRE_EXTENSIONS
#include <SteamWorks>

#define PLUGIN_NAME         "RGL.gg Server Resources Updater & More"
#define PLUGIN_VERSION      "1.2.2beta"

// yes this is the same variable name from tf2Halftime
new String:UPDATE_URL[128] =     "https://stephanielgbt.github.io/rgl-server-resources/updatefile.txt";
new bool:gameIsLive;
new bool:CfgExecuted;
new bool:antiTroll;
new bool:isBeta;
new bool:levelChanged = false;
new isStvDone = -1;
new stvOn;
new formatVal;
new slotVal;
new curplayers;
new Handle:g_hCheckPlayers = INVALID_HANDLE;
new Handle:g_hForceChange = INVALID_HANDLE;

public Plugin:myinfo =
{
    name        =  PLUGIN_NAME,
    author      = "Aad, Stephanie",
    description = "Automatically updates RGL.gg plugins and files and adds QoL tweaks for server management",
    version     =  PLUGIN_VERSION,
    url         = "https://github.com/stephanieLGBT/rgl-server-resources"
}

public OnPluginStart()
{
    // creates cvars for antitrolling stuff and beta opt in
    CreateConVar
        (
        "rgl_cast",
        "0.0",
        "controls antitroll function of rglupdater",
        // notify clients of cvar change
        FCVAR_NOTIFY,
        true,
        0.0,
        true,
        1.0
        );
    CreateConVar
        (
        "rgl_beta",
        "0.0",
        "controls if rglupdater uses the beta branch on github",
        // notify clients of cvar change
        FCVAR_NOTIFY,
        true,
        0.0,
        true,
        1.0
        );
    HookConVarChange(FindConVar("rgl_cast"), OnRGLChanged);
    HookConVarChange(FindConVar("rgl_beta"), OnRGLBetaChanged);
    HookConVarChange(FindConVar("tv_enable"), OnSTVChanged);
    rglBetaCheck();
    LogMessage("[RGLUpdater] Initializing RGLUpdater version %s", PLUGIN_VERSION);
    CPrintToChatAll("{lightsalmon}[RGLUpdater]{white} has been {green}loaded{default}.");
    // hooks round start events
    HookEvent("teamplay_round_start", EventRoundStart);
    // hooks round win events for determining auto restart
    HookEvent("teamplay_round_win", EventRoundEnd);
    // hooks player fully disconnected events
    HookEvent("player_disconnect", EventPlayerLeft);

    // shoutouts to lange, borrowed this from soap_tournament.smx here: https://github.com/Lange/SOAP-TF2DM/blob/master/addons/sourcemod/scripting/soap_tournament.sp#L49

    // Win conditions met (maxrounds, timelimit)
    HookEvent("teamplay_game_over", GameOverEvent);
    // Win conditions met (windifference)
    HookEvent("tf_game_over", GameOverEvent);

    RegServerCmd("changelevel", changeLvl);
}

public OnLibraryAdded(const String:name[])
{
    if (StrEqual(name, "updater"))
    {
        // does updater stuff as well
        Updater_AddPlugin(UPDATE_URL);
    }
}

public OnMapStart() {
    // kill the changelevel timer if its running
    if (g_hForceChange != INVALID_HANDLE)
    {
        KillTimer(g_hForceChange);
        g_hForceChange = INVALID_HANDLE;
    }
    // double assign this just in case because sometimes invalid handles don't get read properly as invalid
    g_hForceChange = INVALID_HANDLE;
    gameIsLive = false;
}

public OnClientPostAdminCheck(client)
{
    PrintToChat(client, "[RGLUpdater] This server is running RGL Updater version %s", PLUGIN_VERSION);
}

public OnClientPutInServer(client)
{
    LogMessage("[RGLUpdater] Player joined. Killing player checker timer.");
    if (g_hCheckPlayers != INVALID_HANDLE)
    {
        KillTimer(g_hCheckPlayers);
        g_hCheckPlayers = INVALID_HANDLE;
    }
    // double assign this just in case because sometimes invalid handles don't get read properly as invalid
    g_hCheckPlayers = INVALID_HANDLE;
}

public Action EventRoundStart(Handle event, const char[] name, bool dontBroadcast)
{
    CPrintToChatAll("{lightsalmon}[RGLUpdater]{white} This server is running RGL Updater version {lightsalmon}%s{default}", PLUGIN_VERSION);
    AntiTrollStuff();
}

// hook the round end event for making sure that a game has occured before restarting the server
public EventRoundEnd(Event event, const char[] name, bool dontBroadcast)
{
    // sets gamelive bool to true
    gameIsLive = true;
}

public Action EventPlayerLeft(Handle event, const char[] name, bool dontBroadcast)
{
    LogMessage("[RGLUpdater] Player left. Waiting 30 seconds and then checking if server is empty.");
    // kill the player check timer if its running
    if (g_hCheckPlayers != INVALID_HANDLE)
    {
        KillTimer(g_hCheckPlayers);
        g_hCheckPlayers = INVALID_HANDLE;
    }
    // double assign this just in case because sometimes invalid handles don't get read properly as invalid
    g_hCheckPlayers = INVALID_HANDLE;
    g_hCheckPlayers = CreateTimer(30.0, checkStuff);
}

public Action checkStuff(Handle timer)
{
    stvOn = GetConVarBool(FindConVar("tv_enable"));
    curplayers = GetClientCount() - stvOn;
    LogMessage("[RGLUpdater] %i players on server.", curplayers);
    if (curplayers > 0)
    {
        LogMessage("[RGLUpdater] At least 1 player on server. Not restarting.");
        return;
    }
    // ok if we get this far server's empty. but if a round hasnt been won OR the rgl config hasnt been execed then don't restart!
    else if (!CfgExecuted || !gameIsLive)
    {
        LogMessage("[RGLUpdater] RGL config not executed and/or a round has not yet ended. Not restarting.");
        return;
    }
    // ok. the game is over. the last person has left. restart the server
    else
    {
        LogMessage("[RGLUpdater] Server empty. Waiting ~95 seconds for stv and issuing sv_shutdown.");
        // wait 90 seconds + 5 (just in case the server is really  slow) for stv
        CreateTimer(95.0, yeetServ);
    }
}

// yeet
public Action yeetServ(Handle timer)
{
    LogMessage("[RGLUpdater] Issuing sv_shutdown.");
    // set the server to never shut down here unless it's FULLY empty with this convar...
    SetConVarInt(FindConVar("sv_shutdown_timeout_minutes"), 0, false);
    // ...and actually send an sv_shutdown. if MY player-on-server logic somehow fails...tf2's HOPEFULLY shouldn't
    ServerCommand("sv_shutdown");
}

public OnRGLChanged(ConVar convar, char[] oldValue, char[] newValue)
{
    antiTroll = GetConVarBool(FindConVar("rgl_cast"));
    if (antiTroll)
    {
        AntiTrollStuff();
        return;
    }
    else if (!antiTroll)
    {
        // zeros reserved slots value
        SetConVarInt(FindConVar("sm_reserved_slots"), 0, true);
        // unloads reserved slots
        ServerCommand("sm plugins unload reservedslots");
        // unloads reserved slots in case its in the disabled folder
        ServerCommand("sm plugins unload disabled/reservedslots");
        // resets visible slots
        SetConVarInt(FindConVar("sv_visiblemaxplayers"), -1, true);
        LogMessage("[RGLUpdater] Casting antiTroll stuff has been turned off!");
        return;
    }
}

public rglBetaCheck()
{
    isBeta = GetConVarBool(FindConVar("rgl_beta"));
    if (isBeta)
    {
        UPDATE_URL = "https://raw.githubusercontent.com/stephanieLGBT/rgl-server-resources/beta/updatefile.txt";
        return;
    }
    else if (!isBeta)
    {
        UPDATE_URL = "https://stephanielgbt.github.io/rgl-server-resources/updatefile.txt";
        return;
    }
    // this is the actual "updater" part of this plugin
    if (LibraryExists("updater"))
    {
        Updater_AddPlugin(UPDATE_URL);
    }
}

public OnRGLBetaChanged(ConVar convar, char[] oldValue, char[] newValue)
{
    rglBetaCheck();
}

// this section was influenced by f2's broken FixSTV plugin
public OnSTVChanged(ConVar convar, char[] oldValue, char[] newValue)
{
    stvOn = GetConVarBool(FindConVar("tv_enable"));
    if (stvOn == 1)
    {
        LogMessage("[RGLUpdater] tv_enable changed to 1! Changing level in 30 seconds unless manual map change occurs before then.");
        CPrintToChatAll("{lightsalmon}[RGLUpdater]{white} tv_enable changed to 1! Changing level in 30 seconds unless manual map change occurs before then.");

        // we wait 30 seconds in case the server owner changes the level on their own
        CreateTimer(30.0, ForceChange);
        return;
    }
    else if (stvOn == 0)
    {
        LogMessage("[RGLUpdater] tv_enable changed to 0!");
        CPrintToChatAll("{lightsalmon}[RGLUpdater]{white} tv_enable changed to 0! You must restart your server to unload STV properly!");
        return;
    }
}

public Action GameOverEvent(Handle event, const char[] name, bool dontBroadcast)
{
    isStvDone = 0;
    CPrintToChatAll("{lightsalmon}[RGLUpdater]{white} Match ended. Wait 90 seconds to changelevel to avoid cutting off actively broadcasting STV. {default}", PLUGIN_VERSION);
    CreateTimer(95.0, SafeToChangeLevel);
}

public Action SafeToChangeLevel(Handle timer)
{
    isStvDone = 1;
    CPrintToChatAll("{lightsalmon}[RGLUpdater]{white} STV finished. It is now safe to changelevel. {default}", PLUGIN_VERSION);
}

public Action changeLvl(int args)
{
    if (isStvDone == -1)
    {
        levelChanged = true;
        return Plugin_Continue;
    }
    if (isStvDone)
    {
        return Plugin_Continue;
    }
    else
    {
        PrintToServer("Refusing to changelevel! Please wait until STV is done broadcasting.");
        return Plugin_Stop;
    }
}

public Action ForceChange(Handle timer)
{
    if (levelChanged || isStvDone == 0)
    {
        return;
    }
    LogMessage("[RGLUpdater] Changing level to fix STV");
    CPrintToChatAll("{lightsalmon}[RGLUpdater]{white} tv_enable changed to 1! Changing level to fix STV");
    new String:mapName[128];
    GetCurrentMap(mapName, sizeof(mapName));
    ForceChangeLevel(mapName, "Changing level to fix STV");
}

public AntiTrollStuff()
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

    // ANTI TROLLING STUFF (prevents extra users from joining the server, useful for casts)

    antiTroll = GetConVarBool(FindConVar("rgl_cast"));

    if (antiTroll)
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
            LogMessage("[RGLUpdater] Config not executed! Cast AntiTroll has not been enabled!");
        }
    }

    if (CfgExecuted && antiTroll && formatVal != 0)
    {
        // this calculates reserved slots to leave just enough space for 12/12, 14/14 or 18/18 players on server
        slotVal = ((MaxClients - formatVal) - 1);

        // loads reserved slots because it gets unloaded by soap tournament (thanks lange... -_-)
        ServerCommand("sm plugins load reservedslots");
        // loads it from disabled/ just in case it's disabled by the server owner
        ServerCommand("sm plugins load disabled/reservedslots");
        // set type 0 so as to not kick anyone ever
        SetConVarInt(FindConVar("sm_reserve_type"), 0, true);
        // hide slots is broken with stv so disable it
        SetConVarInt(FindConVar("sm_hide_slots"), 0, true);
        // sets reserved slots with above calculated value
        SetConVarInt(FindConVar("sm_reserved_slots"), slotVal, true);
        // manually override this because hide slots is broken
        SetConVarInt(FindConVar("sv_visiblemaxplayers"), formatVal, true);

        // players can still join if they have password and connect thru console but they will be instantly kicked due to the slot reservation we just made
        // obviously this can backfire if there's an collaborative effort by a player and a troll where the player leaves, and the troll joins in their place...
        // ...but if that's happening the player will almost certainly face severe punishments and a probable league ban.
        LogMessage("[RGLUpdater] Cast AntiTroll has been turned on!");
    }
}

public OnPluginEnd()
{
    CPrintToChatAll("{lightsalmon}[RGLUpdater]{white} has been {red}unloaded{default}.");
}
