local kWhipAttackScanInterval = 0.33
local kSlapAfterBombardTimeout = Shared.GetAnimationLength(Whip.kModelName, "attack")
local kBombardAfterBombardTimeout = Shared.GetAnimationLength(Whip.kModelName, "bombard")

-- Delay between the animation start and the "hit" tagName. Values here are hardcoded and
-- will be replaced with the more accurate, real one at the first whip "hit" tag recorded.
local kAnimationHitTagAtSet       = { slap = false, bombard = false }
local kSlapAnimationHitTagAt      = kSlapAfterBombardTimeout / 2.5
local kBombardAnimationHitTagAt   = kBombardAfterBombardTimeout / 11.5

function Whip:UpdateAttacks()
    -- Update targetSelector ranges
    local whipRange = self:GetWhipRange()
    local whipRangeSquared = whipRange^2
    self.slapTargetSelector:SetRange(whipRange)
    
    local bombardRange = self:GetBombardRange()
    local bombardRangeSquared = bombardRange^2
    self.bombardTargetSelector:SetRange(bombardRange)

    if self:GetCanStartSlapAttack() then
        local newTarget = self:TryAttack(self.slapTargetSelector, true, whipRangeSquared)
        self.nextAttackScanTime = Shared.GetTime() + kWhipAttackScanInterval
        if newTarget then
            self:FaceTarget(newTarget)
            self.targetId = newTarget:GetId()
            self.slapping = true
            self.bombarding = false
        end
    end

    if not self.slapping and self:GetCanStartBombardAttack() then
        local newTarget = self:TryAttack(self.bombardTargetSelector, false, bombardRangeSquared)
        self.nextAttackScanTime = Shared.GetTime() + kWhipAttackScanInterval
        if newTarget then
            self:FaceTarget(newTarget)
            self.targetId = newTarget:GetId()
            self.bombarding = true
            self.slapping = false;
        end
    end
end

function Whip:OnAttackHitBlockedTarget(target)
    local whipRange = self:GetWhipRange()
    local whipRangeSquared = whipRange^2
    local targets = GetEntitiesForTeamWithinRange("Player", GetEnemyTeamNumber(self:GetTeamNumber()), self:GetOrigin(), whipRange)
    Shared.SortEntitiesByDistance(target:GetOrigin(), targets)

    for _, newTarget in ipairs(targets) do
        if newTarget ~= target then
            self.targetId = newTarget:GetId()
            newTarget = self:TryAttack(self.slapTargetSelector, true, whipRangeSquared)

            local isTargetValid = newTarget and newTarget:isa("Player") and HasMixin(newTarget, "Live") and newTarget:GetIsAlive()
            if isTargetValid and self:IsEntBlockingLos(newTarget, target)
            then
                return true, newTarget
            end
        end
    end

    return false, nil
end

function Whip:OnAttackHit()
    -- Prevent OnAttackHit to be called multiple times in a raw
    if self.attackStarted and (self.slapping or self.bombarding) and not self:GetIsOnFire() then
        local success = false
        local target = Shared.GetEntity(self.targetId)
        local eyePos = GetEntityEyePos(self)
        local selector = (self.slapping and self.slapTargetSelector or self.bombardTargetSelector)

        if target then
            local whipRangeSquared = self:GetWhipRange()^2
            local targetValidated = self.slapping and self:GetCanAttackTarget(selector, target, whipRangeSquared) or true
            if not targetValidated then
                targetValidated, target = self:OnAttackHitBlockedTarget(target)
            end

            if targetValidated then
                -- Guestimate HitTagAt vars, they *should* be updated at the next hit tag but they're not always.
                -- Since this value can change depending on if we're AdrenalineRushed or not
                kSlapAnimationHitTagAt = self:GetSlapAfterBombardTimeout() / 2.5
                kBombardAnimationHitTagAt = self:GetBombardAfterBombardTimeout() / 11.5
                if self.slapping then
                    if self:GetCanAttackTarget(selector, target, whipRangeSquared) then
                        self:SlapTarget(target)
                        success = true
                    end
                else
                    self:BombardTarget(target)
                    success = true
                end 
            end
        end

        if not success then
            self.targetId = Entity.invalidId
        end
    end

    self.attackStarted = false
    self:EndAttack()
end

function Whip:GetSlapAfterBombardTimeout()
    local timeout = kSlapAfterBombardTimeout
    if self.isAdrenalineRushed then
        return timeout - timeout * self.adrenalineRushLevel * kAdrenalineRushIntervalScalar
    end

    return timeout
end

function Whip:GetBombardAfterBombardTimeout()
    local timeout = kBombardAfterBombardTimeout
    if self.isAdrenalineRushed then
        return timeout - timeout * self.adrenalineRushLevel * kAdrenalineRushIntervalScalar
    end

    return timeout
end

function Whip:SlapTarget(target)
    self:FaceTarget(target)
    -- where we hit
    local now = Shared.GetTime()
    local targetPoint = target:GetEngagementPoint()
    local attackOrigin = self:GetEyePos()
    local hitDirection = targetPoint - attackOrigin
    hitDirection:Normalize()
    -- fudge a bit - put the point of attack 0.5m short of the target
    local hitPosition = targetPoint - hitDirection * 0.5

    self:DoDamage(Whip.kDamage, target, hitPosition, hitDirection, nil, true)
    self:TriggerEffects("whip_attack")

    local slapTimeout = self:GetSlapAfterBombardTimeout()
    local nextSlapStartTime    = now + (slapTimeout - kSlapAnimationHitTagAt)
    local nextBombardStartTime = now + (slapTimeout - kSlapAnimationHitTagAt)

    self.nextSlapStartTime    = math.max(nextSlapStartTime,    self.nextSlapStartTime)
    self.nextBombardStartTime = math.max(nextBombardStartTime, self.nextBombardStartTime)
end

function Whip:BombardTarget(target)
    self:FaceTarget(target)
    -- This seems to fail completly; we get really weird values from the Whip_Ball point,
    local now = Shared.GetTime()
    local bombStart,success = self:GetAttachPointOrigin("Whip_Ball")
    if not success then
        Log("%s: no Whip_Ball point?", self)
        bombStart = self:GetOrigin() + Vector(0,1,0);
    end

    local targetPos = target:GetEngagementPoint()

    local direction = Ballistics.GetAimDirection(bombStart, targetPos, Whip.kBombSpeed)
    if direction then
        self:FlingBomb(bombStart, targetPos, direction, Whip.kBombSpeed)
    end

    local slapTimeout = self:GetSlapAfterBombardTimeout()
    local bombardTimeout = self:GetBombardAfterBombardTimeout()
    local nextSlapStartTime    = now + (slapTimeout    - kBombardAnimationHitTagAt)
    local nextBombardStartTime = now + (bombardTimeout - kBombardAnimationHitTagAt)

    self.nextSlapStartTime    = math.max(nextSlapStartTime,    self.nextSlapStartTime)
    self.nextBombardStartTime = math.max(nextBombardStartTime, self.nextBombardStartTime)
end

function Whip:OnTag(tagName)
    PROFILE("Whip:OnTag")
    if tagName == "hit" and self.attackStarted then
        if not kAnimationHitTagAtSet.slap and self.slapping then
            kAnimationHitTagAtSet.slap    = true
            kSlapAnimationHitTagAt        = (Shared.GetTime() - self.lastAttackStart)
            -- Log("%s : Setting slap hit tag at %s", self, tostring(kBombardAnimationHitTagAt))
        end

        if not kAnimationHitTagAtSet.bombard and self.bombarding then
            kAnimationHitTagAtSet.bombard = true
            kBombardAnimationHitTagAt     = (Shared.GetTime() - self.lastAttackStart)
            -- Log("%s : Setting bombard hit tag at %s", self, tostring(kBombardAnimationHitTagAt))
        end

        self:OnAttackHit()
    end

    -- The 'tagName == "hit"' is not reliable and sometime is not triggered at all (obscure reasons).
    -- To fix that we use a manual callback that is reliable, so each time a whip has an animation,
    -- it is guaranted it will hit if the target is still in range and in sight.
    if (tagName == "slap_start" or tagName == "bombard_start") and not self.attackStarted then
        local animationLength = (tagName == "slap_start" and kSlapAnimationHitTagAt or kBombardAnimationHitTagAt)

        self.attackStarted = true
        self.lastAttackStart = Shared.GetTime()
        self:OnAttackStart()
        self:AddTimedCallback(Whip.OnAttackHit, animationLength)
    end

    if tagName == "slap_end" or tagName == "bombard_end" then
        self:OnAttackEnd()
    end
end
