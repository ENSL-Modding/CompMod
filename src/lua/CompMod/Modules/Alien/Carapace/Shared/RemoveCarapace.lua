local techHandler = CompMod:GetModule('techhandler')

techHandler:RemoveAlienBuyNode(kTechId.Carapace)
techHandler:RemoveAlienTechMapLine(kTechId.Shell, kTechId.Carapace)
techHandler:RemoveAlienTechMapTech(kTechId.Carapace)
techHandler:RemoveTechData(kTechId.Carapace)
