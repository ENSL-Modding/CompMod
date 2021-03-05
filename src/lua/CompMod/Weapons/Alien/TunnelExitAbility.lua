Script.Load("lua/CompMod/Weapons/Alien/TunnelAbility.lua")

class 'TunnelExitAbility' (TunnelAbility)

function TunnelExitAbility:GetDropStructureId()
    return kTechId.GorgeTunnelMenuExit
end

local techIds = {
    kTechId.BuildTunnelExitOne,
    kTechId.BuildTunnelExitTwo,
    kTechId.BuildTunnelExitThree,
    kTechId.BuildTunnelExitFour,
}
function TunnelExitAbility:GetTechIds()
    return techIds
end

local selectTechIds = {
    kTechId.SelectTunnelExitOne,
    kTechId.SelectTunnelExitTwo,
    kTechId.SelectTunnelExitThree,
    kTechId.SelectTunnelExitFour,
}
function TunnelExitAbility:GetSelectTechIds()
    return selectTechIds
end
