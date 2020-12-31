-- remove focus
local techHandler = CompMod:GetModule('techhandler')

techHandler:RemoveAlienBuyNode(kTechId.Focus)
techHandler:RemoveTechData(kTechId.Focus)