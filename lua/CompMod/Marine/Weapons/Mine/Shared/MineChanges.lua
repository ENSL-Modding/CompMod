-- The *proper* way to do this would be to use ReplaceLocals on Arm.
-- We would be able to use GetLocalFunction to get a reference to Arm from
-- any non-local function that calls it; however the only non-local function
-- that calls Arm is declared only in the Server vm, therefore it's not
-- possible to get a reference to Arm in the Client and Predict vms. Both of
-- which need it.
-- Hence the mess that's about to follow.
--
-- All this to replace a local...

local kTimeArmed = 0.1 -- lowered from 0.17.

-- fluff
local kTimedDestruction = 0.5
local kMineChainDetonateRange = 3

local kMineCameraShakeDistance = 15
local kMineMinShakeIntensity = 0.01
local kMineMaxShakeIntensity = 0.13

-- use our new local
local function Detonate(self, armFunc)

    local hitEntities = GetEntitiesWithMixinWithinRange("Live", self:GetOrigin(), kMineDetonateRange)
    RadiusDamage(hitEntities, self:GetOrigin(), kMineDetonateRange, kMineDamage, self, false, SineFalloff)

    -- Start the timed destruction sequence for any mine within range of this exploded mine.
    local nearbyMines = GetEntitiesWithinRange("Mine", self:GetOrigin(), kMineChainDetonateRange)
    for _, mine in ipairs(nearbyMines) do

        if mine ~= self and not mine.armed then
            mine:AddTimedCallback(function() armFunc(mine) end, (math.random() + math.random()) * kTimedDestruction)
        end

    end

    local params = {}
    params[kEffectHostCoords] = Coords.GetLookIn( self:GetOrigin(), self:GetCoords().zAxis )

    params[kEffectSurface] = "metal"

    self:TriggerEffects("mine_explode", params)

    DestroyEntity(self)

    CreateExplosionDecals(self)
    TriggerCameraShake(self, kMineMinShakeIntensity, kMineMaxShakeIntensity, kMineCameraShakeDistance)

end

local function Arm(self)

    if not self.armed then

        self:AddTimedCallback(function() Detonate(self, Arm) end, kTimeArmed)

        self:TriggerEffects("mine_arm")

        self.armed = true

    end

end

-- use our new function
local function CheckEntityExplodesMine(self, entity)

    if not self.active then
        return false
    end

    if entity:isa("Hallucination") or entity.isHallucination then
        return false
    end

    if not HasMixin(entity, "Team") or GetEnemyTeamNumber(self:GetTeamNumber()) ~= entity:GetTeamNumber() then
        return false
    end

    if not HasMixin(entity, "Live") or not entity:GetIsAlive() or not entity:GetCanTakeDamage() then
        return false
    end

    if not (entity:isa("Player") or entity:isa("Whip") or entity:isa("Babbler")) then
        return false
    end

    if entity:isa("Commander") then
        return false
    end

    if entity:isa("Fade") and entity:GetIsBlinking() then

        return false

    end

    local minePos = self:GetEngagementPoint()
    local targetPos = entity:GetEngagementPoint()
    -- Do not trigger through walls. But do trigger through other entities.
    if not GetWallBetween(minePos, targetPos, entity) then

        -- If this fails, targets can sit in trigger, no "polling" update performed.
        Arm(self)
        return true

    end

    return false

end

local function CheckAllEntsInTriggerExplodeMine(self)

    local ents = self:GetEntitiesInTrigger()
    for e = 1, #ents do
        CheckEntityExplodesMine(self, ents[e])
    end

end

if Server then

  ReplaceLocals(Mine.OnTouchInfestation, {Arm = Arm})
  ReplaceLocals(Mine.OnStun, {Arm = Arm})
  ReplaceLocals(Mine.OnKill, {Arm = Arm})
  ReplaceLocals(Mine.OnTriggerEntered, {CheckEntityExplodesMine = CheckEntityExplodesMine})
  ReplaceLocals(Mine.OnUpdate, {CheckAllEntsInTriggerExplodeMine = CheckAllEntsInTriggerExplodeMine})

end

ReplaceLocals(Mine.OnInitialized, {CheckAllEntsInTriggerExplodeMine = CheckAllEntsInTriggerExplodeMine})
