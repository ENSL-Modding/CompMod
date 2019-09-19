-- ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Weapons\Alien\ClogAbility.lua
--
--    Created by:   Andreas Urwalek (andi@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Alien/StructureAbility.lua")

class 'ClogAbility' (StructureAbility)

local kMinDistance = 0.5
local kClogOffset = 0.3

function ClogAbility:OverrideInfestationCheck(trace)

    if trace.entity and trace.entity:isa("Clog") then
        return true
    end

    return false    

end

function ClogAbility:AllowBackfacing()
    return true
end

function ClogAbility:GetIsPositionValid(position, player, normal)

    local entities = GetEntitiesWithinRange("ScriptActor", position, 7)    
    for _, entity in ipairs(entities) do
    
        if not entity:isa("Infestation") and not entity:isa("Babbler") and entity ~= player and (not entity.GetIsAlive or entity:GetIsAlive()) then
        
            local checkDistance = ConditionalValue(entity:isa("PhaseGate") or entity:isa("TunnelEntrance") or entity:isa("InfantryPortal"), 3, kMinDistance)
            local valid = ((entity:GetCoords().yAxis * checkDistance * 0.75 + entity:GetOrigin()) - position):GetLength() > checkDistance

            if not valid then
                return false
            end
        
        end
    
    end
    
    -- ensure we're not creating clogs inside of other clogs.
    local radius = Clog.kRadius - 0.001
    local entities = GetEntitiesWithinRange("Clog", position, radius)
    for i=1, #entities do
        if entities[i] then
            return false
        end
    end
    
    return true
    

end

function ClogAbility:ModifyCoords(coords)
    coords.origin = coords.origin + coords.yAxis * kClogOffset
end

function ClogAbility:GetEnergyCost()
    return kDropStructureEnergyCost
end

function ClogAbility:GetDropRange()
    return 3
end

function ClogAbility:GetPrimaryAttackDelay()
    return 1.0
end

function ClogAbility:GetGhostModelName(ability)

    local player = ability:GetParent()
    if player and player:isa("Gorge") then
    
        local variant = player:GetVariant()
        if variant == kGorgeVariant.shadow then
            return Clog.kModelNameShadow
        elseif variant == kGorgeVariant.toxin then
            return Clog.kModelNameToxin
        elseif variant == kGorgeVariant.abyss then
            return Clog.kModelNameAbyss
        end
        
    end
    
    return Clog.kModelName
    
end

function ClogAbility:GetDropStructureId()
    return kTechId.Clog
end

function ClogAbility:GetSuffixName()
    return "clog"
end

function ClogAbility:GetDropClassName()
    return "Clog"
end

function ClogAbility:GetDropMapName()
    return Clog.kMapName
end    

function ClogAbility:GetIgnoreGhostHighlight()
    return true
end