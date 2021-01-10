function Alien:UpdateAutoHeal()
    PROFILE("Alien:UpdateAutoHeal")

    if self:GetIsHealable() and ( not self.timeLastAlienAutoHeal or self.timeLastAlienAutoHeal + kAlienRegenerationTime <= Shared.GetTime() ) then
        -- Double bleh
        if self:isa("Lerk") and GetHasTech(self, kTechId.Roost, true) and self.GetIsWallGripping and self:GetIsWallGripping() then
            self.timeLastAlienAutoHeal = Shared.GetTime()
            return
        end

        local shellLevel = self:GetShellLevel()
        local hasRegenUpgrade = shellLevel > 0 and GetHasRegenerationUpgrade(self)
        local maxHealth = self:GetBaseHealth()
        local innateHealPercent = self:isa("Skulk") and kSkulkInnateRegenerationPercentage or kAlienInnateRegenerationPercentage
        local unclampedHealAmount = innateHealPercent * maxHealth

        -- Bleh
        if GetHasTenacityUpgrade(self) then
            unclampedHealAmount = unclampedHealAmount + unclampedHealAmount * kTenacityInnatePercentage * (shellLevel/3)
        end

        local healRate = Clamp(unclampedHealAmount, kAlienMinInnateRegeneration, kAlienMaxInnateRegeneration)
        
        if self:GetIsUnderFire() then
            local modifier = kAlienRegenerationCombatModifier
            if self.GetCombatInnateRegenOverride then
                modifier = self:GetCombatInnateRegenOverride() or modifier
            end
            healRate = healRate * modifier
        end

        self.innateRegen = true
        self:AddHealth(healRate, false, false, not hasRegenUpgrade, self, true)
        self.innateRegen = false
        self.timeLastAlienAutoHeal = Shared.GetTime()
    end 
end
