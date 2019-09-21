function Weapon:CheckExpireTime()
    PROFILE("Weapon:CheckExpireTime")

    if self:GetExpireTime() == 0 then
        return false
    end

    --[[

    Remove stepping on dropped weapons fully refreshes a weapon timer

    if #GetEntitiesForTeamWithinRange("Marine", self:GetTeamNumber(), self:GetOrigin(), 1.5) > 0 then
        self:StartExpiration()
        return false
    end

    ]]
    return true
end