local techHandler = CompMod:GetModule('techhandler')
techHandler:ChangeTechData(kTechId.BabblerEgg, {
    [kTechDataDisplayName] = "Toxic Mine",
    [kTechDataTooltipInfo] = "Explodes when marines get close and covers them with toxin"
})
