function RadiusDamage(entities, centerOrigin, radius, fullDamage, doer, ignoreLOS, fallOffFunc, useXZDistance)

    assert(HasMixin(doer, "Damage"))

    local radiusSquared = radius * radius

    -- Do damage to every target in range
    for _, target in ipairs(entities) do

        -- Find most representative point to hit
        local targetOrigin = GetTargetOrigin(target)

        local distanceVector = targetOrigin - centerOrigin

        -- Trace line to each target to make sure it's not blocked by a wall
        local wallBetween = false
        local distanceFromTarget
        if useXZDistance then
            distanceFromTarget = distanceVector:GetLengthSquaredXZ()
        else
            distanceFromTarget = distanceVector:GetLengthSquared()
        end

        if not ignoreLOS then
            wallBetween = GetWallBetween(centerOrigin, targetOrigin, target)
        end

        if (ignoreLOS or not wallBetween) and (distanceFromTarget <= radiusSquared) then

            -- Damage falloff
            local distanceFraction = distanceFromTarget / radiusSquared
            if fallOffFunc then
                distanceFraction = fallOffFunc(distanceFraction)
            end
            distanceFraction = Clamp(distanceFraction, 0, 1)

            local damage = fullDamage * (1 - distanceFraction)

            local damageDirection = distanceVector
            damageDirection:Normalize()

            -- we can't hit world geometry, so don't pass any surface params and let DamageMixin decide
            doer:DoDamage(damage, target, centerOrigin, damageDirection, "none")

        end

    end

end
