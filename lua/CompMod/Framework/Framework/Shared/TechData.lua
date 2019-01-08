local kModName = debug.getinfo(1, "S").source:gsub("@lua/", ""):gsub("/Framework/.*%.lua", "")
local Mod = _G[kModName]

local function TechDataChanges(techData)

    local techToRemove = Mod:GetTechToRemove()
    local techToChange = Mod:GetTechToChange()

    for techIndex = #techData, 1, -1 do
        local record = techData[techIndex]
        local techDataId = record[kTechDataId]

        if techToRemove[techDataId] then
            Mod:PrintDebug("Removing tech: " .. record[kTechDataDisplayName], "all")

            table.remove(techData, techIndex)
        elseif techToChange[techDataId] then
            Mod:PrintDebug("Changing tech: " .. record[kTechDataDisplayName], "all")

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

    local techToAdd = Mod:GetTechToAdd()
    for _,v in ipairs(techToAdd) do
        Mod:PrintDebug("Adding tech: " .. v[kTechDataDisplayName])
        table.insert(techData, v)
    end

    return techData
end
