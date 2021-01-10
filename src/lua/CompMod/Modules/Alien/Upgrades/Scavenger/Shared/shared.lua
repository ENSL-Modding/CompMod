local techHandler = CompMod:GetModule('techhandler')

techHandler:AddTechData({
    [kTechDataId] = kTechId.Scavenger,
    [kTechDataCategory] = kTechId.ShiftHive,
    [kTechDataDisplayName] = "Scavenger",
    [kTechDataSponitorCode] = "S",
    [kTechDataTooltipInfo] = "Scavenges the lifeforce from recently slain Marines",
    [kTechDataCostKey] = 0,
})

techHandler:AddAlienBuyNode(kTechId.Scavenger, kTechId.Spur, kTechId.None, kTechId.AllAliens)
techHandler:AddMaterialOffset(kTechId.Scavenger, 62)
