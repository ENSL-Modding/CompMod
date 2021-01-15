local removeTechDataValue = "CompModRemoveTechData"

local techToAdd = {
    {
        [kTechDataId] = kTechId.AdvancedSwipe,
        [kTechDataCategory] = kTechId.Fade,
        [kTechDataCostKey] = kAdvancedSwipeCost,
        [kTechDataResearchTimeKey] = kAdvancedSwipeResearchTime,
        [kTechDataDisplayName] = "Advanced Swipe",
        [kTechDataTooltipInfo] = "Increase Swipe damage by 8%",
    },

    {
        [kTechDataId] = kTechId.Neurotoxin,
        [kTechDataCategory] = kTechId.ShadeHive,
        [kTechDataDisplayName] = "Neurotoxin", -- TODO: Use locale
        [kTechDataSponitorCode] = "N",
        [kTechDataTooltipInfo] = "Each hit inflicts a poison toxin, hurting Marines over time",
        [kTechDataCostKey] = 0,
    },

    {
        [kTechDataId] = kTechId.DemolitionsTech,
        [kTechDataCostKey] = kDemolitionsTechResearchCost,
        [kTechDataResearchTimeKey] = kDemolitionsTechResearchTime,
        [kTechDataDisplayName] = "Research Demolitions",
        [kTechDataTooltipInfo] = "Allows Flamethowers and Grenade Launchers to be purchased at the Advanced Armory",
    },

    {
        [kTechDataId] = kTechId.CyberneticBoots,
        [kTechDataCostKey] = 666,
        [kTechDataResearchTimeKey] = 13,
        [kTechDataDisplayName] = "Cybernetic Boots",
        [kTechDataTooltipInfo] = "Upgrades standard TSF boots to a prototype model :)",
        [kTechDataResearchName] = "Cybernetic Boots",
    }
}

local tunnelExtents = {[kTechDataMaxExtents] = Vector(1.2, 0.3, 1.2)}

local techToChange = {
    [kTechId.BuildTunnelEntryOne] = tunnelExtents,
    [kTechId.BuildTunnelEntryTwo] = tunnelExtents,
    [kTechId.BuildTunnelEntryThree] = tunnelExtents,
    [kTechId.BuildTunnelEntryFour] = tunnelExtents,
    [kTechId.Tunnel] = tunnelExtents,
    [kTechId.TunnelRelocate] = tunnelExtents,

    [kTechId.MedPack] = {
        [kCommanderSelectRadius] = removeTechDataValue
    }
}

local techToRemove = {
    [kTechId.GorgeEgg] = true,
    [kTechId.LerkEgg] = true,
    [kTechId.FadeEgg] = true,
    [kTechId.OnosEgg] = true,

    [kTechId.Stab] = true,

    [kTechId.Carapace] = true,
    [kTechId.Focus] = true
}

local function TechDataChanges(techData)
    -- Handle changes / removes
    local indexToRemove = {}
    for techIndex,record in ipairs(techData) do
        local techDataId = record[kTechDataId]

        if techToRemove[techDataId] then
            table.insert(indexToRemove, techIndex)
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

    -- Remove tech
    local offset = 0
    for _,idx in ipairs(indexToRemove) do
        table.remove(techData, idx - offset)
        offset = offset + 1
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
