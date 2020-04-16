local kShotgunDamagePerUpgradeScalar = 0.059
local kShotgunWeapons1DamageScalar = 1 + kShotgunDamagePerUpgradeScalar
local kShotgunWeapons2DamageScalar = 1 + kShotgunDamagePerUpgradeScalar * 2
local kShotgunWeapons3DamageScalar = 1 + kShotgunDamagePerUpgradeScalar * 3

function NS2Gamerules_GetUpgradedDamageScalar(attacker)
    local weapon = attacker:GetActiveWeapon()
    if GetHasTech(attacker, kTechId.Weapons3, true) then
        if weapon and weapon.kMapName == "shotgun" then
            return kShotgunWeapons3DamageScalar
        end
        return kWeapons3DamageScalar
    elseif GetHasTech(attacker, kTechId.Weapons2, true) then
        if weapon and weapon.kMapName == "shotgun" then
            return kShotgunWeapons2DamageScalar
        end
        return kWeapons2DamageScalar
    elseif GetHasTech(attacker, kTechId.Weapons1, true) then
        if weapon and weapon.kMapName == "shotgun" then
            return kShotgunWeapons1DamageScalar
        end
        return kWeapons1DamageScalar
    end

    return 1.0

end