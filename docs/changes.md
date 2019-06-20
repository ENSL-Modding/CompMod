## Changes
### Alien
* Embryos
    * Hive's don't heal eggs, only embryos
    * Embyro HP scales depending on lifeform.
* Upgrades
    * Camouflage
        * Cloak intensity is now related to player speed.
        * Lifeforms will decloak when moving at full speed
    * Carapace
        * Decreased armour bonus for skulks to 15 (from 20)
        * Decreased armour bonus for lerks to 20 (from 30)
* Gorge
    * Web
        * Webs break when marines walk through them
        * Webs no longer show in the kill feed
* Lerk
    * Changed hp to 190/20 from 150/45 (shifting more hp to health)
    * Spikes
        * Increased spread to 3.6 radius (from 3.1)
        * Deceased spike diameter to 0.045 (from 0.06)
    * Umbra
        * Now requires biomass 6 (up from 5)
        * Decreased damage reduction to 20% (from 25%)
        * Decreased umbra cloud life time to 2.5 seconds (from 4)
* Fade
    * Increased initial blink boost to 15 m/s (from 13.5)
* Onos
    * Decreased base health to 700 (from 900)
    * Increased biomass health bonus to 50 (from 30)
    * Increase Boneshield Movement Speed to 4.5 (up from 3.3)
    * Boneshield is now available on Biomass 5 (down from Bio 6)
* Cyst & Clogs receive 7x direct damage from welders, flame throwers and cluster grenades (up from 2.5x)
* Cyst
    * Build time increased to 6 seconds from 3.33 
seconds
### Marine
* Walk added
    * Default key is CapsLock
* Grenade
    * Pulse
        * Damage increased to 140 from 110
        * Explode radius lowered to 1 from 3
    * Nerve Gas Grenade
        * Grenade lifetime lowered from 10 to 7.5
        * Cloud lifetime lowered from 6 to 4.5
    * Cluster Grenade
        * Set players and structures on fire
        * New damage type ClusterFlame  
            * Similar to Flame but deals half damage to players and 25% more damage to structures.
* Machine Gun
    * Decreased player target damage to 12/13/14/15 from 12/13.2/14.4/15.6
* Mines
    * Damage type changed to Normal (from Light)
    * Damage increased to 150 (from 125)
    * HP increased to 50 (from 30)
    * Mines should no longer detonate when killed while deploying
* Shotgun
    * Removed damage falloff
    * Change the spread pattern to 13 (1/5/7) pellets total with variable calibers and damage values:
        * 1 pellet in the very center causing 15 dmg and a caliber of 16 mm
        * 5 pellets with a center offset of 0.6 (inner ring) dealing 17 dmg and and a caliber of 16 mm
        * 7 pellets with a center offset of 1.6 (outer ring) dealing 17 dmg and and a caliber of 150 mm
        ![Shotgun Changes](https://camo.githubusercontent.com/ca0779b0cdec0246ebdb359237a2dc30deb3b49e/68747470733a2f2f7472656c6c6f2d6174746163686d656e74732e73332e616d617a6f6e6177732e636f6d2f3562346532333734383733396331333333663664633439392f3563643263643138336264366531323165386233326161632f35613031383536393731336438613166333031346136376135313662343466392f3332375f53475f72616e746f2e706e67)
* Axe
    * The axe now works.

### Alien Commander
* Consume
    * Essentially recycle for the Alien side.
    * Allows commanders to recycle their structures to get the supply cost back.
    * Does not give resources back.
* Lifeform egg drops removed

### Marine Commander
* NanoShield
    * Search range lowered to 3 from 6
        * Placing NanoShield on a specific player is difficult in a group because it tends to target the wrong player.
        * This is fixed by lowering the search range.
        * Vanilla NanoShield has similar behaviour to how NanoBoost was before the sensitivity options were added. Example [here](https://gfycat.com/smugharmlessblacklab-overwatch-ana-why-tho)    
* ARC
    * Damage reduced to 530 (from 630)
    * Changed hp to 2600/400 fromm 3000/200 (shifting more hp to armor)
    * Fixed that ARCs didn't save and restore their previous armor value properly when changing their deployment state.
    * Make ARCs target the center of their target, instead of the model origin. So ARCs total damage is consistent and doesn't depend on the height of the main target's model origin.

### Global
* Player healthbars are disabled.

### Bug Fixes
* ARCs now take corrode damage after deploying and undeploying.
