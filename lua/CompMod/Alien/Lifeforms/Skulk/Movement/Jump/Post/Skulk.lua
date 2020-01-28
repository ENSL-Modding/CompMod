Skulk.kBunnyHopMaxGroundTouchDuration = 0.5
Skulk.kWallJumpForce = 5

function Skulk:ModifyJump(input, velocity, jumpVelocity)
    -- we add the bonus in the direction the move is going
    local viewCoords = self:GetViewAngles():GetCoords()

    if self:GetCanWallJump() then

        jumpVelocity.y = 3 + math.min(1, 1 + viewCoords.zAxis.y) * 2

        if not self:GetRecentlyWallJumped() then
            local minimumForce = Skulk.kMinWallJumpForce
            local scalableForce = Skulk.kWallJumpForce
            local verticalForce = Skulk.kVerticalWallJumpForce
            local maxSpeed = self:GetMaxWallJumpSpeed()

            local fraction = 1 - Clamp( velocity:GetLengthXZ() / maxSpeed , 0, 1)

            local force = math.max(minimumForce, scalableForce * fraction)

            local direction = input.move.z == -1 and -1 or 1
            local bonusVec = viewCoords.zAxis * direction
            bonusVec.y = 0
            bonusVec:Normalize()

            bonusVec:Scale(force)

            bonusVec.y = viewCoords.zAxis.y * verticalForce
            jumpVelocity:Add(bonusVec)

        end

        self.timeLastWallJump = Shared.GetTime()

    elseif not self:GetRecentlyJumped() and self:GetTimeGroundTouched() > Shared.GetTime() - Skulk.kBunnyHopMaxGroundTouchDuration then

        local minimumForce = Skulk.kMinBunnyHopForce
        local scalableForce = Skulk.kBunnyHopForce
        local maxSpeed = self:GetMaxBunnyHopSpeed()

        local fraction = 1 - Clamp( velocity:GetLengthXZ() / maxSpeed, 0, 1)
        local force = math.max(minimumForce, scalableForce * fraction)

        local bonusVec = viewCoords:TransformVector(input.move)
        bonusVec.y = 0
        bonusVec:Normalize()

        bonusVec:Scale(force)

        jumpVelocity:Add(bonusVec)
    end

end
