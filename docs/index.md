# NSL Competitive Mod
A Natural Selection 2 balance and feature mod used by the [ENSL](https://www.ensl.org).

# Mission statement
The vision of the Natural Selection League (NSL) Competitive Modification (CompMod) is to enable fun, fair and balanced play in a 6 vs 6 environment, while remaining as accessible to new players as possible.
To do this the team commits to remaining transparent in all changes, to be open to discussion, feedback and criticism, and above all else, to strive to attain enjoyable play for all members of the competitive community, regardless of skill level. 

# Changes
For a full list of changes from vanilla see [here](changes "CompMod ChangeLog").
To see the full CompMod changelog see [here](full_changelog "CompMod Full Changelog")

CompMod utilizes the changes made in [ns2_beta](https://github.com/taekwonjoe01/ns2_beta "NS2 Beta Github Repository"). 

The included version of ns2_beta is Revision 3, the changes for which can be found [here](ns2_beta_rev3 "NS2 Beta Revision 2 Changes")

# Recent Changes
## CompMod 2.7.2-beta1 - (07/08/2019)
##### Marines
* Medpacks
    * Marines now keep the HoT effect even when they're full HP for the full duration of the Medpack. They cannot overheal.
    * The result is that Marines can take damage after receiving a Medpack and still benefit from the HoT buff, even if they were already healed to full HP. 

##### Aliens
* Lerk
    * Lerk HP changed to 180/25 from 180/30
   
##### Spectators
* Added display for team supply.

##### Bug Fixes
* Fix carapace being shown incorrectly in spectate view.
* Fix mucous hitsounds.
* Fix Vamparism doing friendly fire.
* Fixed that Cluster Grenades were not having the FlameAble multiplier applied.
* Fixed that the commander actions panel would overlap with the supply display on a Marine's HUD

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
