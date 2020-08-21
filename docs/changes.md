# Changes between CompMod 3.3.1 and Vanilla 334
<br/>

# Alien
![alt text](https://wiki.naturalselection2.com/images/9/9d/Movement_Banner.png "Alien")

## Drifters
* Reduced hover height to 1 from 1.2 so they don't float in Marine's faces
* Drifters cloaked by Shade hive upgrade will now uncloak from further away (to 5 from 1.5)
* ### Abilities
  * Enzyme
    * Reduced cooldown from 12 seconds to 1 second
  * Hallucinations
    * No longer affected by mucous
    * Can no longer have babblers attached
    * Reduced Onos HP to 100 eHP
  * Mucous
    * Reduced cooldown to 1 second from 12 seconds
    * Reduced cloud radius from 8 to 5 (reduces area by 60%)
    * Shield matches babbler shield values (except Skulk - remains at 15 HP)

## Eggs
* Hives no longer heal eggs, only embryos
* Lifeform egg drops removed

## Embryos
* Embryo HP scales depending on lifeform

## Fade
* ### Advanced Swipe
  * Replaces Stab
  * Upgrades the normal swipe damage to 81 from 70
  * Can be researched at Biomass 7
  * Costs 25 tres and takes 60 seconds to research
* ### Movement
  * Removed auto-crouch
  * Removed ground slide
  * Air friction decreases with Celerity (0.01 per spur, base 0.17)
  * Remove speed cap without Celerity

## Gorge
* ### Babblers
  * Are flammable (die in one welder tick)
  * Reduced spawn rate to 3sec/babbler from 2.5sec/babbler
* ### BileBomb
  * Research changed to Biomass 2 from Biomass 3
* ### Web
  * HP gain per charge to 5 from 10
  * Web charges lowered to 0 from 3
  * Webbed duration lowered to 2.5 seconds from 5 seconds

## Lerk
* ### Movement
  * Increase strafe force to 8.3 from 7
  * Air friction value remains equal to vanilla friction (0.08) for 0.64 seconds after flapping
  * After 0.75 seconds, friction is scaled linearly from 0.08 to 0.5 over 3.25 seconds (total of 4 seconds)
  * This change minimizes the effectiveness of silent Lerk ambushes. A lerk will have to flap in order to quickly catch a marine
  * Lerk movement mid-flight while flapping often is unaffected
* ### Spikes
  * Damage increased to 6 from 5 (to 12 from 10 to players)
  * Spread increased to 3.8 radians from 3.6 radians
  * Size reduced to 45mm from 60mm
* ### Spores
  * Research changed to Biomass 6 from Biomass 5
  * Opacity of cloud lowered by 50%
* ### Umbra
  * Reduced opacity by 50%

## Onos
* ### BoneShield
  * Add small initial cost to BoneShield
  * Moving with BoneShield active will consume BoneFuel faster
* ### Charge
  * Marine knockback removed

## Skulk
* ### BiteCone
  * Reduced width of cone from 1.2 to 0.8
* ### Leap
  * Energy cost increased to 55 from 45

## Structures
* ### Cyst
  * Build time increased to 6 seconds from 3.33 seconds
  * Shade hive cysts are now visible from further away (to 10 from 6)
* ### Shift
  * Echo
    * Echo cost for upgrades increased to 2 from 1
    * Echo cost for eggs reduced to 1 from 2
* ### Tunnels
  * Tunnels are infested tunnels by default
  * Tunnel cost changed to 8 tres from 6 tres
  * Decreased height check for tunnel placement

## Upgrades
* ### Aura
  * Max range decreased to 24 from 30 (to 8 per veil from 10 per veil)
  * No longer shows HP value
* ### Camouflage
  * No longer fully cloaked while moving
* ### Carapace
  * Upgrade removed
* ### Regeneration
  * Removed heal effect (visual and audio)
  * Reduced from 8% per tick to 6% per tick
* ### Vampirism
  * No longer triggers from friendly-fire damage
  * Works against exosuits

# Marine
![alt text](https://wiki.naturalselection2.com/images/3/30/Marine_banner.png "Marine")

## ARCs
* Health lowered to 2200/400 from 2600/400

## AdvancedWeapons
* Shotgun research removed
* Added new research 'Munitions'
  * Researched on Armory
  * Research cost 35 tres
  * Research time 90 seconds
  * Unlocks Shotgun and Heavy Machine Gun to purchase from the Armory
* Added new research 'Demolitions'
  * Researched on Advanced Armory
  * Research cost 15 tres
  * Research time 30 seconds
  * Unlocks Flamethrower and Grenade Launcher to purchase from the Advanced Armory

## MACs
* Cost reduced to 4 tres from 5 tres

## Medpacks
* Marines now keep the HoT effect even when they're full HP for the full duration of the Medpack. They cannot overheal.
* The result is that Marines can take damage after receiving a Medpack and still benefit from the HoT buff, even if they were already healed to full HP.

## Nanoshield
* Duration on players reduced to 2 seconds from 3 seconds

## Structures
* ### AdvancedArmory
  * Health decreased to 2000/200 from 3000/200
  * Research cost decreased to 15 tres from 25 tres
  * Research time decreased to 45 seconds from 90 seconds
* ### Observatory
  * Changed build time to 10 seconds from 15 seconds
* ### Prototype Lab
  * Cost reduced to 25 from 35
* ### Robotics Factory
  * Removed Armory requirement for ARC Factory upgrade
  * ARC Factory upgrade cost increased to 15 tres from 5 tres
* ### Sentry
  * Cost increased to 6 tres from 5 tres
  * Confusion from Spores
    * Duration increased to 8 seconds from 4 seconds
    * Time until next attack increased to 4 seconds from 2 seconds
* ### Sentry Battery
  * Cost increased to 12 tres from 10 tres

## SupplyChanges
* MAC supply cost increased to 15 from 5
* Sentry supply cost increased to 15 from 10
* Observatory supply cost increased to 30 from 25
* Sentry Battery supply cost increased to 25 from 15
* Robotics Factory supply cost increased to 15 from 5

## Weapons
* ### Expiration Rate
  * Stepping on a dropped weapon no longer refreshes the weapon timer
  * Standing near a weapon slows decay rate by 50%
* ### Flamethrower
  * Removed friendly fire of flame puddles
* ### Heavy Machine Gun
  * Reduced damage to 7 from 8
* ### Weapon Lifetime
  * Increased weapon lifetime to 18 seconds from 16 seconds

# Spectator
![alt text](https://wiki.naturalselection2.com/images/d/d1/Alien_Structures_Banner.png "Spectator")
* Fixed edge pan jitter when following a player -- click to unfollow
* Defaulted help text at bottom of the screen to a collapsed state
* Added team supply to top bar

# Global
![alt text](https://wiki.naturalselection2.com/images/3/35/Resource_Model_Banner.png "Global")

## Hive Power Node
* Power node in Alien starting Hive room will no longer be destroyed on round start.

## MucousHitsounds
* Added hitsounds against Aliens with Mucous

## Resources
* Decreased Pres income rate to 1 res per resource tower per minute from 1.25 res per resource tower per minute
* Increased Alien starting pres to 15 from 12
* Increased Marine starting pres to 20 from 15

# Fixes & Improvements
![alt text](https://wiki.naturalselection2.com/images/1/17/Tutorial_Banner.png "Fixes & Improvements")
* Fixed that the scoreboard would sometimes be slow to open
* Fixed bug where multiple IPs would sometimes spawn with few players
