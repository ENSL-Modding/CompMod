CompMod:AddTech({
    [kTechDataId] = kTechId.Roost,
    [kTechDataCostKey] = kRoostResearchCost,
    [kTechDataResearchTimeKey] = kRoostResearchTime,
    [kTechDataDisplayName] = "Roost",
    [kTechDataTooltipInfo] = "Allows Lerks to heal by perching on walls",
})
CompMod:AddResearchNode(kTechId.Roost, kTechId.BioMassTwo, kTechId.None, kTechId.AllAliens)
CompMod:AddTechIdToMaterialOffset(kTechId.Roost, 166)
CompMod:AddAlienTechmapTech(kTechId.Roost, 4, 10)
