# Changes between CompMod [revision 29](revisions/revision29.md) and Vanilla Build 344
<br/>

# Alien
![alt text](https://static.wikia.nocookie.net/naturalselection/images/9/9d/Movement_Banner.png "Alien")

## Commander Abilities
* ### Adrenaline Rush
  * Added new ability Adrenaline Rush to the Shift
  * Costs 3 tres to cast
  * Duration 5 seconds
  * Cooldown 5 seconds
  * When active increases range and output time of nearby PvE
    * Increases range by 25%
    * Increases output time by 10% (Whips attack 10% faster, Crags heal 10% faster, etc)

## Crag
* ### Healing
  * Changed Crag to heal eHP instead of a flat value
  * Added per-lifeform heal, removing the min/max heal clamps for lifeforms
  * Healing values:
    * Skulk: 10 (~13%) up from 7
    * Gorge: 15 (9%) up from 11
    * Lerk: 16 (~9%) up from 10
    * Fade: 25  (10%) up from 17
    * Onos: 55  (8%) up from 42

## Drifters
* Increased Drifter detection range to 5 from 3
  * This will cause Drifters to uncloak from further away
* ### Abilities
  * Enzyme
    * Decreased cooldown to 1 second from 3 seconds
  * Hallucinations
    * No longer affected by Mucous
    * Will no longer gain health with Biomass upgrades
    * Hallucination Lerks will no longer use Umbra or Spores
  * Mucous
    * Decreased cooldown to 1 second from 3 seconds
    * Added per-lifeform shield values:
      * Skulk: 20% of base health
      * Gorge: 13% of base health
      * Lerk: 14% of base health
      * Fade: 16% of base health
      * Onos: 9% of base health

## Eggs
* Hives no longer heal eggs, only embryos
* Lifeform egg drops removed

## Embryo
* Embryo HP scales depending on lifeform

## Fade
* ### Advanced Swipe
  * Replaces Stab
  * Increases Swipe damage by 8%
  * Can be researched at Biomass 7
  * Costs 25 tres and takes 60 seconds to research
* ### Swipe
  * Damage
    * Increased damage to 75 from 37.5
    * Changed damage type to StructuresOnlyLight from Puncture
    * This will deal the same amount of damage to players but will deal full damage to structures without armour

## Gorge
* ### Babblers
  * Decreased health to 11 from 12
  * Increased spawn rate to 3 seconds from 2.5 seconds
* ### Health
  * Increased Gorge health to 190 from 160
* ### Tunnels
  * Gorges can now drop tunnels for 4 pres
* ### Web
  * Decreased health gain per charge to 5 from 10
  * Decreased Web charges to 0 from 3
  * Decreased webbed duration to 2.5 seconds from 5 seconds

## Healing Cap
* Increased additional healing after softcap to 80% from 66%

## Lerk
* ### Health
  * Decreased base Lerk health to 170 from 180
* ### Movement
  * Air friction value is 8% for 0.75 seconds after flapping
  * After 0.75 seconds, friction is scaled linearly from 8% to 50% over 3.25 seconds
  * This change minimizes the effectiveness of silent Lerk ambushes. A lerk will have to flap in order to quickly catch a marine
  * Lerk movement mid-flight while flapping often is unaffected
* ### Spikes
  * Increased damage to 6 from 5
  * Increased spread to 3.8 degrees from 3.3 degrees
* ### Spores
  * Opacity of cloud lowered by 40%
* ### Umbra
  * Reduced opacity by 25%
  * Increased research time to 105 seconds from 75 seconds

## Onos
* ### BoneShield
  * Decreased hitpoints to 500 from 1000
* ### Charge
  * Marine knockback removed
* ### Stomp
  * Moved Stomp to Biomass 9 from Biomass 8

## Skulk
* ### Leap
  * Increased energy cost to 55 from 45

## Structures
* ### Cyst
  * Increased build time to 6 seconds from 3.33 seconds
  * Increased cyst detection range to 10 from 8
  * Lowered damage bonus from welders to 4x from 7x
  * Increased auto build time multiplier with Shift hive to 1.5 from 1.25
* ### Movement
  * Structures will move 10% faster when not under attack
* ### Tunnels
  * Tunnels are infested tunnels by default
  * Decreased height check for tunnel placement

## Upgrades
* ### Aura
  * Decreased max range to 24 from 30
  * Only shows HP value on parasited players
* ### Camouflage
  * No longer fully cloaked while moving
* ### Carapace
  * Upgrade removed
* ### Neurotoxin
  * Replaces Focus
  * All Alien primary attacks will inflict a poison toxin, hurting the Marine over time
  * Damage ticks every 1 second
  * The toxin inflicted from each hit lasts for 1 second
  * Damage Values:
    * Skulk: 7
    * Gorge: 6
    * Lerk: 5
    * Fade: 9
    * Onos: 7
* ### Regeneration
  * Removed heal effect (visual and audio)
* ### Vampirism
  * Health can no longer be leached from friendly-fire damage
  * Health can now be leached from Exosuits
  * Added a shader to players that have Vampirism shield
    * This is so that the Marines can have visual feedback
  * Decreased Skulk vampirism percentage to 3.77% per shell from 4.66% per shell

# Marine
![alt text](https://static.wikia.nocookie.net/naturalselection/images/3/30/Marine_banner.png "Marine")

## ARCs
* Decreased health to 1800 from 2600
* Increased armor to 500 from 400
* Decreased deployed health to 1800 from 2600
* Commanders can only create a maximum of 4 ARCs

## Advanced Weapons
* Added new research 'Demolitions'
  * Researched on Advanced Armory
  * Research cost 15 tres
  * Research time 30 seconds
  * Unlocks Flamethrower and Grenade Launcher to purchase from the Advanced Armory

## Jetpacks
* Increased drop cost to 20 tres from 15 tres

## MACs
* Increased cost to 4 tres from 3 tres
* MACs will move 15% faster when not under attack

## Medpacks
* Increased instant heal amount to 50 from 25
* Decreased HoT amount to 0 from 25
* Decreased snap radius to match AmmoPack
* Increased pickup delay to 0.6 seconds from 0.45 seconds
* ### HoT
  * Marines now keep the HoT effect even when they're full HP for the full duration of the Medpack. They cannot overheal.
  * The result is that Marines can take damage after receiving a Medpack and still benefit from the HoT buff, even if they were already healed to full HP.

## Nanoshield
* Decreased player duration to 2 seconds from 3 seconds

## Structures
* ### AdvancedArmory
  * Decreased health to 2000 from 3000
  * Decreased research cost to 15 tres from 25 tres
  * Decreased research time to 45 seconds from 90 seconds
  * Now heals Marine armour
    *  Heals 15 armour per tick
* ### Phase Gate
  * Decreased health to 1300 from 1500
  * Increased armor to 900 from 800
* ### Robotics Factory
  * Removed Armory requirement for ARC Factory upgrade
* ### Sentry
  * Increased cost to 6 tres from 5 tres
* ### Sentry Battery
  * Increased cost to 12 tres from 10 tres

## Supply
* Increased Observatory supply cost to 30 from 25
* Increased Robotics Factory supply cost to 15 from 10

## Upgrades
* ### Armour 1
  * Increased research time to 80 from 75
* ### Armour 2
  * Increased research time to 95 from 90
* ### Weapons 1
  * Increased research time to 80 from 75
* ### Weapons 2
  * Increased research time to 95 from 90

## Weapons
* ### Expiration Rate
  * Stepping on a dropped weapon no longer refreshes the weapon timer
  * Standing near a weapon slows decay rate by 50%
* ### Flamethrower
  * Removed friendly fire of flame puddles
* ### Heavy Machine Gun
  * Increased structure damage scalar to 25% from 0%
* ### Shotgun
  * Falloff
    * Increased falloff start distance to 10 from 5
    * Increased falloff end distance to 20 from 15
      * This will result in Shotguns doing more damage at range
* ### Weapon Lifetime
  * Increased weapon lifetime to 18 seconds from 16 seconds

# Spectator
![alt text](https://static.wikia.nocookie.net/naturalselection/images/d/d1/Alien_Structures_Banner.png "Spectator")

## Edge Panning
* Fixed edge pan jitter when following a player -- click to unfollow

## Help Text
* Defaulted help text at bottom of the screen to a collapsed state

## Supply Display
* Added team supply to top bar

# Global
![alt text](https://static.wikia.nocookie.net/naturalselection/images/3/35/Resource_Model_Banner.png "Global")

## Hive Power Node
* Power node in Alien starting Hive room will no longer be destroyed on round start

## Mucous Hitsounds
* Added hitsounds against Aliens with Mucous

# Fixes & Improvements
![alt text](https://static.wikia.nocookie.net/naturalselection/images/1/17/Tutorial_Banner.png "Fixes & Improvements")

## Ambient Sound
* Sets the ambient sound modifier to 0, if the lowest option (20%) is chosen in the sound settings.

## Armory HP Bar
* Fixed a vanilla bug that caused the HP bar for the Armory/Advanced Armory to display at inconsistent heights

## BMAC Hit Sounds
* Changed the blood effects and the hitsounds of BMAC Marines to match the human Marines

## Babbler Shield Friendly Fire Damage Feedback
* Fixed a vanilla bug that would show damage numbers and hitsounds when attacking babbler shielded teammates

## Biodamnnn Minimal Particles
* Updated minimal particle prop exclusion list to include ns2_biodamnnn

## Fade Commander Metabolize Bug
* Fixed a vanilla bug that meant a Fade's active weapon wouldn't reset when becoming a commander while partway through the Metabolize animation

## Female Sprinting Sounds
* Fixed a vanilla bug that caused the start and end sprinting sounds for the Female marine to be swapped

## IPs
* Fixed bug where multiple IPs would sometimes spawn with few players

## Minimap
* Fixed that enemy structures would not pulse red when under attack
* Fixed a vanilla bug that would render the Marine minimap over status icons
  * See: https://youtu.be/_8OmfC79-jc

## Scoreboard
* Fixed that the scoreboard would sometimes be slow to open

## Spectator Embryo Script Errors
* Fixed a vanilla bug that would cause script errors and prevent you from joining a team if you joined spec as an embryo

## Status Icons
* Enabled all status icons regardless of HUD detail setting. Previously would only show on High detail
* Fixed that the status icon duration bar would sometimes go negative

<br/>
<hr/>
<br/>

Last updated: 25 February 2023
