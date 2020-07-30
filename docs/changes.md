# Changes between CompMod and Vanilla (Build 332)
### Alien
* Increased starting Pres to 15 from 12
* Lifeforms
    * Pres costs
        * Fade to 35 from 37
        * Onos to 55 from 62
    * Lifeform egg drops removed
* Embryos
    * Hive's don't heal eggs, only embryos
    * Embyro HP scales depending on lifeform.
* Skulk
    * Leap
        * Energy cost increased to 55 from 45
    * Movement
        * Reduced kWallJumpForce to 5 from 6.4
            * The velocity gained while wallhopping scales with this variable and how fast you are going
            * This results in taking ~1.5 more jumps to reach top speed
        * No longer get a speed bonus on their first jump from the ground
        * Can no longer jump at various heights from the floor
    * Bite cone
        * Reduced width of cone from 1.2 to 0.8
* Gorge
    * Babblers
        * Are flammable (die in one welder tick)
        * Reduced spawn rate to 3sec/babbler from 2.5sec/babbler
    * Web
        * HP gain per charge to 5 from 10
        * Webbed duration lowered to 2.5 seconds from 5 seconds
        * Web charges lowered to 0 from 3
* Lerk
    * Increase strafe force to 8.3 from 7
    * Spikes
        * Damage increased to 6 from 5 (to 12 from 10 to players)
        * Spread increased to 3.8 radians from 3.6 radians (Nostalgia spread was 4.0 radians)
        * Size reduced to 45mm from 60mm
    * Air friction value remains equal to vanilla friction (0.08) for 0.64 seconds after flapping
    * After 0.75 seconds, scale friction value linearly from 0.08 to 0.5 over 3.25 seconds (total of 4 seconds)
        * This change minimizes the effectiveness of silent lerk ambushes. A lerk will have to flap in order to quickly catch a marine
        * Lerk movement mid-fight while flapping often is unaffected
    * Spores
        * Requires biomass 6 from 5
* Fade
    * Advanced Metabolise
        * Now required biomass 5 up from 4
    * Stab replaced by Advanced Swipe
        * Upgrades the normal swipe damage to 81 from 70
        * Can be researched at Biomass 7 
        * Costs 25 tres and takes 60 seconds to research
        * Now appears in the researched tech at the bottom of the screen
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
    * Shade hive drifters will now uncloak from further away (to 5 from 1.5)
    * Abilities
        * Mucous
            * Reduced cloud radius from 8 to 5 (reduces area by 60%)
            * Shield matches babbler shield values (except skulk - remains at 15 hp)
        * Hallucinations
            * No longer affected by mucous
            * Can no longer have babblers attached
            * Reduced Onos HP to 100 eHP
            * Reduced hallucination drifter's hover height to match real drifter
* Structures
    * Cyst
        * Build time increased to 6 seconds from 3.33 seconds
        * Unconnected cysts now take 20 damage/second up from 12 damage/second
        * Shade hive cysts are now visible from further away (to 10 from 6)
    * Tunnels
        * Tunnels are infested tunnels by default
        * Tunnel cost changed to 8 tres up from 6 tres
        * Decreased height check for tunnel placement
    * Abilities
        * Echo
            * Echo upgrade cost increased to 2 from 1
            * Echo egg cost reduced to 1 from 2
* Upgrades
    * Aura
        * Max range decreased to 20 from 30 (to 6.67 per veil from 10 per veil)
    * Carapace
        * Upgrade removed
        * Removed upgrade from Tech Map
    * Vampirism
        * No longer triggers from friendly-fire damage
        * Works against exosuits
    * Camouflage
        * No longer fully cloaked while moving
    * Regeneration
        * Reduced from 8% per tick to 6% per tick
        * Removed heal effect (visual and audio)

### Marine
* ARCs
    * Health
        * Health lowered to 2200/400 from 2600/400
* MACs
    * Cost
        * Cost reduced to 3 tres from 5 tres
* Weapons
    * Pistol
        * Damage type changed to NORMAL from LIGHT
        * Damage reduced to 20 from 25
    * Shotgun
        * Reduced weapon upgrade scaling to 5.9% per upgrade from 10% (Damage is now 170, 180, 190, 200)
        * Now unlocked on the Advanced Armory with 'Munitions' research
    * Heavy Machine Gun
        * Reduced damage to 7 from 8
        * Now unlocked on the Advanced Armory with 'Munitions' research
    * Flamethrower
        * Removed friendly fire of flame puddles
        * Now unlocked on the Advanced Armory with 'Demolitions' research
    * Grenade Launcher
        * Now unlocked on the Advanced Armory with 'Demolitions' research
    * Mines
        * Limit capacity to 1 from 2
        * Cost reduced to 5 from 10
    * Weapon Lifetime
        * Reduced weapon lifetime to 18 seconds from 25 seconds
        * Stepping on a dropped weapon no longer refreshes the weapon timer
        * Standing near a weapon slows decay rate by 50%
* Commander Assistance
    * Medpacks
        * Marines now keep the HoT effect even when they're full HP for the full duration of the Medpack. They cannot overheal.
        * The result is that Marines can take damage after receiving a Medpack and still benefit from the HoT buff, even if they were already healed to full HP.
    * Nanoshield
        * Duration on players reduced to 2 seconds from 3 seconds
* Structures
    * Observatory
        * Changed build time to 10 seconds from 15 seconds
    * PrototypeLab
        * Cost reduced to 25 from 35
    * RoboticsFactory
        * Cost reduced to 5 from 10
        * ARC Factory upgrade cost increased to 15 from 5
        * Removed Armory requirement for ARC Factory upgrade
    * Armory
        * Shotgun research removed
        * Added new research 'Munitions'
            * Research cost 35 tres
            * Research time 90 seconds
            * Unlocks Shotgun and Heavy Machine Gun purchase from the Advanced Armory
        * Advanced Armory
            * Health decreased to 2000/200 from 3000/200
            * Research cost to 15 tres from 25 tres
            * Research time to 45 seconds from 90 seconds
            * Added new research 'Demolitions'
                * Research cost 15 tres
                * Research time 30 seconds
                * Unlocks Flamethrower and Grenade Launcher purchase from the Advanced Armory
* Mucous Membrane
    * Added hitsounds for Aliens with mucous
* Increased starting Pres to 20 from 15

### Global
* Decreased Pres income rate to 1 res per resource tower per minute from 1.25 res per resource tower per minute

### Spectator
* Added team supply to top bar
* Fixed edge pan jitter when following a player -- click to unfollow
* Advanced Swipe will now appear in the researched tech at the bottom of the screen
* Defaulted help text at bottom of the screen to a collapsed state

### Bug Fixes & Improvements
* Fixed that the scoreboard would sometimes be slow to open.
* Fixed bug where multiple IPs would sometimes spawn with few players
 