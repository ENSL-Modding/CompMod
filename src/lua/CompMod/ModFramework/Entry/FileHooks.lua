local function FormatDir(fw, module, hookType)
    return string.format("lua/%s/Modules/%s/%s/*.lua", fw:GetModName(), module, hookType)
end

local modname = debug.getinfo(1, "S").source:gsub("@lua/", ""):gsub("/ModFramework/.*%.lua", "")
Script.Load("lua/" .. modname .. "/ModFramework/ModFramework.lua")

local mod = ModFramework
mod:Initialize(modname, "FileHook", true)
mod:InitModules()
mod:LoadAllModuleFiles("FileHook")

local moduleManager = mod:GetModule('modulemanager')
local logger = mod:GetModule('logger')
local modules = moduleManager:GetModules()

for _,module in ipairs(modules) do
    local types = { "Halt", "Post", "Pre", "Replace" }

    for _,hookType in ipairs(types) do
        local path = FormatDir(mod, module, hookType)
        local files = {}

        Shared.GetMatchingFileNames(path, true, files)

        for _,file in ipairs(files) do
            local vpath = file:gsub(mod:GetModName() .. "/.*/" .. hookType .. "/", "")

            logger:PrintDebug("Hooking file: %s, Vanilla Path: %s, Method: %s", file, vpath, hookType)
            ModLoader.SetupFileHook(vpath, file, hookType:lower())
        end
    end
end
