# Changes between Vanilla (Build 328)
## Changes between ns2_beta Revision 2 and Vanilla (Build 328)
A list of changes between ns2_beta Revision 2 and Build 328 can be found [here](ns2_beta_rev2).
## Changes between CompMod and Vanilla (Build 328)
### Alien
* Embryos
    * Hive's don't heal eggs, only embryos
    * Embyro HP scales depending on lifeform.
* Gorge
    * Web
        * Webs break when marines walk through them
* Lerk
    * Spores
        * Now requires biomass 5 (up from 4)
* Fade
    * Advanced Metabolise
        * Now required biomass 4 down from 5)
    * Stab replaced by Advanced Swipe
        * Upgrades the normal swipe damage to 81 from 70
        * Can be researched at Biomass 7 
        * Costs 25 tres and takes 60 seconds to research
* Onos
    * BoneShield
        * Add BoneShield initial cost 
        * Moving with BoneShield active will consume BoneFuel faster
    * Stomp
        * Research cost increased to 35 from 25
        * Research time increased to 90 seconds from 60 seconds
* Heal sound will no longer play when shells are built.

### Marine
* Walk added
    * Default key is CapsLock
* Grenade
    * Improved Grenade Quick Throw
        * Implements an improved version of the grenade quick throw found in ns2_beta
        * Allows Marines to throw the grenade instantly, without waiting for the deploy animations.
* Pulse Grenade
	* Damage decreased to 50 from 140
* Axe
    * The axe now works. (Thanks Steelcap ❤️)

### Alien Commander
* Lifeform egg drops removed
* Cyst
    * Build time increased to 6 seconds from 3.33 seconds
    * Unconnected cysts now take 20 damage/second up from 12 damage/second
* Harvesters
    * Now take 60 seconds to die off infestation down from 90 seconds.
* Tunnels
    * Tunnels are infested tunnels by default
    * Tunnel cost changed to 8 tres up from 6 tres
* Supply Changes
    * Drifter costs 5 from 10
    * Whip costs 10 from 5
    * Crag costs 25 from 5
    * Shift costs 25 from 5
    * Shade costs 25 from 5

### Marine Commander
* Supply Changes
    * MAC costs 5 from 10
    * Armory costs 0 from 5
    * ARCs cost 25 from 35
    * Robotics Factory costs 0 from 5
    * Sentry Battery costs 10 from 0
    * Observatory costs 40 from 0

### Global
* Player healthbars are disabled.
* Team supply is now visible on the player HUD

### Bug Fixes & Improvements
* ARCs now take corrode damage after deploying and undeploying.
* Cysts should no longer starve when they shouldn't
* Cysts should be able to find their parents more reliably when the chain is updated
* Drifters can pop blueprints again
* Killfeed shows for spectators and readyroom players again
 
