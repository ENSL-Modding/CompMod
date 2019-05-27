function GetModConfig(kLogLevels)
	local config = {}

	config.kLogLevel = kLogLevels.info
	config.kShowInFeedbackText = true
	config.kModVersion = "2"
	config.kModBuild = "1.0"
	config.disableRanking = true
	config.use_config = "none"
	config.techIdsToAdd = {
		"Neurotoxin",
		"Consume",
		"ARCSpeedBoost",
	}

	config.modules =
	{
		-- Alien Changes
		"Alien/Eggs",
		"Alien/Webs",

		-- Lifeforms
		"Alien/Lifeforms/Gorge",
		"Alien/Lifeforms/Fade",
		"Alien/Lifeforms/Lerk",
		"Alien/Lifeforms/Onos",

		-- Upgrades
		"Alien/Upgrades/Aura",
		"Alien/Upgrades/Camouflage",
		"Alien/Upgrades/Carapace",
		"Alien/Upgrades/Focus",
		"Alien/Upgrades/Neurotoxin",

		-- Commander Changes

		-- Alien Commander
		"Commander/Alien/Biomass",
		"Commander/Alien/Consume",
		"Commander/Alien/Echo",
		"Commander/Alien/HallucinationCloud",
		"Commander/Alien/LifeformEggs",
		"Commander/Alien/MucousShield",
		"Commander/Alien/NutrientMist",
		"Commander/Alien/SupplyChanges",

		-- Marine Commander
		"Commander/Marine/ARCCorrodeBugFix",
		"Commander/Marine/ARCSpeedBoost",
		"Commander/Marine/ArmsLab",
		"Commander/Marine/Medpack",
		"Commander/Marine/NanoShield",
		"Commander/Marine/SupplyChanges",

		-- Global Changes
		"Global/Bindings",
		"Global/DamageIndicatorFix",
		"Global/HealthBars",
		"Global/MucousHitsounds",
		"Global/ReadyRoomPanels",

		-- Marine Changes
		"Marine/GunDropTime",
		"Marine/Jetpack",
		"Marine/Observatory",
		"Marine/PrototypeLab",
		"Marine/Walk",
		"Marine/WeldSpeed",

		-- Weapons
		"Marine/Weapons/Flamethrower",
		"Marine/Weapons/Grenades",
		"Marine/Weapons/HMG",
		"Marine/Weapons/Mine",
	}

	return config
end
