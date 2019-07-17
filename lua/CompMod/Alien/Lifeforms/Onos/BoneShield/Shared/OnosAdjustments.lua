-- move boneshield requirement to bio5
CompMod:ChangeResearch(kTechId.BoneShield, kTechId.BioMassFive, kTechId.None, kTechId.AllAliens)

-- update techtree
CompMod:ChangeAlienTechmapTech(kTechId.BoneShield, 7, 8)