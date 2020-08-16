Script.Load("lua/" .. fw_get_current_mod_name() .. "/ModFramework/Modules/FrameworkModule.lua")

class 'ModuleManagerModule' (FrameworkModule)

function ModuleManagerModule:Initialize(framework)
    FrameworkModule.Initialize(self, "modulemanager", framework, false)

    self.framework:LoadScript("Modules.lua", self)
    self.modules = self:GetModules()
end

function ModuleManagerModule:GetModules()
    self.framework:GetModule("logger"):PrintWarn("Call to ModuleManagerModule:GetModules() before overwrite!")

    return nil
end

function ModuleManagerModule:FormatPath(moduleName, vm)
    if vm then
        return string.format("lua/%s/Modules/%s/%s/*.lua", self.framework:GetModName(), moduleName, vm)
    else
        return string.format("lua/%s/Modules/%s/*.lua", self.framework:GetModName(), moduleName)
    end
end

function ModuleManagerModule:ValidateModules()
    local modules = self:GetModules()
    local logger = self.framework:GetModule("logger")
    logger:PrintDebug("Validating modules")

    for _,v in ipairs(modules) do
        local files = {}
        local dir = self:FormatPath(v)
        Shared.GetMatchingFileNames(dir, true, files)

        if #files == 0 or (#files == 1 and files[1] == ".docugen") then
            logger:PrintWarn("No files found for module: %s", v)
        else
            local allowedFollowingDirs = {"Post", "Pre", "Replace", "Halt", "Client", "Server", "Predict", "Shared"}
            for _,file in ipairs(files) do
                local followingDir = file:gsub(dir:gsub("/*.lua", ""), ""):match("^([^/]+)/.*$")
                local dirOk = false
                for _,allowedDir in ipairs(allowedFollowingDirs) do
                    if followingDir == allowedDir then
                        dirOk = true
                        break
                    end
                end

                if not dirOk then
                    logger:PrintWarn("Found invalid directory \"%s\" in module: %s", followingDir, v)
                end
            end
        end


    end
end
