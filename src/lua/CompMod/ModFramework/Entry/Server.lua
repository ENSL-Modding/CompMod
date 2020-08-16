if not Server then return end

local mod = fw_get_current_mod()
mod:LoadAllModuleFiles("Server")
local moduleManager = mod:GetModule('modulemanager')
local modules = moduleManager:GetModules()

fw_print_debug(moduleManager, "Loading all server files")
for _,module in ipairs(modules) do
    fw_print_debug(moduleManager, "Loading server files for module: %s", module)
    local path = moduleManager:FormatPath(module, "Server")
    local ServerFiles = {}
    
    Shared.GetMatchingFileNames(path, true, ServerFiles)

    for _,serverFile in ipairs(ServerFiles) do
        fw_print_debug(moduleManager, "Loading server file: %s", serverFile)
        Script.Load(serverFile)
    end
end
