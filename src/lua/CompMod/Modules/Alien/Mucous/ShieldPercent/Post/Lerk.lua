function Lerk:GetMaxShieldAmount()
    return math.floor(math.min(self:GetBaseHealth() * kLerkMucousShieldPercent, kMucousShieldMaxAmount))
end
