--Check for diabling global
if gDisableUWEBalance then return end

local rootPath = "lua/ns2_beta"

-- Use powershell's dir -Directory or similair to get the list for now
local moduleNames = {
    "ARC",
    "Camoflauge",
    "Fade",
    "FlameDamage",
    "Gorge",
    "Grenades",
    "GUIChangelog",
    "Lerk",
    "MarineCommAbilities",
    "MG",
    "Mine",
    "Onos",
    "Shared",
    "Shotgun",
    "Skulk",
    "Ultility",
}


ModuleLoader = {}

function ModuleLoader:LoadModuleFileHooks(moduleName)
    local folders = { "halt", "post", "pre", "replace" }

    for i = 1, #folders do
        local hookType = folders[i]
        local modulePath = string.format("%s/modules/%s/%s", rootPath, moduleName, hookType)
        local filePattern = string.format("%s/*.lua", modulePath)
        local files = {}
        Shared.GetMatchingFileNames(filePattern, true, files)

        for j = 1, #files do
            local filePath = files[j]
            local vanillaFilePath = string.gsub(filePath, modulePath, "lua")
            ModLoader.SetupFileHook(vanillaFilePath, filePath, hookType)
        end
    end

end

function ModuleLoader:LoadModuleShared(moduleName)
    local file = string.format("%s/modules/%s/Shared.lua", rootPath, moduleName)
    if GetFileExists(file) then
        Script.Load(file)
    end
end

function ModuleLoader:LoadModulePredict(moduleName)
    local file = string.format("%s/modules/%s/Predict.lua", rootPath, moduleName)
    if GetFileExists(file) then
        Script.Load(file)
    end
end

function ModuleLoader:LoadModuleClient(moduleName)
    local file = string.format("%s/modules/%s/Client.lua", rootPath, moduleName)
    if GetFileExists(file) then
        Script.Load(file)
    end

    file = string.format("%s/modules/%s/Locale.lua", rootPath, moduleName)
    if GetFileExists(file) then
        Script.Load(file)
    end
end

function ModuleLoader:LoadModuleServer(moduleName)
    local file = string.format("%s/modules/%s/Server.lua", rootPath, moduleName)
    if GetFileExists(file) then
        Script.Load(file)
    end
end

local Loaders = {
    Filehooks = ModuleLoader.LoadModuleFileHooks,
    Shared = ModuleLoader.LoadModuleShared,
    Predict = ModuleLoader.LoadModulePredict,
    Client = ModuleLoader.LoadModuleClient,
    Server = ModuleLoader.LoadModuleServer
}
function ModuleLoader:LoadModule(moduleName, mode)
    if Loaders[mode] then
        Loaders[mode](self, moduleName)
    end
end

function ModuleLoader:LoadAllModules(mode)
    for i = 1, #moduleNames do
        local moduleName = moduleNames[i]
        self:LoadModule(moduleName, mode)
    end
end

-- Set up Filehooks
do
    ModuleLoader:LoadAllModules("Filehooks")
end