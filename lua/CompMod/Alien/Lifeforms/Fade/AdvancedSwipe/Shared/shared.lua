CompMod:AddTech({
    [kTechDataId] = kTechId.AdvancedSwipe,
    [kTechDataCategory] = kTechId.Fade,
    [kTechDataCostKey] = kAdvancedSwipeCost,
    [kTechDataResearchTimeKey] = kAdvancedSwipeResearchTime,
    [kTechDataDisplayName] = "Advanced Swipe",
    [kTechDataTooltipInfo] = "Increase Swipe damage by 8%",
})
CompMod:AddTechIdToMaterialOffset(kTechId.AdvancedSwipe, 105)
CompMod:AddResearchNode(kTechId.AdvancedSwipe, kTechId.BioMassSeven, kTechId.None, kTechId.AllAliens)
CompMod:AddAlienTechmapTech(kTechId.AdvancedSwipe, 9, 8)
