-- Original
-- 
-- local techUpgradesTable =
-- {
--     kTechId.Jetpack,
--     kTechId.Welder,
--     kTechId.ClusterGrenade,
--     kTechId.PulseGrenade,
--     kTechId.GasGrenade,
--     kTechId.Mine,

--     kTechId.Vampirism,
--     kTechId.Carapace,
--     kTechId.Regeneration,

--     kTechId.Aura,
--     kTechId.Focus,
--     kTechId.Camouflage,

--     kTechId.Celerity,
--     kTechId.Adrenaline,
--     kTechId.Crush,

--     kTechId.Parasite
-- }

local techUpgradesTable =
{
    kTechId.Jetpack,
    kTechId.Welder,
    kTechId.ClusterGrenade,
    kTechId.PulseGrenade,
    kTechId.GasGrenade,
    kTechId.Mine,

    kTechId.Vampirism,
    kTechId.Crush,
    kTechId.Tenacity,

    kTechId.Aura,
    kTechId.Neurotoxin,
    kTechId.Camouflage,

    kTechId.Celerity,
    kTechId.Adrenaline,
    kTechId.Scavenger,

    kTechId.Parasite,
}

local techUpgradesBitmask = CreateBitMask(techUpgradesTable)

debug.setupvaluex(GetTechIdsFromBitMask, "techUpgradesTable", techUpgradesTable)
debug.setupvaluex(PlayerInfoEntity.UpdateScore, "techUpgradesBitmask", techUpgradesBitmask)
debug.setupvaluex(GetTechIdsFromBitMask, "techUpgradesBitmask", techUpgradesBitmask)
