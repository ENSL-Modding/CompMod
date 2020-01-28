Lerk.kFlapForceStrafe = 8.3

-- Vanilla friction value
Lerk.kMinAirFriction = 0.08

-- High max friction value
Lerk.kMaxAirFriction = 0.5

-- Reach full friction in this many seconds
Lerk.timeToFullFriction = 4

function Lerk:GetAirFriction()
    -- Scale air friction linearly by time, from a minimum value to a maximum value
    -- Reaches full friction value in Lerk.timeToFullFriction seconds
    local timeSinceLastFlap = Shared.GetTime() - self:GetTimeOfLastFlap()
    return Clamp(Lerk.kMaxAirFriction * (timeSinceLastFlap - Lerk.kMinAirFriction / Lerk.timeToFullFriction), Lerk.kMinAirFriction, Lerk.kMaxAirFriction)
end
