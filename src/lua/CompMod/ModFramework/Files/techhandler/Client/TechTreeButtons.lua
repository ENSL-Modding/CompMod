local mod = CompMod
local logger = mod:GetModule('logger')
local techHandler = mod:GetModule('techhandler')

local kTechIdToMaterialOffset = debug.getupvaluex(GetMaterialXYOffset, "kTechIdToMaterialOffset")
local toAdd = techHandler:GetMaterialOffsetToAdd()
local toChange = techHandler:GetMaterialOffsetToChange()
local toRemove = techHandler:GetMaterialOffsetToRemove()

for _,v in ipairs(toChange) do
    local techIdName = (EnumToString(kTechId, v[1]) or v[1])

    if not kTechIdToMaterialOffset[v[1]] then
        logger:PrintWarn("Attempt to change TechIdToMaterialOffset value for invalid index: %s", techIdName)
    else
        logger:PrintDebug("Changing TechIdToMaterialOffset [%s] = %s", techIdName, v)
    
        kTechIdToMaterialOffset[v[1]] = v[2]
    end
end

for _,v in ipairs(toRemove) do
    local techIdName = (EnumToString(kTechId, v) or v)

    if not kTechIdToMaterialOffset[i] then
        logger:PrintWarn("Attempt to remove TechIdToMaterialOffset value for invalid index: %s", techIdName)
    else
        logger:PrintDebug("Removing TechIdToMaterialOffset for: %s", techIdName)

        table.remove(kTechIdToMaterialOffset, v)
    end
end

for _,v in ipairs(toAdd) do
    local techIdName = (EnumToString(kTechId, v[1]) or v[1])

    if kTechIdToMaterialOffset[v[1]] then
        logger:PrintWarn("Attempt to add TechIdToMaterialOffset value for already existing index: %s", techIdName)
    else
        logger:PrintDebug("Adding TechIdToMaterialOffset for: %s", techIdName)

        kTechIdToMaterialOffset[v[1]] = v[2]
    end
end
