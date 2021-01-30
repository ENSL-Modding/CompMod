local oldGetCanAttachBabbler = BabblerClingMixin.GetCanAttachBabbler

function BabblerClingMixin:GetCanAttachBabbler()
    if self.isHallucination then
        return false
    end

    return oldGetCanAttachBabbler(self)
end

-- Fix vanilla bug with friendly fire
function BabblerClingMixin:ModifyDamageTaken(damageTable, attacker, doer, damageType, hitPoint, weapon)
    local damage = damageTable.damage or 0
    if damage > 0 and self:GetApplyBabblerShield(damageType) then
        local amount = math.min(damage, self.babblerShieldRemaining)

        if Server then
            self.babblerShieldRemaining = self.babblerShieldRemaining - amount
            self:DestroyNumClingedBabbler(math.floor((self.numBabblers * self.babblerShieldPerBabbler - self.babblerShieldRemaining) / self.babblerShieldPerBabbler ))

            -- CompMod: Check if attacker and ourselves are actually enemies before sending damage numbers/hitsounds
            if GetAreEnemies(self, attacker) then
                if HitSound_IsEnabledForWeapon( weapon ) then
                    -- Damage message will be sent at the end of OnProcessMove by the HitSound system
                    HitSound_RecordHit( attacker, self, amount, hitPoint, 0, weapon )
                else
                    SendDamageMessage( attacker, self:GetId(), amount, hitPoint, 0, weapon )
                end
            end

            SendMarkEnemyMessage( attacker, self, amount, weapon )

            if self.OnTakeDamage then
                self:OnTakeDamage(amount, attacker, doer, hitPoint, nil, damageType, false)
            end
        end

        damageTable.damage = damage - amount
    end
end
