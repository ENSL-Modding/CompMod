# Changes between CompMod and Vanilla (Build 331)
### Alien
* Embryos
    * Hive's don't heal eggs, only embryos
    * Embyro HP scales depending on lifeform.
* Skulk
    * Model/hitbox size reduced by 10%
    * Sneak speed reduced to 4 from 4.8
    * Skulks no longer get a speed bonus on their first jump from the ground
    * Can no longer jump at various heights from the floor
    * Bite cone
        * Reduced width of cone from 1.2 to 0.8
        * Reduced Height of cone from 1.2 to 1.0
        * Reduced range of outer bite cone by 65%
* Gorge
    * Babblers
        * No longer scale with biomass
        * Are flammable (die in one welder tick)
    * Web
        * Webs break when marines walk through them
* Lerk
    * HP changed to 180/25 from 180/30
    * Increase strafe force to 8.3 from 7
    * Spikes
        * Penetrate soft targets
         * Damage increased to 6 from 5 (to 12 from 10 to players)
         * Spread increased to 3.8 radians from 3.6 radians (Nostalgia spread was 4.0 radians)
* Fade
    * Advanced Metabolise
        * Now required biomass 4 down from 5)
    * Stab replaced by Advanced Swipe
        * Upgrades the normal swipe damage to 81 from 70
        * Can be researched at Biomass 7 
        * Costs 25 tres and takes 60 seconds to research
    * Blink
        * Removed Auto-crouch
        * Tweaked movement when traveling faster than base blink speed
            * Will lose velocity more quickly when moving faster than 16.25
            * Rate at which you lose velocity is reduced when using celerity
* Onos
    * BoneShield
        * Add BoneShield initial cost 
        * Moving with BoneShield active will consume BoneFuel faster
    * Charge
        * Knockback removed
* Drifters
    * Reduced hover height to 1 from 1.2 so they don't float in marine's faces
    * Abilities
        * Mucous
            * Reduced cloud radius from 8 to 5 (reduces area by 60%)
            * Shield matches babbler shield values (except skulk - remains at 15 hp)
        * Hallucinations
            * No longer affected by mucous
            * Can no longer have babblers attached
            * Reduced Onos HP to 100 eHP
            * Reduced hallucination drifter's hover height to match real drifter
* Structure Abilities
    * Echo
        * Echo upgrade cost increased to 2 from 1
        * Echo egg cost reduced to 1 from 2
* Upgrades
    * Carapace
        * Upgrade removed
        * Removed upgrade from Tech Map
    * Vampirism
        * Now heals eHP rather than by point value
        * No longer triggers from friendly-fire damage
        * Reduced value on Skulk and Fade to 2 shell vanilla value
    * Camouflage
        * No longer fully cloaked while moving

### Marine
* Medpacks
    * Marines now keep the HoT effect even when they're full HP for the full duration of the Medpack. They cannot overheal.
    * The result is that Marines can take damage after receiving a Medpack and still benefit from the HoT buff, even if they were already healed to full HP. 
* Walk added
    * Default key is CapsLock
* Grenade
    * Throw the grenade instantly, without waiting for the deploy animations.
* Weapon Lifetime
    * Reduced weapon lifetime to 18 seconds from 25 seconds
    * Stepping on a dropped weapon no longer refreshes the weapon timer
    * Standing near a weapon slows decay rate by 50%
* Mucous Membrane
    * Added hitsounds for Aliens with mucous
* PowerNodes
    * Removed the flashlight requirement for finish power nodes without a structure in the room
* Observatory
    * Changed build time to 10 seconds from 15 seconds
* Nanoshield
    * Duration on players reduced to 2 seconds from 5 seconds
* Mines
    * Damage reduced to 130 normal damage from 150 normal damage
* Pistol
    * Damage type changed to NORMAL from LIGHT
    * Damage reduced to 20 from 25
* Shotgun
    * Nostalgia spread
    * Shotgun base aggregate damage reduced to 150 from 170
* Flamethrower
    * Removed friendly fire of flame puddles
* Heavy Machine Gun
    * Decrease clip size to 100 rounds
    * Increase reload speed to 4.5s from 5.0s

### Alien Commander
* Lifeform egg drops removed
* Cyst
    * Build time increased to 6 seconds from 3.33 seconds
    * Unconnected cysts now take 20 damage/second up from 12 damage/second
* Tunnels
    * Tunnels are infested tunnels by default
    * Tunnel cost changed to 8 tres up from 6 tres

### Marine Commander
* Advanced Assistance Tres cost increased to 25 from 20

### Global
* Player healthbars are disabled.

### Bug Fixes & Improvements
* Fixed that the scoreboard would sometimes be slow to open.
* Fixed bug where multiple IPs would sometimes spawn with few players
* Mines can now be killed before arming
* Added team supply to top bar
* Fixed edge pan jitter when following a player -- click to unfollow
* Advanced Swipe will now appear in the researched tech at the bottom of the screen
* Defaulted help text at bottom of the screen to a collapsed state
 