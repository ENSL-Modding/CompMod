local techUpgradesTable = debug.getupvaluex(GetTechIdsFromBitMask, "techUpgradesTable")

for i,v in ipairs(techUpgradesTable) do
    if v == kTechId.Focus then
        techUpgradesTable[i] = kTechId.Neurotoxin
    end
end

local techUpgradesBitmask = CreateBitMask(techUpgradesTable)

debug.setupvaluex(GetTechIdsFromBitMask, "techUpgradesTable", techUpgradesTable)
debug.setupvaluex(PlayerInfoEntity.UpdateScore, "techUpgradesBitmask", techUpgradesBitmask)
debug.setupvaluex(GetTechIdsFromBitMask, "techUpgradesBitmask", techUpgradesBitmask)
