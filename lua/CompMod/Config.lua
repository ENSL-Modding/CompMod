local function GetModules()
	return {
		--[[
		=====================
			Alien Changes
		=====================
		]]

		"Alien/Biomass",
		"Alien/Consume",
		"Alien/Eggs",
		"Alien/LifeformEggs",
		"Alien/SupplyChanges",

		-- Abilities
		"Alien/Abilities/AdvancedMetabolize",
		"Alien/Abilities/AdvancedSwipe",
		"Alien/Abilities/Roost",
		"Alien/Abilities/Spores",
		"Alien/Abilities/Stab",
		"Alien/Abilities/Stomp",
		"Alien/Abilities/Umbra",
		"Alien/Abilities/Webs",

		-- Lifeform Changes
		"Alien/Lifeforms/Skulk",
		"Alien/Lifeforms/Lerk",
		"Alien/Lifeforms/Fade",
		"Alien/Lifeforms/Onos",

		-- Structure Changes
		"Alien/Structures/Cyst",
		"Alien/Structures/GorgeTunnels",
		"Alien/Structures/Harvester",

		-- Upgrades
		"Alien/Upgrades/Camouflage",

		--[[
		======================
			Global Changes
		======================
		]]
		"Global/Bindings",
		"Global/HealthBars",
		"Global/ReadyRoomPanels",
		"Global/SupplyDisplay",

		--[[
		======================
			Marine Changes
		======================
		]]
		"Marine/ARCCorrodeBugFix",
		"Marine/FlameVsClogAndCystBuffs",
		"Marine/SpawnFix",
		"Marine/SupplyChanges",
		"Marine/Walk",

		-- Abilities
		"Marine/Abilities/GrenadeQuickThrow",
		"Marine/Abilities/NanoShield",
		"Marine/Abilities/PowerSurge",

		-- Structures
		"Marine/Structures/ARC",

		-- Weapons
		"Marine/Weapons/Axe",
		"Marine/Weapons/Grenades",
		"Marine/Weapons/HMG",
		"Marine/Weapons/Mine",
		"Marine/Weapons/Shotgun",
	}
end

local function GetTechIdsToAdd()
	return {
		"Consume",
		"AdvancedSwipe",
		"Roost"
	}
end

function GetModConfig(kLogLevels)
	local config = {}

	config.kLogLevel = kLogLevels.info
	config.kShowInFeedbackText = true
	config.kModVersion = "2"
	config.kModBuild = "6.2-beta"
	config.disableRanking = true
	config.use_config = "none"

	config.techIdsToAdd = GetTechIdsToAdd()
	config.modules = GetModules()

	return config
end
