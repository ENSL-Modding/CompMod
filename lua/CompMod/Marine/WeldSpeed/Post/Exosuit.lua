function Exosuit:OnWeldOverride(doer, elapsedTime)

    -- macs weld marines by only 50% of the rate
    local macMod = (HasMixin(self, "Combat") and self:GetIsInCombat()) and 0.1 or 0.5    
    local weldMod = ( doer ~= nil and doer:isa("MAC") ) and macMod or 1

    if self:GetArmor() < self:GetMaxArmor() then
    
        local addArmor = kExoArmorWeldRate * elapsedTime * weldMod
        self:SetArmor(self:GetArmor() + addArmor)
        
    end
    
end
