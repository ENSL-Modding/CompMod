Script.Load("lua/CompMod/Weapons/Alien/TunnelAbility.lua")

class 'TunnelEntranceAbility' (TunnelAbility)

function TunnelEntranceAbility:GetDropStructureId()
    return kTechId.GorgeTunnelMenuEntrance
end

function TunnelEntranceAbility:GetTechIds()
    return {
        kTechId.BuildTunnelEntryOne,
        kTechId.BuildTunnelEntryTwo,
        kTechId.BuildTunnelEntryThree,
        kTechId.BuildTunnelEntryFour,
    }
end

function TunnelEntranceAbility:GetSelectTechIds()
    return {
        kTechId.SelectTunnelEntryOne,
        kTechId.SelectTunnelEntryTwo,
        kTechId.SelectTunnelEntryThree,
        kTechId.SelectTunnelEntryFour,
    }
end
