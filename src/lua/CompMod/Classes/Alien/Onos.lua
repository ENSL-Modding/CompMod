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

function Onos:GetMaxShieldAmount()
    return math.floor(math.min(self:GetBaseHealth() * kOnosMucousShieldPercent, kMucousShieldMaxAmount))
end
