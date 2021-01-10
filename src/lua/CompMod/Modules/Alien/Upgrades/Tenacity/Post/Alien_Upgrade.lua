local HasUpgrade = debug.getupvaluex(GetHasCelerityUpgrade, "HasUpgrade")

function GetHasTenacityUpgrade(callingEntity)
    return HasUpgrade(callingEntity, kTechId.Tenacity)
end
