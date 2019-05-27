function GetModConfig(kLogLevels)
	local config = {}

	config.kLogLevel = kLogLevels.info
	config.kShowInFeedbackText = true
	config.kModVersion = "2"
	config.kModBuild = "1.0"
	config.disableRanking = true
	config.use_config = "none"
	config.techIdsToAdd = {
		"Consume",
		"ARCSpeedBoost",
	}

	config.modules =
	{
		-- Alien Changes
		"Alien/Eggs",
		"Alien/Webs",

		-- Upgrades
		"Alien/Upgrades/Aura",
		"Alien/Upgrades/Camouflage",

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
		"Marine/PrototypeLab",
		"Marine/Walk",

		-- Weapons
		"Marine/Weapons/Grenades",
		"Marine/Weapons/Mine",
	}

	return config
end
