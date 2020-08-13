Script.Load("lua/" .. fw_get_current_mod_name() .. "/ModFramework/Modules/FrameworkModule.lua")

class 'ModuleManagerModule' (FrameworkModule)

function ModuleManagerModule:Initialize(framework)
    FrameworkModule.Initialize(self, "modulemanager", framework, false)

    self.framework:LoadScript("Modules.lua", self)
    self.modules = self:GetModules()
end

function ModuleManagerModule:GetModules()
    return self.modules
end

function ModuleManagerModule:FormatPath(moduleName, vm)
    return string.format("lua/%s/Modules/%s/%s/*.lua", self.framework:GetModName(), moduleName, vm)
end