-- TODO: Implement this properly by implementing Alien:GetCanVampirismBeUsedOn, removing Exo:GetCanVampirismBeUsedOn and removing the below

--Utility function to apply chamber-upgraded modifications to alien damage
--Note: this should _always_ be called BEFORE damage-type specific modifications are done (i.e. Light vs Normal vs Structural, etc)
function NS2Gamerules_GetUpgradedAlienDamage( target, attacker, doer, damage, armorFractionUsed, _, damageType )

    if not doer then return damage, armorFractionUsed end

    local isAffectedByCrush = doer.GetIsAffectedByCrush and attacker:GetHasUpgrade( kTechId.Crush ) and doer:GetIsAffectedByCrush()
    local isAffectedByVampirism = doer.GetVampiricLeechScalar and attacker:GetHasUpgrade( kTechId.Vampirism )
    local isAffectedByFocus = doer.GetIsAffectedByFocus and attacker:GetHasUpgrade( kTechId.Focus ) and doer:GetIsAffectedByFocus()

    if isAffectedByCrush then --Crush
        local crushLevel = attacker:GetSpurLevel()
        if crushLevel > 0 then
            if target:isa("Exo") or target:isa("Exosuit") or target.GetReceivesStructuralDamage and target:GetReceivesStructuralDamage(damageType) then
                damage = damage + ( damage * ( crushLevel * kAlienCrushDamagePercentByLevel ) )
            elseif target:isa("Player") then
                armorFractionUsed = kBaseArmorUseFraction + ( crushLevel * kAlienCrushDamagePercentByLevel )
            end
        end
        
    end
    
    if Server then

        -- Vampirism
        if isAffectedByVampirism then
            local vampirismLevel = attacker:GetShellLevel()
            if vampirismLevel > 0 then
                if attacker:GetIsHealable() and target:isa("Marine") then
                    local scalar = doer:GetVampiricLeechScalar()
                    if scalar > 0 then

                        local focusBonus = 1
                        if isAffectedByFocus then
                            focusBonus = 1 + doer:GetFocusAttackCooldown()
                        end

                        local maxHealth = attacker:GetMaxHealth()
                        local leechedHealth =  maxHealth * vampirismLevel * scalar * focusBonus

                        attacker:AddOverShield(leechedHealth)

                    end
                end
            end
        end
        
    end

    --Focus
    if isAffectedByFocus then
        local veilLevel = attacker:GetVeilLevel()
        local damageBonus = doer:GetMaxFocusBonusDamage()
        damage = damage * (1 + (veilLevel/3) * damageBonus) --1.0, 1.333, 1.666, 2
    end
    
    --!!!Note: if more than damage and armor fraction modified, be certain the calling-point of this function is updated
    return damage, armorFractionUsed
    
end