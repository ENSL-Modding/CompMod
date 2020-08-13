local techHandler = CompMod:GetModule('techhandler')
techHandler:ChangeAlienResearchNode(kTechId.BileBomb, kTechId.BioMassTwo, kTechId.None, kTechId.AllAliens)
techHandler:ChangeAlienTechMapTech(kTechId.BileBomb, 4, 10)

-- Move metabolize energy down to fill the gap
techHandler:ChangeAlienTechMapTech(kTechId.MetabolizeEnergy, 5, 9)
