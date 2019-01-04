-- i wonder if this will still work with multiple mods using the framework
-- prolly not but hey :)

Mod.config.kLogLevel = 4
Mod.config.kShowInFeedbackText = true
Mod.config.kModVersion = "0"
Mod.config.kModBuild = "1"

Mod.config.modules =
{
	-- Alien Changes
	"Alien/Eggs",
	"Alien/Fade",
	"Alien/Gorge",
	"Alien/Lerk",
	"Alien/Onos",
	"Alien/Pres",

	-- Commander Changes
		-- Alien Commander
		"Commander/Alien/LifeformEggs",
		"Commander/Alien/SupplyChanges",

		-- Marine Commander
		"Commander/Marine/ARCBugFix",
		"Commander/Marine/ARCSpeedBoost",
		"Commander/Marine/CatPacks",
		"Commander/Marine/Medpack",
		"Commander/Marine/NanoShield",
		"Commander/Marine/SupplyChanges",

	-- Global Changes
	"Global/HealthBars",

	-- Marine Changes
	"Marine/GunDropTime",
	"Marine/Jetpack",
	"Marine/Pres",
	"Marine/WeldSpeed",

		-- Weapons
		"Marine/Weapons/Flamethrower",
		"Marine/Weapons/Grenades",
		"Marine/Weapons/HMG",
		"Marine/Weapons/Mine",
		"Marine/Weapons/Shotgun",
}
