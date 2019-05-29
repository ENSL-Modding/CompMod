function GetModConfig(kLogLevels)
	local config = {}

	config.kLogLevel = kLogLevels.info
	config.kShowInFeedbackText = true
	config.kModVersion = "2"
	config.kModBuild = "2.1"
	config.disableRanking = true
	config.use_config = "none"
	config.techIdsToAdd = {
		"Consume",
	}

	config.modules =
	{
		-- Alien Changes
		"Alien/Eggs",
		"Alien/Webs",

		-- Upgrades
		"Alien/Upgrades/Camouflage",

		-- Commander Changes

			-- Alien Commander
			"Commander/Alien/Consume",
			"Commander/Alien/LifeformEggs",

			-- Marine Commander
			"Commander/Marine/ARCCorrodeBugFix",
			"Commander/Marine/NanoShield",

		-- Global Changes
		"Global/Bindings",
		"Global/HealthBars",
		"Global/ReadyRoomPanels",

		-- Marine Changes
		"Marine/Walk",

		-- Weapons
		"Marine/Weapons/Grenades",
		"Marine/Weapons/Mine",
	}

	return config
end
