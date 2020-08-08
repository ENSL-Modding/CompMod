local modules = {
	"Alien/Babblers/Flammable",
	"Alien/Babblers/SpawnRate",
	"Alien/Drifters/Abilities/Enzyme/Cooldown",
	"Alien/Drifters/Abilities/Mucous/Cooldown",
	"Alien/Drifters/Abilities/Mucous/Radius",
	"Alien/Drifters/Abilities/Mucous/ShieldPercent",
	"Alien/Drifters/Abilities/Hallucination/HealthAndShields",
	"Alien/Drifters/Abilities/Hallucination/DrifterHeight",
	"Alien/Drifters/HoverHeight",
	"Alien/Drifters/Uncloak",
	"Alien/Eggs/EmbryoHP",
	"Alien/Eggs/HiveEggHeal",
	"Alien/Eggs/LifeformEggDrops",
	"Alien/Lifeforms/Fade/AdvancedMetabBiomass",
	"Alien/Lifeforms/Fade/AdvancedSwipe",
	"Alien/Lifeforms/Fade/Blink",
	"Alien/Lifeforms/Fade/Stab",
	"Alien/Lifeforms/Gorge/BileBomb/Research",
	"Alien/Lifeforms/Gorge/Web/HealthPerCharge",
	"Alien/Lifeforms/Gorge/Web/MaxCharges",
	"Alien/Lifeforms/Gorge/Web/SlowDuration",
	"Alien/Lifeforms/Lerk/Movement",
	"Alien/Lifeforms/Lerk/Spikes",
	"Alien/Lifeforms/Lerk/SporesBiomass",
	"Alien/Lifeforms/Onos/BoneShield/ConsumeRate",
	"Alien/Lifeforms/Onos/Charge/CollideWithPlayers",
	"Alien/Lifeforms/Skulk/BiteConeSize",
	"Alien/Lifeforms/Skulk/Leap",
	"Alien/Structures/Cyst",
	"Alien/Structures/GorgeTunnels",
	"Alien/Structures/Shift/Echo",
	"Alien/Upgrades/Aura/Range",
	"Alien/Upgrades/Carapace",
	"Alien/Upgrades/Cloaking/MoveSpeed",
	"Alien/Upgrades/Regen/Noise",
	"Alien/Upgrades/Regen/RegenRate",
	"Alien/Upgrades/Vampirism/FriendlyFireFix",

	"Changelog",

	"Global/KeepLightsOnAtStart",
	"Global/MucousHitsounds",
	"Global/Resources",
	"Global/ResponsiveGUI",

	"Marine/ARC/Health",
	"Marine/MAC/Cost",
	"Marine/MedpackHoT",
	"Marine/Nanoshield",
	"Marine/Structures/AdvancedArmory/Health",
	"Marine/Structures/InfantryPortal/PreventMultipleInitialIPs",
	"Marine/Structures/Observatory/BuildTime",
	"Marine/Structures/PrototypeLab/Cost",
	"Marine/Structures/RoboticsFactory/ARCFactoryResearch",
	"Marine/Structures/RoboticsFactory/Cost",
	"Marine/Structures/Sentry/Cost",
	"Marine/Structures/Sentry/SporesConfusion",
	"Marine/Structures/SentryBattery/Cost",
	"Marine/SupplyChanges",
	"Marine/WeaponDropTime",
	"Marine/Weapons/Flamethrower",
	"Marine/Weapons/HMG/Damage",
	"Marine/Weapons/SlowExpirationRate",
	"Marine/AdvancedWeapons", -- this needs to be last, don't ask

	"Spectator/EdgePanning",
	"Spectator/HelpText",
	"Spectator/SupplyDisplay",
}

function GetModConfig(kLogLevels)
	local config = {}

	config.kLogLevel = kLogLevels.info
	config.kShowInFeedbackText = true
	config.kModVersion = "3"
	config.kModBuild = "2.1"
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
