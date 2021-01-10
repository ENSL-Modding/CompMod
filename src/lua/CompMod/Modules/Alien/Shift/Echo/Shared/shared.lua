local techHandler = CompMod:GetModule('techhandler')

techHandler:ChangeTechData(kTechId.TeleportHive, {
    [kTechDataImplemented] = true,
    [kTechDataDisplayName] = "Move Hive",
    [kTechDataTooltipInfo] = "Moves structure to another legal location",
    [kTechDataSpawnHeightOffset] = 2.494,
})
