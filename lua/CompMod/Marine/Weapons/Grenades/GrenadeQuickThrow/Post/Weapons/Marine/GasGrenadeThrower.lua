local kAnimationGraph = debug.getupvaluex(GasGrenadeThrower.GetAnimationGraphName, "kAnimationGraph")
local kAnimationGraphQuickThrow = PrecacheAsset("models/marine/grenades/grenade_view_quickthrow.animation_graph")

function GasGrenadeThrower:GetAnimationGraphName()
    if self.GetIsQuickThrown and self:GetIsQuickThrown() then
        return kAnimationGraphQuickThrow
    end

    return kAnimationGraph
end
