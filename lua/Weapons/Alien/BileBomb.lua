-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Weapons\Alien\BileBomb.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================
Script.Load("lua/Weapons/Alien/Ability.lua")
Script.Load("lua/Weapons/Alien/Bomb.lua")
Script.Load("lua/Weapons/Alien/HealSprayMixin.lua")

class 'BileBomb' (Ability)

BileBomb.kMapName = "bilebomb"

-- part of the players velocity is use for the bomb
local kPlayerVelocityFraction = 1
local kBombVelocity = 11

local kAnimationGraph = PrecacheAsset("models/alien/gorge/gorge_view.animation_graph")

local kBbombViewEffect = PrecacheAsset("cinematics/alien/gorge/bbomb_1p.cinematic")

local networkVars =
{
    firingPrimary = "boolean"
}

AddMixinNetworkVars(HealSprayMixin, networkVars)

function BileBomb:OnCreate()

    Ability.OnCreate(self)
    
    self.firingPrimary = false
    self.timeLastBileBomb = 0
    
    InitMixin(self, HealSprayMixin)
    
end

function BileBomb:GetAnimationGraphName()
    return kAnimationGraph
end

function BileBomb:GetEnergyCost()
    return kBileBombEnergyCost
end

function BileBomb:GetHUDSlot()
    return 3
end

function BileBomb:GetSecondaryTechId()
    return kTechId.Spray
end

local function CreateBombProjectile( self, player )
    
    if not Predict then
        
        -- little bit of a hack to prevent exploitey behavior.  Prevent gorges from bile bombing
        -- through clogs they are trapped inside.
        local startPoint
        local startVelocity
        if GetIsPointInsideClogs(player:GetEyePos()) then
            startPoint = player:GetEyePos()
            startVelocity = Vector(0,0,0)
        else
            local viewCoords = player:GetViewAngles():GetCoords()
            startPoint = player:GetEyePos() + viewCoords.zAxis * 1.5
            startVelocity = viewCoords.zAxis * kBombVelocity
            
            local startPointTrace = Shared.TraceRay(player:GetEyePos(), startPoint, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterOneAndIsa(player, "Babbler"))
            
            startPoint = startPointTrace.endPoint
        end
        
        player:CreatePredictedProjectile( "Bomb", startPoint, startVelocity, 0, 0, nil )
        
    end
    
end

function BileBomb:OnTag(tagName)

    PROFILE("BileBomb:OnTag")

    if self.firingPrimary and tagName == "shoot" then
    
        local player = self:GetParent()
        
        if player then
        
            if Server or (Client and Client.GetIsControllingPlayer()) then
                CreateBombProjectile(self, player)
            end
            
            player:DeductAbilityEnergy(self:GetEnergyCost())            
            self.timeLastBileBomb = Shared.GetTime()
            
            self:TriggerEffects("bilebomb_attack")
            
            if Client then
            
                local cinematic = Client.CreateCinematic(RenderScene.Zone_ViewModel)
                cinematic:SetCinematic(kBbombViewEffect)
                
            end
            
        end
    
    end
    
end

function BileBomb:OnPrimaryAttack(player)

    if player:GetEnergy() >= self:GetEnergyCost() then
    
        self.firingPrimary = true
        
    else
        self.firingPrimary = false
    end  
    
end

function BileBomb:OnPrimaryAttackEnd(player)

    Ability.OnPrimaryAttackEnd(self, player)
    
    self.firingPrimary = false
    
end

function BileBomb:GetTimeLastBomb()
    return self.timeLastBileBomb
end

function BileBomb:OnUpdateAnimationInput(modelMixin)

    PROFILE("BileBomb:OnUpdateAnimationInput")

    modelMixin:SetAnimationInput("ability", "bomb")
    
    local activityString = "none"
    if self.firingPrimary then
        activityString = "primary"
    end
    modelMixin:SetAnimationInput("activity", activityString)
    
end

function BileBomb:GetDeathIconIndex()
    return kDeathMessageIcon.Spray
end

Shared.LinkClassToMap("BileBomb", BileBomb.kMapName, networkVars)
