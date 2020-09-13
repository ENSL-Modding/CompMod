Script.Load("lua/CompMod/ModFramework/Utils.lua")
Script.Load("lua/CompMod/Config.lua")

-- Modules
Script.Load("lua/CompMod/ModFramework/Modules/ModuleManagerModule.lua")
Script.Load("lua/CompMod/ModFramework/Modules/LoggerModule.lua")
Script.Load("lua/CompMod/ModFramework/Modules/VersioningModule.lua")
Script.Load("lua/CompMod/ModFramework/Modules/EnumUtilitiesModule.lua")
Script.Load("lua/CompMod/ModFramework/Modules/TechHandlerModule.lua")

class 'ModFramework'

local modFrameworkVersion = "1.0.2"

function ModFramework:Initialize(vm, filehook)
    self.modName = "CompMod"
    fw_print_info(nil, "Initializing %s Framework Version %s", self.modName, modFrameworkVersion)

    -- Validate params
    fw_assert_not_nil(vm, "No VM passed")
    fw_assert_type(vm, "string", "vm")

    fw_assert_not_nil(filehook, "No filehook flag passed")
    fw_assert_type(filehook, "boolean", "filehook")

    -- Move the rest to attributes
    self.vm = vm
    self.filehook = filehook

    -- Init modules array
    self.modules = {}

    -- Load config
    local configFunc = GetModFrameworkConfigCompMod
    local configFuncName = "GetModFrameworkConfigCompMod"

    fw_assert_not_nil(configFunc, "Missing " .. configFuncName .. " in Config.lua")
    fw_assert_type(configFunc, "function", configFuncName)

    self.config = configFunc()
    fw_assert_not_nil(self.config, "No config found in Config.lua")

    -- Setup a global variable to hold our mod
    _G[self.modName] = self
end

function ModFramework:InitModules()
    fw_print_debug(nil, "Initializing all modules")
    self:InitializeModule(LoggerModule)
    self:InitializeModule(VersioningModule)
    self:InitializeModule(EnumUtilitiesModule)
    self:InitializeModule(TechHandlerModule)
    self:InitializeModule(ModuleManagerModule)
end

function ModFramework:InitializeModule(module)
    fw_assert_not_nil(module, "Attempt to initialize nil module")

    module:Initialize(self)
    self:AddModule(module)
    
    if module.hasConfig then
        fw_assert_not_nil(self.config[module:GetModuleName()], "Module has config, but no config entry found.")
        module.config = self.config[module:GetModuleName()]
        module:ValidateConfig()
    end
end

function ModFramework:LoadAllModuleFiles(vm)
    fw_assert_not_nil(vm, "Attempt to initialize module with nil vm")

    for i,v in pairs(self.modules) do
        v:LoadAllFiles(vm)
    end
end

function ModFramework:AddModule(module)
    fw_assert_not_nil(module:GetModuleName(), "Failed to get module name")
    fw_assert_nil(self.modules[module:GetModuleName()], "Config already exists for module: " .. module:GetModuleName())
    self.modules[module:GetModuleName()] = module
end

function ModFramework:GetModule(moduleName)
    fw_assert_not_nil(moduleName, "ModuleName cannot be nil")
    fw_assert_not_nil(self.modules[moduleName], "Failed to get module with name '" .. moduleName .. "'")
    return self.modules[moduleName]
end

function ModFramework:GetModName()
    return self.modName
end
