Onos.kStampedeDefaultSettings = {
    kChargeImpactForce = 0,
    kChargeDiffForce = 0,
    kChargeUpForce = 0,
    kDisableDuration = 0,
}

Onos.kStampedeOverrideSettings["Exo"] = {
    kChargeImpactForce = 0,
    kChargeDiffForce = 0,
    kChargeUpForce = 0,
    kDisableDuration = 0,
}

local oldProcessMove = Onos.OnProcessMove
function Onos:OnProcessMove(input)
    oldProcessMove(self, input)

    if self:GetIsBoneShieldActive() then
        -- we already know our active weapon is boneshield at this point
        local boneshield = self:GetActiveWeapon()
        local speedScalar =  self:GetVelocity():GetLength() / self:GetMaxSpeed()
        local movementPenalty = speedScalar * kBoneShieldMoveFuelMaxReduction
        local newFuel = boneshield:GetFuel() - movementPenalty

        boneshield:SetFuel(math.max(0, newFuel))
    end
end

function Onos:GetMaxShieldAmount()
    return math.floor(math.min(self:GetBaseHealth() * kOnosMucousShieldPercent, kMucousShieldMaxAmount))
end
