-- Original
--
-- local kIndexToUpgrades =
-- {
--     { kTechId.Spur, kTechId.Crush, kTechId.Celerity, kTechId.Adrenaline },
--     { kTechId.Veil, kTechId.Camouflage, kTechId.Aura, kTechId.Focus },
--     { kTechId.Shell, kTechId.Vampirism, kTechId.Carapace, kTechId.Regeneration },
-- }

local kIndexToUpgrades =
{
    { kTechId.Spur, kTechId.Scavenger, kTechId.Celerity, kTechId.Adrenaline },
    { kTechId.Veil, kTechId.Camouflage, kTechId.Aura, kTechId.Neurotoxin },
    { kTechId.Shell, kTechId.Vampirism, kTechId.Tenacity, kTechId.Crush },
}

debug.setupvaluex(GUIUpgradeChamberDisplay.Update, "kIndexToUpgrades", kIndexToUpgrades)
