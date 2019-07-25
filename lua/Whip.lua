-- ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\Whip.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
--
-- Alien structure that provides attacks nearby players with area of effect ballistic attack.
-- Also gives attack/hurt capabilities to the commander. Range should be just shorter than
-- marine sentries.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/AlienStructure.lua")

-- Have idle animations
Script.Load("lua/IdleMixin.lua")
-- can be ordered to move along paths and uses reposition when too close to other AI units
Script.Load("lua/OrdersMixin.lua")
Script.Load("lua/PathingMixin.lua")
Script.Load("lua/RepositioningMixin.lua")
-- ragdolls on death
Script.Load("lua/RagdollMixin.lua")
-- counts against the supply limit
Script.Load("lua/SupplyUserMixin.lua")
-- is responsible for an alien upgrade tech
Script.Load("lua/UpgradableMixin.lua")

-- can open doors
Script.Load("lua/DoorMixin.lua")
-- have targetSelectors that needs cleanup
Script.Load("lua/TargetCacheMixin.lua")
-- Can do damage
Script.Load("lua/DamageMixin.lua")
-- Handle movement
Script.Load("lua/AlienStructureMoveMixin.lua")
Script.Load("lua/ConsumeMixin.lua")


class 'Whip' (AlienStructure)

Whip.kMapName = "whip"

Whip.kModelName = PrecacheAsset("models/alien/whip/whip.model")
Whip.kAnimationGraph = PrecacheAsset("models/alien/whip/whip.animation_graph")

Whip.kUnrootSound = PrecacheAsset("sound/NS2.fev/alien/structures/whip/unroot")
Whip.kRootedSound = PrecacheAsset("sound/NS2.fev/alien/structures/whip/root")
Whip.kWalkingSound = PrecacheAsset("sound/NS2.fev/alien/structures/whip/walk")

Whip.kFov = 360

Whip.kMoveSpeed = 3.5
Whip.kMaxMoveSpeedParam = 10
Whip.kWhipBallParam = "ball"


-- slap data - ROF controlled by animation graph, about-ish 1 second per attack
Whip.kRange = 7
Whip.kDamage = kWhipSlapDamage

-- bombard data - ROF controlled by animation graph, about 4 seconds per attack
Whip.kBombardRange = 20
Whip.kBombSpeed = 20

local networkVars =
    {
        attackYaw = "interpolated integer (0 to 360)",
        
        slapping = "boolean", -- true if we have started a slap attack
        bombarding = "boolean", -- true if we have started a bombard attack
        lastAttackStart = "compensated time", -- Time of the last attack start
        
        rooted = "boolean",
        move_speed = "float", -- used for animation speed
        
        -- used for rooting/unrooting
        unblockTime = "time",
    }

AddMixinNetworkVars(UpgradableMixin, networkVars)
AddMixinNetworkVars(OrdersMixin, networkVars)
AddMixinNetworkVars(IdleMixin, networkVars)
AddMixinNetworkVars(DoorMixin, networkVars)
AddMixinNetworkVars(DamageMixin, networkVars)
AddMixinNetworkVars(AlienStructureMoveMixin, networkVars)
AddMixinNetworkVars(ConsumeMixin, networkVars)

if Server then

    Script.Load("lua/Whip_Server.lua")
    
end

PrecacheAsset("models/alien/whip/ball.surface_shader")

function Whip:OnCreate()

    AlienStructure.OnCreate(self, kMatureWhipHealth, kMatureWhipArmor, kWhipMaturationTime, kWhipBiomass)

    InitMixin(self, UpgradableMixin)
    InitMixin(self, RagdollMixin)
    InitMixin(self, PathingMixin)
    InitMixin(self, OrdersMixin, { kMoveOrderCompleteDistance = kAIMoveOrderCompleteDistance })
    InitMixin(self, DamageMixin)
    InitMixin(self, AlienStructureMoveMixin, { kAlienStructureMoveSound = Whip.kWalkingSound })
    InitMixin(self, ConsumeMixin)
    
    self.attackYaw = 0
    
    self.slapping = false
    self.bombarding = false
    self.lastAttackStart = 0

    self.rooted = true
    self.moving = false
    self.move_speed = 0
    self.unblockTime = 0

    -- to prevent collision with whip bombs
    self:SetPhysicsGroup(PhysicsGroup.WhipGroup)
    
    if Server then

        self.targetId = Entity.invalidId
        self.nextAttackTime = 0
        
    end

end

function Whip:OnInitialized()

    AlienStructure.OnInitialized(self, Whip.kModelName, Whip.kAnimationGraph)
    
    if Server then
        
        InitMixin(self, RepositioningMixin)
        InitMixin(self, SupplyUserMixin)
        InitMixin(self, TargetCacheMixin)
        
        local targetTypes = { kAlienStaticTargets, kAlienMobileTargets }
        self.slapTargetSelector = TargetSelector():Init(self, Whip.kRange, true, targetTypes)
        self.bombardTargetSelector = TargetSelector():Init(self, Whip.kBombardRange, true, targetTypes)
        
    end
    
    InitMixin(self, DoorMixin)
    InitMixin(self, IdleMixin)
    
    self:SetUpdates(true, kRealTimeUpdateRate)
    self.nextSlapStartTime    = 0
    self.nextBombardStartTime = 0
    
end


function Whip:OnDestroy()

    AlienStructure.OnDestroy(self)
    
    if Server then
        self.movingSound = nil
    end
    
end 

-- AlienStructureMove
-- no moving while blocked (rooting/unrooting)
function Whip:GetStructureMoveable()
    return self:GetIsUnblocked()
end

function Whip:GetMaxSpeed()
    return Whip.kMoveSpeed
end

-- ---  RepositionMixin
function Whip:GetCanReposition()
    return self:GetIsBuilt()
end

function Whip:OverrideRepositioningSpeed()
    return Whip.kMoveSpeed
end

-- --

-- --- SleeperMixin
function Whip:GetCanSleep()
    return not self.moving
end

function Whip:GetMinimumAwakeTime()
    return 10
end
-- ---

-- CQ: Is this needed? Used for LOS, but with 360 degree FOV...
function Whip:GetFov()
    return Whip.kFov
end

-- --- DamageMixin
function Whip:GetShowHitIndicator()
    return false
end

-- CQ: This should be something that everyone that can damage anything must implement, DamageMixin?
function Whip:GetDeathIconIndex()
    return kDeathMessageIcon.Whip
end

-- --- UnitStatusMixin
function Whip:OverrideHintString(hintString)

    if self:GetHasUpgrade(kTechId.WhipBombard) then
        return "WHIP_BOMBARD_HINT"
    end
    
    return hintString
    
end

-- --- LOSMixin
function Whip:OverrideVisionRadius()
    -- a whip sees as far as a player
    return kPlayerLOSDistance
end


-- --- ModelMixin
function Whip:OnUpdatePoseParameters()

    local yaw = self.attackYaw
    if yaw >= 135 and yaw <= 225 then
        -- we will be using the bombard_back animation which rotates through
        -- 135 to 225 degrees using 225 to 315. Yea, screwed up.
        yaw = 90 + yaw
    end
    
    self:SetPoseParam("attack_yaw", yaw)
    self:SetPoseParam("move_speed", self.move_speed)
    
    if self:GetHasUpgrade(kTechId.WhipBombard) then
        self:SetPoseParam(Whip.kWhipBallParam, 1.0)
    else
        self:SetPoseParam(Whip.kWhipBallParam, 0)
    end
    
end

function Whip:OnUpdateAnimationInput(modelMixin)

    PROFILE("Whip:OnUpdateAnimationInput")  
    
    local activity = "none"
    local timeFromLastAttack = 0
    local outSyncedBy = Server and 0 or (Shared.GetTime() - self.lastAttackStart)

    -- 0.10s is a good value, you have to set net_lag=700 and net_loss=40 to start seeing
    -- the animation not playing, and even then only once in a while. It's still a permissive.
    -- However, when it plays, it is sync with the hit of the tentacle.
    if outSyncedBy <= 0.10 then
        if self.slapping then
            activity = "primary"
        elseif self.bombarding then
            activity = "secondary"
        end
    end
    
    -- use the back attack animation (both slap and bombard) for this range of yaw
    local useBack = self.attackYaw > 135 and self.attackYaw < 225

    modelMixin:SetAnimationInput("use_back", useBack)    
    modelMixin:SetAnimationInput("activity", activity)
    modelMixin:SetAnimationInput("rooted", self.rooted)
    modelMixin:SetAnimationInput("move", self.moving and "run" or "idle")
    
end
-- --- end ModelMixin

-- --- LiveMixin
function Whip:GetCanGiveDamageOverride()
    -- whips can hurt you
    return true
end


-- --- DoorMixin
function Whip:OnOverrideDoorInteraction(inEntity)
    -- Do not open doors when rooted.
    if (self:GetIsRooted()) then
        return false, 0
    end
    return true, 4
end

function Whip:OnConsumeTriggered()
    local currentOrder = self:GetCurrentOrder()
    if currentOrder ~= nil then
        self:CompletedCurrentOrder()
        self:ClearOrders()
    end
end

function Whip:OnOrderGiven(order)
    --This will cancel Consume if it is running.
    if self:GetIsConsuming() then
        self:CancelResearch()
    end
end

-- CQ: EyePos seems to be somewhat hackish; used in several places but not owned anywhere... predates Mixins
function Whip:GetEyePos()
    return self:GetOrigin() + Vector(0, 1.8, 0) -- self:GetCoords().yAxis * 1.8
end

-- CQ: Predates Mixins, somewhat hackish
function Whip:GetCanBeUsed(player, useSuccessTable)
    useSuccessTable.useSuccess = false    
end

-- --- Commander interface

function Whip:GetTechButtons(techId)

    local techButtons = { kTechId.Slap, kTechId.Move, kTechId.None, kTechId.None,
                    kTechId.None, kTechId.None, kTechId.None, kTechId.Consume }
    
    if self:GetIsMature() then
        techButtons[1] = kTechId.WhipBombard
    end
    
    if self.moving then
        techButtons[2] = kTechId.Stop
    end
    
    return techButtons
    
end

function Whip:GetTechAllowed(techId, techNode, player)
    
    local allowed, canAfford = AlienStructure.GetTechAllowed(self, techId, techNode, player)
    
    if techId == kTechId.Stop then
        allowed = self:GetCurrentOrder() ~= nil
    end
    
    if techId == kTechId.Attack then
        allowed = self:GetIsBuilt() and self.rooted == true
    end

    return allowed and self:GetIsUnblocked(), canAfford
end

function Whip:GetVisualRadius()

    local slapRange = LookupTechData(self:GetTechId(), kVisualRange, nil)
    if self:GetHasUpgrade(kTechId.WhipBombard) then
        return { slapRange, Whip.kBombardRange }
    end
    
    return slapRange
    
end

-- --- end CommanderInterface

-- --- Whip specific
function Whip:GetIsRooted()
    return self.rooted
end

function Whip:GetIsUnblocked()
    return self.unblockTime == 0 or (Shared.GetTime() > self.unblockTime)
end


function Whip:OnUpdate(deltaTime)

    PROFILE("Whip:OnUpdate")
    AlienStructure.OnUpdate(self, deltaTime)
    
    if Server then 
        
        self:UpdateRootState()           
        self:UpdateOrders(deltaTime)
        
        -- CQ: move_speed is used to animate the whip speed.
        -- As GetMaxSpeed is constant, this just toggles between 0 and fixed value depending on moving
        -- Doing it right should probably involve saving the previous origin and calculate the speed
        -- depending on how fast we move
        self.move_speed = self.moving and ( self:GetMaxSpeed() / Whip.kMaxMoveSpeedParam ) or 0

    end  
    
end


-- syncronize the whip_attack_start effect from the animation graph
if Client then

    function Whip:OnTag(tagName)

        PROFILE("ARC:OnTag")
        
        if tagName == "attack_start" then
            self:TriggerEffects("whip_attack_start")        
        end
        
    end

end

Shared.LinkClassToMap("Whip", Whip.kMapName, networkVars, true)
