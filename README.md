
# Server Resources for RGL.gg

Hi! This github repository contains all of the **required** plugins, configs, maps, etc. for RGL league play. The configs were created from scratch, though they were inspired by the UGC, ETF2L, and CEVO configs. The autoupdater plugin was also created from scratch, but heavily inspired by Miggy's (RIP) [UGCUpdate](https://github.com/Miggthulu/UGCUpdate) and [IntegriTF2](https://github.com/Miggthulu/IntegriTF2) plugins.


In creating the configs, I tried my best to prevent extra and/or useless commands while also minimizing the ability for cheating, exploitation, and unfair play due to preexisting client and/or server settings.

The RGL updater plugin was created mostly by Aad, and it automatically updates itself and the rest of the files downloaded to your server as this repository gets updated.

If you find that I missed something in the configs, or if something doesn't work the way it should, or you have a suggestion, *please add and message me on Steam or Discord*.

my steam id is `/ stephanielgbt /` and my discord is `stephanie#9999` .

If you have problems with the plugin, or if you have a suggestion, please message me or `Aad#2621` on discord about it.

## Install Instructions

1. **Remove all old RGL.gg configs from your server.** (THIS IS IMPORTANT, if you do not do this things will break!)
2. Download the latest zip from the [releases tab](https://github.com/stephanieLGBT/rgl-server-resources/releases/latest)
3. Navigate to your server install folder in an (S)FTP client of your choice
4. Place everything inside the zip into the root `/tf/` folder. Overwrite any and all files that you get prompted for.
5. Done!

If you're still having trouble, there's step by step instructions with pictures over in the [wiki](https://github.com/stephanieLGBT/tf2-halftime/wiki)!

## Updating Instructions

The plugin updates itself, along with the RGL configs, after every exec and changelevel. You should never manually edit any config that isn't a gamemode specific custom.cfg, because it will get automatically overwritten. This is to prevent cheating and ensure each server is running the same settings.

You will have to add new maps to your server manually as RGL introduces them to each gamemode's map pool. This is to prevent lengthly download times with the updater plugin.

Simply download the new map and place it in the `/tf/maps/` folder, through an (S)FTP client of your choice, and you're done.


## !!Please read this section if you're not going to read anything else!!

There are different configs and plugins for scrims and matches if you're playing 5cp and koth in 6s. Halftimes in 5cp and koth are handled by the tf2Halftime plugin, mirrored from [here](https://github.com/stephanieLGBT/tf2-halftime).

Every other gamemode and type has the same config for scrims and matches.

Here are the configs you need to exec for specific modes and map types:


<table>
<thead>
<tr>
<th align="center" colspan="3">6s</th>
</tr>
</thead>
<tbody>
<tr>
<td align="left"><b>type of game</b></td>
<td align="left"><b>config to exec</b></td>
<td align="left"><b>notes</b></td>
</tr>
<tr>
<td align="left">5cp Scrim</td>
<td align="left">rgl_6s_5cp_scrim</td>
<td align="left">winlimit 5, timelimit 30, for scrims only</td>
</tr>
<tr>
<td align="left">5cp Match</td>
<td align="left">rgl_6s_5cp_match</td>
<td align="left">First half: winlimit 3, timelimit 30, 2nd half: first to 5 or timelimit</td>
</tr>
<tr>
<td align="left">5cp Match 1st Half</td>
<td align="left">rgl_6s_5cp_match_half1</td>
<td align="left">winlimit 3, timelimit 30 (this and half2 can be used if plugin isn't available)</td>
</tr>
<tr>
<td align="left">5cp Match 2nd Half</td>
<td align="left">rgl_6s_5cp_match_half2</td>
<td align="left">winlimit 5, timelimit 30, reexec after one team has won 5 total rounds</td>
</tr>
<tr>
<td align="left">5cp Match Golden Cap</td>
<td align="left">rgl_6s_5cp_gc</td>
<td align="left">winlimit 1, no timelimit</td>
</tr>
<tr>
<td align="left">KoTH Match</td>
<td align="left">rgl_6s_koth</td>
<td align="left">winlimit 2, no timelimit, 2 halves.</td>
</tr>
<tr>
<td align="left">KoTH Scrim</td>
<td align="left">rgl_6s_koth</td>
<td align="left">winlimit 2, no timelimit, 2 halves. (can be used for matches and reexeced if plugin is not available, reexec after one team has won 4 total rounds)</td>
</tr>
<tr>
<td align="left">Playoffs KoTH</td>
<td align="left">rgl_6s_koth_bo5</td>
<td align="left">winlimit 3, no timelimit</td>
</tr>
</tbody>
</table>
<br>
<table>
<thead>
<tr>
<th align="center" colspan="3">HL</th>
</tr>
</thead>
<tbody>
<tr>
<td align="left"><b>type of game</b></td>
<td align="left"><b>config to exec</b></td>
<td align="left"><b>notes</b></td>
</tr>
<tr>
<td align="left">Stopwatch</td>
<td align="left">rgl_HL_stopwatch</td>
<td align="left">winlimit 2 (best of 3)</td>
</tr>
<tr>
<td align="left">Regular Season KoTH</td>
<td align="left">rgl_HL_koth</td>
<td align="left">winlimit 2, no timelimit, 2 halves. reexec after one team has won 4 total rounds</td>
</tr>
<tr>
<td align="left">Playoffs KoTH</td>
<td align="left">rgl_HL_koth_bo5</td>
<td align="left">winlimit 3, no timelimit</td>
</tr>
</tbody>
</table>
<br>
<table>
<thead>
<tr>
<th align="center" colspan="3">7s</th>
</tr>
</thead>
<tbody>
<tr>
<td align="left"><b>type of game</b></td>
<td align="left"><b>config to exec</b></td>
<td align="left"><b>notes</b></td>
</tr>
<tr>
<td align="left">Stopwatch</td>
<td align="left">rgl_7s_stopwatch</td>
<td align="left">winlimit 2 (best of 3)</td>
</tr>
<tr>
<td align="left">Regular Season KoTH</td>
<td align="left">rgl_7s_koth</td>
<td align="left">winlimit 2, no timelimit, 2 halves. reexec after one team has won 4 total rounds</td>
</tr>
<tr>
<td align="left">Playoffs KoTH</td>
<td align="left">rgl_7s_koth_bo5</td>
<td align="left">winlimit 3, no timelimit</td>
</tr>
</tbody>
</table>
<br>
<table>
<thead>
<tr>
<th align="center" colspan="3">NR 6s</th>
</tr>
</thead>
<tbody>
<tr>
<td align="left"><b>type of game</b></td>
<td align="left"><b>config to exec</b></td>
<td align="left"><b>notes</b></td>
</tr>
<tr>
<td align="left">5cp</td>
<td align="left">rgl_mm_5cp</td>
<td align="left">winlimit 3, no timelimit</td>
</tr>
<tr>
<td align="left">Stopwatch</td>
<td align="left">rgl_mm_stopwatch</td>
<td align="left">winlimit 2 (best of 3)</td>
</tr>
<tr>
<td align="left">Regular Season KoTH</td>
<td align="left">rgl_mm_koth</td>
<td align="left">winlimit 2, no timelimit, 2 halves. reexec after one team has won 4 total rounds</td>
</tr>
<tr>
<td align="left">Playoffs KoTH</td>
<td align="left">rgl_mm_koth_bo5</td>
<td align="left">winlimit 3, no timelimit</td>
</tr>
</tbody>
</table>
<br>


### Reset Config

`(rcon) exec rgl_off`

This will reset your server to default settings, plus whatever you have set in server.cfg. It *will not* unload the STV bot (though it will stop recording). A more detailed explanation is below.


#### On the off config and STV bugginess

There is something seriously wrong with STV in TF2. For no apparent reason, when you start it up, it eats a player slot by incrementing the value of your server's `maxplayers` by 1. This isn't a problem, typically, because TF2 can technically handle 33 "players", aka 32 + STV. If you were to set +maxplayers to 33 and then add stv, things would get ugly, really quickly.

But that's not all. When the bot is unloaded, it, for no apparent reason, reads the value of `tv_maxplayers` and sets your server's visible player count to *that* number. Why? Who knows. `sv_visiblemaxplayers` has ZERO effect on this. For that reason, I decided to *not* unload the STV bot in the `rgl_off` config, as things would get broken quickly if players didn't set `tv_maxplayers` AND `sv_visiblemaxplayers` to the same value, which also has to be at or under the server's slot limit.

For this reason, and on the advice of some server network operators, I have decided to not shut down stv with rgl_off. If you need to disable the STV, please restart your server.

The bug report for this issue is [here](https://github.com/ValveSoftware/Source-1-Games/issues/2778).

## Special Thanks

thank you to Mastercomms for helping me out with net settings

thank you to Arie from serveme for letting me run some things by him for the configs

thank you to Aad for making the plugin

thank you to JarateKing for adding a .gitattributes file and fixing typos and grammar because I suck with github and english

thank you to Sigafoo for running RGL

thank you to GoD_tony for making the original updater.smx plugin

thank you to F2 for making the original pause plugin, and others

thank you to Miggy for being a cool anticheat admin who inspired me to make the configs in the first place

and shoutouts to plenty of other people for helping me with miscellaneous other stuff
