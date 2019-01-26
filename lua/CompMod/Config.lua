function GetModConfig(kLogLevels)
	local config = {}

	config.kLogLevel = kLogLevels.info
	config.kShowInFeedbackText = true
	config.kModVersion = "1"
	config.kModBuild = "3.1"
	config.disableRanking = true

	config.modules =
	{
		-- Alien Changes
		"Alien/Babblers",
		"Alien/Eggs",
		"Alien/GorgeTunnel",
		"Alien/Healing",
		"Alien/Pres",

		-- Lifeforms
		"Alien/Lifeforms/Fade",
		"Alien/Lifeforms/Gorge",
		"Alien/Lifeforms/Lerk",
		"Alien/Lifeforms/Onos",
		"Alien/Lifeforms/Skulk",

		-- Upgrades
		"Alien/Upgrades/Adrenaline",
		"Alien/Upgrades/Aura",
		"Alien/Upgrades/Camouflage",
		"Alien/Upgrades/Carapace",
		"Alien/Upgrades/Focus",
		"Alien/Upgrades/Neurotoxin",

		-- Commander Changes

		-- Alien Commander
		"Commander/Alien/Biomass",
		"Commander/Alien/Cyst",
		"Commander/Alien/Drifter",
		"Commander/Alien/Echo",
		"Commander/Alien/HallucinationCloud",
		"Commander/Alien/LifeformEggs",
		"Commander/Alien/MucousShield",
		"Commander/Alien/NutrientMist",
		"Commander/Alien/Structures",
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
		"Global/Bindings",

		-- Marine Changes
		"Marine/AxeFix",
		"Marine/GunDropTime",
		"Marine/Jetpack",
		"Marine/MarineClassChanges",
		"Marine/Observatory",
		"Marine/Pres",
		"Marine/PrototypeLab",
		"Marine/Walk",
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
