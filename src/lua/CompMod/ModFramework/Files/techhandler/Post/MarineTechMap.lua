local mod = CompMod
local logger = mod:GetModule('logger')
local techHandler = mod:GetModule('techhandler')

local techToAdd = techHandler:GetTechMapTechToAdd().marine
local techToChange = techHandler:GetTechMapTechToChange().marine
local techToRemove = techHandler:GetTechMapTechToRemove().marine

local linesToAdd = techHandler:GetTechMapLineToAdd().marine
local linesToChange = techHandler:GetTechMapLineToChange().marine
local linesToRemove = techHandler:GetTechMapLineToRemove().marine

-- Make a backup of kMarineTechMap
local kMarineTechMapOrig = {}
for k,v in ipairs(kMarineTechMap) do
    kMarineTechMapOrig[k] = v
end

local function CheckForInvalidPoints(line)
    if(type(line) == "table") then
        return (line[1] == 0 and line[2] == 0) or (line[3] == 0 and line[4] == 0)
    end

    return true
end

-- Return true if equal
local function ArrayCompare(arr1, arr2)
    return  arr1[1] == arr2[1]
        and arr1[2] == arr2[2]
        and arr1[3] == arr2[3]
        and arr1[4] == arr2[4]
end

local function FormatLineInput(lines)
    local output = {}

    for _,lineData in ipairs(lines) do
        local line = {}
        local entries = #lineData
        if entries == 1 then
            line = lineData[1]
        elseif entries == 2 then
            line = GetLinePositionForTechMap(kMarineTechMap, lineData[1], lineData[2])
    
            -- If either of the line points are 0,0 assume above failed, run again on original data
            if CheckForInvalidPoints(line) then
                line = GetLinePositionForTechMap(kMarineTechMapOrig, lineData[1], lineData[2])
            end
        end
    
        if CheckForInvalidPoints(line) then
            local errStr = "Failed to find a line that matches: (%s"
            for i = 2, #lineData do
                errStr = errStr .. ", %s"
            end
            errStr = errStr .. ")"
            logger:PrintWarn(errStr, unpack(lineData))
        else
            table.insert(output, line)
        end
    end

    return output
end

-- Apply tech changes first, this is because lines might need to be drawn between techIds that are added 
-- Changes / Removes
for techIndex,record in ipairs(kMarineTechMap) do
    local techId = record[1]

    if techToChange[techId] then
        logger:PrintDebug("Changing MarineTechMap tech: %s", (EnumToString(kTechId, techId) or techId))
        kMarineTechMap[techIndex] = techToChange[techId]
    end

    if techToRemove[techId] then
        logger:PrintDebug("Removing MarineTechMap tech: %s", (EnumToString(kTechId, techId) or techId))
        table.remove(kMarineTechMap, techIndex)
    end
end

-- Additions
for _,v in ipairs(techToAdd) do
    local techId = v[1]
    logger:PrintDebug("Adding MarineTechMap tech: %s", (EnumToString(kTechId, techId) or techId))
    table.insert(kMarineTechMap, v)
end

-- Now we can modify lines

-- Changes
for _,v in ipairs(kMarineLines) do
    for _,lineData in ipairs(linesToChange) do
        local oldLine = lineData[1]
        local newLine = lineData[2]

        if ArrayCompare(oldLine, newLine) then
            logger:PrintDebug("Changing MarineTechMap line: (%f, %f, %f, %f) to (%f, %f, %f, %f)", unpack(oldLine), unpack(newLine))
            kMarineLines[index] = newLine
        end
    end
end

-- Removes
local linesToRemoveFormatted = FormatLineInput(linesToRemove)
for i,v in ipairs(kMarineLines) do 
    for _,line in ipairs(linesToRemoveFormatted) do
        if ArrayCompare(line, v) then
            logger:PrintDebug("Removing MarineTechMap line: %f, %f, %f, %f", unpack(v))
            table.remove(kMarineLines, i)
        end
    end
end

-- Additions
local linesToAddFormatted = FormatLineInput(linesToAdd)
for _,line in ipairs(linesToAddFormatted) do
    logger:PrintDebug("Adding MarineTechMap line: (%f, %f, %f, %f)", unpack(line))
    table.insert(kMarineLines, line)
end
