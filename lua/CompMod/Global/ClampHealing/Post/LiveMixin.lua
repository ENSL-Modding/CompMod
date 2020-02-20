function LiveMixin:ClampHealing( healAmount, noArmor, healer )
    -- Don't clamp system healing (growth/spawning)
    if not healer then return healAmount end

    -- Only clamp healing for aliens
    local isAlien = HasMixin( self, "Team") and self:GetTeamType() == kAlienTeamType
    if not isAlien then return healAmount end

    local now = Shared.GetTime()

    -- Init history
    if not self.healHistory then
        self.healHistory = {
            lastUpdate = now,
            healingReceived = 0
        }
    end

    local ehpMax = self:GetMaxHealth() + self:GetMaxArmor() * kHealthPointsPerArmor
    local ehpSoftCap = ehpMax * kHealingClampMaxHPAmount / kHealingClampInterval -- Maximum amount of ehp that can be received un-taxed

    -- Amortize for time past since last heal
    local timeDiff = now - self.healHistory.lastUpdate
    if timeDiff > 0 then
        self.healHistory.healingReceived = math.max( self.healHistory.healingReceived - timeDiff * ehpSoftCap, 0)
    end

    -- Amount of ehp that can be added before we start getting taxed.
    local ehpRemainUntilCap = math.max(ehpSoftCap - self.healHistory.healingReceived, 0)

    -- Split heal amount into two sums: amount that pushes us up to the cap (if enough), and amount over the cap.
    local nonTaxableHealAmount = math.min(healAmount, ehpRemainUntilCap)
    local taxableHealAmount = healAmount - nonTaxableHealAmount
    assert(nonTaxableHealAmount >= 0)
    assert(taxableHealAmount >= 0)

    healAmount = nonTaxableHealAmount + taxableHealAmount * kHealingClampReductionScalar

    self.healHistory.healingReceived = self.healHistory.healingReceived + healAmount
    self.healHistory.lastUpdate = now

    return healAmount

end
