#pragma semicolon 1

#include <sourcemod>
#undef REQUIRE_PLUGIN
#include <updater>

#define PLUGIN_NAME         "RGL.gg Server Resources Updater"
#define PLUGIN_VERSION         "1.0"
#define UPDATE_URL    "https://stephanielgbt.github.io/rgl-server-resources/updatefile.txt"
#define authors
public Plugin:myinfo =
{
    name = PLUGIN_NAME,
    author = "Aad, Stephanie",
    description = "Automatically updates RGL.gg plugins and files",
    version = PLUGIN_VERSION,
    url = "https://github.com/stephanieLGBT/rgl-server-resources"
};

public OnPluginStart()
{
    PrintToChatAll("[RGLUpdater] has been loaded.");
    if (LibraryExists("updater"))
    {
        Updater_AddPlugin(UPDATE_URL);
    }
}

public OnLibraryAdded(const String:name[])
{
    PrintToChatAll("[RGLUpdater] has been loaded.");
    if (StrEqual(name, "updater"))
    {
        Updater_AddPlugin(UPDATE_URL);
    }
}