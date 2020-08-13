local mod = fw_get_current_mod()
local techHandler = mod:GetModule('techhandler')
local enumUtils = mod:GetModule('enumutilities')
local logger = mod:GetModule('logger')

local newTechNames = techHandler:GetTechIdsToAdd()

fw_print_debug(techHandler, "Adding new TechIds")
for _,v in ipairs(newTechNames) do
    fw_print_debug(techHandler, "Adding: %s", v)
    enumUtils:AppendToEnum(kTechId, v)
end
