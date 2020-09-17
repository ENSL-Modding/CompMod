local kFadeScanDuration = debug.getupvaluex(Fade.OnProcessMove, "kFadeScanDuration")
local kFadeGravityMod = debug.getupvaluex(Fade.OnCreate, "kFadeGravityMod")
local kBlinkAcceleration = debug.getupvaluex(Fade.ModifyVelocity, "kBlinkAcceleration")
local kMaxSpeed = debug.getupvaluex(Fade.GetMaxSpeed, "kMaxSpeed")
local kBlinkMaxSpeed = 20
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

function Fade:ModifyVelocity(input, velocity, deltaTime)
    if self:GetIsBlinking() then
        local wishDir = self:GetViewCoords().zAxis
        local maxSpeedTable = { maxSpeed = kBlinkMaxSpeed }
        self:ModifyMaxSpeed(maxSpeedTable, input)  
        local prevSpeed = velocity:GetLength()

        -- the following block will set the acceleration to either the minimum blink ethereal force speed or
        -- the speed a player has built up over successive blinks. Then it will make sure that doesn't exceed
        -- an absolute max.
        local desiredSpeed = math.max(prevSpeed, kBlinkSpeed)
        local speedCeiling = math.min(maxSpeedTable.maxSpeed, desiredSpeed)

        velocity:Add(wishDir * kBlinkAcceleration * deltaTime)
        
        if velocity:GetLength() > speedCeiling then
            velocity:Normalize()
            velocity:Scale(speedCeiling)
        end 
    end
end

function Fade:HandleButtons(input)
    Alien.HandleButtons(self, input)
end

function Fade:GetAirFriction()
    return (self:GetIsBlinking() or self:GetRecentlyShadowStepped()) and 0 or 0.14
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
