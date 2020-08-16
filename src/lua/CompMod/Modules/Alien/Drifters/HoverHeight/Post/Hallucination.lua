kHallucinationHoverHeight = 1

if Server then
    function Hallucination:GetHoverHeight()
        if self.assignedTechId == kTechId.Lerk or self.assignedTechId == kTechId.Drifter then
            return kHallucinationHoverHeight
        else
            return 0
        end
    end
end