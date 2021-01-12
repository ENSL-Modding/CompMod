local oldBuildDamageTypeRules = debug.getupvaluex(GetDamageByType, "BuildDamageTypeRules")

local function BuildDamageTypeRules()
    oldBuildDamageTypeRules()

    local oldMultiplyForMachineGun = kDamageTypeRules[kDamageType.MachineGun][1]

    local kMachineGunStructureDamageScalar = 1.25
    local function MultiplyForMachineGun(target, _, _, damage, armorFractionUsed, healthPerArmor, damageType)
        if target.GetReceivesStructuralDamage and target:GetReceivesStructuralDamage(damageType) then
            return damage * kMachineGunStructureDamageScalar, armorFractionUsed, healthPerArmor
        else
            return oldMultiplyForMachineGun(target, nil, nil, damage, armorFractionUsed, healthPerArmor)
        end
    end
    
    kDamageTypeRules[kDamageType.MachineGun] = { 
        MultiplyForMachineGun
    }
end

debug.setupvaluex(GetDamageByType, "BuildDamageTypeRules", BuildDamageTypeRules)
