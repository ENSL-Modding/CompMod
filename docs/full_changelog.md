# Full Changelog for CompMod

## CompMod 2.8.3 - (15/10/2019)
##### Marine
* Mine damage reduced to 130 normal damage (from 150)
* Advanced Assistance Tres cost increased to 25 from 20
* Reduced NanoShield duration on players to 2s from 4s
* Pistol damage to Normal type
* Pistol damage to 20 normal damage from 25 light damage
* Heavy Machine Gun reload is now cancel-able with alt-fire

## CompMod 2.8.2 - (12/10/2019)
##### Marine
* Nanoshield duration on players reduced to 4 seconds (from 5)
* Standing near a weapon slows decay rate by 50%
* Shotgun changed to nostalgia code (hotfix to fix damage bug - 13/10/2019)

## CompMod 2.8.1 - (09/10/2019)
##### Alien
* Removed Fade autocrouch

##### Marine
* Grenades are deploy instantly again
* Shotgun spread to nostalgia spread approximated in new spread code

## CompMod 2.8.0 - (01/10/2019)  
##### Alien
* Removed Carapace again
* Removed Onos Charge Knockback

## CompMod 2.7.7 - (12/08/2019)
##### Alien
* Carapace
    * It's back.

## CompMod 2.7.6 - (11/08/2019)
##### Marines
* Shotgun
    * Shotgun pellet size changed to 32mm from 60mm
    
## CompMod 2.7.5 - (10/08/2019)
##### Marines
* Shotgun
    * Shotgun pellet size changed from 66mm to 60mm.

## CompMod 2.7.4 - (09/08/2019)
##### Marines
* Shotgun
    * Fixed an issue that caused the pellet changes to not be applied correctly. 

## CompMod 2.7.3 - (09/08/2019)
##### Marines
* Observatory
    * Changed build time to 10 seconds from 15 seconds
* Shotgun
    * Outer ring pellet size changed to 66mm from 16mm
* Cluster Grenades
    * Changed Cluster Grenades player damage reduction to 50%

##### Alien
* Carapace
    * Deleted carapace.
    
## CompMod 2.7.2 - (09/08/2019)
##### Marines
* Medpacks
    * Marines now keep the HoT effect even when they're full HP for the full duration of the Medpack. Medpacks cannot overheal.
    * The result is that Marines can take damage after receiving a Medpack and still benefit from the HoT buff, even if they were already healed to full HP. 

##### Aliens
* Lerk
    * Lerk HP changed to 180/25 from 180/30
   
##### Spectators
* Added display for team supply.

##### Bug Fixes and Improvements
* Fix carapace being shown incorrectly in spectate view.
* Fix mucous hitsounds.
* Fix Vampirism doing friendly fire.
* Fixed that Cluster Grenades were not having the FlameAble multiplier applied.
* Fixed that the commander actions panel would overlap with the supply display on a Marine's HUD
* Fixed that the scoreboard would sometimes be slow to open.

## CompMod 2.7.1 - (01/08/2019)
* Implement ns2_beta rev 3 hotfix
    * Fade's can't zoom zoom on the floor anymore
    
## CompMod 2.7.0 - (01/08/2019)
* Implement ns2_beta Revision 3
* Weapon Lifetime
    * Reduced weapon lifetime to 18 seconds from 25 seconds
    * Stepping on a dropped weapon no longer refreshes the weapon timer
* Mucous Membrane
    * Added hitsounds for Aliens with mucous
* PowerNodes
    * Removed the flashlight requirement for finish power nodes without a structure in the room

## CompMod 2.6.5 - (30/07/2019)
* Pulse Grenade Hotfix
	* Damage lowered to 50 from 140

## CompMod 2.6.4 - (27/07/2019)
* Fade Blink Hotfix (Again :D)
    * Revert Fade blink speed to 17
    * Lower blink initial force to 14.25 from 15
* PowerSurge
    * Fixed that PowerSurge was acting like vanilla.

## CompMod 2.6.3 - (27/07/2019)
* Fade Blink Hotfix
    * Lowered Fade blink speed to 16.25 from 17

## CompMod 2.6.2 - (26/07/2019)
* Walk
    * Fixed that marine walk couldn't be rebound.
    * Walk bind will be reset to default after this patch.

## CompMod 2.6.1 - (25/07/2019)
* Fixed a bug that caused a ghost entity to remain after a mine was destroyed while arming.
* Fixed a bug that caused mines to detonate after being destroyed

## CompMod 2.6.0 - (25/07-2019)
* Stab replaced by Advanced Swipe
    * Upgrades the normal swipe damage to 81 from 70
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

#### Bug Fixes
* Drifters can pop blueprints again
* Killfeed shows for spectators and readyroom players again

## CompMod 2.5.0 - (28/06/2019)
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