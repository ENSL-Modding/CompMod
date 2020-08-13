if not Client then return end

local mod = fw_get_current_mod()
mod:LoadAllModuleFiles("Client")
local moduleManager = mod:GetModule('modulemanager')
local modules = moduleManager:GetModules()

fw_print_debug(moduleManager, "Loading all client files")
for _,module in ipairs(modules) do
    fw_print_debug(moduleManager, "Loading client files for module: %s", module)
    local path = moduleManager:FormatPath(module, "Client")
    local ClientFiles = {}
    
    Shared.GetMatchingFileNames(path, true, ClientFiles)

    for _,clientFile in ipairs(ClientFiles) do
        fw_print_debug(moduleManager, "Loading client file: %s", clientFile)
        Script.Load(clientFile)
    end
end