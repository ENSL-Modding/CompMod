-- higher numbers reduces the spread
Shotgun.kStartOffset = 0
Shotgun.kBulletSize = 0.016

Shotgun.kSpreadVectors = {
    GetNormalizedVector(Vector(-0.01, 0.01, kShotgunSpreadDistance)),

    GetNormalizedVector(Vector(-0.45, 0.45, kShotgunSpreadDistance)),
    GetNormalizedVector(Vector(0.45, 0.45, kShotgunSpreadDistance)),
    GetNormalizedVector(Vector(0.45, -0.45, kShotgunSpreadDistance)),
    GetNormalizedVector(Vector(-0.45, -0.45, kShotgunSpreadDistance)),

    GetNormalizedVector(Vector(-1, 0, kShotgunSpreadDistance)),
    GetNormalizedVector(Vector(1, 0, kShotgunSpreadDistance)),
    GetNormalizedVector(Vector(0, -1, kShotgunSpreadDistance)),
    GetNormalizedVector(Vector(0, 1, kShotgunSpreadDistance)),

    GetNormalizedVector(Vector(-0.35, 0, kShotgunSpreadDistance)),
    GetNormalizedVector(Vector(0.35, 0, kShotgunSpreadDistance)),
    GetNormalizedVector(Vector(0, -0.35, kShotgunSpreadDistance)),
    GetNormalizedVector(Vector(0, 0.35, kShotgunSpreadDistance)),

    GetNormalizedVector(Vector(-0.8, -0.8, kShotgunSpreadDistance)),
    GetNormalizedVector(Vector(-0.8, 0.8, kShotgunSpreadDistance)),
    GetNormalizedVector(Vector(0.8, 0.8, kShotgunSpreadDistance)),
    GetNormalizedVector(Vector(0.8, -0.8, kShotgunSpreadDistance)),

}
function Shotgun:FirePrimary(player)

    local viewAngles = player:GetViewAngles()
    viewAngles.roll = NetworkRandom() * math.pi * 2

    local shootCoords = viewAngles:GetCoords()

    -- Filter ourself out of the trace so that we don't hit ourselves.
    local filter = EntityFilterTwo(player, self)
    local range = self:GetRange()

    local numberBullets = self:GetBulletsPerShot()

    self:TriggerEffects("shotgun_attack_sound")
    self:TriggerEffects("shotgun_attack")


    for bullet = 1, math.min(numberBullets, #self.kSpreadVectors) do

        if not self.kSpreadVectors[bullet] then
            break
        end

        local spreadVector = self.kSpreadVectors[bullet]
        local pelletSize = 0.016
        local spreadDamage = kShotgunDamage

        local spreadDirection = shootCoords:TransformVector(spreadVector)

        local startPoint = player:GetEyePos() + shootCoords.xAxis * spreadVector.x * self.kStartOffset + shootCoords.yAxis * spreadVector.y * self.kStartOffset

        local endPoint = player:GetEyePos() + spreadDirection * range

        local targets, trace, hitPoints = GetBulletTargets(startPoint, endPoint, spreadDirection, pelletSize, filter)

        HandleHitregAnalysis(player, startPoint, endPoint, trace)

        local direction = (trace.endPoint - startPoint):GetUnit()
        local hitOffset = direction * kHitEffectOffset
        local impactPoint = trace.endPoint - hitOffset
        local effectFrequency = self:GetTracerEffectFrequency()
        local showTracer = bullet % effectFrequency == 0

        local numTargets = #targets

        if numTargets == 0 then
            self:ApplyBulletGameplayEffects(player, nil, impactPoint, direction, 0, trace.surface, showTracer)
        end

        if Client and showTracer then
            TriggerFirstPersonTracer(self, impactPoint)
        end

        for i = 1, numTargets do

            local target = targets[i]
            local hitPoint = hitPoints[i]

            local thisTargetDamage = spreadDamage

            self:ApplyBulletGameplayEffects(player, target, hitPoint - hitOffset, direction, thisTargetDamage, "", showTracer and i == numTargets)

            local client = Server and player:GetClient() or Client
            if not Shared.GetIsRunningPrediction() and client.hitRegEnabled then
                RegisterHitEvent(player, bullet, startPoint, trace, thisTargetDamage)
            end

        end

    end

end
