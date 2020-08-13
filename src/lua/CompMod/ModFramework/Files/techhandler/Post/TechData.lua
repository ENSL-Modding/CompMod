local mod = fw_get_current_mod()
local logger = mod:GetModule('logger')
local techHandler = mod:GetModule('techhandler')

local function TechDataChanges(techData)
    local techToAdd = techHandler:GetTechDataToAdd()
    local techToRemove = techHandler:GetTechDataToRemove()
    local techToChange = techHandler:GetTechDataToChange()

    -- Handle changes / removes
    for techIndex,record in ipairs(techData) do
        local techDataId = record[kTechDataId]

        if techToRemove[techDataId] then
            logger:PrintDebug("Removing tech: %s", record[kTechDataDisplayName])
            table.remove(techData, techIndex)
        elseif techToChange[techDataId] then
            logger:PrintDebug("Changing tech: %s", record[kTechDataDisplayName])

            for index, value in pairs(techToChange[techDataId][2]) do
                logger:PrintDebug("Changing [%s] = %s", index, value)
                techData[techIndex][index] = value
            end
        end
    end

    -- Add new tech
    for _,v in ipairs(techToAdd) do
        logger:PrintDebug("Adding tech: %s", v[kTechDataDisplayName])
        table.insert(techData, v)
    end
end

local oldBuildTechData = BuildTechData
function BuildTechData()
    local techData = oldBuildTechData()

    logger:PrintDebug("Applying TechData changes")
    TechDataChanges(techData)

    return techData
end
