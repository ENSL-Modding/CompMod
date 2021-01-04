<div style="width:100%;background-color:#373737;color:#FFFFFF;text-align:center">
<div style="display:inline-block;float:left;padding-left:20%">
<a href="revision2">
[ <- Previous ]
</a>
</div>
<div style="display:inline-block;">
Revision 3
</div>
<div style="display:inline-block;float:right;padding-right:20%">
<a href="revision4">
[ Next -> ]
</a>
</div>
</div>

<br />

# CompMod revision 3 - (04/01/2021)
## Alien

### Crag
* Healing
  * Implement per-lifeform heal values (I assume this means we're removing min/max heal clamps for lifeforms?)
  * Added per-lifeform heal, removing the min/max heal clamps for lifeforms
  * Healing values:
    * Skulk: 10 (13%) up from 7
    * Gorge: 15 (9%) up from 11
    * Lerk: 16 (9%) up from 10
    * Fade: 25 (10%) up from 17
    * Onos: 80 (11%) up from 42

### Fade
* Movement
  * Blink will no longer take into account the Fade's momentum
  * Blink will give 16.25 speed in the direction the Fade is facing
  * Will lose velocity more quickly when moving faster than 16.25
  * Rate at which you lose velocity is reduced when using Celerity

### Healing Cap
* Decreased healing softcap to 12% from 14%
* Increased additional healing penalty to 80% from 66%

### Upgrades
* Neurotoxin
  * Fixed friendly fire bug

## Marine

### Medpack
* Increased instant heal amount to 40 from 25
* Decreased HoT amount to 10 from 25
* Decreased snap radius to match AmmoPack
* Increased pickup delay to 0.6 seconds from 0.45 seconds
