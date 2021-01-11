local oldSetGestationData = Embryo.SetGestationData
function Embryo:SetGestationData(techIds, previousTechIds, healthScalar, armorScalar)
    oldSetGestationData(self, techIds, previousTechIds, healthScalar, armorScalar)

    local maxHealth = LookupTechData(self.gestationTypeTechId, kTechDataMaxHealth) * 0.3 + 100
    maxHealth = math.round(maxHealth * 0.1) * 10

    self:SetMaxHealth(maxHealth)
    self:SetHealth(maxHealth * healthScalar)
end