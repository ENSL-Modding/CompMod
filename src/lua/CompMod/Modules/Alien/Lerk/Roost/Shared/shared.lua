local techHandler = CompMod:GetModule('techhandler')

techHandler:AddTechData({
    [kTechDataId] = kTechId.Roost,
    [kTechDataCategory] = kTechId.Lerk,
    [kTechDataCostKey] = kRoostCost,
    [kTechDataResearchTimeKey] = kRoostResearchTime,
    [kTechDataDisplayName] = "Roost",
    [kTechDataTooltipInfo] = "Allows Lerks to heal by perching on walls",
})

techHandler:AddMaterialOffset(kTechId.Roost, 166)
techHandler:AddAlienResearchNode(kTechId.Roost, kTechId.BioMassTwo, kTechId.None, kTechId.AllAliens)
techHandler:AddAlienTechMapTech(kTechId.Roost, 4, 11)
