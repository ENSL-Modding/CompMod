<div style="width:100%;background-color:#373737;color:#FFFFFF;text-align:center">
<div style="display:inline-block;float:left;padding-left:20%">
<a href="revision6">
[ <- Previous ]
</a>
</div>
<div style="display:inline-block;">
Revision 7
</div>
<div style="display:inline-block;float:right;padding-right:20%">
<a href="revision8">
[ Next -> ]
</a>
</div>
</div>

<br />

# CompMod revision 7 - (10/01/2021)
## Alien

### Bile Mine
* Renamed to Toxic Mine
* Changed damage type to normal from corrosive
* Lowered damage to 40 from 125

### Gorge
* Babblers
  * Lowered health to 11 from 12

### Innate Regen
* Increased out of combat timer to 5 seconds from 3 seconds
* Increase Skulk innate regen rate by 100%

### Lerk
* Roost
  * Added Roost
  * When Lerks perch on a surface they will silently heal for 2.2% of max HP per second
  * Costs 10 tres to research and requires Biomass 2
* Umbra
  * Increased research cost to 30 from 20

### Onos
* Stomp
  * Increased Stomp damage to 60 from 40
  * Removed knockdown effect

### Structures
* Cyst
  * Lowered damage bonus from welders to 5x from 7x
* Shift
  * Echo
    * Hives can now be echoed for 50 tres

### Upgrades
* Regeneration
  * Upgrade removed
* Scavenger
  * Added new Trait Scavenger to the Crag hive
  * When a Marine is killed their lifeforce is scavenged by the attacking lifeforms
  * Lifeforms will heal proportionally based on how much damage they contributed to kill the Marine, up to a maximum value
  * Max Heal Values
    * Skulk: 30
    * Gorge: 50
    * Lerk: 60
    * Fade: 120
    * Onos: 300
  * The max heal values will increase with Biomass to scale in effectiveness as the game progresses
  * The heal is applied in 3 chunks over 5 seconds
    * In other words: one third of the total heal is applied every 1.67s three times
  * Only the damage contributed through primary attacks will count towards the heal bonus
  * Only damage done in the last 10 seconds will count towards the heal bonus
* Tenacity
  * Added new Trait Tenacity to the Crag Hive
  * Increases out of combat healing by 20%
  * Increases in combat healing by 5%
  * Increases innate regen by 50%

### Fade
* Movement
  * Reverted all movement changes to vanilla values

## Marine

### Medpack
* Increased instant heal amount to 50 from 40
* Decreased HoT amount to 0 from 10
* Decreased pickup delay to 0.55 seconds from 0.6 seconds

## Fixes & Improvements

### Status Icons
* Enabled all status icons regardless of HUD detail setting. Previously would only show on High detail

<br/>

