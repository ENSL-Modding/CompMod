local kAnimationGraph = debug.getupvaluex(ClusterGrenadeThrower.GetAnimationGraphName, "kAnimationGraph")
local kAnimationGraphQuickThrow = PrecacheAsset("models/marine/grenades/grenade_view_quickthrow.animation_graph")

function ClusterGrenadeThrower:GetAnimationGraphName()
    if self.GetIsQuickThrown and self:GetIsQuickThrown() then
        return kAnimationGraphQuickThrow
    end

    return kAnimationGraph
end
