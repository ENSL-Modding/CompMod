# Changes between CompMod [revision 12](revisions/revision12.md) and Vanilla Build 336
<br/>

# Alien
![alt text](https://wiki.naturalselection2.com/images/9/9d/Movement_Banner.png "Alien")

## Bonewall
* BoneWall is no longer flammable

## Crag
* ### Healing
  * Changed Crag to heal eHP instead of a flat value
  * Implement per-lifeform heal values
  * Added per-lifeform heal, removing the min/max heal clamps for lifeforms
  * Healing values:
    * Skulk: 10 (~13%) up from 7
    * Gorge: 15 (9%) up from 11
    * Lerk: 16 (~9%) up from 10
    * Fade: 25  (10%) up from 17
    * Onos: 80  (11%) up from 42

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

## Embryo
* Embryo HP scales depending on lifeform

## Fade
* ### Advanced Swipe
  * Replaces Stab
  * Upgrades the normal swipe damage to 81 from 75
  * Can be researched at Biomass 7
  * Costs 25 tres and takes 60 seconds to research
* ### Blink
  * Lowered Blink energy cost to 12 from 14

## Gorge
* ### Babblers
  * Are flammable (die in one welder tick)
  * Lowered health to 11 from 12
  * Reduced spawn rate to 3sec/babbler from 2.5sec/babbler
* ### BileBomb
  * Research changed to Biomass 2 from Biomass 3
* ### Web
  * HP gain per charge to 5 from 10
  * Web charges lowered to 0 from 3
  * Webbed duration lowered to 2.5 seconds from 5 seconds

## Healing Cap
* Decreased healing softcap to 12% from 14%
* Increased additional healing penalty to 80% from 66%

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
  * Opacity of cloud lowered by 40%
* ### Umbra
  * Reduced opacity by 25%
  * Increased research cost to 30 from 20
  * Increased research time to 1 minute 45 seconds from 45 seconds
* ### Vampirism Shield
  * Reduced leeched health amount to 6% from 8%

## Onos
* ### BoneShield
  * Add small initial cost to BoneShield
  * Moving with BoneShield active will consume BoneFuel faster
* ### Charge
  * Marine knockback removed
* ### Stomp
  * Moved Stomp to Biomass 9 from Biomass 8

## Skulk
* ### Leap
  * Energy cost increased to 55 from 45

## Structures
* ### Cyst
  * Build time increased to 6 seconds from 3.33 seconds
  * Shade hive cysts are now visible from further away (to 10 from 6)
  * Lowered damage bonus from welders to 5x from 7x
* ### Shift
  * Echo
    * Echo cost for upgrades increased to 2 from 1
    * Echo cost for eggs reduced to 1 from 2
* ### Tunnels
  * Tunnels are infested tunnels by default
  * Tunnel cost changed to 8 tres from 6 tres
  * Decreased height check for tunnel placement

## Upgrades
* ### Adrenaline
  * Removed additional energy pool from Adrenaline
* ### Aura
  * Max range decreased to 24 from 30 (to 8 per veil from 10 per veil)
  * Only shows HP value on parasited players
* ### Camouflage
  * No longer fully cloaked while moving
* ### Carapace
  * Upgrade removed
* ### Neurotoxin
  * Replaces Focus
  * All Alien primary attacks will inflict a poison toxin, hurting Marines over time
  * Damage will tick once every second
  * Duration will be 1 second per Veil
  * Damage Values:
    * Skulk: 7
    * Gorge: 6
    * Lerk: 5
    * Fade: 9
    * Onos: 7
* ### Regeneration
  * Removed heal effect (visual and audio)
  * Reduced from 8% per tick to 6% per tick
* ### Vampirism
  * No longer triggers from friendly-fire damage
  * Works against exosuits
  * Now applies a shader to players that have Vampirism shield
  * Lowered Skulk vampirism percentage to 3.77% from 4.66%

# Marine
![alt text](https://wiki.naturalselection2.com/images/3/30/Marine_banner.png "Marine")

## ARCs
* Health lowered to 2000/500 from 2600/400
* Deployed health lowered to 2000 from 2600

## Advanced Weapons
* Added new research 'Demolitions'
  * Researched on Advanced Armory
  * Research cost 15 tres
  * Research time 30 seconds
  * Unlocks Flamethrower and Grenade Launcher to purchase from the Advanced Armory

## MACs
* Cost reduced to 4 tres from 5 tres

## Medpacks
* Increased instant heal amount to 40 from 25
* Decreased HoT amount to 10 from 25
* Decreased snap radius to match AmmoPack
* Increased pickup delay to 0.6 seconds from 0.45 seconds
* ### HoT
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

## Supply
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
  * Lowered spread to 3.2 radians from 4 radians
  * Increased structure damage multiplier to 1.25x from 1.0x
* ### Shotgun
  * Damage
    * Increase Shotgun damage per weapon upgrade to ~13.33 from ~10
  * Falloff
    * Falloff start distance increased to 10m from 5m
    * Falloff end distance increased to 20m from 15m
      * This will result in Shotguns doing more damage at range
* ### Weapon Lifetime
  * Increased weapon lifetime to 18 seconds from 16 seconds

# Spectator
![alt text](https://wiki.naturalselection2.com/images/d/d1/Alien_Structures_Banner.png "Spectator")

## Edge Panning
* Fixed edge pan jitter when following a player -- click to unfollow

## Help Text
* Defaulted help text at bottom of the screen to a collapsed state

## Supply Display
* Added team supply to top bar

# Global
![alt text](https://wiki.naturalselection2.com/images/3/35/Resource_Model_Banner.png "Global")

## Hive Power Node
* Power node in Alien starting Hive room will no longer be destroyed on round start

## Mucous Hitsounds
* Added hitsounds against Aliens with Mucous

## Resources
* Decreased Pres income rate to 1 res per resource tower per minute from 1.25 res per resource tower per minute
* Increased Alien starting pres to 15 from 12
* Increased Marine starting pres to 20 from 15

# Fixes & Improvements
![alt text](https://wiki.naturalselection2.com/images/1/17/Tutorial_Banner.png "Fixes & Improvements")

## Armory HP Bar
* Fixed a vanilla bug that caused the HP bar for the Armory/Advanced Armory to display at inconsistent heights

## BMAC Hit Sounds
* Changed the blood effects and the hitsounds of BMAC Marines to match the human Marines

## Babbler Shield Friendly Fire Damage Feedback
* Fixed a vanilla bug that would show damage numbers and hitsounds when attacking babbler shielded teammates

## Fade Commander Metabolize Bug
* Fixed a vanilla bug that meant a Fade's active weapon wouldn't reset when becoming a commander while partway through the Metabolize animation

## Female Sprinting Sounds
* Fixed a vanilla bug that caused the start and end sprinting sounds for the Female marine to be swapped

## IPs
* Fixed bug where multiple IPs would sometimes spawn with few players

## Keep Upgrades
* Fixed a vanilla bug that meant players would lose their upgrades when using console commands to change lifeforms

## Scoreboard
* Fixed that the scoreboard would sometimes be slow to open

## Spectator Embryo Script Errors
* Fixed a vanilla bug that would cause script errors and prevent you from joining a team if you joined spec as an embryo

## Status Icons
* Enabled all status icons regardless of HUD detail setting. Previously would only show on High detail
