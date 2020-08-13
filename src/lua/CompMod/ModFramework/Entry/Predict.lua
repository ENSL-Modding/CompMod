if not Predict then return end

local mod = fw_get_current_mod()
mod:LoadAllModuleFiles("Predict")
local moduleManager = mod:GetModule('modulemanager')
local modules = moduleManager:GetModules()

fw_print_debug(moduleManager, "Loading all predict files")
for _,module in ipairs(modules) do
    fw_print_debug(moduleManager, "Loading predict files for module: %s", module)
    local path = moduleManager:FormatPath(module, "Predict")
    local PredictFiles = {}
    
    Shared.GetMatchingFileNames(path, true, PredictFiles)

    for _,predictFile in ipairs(PredictFiles) do
        fw_print_debug(moduleManager, "Loading predict file: %s", predictFile)
        Script.Load(predictFile)
    end
end