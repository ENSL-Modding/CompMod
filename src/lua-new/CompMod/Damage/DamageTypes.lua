local oldBuildDamageTypeRules = debug.getupvaluex(GetDamageByType, "BuildDamageTypeRules")

local function MultiplyFlameAble(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType)
    if target.GetIsFlameAble and target:GetIsFlameAble(damageType) then
        local multi = kFlameableMultiplier
        if target.GetIsFlameableMultiplier then
            -- multi = target:GetIsFlameableMultiplier()
            
            -- Modify GetIsFlameableMultiplier call to pass the doer
            multi = target:GetIsFlameableMultiplier(doer)
        end

        damage = damage * multi
    end
    
    return damage, armorFractionUsed, healthPerArmor
end

local function BuildDamageTypeRules()
    oldBuildDamageTypeRules()
    
    kDamageTypeRules[kDamageType.Flame][1] = MultiplyFlameAble
end

debug.setupvaluex(GetDamageByType, "BuildDamageTypeRules", BuildDamageTypeRules)

local oldGetUpgradedDamage = NS2Gamerules_GetUpgradedDamage
function NS2Gamerules_GetUpgradedDamage(attacker, doer, damage, damageType, hitPoint)
    if doer.kMapName == "swipe" and attacker:GetHasThreeHives() then
        return damage * kAdvancedSwipeDamageScalard
    end

    return oldGetUpgradedDamage(attacker, doer, damage, damageType, hitPoint)
end
