local removeTechDataValue = "CompModRemoveTechData"

local techToAdd = {
    {
        [kTechDataId] = kTechId.AdvancedSwipe,
        [kTechDataCategory] = kTechId.Fade,
        [kTechDataCostKey] = kAdvancedSwipeCost,
        [kTechDataResearchTimeKey] = kAdvancedSwipeResearchTime,
        [kTechDataDisplayName] = "Advanced Swipe",
        [kTechDataTooltipInfo] = "Increase Swipe damage by 8%",
    }
}

local techToChange = {}

local techToRemove = {
    [kTechId.GorgeEgg] = true,
    [kTechId.LerkEgg] = true,
    [kTechId.FadeEgg] = true,
    [kTechId.OnosEgg] = true,

    [kTechId.Stab] = true
}

local function TechDataChanges(techData)
    -- Handle changes / removes
    for techIndex,record in ipairs(techData) do
        local techDataId = record[kTechDataId]

        if techToRemove[techDataId] then
            table.remove(techData, techIndex)
        elseif techToChange[techDataId] then
            for index, value in pairs(techToChange[techDataId]) do
                if value == removeTechDataValue then
                    techData[techIndex][index] = nil
                else
                    techData[techIndex][index] = value
                end
            end
        end
    end

    -- Add new tech
    for _,v in ipairs(techToAdd) do
        table.insert(techData, v)
    end
end

local oldBuildTechData = BuildTechData
function BuildTechData()
    local techData = oldBuildTechData()
    TechDataChanges(techData)
    return techData
end
