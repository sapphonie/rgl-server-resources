#pragma semicolon 1

#include <sourcemod>
#include <color_literals>
#include <regex>
#include <nextmap>

#define PLUGIN_NAME                 "RGL.gg QoL Tweaks"
#define PLUGIN_VERSION              "1.3.5b"

bool:CfgExecuted;
bool:antiTroll;
bool:levelChanged;
bool:alreadyRestarting;
bool:alreadyChanging;
bool:IsSafe;
bool:warnedStv;
isStvDone                           = -1;
stvOn;
formatVal;
slotVal;
curplayers;
Handle:g_hForceChange;
Handle:g_hWarnServ;
Handle:g_hyeetServ;
Handle:g_hcheckStuff;
Handle:g_hSafeToChangeLevel;

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
            "controls antitroll function for casts",
            // notify clients of cvar change
            FCVAR_NOTIFY,
            true,
            0.0,
            true,
            1.0
        );
    // hooks stuff for auto changelevel
    HookConVarChange(FindConVar("rgl_cast"), OnRGLChanged);
    HookConVarChange(FindConVar("tv_enable"), OnSTVChanged);
    AddCommandListener(OnPure, "sv_pure");

    LogMessage("[RGLQoL] Initializing RGLQoL version %s", PLUGIN_VERSION);
    PrintColoredChatAll("\x07FFA07A[RGLQoL]\x01 version \x07FFA07A%s\x01 has been \x073EFF3Eloaded\x01.", PLUGIN_VERSION);
    // hooks round start events
    HookEvent("teamplay_round_start", EventRoundStart);
    // hooks player fully disconnected events
    HookEvent("player_disconnect", EventPlayerLeft);

    // shoutouts to lange, borrowed this from soap_tournament.smx here: https://github.com/Lange/SOAP-TF2DM/blob/master/addons/sourcemod/scripting/soap_tournament.sp#L48

    // Win conditions met (maxrounds, timelimit)
    HookEvent("teamplay_game_over", GameOverEvent);
    // Win conditions met (windifference)
    HookEvent("tf_game_over", GameOverEvent);

    RegServerCmd("changelevel", changeLvl);
}

public OnMapStart()
{
    delete g_hForceChange;
    // this is to prevent server auto changing level
    ServerCommand("sm plugins unload nextmap");
    ServerCommand("sm plugins unload mapchooser");
}

public OnClientPostAdminCheck(client)
{
    CreateTimer(15.0, prWelcomeClient, GetClientUserId(client));
    LogMessage("[RGLQoL] Player joined. Killing restart timer.");
    delete g_hyeetServ;
    delete g_hcheckStuff;
}

public Action prWelcomeClient(Handle timer, int userid)
{
    int client = GetClientOfUserId(userid);
    if (client)
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

public Action EventPlayerLeft(Handle event, const char[] name, bool dontBroadcast)
{
    LogMessage("[RGLQoL] Player left. Waiting 10 minutes and then checking if server is empty.");
    delete g_hcheckStuff;
    g_hcheckStuff = CreateTimer(15.0, checkStuff);
}

public Action checkStuff(Handle timer)
{
    stvOn = GetConVarBool(FindConVar("tv_enable"));
    curplayers = GetClientCount() - stvOn;
    LogMessage("[RGLQoL] %i players on server.", curplayers);
    // if the server isnt empty, don't restart!
    if (curplayers > 0)
    {
        LogMessage("[RGLQoL] At least 1 player on server. Not restarting.");
        return;
    }
    // if the rgl config hasnt been execed, don't restart!
    else if (!CfgExecuted)
    {
        LogMessage("[RGLQoL] RGL config not executed. Not restarting.");
        return;
    }
    // ok. the last person has left - restart the server
    else
    {
        if (alreadyRestarting)
        {
            return;
        }
        else if (!alreadyRestarting)
        {
            LogMessage("[RGLQoL] Server empty. Waiting ~95 seconds for STV and issuing sv_shutdown.");
            // wait 90 seconds + 5 (just in case) for stv
            g_hyeetServ = CreateTimer(95.0, yeetServ);
            alreadyRestarting = true;
        }
    }
    g_hcheckStuff = null;
}

// yeet
public Action yeetServ(Handle timer)
{
    LogMessage("[RGLQoL] Issuing sv_shutdown.");
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
        LogMessage("[RGLQoL] Cast AntiTroll has been turned off!");
    }
}

// this section was influenced by f2's broken FixSTV plugin
public OnSTVChanged(ConVar convar, char[] oldValue, char[] newValue)
{
    stvOn = GetConVarBool(FindConVar("tv_enable"));
    if (stvOn == 1)
    {
        LogMessage("[RGLQoL] tv_enable changed to 1! Changing level in 30 seconds unless manual map change occurs before then.");
        change30();
    }
    else if (stvOn == 0)
    {
        LogMessage("[RGLQoL] tv_enable changed to 0!");
    }
}

// pure checking code below provided by nosoop ("top kekkeroni#4449" on discord) thank you i love you

public Action OnPure(int client, const char[] command, int argc)
{
    if (argc > 0)// && client == 0)
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
        g_hWarnServ = CreateTimer(5.0, WarnServ);
        g_hForceChange = CreateTimer(30.0, ForceChange);
        alreadyChanging = true;
    }
}

public Action GameOverEvent(Handle event, const char[] name, bool dontBroadcast)
{
    isStvDone = 0;
    PrintColoredChatAll("\x07FFA07A[RGLQoL]\x01 Match ended. Wait 90 seconds to changelevel to avoid cutting off actively broadcsating STV. This can be overridden with a second changelevel command.");
    g_hSafeToChangeLevel = CreateTimer(95.0, SafeToChangeLevel);
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
    delete g_hSafeToChangeLevel;
}

public Action changeLvl(int args)
{
    if (warnedStv)
    {
        return Plugin_Continue;
    }
    else if (isStvDone == -1)
    {
        levelChanged = true;
        return Plugin_Continue;
    }
    else if (isStvDone == 1)
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
    if (levelChanged || isStvDone == 0)
    {
        return;
    }
    LogMessage("[RGLQoL] Forcibly changing level.");
    char mapName[128];
    GetCurrentMap(mapName, sizeof(mapName));
    ForceChangeLevel(mapName, "Important cvar changed! Forcibly changing level to prevent bugs.");
    g_hForceChange = null;
}

public AntiTrollStuff()
{
    char cfgVal[32];
    GetConVarString(FindConVar("servercfgfile"), cfgVal, 32);
    if ((SimpleRegexMatch(cfgVal, "^rgl.*$", 3)) > 0)
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

    // ANTI TROLLING STUFF (prevents extra users from joining the server, used for casts)

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
            LogMessage("[RGLQoL] Config not executed! Cast AntiTroll has not been enabled!");
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
        // obviously this can go wrong if there's an collaborative effort by a player and a troll where the player leaves, and the troll joins in their place...
        // ...but if that's happening the players involved will almost certainly face severe punishments and a probable league ban.
        LogMessage("[RGLQoL] Cast AntiTroll has been turned on!");
    }
}

public OnPluginEnd()
{
    PrintColoredChatAll("\x07FFA07A[RGLQoL]\x01 version \x07FFA07A%s\x01 has been \x07FF4040unloaded\x01.", PLUGIN_VERSION);
}
