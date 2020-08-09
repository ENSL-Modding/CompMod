function Gorge:GetMaxShieldAmount()
    return math.floor(math.min(self:GetBaseHealth() * kGorgeMucousShieldPercent, kMucousShieldMaxAmount))
end
