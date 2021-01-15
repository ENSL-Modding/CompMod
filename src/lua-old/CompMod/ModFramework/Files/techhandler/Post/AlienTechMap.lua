local mod = CompMod
local logger = mod:GetModule('logger')
local techHandler = mod:GetModule('techhandler')

local techToAdd = techHandler:GetTechMapTechToAdd().alien
local techToChange = techHandler:GetTechMapTechToChange().alien
local techToRemove = techHandler:GetTechMapTechToRemove().alien

local linesToAdd = techHandler:GetTechMapLineToAdd().alien
local linesToChange = techHandler:GetTechMapLineToChange().alien
local linesToRemove = techHandler:GetTechMapLineToRemove().alien

-- Make a backup of kAlienTechMap
local kAlienTechMapOrig = {}
for k,v in ipairs(kAlienTechMap) do
    kAlienTechMapOrig[k] = v
end

local function CheckForInvalidPoints(line)
    if(type(line) == "table") then
        return (line[1] == 0 and line[2] == 0) or (line[3] == 0 and line[4] == 0)
    end

    return true
end

-- Return true if equal
local function ArrayCompare(arr1, arr2)
    if type(arr1) ~= "table" or type(arr2) ~= "table" then
        return false
    end

    return  arr1[1] == arr2[1]
        and arr1[2] == arr2[2]
        and arr1[3] == arr2[3]
        and arr1[4] == arr2[4]
end

-- Normalize toAdd and toRemove line arrays
-- The values for a given techid in the input array can be either:
-- 1: {{x, y, x1, y1}}
-- 2: {techId1, techId2}
--
-- Output will be in the form [{x, y, x1, y1}, ...]
local function FormatLineInput(lines)
    local output = {}

    for _,lineData in ipairs(lines) do
        local line = {}
        local entries = #lineData
        local validLineData = true
        if entries == 4 then
            line = lineData
        elseif entries == 2 then
            line = GetLinePositionForTechMap(kAlienTechMap, lineData[1], lineData[2])
    
            -- If either of the line points are 0,0 assume above failed, run again on original data
            if CheckForInvalidPoints(line) then
                line = GetLinePositionForTechMap(kAlienTechMapOrig, lineData[1], lineData[2])
            end
        else
            local errStr = "Ignoring malformed line input: {"
            for i=1, #lineData do
                if i > 1 then
                    errStr = errStr .. ", "
                end
                errStr = errStr .. "%s"
            end
            errStr = errStr .. "}"
            logger:PrintWarn(errStr, unpack(lineData))
            validLineData = false
        end

        if validLineData then    
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
    end

    return output
end

-- Apply tech changes first, this is because lines might need to be drawn between techIds that are added 
-- Changes
for i,v in ipairs(kAlienTechMap) do
    local techId = v[1]
    if techToChange[techId] then
        logger:PrintDebug("Changing AlienTechMap tech: %s", (EnumToString(kTechId, techId) or techId))
        kAlienTechMap[i] = techToChange[techId]
    end
end

-- Removes
for _,v in ipairs(techToRemove) do
    logger:PrintDebug("Removing AlienTechMap tech: %s", (EnumToString(kTechId, v) or v))
    for i,tech in ipairs(kAlienTechMap) do
        if tech[1] == v then
            table.remove(kAlienTechMap, i)
            break
        end
    end
end

-- Additions
for _,v in ipairs(techToAdd) do
    logger:PrintDebug("Adding AlienTechMap tech: %s", (EnumToString(kTechId, v[1]) or v[1]))
    table.insert(kAlienTechMap, v)
end

-- Now we can modify lines
-- Changes
for index,v in ipairs(kAlienLines) do
    for _,lineData in ipairs(linesToChange) do
        local oldLine
        local newLine

        if #lineData == 2 or (#lineData == 3 and lineData[3] == false) then
            oldLine = GetLinePositionForTechMap(kAlienTechMapOrig, lineData[1], lineData[2])
            newLine = GetLinePositionForTechMap(kAlienTechMap, lineData[1], lineData[2])
        elseif #lineData == 3 and lineData[3] == true then
            oldLine = lineData[1]
            newLine = lineData[2]
        elseif #lineData == 4 then
            oldLine = GetLinePositionForTechMap(kAlienTechMap, lineData[1], lineData[2])
            newLine = GetLinePositionForTechMap(kAlienTechMap, lineData[3], lineData[4])
        elseif #lineData == 5 then
            if lineData[5] == true then
                oldLine = GetLinePositionForTechMap(kAlienTechMap, lineData[1], lineData[2])
                newLine = GetLinePositionForTechMap(kAlienTechMapOrig, lineData[3], lineData[3])
            elseif lineData[5] == false then
                oldLine = GetLinePositionForTechMap(kAlienTechMapOrig, lineData[1], lineData[2])
                newLine = GetLinePositionForTechMap(kAlienTechMap, lineData[3], lineData[4])
            else
                local errStr = "Ignoring malformed toChange line input: {"
                for i=1, #lineData do
                    if i > 1 then
                        errStr = errStr .. ", "
                    end
                    errStr = errStr .. "%s"
                end
                errStr = errStr .. "}"
                logger:PrintWarn(errStr, unpack(lineData))
            end
        else
            local errStr = "Ignoring malformed toChange line input: {"
            for i=1, #lineData do
                if i > 1 then
                    errStr = errStr .. ", "
                end
                errStr = errStr .. "%s"
            end
            errStr = errStr .. "}"
            logger:PrintWarn(errStr, unpack(lineData))
        end

        if ArrayCompare(oldLine, v) then
            local combined = oldLine
            for _,v in ipairs(newLine) do
                table.insert(combined, v)
            end
            logger:PrintDebug("Changing AlienTechMap line: (%f, %f, %f, %f) to (%f, %f, %f, %f)", unpack(combined))
            kAlienLines[index] = newLine
            break
        end
    end
end

-- Removes
local linesToRemoveFormatted = FormatLineInput(linesToRemove)

for _, line in ipairs(linesToRemoveFormatted) do
    for i,v in ipairs(kAlienLines) do
        if ArrayCompare(line, v) then
            logger:PrintDebug("Deleting AlienTechMap line: %f, %f, %f, %f", unpack(v))
            table.remove(kAlienLines, i)
            break
        end
    end
end

-- Additions
local linesToAddFormatted = FormatLineInput(linesToAdd)

for _,line in ipairs(linesToAddFormatted) do
    logger:PrintDebug("Adding AlienTechMap line: (%f, %f, %f, %f)", unpack(line))
    table.insert(kAlienLines, line)
end
