local oldModifyHeal = Alien.ModifyHeal
function Alien:ModifyHeal(healTable)
    oldModifyHeal(self, healTable)
    
    if not self.innateRegen and GetHasTenacityUpgrade(self) then
        local shellLevel = self:GetShellLevel()
        local healMultiplier = 1 + (self:GetIsUnderFire() and kTenacityInCombatPercentage or kTenacityOutOfCombatPercentage) * (shellLevel/3)
        healTable.health = healTable.health * healMultiplier
    end
end
