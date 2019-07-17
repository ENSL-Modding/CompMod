local kAnimationGraph = debug.getupvaluex(PulseGrenadeThrower.GetAnimationGraphName, "kAnimationGraph")
local kAnimationGraphQuickThrow = PrecacheAsset("models/marine/grenades/grenade_view_quickthrow.animation_graph")

function PulseGrenadeThrower:GetAnimationGraphName()
    if self.GetIsQuickThrown and self:GetIsQuickThrown() then
        return kAnimationGraphQuickThrow
    end

    return kAnimationGraph
end
