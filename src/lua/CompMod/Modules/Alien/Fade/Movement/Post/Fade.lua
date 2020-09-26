local kFadeScanDuration = debug.getupvaluex(Fade.OnProcessMove, "kFadeScanDuration")
local kFadeGravityMod = debug.getupvaluex(Fade.OnCreate, "kFadeGravityMod")
local kBlinkAcceleration = debug.getupvaluex(Fade.ModifyVelocity, "kBlinkAcceleration")
local kMaxSpeed = debug.getupvaluex(Fade.GetMaxSpeed, "kMaxSpeed")
-- Max speed when holding blink. Hard cap
local kBlinkMaxSpeed = 25

-- Max speeds for Fade. Soft cap
local kBlinkMaxSpeedBase = 17.5
local kBlinkMaxSpeedCelerity = 19

-- Air friction vars for softcap
local kCelerityFrictionFactor = 0.04
local kFastMovingAirFriction = 0.40

Fade.kGroundFrictionPostBlinkDelay = 1

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
}

function Fade:OnCreate()
    InitMixin(self, BaseMoveMixin, { kGravity = Player.kGravity * kFadeGravityMod })
    InitMixin(self, GroundMoveMixin)
    InitMixin(self, JumpMoveMixin)
    InitMixin(self, CrouchMoveMixin)
    InitMixin(self, CelerityMixin)
    InitMixin(self, CameraHolderMixin, { kFov = kFadeFov })
    
    Alien.OnCreate(self)
    
    InitMixin(self, DissolveMixin)
    InitMixin(self, TunnelUserMixin)
    InitMixin(self, BabblerClingMixin)
    InitMixin(self, FadeVariantMixin)
    
    self.shadowStepDirection = Vector()
    
    if Server then
        self.timeLastScan = 0
        self.isBlinking = false
        self.timeShadowStep = 0
        self.shadowStepping = false
    end
    
    self.etherealStartTime = 0
    self.etherealEndTime = 0
    self.ethereal = false
    self.landedAfterBlink = true
    -- self.crouchBlinked = false
end

function Fade:OnProcessMove(input)
    Alien.OnProcessMove(self, input)
    
    if Server then
        if self.isScanned and self.timeLastScan + kFadeScanDuration < Shared.GetTime() then
            self.isScanned = false
        end
    end
        
    if not self:GetHasMetabolizeAnimationDelay() and self.previousweapon ~= nil and not self:GetIsBlinking() then
        if self:GetActiveWeapon():GetMapName() == Metabolize.kMapName then
            self:SetActiveWeapon(self.previousweapon)
        end
        self.previousweapon = nil
    end

    -- if self.crouchBlinked and self:GetIsOnGround() and bit.band(input.commands, Move.Jump) == 0  then
    --     self.crouchBlinked = false
    -- end
end

function Fade:HandleButtons(input)
    Alien.HandleButtons(self, input)
end

function Fade:GetAirFriction()
    local currentSpeed = self:GetVelocityLength()
    local baseFriction = 0.17

    if self:GetIsBlinking() then
        return 0
    elseif GetHasCelerityUpgrade(self) then
        if currentSpeed > kBlinkMaxSpeedCelerity then
            return kFastMovingAirFriction
        end

        return baseFriction - self:GetSpurLevel() * 0.01
    elseif currentSpeed > kBlinkMaxSpeedBase then
        return kFastMovingAirFriction
    else
        return baseFriction
    end
    -- return (self:GetIsBlinking() or self:GetRecentlyShadowStepped()) and 0 or 0.14
end 

function Fade:GetMaxSpeed(possible)
    if possible then
        return kMaxSpeed
    end
    
    if self:GetIsBlinking() then
        return kBlinkMaxSpeed
    end
    
    -- Take into account crouching.
    return kMaxSpeed
end

Shared.LinkClassToMap("Fade", Fade.kMapName, networkVars)
