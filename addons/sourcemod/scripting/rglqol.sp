#pragma semicolon 1

#include <sourcemod>
#include <color_literals>
#include <regex>

#define PLUGIN_NAME                 "RGL.gg QoL Tweaks"
#define PLUGIN_VERSION              "1.4.2"

bool CfgExecuted;
bool alreadyChanging;
bool IsSafe;
bool warnedStv;
bool matchHasHappened;
isStvDone                           = -1;
formatVal;
slotVal;
Handle g_hForceChange;
Handle g_hWarnServ;
Handle g_hSafeToChangeLevel;
Handle g_hHideServer;
Handle g_hCheckStuff;

float waitTime;

public Plugin:myinfo =
{
    name                            =  PLUGIN_NAME,
    author                          = "Stephanie, Aad",
    description                     = "Adds QoL tweaks for easier competitive server management",
    version                         =  PLUGIN_VERSION,
    url                             = "https://github.com/stephanieLGBT/rgl-server-resources"
}

public OnPluginStart()
{
    // creates cvar for antitrolling stuff
    CreateConVar
        (
            "rgl_cast",
            "0.0",
            "Controls antitroll function for casts/matches. Default 0",
            // notify clients of cvar change
            FCVAR_NOTIFY,
            true,
            0.0,
            true,
            1.0
        );
    CreateConVar
        (
            "rgl_autorestart_waittime",
            "90.0",
            "Controls amount of time to wait before restarting the server after games and matches. Default 90.0",
            // notify clients of cvar change
            FCVAR_NOTIFY,
            true,
            0.0,
            false
        );
    // hooks stuff for auto changelevel
    HookConVarChange(FindConVar("tv_enable"), OnSTVChanged);
    HookConVarChange(FindConVar("servercfgfile"), OnServerCfgChanged);
    AddCommandListener(OnPure, "sv_pure");

    // hooks rgl cvars
    HookConVarChange(FindConVar("rgl_cast"), OnRGLChanged);
    HookConVarChange(FindConVar("rgl_autorestart_waittime"), OnWaitChanged);

    LogMessage("[RGLQoL] Initializing RGLQoL version %s", PLUGIN_VERSION);
    PrintColoredChatAll("\x07FFA07A[RGLQoL]\x01 version \x07FFA07A%s\x01 has been \x073EFF3Eloaded\x01.", PLUGIN_VERSION);
    // hooks round start events
    HookEvent("teamplay_round_start", EventRoundStart);
    // shoutouts to lange, originally borrowed this from soap_tournament.smx here: https://github.com/Lange/SOAP-TF2DM/blob/master/addons/sourcemod/scripting/soap_tournament.sp#L48

    // Win conditions met (maxrounds, timelimit)
    HookEvent("teamplay_game_over", GameOverEvent);
    // Win conditions met (windifference)
    HookEvent("tf_game_over", GameOverEvent);

    HookEvent("player_connect", PlayerConnect);
    HookEvent("player_disconnect", PlayerDisconnect);

    RegServerCmd("changelevel", changeLvl);

    // sets stv slots to reasonable value if default, you're welcome arie!
    if (GetConVarInt(FindConVar("tv_maxclients")) == 128)
    {
        LogMessage("tv_maxclients detected at default. Setting to 8 to prevent server overload!");
        SetConVarInt(FindConVar("tv_maxclients"), 8);
    }
}

public OnMapStart()
{
    delete g_hForceChange;
    delete g_hWarnServ;
    delete g_hSafeToChangeLevel;
    alreadyChanging = false;
    // this is to prevent server auto changing level
    ServerCommand("sm plugins unload nextmap");
    ServerCommand("sm plugins unload mapchooser");
    // this is to unload waitforstv which can break 5cp matches
    ServerCommand("sm plugins unload waitforstv");
    AntiTrollStuff();
}

public Action PlayerConnect(Handle event, const char[] name, bool dontBroadcast)
{
    if (GetEventInt(event, "bot", 0) == 0)
    {
        delete g_hCheckStuff;
    }
}

public Action PlayerDisconnect(Handle event, const char[] name, bool dontBroadcast)
{
    if (GetEventInt(event, "bot", 0) == 0)
    {
        delete g_hCheckStuff;
        g_hCheckStuff = CreateTimer(waitTime, checkStuff);
    }
}

public OnClientPostAdminCheck(client)
{
    CreateTimer(20.0, prWelcomeClient, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
}

public Action prWelcomeClient(Handle timer, int userid)
{
    int client = GetClientOfUserId(userid);
    if  (
            (
                client != 0
            )
            &&
            (
                !IsClientSourceTV(client) && !IsClientReplay(client) && !IsFakeClient(client)
            )
        )
    {
        PrintColoredChat(client, "\x07FFA07A[RGLQoL]\x01 This server is running RGL Updater version \x07FFA07A%s\x01", PLUGIN_VERSION);
        PrintColoredChat(client, "\x07FFA07A[RGLQoL]\x01 Remember, per RGL rules, players must record POV demos for every match!");
    }
}

public Action EventRoundStart(Handle event, const char[] name, bool dontBroadcast)
{
    AntiTrollStuff();
    // prevents stv done notif spam if teams play another round before 90 seconds have passed
    delete g_hSafeToChangeLevel;
}

// guess what this does...
stock GrabPlayerCount()
{
    int realClis = 0;
    for (new Cl = 1; Cl <= MaxClients; Cl++)
    {
        if  (
                IsClientConnected(Cl) &&
                (
                    !IsClientSourceTV(Cl) &&
                    !IsClientReplay(Cl)   &&
                    !IsFakeClient(Cl)
                )
            )
        {
            realClis++;
        }
    }
    return realClis;
}

// checks stuff for restarting server
public Action checkStuff(Handle timer)
{
    g_hCheckStuff = null;
    int curplayers = GrabPlayerCount();
    checkServerCfg();
    LogMessage("[RGLQoL] %i players on server.", curplayers);
    // if the server isnt empty, don't restart! check JUST IN CASE
    if (curplayers > 0)
    {
        LogMessage("[RGLQoL] At least 1 player on server. Not restarting.");
        return;
    }
    else if (!CfgExecuted)
    // if the rgl isnt exec'd dont restart.
    {
        LogMessage("[RGLQoL] RGL config not executed. Not restarting.");
        return;
    }
    else if (!matchHasHappened)
    {
        LogMessage("[RGLQoL] At least 1 game has not happened yet. Not restarting.");
        return;
    }
    // ok. if we got this far, restart the server
    else
    {
        LogMessage("[RGLQoL] Server empty. Issuing sv_shutdown.");
        // set the server to never shut down here unless it's FULLY empty with this convar...
        SetConVarInt(FindConVar("sv_shutdown_timeout_minutes"), 0, false);
        // ...and actually send an sv_shutdown. if MY player-on-server logic somehow fails...tf2's HOPEFULLY shouldn't
        ServerCommand("sv_shutdown");
    }
}

public OnRGLChanged(ConVar convar, char[] oldValue, char[] newValue)
{
    AntiTrollStuff();
}

public OnWaitChanged(ConVar convar, char[] oldValue, char[] newValue)
{
    waitTime = GetConVarFloat(FindConVar("rgl_autorestart_waittime"));
}

// this section was influenced by f2's broken FixSTV plugin
public OnSTVChanged(ConVar convar, char[] oldValue, char[] newValue)
{
    if (StringToInt(newValue) == 1)
    {
        LogMessage("[RGLQoL] tv_enable changed to 1! Changing level in 30 seconds unless manual map change occurs before then.");
        change30();
    }
    else if (StringToInt(newValue) == 0)
    {
        LogMessage("[RGLQoL] tv_enable changed to 0!");
    }
}

checkServerCfg()
{
    // checks if rgl cfg is exec'd first
    char cfgVal[128];
    GetConVarString(FindConVar("servercfgfile"), cfgVal, sizeof(cfgVal));
    if (StrContains(cfgVal, "rgl") != -1)
    {
        // then checks antitroll stuff
        if ((StrContains(cfgVal, "6s", false) != -1) ||
            (StrContains(cfgVal, "mm", false) != -1))
        {
            formatVal = 12;
        }
        else if (StrContains(cfgVal, "HL", false) != -1)
        {
            formatVal = 18;
        }
        else if (StrContains(cfgVal, "7s", false) != -1)
        {
            formatVal = 14;
        }
        else
        {
            formatVal = 0;
        }
        CfgExecuted = true;
    }
    else
    {
        CfgExecuted = false;
    }
}

public OnServerCfgChanged(ConVar convar, char[] oldValue, char[] newValue)
{
    checkServerCfg();
}

// pure checking code below provided by nosoop ("top kekkeroni#4449" on discord) thank you i love you
public Action OnPure(int client, const char[] command, int argc)
{
    if (argc > 0)
    {
        RequestFrame(InvokePureCommandCheck);
    }
    return Plugin_Continue;
}

public void InvokePureCommandCheck(any ignored)
{
    char pureOut[512];
    ServerCommandEx(pureOut, sizeof(pureOut), "sv_pure");
    if (StrContains(pureOut, "changelevel") != -1)
    {
        LogMessage("[RGLQoL] sv_pure cvar changed! Changing level in 30 seconds unless manual map change occurs before then.");
        change30();
    }
}

public change30()
{
    if (!alreadyChanging)
    {
        g_hWarnServ = CreateTimer(5.0, WarnServ, TIMER_FLAG_NO_MAPCHANGE);
        g_hForceChange = CreateTimer(30.0, ForceChange, TIMER_FLAG_NO_MAPCHANGE);
        alreadyChanging = true;
    }
}

public Action GameOverEvent(Handle event, const char[] name, bool dontBroadcast)
{
    isStvDone = 0;
    matchHasHappened = true;
    PrintColoredChatAll("\x07FFA07A[RGLQoL]\x01 Match ended. Wait 90 seconds to changelevel to avoid cutting off actively broadcasting STV. This can be overridden with a second changelevel command.");
    g_hSafeToChangeLevel = CreateTimer(95.0, SafeToChangeLevel, TIMER_FLAG_NO_MAPCHANGE);
    // this is to prevent server auto changing level
    CreateTimer(5.0, unloadMapChooserNextMap);
}

public Action unloadMapChooserNextMap(Handle timer)
{
    ServerCommand("sm plugins unload nextmap");
    ServerCommand("sm plugins unload mapchooser");
}

public Action WarnServ(Handle timer)
{
    LogMessage("[RGLQoL] An important cvar has changed. Forcing a map change in 25 seconds unless the map is manually changed before then.");
    PrintColoredChatAll("\x07FFA07A[RGLQoL]\x01 An important cvar has changed. Forcing a map change in 25 seconds unless the map is manually changed before then.");
    g_hWarnServ = null;
}

public Action SafeToChangeLevel(Handle timer)
{
    isStvDone = 1;
    if (!IsSafe)
    {
        PrintColoredChatAll("\x07FFA07A[RGLQoL]\x01 STV finished. It is now safe to changelevel.");
        // this is to prevent double printing
        IsSafe = true;
    }
    g_hSafeToChangeLevel = null;
}

public Action changeLvl(int args)
{
    if (warnedStv || isStvDone != 0)
    {
        return Plugin_Continue;
    }
    else
    {
        PrintToServer("*** Refusing to changelevel! STV is still broadcasting. If you don't care about STV, changelevel again to override this message and force a map change. ***");
        warnedStv = true;
        ServerCommand("tv_delaymapchange 0");
        ServerCommand("tv_delaymapchange_protect 0");
        return Plugin_Stop;
    }
}

public Action ForceChange(Handle timer)
{
    LogMessage("[RGLQoL] Forcibly changing level.");
    char mapName[128];
    GetCurrentMap(mapName, sizeof(mapName));
    ForceChangeLevel(mapName, "Important cvar changed! Forcibly changing level to prevent bugs.");
    g_hForceChange = null;
}

public AntiTrollStuff()
{
    if (!GetConVarBool(FindConVar("rgl_cast")))
    {
        // zeros reserved slots value
        SetConVarInt(FindConVar("sm_reserved_slots"), 0, true);
        // unloads reserved slots
        ServerCommand("sm plugins unload reservedslots");
        // unloads reserved slots in case its in the disabled folder
        ServerCommand("sm plugins unload disabled/reservedslots");
        // resets visible slots
        SetConVarInt(FindConVar("sv_visiblemaxplayers"), -1, true);
        // resets hide_server
        g_hHideServer = CreateTimer(30.0, resetHideServer);
        //PrintColoredChatAll("\x07FFA07A[RGLQoL]\x01 AntiTroll/Anti-DDOS mode disabled.");
        LogMessage("[RGLQoL] Cast AntiTroll is OFF!");
        return;
    }
    else
    {
        // ANTI TROLLING STUFF (prevents extra users from joining the server, used for casts and also matches if you want to)
        // resets hideserver timer
        delete g_hHideServer;

        if (formatVal == 0)
        {
            LogMessage("[RGLQoL] Config not executed! Cast AntiTroll is OFF!");
        }
        else if (formatVal != 0)
        {
            // this calculates reserved slots to leave just enough space for 12/12, 14/14 or 18/18 players on server
            slotVal = ((MaxClients - formatVal) - 1);
            // loads reserved slots just in case
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
            // obviously this can go wrong if there's an collaborative effort by a player and a troll where the player leaves, and the troll joins in their place...
            // ...but if that's happening the players involved will almost certainly face severe punishments and a probable league ban.
            // set hide_server to 1 to hopefully lock the server down as much as possible
            SetConVarInt(FindConVar("hide_server"), 1, false);
            PrintColoredChatAll("\x07FFA07A[RGLQoL]\x01 AntiTroll/Anti-DDOS mode enabled. All players in the server should \x07FF0000GO OFFLINE ON STEAM\x01 to ensure maximum security.");
            LogMessage("[RGLQoL] Cast AntiTroll is ON!");
        }
    }
}

public Action resetHideServer(Handle timer)
{
    SetConVarInt(FindConVar("hide_server"), 0, false);
    g_hHideServer = null;
}

public OnPluginEnd()
{
    PrintColoredChatAll("\x07FFA07A[RGLQoL]\x01 version \x07FFA07A%s\x01 has been \x07FF4040unloaded\x01.", PLUGIN_VERSION);
}