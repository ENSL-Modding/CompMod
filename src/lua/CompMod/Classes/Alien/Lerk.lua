Lerk.kFlapForceStrafe = 8.3

-- Vanilla friction value
Lerk.kMinAirFriction = 0.08

-- High max friction value
Lerk.kMaxAirFriction = 0.5

-- Reach full friction in this many seconds
Lerk.timeToFullFriction = 3.25

-- Time before friction is higher than vanilla
Lerk.flapGracePeriod = 0.75

function Lerk:GetAirFriction()
    -- Scale air friction linearly by time, from a minimum value to a maximum value
    -- Reaches full friction value in Lerk.timeToFullFriction seconds
    local timeSinceLastFlap = Shared.GetTime() - self:GetTimeOfLastFlap()
    return Clamp((Lerk.kMaxAirFriction / Lerk.timeToFullFriction) * (timeSinceLastFlap - Lerk.flapGracePeriod), Lerk.kMinAirFriction, Lerk.kMaxAirFriction)
end

function Lerk:GetMaxShieldAmount()
    return math.floor(math.min(self:GetBaseHealth() * kLerkMucousShieldPercent, kMucousShieldMaxAmount))
end
