# NSL Competitive Mod
A Natural Selection 2 balance and feature mod used by the [ENSL](https://www.ensl.org).

# Mission statement
The vision of the Natural Selection League (NSL) Competitive Modification (CompMod) is to enable fun, fair and balanced play in a 6 vs 6 environment, while remaining as accessible to new players as possible.
To do this the team commits to remaining transparent in all changes, to be open to discussion, feedback and criticism, and above all else, to strive to attain enjoyable play for all members of the competitive community, regardless of skill level. 

# Changes
For a full list of changes from vanilla see [here](changes "CompMod ChangeLog").

CompMod utilizes the changes made in [ns2_beta](https://github.com/taekwonjoe01/ns2_beta "NS2 Beta Github Repository"). 

The included version of ns2_beta is Revision 2, the changes for which can be found [here](ns2_beta_rev2 "NS2 Beta Revision 2 Changes")

# Recent Changes
## 25/07-2019 (CompMod 2.6.0)
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

## 28/06/2019 (CompMod 2.5.0)
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