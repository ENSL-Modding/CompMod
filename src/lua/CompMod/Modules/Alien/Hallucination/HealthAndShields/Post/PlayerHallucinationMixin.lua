if not Server then return end

function PlayerHallucinationMixin:ModifyDamageTaken(damageTable, attacker, doer, damageType, hitPoint)

    local multiplier = 8

    if self:isa("Skulk") then
        multiplier = 6

    elseif self:isa("Fade") then
        multiplier = 12

    elseif self:isa("Onos") then
        -- multiplier = 14
        multiplier = 16
    end

    damageTable.damage = damageTable.damage * multiplier

end

function PlayerHallucinationMixin:ModifyHeal(healTable)
    healTable.health = 0
end

function PlayerHallucinationMixin:GetHealthPerBioMass()
    return 0
end
