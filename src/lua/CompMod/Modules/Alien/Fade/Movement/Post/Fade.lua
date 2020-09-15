local kFadeScanDuration = debug.getupvaluex(Fade.OnProcessMove, "kFadeScanDuration")
local kFadeGravityMod = debug.getupvaluex(Fade.OnCreate, "kFadeGravityMod")
-- local kBlinkMaxSpeed = debug.getupvaluex(Fade.ModifyVelocity, "kBlinkMaxSpeed")
local kBlinkAcceleration = debug.getupvaluex(Fade.ModifyVelocity, "kBlinkAcceleration")
local kCelerityFrictionFactor = 0.04
local kFastMovingAirFriction = 0.40
local kBlinkMaxSpeed = 19
local kBlinkAddAcceleration = 1
-- Speed after first blink from standstill
local kBlinkSpeed = 14.25
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
        -- velocity:Add(wishDir * kBlinkAddAcceleration * deltaTime)
        
    end

end

-- function Fade:ModifyVelocity(input, velocity, deltaTime)
--     if self:GetIsBlinking() then
--         local wishDir = self:GetViewCoords().zAxis
--         local maxSpeedTable = { maxSpeed = kBlinkSpeed } 
--         self:ModifyMaxSpeed(maxSpeedTable, input)
--         local prevSpeed = velocity:GetLength()
--         local maxSpeed = math.max(prevSpeed, maxSpeedTable.maxSpeed)
--         maxSpeed = math.min(kBlinkMaxSpeed, maxSpeed)

--         velocity:Add(wishDir * kBlinkAcceleration * deltaTime)

--         if velocity:GetLength() > maxSpeed then
--             velocity:Normalize()
--             velocity:Scale(maxSpeed)
--         end

--         velocity:Add(wishDir * kBlinkAddAcceleration * deltaTime)
--     end
-- end

function Fade:HandleButtons(input)
    Alien.HandleButtons(self, input)
end

function Fade:GetAirFriction()
    return (self:GetIsBlinking() or self:GetRecentlyShadowStepped()) and 0 or 0.15
    -- local currentVelocityVector = self:GetVelocityLength() 
    -- return (self:GetIsBlinking() or self:GetRecentlyShadowStepped()) and 0 or GetHasCelerityUpgrade(self) and (kFastMovingAirFriction - (kCelerityFrictionFactor * self:GetSpurLevel())) or currentVelocityVector > kEtherealForce and kFastMovingAirFriction or 0.17
end 

Shared.LinkClassToMap("Fade", Fade.kMapName, networkVars)
