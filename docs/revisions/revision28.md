<div style="width:100%;background-color:#373737;color:#FFFFFF;text-align:center">
<div style="display:inline-block;float:left;padding-left:20%">
<a href="revision27">
[ <- Previous ]
</a>
</div>
<div style="display:inline-block;">
Revision 28
</div>
<div style="display:inline-block;float:right;padding-right:20%">
[ Next -> ]
</div>
</div>

<br />

# CompMod revision 28 - (22/01/2023)
## Alien

### Commander Abilities
* Adrenaline Rush
  * Costs 3 tres to cast
  * == REMOVED == Costs 3 tres

### Drifters
* Increased Drifter detection range to 5 from 3
  * This will cause Drifters to uncloak from further away
* == REMOVED == Reduced hover height to 1 from 1.2 so they don't float in Marine's faces
* == REMOVED == Drifters cloaked by Shade hive upgrade will now uncloak from further away (to 5 from 1.5)
* Abilities
  * Enzyme
    * Decreased cooldown to 1 second from 3 seconds
    * == REMOVED == Reduced cooldown from 12 seconds to 1 second
  * Mucous
    * Decreased cooldown to 1 second from 3 seconds
    * Added per-lifeform shield values:
      * Skulk: 20% of base health
      * Gorge: 13% of base health
      * Lerk: 14% of base health
      * Fade: 16% of base health
      * Onos: 9% of base health
    * == REMOVED == Reduced cooldown to 1 second from 12 seconds
    * == REMOVED == Reduced cloud radius from 8 to 5 (reduces area by 60%)
    * == REMOVED == >Skulk: 20% (15 HP)
    * == REMOVED == >Gorge: 13% (20 HP)
    * == REMOVED == >Lerk: 14% (24 HP)
    * == REMOVED == >Fade: 16% (40 HP)
    * == REMOVED == >Onos: 9% (63 HP)

### Fade
* Advanced Swipe
  * Increases Swipe damage by 8%
  * == REMOVED == Upgrades the normal swipe damage to 81 from 75
* Swipe
  * Damage
    * Increased damage to 75 from 37.5
    * Changed damage type to StructuresOnlyLight from Puncture
  * == REMOVED == Tweaked damage
  * == REMOVED == >Swipe damage increased to 75 from 37.5
  * == REMOVED == >Swipe damage type changed to StructuresOnlyLight from Puncture
* Blink
  * == REMOVED == Lowered Blink energy cost to 12 from 14

### Gorge
* Babblers
  * Decreased health to 11 from 12
  * Increased spawn rate to 3 seconds from 2.5 seconds
  * == REMOVED == Lowered health to 11 from 12
  * == REMOVED == Reduced spawn rate to 3sec/babbler from 2.5sec/babbler
* Web
  * Decreased health gain per charge to 5 from 10
  * Decreased Web charges to 0 from 3
  * Decreased webbed duration to 2.5 seconds from 5 seconds
  * == REMOVED == HP gain per charge to 5 from 10
  * == REMOVED == Web charges lowered to 0 from 3
  * == REMOVED == Webbed duration lowered to 2.5 seconds from 5 seconds
* Spit
  * == REMOVED == Increased Gorge spit speed to 43 from 35

### Healing Cap
* Decreased additional healing after softcap to 80% from 66%
* == REMOVED == Decreased healing softcap to 12% from 14%
* == REMOVED == Additional healing after soft cap increased to 80% reduction from 66%

### Crag
* Healing
  * == REMOVED == Implement per-lifeform heal values

### Lerk
* Spikes
  * == REMOVED == Size reduced to 45mm from 60mm
* Umbra
  * == REMOVED == Increased research cost to 30 from 20

### Structures
* Shift
  * Echo
    * == REMOVED == Echo cost for upgrades increased to 2 from 1
    * == REMOVED == Echo cost for eggs reduced to 1 from 2
* Tunnels
  * == REMOVED == Tunnel cost changed to 8 tres from 6 tres

### Upgrades
* Adrenaline
  * == REMOVED == Removed additional energy pool from Adrenaline
* Regeneration
  * == REMOVED == Reduced from 8% per tick to 6% per tick
* Vampirism
  * == REMOVED == Lowered Lerk vampirism percentage to 2% from 2.67% per shell

## Marine

### Structures
* AdvancedArmory
  * Decreased health to 2000 from 3000
  * == REMOVED == Health decreased to 2000/200 from 3000/200
* Observatory
  * == REMOVED == Changed build time to 10 seconds from 15 seconds
* Prototype Lab
  * == REMOVED == Cost reduced to 25 from 35
* Robotics Factory
  * == REMOVED == ARC Factory upgrade cost increased to 15 tres from 5 tres

### Supply
* == REMOVED == MAC supply cost increased to 15 from 5
* == REMOVED == Sentry supply cost increased to 15 from 10
* == REMOVED == Sentry Battery supply cost increased to 25 from 15

### Weapons
* Heavy Machine Gun
  * == REMOVED == Reduced damage to 7 from 8
  * == REMOVED == Lowered spread to 3.2 degrees from 4 degrees

## Global

### Resources
* == REMOVED == Decreased Pres income rate to 1 res per resource tower per minute from 1.25 res per resource tower per minute
* == REMOVED == Increased Alien starting pres to 15 from 12
* == REMOVED == Increased Marine starting pres to 20 from 15

## Fixes & Improvements

### Hallucinations
* Hallucination Lerks will no longer use Umbra or Spores

<br/>

