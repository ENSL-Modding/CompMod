-- gracefully stolen from the og mod master
if Server then
  local oldMucousableMixinComputeDamageOverrideMixin = MucousableMixin.ComputeDamageOverrideMixin
  function MucousableMixin:ComputeDamageOverrideMixin(attacker, damage, damageType, hitPoint)
    local ogdamage = damage
    damage = oldMucousableMixinComputeDamageOverrideMixin(self, attacker, damage, damageType, hitPoint)
    if damage == 0 and ogdamage > 0 then
      local weapon = attacker:GetActiveWeapon()
      local techId
      
      if weapon then
        if attacker:isa("Alien") and ( weapon.secondaryAttacking or weapon.shootingSpikes) then
          techId = weapon:GetSecondaryTechId()
        else
          techId = weapon:GetTechId()
        end
      end

      if techId and HitSound_IsEnabledForWeapon( techId ) then
        HitSound_RecordHit( attacker, self, ogdamage, self:GetOrigin(), ogdamage, techId )
      else
        SendDamageMessage( attacker, target, amount, point, overkill, weapon )
      end
    end
    return damage
  end
end
