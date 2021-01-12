-- Original
--
-- local kUpgradeStructureTable =
-- {
--     {
--         name = "Shell",
--         techId = kTechId.Shell,
--         upgrades = {
--             kTechId.Vampirism, kTechId.Carapace, kTechId.Regeneration
--         }
--     },
--     {
--         name = "Veil",
--         techId = kTechId.Veil,
--         upgrades = {
--             kTechId.Camouflage, kTechId.Aura, kTechId.Focus
--         }
--     },
--     {
--         name = "Spur",
--         techId = kTechId.Spur,
--         upgrades = {
--             kTechId.Crush, kTechId.Celerity, kTechId.Adrenaline
--         }
--     }
-- }

local kUpgradeStructureTable =
{
    {
        name = "Shell",
        techId = kTechId.Shell,
        upgrades = {
            kTechId.Vampirism, kTechId.None, kTechId.Regeneration
        }
    },
    {
        name = "Veil",
        techId = kTechId.Veil,
        upgrades = {
            kTechId.Camouflage, kTechId.Aura, kTechId.Neurotoxin
        }
    },
    {
        name = "Spur",
        techId = kTechId.Spur,
        upgrades = {
            kTechId.Crush, kTechId.Celerity, kTechId.Adrenaline
        }
    }
}

debug.setupvaluex(AlienTeam.GetUpgradeStructureTable, "kUpgradeStructureTable", kUpgradeStructureTable)
