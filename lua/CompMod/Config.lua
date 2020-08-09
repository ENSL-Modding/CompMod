local modules = {
	"Alien/Aura/Range",
	"Alien/Carapace",
	"Alien/Cloaking/MoveSpeed",
	"Alien/Cyst",
	"Alien/Drifters/HoverHeight",
	"Alien/Drifters/Uncloak",
	"Alien/Eggs/EmbryoHP",
	"Alien/Eggs/HiveEggHeal",
	"Alien/Eggs/LifeformEggDrops",
	"Alien/Enzyme/Cooldown",
	"Alien/Fade/AdvancedMetabBiomass",
	"Alien/Fade/AdvancedSwipe",
	"Alien/Fade/Blink",
	"Alien/Fade/Stab",
	"Alien/Gorge/Babblers/Flammable",
	"Alien/Gorge/Babblers/SpawnRate",
	"Alien/Gorge/BileBomb/Research",
	"Alien/Gorge/Web/HealthPerCharge",
	"Alien/Gorge/Web/MaxCharges",
	"Alien/Gorge/Web/SlowDuration",
	"Alien/GorgeTunnels/HeightCheck",
	"Alien/GorgeTunnels/AlwaysInfested",
	"Alien/GorgeTunnels/Cost",
	"Alien/Hallucination/HealthAndShields",
	"Alien/Hallucination/DrifterHeight",
	"Alien/Lerk/Movement",
	"Alien/Lerk/Spikes",
	"Alien/Lerk/SporesBiomass",
	"Alien/Mucous/Cooldown",
	"Alien/Mucous/Radius",
	"Alien/Mucous/ShieldPercent",
	"Alien/Onos/BoneShield/ConsumeRate",
	"Alien/Onos/Charge/CollideWithPlayers",
	"Alien/Regen/Noise",
	"Alien/Regen/RegenRate",
	"Alien/Shift/Echo",
	"Alien/Skulk/BiteConeSize",
	"Alien/Skulk/Leap",
	"Alien/Vampirism/FriendlyFireFix",

	"Changelog",

	"Global/KeepLightsOnAtStart",
	"Global/MucousHitsounds",
	"Global/Resources",
	"Global/ResponsiveGUI",

	"Marine/AdvancedArmory/Health",
	"Marine/ARC/Health",
	"Marine/Flamethrower",
	"Marine/HMG/Damage",
	"Marine/InfantryPortal/PreventMultipleInitialIPs",
	"Marine/MAC/Cost",
	"Marine/MedpackHoT",
	"Marine/Nanoshield",
	"Marine/Observatory/BuildTime",
	"Marine/PrototypeLab/Cost",
	"Marine/RoboticsFactory/ARCFactoryResearch",
	"Marine/RoboticsFactory/Cost",
	"Marine/Sentry/Cost",
	"Marine/Sentry/SporesConfusion",
	"Marine/SentryBattery/Cost",
	"Marine/SupplyChanges",
	"Marine/SlowExpirationRate",
	"Marine/WeaponDropTime",
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
