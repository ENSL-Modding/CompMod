function MAC:GetMoveSpeed()
    local maxSpeedTable = { maxSpeed = MAC.kMoveSpeed }
    if self.rolloutSourceFactory then
        maxSpeedTable.maxSpeed = MAC.kRolloutSpeed
    elseif not self:GetIsInCombat() then
        maxSpeedTable.maxSpeed = maxSpeedTable.maxSpeed * kMACOutOfCombatSpeedScalar
    end
    self:ModifyMaxSpeed(maxSpeedTable)

    return maxSpeedTable.maxSpeed 
end
