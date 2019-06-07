local kMachineGunPlayerDamageScalar = 1.5
local function MultiplyForMachineGun(target, _, doer, damage, armorFractionUsed, healthPerArmor)
    if target:isa("Player") or target:isa("Exosuit") then
        damage = math.floor(damage * kMachineGunPlayerDamageScalar)
    end

    return damage, armorFractionUsed, healthPerArmor
end
debug.setupvaluex(GetDamageByType, "MultiplyForMachineGun", MultiplyForMachineGun)
