local HasUpgrade = debug.getupvaluex(GetHasCelerityUpgrade, "HasUpgrade")

function GetHasScavengerUpgrade(callingEntity)
    return HasUpgrade(callingEntity, kTechId.Scavenger)
end
