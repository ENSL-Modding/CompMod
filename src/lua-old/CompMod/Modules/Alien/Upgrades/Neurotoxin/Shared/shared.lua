local techHandler = CompMod:GetModule('techhandler')

techHandler:AddTechData({
    [kTechDataId] = kTechId.Neurotoxin,
    [kTechDataCategory] = kTechId.ShadeHive,
    [kTechDataDisplayName] = "Neurotoxin", -- TODO: Use locale
    [kTechDataSponitorCode] = "N",
    [kTechDataTooltipInfo] = "Each hit inflicts a poison toxin, hurting Marines over time",
    [kTechDataCostKey] = 0,
})

techHandler:AddAlienBuyNode(kTechId.Neurotoxin, kTechId.Veil, kTechId.None, kTechId.AllAliens)
techHandler:AddMaterialOffset(kTechId.Neurotoxin, 174)
