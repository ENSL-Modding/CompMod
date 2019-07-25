-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Weapons\Weapon_Server.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

local kPerformExpirationCheckAfterDelay = 1.00

function Weapon:OnInitialized()

    ScriptActor.OnInitialized(self)
    
    self:SetWeaponWorldState(true, true)
    self:SetRelevancy()
    
end

local ignoredWeapons = set { "Pistol", "Rifle" }
function Weapon:CheckExpirationState()
    local ignoredWeapon = ignoredWeapons[self:GetClassName()]
    if ignoredWeapon then return end

    local prevOwner = self.prevOwnerId and self.prevOwnerId ~= Entity.invalidId and Shared.GetEntity(self.prevOwnerId)
    if not prevOwner or not prevOwner.GetIsAlive or not prevOwner:GetIsAlive() then
        return
    end

    local armories = GetEntitiesForTeamWithinRange("Armory", self:GetTeamNumber(), self:GetOrigin(), kArmoryDroppedWeaponAttachRange)
    local nearbyArmory = false
    for _, armory in ipairs(armories) do
        if GetIsUnitActive(armory) then
            nearbyArmory = true
            break
        end
    end


    if nearbyArmory then
        self:PreventExpiration()
    end
end

function Weapon:Dropped(prevOwner)

    self.prevOwnerId = prevOwner:GetId()
    self:SetWeaponWorldState(true)

    --McG: FIXME If previous owner isn't accessible (for whatever reason), below will fail. If !owner, just fall
    if self.physicsModel then
        local viewCoords = prevOwner:GetViewCoords()
        self.physicsModel:AddImpulse(self:GetOrigin(), (viewCoords.zAxis * kMarineWeaponTossImpulse))
        self.physicsModel:SetAngularVelocity(Vector(4,1,1)) --McG: This could be a function of viewer-angles
    end
    
    self.weaponExpirationCheckTime = Shared.GetTime() + kPerformExpirationCheckAfterDelay

end

-- Set to true for being a world weapon, false for when it's carried by a player
function Weapon:SetWeaponWorldState(state, preventExpiration)

    if state ~= self.weaponWorldState then
    
        self.weaponExpirationCheckTime = nil -- Cancel any expiration timer set during a drop
        
        if state then
            
            --FIXME Doesn't consistently affect all model variants (more debugging needed), but this will be resolved when material-swapping is added
            self:SetModelMass( kDefaultMarineWeaponMass )

            -- when dropped weapons always need a physic model
            if not self.physicsModel then
                self.physicsModel = Shared.CreatePhysicsModel(self.physicsModelIndex, true, self:GetCoords(), self)
            end
            
            self:SetPhysicsType(PhysicsType.DynamicServer)
            
            -- So it doesn't affect player movement and so collide callback is called
            self:SetPhysicsGroup(PhysicsGroup.DroppedWeaponGroup)
            self:SetPhysicsGroupFilterMask(PhysicsMask.DroppedWeaponFilter)
            
            if self.physicsModel then
                self.physicsModel:SetCCDEnabled(true)
            end
            
            if not preventExpiration then
                self:StartExpiration()
            else
                self:PreventExpiration()
            end
            
            self:SetIsVisible(true)

            self:SetUpdateRate(kRealTimeUpdateRate)
            
        else
        
            self:SetPhysicsType(PhysicsType.None)
            self:SetPhysicsGroup(PhysicsGroup.WeaponGroup)
            self:SetPhysicsGroupFilterMask(PhysicsMask.None)
            
            if self.physicsModel then
                self.physicsModel:SetCCDEnabled(false)
            end

            self:SetUpdateRate(kDefaultUpdateRate)
            
        end
        
        self.hitGround = false
        
        self.weaponWorldState = state
        
    end
    
end

function Weapon:PreventExpiration()

    self.expireTime = nil
    self.weaponWorldStateTime = nil
    self.weaponExpirationCheckTime = nil

end

function Weapon:CheckExpireTime()
    PROFILE("Weapon:CheckExpireTime")

    if self:GetExpireTime() == 0 then
        return false
    end

    if #GetEntitiesForTeamWithinRange("Marine", self:GetTeamNumber(), self:GetOrigin(), 1.5) > 0 then
        self:StartExpiration()
        return false
    end

    return true
end

function Weapon:StartExpiration(stayTime)

    stayTime = stayTime or kWeaponStayTime
    self.weaponWorldStateTime = Shared.GetTime()
    self.expireTime = Shared.GetTime() + stayTime

    self:AddTimedCallback( self.CheckExpireTime, 0.5)

end

function Weapon:DestroyWeaponPhysics()

    if self.physicsModel then
        Shared.DestroyCollisionObject(self.physicsModel)
        self.physicsModel = nil
    end    

end

function Weapon:OnCapsuleTraceHit(entity)

    PROFILE("Weapon:OnCapsuleTraceHit")

    if self.OnCollision then
        self:OnCollision(entity)
    end
    
end

-- Should only be called when dropped
function Weapon:OnCollision(targetHit)

    if not targetHit then
    
        -- Play weapon drop sound
        if not self.hitGround then
            --McG: Could potentially check self velocity and ground to play sliding sound
            -- above could also be used to trigger multiple drop events (per hit/touch)
            self:TriggerEffects("weapon_dropped")
            self.hitGround = true
            
        end
        
    end
    
end

function Weapon:OnEntityChange(oldId, newId)
    if self.prevOwnerId == oldId then
        self.prevOwnerId = newId or Entity.invalidId
    end
end

Shared.SetPhysicsCollisionCallbackEnabled(PhysicsGroup.DroppedWeaponGroup, 0)
Shared.SetPhysicsCollisionCallbackEnabled(PhysicsGroup.DroppedWeaponGroup, PhysicsGroup.DefaultGroup)
Shared.SetPhysicsCollisionCallbackEnabled(PhysicsGroup.DroppedWeaponGroup, PhysicsGroup.CommanderPropsGroup)
Shared.SetPhysicsCollisionCallbackEnabled(PhysicsGroup.DroppedWeaponGroup, PhysicsGroup.AttachClassGroup)
Shared.SetPhysicsCollisionCallbackEnabled(PhysicsGroup.DroppedWeaponGroup, PhysicsGroup.CommanderUnitGroup)
Shared.SetPhysicsCollisionCallbackEnabled(PhysicsGroup.DroppedWeaponGroup, PhysicsGroup.CollisionGeometryGroup)
