local techHandler = CompMod:GetModule('techhandler')

techHandler:AddTechData({
    [kTechDataId] = kTechId.AdvancedSwipe,
    [kTechDataCategory] = kTechId.Fade,
    [kTechDataCostKey] = kAdvancedSwipeCost,
    [kTechDataResearchTimeKey] = kAdvancedSwipeResearchTime,
    [kTechDataDisplayName] = "Advanced Swipe",
    [kTechDataTooltipInfo] = "Increase Swipe damage by 8%",
})
techHandler:AddMaterialOffset(kTechId.AdvancedSwipe, 105)
techHandler:AddAlienResearchNode(kTechId.AdvancedSwipe, kTechId.BioMassSeven, kTechId.None, kTechId.AllAliens)
techHandler:AddAlienTechMapTech(kTechId.AdvancedSwipe, 9, 8)
