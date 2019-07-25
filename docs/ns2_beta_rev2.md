# NS2 Beta Balance
**SteamWorks Mod ID**: *6ba7131e*

This mod contains various balance changes based on various ideas of the NS2 balance team.

Join the official ns2 discord server (discord.gg/ns2) to leave feedback!

## Latest Changes (Revision 2)

- Fade
    - Blink's initial cast (when you first activate ability) will now cancel All velocity across all axis' (used to only cancel Up/Down velocity)
    - Blink initial cast speed set to 17 (up from ~15.6)
    - Removed spurs reducing Air friction for fade. Originally this reduced 0.01 air friction per spur. Fade air friction is 0.17.

- Lerk
    - New Ability: Roost. When a lerk is perched on a wall, they will heal 5HP per second.
        - Roost costs 10 Team resources to research
        - Roost unlocked at biomass 2
        - Research takes 30 seconds
        
- Alien Commander
    - New Ability: Consume. Allows a Khammander to recycle alien structures and return the supply cost. Structures do not return team resources. 
        - Ability is cancelled if orders are given to units that are being consumed.
        - Consume ability cancels any existing orders for the unit.

- Marines
    - New Ability: Grenade Quick Throw. Default button "B" will instantly and quickly throw any grenades the marine has purchased. 
        - Can rebind the button in menu options.
    - Tweaked Shotgun:
        - Damage falloff added. Fall off starts at 6m. Damage of each pellet scales from 100% to 75% between 6m and 12m. After 12 meters, damage is always 75%.
        - Change the spread pattern to 13 (1/5/7) pellets total with variable calibers and damage values:
            - 1 pellet in the very center causing 20 dmg and a caliber of 16 mm
            - 5 pellets with a center offset of 0.5 (inner ring) dealing 16 dmg and and a caliber of 16 mm
            - 7 pellets with a center offset of 1.5 (outer ring) dealing 10 dmg and and a caliber of 150 mm

## All Changes (Compared to Vanilla Build 328)
- Alien
    - Khammander
        - New Ability: Grenade Quick Throw. Default button "B" will instantly and quickly throw any grenades the marine has purchased. 
            - Can rebind the button in menu options.
    - Upgrades
        - Camouflage
            - Now de-cloaks completely at max speed
        - Carapace
            - Decreased armor bonus for skulks to 15 (from 20)
            - Decreased armor bonus for lerks to 20 (from 30)
    - Gorge
        - Webs no longer appear in the kill feed
    - Lerk
        - Changed hp to 190/20 from 150/45 (shifting more hp to health)
        - Spikes
            - Increased spread to 3.6 radius (from 3.1)
            - Deceased spike diameter to 0.045 (from 0.06)
        - Umbra
            - Now requires biomass 6 (up from 5)
            - Decreased damage reduction to 20% (from 25%)
            - Decreased umbra cloud life time to 2.5 seconds (from 4)
        - New Ability: Roost. When a lerk is perched on a wall, they will heal 5HP per second.
            - Roost costs 10 Team resources to research
            - Roost unlocked at biomass 2
            - Research takes 30 seconds
    - Fade
        - Blink's initial cast (when you first activate ability) will now cancel All velocity across all axis' (used to only cancel Up/Down velocity)
        - Blink initial cast speed set to 17 (up from ~15.6)
        - Removed spurs reducing Air friction for fade. Originally this reduced 0.01 air friction per spur. Fade air friction is 0.17.
    - Onos
        - Decreased base health to 700 (from 900)
        - Increased biomass health bonus to 50 (from 30)
        - Increase Boneshield Movement Speed to 4.5 (up from 3.3)
        - Boneshield is now available on Biomass 5 (down from Bio 6)
    - Cyst & Clogs
        - Receive 7x direct damage from welders, flame throwers and cluster grenades (up from 2.5x)
    
- Marine
    - New Ability: Grenade Quick Throw. Default button "B" will instantly and quickly throw any grenades the marine has purchased. 
        - Can rebind the button in menu options.
    - Grenades
        - Cluster
            - Now deals 5x damage vs. flammable structures, 2.5x vs. all other structures.
            - Now sets targets on fire
            - Burns away umbra, spores and bile bombs
        - Nerve Gas
            - Decreased cloud life time to 4.5 seconds (from 6)
            - Decrease grenade max life time to 7.5 seconds (from 10)
        - Pulse
            - Decreased detonation radius decreased to 1 meter (down from 3)
            - Damage increased to 140 (from 110)
    - Machine Gun
        - Decreased player target damage to 12/13/14/15 from 12/13.2/14.4/15.6
    - Shotgun 
        - Damage falloff added. Fall off starts at 6m. Damage of each pellet scales from 100% to 75% between 6m and 12m. After 12 meters, damage is always 75%.
        - Change the spread pattern to 13 (1/5/7) pellets total with variable calibers and damage values:
            - 1 pellet in the very center causing 20 dmg and a caliber of 16 mm
            - 5 pellets with a center offset of 0.5 (inner ring) dealing 16 dmg and and a caliber of 16 mm
            - 7 pellets with a center offset of 1.5 (outer ring) dealing 10 dmg and and a caliber of 150 mm
    - Mines
        - Damage type changed to Normal (from Light)
        - Damage increased to 150 (from 125)
        - HP increased to 50 (from 30)
        - Mines should no longer detonate when killed while deploying
    - Ammo and Cat Pack
        - Now use the same snap radius as the med pack
    - Nano shield
        - Decreased snap radius to 3 m from 6
    - ARC
        - Damage reduced to 530 (from 630)
        - Changed hp to 2600/400 fromm 3000/200 (shifting more hp to armor)
        - Fixed that ARCs didn't save and restore their previous armor value properly when changing their deployment state.
        - Changed ARC's radial damage falloff to use XZ distance (ignore Y (height) axis). So ARCs total damage is consistent and doesn't depend on the height of the main target's model origin.
