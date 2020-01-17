local kMaxSpeed = 6.2
local kFadeGravityMod = 1.0
local kFadeScanDuration = 4
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

    if Client then
        InitMixin(self, RailgunTargetMixin)
    end

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

end

-- start the auto-crouch if player blinks and hold crouch for them
function Fade:HandleButtons(input)

    Alien.HandleButtons(self, input)

end

function Fade:GetAirFriction()
    local currentVelocityVector = self:GetVelocityLength()
    return (self:GetIsBlinking() or self:GetRecentlyShadowStepped()) and 0 or GetHasCelerityUpgrade(self) and (kFastMovingAirFriction - (kCelerityFrictionFactor * self:GetSpurLevel())) or currentVelocityVector > kEtherealForce and kFastMovingAirFriction or 0.17
end