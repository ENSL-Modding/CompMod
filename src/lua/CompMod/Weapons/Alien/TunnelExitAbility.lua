Script.Load("lua/CompMod/Weapons/Alien/TunnelAbility.lua")

class 'TunnelExitAbility' (TunnelAbility)

function TunnelExitAbility:GetDropStructureId()
    return kTechId.GorgeTunnelMenuExit
end

function TunnelExitAbility:GetTechIds()
    return {
        kTechId.BuildTunnelExitOne,
        kTechId.BuildTunnelExitTwo,
        kTechId.BuildTunnelExitThree,
        kTechId.BuildTunnelExitFour,
    }
end

function TunnelExitAbility:GetSelectTechIds()
    return {
        kTechId.SelectTunnelExitOne,
        kTechId.SelectTunnelExitTwo,
        kTechId.SelectTunnelExitThree,
        kTechId.SelectTunnelExitFour,
    }
end
