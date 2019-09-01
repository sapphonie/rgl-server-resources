## Install Instructions

1. Remove all old RGL.gg configs from your server.
2. Extract the contents of this .zip file (not the .zip file itself) to your server's /tf/ folder through an (S)FTP client of your choice
3. Overwrite ANY AND ALL files that you get prompted for.
4. Done!

## Updating Instructions

The plugin updates itself, along with the RGL configs, after every exec and changelevel. You should never manually edit any config that isn't a gamemode specific custom.cfg, because it will get automatically overwritten. This is to prevent cheating and ensure each server is running the same settings.

You will have to add new maps to your server manually as RGL introduces them to each gamemode's map pool. This is to prevent lengthly download times with the updater plugin.

Simply download the new map and place it in the /tf/maps/ folder through an (S)FTP client of your choice, and you're done.


## READ THIS PLEASE ##

There are different configs for scrims and matches if you're playing 5cp in 6s. Everything else has the same config for scrims and matches.

Here are the configs you need to exec for specific modes and map types:

+----------------------+------------------------+----------------------------------------------------------------------------------+
|                                                                6s                                                                |
+----------------------+------------------------+----------------------------------------------------------------------------------+
| type of game         | config to exec         | notes                                                                            |
+----------------------+------------------------+----------------------------------------------------------------------------------+
|                      |                        |                                                                                  |
+----------------------+------------------------+----------------------------------------------------------------------------------+
| 5cp Scrim            | rgl_6s_5cp_scrim       | winlimit 5, timelimit 30, for scrims only                                        |
+----------------------+------------------------+----------------------------------------------------------------------------------+
| 5cp Match 1st Half   | rgl_6s_5cp_match_half1 | winlimit 3, timelimit 30                                                         |
+----------------------+------------------------+----------------------------------------------------------------------------------+
| 5cp Match 2nd Half   | rgl_6s_5cp_match_half2 | winlimit 5, timelimit 30, reexec after one team has won 5 total rounds           |
+----------------------+------------------------+----------------------------------------------------------------------------------+
| 5cp Match Golden Cap | rgl_6s_5cp_gc          | winlimit 1, no timelimit                                                         |
+----------------------+------------------------+----------------------------------------------------------------------------------+
| Regular Season KoTH  | rgl_6s_koth            | winlimit 2, no timelimit, 2 halves. reexec after one team has won 4 total rounds |
+----------------------+------------------------+----------------------------------------------------------------------------------+
| Playoffs KoTH        | rgl_6s_koth_bo5        | winlimit 3, no timelimit                                                         |
+----------------------+------------------------+----------------------------------------------------------------------------------+

+----------------------+------------------------+----------------------------------------------------------------------------------+
|                                                                HL                                                                |
+----------------------+------------------------+----------------------------------------------------------------------------------+
| type of game         | config to exec         | notes                                                                            |
+----------------------+------------------------+----------------------------------------------------------------------------------+
|                      |                        |                                                                                  |
+----------------------+------------------------+----------------------------------------------------------------------------------+
| Stopwatch            | rgl_HL_stopwatch       | winlimit 2 (best of 3)                                                           |
+----------------------+------------------------+----------------------------------------------------------------------------------+
| 5cp Match 1st Half   | rgl_HL_koth            | winlimit 2, no timelimit, 2 halves. reexec after one team has won 4 total rounds |
+----------------------+------------------------+----------------------------------------------------------------------------------+
| 5cp Match 2nd Half   | rgl_HL_koth_bo5        | winlimit 3, no timelimit                                                         |
+----------------------+------------------------+----------------------------------------------------------------------------------+

+----------------------+------------------------+----------------------------------------------------------------------------------+
|                                                                7s                                                                |
+----------------------+------------------------+----------------------------------------------------------------------------------+
| type of game         | config to exec         | notes                                                                            |
+----------------------+------------------------+----------------------------------------------------------------------------------+
|                      |                        |                                                                                  |
+----------------------+------------------------+----------------------------------------------------------------------------------+
| Stopwatch            | rgl_7s_stopwatch       | winlimit 2 (best of 3)                                                           |
+----------------------+------------------------+----------------------------------------------------------------------------------+
| 5cp Match 1st Half   | rgl_7s_koth            | winlimit 2, no timelimit, 2 halves. reexec after one team has won 4 total rounds |
+----------------------+------------------------+----------------------------------------------------------------------------------+
| 5cp Match 2nd Half   | rgl_7s_koth_bo5        | winlimit 3, no timelimit                                                         |
+----------------------+------------------------+----------------------------------------------------------------------------------+

+----------------------+------------------------+----------------------------------------------------------------------------------+
|                                                        No Restrictions 6s                                                        |
+----------------------+------------------------+----------------------------------------------------------------------------------+
| type of game         | config to exec         | notes                                                                            |
+----------------------+------------------------+----------------------------------------------------------------------------------+
|                      |                        |                                                                                  |
+----------------------+------------------------+----------------------------------------------------------------------------------+
| 5cp                  | rgl_mm_5cp             | winlimit 3, no timelimit                                                         |
+----------------------+------------------------+----------------------------------------------------------------------------------+
| Stopwatch            | rgl_7s_stopwatch       | winlimit 2 (best of 3)                                                           |
+----------------------+------------------------+----------------------------------------------------------------------------------+
| 5cp Match 1st Half   | rgl_7s_koth            | winlimit 2, no timelimit, 2 halves. reexec after one team has won 4 total rounds |
+----------------------+------------------------+----------------------------------------------------------------------------------+
| 5cp Match 2nd Half   | rgl_7s_koth_bo5        | winlimit 3, no timelimit                                                         |
+----------------------+------------------------+----------------------------------------------------------------------------------+


## Contact

If you run into any issues with these server resources, please contact me or Aad on Discord.

stephanie#9999
Aad#2621

## More info

https://stephanielgbt.github.io/rgl-server-resources/

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