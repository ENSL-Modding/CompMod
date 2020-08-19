local kBlinkSpeed = 14
local kBlinkAddAcceleration = 1
local kMaxSpeed = debug.getupvaluex(Fade.GetMaxSpeed, "kMaxSpeed", false)
local kBlinkMaxSpeed = debug.getupvaluex(Fade.GetMaxSpeed, "kBlinkMaxSpeed", false)
local kBlinkAcceleration = debug.getupvaluex(Fade.ModifyVelocity, "kBlinkAcceleration", false)
local kFadeScanDuration = debug.getupvaluex(Fade.OnProcessMove, "kFadeScanDuration", false)
local kFadeGravityMod = debug.getupvaluex(Fade.OnCreate, "kFadeGravityMod", false)

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

function Fade:GetGroundFriction()
    return 9
end

function Fade:GetAirFriction()
    return (self:GetIsBlinking() or self:GetRecentlyShadowStepped()) and 0 or (0.17  - (GetHasCelerityUpgrade(self) and self:GetSpurLevel() or 0) * 0.01)
end

function Fade:ModifyVelocity(input, velocity, deltaTime)
    if self:GetIsBlinking() then
        local wishDir = self:GetViewCoords().zAxis
        local maxSpeedTable = { maxSpeed = kBlinkSpeed } 
        self:ModifyMaxSpeed(maxSpeedTable, input)
        local prevSpeed = velocity:GetLength()
        local maxSpeed = math.max(prevSpeed, maxSpeedTable.maxSpeed)
        maxSpeed = math.min(kBlinkMaxSpeed, maxSpeed)

        velocity:Add(wishDir * kBlinkAcceleration * deltaTime)

        if velocity:GetLength() > maxSpeed then
            velocity:Normalize()
            velocity:Scale(maxSpeed)
        end

        velocity:Add(wishDir * kBlinkAddAcceleration * deltaTime)
    end
end

function Fade:GetMaxSpeed(possible)
    if possible then
        return kMaxSpeed
    end
    
    if self:GetIsBlinking() then
        return kBlinkSpeed
    end
    
    -- Take into account crouching.
    return kMaxSpeed
end

Fade.GetSpeedScalar = Player.GetSpeedScalar

Shared.LinkClassToMap("Fade", Fade.kMapName, networkVars)
