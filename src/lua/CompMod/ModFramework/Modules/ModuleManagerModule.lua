Script.Load("lua/CompMod/ModFramework/Modules/FrameworkModule.lua")
Script.Load("lua/CompMod/Modules.lua")

class 'ModuleManagerModule' (FrameworkModule)

function ModuleManagerModule:Initialize(framework)
    FrameworkModule.Initialize(self, "modulemanager", framework, false)
    
    -- Load modules
    local moduleFunc = GetModFrameworkModulesCompMod
    local moduleFuncName = "GetModFrameworkModulesCompMod"

    fw_assert_not_nil(moduleFunc, "Missing " .. moduleFuncName .. " in Modules.lua")
    fw_assert_type(moduleFunc, "function", moduleFuncName)

    self.modules = moduleFunc()
    fw_assert_not_nil(self.modules, "No modules found in Modules.lua")
end

function ModuleManagerModule:GetModules()
    return self.modules
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

        if #files == 0 then
            logger:PrintWarn("No files found for module: %s", v)
        elseif not (#files == 1 and files[1] == ".docugen") then -- Skip modules that only have .docugen files
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
