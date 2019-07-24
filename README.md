
# Team Fortress Competitive League Configs

Hi! These are the configs for TFCL, otherwise known as the Team Fortress Competitive League, a competitive Team Fortress 2 league. These configs were created from scratch, though the UGC, ETF2L, and CEVO configs must be mentioned as inspirations. 

I tried my best to remove extraneous commands while minimizing the ability for cheating, exploitation, and unfair play due to preexisting client and/or server settings. If you find that I missed something, or if something doesn't work the way it should, or you have a suggestion, *please add and message me on Steam or Twitter*.

my steam id is / stephanielgbt / and my twitter is @ stephanielgbt .


These are for use in the relaunch of TFCL. *Do not use them directly off github for TFCL matches. Use the ones on the tfcleague domain.*



## !!Please read this section if you're not going to read anything else!!

There are different configs for scrims and matches, if you're playing 5cp. Every other mode is the same, regardless of it being a scrim or a match.

Here are the configs you need to exec for specific modes/map types:

**6s:**

5cp Match: `(rcon) exec tfcl_6s_5cp_match` *exec for 5cp matches*
* 5cp Match Golden Cap: `(rcon) exec tfcl_6s_5cp_GOLD` *exec for golden cap in 5cp matches*

5cp Scrim: `(rcon) exec tfcl_6s_5cp_scrim` *exec for 5cp scrims*

KoTH: `(rcon) exec tfcl_6s_koth` *exec for any koth maps*

Stopwatch: `(rcon) exec tfcl_6s_stopwatch` *exec for any stopwatch style maps*


**HL:**

5cp Match: `(rcon) exec tfcl_HL_5cp_match` *exec for 5cp matches*
* 5cp Match Golden Cap: `(rcon) exec tfcl_HL_5cp_GOLD` *exec for golden cap in 5cp matches*

5cp Scrim: `(rcon) exec tfcl_HL_5cp_scrim` *exec for 5cp scrims*

KoTH: `(rcon) exec tfcl_HL_koth` *exec for any koth maps*

Stopwatch: `(rcon) exec tfcl_HL_stopwatch` *exec for any stopwatch style maps*

**Ultiduo:**

`(rcon) exec tfcl_UD_ultiduo`

**Reset Config:**

`(rcon) exec tfcl_off`

This will reset your server to default settings, plus whatever you have set in server.cfg. It *will not* unload the STV bot (though it will stop recording). A more detailed explaination is below.


## On tfcl_off and STV bugginess

There is something seriously wrong with STV in TF2. For no apparent reason, when you start it up, it eats a player slot by incrementing the value of your server's `maxplayers` by 1. This isn't a problem, typically, because TF2 can technically handle 33 "players", aka 32 + STV. If you were to set +maxplayers to 33 and then add stv, things would get ugly, really quickly.

But that's not all. When you unload the bot, it, for no apparent reason, reads the value of `tv_maxplayers` and sets your server's visible player count to *that* number. Why? Who knows. `sv_visiblemaxplayers` has ZERO effect on this. For that reason, I decided to *not* unload the STV bot in the `tfcl_off` config, as things would get broken quickly if players didn't set `tv_maxplayers` AND `sv_visiblemaxplayers` to the same value, which also has to be at or under the server's slot limit.

For this reason, and on the advice of some server network operators, I have decided to not shut down stv with tfcl_off. If you need to disable the STV, please restart your server.

The bug report for this issue is [here](https://github.com/ValveSoftware/Source-1-Games/issues/2778):

## Todo: 

* ~~add golden cap for all modes~~ **done**
* ~~add stopwatch~~ **done**
* ~~add ?ctf?~~ **probably will never happen**
* ~~add ultiduo~~ **done**
* ~~add highlander~~ **done**
* ~~add overtime/gc~~ **done**