function GetModConfig(kLogLevels)
	local config = {}

	config.kLogLevel = kLogLevels.info
	config.kShowInFeedbackText = true
	config.kModVersion = "1"
	config.kModBuild = "1"

	config.modules =
	{
		-- Alien Changes
		"Alien/Eggs",
		"Alien/Healing",
		"Alien/Pres",

		-- Lifeforms
		"Alien/Lifeforms/Fade",
		"Alien/Lifeforms/Gorge",
		"Alien/Lifeforms/Lerk",
		"Alien/Lifeforms/Onos",

		-- Upgrades
		"Alien/Upgrades/Adrenaline",
		"Alien/Upgrades/Aura",
		"Alien/Upgrades/Camouflage",
		"Alien/Upgrades/Focus",
		"Alien/Upgrades/Neurotoxin",

		-- Commander Changes

		-- Alien Commander
		"Commander/Alien/Biomass",
		"Commander/Alien/Cyst",
		"Commander/Alien/Drifter",
		"Commander/Alien/Echo",
		"Commander/Alien/LifeformEggs",
		"Commander/Alien/NutrientMist",
		"Commander/Alien/Structures",
		"Commander/Alien/SupplyChanges",

		-- Global Commander Changes
		"Commander/Global/SupplyChanges",

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
		"Marine/AxeFix",
		"Marine/GunDropTime",
		"Marine/Jetpack",
		"Marine/Pres",
		"Marine/PrototypeLab",
		"Marine/WeldSpeed",

		-- Weapons
		"Marine/Weapons/Flamethrower",
		"Marine/Weapons/Grenades",
		"Marine/Weapons/HMG",
		"Marine/Weapons/Mine",
		"Marine/Weapons/Shotgun",
	}

	return config
end
