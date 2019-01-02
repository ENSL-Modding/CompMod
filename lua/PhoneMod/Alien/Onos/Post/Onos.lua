-- change max speed
Onos.kMaxSpeed = 7.5

-- stampede changes
Onos.kStampedeDefaultSettings =
{
    kChargeImpactForce = 0,
    kChargeDiffForce = 0,
    kChargeUpForce = 0,
    kDisableDuration = 0.05,
}

Onos.kStampedeOverrideSettings = Onos.kStampedeOverrideSettings or {}
Onos.kStampedeOverrideSettings["Exo"] =
{
    kChargeImpactForce = 0,
    kChargeDiffForce = 0,
    kChargeUpForce = 0,
    kDisableDuration = 0.05,
}
