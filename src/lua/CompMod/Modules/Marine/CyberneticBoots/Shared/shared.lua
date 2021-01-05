local techHandler = CompMod:GetModule('techhandler')
techHandler:AddTechData({
    [kTechDataId] = kTechId.CyberneticBoots,
    [kTechDataCostKey] = 666,
    [kTechDataResearchTimeKey] = 13,
    [kTechDataDisplayName] = "Cybernetic Boots",
    [kTechDataTooltipInfo] = "Upgrades standard TSF boots to a prototype model :)",
    [kTechDataResearchName] = "Cybernetic Boots",
})

techHandler:AddMarineResearchNode(kTechId.CyberneticBoots, kTechId.PrototypeLab, kTechId.None)
techHandler:AddMaterialOffset(kTechId.CyberneticBoots, 154)
