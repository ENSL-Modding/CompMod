-- OVERRIDING TO FIX CALLBACK MEMORY LEAK
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
            self.expireTime = 0
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

function Weapon:CheckExpireTime()
    PROFILE("Weapon:CheckExpireTime")

    if self:GetExpireTime() == 0 then
        return false
    end

    local timeSinceLastCheck = Shared.GetTime() - self.weaponWorldStateTime
    local timeUntilExpiration = self.expireTime - Shared.GetTime()

    -- Only slow expiration when marine player in range
    if #GetEntitiesForTeamWithinRange("Marine", self:GetTeamNumber(), self:GetOrigin(), kMarineWeaponExpirationSlowDistance) > 0 then
        local adjustedStayTime = timeUntilExpiration + (timeSinceLastCheck * kMarineWeaponExpirationSlowRate)
        self:StartExpiration(adjustedStayTime)
        return false
    end

    -- Always create a new callback to update weaponWorldStateTime
    self:StartExpiration(timeUntilExpiration)
    return false
end

function Weapon:StartExpiration(stayTime)

    stayTime = stayTime or kWeaponStayTime
    self.weaponWorldStateTime = Shared.GetTime()
    self.expireTime = Shared.GetTime() + stayTime

    self:AddTimedCallback( self.CheckExpireTime, 0.5)

end