local kMarineWeaponExpireSlowDistance = 4
local kMarineWeaponExpireSlowRate = 2
local kCallbackInterval

function Weapon:CheckExpireTime()
    PROFILE("Weapon:CheckExpireTime")

    if self:GetExpireTime() == 0 then
        return false
    end

    if #GetEntitiesForTeamWithinRange("Marine", self:GetTeamNumber(), self:GetOrigin(), kMarineWeaponExpireSlowDistance) > 0 then
        -- Increase remaining expireTime by kCallbackInterval / kMarineWeaponExpireSlowRate.
        local now = Shared.GetTime()
        self:StartExpiration((self.expireTime - now) + (kCallbackInterval / kMarineWeaponExpireSlowRate))
        return false
    end

    return true
end

function Weapon:StartExpiration(stayTime)

    stayTime = stayTime or kWeaponStayTime
    self.weaponWorldStateTime = Shared.GetTime()
    self.expireTime = Shared.GetTime() + stayTime

    self:AddTimedCallback( self.CheckExpireTime, kCallbackInterval, false)

end