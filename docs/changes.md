# Changes between CompMod and Vanilla (Build 330)
### Alien
* Embryos
    * Hive's don't heal eggs, only embryos
    * Embyro HP scales depending on lifeform.
* Skulk
    * Model/hitbox size reduced by 10%
* Gorge
    * Web
        * Webs break when marines walk through them
* Lerk
    * HP changed to 180/25 from 180/30
* Fade
    * Advanced Metabolise
        * Now required biomass 4 down from 5)
    * Stab replaced by Advanced Swipe
        * Upgrades the normal swipe damage to 81 from 70
        * Can be researched at Biomass 7 
        * Costs 25 tres and takes 60 seconds to research
    * Removed Auto-crouch
    * Blink
        * No longer gain speed on successive blinks without celerity
* Onos
    * BoneShield
        * Add BoneShield initial cost 
        * Moving with BoneShield active will consume BoneFuel faster
    * Charge
        * Knockback removed
* Carapace removed

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
    * Shotgun base aggregate damage reduced to 130 from 170
    * Shotgun rate of fire increased to 1.49 from 1.14
* Heavy Machine Gun
    * Reload is now cancel-able with alt-fire

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
* Team supply is now visible on the player HUD

### Bug Fixes & Improvements
* Carapace now shows correctly in spectate
* ARCs now take corrode damage after deploying and undeploying.
* Vampirism no longer triggers from friendly fire damage.
* Fixed that the scoreboard would sometimes be slow to open.
* Fixed bug where multiple IPs would sometimes spawn with few players
 