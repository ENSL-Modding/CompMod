local kMaxSpeed = debug.getupvaluex(Fade.GetMaxSpeed, "kMaxSpeed", false)
local kCelerityFrictionFactor = 0.04
local kFastMovingAirFriction = 0.40

local networkVars =
{
    isScanned = "boolean",
    shadowStepping = "compensated boolean",
    timeShadowStep = "private compensated time",
    shadowStepDirection = "private compensated vector",
    shadowStepSpeed = "private compensated interpolated float",
    
    etherealStartTime = "private time",
    etherealEndTime = "private time",
    
    -- True when we're moving quickly "through the ether"
    ethereal = "compensated boolean",
    
    landedAfterBlink = "private compensated boolean",  
    
    timeMetabolize = "private compensated time",
    
    timeOfLastPhase = "time",

    -- crouchBlinked = "private compensated boolean",
}

local oldOnCreate = Fade.OnCreate
function Fade:OnCreate()
    oldOnCreate(self)

    self.crouchBlinked = nil
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

function Fade:HandleButtons(input)
    Alien.HandleButtons(self, input)
end

function Fade:GetAirFriction()
    local currentVelocityVector = self:GetVelocityLength()
    return (self:GetIsBlinking() or self:GetRecentlyShadowStepped()) and 0 or GetHasCelerityUpgrade(self) and (kFastMovingAirFriction - (kCelerityFrictionFactor * self:GetSpurLevel())) or currentVelocityVector > kEtherealForce and kFastMovingAirFriction or 0.17
end

Shared.LinkClassToMap("Fade", Fade.kMapName, networkVars)
