local modules = {
	--[[
	  ============================
			Alien Modules
	  ============================
	]]

	"Alien/Biomass",
	"Alien/CaraSpecBugfix",

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
			"Alien/Lifeforms/Fade/Stab",

			-- Gorge Modules
				-- Web Modules
				"Alien/Lifeforms/Gorge/Webs/DestroyOnTouch",

			-- Lerk Modules
			"Alien/Lifeforms/Lerk/Base",
			"Alien/Lifeforms/Lerk/Spores",

			-- Onos Modules
				-- BoneShield Modules
				"Alien/Lifeforms/Onos/BoneShield/ConsumeRate",
				"Alien/Lifeforms/Onos/BoneShield/UIBar",

			"Alien/Lifeforms/Onos/Stomp",

	"Alien/ShellHealSound",

		-- Structure Modules
		"Alien/Structures/Cyst",
		"Alien/Structures/GorgeTunnels",
		"Alien/Structures/Harvester",

	"Alien/SupplyChanges",

		-- Upgrade Modules
		"Alien/Upgrades/Carapace",
			-- Vamparism Modules
			"Alien/Upgrades/Vamparism/FriendlyFireFix",

	--[[
	  ==========================
			Global Modules
	  ==========================
	]]

	"Global/Bindings",
	"Global/HealthBars",
	"Global/MucousHitsounds",
	"Global/PrimePowerNodes",
	"Global/ReadyRoomPanels",
	"Global/ResponsiveGUI",
	"Global/SupplyDisplay",

	--[[
	  ==========================
			Marine Modules
	  ==========================
	]]

	-- Structure Modules
		-- ARCs
		"Marine/Structures/ARC/ARCCorrodeBugFix",

		-- Observatory
		"Marine/Structures/Observatory/BuildTime",

	"Marine/MedpackHoT",
	"Marine/PowerSurge",
	"Marine/SupplyChanges",
	"Marine/Walk",
	"Marine/WeaponDropTime",

		-- Weapons
		"Marine/Weapons/AxeHitFix",

			-- Grenades
			"Marine/Weapons/Grenades/GrenadeQuickThrow",
			"Marine/Weapons/Grenades/ClusterGrenade/PlayerDamageReduction",

		"Marine/Weapons/Shotgun",

	"Marine/WeaponStepping",

	--[[
	  ==============================
	  		Spectator Modules
	  ==============================
	]]
	"Spectator/KillFeedFix",
}

function GetModConfig(kLogLevels)
	local config = {}

	config.kLogLevel = kLogLevels.info
	config.kShowInFeedbackText = true
	config.kModVersion = "2"
	config.kModBuild = "7.5"
	config.disableRanking = true
	config.use_config = "none"

	config.techIdsToAdd = {
		"AdvancedSwipe",
	}

	config.modules = modules

	return config
end
