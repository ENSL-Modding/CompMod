-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Weapons\GrenadeLauncher.lua
--
--    Created by:   Andreas Urwalek (andi@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Balance.lua")
Script.Load("lua/Weapons/Marine/ClipWeapon.lua")
Script.Load("lua/PickupableWeaponMixin.lua")
Script.Load("lua/Weapons/Marine/Grenade.lua")
Script.Load("lua/EntityChangeMixin.lua")
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/PointGiverMixin.lua")
Script.Load("lua/AchievementGiverMixin.lua")
Script.Load("lua/GrenadeLauncherVariantMixin.lua")

class 'GrenadeLauncher' (ClipWeapon)

GrenadeLauncher.kMapName = "grenadelauncher"

local networkVars =
{
    -- Only used on the view model, so it can be private.
    emptyPoseParam = "private float (0 to 1 by 0.01)"
}

AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(GrenadeLauncherVariantMixin, networkVars)

GrenadeLauncher.kModelName = PrecacheAsset("models/marine/grenadelauncher/grenadelauncher.model")
local kViewModels = GenerateMarineViewModelPaths("grenadelauncher")

function GrenadeLauncher:OnCreate()

    ClipWeapon.OnCreate(self)
    
    InitMixin(self, PickupableWeaponMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, PointGiverMixin)
    InitMixin(self, AchievementGiverMixin)
    InitMixin(self, GrenadeLauncherVariantMixin)

    self.emptyPoseParam = 0
    
end

function GrenadeLauncher:GetAnimationGraphName()
    return GrenadeLauncherVariantMixin.kGrenadeLauncherAnimationGraph
end

function GrenadeLauncher:GetPickupOrigin()
    return self:GetCoords():TransformPoint(Vector(0.19896945357322693, -0.0013178586959838867, -0.07674674689769745))
end

function GrenadeLauncher:GetViewModelName(sex, variant)
    return kViewModels[sex][variant]
end

function GrenadeLauncher:GetDeathIconIndex()
    return kDeathMessageIcon.Shotgun
end

function GrenadeLauncher:GetHUDSlot()
    return kPrimaryWeaponSlot
end

function GrenadeLauncher:GetClipSize()
    return kGrenadeLauncherClipSize
end

function GrenadeLauncher:GetHasSecondary(player)
    return false
end

function GrenadeLauncher:GetPrimaryCanInterruptReload()
    return true
end

function GrenadeLauncher:GetSecondaryAttackRequiresPress()
    return true
end    

function GrenadeLauncher:GetWeight()
    return kGrenadeLauncherWeight
end

function GrenadeLauncher:UpdateViewModelPoseParameters(viewModel)

    viewModel:SetPoseParam("empty", self.emptyPoseParam)
    
end

local function LoadBullet(self)

    if self.ammo > 0 and self.clip < self:GetClipSize() then
    
        self.clip = self.clip + 1
        self.ammo = self.ammo - 1
        
    end
    
end

function GrenadeLauncher:GetMaxClips()
    return 7
end

function GrenadeLauncher:GetAmmoPackMapName()
    return GrenadeLauncherAmmo.kMapName
end 

function GrenadeLauncher:OnTag(tagName)

    PROFILE("GrenadeLauncher:OnTag")
    
    local continueReloading = false
    if self:GetIsReloading() and tagName == "reload_end" then
    
        continueReloading = true
        self.reloading = false
        
    end
    
    if tagName == "end" then
        self.primaryAttacking = false
    end
    
    ClipWeapon.OnTag(self, tagName)
    
    if tagName == "load_shell" then
        LoadBullet(self)
    -- We have a special case when loading the last shell in the clip.
    elseif tagName == "load_shell_sound" and self.clip < (self:GetClipSize() - 1) then
        self:TriggerEffects("grenadelauncher_reload_shell")
    elseif tagName == "load_shell_sound" then
        self:TriggerEffects("grenadelauncher_reload_shell_last")
    elseif tagName == "reload_start" then
        self:TriggerEffects("grenadelauncher_reload_start")
    elseif tagName == "shut_canister" then
        self:TriggerEffects("grenadelauncher_reload_end")
    end
    
    if continueReloading then
    
        local player = self:GetParent()
        if player then
            player:Reload()
        end
        
    end
    
end

function GrenadeLauncher:OnUpdateAnimationInput(modelMixin)

    ClipWeapon.OnUpdateAnimationInput(self, modelMixin)
    
    modelMixin:SetAnimationInput("loaded_shells", self:GetClip())
    modelMixin:SetAnimationInput("reserve_ammo_empty", self:GetAmmo() == 0)
    
end

GrenadeLauncher.kGrenadeSpeed = 25
GrenadeLauncher.kGrenadeBounce = 0.15
GrenadeLauncher.kGrenadeFriction = 0.35
GrenadeLauncher.kLauncherBarrelDist = 1.5

function GrenadeLauncher:ShootGrenade(player)

    PROFILE("GrenadeLauncher:ShootGrenade")

    self:TriggerEffects("grenadelauncher_attack")

    if Server or (Client and Client.GetIsControllingPlayer()) then

        local viewCoords = player:GetViewCoords()
        local eyePos = player:GetEyePos()

        local floorAim = 1 - math.min(viewCoords.zAxis.y,0) -- this will be a number 1-2

        local startPointTrace = Shared.TraceCapsule(eyePos, eyePos + viewCoords.zAxis * floorAim * GrenadeLauncher.kLauncherBarrelDist, Grenade.kRadius+0.0001, 0, CollisionRep.Move, PhysicsMask.PredictedProjectileGroup, EntityFilterTwo(self, player))
        local startPoint = startPointTrace.endPoint

        local direction = viewCoords.zAxis

        player:CreatePredictedProjectile("Grenade", startPoint, direction * GrenadeLauncher.kGrenadeSpeed, GrenadeLauncher.kGrenadeBounce, GrenadeLauncher.kGrenadeFriction)

    end

end

function GrenadeLauncher:GetUpgradeTechId()
    return kTechId.DetonationTimeTech
end

function GrenadeLauncher:GetIsAffectedByWeaponUpgrades()
    return false
end

function GrenadeLauncher:FirePrimary(player)
    self:ShootGrenade(player)
end

function GrenadeLauncher:OnProcessMove(input)

    ClipWeapon.OnProcessMove(self, input)
    self.emptyPoseParam = Clamp(Slerp(self.emptyPoseParam, ConditionalValue(self.clip == 0, 1, 0), input.time * 1), 0, 1)
    
end

function GrenadeLauncher:ModifyDamageTaken(damageTable, attacker, doer, damageType)
    if damageType ~= kDamageType.Corrode then
        damageTable.damage = 0
    end
end

function GrenadeLauncher:GetCanTakeDamageOverride()
    return self:GetParent() == nil
end

if Server then

    function GrenadeLauncher:GetDestroyOnKill()
        return true
    end
    
    function GrenadeLauncher:GetSendDeathMessageOverride()
        return false
    end 
    
end

if Client then

    function GrenadeLauncher:GetUIDisplaySettings()
        return { xSize = 256, ySize = 256, script = "lua/GUIGrenadelauncherDisplay.lua", variant = self:GetGrenadeLauncherVariant() }
    end
    
end

Shared.LinkClassToMap("GrenadeLauncher", GrenadeLauncher.kMapName, networkVars)
