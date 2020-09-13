local mod = CompMod
local techHandler = mod:GetModule('techhandler')
local enumUtils = mod:GetModule('enumutilities')
local logger = mod:GetModule('logger')

local newTechNames = techHandler:GetTechIdsToAdd()

logger:PrintDebug("Adding new TechIds")
for _,v in ipairs(newTechNames) do
    enumUtils:AppendToEnum(kTechId, v)
    logger:PrintDebug("Adding: %s(%s)", v, kTechId[v])
end
