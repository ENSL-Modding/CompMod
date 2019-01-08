local kStructurePercentage = 1.25
local kPlayerPercentage = 0.5

CompMod:AppendToEnum(kDamageType, "ClusterFlame")
CompMod:AppendToEnum(kDamageTypeDesc, "Cluster Flame: Deals half damage to players but 25% more damage to structures")

-- try to make setting the dmg type more robust
if not kClusterGrenadeDamageType then
    CompMod:Print("cluster grenade damage type not set. will get overritten by default value", CompMod.kLogLevels.warn)
end

kClusterGrenadeDamageType = kDamageType.ClusterFlame

local function ClusterFlameDamage(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)
    if target.GetReceivesStructuralDamage and target:GetReceivesStructuralDamage(damageType) then
        damage = damage * kStructurePercentage -- structure
    else
        damage = damage * kPlayerPercentage -- player
    end

    return damage, armorFractionUsed, healthPerArmor
end

-- nullify these values to force a rebuild
kDamageTypeGlobalRules = nil
kDamageTypeRules = nil

local oldBuildDamageTypeRules = CompMod:GetLocalVariable(GetDamageByType, "BuildDamageTypeRules")
local function BuildDamageTypeRules()
    oldBuildDamageTypeRules()

    -- ClusterFlame damage rules
    kDamageTypeRules[kDamageType.ClusterFlame] = {}
    table.insert(kDamageTypeRules[kDamageType.ClusterFlame], ClusterFlameDamage)
    -- ------------------------------
end

ReplaceLocals(GetDamageByType, {BuildDamageTypeRules = BuildDamageTypeRules})
