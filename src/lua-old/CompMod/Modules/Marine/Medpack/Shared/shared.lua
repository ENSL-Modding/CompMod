local techHandler = CompMod:GetModule('techhandler')

techHandler:ChangeTechData(kTechId.MedPack, {
    [kCommanderSelectRadius] = techHandler.Remove
})
