
class 'EventTarget' (Entity)

EventTarget.kMapName = "target_point"

gTargets = gTargets or {}

local networkVars = 
{
    targetName = "string (256)"
}

function EventTarget:OnCreate()
end

function EventTarget:OnInitialized()
        
    if self.targetName == '' then
        Log("Warning!  Detected target with a blank name!  Skipping.")
        return
    end
    
    if gTargets[self.targetName] ~= nil then
        Log("Warning!  Detected target with duplicate name!  Skipping. (name is %s)", self.targetName)
        return
    else
        gTargets[self.targetName] = self
    end
    
end

function GetTargetPositionByName(name)
    
    if gTargets[name] then
        return gTargets[name]:GetOrigin()
    end
    
    error(string.format("Target point '%s' not found!", name), 2)
    
end

-- Does not throw an error if target doesn't exist.
function GetTargetPositionByNameNoError(name)
    
    if gTargets[name] then
        return gTargets[name]:GetOrigin()
    end
    
end

function GetTargetPositionFarthestFromPoint(pos, targetNames)
    
    local farthest = targetNames[1]
    local farthestPos = GetTargetPositionByName(farthest)
    local farthestDist = (farthestPos - pos):GetLengthSquared()
    
    if #targetNames == 1 then
        return farthestPos
    end
    
    for i=2, #targetNames do
        local candidate = targetNames[i]
        local candidatePos = GetTargetPositionByName(candidate)
        local candidateDist = (candidatePos - pos):GetLengthSquared()
        
        if candidateDist > farthestDist then
            farthest = candidate
            farthestPos = candidatePos
            farthestDist = candidateDist
        end
    end
    
    return farthestPos
    
end

Shared.LinkClassToMap("EventTarget", EventTarget.kMapName, networkVars)