function Ability:GetNeuroCooldown()
    return self:GetAttackAnimationDuration() * kNeurotoxinPercentageAttackSpeedIncrease
end

function Ability:DoAbilityNeurotoxinCooldown(player)

    if player:GetHasUpgrade( kTechId.Neurotoxin ) then

        local veilLevel = player:GetVeilLevel()
        local neuroCooldown = veilLevel > 0 and self:GetNeuroCooldown() or 0

        local animationDuration = self:GetAttackAnimationDuration()
        local cooldown = animationDuration * (1 + neuroCooldown)

        -- factor in effects like enzyme and pulse grenade hits
        local attackPeriodFactor = 1.0

        -- general attack speed modifications by self
        if player.ModifyAttackSpeed then
            local attackSpeedTable = { attackSpeed = attackPeriodFactor }
            player:ModifyAttackSpeed(attackSpeedTable)
            attackPeriodFactor = attackSpeedTable.attackSpeed
        end

        -- pulse grenades/overcharge
        if player.electrified then
            attackPeriodFactor = attackPeriodFactor * kElectrifiedAttackSpeed
        end

        -- enzyme
        if player:GetIsEnzymed() then
            attackPeriodFactor = attackPeriodFactor * kEnzymeAttackSpeed
        end

        self.nextAttackTime = Shared.GetTime() + (cooldown / attackPeriodFactor)

        return neuroCooldown
    end

    return 0
end

function Ability:OnAttack(player, energyCost)
    energyCost = energyCost or self:GetEnergyCost()

    if self:GetIsAffectedByNeurotoxin() then
        self:DoAbilityNeurotoxinCooldown(player)
    end

    player:DeductAbilityEnergy(energyCost)
end
