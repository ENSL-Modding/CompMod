local kMaxShield = kMucousShieldMaxAmount

local oldGetMaxShieldAmount = MucousableMixin.GetMaxShieldAmount
function MucousableMixin:GetMaxShieldAmount()
    if self.isHallucination then
        return 0
    end

    return oldGetMaxShieldAmount(self)
end