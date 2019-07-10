local oldGetUpgradedDamage = NS2Gamerules_GetUpgradedDamage

function NS2Gamerules_GetUpgradedDamage(attacker, doer, damage, damageType, hitPoint)
    if doer.kMapName == "swipe" then
        if GetHasTech(attacker, kTechId.AdvancedSwipe, true) then
            return damage * kAdvancedSwipeDamageScalar
        end
    end

    return oldGetUpgradedDamage(attacker, doer, damage, damageType, hitPoint)
end