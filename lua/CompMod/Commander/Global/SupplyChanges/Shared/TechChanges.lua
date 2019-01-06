Script.Load("lua/SupplyUserMixin.lua")

-- add observatory supply
CompMod:ChangeTech(kTechId.Observatory, {[kTechDataSupply] = kObservatorySupply})

if Server then
    local oldIntitialize = Observatory.OnInitialized
    function Observatory:OnInitialized()
        oldIntitialize(self)
        InitMixin(self, SupplyUserMixin)
    end
end

-- add sentry battery supply
CompMod:ChangeTech(kTechId.SentryBattery, {[kTechDataSupply] = kSentryBatterySupply})

if Server then
    local oldIntitialize = SentryBattery.OnInitialized
    function SentryBattery:OnInitialized()
        oldIntitialize(self)
        InitMixin(self, SupplyUserMixin)
    end
end
