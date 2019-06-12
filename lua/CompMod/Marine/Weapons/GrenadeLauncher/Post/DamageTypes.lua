local kGLStructuralDamageScalar = 5
local kGLStructureDamageScalarHive = 4
local function QuintupleForStructure(target, attacker, doer, damage, armorFractionUsed, healthPerArmor, damageType, hitPoint)

    if target.GetReceivesStructuralDamage and target:GetReceivesStructuralDamage(damageType) then
        if target:isa("Hive") then
            print("HIVE")
            damage = damage * kGLStructureDamageScalarHive
        else
            print("NOT HIVE")
            damage = damage * kGLStructuralDamageScalar
        end
    end

    return damage, armorFractionUsed, healthPerArmor
end
debug.setupvaluex(GetDamageByType, "QuintupleForStructure", QuintupleForStructure)
