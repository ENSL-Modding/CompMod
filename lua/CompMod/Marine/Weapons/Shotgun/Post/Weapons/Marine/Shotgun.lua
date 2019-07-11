Shotgun.kDamageFalloffStart = 6
Shotgun.kDamageFalloffEnd = 12
Shotgun.kDamageFalloffReductionFactor = 0.75

--
--  Base: Build 327, Shotgun.lua:41-68
--
--  Recalculate the shotgun rings for rantoSG
--  We also need to add ring damage to the table
--
do
    Shotgun.kSpreadVectors = {}

    local kShotgunRings =
    {
        { distance = 0.0, pelletCount = 1, pelletSize = 0.016, damage=20 },
        { distance = 0.5, pelletCount = 5, pelletSize = 0.016, damage=16 },
        { distance = 1.5, pelletCount = 7, pelletSize = 0.15 , damage=10 },
    }

    local function CalculateShotgunSpreadVectors()
        local circle = math.pi * 2.0
        for _, ring in ipairs(kShotgunRings) do

            local radiansPer = circle / ring.pelletCount
            for pellet = 1, ring.pelletCount do

                local theta = radiansPer * (pellet - 1)
                local x = math.cos(theta) * ring.distance
                local y = math.sin(theta) * ring.distance
                table.insert(Shotgun.kSpreadVectors, {
                    vector=GetNormalizedVector(Vector(x, y, kShotgunSpreadDistance)),
					pelletSize=ring.pelletSize,
                    damage=ring.damage
                })

            end

        end
    end

    CalculateShotgunSpreadVectors()
end
-- END --

--
--  Base: Build 327, Shotgun.lua:215-288(self.FirePrimary)
--
--  We need to modify this function to use the new table layout,
--  and also to implement the damage-per-ring model.
--
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

        local spreadVector = self.kSpreadVectors[bullet].vector

        if not spreadVector then
            break
        end

        local spreadDirection = shootCoords:TransformVector(spreadVector)

        local startPoint = player:GetEyePos() + shootCoords.xAxis * spreadVector.x * self.kStartOffset + shootCoords.yAxis * spreadVector.y * self.kStartOffset

        local endPoint = player:GetEyePos() + spreadDirection * range

		local pelletSize = self.kSpreadVectors[bullet].pelletSize

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

            -- local damage = kShotgunDamage
            local damage = self.kSpreadVectors[bullet].damage

            -- Apply a damage falloff for shotgun damage.
            local distance = (hitPoint - startPoint):GetLength()
            local falloffFactor = Clamp((distance - self.kDamageFalloffStart) / (self.kDamageFalloffEnd - self.kDamageFalloffStart), 0, 1)
            local nearDamage = damage
            local farDamage = damage * self.kDamageFalloffReductionFactor
            damage = nearDamage * (1.0 - falloffFactor) + farDamage * falloffFactor

            self:ApplyBulletGameplayEffects(player, target, hitPoint - hitOffset, direction, damage, "", showTracer and i == numTargets)

            local client = Server and player:GetClient() or Client
            if not Shared.GetIsRunningPrediction() and client.hitRegEnabled then
                RegisterHitEvent(player, bullet, startPoint, trace, damage)
            end

        end

    end

end
-- END
