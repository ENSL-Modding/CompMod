local oldAlienAddHealth = LiveMixin.AddHealth -- Alien.AddHealth
function Alien:AddHealth(health, playSound, noArmor, hideEffect, healer, useEHP)
    assert(health >= 0)

    if not self.innateRegen and GetHasTenacityUpgrade(self) then
        local shellLevel = self:GetShellLevel()
        local healMultiplier = 1 + (self:GetIsUnderFire() and kTenacityInCombatPercentage or kTenacityOutOfCombatPercentage) * (shellLevel/3)
        health = health * healMultiplier
    end

    return oldAlienAddHealth(self, health, playSound, noArmor, hideEffect, healer, useEHP)
end
