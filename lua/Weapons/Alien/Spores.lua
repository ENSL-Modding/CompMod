-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Weapons\Alien\Spores.lua
--
--    Created by:   Andreas Urwalek (andi@unknownworlds.com)
--
-- Spores main attack, spikes secondary
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Alien/Ability.lua")
Script.Load("lua/Weapons/Alien/SpikesMixin.lua")
Script.Load("lua/Weapons/Alien/SporeCloud.lua")
Script.Load("lua/Weapons/ClientWeaponEffectsMixin.lua")

kSporesHUDSlot = 3

local function CreateSporeCloud(self, origin, player)
    
    local maxRange = self:GetRange()
    
    local trace = Shared.TraceRay(
        player:GetEyePos(), 
        player:GetEyePos() + player:GetViewCoords().zAxis * maxRange, 
        CollisionRep.Damage, 
        PhysicsMask.Bullets, 
        EntityFilterOneAndIsa(player, "Babbler")
    )
    local travelVector = trace.endPoint - origin
    
    local distance
    if trace.entity and HasMixin( trace.entity, "Live") then
        distance = math.min( maxRange + kSporesDustCloudRadius, travelVector:GetLength() )
    else
    --keep it kSporesDustCloudRadius meters out of the wall.    
        distance = math.min( maxRange + kSporesDustCloudRadius, travelVector:GetLength() ) - kSporesDustCloudRadius * 0.75
    end
    
    local destination = GetNormalizedVector(travelVector) * distance + origin
    
    local spores = CreateEntity( SporeCloud.kMapName, origin, player:GetTeamNumber() )
    spores:SetTravelDestination( destination )
    
    spores:SetOwner(player)
    
    if gDebugSporesAndUmbra then
    --TEMP - Remove once tuning / debugging of VFX, etc done
        DebugWireSphere( destination, kSporesDustCloudRadius, kSporesDustCloudLifetime, 0, 1, 0, 0.8, false )
        DebugDrawAxes( Coords.GetTranslation( destination + trace.normal * 0.35), destination, 2, kSporesDustCloudLifetime, 1 )
    end
    
    return spores
    
end

local function GetHasSporeCloudsInRangeWithLifeTime(position, range, minLifeTime)
    
    for index, sporeCloud in ipairs(GetEntitiesWithinRange("SporeCloud", position, range)) do
    
        if sporeCloud:GetRemainingLifeTime() >= minLifeTime then
            return true
        end
    
    end
    
end

class 'Spores' (Ability)

Spores.kMapName = "Spores"

local kAnimationGraph = PrecacheAsset("models/alien/lerk/lerk_view.animation_graph")

-- no sporeclouds will be created when another cloud in kCheckSporeRange with remaining life time > kCheckSporeLifeTime is found
local kCheckSporeRange = kSporesDustCloudRadius * 0.7
local kCheckSporeLifeTime = kSporesDustCloudLifetime * 0.7

local kSporesBlockingTime = 0.3

--local kLoopingDustSound = PrecacheAsset("sound/NS2.fev/alien/lerk/spore_spray")

local networkVars =
{
    lastPrimaryAttackStartTime = "time",
    lastPrimaryAttackEndTime = "time"
}

AddMixinNetworkVars(SpikesMixin, networkVars)

function Spores:OnCreate()

    Ability.OnCreate(self)
    
    InitMixin(self, SpikesMixin)
    
    self.primaryAttacking = false
       
    if Client then
        InitMixin(self, ClientWeaponEffectsMixin)
    end

end

function Spores:OnDestroy()
    Ability.OnDestroy(self)
end

function Spores:GetAnimationGraphName()
    return kAnimationGraph
end

function Spores:GetEnergyCost()
    return kSporesDustEnergyCost
end

function Spores:GetHUDSlot()
    return kSporesHUDSlot
end

function Spores:GetRange()
    return kSporesMaxRange
end

function Spores:GetDeathIconIndex()
    return kDeathMessageIcon.Spikes
end

function Spores:GetSecondaryTechId()
    return kTechId.Spikes
end

function Spores:GetAttackDelay()
    return kSporesDustFireDelay
end

function Spores:OnPrimaryAttack(player)

    if player:GetEnergy() >= self:GetEnergyCost() and not GetHasSporeCloudsInRangeWithLifeTime(player:GetOrigin(), kCheckSporeRange, kCheckSporeLifeTime) then
    
        self.primaryAttacking = true
        self:PerformPrimaryAttack(player)
        
    else
        self.primaryAttacking = false
    end
    
end

function Spores:OnPrimaryAttackEnd()
    self.primaryAttacking = false
    self.lastPrimaryAttackEndTime = Shared.GetTime()    
end

function Spores:PerformPrimaryAttack(player)
-- Create long-lasting spore cloud near player that can be used to prevent marines from passing through an area.
    if (Shared.GetTime() - self.lastPrimaryAttackStartTime) > self:GetAttackDelay() then
        self.lastPrimaryAttackStartTime = Shared.GetTime()
    end
end

function Spores:OnHolster(player)
    Ability.OnHolster(self, player)
    self.primaryAttacking = false    
end

function Spores:OnTag(tagName)

    PROFILE("LerkUmbra:OnTag")

    if tagName == "hit" then
    
        local player = self:GetParent()
        
        if player then
            
            if Server then
                
                if player:GetEnergy() >= self:GetEnergyCost() then
                    CreateSporeCloud(self, player:GetModelOrigin(), player)                    
                    player:TriggerEffects("spores_attack")
                    player:DeductAbilityEnergy(self:GetEnergyCost())
                end
                
            end
            
        end
        
    end
    
end

function Spores:OnUpdateAnimationInput(modelMixin)

    PROFILE("Spikes:OnUpdateAnimationInput")
    

    if not self:GetIsSecondaryBlocking() then
    
        modelMixin:SetAnimationInput("ability", "spores")
        
        local activityString = "none"
        if self.primaryAttacking then
            activityString = "primary"
        end
        
        modelMixin:SetAnimationInput("activity", activityString)
    
    end
    
end

Shared.LinkClassToMap("Spores", Spores.kMapName, networkVars)