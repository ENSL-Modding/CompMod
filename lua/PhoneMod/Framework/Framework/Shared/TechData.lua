local function TechDataChanges(techData)

    local techToRemove = GetTechToRemove()
    local techToChange = GetTechToChange()

    for techIndex = #techData, 1, -1 do
        local record = techData[techIndex]
        local techDataId = record[kTechDataId]

        if techToRemove[techDataId] then
            ModPrintDebug("Removing tech: " .. record[kTechDataDisplayName], "all")

            table.remove(techData, techIndex)
        elseif techToChange[techDataId] then
            ModPrintDebug("Changing tech: " .. record[kTechDataDisplayName], "all")

            for index, value in pairs(techToChange[techDataId]) do
                techData[techIndex][index] = value
            end
        end
    end

end

local oldBuildTechData = BuildTechData 
function BuildTechData()
    local techData = oldBuildTechData()

    TechDataChanges(techData)

    local techToAdd = GetTechToAdd()
    for _,v in ipairs(techToAdd) do
        ModPrintDebug("Adding tech: " .. v[kTechDataDisplayName])
        table.insert(techData, v)
    end
    
    return techData
end