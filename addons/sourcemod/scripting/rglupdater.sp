#pragma semicolon 1
#include <sourcemod>
#undef REQUIRE_PLUGIN
#include <updater>
#include <morecolors>

#define PLUGIN_NAME			"RGL.gg Server Resources Updater"
#define PLUGIN_VERSION		   "1.0.3"
#define UPDATE_URL	  "https://stephanielgbt.github.io/rgl-server-resources/updatefile.txt"

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
	CPrintToChatAll("{lightsalmon}[RGLUpdater]{white} has been unloaded.{default}");
	if (LibraryExists("updater"))
	{
		Updater_AddPlugin(UPDATE_URL);
	}
	HookEvent("teamplay_round_start", EventRoundStart);
}

public Action EventRoundStart(Handle event, const char[] name, bool dontBroadcast)
{
	CPrintToChatAll("{lightsalmon}[RGLUpdater]{white} This Server is running RGL Updater version {lightsalmon}%s{default}", PLUGIN_VERSION);
	return Plugin_Continue;
}


public OnClientPutInServer(client)
{
//	  CPrintToChat(client, "{lightsalmon}[RGLUpdater]{white} This server is running RGL Updater version {lightsalmon}%s{default}", PLUGIN_VERSION);
	PrintToChat(client, "[RGLUpdater] This server is running RGL Updater version %s", PLUGIN_VERSION);
}


public OnLibraryAdded(const String:name[])
{
	if (StrEqual(name, "updater"))
	{
		Updater_AddPlugin(UPDATE_URL);
	}
}

public void OnPluginEnd()
{
	CPrintToChatAll("{lightsalmon}[RGLUpdater]{white} has been unloaded.{default}");
}