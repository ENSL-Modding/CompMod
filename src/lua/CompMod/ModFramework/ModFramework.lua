class 'ModFramework'

function ModFramework:Initialize(modname, vm, filehook)
    -- Use basic asserts for the modname as this is required before we can load the Util script.
    assert(modname, "ModFramework: No modname passed")
    assert(type(modname) == "string", "ModFramework: Modname not a string")

    -- Modname validated so move to attribute
    self.modName = modname

    -- Load required scripts
    self:LoadScript("ModFramework/Utils.lua")
    self:LoadScript("Config.lua")

    -- Validate the rest of the params
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
    self:LoadConfig()

    -- Setup a global variable to hold our mod
    _G[self.modName] = self
end

function ModFramework:LoadScript(path, module)
    if fw_print_debug then
        fw_print_debug(module, "Loading 'lua/%s/%s", self.modName, path)
    end
    Script.Load("lua/" .. self.modName .. "/" .. path)
end

function ModFramework:LoadModules()
    fw_print_debug(nil, "Loading modules")

    self:LoadFrameworkModule("ModuleManagerModule")
    self:LoadFrameworkModule("LoggerModule")
    self:LoadFrameworkModule("VersioningModule")
    self:LoadFrameworkModule("EnumUtilitiesModule")
    self:LoadFrameworkModule("TechHandlerModule")
end

function ModFramework:LoadFrameworkModule(moduleName)
    fw_print_debug(nil, "Loading module: %s", moduleName)
    self:LoadScript("ModFramework/Modules/" .. moduleName .. ".lua")
end

function ModFramework:InitModules()
    self:LoadModules()

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
