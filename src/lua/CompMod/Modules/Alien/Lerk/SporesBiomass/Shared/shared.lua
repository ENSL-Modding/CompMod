local techHandler = CompMod:GetModule('techhandler')
techHandler:ChangeAlienTechMapTech(kTechId.Spores, 8, 10)
techHandler:ChangeAlienResearchNode(kTechId.Spores, kTechId.BioMassSix, kTechId.None, kTechId.AllAliens)

-- Shift advanced meta down to fill the gap left by Spores
techHandler:ChangeAlienTechMapTech(kTechId.MetabolizeHealth, 7, 8)
