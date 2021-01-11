function Skulk:GetMaxShieldAmount()
    return math.floor(math.min(self:GetBaseHealth() * kSkulkMucousShieldPercent, kMucousShieldMaxAmount))
end
