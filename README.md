
# Server Resources for RGL.gg

Hi! This github repository contains all of the **required** plugins, configs, maps, etc. for RGL league play. The configs were created from scratch, though they were inspired by the UGC, ETF2L, and CEVO configs.


In creating the configs, I tried my best to prevent extra and/or useless commands while also minimizing the ability for cheating, exploitation, and unfair play due to preexisting client and/or server settings.

The RGL updater plugin was created mostly by Aad, and it automatically updates itself and the rest of the files downloaded to your server as this repository gets updated.

If you find that I missed something in the configs, or if something doesn't work the way it should, or you have a suggestion, *please add and message me on Steam or Discord*.

my steam id is `/ stephanielgbt /` and my discord is `stephanie#9999` .

If you have problems with the plugin, or if you have a suggestion, please message me or `Aad#2621` on discord about it.

## Install Instructions

1. Download zip or clone repo
2. Navigate to your server install folder
3. Place *only the folders* into the root `/tf/` folder, overwrite any files that you get prompted for
4. Done!

## !!Please read this section if you're not going to read anything else!!

There are different configs for scrims and matches if you're playing 5cp in 6s. Everything else has the same config for scrims and matches.

Here are the configs you need to exec for specific modes and map types:


| 6s    |                        |                           |                                                                                         |
|:-----:|:----------------------|:-------------------------|:---------------------------------------------------------------------------------------|
|       | **type of game**       | **config to exec**        | **notes**                                                                               |
|       | 5cp Match 1st Half     | rgl_6s_5cp_match_half1    | winlimit 3, timelimit 30                                                                |
|       | 5cp Match 2nd Half     | rgl_6s_5cp_match_half2    | winlimit 5, timelimit 30, reexec after one team has won 5 total rounds                  |
|       | 5cp Scrim              | rgl_6s_5cp_scrim          | winlimit, timelimit 30, for scrims only                                                 |
|       | 5cp Match Golden Cap   | rgl_6s_5cp_gc             | winlimit 1, no timelimit                                                                |
|       | Regular Season KoTH    | rgl_6s_koth               | winlimit 2, no timelimit, 2 halves. reexec after one team has won 4 total rounds        |
|       | Playoffs KoTH          | rgl_6s_koth_bo5           | winlimit 3, no timelimit                                                                |

<br>

| HL    |                        |                           |                                                                                         |
|:-----:|:----------------------|:-------------------------|:---------------------------------------------------------------------------------------|
|       | **type of game**       | **config to exec**        | **notes**                                                                               |
|       | Stopwatch              | rgl_HL_stopwatch          | winlimit 2 (best of 3)                                                                  |
|       | Regular Season KoTH    | rgl_6s_koth               | winlimit 2, no timelimit, 2 halves. reexec after one team has won 4 total rounds        |
|       | Playoffs KoTH          | rgl_6s_koth_bo5           | winlimit 3, no timelimit                                                                |

<br>

| 7s    |                        |                           |                                                                                         |
|:-----:|:----------------------|:-------------------------|:---------------------------------------------------------------------------------------|
|       | **type of game**       | **config to exec**        | **notes**                                                                               |
|       | Stopwatch              | rgl_7s_stopwatch          | winlimit 2 (best of 3)                                                                  |
|       | Regular Season KoTH    | rgl_7s_koth               | winlimit 2, no timelimit, 2 halves. reexec after one team has won 4 total rounds        |
|       | Playoffs KoTH          | rgl_7s_koth_bo5           | winlimit 3, no timelimit                                                                |

<br>

| NR 6s |                        |                           |                                                                                         |
|:-----:|:----------------------|:-------------------------|:---------------------------------------------------------------------------------------|
|       | **type of game**       | **config to exec**        | **notes**                                                                               |
|       | Any 5cp                | rgl_mm_5cp                | winlimit 3, no timelimit                                                                |
|       | Stopwatch              | rgl_mm_stopwatch          | winlimit 2 (best of 3)                                                                  |
|       | Regular Season KoTH    | rgl_mm_koth               | winlimit 2, no timelimit, 2 halves. reexec after one team has won 4 total rounds        |
|       | Playoffs KoTH          | rgl_mm_koth_bo5           | winlimit 3, no timelimit                                                                |

<br>

### Reset Config

`(rcon) exec rgl_off`

This will reset your server to default settings, plus whatever you have set in server.cfg. It *will not* unload the STV bot (though it will stop recording). A more detailed explanation is below.


## On the off config and STV bugginess

There is something seriously wrong with STV in TF2. For no apparent reason, when you start it up, it eats a player slot by incrementing the value of your server's `maxplayers` by 1. This isn't a problem, typically, because TF2 can technically handle 33 "players", aka 32 + STV. If you were to set +maxplayers to 33 and then add stv, things would get ugly, really quickly.

But that's not all. When the bot is unloaded, it, for no apparent reason, reads the value of `tv_maxplayers` and sets your server's visible player count to *that* number. Why? Who knows. `sv_visiblemaxplayers` has ZERO effect on this. For that reason, I decided to *not* unload the STV bot in the `tfcl_off` config, as things would get broken quickly if players didn't set `tv_maxplayers` AND `sv_visiblemaxplayers` to the same value, which also has to be at or under the server's slot limit.

For this reason, and on the advice of some server network operators, I have decided to not shut down stv with tfcl_off. If you need to disable the STV, please restart your server.

The bug report for this issue is [here](https://github.com/ValveSoftware/Source-1-Games/issues/2778).
