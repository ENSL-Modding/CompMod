function LiveMixin:AddHealth(health, playSound, noArmor, hideEffect, healer, armorScalar)
    if not armorScalar then
        armorScalar = kArmorHealScalar
    end

    if self.OnAddHealth then self:OnAddHealth() end

    -- TakeDamage should be used for negative values.
    assert(health >= 0)

    local total = 0

    if self.GetCanBeHealed and not self:GetCanBeHealed() then
        return 0
    end

    if self.ModifyHeal then

        local healTable = { health = health }
        self:ModifyHeal(healTable)

        health = healTable.health

    end

    if healer and healer.ModifyHealingDone then
        health = healer:ModifyHealingDone(health)
    end

    if self:AmountDamaged() > 0 then

        health = self:ClampHealing( health, noArmor, healer)

        -- Add health first, then armor if we're full
        local healthAdded = math.min(health, self:GetMaxHealth() - self:GetHealth())
        self:SetHealth(math.min(math.max(0, self:GetHealth() + healthAdded), self:GetMaxHealth()))

        local healthToAddToArmor = 0
        if not noArmor then

            healthToAddToArmor = health - healthAdded
            if healthToAddToArmor > 0 then
                self:SetArmor(math.min(math.max(0, self:GetArmor() + healthToAddToArmor * armorScalar ), self:GetMaxArmor()), hideEffect)
            end

        end

        total = healthAdded + healthToAddToArmor

        if total > 0 then

            if Server then

                local time = Shared.GetTime()

                if not hideEffect then

                    self.timeLastVisuallyHealed = time

                end

                self.timeLastHealed = time

            end

        end

    end

    if total > 0 and self.OnHealed then
        self:OnHealed()
    end

    return total

end
