local kClusterStructuralDamageScalar = 2.5
local kClusterPlayerDamageScalar = 0.5
local function ClusterFlameModifier(target, _, _, damage, armorFractionUsed, healthPerArmor, damageType)
    if target:isa("Player") then
        damage = damage * kClusterPlayerDamageScalar
    else
        if target.GetReceivesStructuralDamage and target:GetReceivesStructuralDamage(damageType) then
            damage = damage * kClusterStructuralDamageScalar
        end

        if target.GetIsFlameAble and target:GetIsFlameAble(damageType) then
            local multi = kFlameableMultiplier
            if target.GetIsFlameableMultiplier then
                multi = target:GetIsFlameableMultiplier()
            end

            damage = damage * multi
        end
    end

    return damage, armorFractionUsed, healthPerArmor
end

kDamageTypeGlobalRules = nil
kDamageTypeRules = nil

local oldBuildDamageTypeRules = CompMod:GetLocalVariable(GetDamageByType, "BuildDamageTypeRules")
local function BuildDamageTypeRules()
    oldBuildDamageTypeRules()

    -- ClusterFlame damage rules
    kDamageTypeRules[kDamageType.ClusterFlame] = {
        ClusterFlameModifier
    }
end

ReplaceLocals(GetDamageByType, {BuildDamageTypeRules = BuildDamageTypeRules})
