local techHandler = CompMod:GetModule('techhandler')

techHandler:ChangeAlienTechMapTech(kTechId.MetabolizeHealth, 7, 8)
techHandler:ChangeAlienResearchNode(kTechId.MetabolizeHealth, kTechId.BioMassFive, kTechId.MetabolizeEnergy, kTechId.AllAliens)