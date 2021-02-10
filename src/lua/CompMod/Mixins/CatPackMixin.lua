function CatPackMixin:GetCatPackTimeRemaining()
    local percentLeft = 0

    if self.catpackboost then
        -- percentLeft = Clamp( math.abs( (self.timeCatpackboost + kCatPackDuration) - Shared.GetTime() ) / kCatPackDuration, 0.0, 1.0 )
        percentLeft = Clamp(((self.timeCatpackboost + kCatPackDuration) - Shared.GetTime()) / kCatPackDuration, 0.0, 1.0)
    end

    return percentLeft
end