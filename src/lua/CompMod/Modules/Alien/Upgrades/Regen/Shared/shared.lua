local techHandler = CompMod:GetModule('techhandler')

techHandler:RemoveAlienBuyNode(kTechId.Regeneration)
techHandler:RemoveAlienTechMapLine(kTechId.Shell, kTechId.Regeneration)
techHandler:RemoveAlienTechMapTech(kTechId.Regeneration)
techHandler:RemoveTechData(kTechId.Regeneration)
