-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Weapons\Alien\LerkUmbra.lua
--
--    Created by:   Andreas Urwalek (andi@unknownworlds.com)
--
-- Umbra is main attack, spikes are secondary.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Alien/Ability.lua")
Script.Load("lua/Weapons/Alien/SpikesMixin.lua")
Script.Load("lua/CommAbilities/Alien/CragUmbra.lua")
Script.Load("lua/Weapons/ClientWeaponEffectsMixin.lua")

class 'LerkUmbra' (Ability)

LerkUmbra.kMapName = "lerkumbra"


local kAnimationGraph = PrecacheAsset("models/alien/lerk/lerk_view.animation_graph")

local networkVars =
{
}

AddMixinNetworkVars(SpikesMixin, networkVars)

local function CreateUmbraCloud(self, player)
    
    local maxRange = self:GetRange()
    
    local trace = Shared.TraceRay(
        player:GetEyePos(), 
        player:GetEyePos() + player:GetViewCoords().zAxis * maxRange, 
        CollisionRep.Damage, 
        PhysicsMask.Bullets, 
        EntityFilterOneAndIsa(player, "Babbler")
    )
    
    local origin = player:GetModelOrigin()
    local travelVector = trace.endPoint - origin
    local distance = math.min( maxRange, travelVector:GetLength() )
    local destination = GetNormalizedVector(travelVector) * distance + origin
    local umbraCloud = CreateEntity( CragUmbra.kMapName, origin, player:GetTeamNumber() )
    
    umbraCloud:SetTravelDestination( destination )
    
    if gDebugSporesAndUmbra then
    --TEMP - Remove once tuning / debugging of VFX, etc done
        DebugWireSphere( destination, kUmbraRadius, kUmbraDuration, 1, 1, 0, 0.8, false )
        DebugDrawAxes( Coords.GetTranslation( destination + trace.normal * 0.35), destination, 2, kUmbraDuration, 1 )
    end
    
end

function LerkUmbra:OnCreate()

    Ability.OnCreate(self)
    
    InitMixin(self, SpikesMixin)
    
    self.primaryAttacking = false
    
    if Client then
        InitMixin(self, ClientWeaponEffectsMixin)
    end

end

function LerkUmbra:GetAnimationGraphName()
    return kAnimationGraph
end

function LerkUmbra:GetEnergyCost()
    return kUmbraEnergyCost
end

function LerkUmbra:GetHUDSlot()
    return 2
end

function LerkUmbra:GetRange()
    return kUmbraMaxRange
end

function LerkUmbra:GetDeathIconIndex()
    return kDeathMessageIcon.Spikes
end

function LerkUmbra:GetSecondaryTechId()
    return kTechId.Spikes
end

function LerkUmbra:OnPrimaryAttack(player)

    if player:GetEnergy() >= self:GetEnergyCost() then
        self.primaryAttacking = true
        self:PerformPrimaryAttack(player)
    else
        self.primaryAttacking = false
    end
    
end

function LerkUmbra:OnPrimaryAttackEnd()
    self.primaryAttacking = false
end

function LerkUmbra:OnHolster(player)

    Ability.OnHolster(self, player)
    
    self.primaryAttacking = false
    
end

function LerkUmbra:OnTag(tagName)

    PROFILE("LerkUmbra:OnTag")

    if tagName == "hit" then
    
        local player = self:GetParent()
        
        if player then  
            
            if Server then
                if player:GetEnergy() >= self:GetEnergyCost() then
                    player:TriggerEffects("umbra_attack")
                    CreateUmbraCloud(self, player)
                    player:DeductAbilityEnergy(self:GetEnergyCost())
                end
            end
            
        end
        
    end
    
end


function LerkUmbra:OnUpdateAnimationInput(modelMixin)

    PROFILE("Spikes:OnUpdateAnimationInput")
    
    if not self:GetIsSecondaryBlocking() then
    
        modelMixin:SetAnimationInput("ability", "umbra")

        local activityString = "none"
        if self.primaryAttacking then
            activityString = "primary"
        end

        modelMixin:SetAnimationInput("activity", activityString)
    
    end
    
end

Shared.LinkClassToMap("LerkUmbra", LerkUmbra.kMapName, networkVars)