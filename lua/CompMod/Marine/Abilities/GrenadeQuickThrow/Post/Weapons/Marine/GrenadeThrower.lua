local networkVars =
{
    grenadesLeft = "integer (0 to ".. kMaxHandGrenades ..")",
    quickThrown = "boolean"
}

function GrenadeThrower:GetIsQuickThrown()
    return self.quickThrown
end

function GrenadeThrower:SetIsQuickThrown(quickThrown)
    assert(type(quickThrown) == "boolean")
    self.quickThrown = quickThrown
end

Shared.LinkClassToMap("GrenadeThrower", GrenadeThrower.kMapName, networkVars)