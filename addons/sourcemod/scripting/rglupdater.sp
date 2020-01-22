#pragma semicolon 1

#include <sourcemod>
#include <updater>
#include <color_literals>

#define REQUIRE_EXTENSIONS
#include <SteamWorks>

#define PLUGIN_NAME                     "RGL.gg Server Resources Updater"
#define PLUGIN_VERSION                  "1.0.0"
new String:UPDATE_URL[128]          =   "https://stephanielgbt.github.io/rgl-server-resources/updatefile.txt";
new bool:isBeta;

public Plugin:myinfo =
{
    name = PLUGIN_NAME,
    author = "Stephanie, Aad",
    description = "Automatically updates RGL.gg plugins and files",
    version = PLUGIN_VERSION,
    url = "https://github.com/stephanieLGBT/rgl-server-resources"
}

public OnPluginStart()
{
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
    rglBetaCheck();
}

public OnLibraryAdded(const String:name[])
{
    if (StrEqual(name, "updater"))
    {
        Updater_AddPlugin(UPDATE_URL);
    }
}

public Action rglBetaCheck()
{
    isBeta = GetConVarBool(FindConVar("rgl_beta"));
    if (isBeta)
    {
        UPDATE_URL = "https://raw.githubusercontent.com/stephanieLGBT/rgl-server-resources/beta/updatefile.txt";
        LogMessage("[RGLUpdater] Update url set to %s.", UPDATE_URL);
        Updater_AddPlugin(UPDATE_URL);
        Updater_ForceUpdate();
    }
    else if (!isBeta)
    {
        UPDATE_URL = "https://stephanielgbt.github.io/rgl-server-resources/updatefile.txt";
        LogMessage("[RGLUpdater] Update url set to %s.", UPDATE_URL);
        Updater_AddPlugin(UPDATE_URL);
        Updater_ForceUpdate();
    }
}
public OnRGLBetaChanged(ConVar convar, char[] oldValue, char[] newValue)
{
    LogMessage("[RGLUpdater] rgl_beta cvar changed!");
    rglBetaCheck();
}

public Updater_OnPluginUpdated()
{
    ServerCommand("sm plugins reload rglupdater");
}

public void OnPluginEnd()
{
    PrintColoredChatAll("\x07FFA07A[RGLUpdater]\x01 version \x07FFA07A%s\x01 has been \x07FF4040unloaded\x01.", PLUGIN_VERSION);
}