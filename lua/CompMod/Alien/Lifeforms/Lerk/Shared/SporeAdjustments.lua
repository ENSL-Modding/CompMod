-- change spores to require bio 6
CompMod:ChangeResearch(kTechId.Spores, kTechId.BioMassSix, kTechId.None, kTechId.AllAliens)

-- reflect changes on tech tree
CompMod:ChangeAlienTechmapTech(kTechId.Spores, 8, 9)
