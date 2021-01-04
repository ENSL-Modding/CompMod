local kBlinkMaxSpeed = debug.getupvaluex(Fade.ModifyVelocity, "kBlinkMaxSpeed")
local kMaxSpeed = debug.getupvaluex(Fade.GetMaxSpeed, "kMaxSpeed")
local kBlinkAcceleration = debug.getupvaluex(Fade.ModifyVelocity, "kBlinkAcceleration")
local kCelerityFrictionFactor = 0.04
local kFastMovingAirFriction = 0.40

function Fade:GetAirFriction()
    local currentVelocityVector = self:GetVelocityLength()
    return self:GetIsBlinking() and 0 or GetHasCelerityUpgrade(self) and (kFastMovingAirFriction - (kCelerityFrictionFactor * self:GetSpurLevel())) or currentVelocityVector > kEtherealForce and kFastMovingAirFriction or 0.17
end

function Fade:ModifyVelocity(input, velocity, deltaTime)

    if self:GetIsBlinking() then
    
        local wishDir = self:GetViewCoords().zAxis
        local maxSpeedTable = { maxSpeed = kBlinkMaxSpeed }
        self:ModifyMaxSpeed(maxSpeedTable, input)
        local prevSpeed = velocity:GetLength()

        -- the following block will set the acceleration to either the minimum blink ethereal force speed or
        -- the speed a player has built up over successive blinks. Then it will make sure that doesn't exceed
        -- an absolute max.
        local desiredSpeed = math.max(prevSpeed, kEtherealForce)
        local speedCeiling = math.min(maxSpeedTable.maxSpeed, desiredSpeed)
        --local maxSpeed = math.max(prevSpeed, maxSpeedTable.maxSpeed)
        --maxSpeed = math.min(kBlinkMaxSpeed, maxSpeed)

        --velocity:Add(velocity)
        --velocity:Add(wishDir * 17)
        velocity:Add(wishDir * kBlinkAcceleration * deltaTime)
        
        if velocity:GetLength() > speedCeiling then

            velocity:Normalize()
            velocity:Scale(speedCeiling)
            
        end 
        
        -- additional acceleration when holding down blink to exceed max speed
        --velocity:Add(wishDir * kBlinkAddAcceleration * deltaTime)
        
    end

end

function Fade:GetMaxSpeed(possible)

    if possible then
        return kMaxSpeed
    end
    
    if self:GetIsBlinking() then
        return kEtherealForce
    end
    
    -- Take into account crouching.
    return kMaxSpeed
    
end
