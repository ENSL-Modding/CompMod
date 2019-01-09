Script.Load("lua/SupplyUserMixin.lua")

-- add spur supply
CompMod:ChangeTech(kTechId.Spur, {[kTechDataSupply] = kSpurSupply})
if Server then
    local oldIntitialize = Spur.OnInitialized
    function Spur:OnInitialized()
        oldIntitialize(self)
        InitMixin(self, SupplyUserMixin)
    end
end

-- add shell supply
CompMod:ChangeTech(kTechId.Shell, {[kTechDataSupply] = kShellSupply})
if Server then
    local oldIntitialize = Shell.OnInitialized
    function Shell:OnInitialized()
        oldIntitialize(self)
        InitMixin(self, SupplyUserMixin)
    end
end

-- add veil supply
CompMod:ChangeTech(kTechId.Veil, {[kTechDataSupply] = kVeilSupply})
if Server then
    local oldIntitialize = Veil.OnInitialized
    function Veil:OnInitialized()
        oldIntitialize(self)
        InitMixin(self, SupplyUserMixin)
    end
end
