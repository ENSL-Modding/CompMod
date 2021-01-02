# CompMod 3.5.6 - (02/01/2021)
## Alien

### Upgrades
* Neurotoxin
  * Increased Gorge damage to 5 from 4
  * Increased Lerk damage to 4 from 3
  * Increased Fade damage to 8 from 6
  * Increased Onos damage to 6 from 4

<br/>

# CompMod 3.5.5 - (31/12/2020)
## Alien

### Upgrades
* Neurotoxin
  * Replaces Focus
  * All Alien primary attacks will inflict a poison toxin, hurting Marines over time
  * Damage will tick once every second
  * Duration will be 1 second per Veil
  * Damage Values:
    * Skulk: 6
    * Gorge: 4
    * Lerk: 3
    * Fade: 6
    * Onos: 4

## Fixes & Improvements

### Armory HP Bar
* Fixed a vanilla bug that caused the HP bar for the Armory/Advanced Armory to display at inconsistent heights

### Female Sprinting Sounds
* Fixed a vanilla bug that caused the start and end sprinting sounds for the Female marine to be swapped

### Keep Upgrades
* Fixed a vanilla bug that meant players would lose their upgrades when using console commands to change lifeforms

<br/>

# CompMod 3.5.4 - (29/12/2020)
## Alien

### Lerk
* Vampirism Shield
  * Reduced leeched health amount to 6% from 8%

<br/>

# CompMod 3.5.3 - (17/10/2020)
* Updated CompMod for NS2 Build 335

<br/>

# CompMod 3.5.2 - (14/10/2020)
## Alien

### Fade
* Movement
    * Fixed a bug that let you go supersonic if you held blink while on the ground

<br/>

# CompMod 3.5.1 - (04/10/2020)
## Alien

### Fade
* Movement
  * Added a miniumum speed of 15 to Blink. When changing direction you are guaranteed this speed as a minimum
  * Softcaps added to Fade speed:
    * 19 without Celerity
    * 20.5 with Celerity

## Marine

### Advanced Weapons
* Removed Munitions tech

### Weapons
* Heavy Machine Gun
  * Lowered spread to 3.6 radians from 4 radians

<br/>

# CompMod 3.5.0 - (26/09/2020)
## Alien

### Fade
* Advanced Swipe
  * Fixed a bug that caused the normal Swipe icon to show in the killfeed

* Movement
  * Reverted base movement system back to vanilla
  * Max speed decreased to 20 from 25
  * Blink no longer ignores the Fade's momentum
  * Softcaps added to Fade speed:
    * 17.5 without Celerity
    * 19 with Celerity
  * Movement Breakdown:
    * Without Celerity
      * Initial Blink will give 15 speed from 16.25 speed,
      * Each subsequent blink will now give 2.5 speed
    * With Celerity
      * Initial Blink will give 15.6 speed from 18.28 speed,
      * Each subsequent blink will give 2.9 speed

### Upgrades
* Vampirism
  * Now applies a shader to players that have Vampirism shield

<br/>

# CompMod 3.4.0 - (05/09/2020)
## Alien

### Fade
* Movement
  * Decreased base speed of Blink, increase Celerity Blink speed to compensate
  * Movement Breakdown
    * First blink adds 16.325 speed in the direction the Fade is facing
    * Subsequent blinks add 2.25 speed in the direction the Fade is facing
    * With Celerity: Each Spur adds an additional 0.29 speed to the first blink and 0.06 speed to subsequent blinks

### Lerk
* Spores
  * Opacity of cloud lowered to 40%
* Umbra
  * Reduced opacity to 25%

### Upgrades
* Adrenaline
  * Removed additional energy pool from Adrenaline
* Aura
  * Only shows HP value on parasited players

## Marine

### Weapons
* Shotgun
  * Damage
    * Increase Shotgun damage per weapon upgrade to ~13.33 from ~10
  * Falloff
    * Falloff start distance increased to 10m from 5m
    * Falloff end distance increased to 20m from 15m
      * This will result in Shotguns doing more damage at range

## Fixes & Improvements

### Fade
* Fixed that a Fade's active weapon wouldn't reset when becoming a commander while partway through the Metabolize animation

<br/>

# CompMod 3.3.6 - (03/09/2020)
* Rolled back collision fix from 3.3.5.

<br/>

# CompMod 3.3.5 - (01/09/2020)
## Marine

### Weapons
* Shotgun
  * Falloff start distance increased to 10m from 5m
  * Falloff end distance increased to 20m from 15m
    * This will result in Shotguns doing more damage at range

## Fixes & Improvements

### Collision
* Fixed that two players colliding could cause one player to warp on top of the other player (e.g. Marines walking on top of Skulks, Fades walking on top of crouching Marines, etc.)

<br/>

# CompMod 3.3.4 - (29/08/2020)
## Alien

### Fade
* Movement
  * Re-added ground slide
  * Reduced ground slide duration to 1 second from 2 seconds

<br/>

# CompMod 3.3.3 - (26/08/2020)
## Alien

### Fade
* Movement
  * Increased speed of blink without Celerity
    * First blink adds 16.55 speed in the direction the Fade is facing (from 16.2 speed)
    * Subsequent blinks add 2.3 speed in the direction the Fade is facing (from 2.2 speed)
  * Decreased additional speed gained with Celerity (to 0.15 from 0.3)

<br/>

# CompMod 3.3.2 - (25/08/2020)
## Alien

### BoneWall
* BoneWall is no longer flammable

### Fade
* Movement
  * Increased speed of blink without Celerity.
  * Decreased additional speed gained with Celerity (to 0.3 from 0.5)
    * Net result means that Fades are faster without Celerity but the same speed with 3 Spurs and Celerity

<br/>

# CompMod 3.3.1 - (19/08/2020)
## Alien

### Fade
* Movement
  * Reverted movement base to vanilla
  * Removed auto-crouch
  * Removed ground slide
  * Air friction decreases with Celerity (0.01 per spur, base 0.17)
  * Remove speed cap without Celerity

### Lerk
* Umbra
  * Reduced opacity by 50%

### Upgrades
* Aura
  * Max range decreased to 24 from 30 (to 8 per veil from 10 per veil)
  * No longer shows HP value

## Marine

### MACs
* Cost reduced to 4 tres from 5 tres

## Bug Fixes
* Fixed an indentation issue with the changelogs
* Fixed that webs would still have a single charge applied

<br/>

# CompMod 3.3.0 - (16/08/2020)
## Bug Fixes
* Fixed that per-lifeform Mucous values weren't being applied properly

<br/>

# CompMod 3.2.1 - (05/08/2020)
## Alien
* Spores
    * Opacity of burning cinematic lowered by 50%

* BileBomb
    * Opacity of burning cinematic lowered by 50%

* Umbra
    * Opacity of burning cinematic lowered by 50%

<br/>

# CompMod 3.2 - (04/08/2020)
## Alien
* BileBomb
    * Research changed to Biomass 2 from Biomass 3
* Spores
    * Opacity of cloud lowered by 50%

## Marine
* MACs
    * Supply cost increased to 15 from 5
* Structures
    * Observatory
        * Supply cost increased to 30 from 25
    * Robotics Factory
        * ARC Factory upgrade cost lowered to 10 tres from 15 tres
        * Supply cost increased to 15 from 5
    * Sentry
        * Supply cost increased to 15 from 10
        * Cost increased to 6 tres from 5 tres
        * Confusion from Spores
            * Duration increased to 8 seconds from 4 seconds
            * Time until next attack increased to 4 seconds from 2 seconds
    * Sentry Battery
        * Cost increased to 12 tres from 10 tres
        * Supply cost increased to 25 from 15

## Bug Fixes
* Fixed that Shotguns could only be dropped from an Armory
* Fixed that HMGs could only be dropped from an Advanved Armory
* Fixed that vampirism didn't apply shielding effect added in vanilla

<br/>

# CompMod 3.1.1 - (30/07/2020)
## Alien
* Lifeforms
    * Gorge
        * Web
            * Web charges lowered to 0 from 1

## Marine
* MAC
    * Cost
        * Cost reduced to 3 tres from 5 tres

<br/>

# CompMod 3.1.0 - (30/07/2020)
## Alien
* Lifeforms
    * Gorge
        * Web
            * Webbed duration lowered to 2.5 seconds from 5 seconds
            * Web charges lowered to 1 from 3

* Upgrades
    * Aura
        * Max range decreased to 20 from 30 (to 6.67 per veil from 10 per veil)

## Marine
* ARCs
    * Health
        * Health lowered to 2200/400 from 2600/400

* Munitions
    * Research cost increased to 35 tres from 25 tres 
    * Research time increased to 90 seconds from 45 seconds
    * Research moved to Armory, guns can be purchased from Armory after researching

* Structures
    * Advanced Armory
        * Health lowered to 2000/200 from 3000/200
        * Research time lowered to 45 seconds from 60 seconds
        * Demolitions
            * Research time decreased to 30 seconds from 45 seconds
    * PrototypeLab
        * Cost reduced to 25 from 35
    * RoboticsFactory
        * Cost reduced to 5 from 10
        * ARC Factory upgrade cost increased to 15 from 5
        * Removed Armory requirement for ARC Factory upgrade


# CompMod 3.0.3 - (28/06/2020)
* Fixed script errors when a fade model is created

<br/>

# CompMod 3.0.2 - (19/06/2020)
## Global
* Fixed script errors when using NanoShield.

<br/>

# CompMod 3.0.1 - (18/06/2020)
## Global
* Fixed script errors when using advanced metabolise

<br/>

# CompMod 3.0.0 - (13/5/2020)
## Alien
* Lifeforms
    * Skulk
        * Bite Cone
            * Increase bite cone height to 1.2 from 1.0 to align with vanilla b332
            * Removed reduction of outer edge of bite cone
    * Gorge
        * Webs
            * Imported vanilla b332 mechanical changes
            * HP gain per charge to 5 from 10
    * Lerk
        * Spikes
            * Imported vanilla b332 method of penetrating soft targets
* Upgrades
    * Vampirism
        * Imported vanilla b332 mechanical changes (shield generation)

## Marine
* Weapons
    * Shotgun
        * Truncated cone (shouldn't hit things behind/in you)
    * Mines
        * Imported vanilla b332 mechanical changes
        * Limit capacity to 1 from 2
        * Cost reduced to 5 from 10

<br/>

# CompMod 2.18.2 - (21/4/2020)
## Alien
* Correctly require biomass 6 for spores

## Marine
* Correct AdvancedArmory research cost to 15 from 10

<br/>

# CompMod 2.18.1 - (20/4/2020)
## Global
* Fix spawn view angle bug.. maybe? (Thanks Beige!)

## Alien
* Require Metabolize before you can research Advanced Metabolize

<br/>

# CompMod 2.18.0 - (19/4/2020)
## Alien
* Decreased height check for tunnel placement
    * This should resolve the issues with placement on Jambi. Please note and report if check is too lenient/allows unacceptable tunnel locations

<br/>

# CompMod 2.17.1 - (16/4/2020)
## Marine
* Structures
    * Armory
        * Shotgun research removed
        * Advanced Armory
            * Research cost to 10 tres from 25 tres
            * Research time to 60 seconds from 90 seconds
            * Added new research 'Munitions'
                * Research cost 25 tres
                * Research time 45 seconds
                * Unlocks Shotgun and Heavy Machine Gun purchase from the Advanced Armory
            * Added new research 'Demolitions'
                * Research cost 15 tres
                * Research time 45 seconds
                * Unlocks Flamethrower and Grenade Launcher purchase from the Advanced Armory
* Updated tech tree to reflect above changes

<br/>

# CompMod 2.17.0 - (16/4/2020)
## Alien
* Skulk
    * Leap
        * Energy cost to 55 from 45
* Gorge
    * Pres cost to 10 from 8
    * Babblers
        * Reduced spawn rate to 3 sec/babbler from 2.5 sec/babbler
* Lerk
    * Pres cost to 21 from 20
    * Health to 180/30 from 180/25
    * Spores
        * Requires biomass 6 from 5
* Fade
    * Advanced Metab
        * Requires biomass to 5 from 4
* Drifter
    * Reduced uncloak radius from 7 to 5
* Upgrades
    * Regeneration
        * Reduced from 8% per tick to 6% per tick
        * Removed heal effect (visual and audio)

## Marine
* Advanced Assistance
    * Research cost reverted to 20 from 25
* Weapons
    * Shotgun
        * Base damage to 10 per pellet (170 total) from 8.824 (150 total)
        * Reduced weapon upgrade scaling to 5.9% per upgrade from 10% (Damage is now 170, 180, 190, 200)
    * HMG
        * Reduced damage to 7 from 8
        * Increased reload speed to 3.5s from 4.5s (The sound does not match the animation currently)

<br/>

# CompMod 2.16.0 - (20/2/2020)
## Alien
* Fade
    * Advanced Swipe
        * Fixed a bug where fade would lose advanced swipe when losing biomass 7

<br/>

# CompMod 2.15.0 - (20/2/2020)
## Alien
* Softcap healing above 14% in a short period of time - more healing is applied at 50% value (Thanks Ghoul)
* Fixed bug where armor healing was reduced
* Vampirism
    * Refactored code to keep armor healing at eHP rate
* Advanced Metabolize
    * Refactored code to keep armor healing at eHP rate

<br/>

# CompMod 2.14.4 - (2/2/2020)
## Alien
* Lerk
    * Really fixed inflated spike accuracies

<br/>

# CompMod 2.14.3 - (1/2/2020)
## Alien
* Lerk
    * Fixed inflated spike accuracies

<br/>

# CompMod 2.14.2 - (31/1/2020)
## Alien
* Lerk
    * Increased flap grace period
    * Fixed bug with lerk hallucinations

<br/>

# CompMod 2.14.1 - (30/1/2020)
## Alien
* Lifeform Costs
    * Correct Lerk cost to 20 from 18

<br/>

# CompMod 2.14.0 - (27/1/2020)
## Global
* Decreased Pres income rate to 1 res per resource tower per minute from 1.25 res per resource tower per minute

## Alien
* Drifter
    * Reduced hover height to 1 from 1.2 so they don't float in marine's faces
    * Shade hive drifters will now uncloak from further away (to 7 from 1.5) (You won't run through without seeing them anymore)
    * Abilities
        * Hallucinations
            * Reduced hallucination drifter's hover height to match real drifter
* Skulk
    * Bite cone
        * Reduced width of cone to 0.8 from 1.2
        * Reduced Height of cone to 1.0 from 1.2
    * Movement
        * Reduced kWallJumpForce to 5 from 6.4
            * The velocity gained while wallhopping scales with this variable and how fast you are going
            * This results in taking ~1.5 more jumps to reach top speed
* Lerk
    * Air friction value remains equal to vanilla friction (0.08) for 0.64 seconds after flapping
    * After 0.64 seconds, scale friction value linearly from 0.08 to 0.5 over 3.36 seconds (total of 4 seconds)
        * This change minimizes the effectiveness of silent lerk ambushes. A lerk will have to flap in order to quickly catch a marine
        * Lerk movement mid-fight while flapping often is unaffected
* Increased starting Pres to 15 from 12
* Lifeform Costs
    * Gorge to 8 from 10
    * Lerk to 18 from 21
    * Fade to 35 from 37
    * Onos to 55 from 62

## Marine
* Increased starting Pres to 20 from 15

## Alien Commander
* Cysts
    * Shade hive cysts are now visible from further away (to 10 from 6)

<br/>

# CompMod 2.13.0 - (23/1/2020)
## Alien
* Lerk
    * Spikes penetrate soft targets

<br/>

# CompMod 2.12.0 - (16/1/2020)
## Alien
* Skulk
    * Reduced range of outer bite cone by 65%
* Fade
    * Tweaked movement when traveling faster than base blink speed
        * Will lose velocity more quickly when moving faster than 16.25
        * Rate at which you lose velocity is reduced when using celerity
* Hallucinations
    * No longer affected by mucous
    * Can no longer have babblers attached
    * Reduced Onos HP to 100 eHP

<br/>

# CompMod 2.11.2 - (11/1/2020)
## Marine
* Hotfix HMG reload speed bug

<br/>

# CompMod 2.11.1 - (10/1/2020)
## Alien
* Hotfix Fade blink speed

<br/>

# CompMod 2.11.0 - (8/1/2020)
## Alien
* Mucous
    * Reduced cloud radius from 8 to 5 (reduces area by 60%)
    * Shield matches babbler shield values (except skulk - remains at 15 hp)
* Babblers
    * Are flammable (die in one welder tick)
* Skulk
    * Can longer jump at various heights from the floor
    
## Marine
* HMG
    * Decrease clip size to 100 rounds
    * Increase reload speed to 4.5s from 5.0s
    * Can no longer interrupt reload with secondary fire

<br/>

# CompMod 2.10.0 - (5/1/2020)
## Alien
* Babblers no longer scale with biomass
* Vampirism value reduced to 2 shell vanilla values on Skulk and Fade

## Marine
* Increased shotgun damage to 150 from 140

<br/>

# CompMod 2.9.0 - (5/12/2019)
## Spectator
* Added team supply to top bar
* Fixed edge pan jitter when following a player -- click to unfollow
* Advanced Swipe will now appear in the researched tech at the bottom of the screen
* Removed Carapace from Alien Tech Map
* Defaulted help text at bottom of the screen to a collapsed state

## Alien
* Removed Carapace from Alien Tech Map

<br/>

# CompMod 2.8.8 - (28/11/2019)
## Alien
* Vampirism now heals eHP rather than by point value (this is a nerf)

<br/>

# CompMod 2.8.7 - (14/11/2019)
## Global
* Update for build 331

<br/>

# CompMod 2.8.6 - (11/11/2019)
## Marine
* Shotgun
    * Fire rate reverted to vanilla
    * Aggregate damage changed to 140
* Flamethrower
    * Removed friendly fire of flame puddles

## Alien
* Echo
    * Echo upgrade cost increased to 2 from 1
    * Echo egg cost reduced to 1 from 2
* Lerk
    * Increase lerk strafe force to 8.3 from 7
    * Spike damage increased to 6 from 5 (to 12 from 10 to players)
    * Spike spread increased to 3.8 radians from 3.6 radians (Nostalgia spread was 4.0 radians)

<br/>

# CompMod 2.8.5 - (04/11/2019)
## Marine
* Fixed shotgun fire rate while moving
* Mines can now be killed before arming

## Alien
* No longer cloaked while moving with camouflage
* Skulk sneak speed reduced to 4 from 4.8
* Skulks no longer get a speed bonus on their first jump from the ground

<br/>

# CompMod 2.8.4 - (27/10/2019)
## Marine
* Fixed expiration timer bug where a large amount of time can be added
* Shotgun base aggregate damage reduced to 130 from 170
* Shotgun rate of fire increased to 1.49 from 1.14
* Fixed bug where multiple IPs would spawn

## Alien
* Skulk model/hitbox size reduced by 10%
* Fade no longer gets bonuses from successive blinks without celerity

<br/>

# CompMod 2.8.3 - (15/10/2019)
## Marine
* Mine damage reduced to 130 normal damage (from 150)
* Advanced Assistance Tres cost increased to 25 from 20
* Reduced NanoShield duration on players to 2s from 4s
* Pistol damage to Normal type
* Pistol damage to 20 normal damage from 25 light damage
* Heavy Machine Gun reload is now cancel-able with alt-fire

<br/>

# CompMod 2.8.2 - (12/10/2019)
## Marine
* Nanoshield duration on players reduced to 4 seconds (from 5)
* Standing near a weapon slows decay rate by 50%
* Shotgun changed to nostalgia code (hotfix to fix damage bug - 13/10/2019)

<br/>

# CompMod 2.8.1 - (09/10/2019)
## Alien
* Removed Fade autocrouch

## Marine
* Grenades are deploy instantly again
* Shotgun spread to nostalgia spread approximated in new spread code

<br/>

# CompMod 2.8.0 - (01/10/2019)  
## Alien
* Removed Carapace again
* Removed Onos Charge Knockback

<br/>

# CompMod 2.7.7 - (12/08/2019)
## Alien
* Carapace
    * It's back.

<br/>

# CompMod 2.7.6 - (11/08/2019)
## Marines
* Shotgun
    * Shotgun pellet size changed to 32mm from 60mm

<br/>

# CompMod 2.7.5 - (10/08/2019)
## Marines
* Shotgun
    * Shotgun pellet size changed from 66mm to 60mm.

<br/>

# CompMod 2.7.4 - (09/08/2019)
## Marines
* Shotgun
    * Fixed an issue that caused the pellet changes to not be applied correctly. 

<br/>

# CompMod 2.7.3 - (09/08/2019)
## Marines
* Observatory
    * Changed build time to 10 seconds from 15 seconds
* Shotgun
    * Outer ring pellet size changed to 66mm from 16mm
* Cluster Grenades
    * Changed Cluster Grenades player damage reduction to 50%

## Alien
* Carapace
    * Deleted carapace.

<br/>

# CompMod 2.7.2 - (09/08/2019)
## Marines
* Medpacks
    * Marines now keep the HoT effect even when they're full HP for the full duration of the Medpack. Medpacks cannot overheal.
    * The result is that Marines can take damage after receiving a Medpack and still benefit from the HoT buff, even if they were already healed to full HP. 

## Aliens
* Lerk
    * Lerk HP changed to 180/25 from 180/30
   
## Spectators
* Added display for team supply.

## Bug Fixes and Improvements
* Fix carapace being shown incorrectly in spectate view.
* Fix mucous hitsounds.
* Fix Vampirism doing friendly fire.
* Fixed that Cluster Grenades were not having the FlameAble multiplier applied.
* Fixed that the commander actions panel would overlap with the supply display on a Marine's HUD
* Fixed that the scoreboard would sometimes be slow to open.

<br/>

# CompMod 2.7.1 - (01/08/2019)
* Implement ns2_beta rev 3 hotfix
    * Fade's can't zoom zoom on the floor anymore

<br/>

# CompMod 2.7.0 - (01/08/2019)
* Implement ns2_beta Revision 3
* Weapon Lifetime
    * Reduced weapon lifetime to 18 seconds from 25 seconds
    * Stepping on a dropped weapon no longer refreshes the weapon timer
* Mucous Membrane
    * Added hitsounds for Aliens with mucous
* PowerNodes
    * Removed the flashlight requirement for finish power nodes without a structure in the room

<br/>

# CompMod 2.6.5 - (30/07/2019)
* Pulse Grenade Hotfix
	* Damage lowered to 50 from 140

<br/>

# CompMod 2.6.4 - (27/07/2019)
* Fade Blink Hotfix (Again :D)
    * Revert Fade blink speed to 17
    * Lower blink initial force to 14.25 from 15
* PowerSurge
    * Fixed that PowerSurge was acting like vanilla.

<br/>

# CompMod 2.6.3 - (27/07/2019)
* Fade Blink Hotfix
    * Lowered Fade blink speed to 16.25 from 17

<br/>

# CompMod 2.6.2 - (26/07/2019)
* Walk
    * Fixed that marine walk couldn't be rebound.
    * Walk bind will be reset to default after this patch.

<br/>

# CompMod 2.6.1 - (25/07/2019)
* Fixed a bug that caused a ghost entity to remain after a mine was destroyed while arming.
* Fixed a bug that caused mines to detonate after being destroyed

<br/>

# CompMod 2.6.0 - (25/07-2019)
* Stab replaced by Advanced Swipe
    * Upgrades the normal swipe damage to 81 from 75
    * Can be researched at Biomass 7 
    * Costs 25 tres and takes 60 seconds to research
* Team supply is now visible on the player HUD
* Stomp 
    * Research cost changed to 35 from 25
    * Research time changed to 90 from 60
* BoneShield
    * Now consumes BoneFuel faster when moving
    * Added a small initial cost to casting BoneShield
* Improved Grenade Quick Throw
    * Implements an improved version of the grenade quick throw found in ns2_beta
    * Allows Marines to throw the grenade instantly, without waiting for the deploy animations.
* Heal sound will no longer play when shells are built.

## Bug Fixes
* Drifters can pop blueprints again
* Killfeed shows for spectators and readyroom players again

<br/>

# CompMod 2.5.0 - (28/06/2019)
* Potential fix for view angles being set incorrectly on spawn 
* Cysts should no longer starve when they shouldn't
* Cysts should be able to find their parents more reliably when the chain is updated
* Harvesters now take 60 seconds to die off infestation down from 90 seconds.
* Alien Supply Changes
    * Drifter costs 5 from 10
    * Whip costs 10 from 5
    * Crag costs 25 from 5
    * Shift costs 25 from 5
    * Shade costs 25 from 5
* Marine Supply Changes
    * MAC costs 5 from 10
    * Armory costs 0 from 5
    * ARCs cost 25 from 35
    * Robotics Factory costs 0 from 5
    * Sentry Battery costs 10 from 0
    * Observatory costs 40 from 0
* Stomp
    * Research cost increased to 35 from 25
    * Research time increased to 90 seconds from 60 seconds
* Advanced Metabolise requires biomass 4 (from 5)
* Spores require biomass 5 (from 4)
* Power Surge
    * No longer slows and damages aliens
