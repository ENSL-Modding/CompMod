local modules = {
	--[[
	  ============================
			Alien Modules
	  ============================
	]]

	"Alien/Biomass",
	"Alien/Consume",

		-- Drifter Modules
		"Alien/Drifters/BlueprintPopFix",

		-- Egg Modules
		"Alien/Eggs/EmbryoHP",
		"Alien/Eggs/HiveEggHeal",
		"Alien/Eggs/LifeformEggDrops",

		-- Lifeform Modules

			-- Fade Modules
			"Alien/Lifeforms/Fade/AdvancedMetabolize",
			"Alien/Lifeforms/Fade/AdvancedSwipe",
			"Alien/Lifeforms/Fade/Blink",
			"Alien/Lifeforms/Fade/Stab",

			-- Gorge Modules
			"Alien/Lifeforms/Gorge/Webs",

			-- Lerk Modules
			"Alien/Lifeforms/Lerk/Base",
			"Alien/Lifeforms/Lerk/Roost",
			"Alien/Lifeforms/Lerk/Spikes",
			"Alien/Lifeforms/Lerk/Spores",
			"Alien/Lifeforms/Lerk/Umbra",

			-- Onos Modules
			"Alien/Lifeforms/Onos/Base",

				-- BoneFuel Modules
				"Alien/Lifeforms/Onos/BoneFuel/ConsumeRate",
				"Alien/Lifeforms/Onos/BoneFuel/MovementSpeed",
				"Alien/Lifeforms/Onos/BoneFuel/UIBar",

			"Alien/Lifeforms/Onos/Stomp",

			-- Skulk Modules
			"Alien/Lifeforms/Skulk/CarapaceMaxArmour",
			--"Alien/Lifeforms/Skulk/ModelSize",

	"Alien/ShellHealSound",

		-- Structure Modules
		"Alien/Structures/Cyst",
		"Alien/Structures/GorgeTunnels",
		"Alien/Structures/Harvester",

	"Alien/SupplyChanges",

		-- Upgrade Modules
		"Alien/Upgrades/Camouflage",

	--[[
	  ==========================
			Global Modules
	  ==========================
	]]

	"Global/Bindings",
	"Global/HealthBars",
	"Global/ReadyRoomPanels",
	"Global/SupplyDisplay",

	--[[
	  ==========================
			Marine Modules
	  ==========================
	]]

	"Marine/FlameVsClogAndCystBuffs",
	"Marine/NanoShield",
	"Marine/PowerSurge",
	"Marine/SpawnFix",

		-- Structure Modules
			-- ARCs
			"Marine/Structures/ARC/ARCCorrodeBugFix",
			"Marine/Structures/ARC/Base",

	"Marine/SupplyChanges",
	"Marine/Walk",

		-- Weapons
		"Marine/Weapons/AxeHitFix",

			-- Grenades
			"Marine/Weapons/Grenades/ClusterGrenade",
			"Marine/Weapons/Grenades/GasGrenade",
			"Marine/Weapons/Grenades/GrenadeQuickThrow",
			"Marine/Weapons/Grenades/PulseGrenade",

		"Marine/Weapons/HMG",
		"Marine/Weapons/Mine",
		"Marine/Weapons/Shotgun",
}

function GetModConfig(kLogLevels)
	local config = {}

	config.kLogLevel = kLogLevels.info
	config.kShowInFeedbackText = true
	config.kModVersion = "2"
	config.kModBuild = "6.2-beta"
	config.disableRanking = true
	config.use_config = "none"

	config.techIdsToAdd = {
		"Consume",
		"AdvancedSwipe",
		"Roost"
	}

	config.modules = modules

	return config
end
