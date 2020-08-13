local vm = Client and "Client" or Server and "Server" or Predict and "Predict" or nil
local modname = debug.getinfo(1, "S").source:gsub("@lua/", ""):gsub("/ModFramework/.*%.lua", "")
Script.Load("lua/" .. modname .. "/ModFramework/ModFramework.lua")

local mod = ModFramework
mod:Initialize(modname, vm, false)
mod:InitModules()
mod:LoadAllModuleFiles("Shared")

local moduleManager = mod:GetModule('modulemanager')
local modules = moduleManager:GetModules()

fw_print_debug(moduleManager, "Loading all shared files")
for _,module in ipairs(modules) do
    fw_print_debug(moduleManager, "Loading shared files for module: %s", module)
    local path = moduleManager:FormatPath(module, "Shared")
    local SharedFiles = {}
    
    Shared.GetMatchingFileNames(path, true, SharedFiles)

    for _,sharedFile in ipairs(SharedFiles) do
        fw_print_debug(moduleManager, "Loading shared file: %s", sharedFile)
        Script.Load(sharedFile)
    end
end