function Fade:GetMaxShieldAmount()
    return math.floor(math.min(self:GetBaseHealth() * kFadeMucousShieldPercent, kMucousShieldMaxAmount))
end
