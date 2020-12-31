local kUpgradeStructureTable = AlienTeam.GetUpgradeStructureTable()
for ichamber,vchamber in pairs(kUpgradeStructureTable) do
    if vchamber.techId == kTechId.Veil then
        for iup,vup in ipairs(vchamber.upgrades) do
            if vup == kTechId.Focus then
                kUpgradeStructureTable[ichamber].upgrades[iup] = kTechId.Neurotoxin
            end
        end
    end
end

debug.setupvaluex(AlienTeam.GetUpgradeStructureTable, "kUpgradeStructureTable", kUpgradeStructureTable)
