local kCystClogFlameableMultiplier = 7.0

local function MultiplyFlameAble(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)
    if target.GetIsFlameAble and target:GetIsFlameAble(damageType) then
        if target:isa('Cyst') or target:isa('Clog') then
          damage = damage * kCystClogFlameableMultiplier
        else
          damage = damage * kFlameableMultiplier
        end
    end

    return damage, armorFractionUsed, healthPerArmor
end
debug.setupvaluex(GetDamageByType, "MultiplyFlameAble", MultiplyFlameAble)
