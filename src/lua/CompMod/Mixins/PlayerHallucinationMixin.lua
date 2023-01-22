if not Server then return end

function PlayerHallucinationMixin:ModifyHeal(healTable)
    healTable.health = 0
end

function PlayerHallucinationMixin:GetHealthPerBioMass()
    return 0
end
