-- Don't give cybernetic boots to everyone :)
function TechNode:GetResearched()
    if GetWarmupActive() and self.techId ~= kTechId.CyberneticBoots then return true end

    return self.researched
end