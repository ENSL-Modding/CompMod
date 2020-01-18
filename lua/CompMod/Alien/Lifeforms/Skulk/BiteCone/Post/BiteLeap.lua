local kOuterRangeScalar = 0.65

local function CustomAttackMeleeCapsule(weapon, player, damage, range, optionalCoords, traceRealAttack, scale, priorityFunc, filter, mask)

    scale = scale or 1

    local eyePoint = player:GetEyePos()

    -- if not teamNumber then
    --     teamNumber = GetEnemyTeamNumber( player:GetTeamNumber() )
    -- end

    mask = mask or PhysicsMask.Melee

    local coords = optionalCoords or player:GetViewAngles():GetCoords()
    local axis = coords.zAxis
    local forwardDirection = Vector(coords.zAxis)
    forwardDirection.y = 0

    if forwardDirection:GetLength() ~= 0 then
        forwardDirection:Normalize()
    end

    local width, height = weapon:GetMeleeBase()
    width = scale * width
    height = scale * height

    --[[
    if Client then
        Client.DebugCapsule(eyePoint, eyePoint + axis * range, width, 0, 3)
    end
   --]]

    -- extents defines a world-axis aligned box, so x and z must be the same.
    local extents = Vector(width / 6, height / 6, width / 6)
    if not filter then
        filter = EntityFilterOne(player)
    end
    local middleTrace,middleStart
    local target,endPoint,surface,startPoint

    if not priorityFunc then
        priorityFunc = IsBetterMeleeTarget
    end

    local selectedTrace
    local boxRange

    local outerBoxRange = range * kOuterRangeScalar

    for _, pointIndex in ipairs(kTraceOrder) do

        local dx = pointIndex % 3 - 1
        local dy = math.floor(pointIndex / 3) - 1
        local point = eyePoint + coords.xAxis * (dx * width / 3) + coords.yAxis * (dy * height / 3)

        if dx == 0 and dy == 0 then
            boxRange = range
        else
            boxRange = outerBoxRange
        end

        local trace, sp, ep = TraceMeleeBox(weapon, point, axis, extents, boxRange, mask, filter)

        if dx == 0 and dy == 0 then
            middleTrace, middleStart = trace, sp
            selectedTrace = trace
        end

        if trace.entity and priorityFunc(weapon, player, trace.entity, target) and IsNotBehind(eyePoint, trace.endPoint, forwardDirection) then

            selectedTrace = trace
            target = trace.entity
            startPoint = sp
            endPoint = trace.endPoint
            surface = trace.surface

            surface = GetIsAlienUnit(target) and "organic" or "metal"
            if GetAreEnemies(player, target) then
                if target:isa("Alien") then
                    surface = "organic"
                elseif target:isa("Marine") then
                    surface = "flesh"
                else

                    if HasMixin(target, "Team") then
                        if target:GetTeamType() == kAlienTeamType then
                            surface = "organic"
                        else
                            surface = "metal"
                        end

                    end

                end
            end
        end

    end

    -- if we have not found a target, we use the middleTrace to possibly bite a wall (or when cheats are on, teammates)
    target = target or middleTrace.entity
    endPoint = endPoint or middleTrace.endPoint
    surface = surface or middleTrace.surface
    startPoint = startPoint or middleStart

    local direction = target and (endPoint - startPoint):GetUnit() or coords.zAxis
    return target ~= nil or middleTrace.fraction < 1, target, endPoint, direction, surface, startPoint, selectedTrace


end

function BiteLeap:OnTag(tagName)

    PROFILE("BiteLeap:OnTag")

    if tagName == "hit" then

        local player = self:GetParent()

        if player then

            local range = (player.GetIsEnzymed and player:GetIsEnzymed()) and kEnzymedRange or kRange

            local didHit, target, endPoint = CustomAttackMeleeCapsule(self, player, kBiteDamage, range, nil, false, EntityFilterOneAndIsa(player, "Babbler"))

            if Client and didHit then
                self:TriggerFirstPersonHitEffects(player, target)
            end

            if target and HasMixin(target, "Live") and not target:GetIsAlive() then
                self:TriggerEffects("bite_kill")
            elseif Server and target and target.TriggerEffects and GetReceivesStructuralDamage(target) and (not HasMixin(target, "Live") or target:GetCanTakeDamage()) then
                target:TriggerEffects("bite_structure", {effecthostcoords = Coords.GetTranslation(endPoint), isalien = GetIsAlienUnit(target)})
            end


            self:OnAttack(player)
            self:TriggerEffects("bite_attack")

        end

    end

end