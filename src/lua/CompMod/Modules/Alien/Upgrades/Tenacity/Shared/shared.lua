local techHandler = CompMod:GetModule('techhandler')

techHandler:AddTechData({
    [kTechDataId] = kTechId.Tenacity,
    [kTechDataCategory] = kTechId.CragHive,
    [kTechDataDisplayName] = "Tenacity",
    [kTechDataSponitorCode] = "T",
    [kTechDataTooltipInfo] = "Increases healing potency",
    [kTechDataCostKey] = 0,
})

techHandler:AddAlienBuyNode(kTechId.Tenacity, kTechId.Shell, kTechId.None, kTechId.AllAliens)
techHandler:AddMaterialOffset(kTechId.Tenacity, 61)
