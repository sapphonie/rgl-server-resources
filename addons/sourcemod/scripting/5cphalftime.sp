#pragma semicolon 1

#include <sourcemod>
#include <morecolors>
#undef REQUIRE_PLUGIN
#include <updater>

#define PLUGIN_VERSION	"1.0.6"
#define UPDATE_URL	"https://raw.githubusercontent.com/stephanieLGBT/5cp-halftime/master/updatefile.txt"



public Plugin myinfo = {
	name			= "basic halftime for 5cp",
	author			= "stephanie",
	description		= "emulates esea style halves for 5cp",
	version			= PLUGIN_VERSION,
	url				= "https://stephanie.lgbt"
};

new bluRnds;					// blu round int created here
new redRnds;					// blu round int created here
new bool:isHalf2;				// bool value for determining halftime created here

public void OnPluginStart()
{
	if (LibraryExists("updater"))
	{
		Updater_AddPlugin(UPDATE_URL);
	}
	HookEvent("teamplay_round_win", EventRoundEnd); // hooks round win events
	SetConVarInt(FindConVar("mp_winlimit"), 0, true); // finds and sets winlimit to 0, as this plugin handles it instead
}

public void OnMapEnd() // resets score on map change
{
	bluRnds = 0;
	redRnds = 0;
	isHalf2 = false;
}

public void EventRoundEnd(Event event, const char[] name, bool dontBroadcast) // who fucking knows what this does
{
	int team = event.GetInt("team"); // gets int value of the team who won the round. 2 = red, 3 = blu, anything else is a stalemate
	int winreason = event.GetInt("winreason"); // gets winreason to prevent incrementing when a stalemate occurs

/**vvv LOGIC HERE vvv **/
// this will get refactored at some point because it's messy

	if (team == 2 && winreason == 1) // RED TEAM NON-STALEMATE WIN EVENT
	{
		redRnds++; // increments red round counter by +1
		CPrintToChatAll("{mediumpurple}[5cpHalftime] {red}Red{white} wins! The score is {red}Red{white}: {red}%i{white}, {blue}Blu{white}: {blue}%i{white}.", redRnds, bluRnds);
		if (redRnds >= 3 && !isHalf2) // red reaches 3 rounds before timelimit
		{
			isHalf2 = true;
			CPrintToChatAll("{mediumpurple}[5cpHalftime] {white}Halftime reached! The score is {red}Red{white}: {red}%i{white}, {blue}Blu{white}: {blue}%i{white}.", redRnds, bluRnds);
			ServerCommand("mp_tournament_restart");
		} else if (redRnds == 5 && isHalf2) // red reaches 5 rounds
		{
			CPrintToChatAll("{mediumpurple}[5cpHalftime] {white}The game is over, and {red}Red{white} wins! The score is {red}Red{white}: {red}%i{white}, {blue}Blu{white}: {blue}%i{white}.", redRnds, bluRnds);
			ServerCommand("mp_tournament_restart");
		}
	} else if (team == 3 && winreason == 1) // BLU TEAM NON-STALEMATE WIN EVENT
	{
		bluRnds++; // increments blu round counter by +1
		CPrintToChatAll("{mediumpurple}[5cpHalftime] {blue}Blu{white} wins! The score is {red}Red{white}: {red}%i{white}, {blue}Blu{white}: {blue}%i{white}.", redRnds, bluRnds);
		if (bluRnds >= 3 && !isHalf2) // blu reaches 3 rounds before timelimit
		{
			isHalf2 = true;
			CPrintToChatAll("{mediumpurple}[5cpHalftime] {white}Halftime reached! The score is {red}Red{white}: {red}%i{white}, {blue}Blu{white}: {blue}%i{white}.", redRnds, bluRnds);
			ServerCommand("mp_tournament_restart");
		} else if (bluRnds == 5 && isHalf2) {
			CPrintToChatAll("{mediumpurple}[5cpHalftime] {white}The game is over, and {blue}Blu{white} wins! The score is {red}Red{white}: {red}%i{white}, {blue}Blu{white}: {blue}%i{white}.", redRnds, bluRnds);
			ServerCommand("mp_tournament_restart");
		}
	} else if (isHalf2) // is it the 2nd half?
	{
		if (redRnds < bluRnds) // does blu have more points?
		{
			CPrintToChatAll("{mediumpurple}[5cpHalftime] {white}Timelimit reached! The game is over, and {red}Red{white} wins! The score is {red}Red{white}: {red}%i{white}, {blue}Blu{white}: {blue}%i{white}.", redRnds, bluRnds); // blu win @ timelimit in half 2
			ServerCommand("mp_tournament_restart");
		} else if (redRnds < bluRnds) // ok, does red have more points?
		{
			CPrintToChatAll("{mediumpurple}[5cpHalftime] {white}Timelimit reached! The game is over, and {blue}Blu{white} wins! The score is {red}Red{white}: {red}%i{white}, {blue}Blu{white}: {blue}%i{white}.", redRnds, bluRnds);
			ServerCommand("mp_tournament_restart");
		} else if (redRnds == bluRnds) // no? golden cap
		{
			CPrintToChatAll("{mediumpurple}[5cpHalftime] {white}Timelimit reached! Neither team has won! Exec rgl_6s_5cp_match_gc. The score is {red}Red{white}: {red}%i{white}, {blue}Blu{white}: {blue}%i{white}.", redRnds, bluRnds);
			ServerCommand("mp_tournament_restart");
		}
	} else if (redRnds < 3 && bluRnds < 3) // handles 1st halves going to timelimit
	{
		CPrintToChatAll("{mediumpurple}[5cpHalftime] {white}Halftime reached due to timelimit! The score is {red}Red{white}:{red}%i{white}, {blue}Blu{white}: {blue}%i{white}.", redRnds, bluRnds);
		isHalf2 = true;
		ServerCommand("mp_tournament_restart");
	} else // catch all for nonsensical scenarios
	{
		CPrintToChatAll("{mediumpurple}[5cpHalftime] {white}Something broke, somewhere. The score is {red}Red{white}:{red}%i{white}, {blue}Blu{white}: {blue}%i{white}.", redRnds, bluRnds);
		CPrintToChatAll("{mediumpurple}[5cpHalftime] {white}Spitting out debug info: winreason %i, team %i. Score is {red}Red{white}:{red}%i{white}, {blue}Blu{white}: {blue}%i{white}.", winreason, team, redRnds, bluRnds);
		if (isHalf2) {
			CPrintToChatAll("{mediumpurple}[5cpHalftime] {white}isHalf2 = true");
		} else {
			CPrintToChatAll("{mediumpurple}[5cpHalftime] {white}isHalf2 = false");
		}
	}
	}
/**^^^ LOGIC HERE ^^^ **/