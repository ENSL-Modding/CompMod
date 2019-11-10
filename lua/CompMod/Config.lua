local modules = {
	--[[
	  ============================
			Alien Modules
	  ============================
	]]

	"Alien/CaraSpecBugfix",

		-- Egg Modules
		"Alien/Eggs/EmbryoHP",
		"Alien/Eggs/HiveEggHeal",
		"Alien/Eggs/LifeformEggDrops",

		-- Lifeform Modules
            -- Skulk Modules
            "Alien/Lifeforms/Skulk/Movement/SneakSpeed",
            "Alien/Lifeforms/Skulk/Movement/InitJump",
			-- Fade Modules
			"Alien/Lifeforms/Fade/AdvancedSwipe",
			"Alien/Lifeforms/Fade/Stab",

			-- Gorge Modules
				-- Web Modules
				"Alien/Lifeforms/Gorge/Webs/DestroyOnTouch",
				"Alien/Lifeforms/Gorge/Webs/RemoveFromKillfeed",

			-- Lerk Modules
			"Alien/Lifeforms/Lerk/Base",
			"Alien/Lifeforms/Lerk/Spikes",
			"Alien/Lifeforms/Lerk/Movement",

			-- Onos Modules
				-- BoneShield Modules
				"Alien/Lifeforms/Onos/BoneShield/ConsumeRate",
			-- Charge Modules
			"Alien/Lifeforms/Onos/Charge",

		-- Structure Modules
		"Alien/Structures/Cyst",
		"Alien/Structures/GorgeTunnels",

		-- Upgrade Modules
			-- Vampirism Modules
			"Alien/Upgrades/Vampirism/FriendlyFireFix",
			-- Carapace Modules
			"Alien/Upgrades/Carapace",
            -- Cloaking Modules
            "Alien/Upgrades/Cloaking/MoveSpeed",

		-- Structure Ability Modules
		"Alien/Echo",

	--[[
	  ==========================
			Global Modules
	  ==========================
	]]

	-- "Global/Bindings",
	"Global/HealthBars",
	"Global/MucousHitsounds",
	"Global/PrimePowerNodes",
	"Global/ReadyRoomPanels",
	"Global/ResponsiveGUI",
	"Global/SupplyDisplay",
	"Global/Physics",

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
		-- Infantry Portals
		"Marine/Structures/InfantryPortal/PreventMultipleInitialIPs",

	"Marine/MedpackHoT",
	"Marine/Walk",

	-- Weapon Modules
		"Marine/WeaponDropTime",
		"Marine/Weapons/SlowExpirationRate",
		"Marine/Weapons/Shotgun",
		"Marine/Weapons/HMG",
		"Marine/Weapons/Mine",
		"Marine/Weapons/Pistol",
	"Marine/Nanoshield",
	"Marine/AdvancedAssistance",

    --[[
      ==========================
			Changelog Module
	  ==========================
    ]]

    "Changelog",
}

function GetModConfig(kLogLevels)
	local config = {}

	config.kLogLevel = kLogLevels.info
	config.kShowInFeedbackText = true
	config.kModVersion = "2"
	config.kModBuild = "8.5"
	config.disableRanking = true
	config.use_config = "none"

	config.techIdsToAdd = {
		"AdvancedSwipe",
	}

	config.modules = modules

	return config
end
