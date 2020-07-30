local modules = {
	--[[
	  ============================
			Alien Modules
	  ============================
	]]
	-- Drifter Modules
	"Alien/Drifters/HoverHeight",
	"Alien/Drifters/Uncloak",
		-- Drifter Abilities
			-- Enzyme
			"Alien/Drifters/Abilities/Enzyme/Cooldown",
			-- Mucous
			"Alien/Drifters/Abilities/Mucous/Cooldown",
			"Alien/Drifters/Abilities/Mucous/Radius",
			"Alien/Drifters/Abilities/Mucous/ShieldPercent",
			-- Hallucination
			"Alien/Drifters/Abilities/Hallucination/HealthAndShields",
			"Alien/Drifters/Abilities/Hallucination/DrifterHeight",

	-- Egg Modules
	"Alien/Eggs/EmbryoHP",
	"Alien/Eggs/HiveEggHeal",
	"Alien/Eggs/LifeformEggDrops",

	-- Lifeform Modules
		-- Skulk Modules
		"Alien/Lifeforms/Skulk/Leap",
		"Alien/Lifeforms/Skulk/BiteConeSize",
		-- Fade Modules
		"Alien/Lifeforms/Fade/AdvancedSwipe",
		"Alien/Lifeforms/Fade/Stab",
		"Alien/Lifeforms/Fade/Blink",
		"Alien/Lifeforms/Fade/AdvancedMetabBiomass",

		-- Gorge Modules
			-- Web Modules
			"Alien/Lifeforms/Gorge/Web/HealthPerCharge",
			"Alien/Lifeforms/Gorge/Web/SlowDuration",
			"Alien/Lifeforms/Gorge/Web/MaxCharges",
			-- Babbler Modules
				"Alien/Babblers/Flammable",
				"Alien/Babblers/SpawnRate",

		-- Lerk Modules
		"Alien/Lifeforms/Lerk/Base",
		"Alien/Lifeforms/Lerk/Spikes",
		"Alien/Lifeforms/Lerk/Movement",
		"Alien/Lifeforms/Lerk/SporesBiomass",

		-- Onos Modules
			-- BoneShield Modules
			"Alien/Lifeforms/Onos/BoneShield/ConsumeRate",
			-- Charge Modules
			"Alien/Lifeforms/Onos/Charge/CollideWithPlayers",

	-- Structure Modules
	"Alien/Structures/Cyst",
	"Alien/Structures/GorgeTunnels",
	"Alien/Structures/Shift/Echo",

	-- Upgrade Modules
		-- Crag Modules
			-- Vampirism
			"Alien/Upgrades/Vampirism/FriendlyFireFix",
			-- Carapace
			"Alien/Upgrades/Carapace",
			-- Regen
			"Alien/Upgrades/Regen/Noise",
			"Alien/Upgrades/Regen/RegenRate",
		-- Shade Modules
		 "Alien/Upgrades/Aura/Range",
		 "Alien/Upgrades/Cloaking/MoveSpeed",

	--[[
	  ==========================
			Marine Modules
	  ==========================
	]]

	-- Structure Modules
		-- Advanced Armory
		"Marine/Structures/AdvancedArmory/Health",
		-- Observatory
		"Marine/Structures/Observatory/BuildTime",
		-- Infantry Portals
		"Marine/Structures/InfantryPortal/PreventMultipleInitialIPs",
		-- Proto
		"Marine/Structures/PrototypeLab/Cost",
		-- Robotics
		"Marine/Structures/RoboticsFactory/Cost",
		"Marine/Structures/RoboticsFactory/ARCFactoryResearch",

	-- Commander Assistance
		"Marine/MedpackHoT",
		"Marine/Nanoshield",

	-- Weapon Modules
		"Marine/WeaponDropTime",
		"Marine/Weapons/SlowExpirationRate",
		"Marine/Weapons/HMG/ClipSize",
		"Marine/Weapons/HMG/ReloadSpeed",
		"Marine/Weapons/HMG/Damage",
		"Marine/Weapons/Pistol",
		"Marine/Weapons/Flamethrower",
		"Marine/Weapons/WeaponScaling",
		"Marine/Weapons/Mines/Cost",
		"Marine/Weapons/Mines/NumMines",
		"Marine/AdvancedWeapons",

	-- ARC Changes
		"Marine/ARC/Health",

	-- MAC Changes
		"Marine/MAC/Cost",

	--[[
	  ==========================
			Global Modules
	  ==========================
	]]

	"Global/MucousHitsounds",
	"Global/ResponsiveGUI",
	"Global/Resources",
	"Global/KeepLightsOnAtStart",

	--[[
	==========================
		Spectator Modules
	==========================
	]]

	"Spectator/EdgePanning",
	"Spectator/HelpText",
	"Spectator/SupplyDisplay",

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
	config.kModVersion = "3"
	config.kModBuild = "1.1"
	config.disableRanking = true
	config.use_config = "none"

	config.techIdsToAdd = {
		"AdvancedSwipe",
		"MunitionsTech",
		"DemolitionsTech",
	}

	config.modules = modules

	return config
end
