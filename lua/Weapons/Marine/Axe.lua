-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Weapons\Axe.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
--                  Max McGuire (max@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Weapon.lua")
Script.Load("lua/AxeVariantMixin.lua")

class 'Axe' (Weapon)

Axe.kMapName = "axe"

Axe.kModelName = PrecacheAsset("models/marine/axe/axe.model")

local kViewModels = GenerateMarineViewModelPaths("axe")
local kAnimationGraph = PrecacheAsset("models/marine/axe/axe_view.animation_graph")

Axe.kRange = 1
Axe.kFloorRange = 0.8

local idleTime = 0
local animFrequency = 10

local networkVars =
{
    sprintAllowed = "boolean",
}
AddMixinNetworkVars(AxeVariantMixin, networkVars)

function Axe:OnCreate()

    Weapon.OnCreate(self)
    
    InitMixin(self, AxeVariantMixin)
    
    self.sprintAllowed = true
    
end

function Axe:OnInitialized()

    Weapon.OnInitialized(self)
    
    self:SetModel(Axe.kModelName)
    
end

function Axe:GetViewModelName(sex, variant)
    return kViewModels[sex][variant]
end

function Axe:GetAnimationGraphName()
    return kAnimationGraph
end

function Axe:GetHUDSlot()
    return kTertiaryWeaponSlot
end

function Axe:GetRange()
	local player = self:GetParent()
	local floorAim = player and player:GetViewCoords().zAxis.y or 0
	floorAim = floorAim * floorAim
    return Axe.kRange + Clamp(floorAim,0,1) * Axe.kFloorRange
end

function Axe:GetShowDamageIndicator()
    return true
end

function Axe:GetSprintAllowed()
    return self.sprintAllowed
end

function Axe:GetDeathIconIndex()
    return kDeathMessageIcon.Axe
end

function Axe:GetIdleAnimations(index)
    local animations = {"idle", "idle_toss", "idle_toss"}
    return animations[index]
end

function Axe:OnDraw(player, previousWeaponMapName)

    Weapon.OnDraw(self, player, previousWeaponMapName)
    
    -- Attach weapon to parent's hand
    self:SetAttachPoint(Weapon.kHumanAttachPoint)
    
    idleTime = Shared.GetTime()
    
end

function Axe:OnHolster(player)

    Weapon.OnHolster(self, player)
    
    self.sprintAllowed = true
    self.primaryAttacking = false
    
end

function Axe:OnPrimaryAttack(player)

    if not self.attacking then
        
        self.sprintAllowed = false
        self.primaryAttacking = true
        
    end

end

function Axe:OnPrimaryAttackEnd(player)
    self.primaryAttacking = false
    idleTime = Shared.GetTime()
end

function Axe_HitCheck(self)
    local player = self:GetParent()
    if player and player:GetIsAlive() then
        local coords = player:GetViewAngles():GetCoords()
        local didHit, target = AttackMeleeCapsule(self, player, kAxeDamage, self:GetRange())

        if not (didHit and target) and coords then -- Only for webs

            local boxTrace = Shared.TraceBox(Vector(0.07,0.07,0.07),
                                             player:GetEyePos(),
                                             player:GetEyePos() + coords.zAxis * (0.50 + self:GetRange()),
                                             CollisionRep.Default, PhysicsMask.AllButPCsAndRagdolls,
                                             EntityFilterTwo(player, self))
            -- Log("Boxtrace entity: %s, target: %s", boxTrace.entity, target)
            if boxTrace.entity and boxTrace.entity:isa("Web") then
                self:DoDamage(kAxeDamage, boxTrace.entity, boxTrace.endPoint, coords.zAxis, "organic", false)
            else
                -- local rayTrace = Shared.TraceRay(eyePos, targetOrigin, CollisionRep.LOS, PhysicsMask.All, EntityFilterAll())
                local rayTrace = Shared.TraceRay(player:GetEyePos(), player:GetEyePos() + coords.zAxis * (0.50 + self:GetRange()), CollisionRep.Default, PhysicsMask.AllButPCsAndRagdolls, EntityFilterTwo(player, self))
                -- Log("Raytrace entity: %s", rayTrace.entity)
                if rayTrace.entity and rayTrace.entity:isa("Web") then
                    self:DoDamage(kAxeDamage, boxTrace.entity, boxTrace.endPoint, coords.zAxis, "organic", false)
                end
            end
        end

        -- if didHit then
        --     Log("Hitting entity: %s", target)
        -- end

    end
end

-- local swipeStart = nil
-- local axeHitDelay = nil
function Axe:OnTag(tagName)

    PROFILE("Axe:OnTag")

    if tagName == "swipe_sound" then
    
        -- swipeStart = Shared.GetTime()
        local player = self:GetParent()
        if player then
            player:TriggerEffects("axe_attack")
        end

        self:AddTimedCallback(Axe_HitCheck, 0.035) -- The avg delay recorded with the "hit" tag
        
    -- elseif tagName == "hit" then

        -- if not axeHitDelay then -- Record the first hit delay as reference
        --     axeHitDelay = Shared.GetTime() - swipeStart
        --     -- Log("Delay: %s", tostring(axeHitDelay))
        -- end
        
    elseif tagName == "attack_end" then
        self.sprintAllowed = true
    elseif tagName == "deploy_end" then
        self.sprintAllowed = true
    elseif tagName == "idle_toss_start" then
        self:TriggerEffects("axe_idle_toss")
    elseif tagName == "idle_fiddle_start" then
        self:TriggerEffects("axe_idle_fiddle")
    end
    
end

function Axe:OnUpdateAnimationInput(modelMixin)

    PROFILE("Axe:OnUpdateAnimationInput")
    
    local player = self:GetParent()
    if player and player:GetIsIdle() then
        local totalTime = math.round(Shared.GetTime() - idleTime)
        if totalTime >= animFrequency*3 then
            idleTime = Shared.GetTime()
        elseif totalTime >= animFrequency*2 and self:GetIdleAnimations(3) then
            modelMixin:SetAnimationInput("idleName", self:GetIdleAnimations(3))
        elseif totalTime >= animFrequency and self:GetIdleAnimations(2) then
            modelMixin:SetAnimationInput("idleName", self:GetIdleAnimations(2))
        elseif totalTime < animFrequency then
            modelMixin:SetAnimationInput("idleName", self:GetIdleAnimations(1))
        end
        
    else
        idleTime = Shared.GetTime()
        modelMixin:SetAnimationInput("idleName", "idle")
    end
    
    local activity = "none"
    if self.primaryAttacking then
        activity = "primary"
    end
    modelMixin:SetAnimationInput("activity", activity)
    
end

function Axe:UseLandIntensity()
    return true
end

Shared.LinkClassToMap("Axe", Axe.kMapName, networkVars)