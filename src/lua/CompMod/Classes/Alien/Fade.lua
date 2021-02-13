Fade.kMetabolizeAnimationDelay = 0.65

function Fade:GetMaxShieldAmount()
    return math.floor(math.min(self:GetBaseHealth() * kFadeMucousShieldPercent, kMucousShieldMaxAmount))
end

function Fade:GetHasMetabolizeAnimationDelay()
    return self.timeMetabolize + Fade.kMetabolizeAnimationDelay > Shared.GetTime()
end
