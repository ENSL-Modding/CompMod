function SpikesMixin:FireSpikes()

    local player = self:GetParent()
    local viewAngles = player:GetViewAngles()
    viewAngles.roll = NetworkRandom() * math.pi * 2

    -- Filter ourself out of the trace so that we don't hit ourselves.
    local filter = EntityFilterOneAndIsa(player, "Babbler")
    local range = kSpikesRange

    local numSpikes = kSpikesPerShot
    local startPoint = player:GetEyePos()

    local viewCoords = player:GetViewCoords()

    self.spiked = true
    self.silenced = GetHasSilenceUpgrade(player) and player:GetVeilLevel() > 0

    for spike = 1, numSpikes do

        -- Calculate spread for each shot, in case they differ
        local spreadDirection = CalculateSpread(viewCoords, kSpikeSpread, NetworkRandom)

        local endPoint = startPoint + spreadDirection * range
        local targets, trace, hitPoints = GetSpikeTargets(startPoint, endPoint, spreadDirection, kSpikeSize, filter)

        HandleHitregAnalysis(player, startPoint, endPoint, trace)

        local numTargets = #targets
        local direction = (trace.endPoint - startPoint):GetUnit()

        for i = 1, numTargets do
            local target = targets[i]
            local hitPoint = hitPoints[i]

            local damage = kSpikeDamage
            self:DoDamage(damage, target, hitPoint - direction * kHitEffectOffset, direction, trace.surface, true, math.random() < 0.75)

            local client = Server and player:GetClient() or Client
            if client and not Shared.GetIsRunningPrediction() and client.hitRegEnabled then
                RegisterHitEvent(player, spike, startPoint, trace, damage)
            end

        end

        if numTargets == 0 and trace.fraction < 1 then
            local damage = 0
            self:DoDamage(damage, trace.entity, trace.endPoint - direction * kHitEffectOffset, direction, trace.surface, true, math.random() < 0.75)
        end

    end

end

function GetSpikeTargets(startPoint, endPoint, spreadDirection, spikeSize, filter)
    local targets = {}
    local hitPoints = {}
    local trace

    for _ = 1, 20 do
        local traceFilter
        if filter then

            traceFilter = function(test)
                return EntityFilterList(targets)(test) or filter(test)
            end
        else
            traceFilter = EntityFilterList(targets)
        end

        trace = Shared.TraceRay(startPoint, endPoint, CollisionRep.Damage, PhysicsMask.Bullets, traceFilter)
        if not trace.entity then

            -- Limit the box trace to the point where the ray hit as an optimization.
            local boxTraceEndPoint = trace.fraction ~= 1 and trace.endPoint or endPoint
            local extents = GetDirectedExtentsForDiameter(spreadDirection, spikeSize)
            trace = Shared.TraceBox(extents, startPoint, boxTraceEndPoint, CollisionRep.Damage, PhysicsMask.Bullets, traceFilter)

        end

        if trace.entity and not table.icontains(targets, trace.entity) then

            table.insert(targets, trace.entity)
            table.insert(hitPoints, trace.endPoint)

        end

        local deadTarget = trace.entity and HasMixin(trace.entity, "Live") and not trace.entity:GetIsAlive()
        local softTarget = trace.entity and HasMixin(trace.entity, "SoftTarget")
        local ragdollTarget = trace.entity and trace.entity:isa("Ragdoll")
        if (not trace.entity or not (deadTarget or softTarget or ragdollTarget)) or trace.fraction == 1 then
            break
        end
    end

    return targets, trace, hitPoints
end