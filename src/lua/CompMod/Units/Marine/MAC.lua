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

function MAC:OnValidateOrder(order)

    local gameInfo = GetGameInfoEntity()
    if not gameInfo then return true end

    local state = gameInfo:GetState()
    if state <= kGameState.Countdown then
        return false
    end
    
    return true
end
