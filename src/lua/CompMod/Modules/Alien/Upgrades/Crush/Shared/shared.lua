local techHandler = CompMod:GetModule('techhandler')

techHandler:ChangeAlienBuyNode(kTechId.Crush, kTechId.Shell, kTechId.None, kTechId.AllAliens)
techHandler:ChangeAlienTechMapTech(kTechId.Crush, 11, 5)
techHandler:ChangeTechData(kTechId.Crush, {
    [kTechDataCategory] = kTechId.CragHive
})
