#pragma semicolon 1

#include <sourcemod>
#include <updater>
#include <color_literals>

#define REQUIRE_EXTENSIONS
#include <SteamWorks>

#define PLUGIN_NAME                     "RGL.gg Server Resources Updater"
#define PLUGIN_VERSION                  "2.0.9b"
new String:UPDATE_URL[128]          =   "https://stephanielgbt.github.io/rgl-server-resources/updatefile.txt";
new bool:isBeta;
new bool:updatePlug;

public Plugin:myinfo =
{
    name                            =  PLUGIN_NAME,
    author                          = "Stephanie, Aad",
    description                     = "Automatically updates RGL.gg plugins and files",
    version                         =  PLUGIN_VERSION,
    url                             = "https://github.com/stephanieLGBT/rgl-server-resources"
}

public OnPluginStart()
{
    LogMessage("[RGLUpdater] version %s has been loaded.", PLUGIN_VERSION);
    PrintColoredChatAll("\x07FFA07A[RGLUpdater]\x01 version \x07FFA07A%s\x01 has been \x073EFF3Eloaded\x01.", PLUGIN_VERSION);
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
    HookConVarChange(FindConVar("rgl_beta"), OnRGLBetaChanged);
}

public OnLibraryAdded(const String:name[])
{
    if (StrEqual(name, "updater"))
    {
        Updater_AddPlugin(UPDATE_URL);
    }
}

public OnRGLBetaChanged(ConVar convar, char[] oldValue, char[] newValue)
{
    if (StringToInt(newValue) == 1)
    {
        return;
    }
    else if (StringToInt(newValue) == 0)
    {
        isBeta = GetConVarBool(FindConVar("rgl_beta"));
        LogMessage("[RGLUpdater] rgl_beta cvar changed!");
        if (isBeta)
        {
            UPDATE_URL = "https://raw.githubusercontent.com/stephanieLGBT/rgl-server-resources/beta/updatefile.txt";
            LogMessage("[RGLUpdater] rgl_beta = 1");
            LogMessage("[RGLUpdater] Update url is %s.", UPDATE_URL);
            LogMessage("[RGLUpdater] QUEUING UPDATE");
        }
        else if (!isBeta)
        {
            UPDATE_URL = "https://stephanielgbt.github.io/rgl-server-resources/updatefile.txt";
            LogMessage("[RGLUpdater] rgl_beta = 0");
            LogMessage("[RGLUpdater] Update url is %s.", UPDATE_URL);
            LogMessage("[RGLUpdater] QUEUING UPDATE");
        }
        Updater_RemovePlugin();
        Updater_AddPlugin(UPDATE_URL);
        Updater_ForceUpdate();
        updatePlug = true;
    }
}

public Updater_OnPluginUpdated()
{
    if (updatePlug)
    {
        RequestFrame(reloadPlug);
    }
}

public reloadPlug()
{
    ServerCommand("sm plugins reload disabled/tf2Halftime");
    ServerCommand("sm plugins reload pause");
    ServerCommand("sm plugins reload rglqol");
    ServerCommand("sm plugins reload rglupdater");
}

public void OnPluginEnd()
{
    LogMessage("[RGLUpdater] version %s has been unloaded.", PLUGIN_VERSION);
    PrintColoredChatAll("\x07FFA07A[RGLUpdater]\x01 version \x07FFA07A%s\x01 has been \x07FF4040unloaded\x01.", PLUGIN_VERSION);
}
