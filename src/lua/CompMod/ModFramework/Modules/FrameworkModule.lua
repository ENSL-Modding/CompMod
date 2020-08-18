--[[
    TODO: Add intro here :)
]]

-- Abstract
class 'FrameworkModule'

function FrameworkModule:Initialize(moduleName, framework, hasConfig)
    fw_assert_not_nil(moduleName, "Cannot initialize FrameworkModule without moduleName", self)
    fw_assert_type(moduleName, "string", "Module name", self)
    self.moduleName = moduleName
    self.hasConfig = hasConfig
    self.framework = framework
    self.config = {}
end

function FrameworkModule:ValidateConfig()
    fw_assert(false, "ValidateConfig is not implemented", self)
end

function FrameworkModule:GetModuleName()
    return self.moduleName
end

function FrameworkModule:LoadModule()
    fw_print_info(self, "Loading module")
    self:LoadAllFiles()
    fw_print_info(self, "Finished loading module")
end

function FrameworkModule:LoadAllFiles(vm)
    fw_print_debug(self, "Loading all files")

    if vm == "FileHook" then
        self:SetupFileHooks()
    elseif vm == "Shared" then
        self:LoadSharedFiles()
    elseif vm == "Client" then
        self:LoadClientFiles()
    elseif vm == "Server" then
        self:LoadServerFiles()
    elseif vm == "Predict" then
        self:LoadPredictFiles()
    end

    fw_print_debug(self, "Finished loading all files")
end

function FrameworkModule:LoadSharedFiles()
    fw_print_debug(self, "Loading shared files")
    self:LoadVMFiles("shared")
    fw_print_debug(self, "Finished loading shared files")
end

function FrameworkModule:LoadClientFiles()
    fw_print_debug(self,"Loading client files")
    self:LoadVMFiles("client")
    fw_print_debug(self, "Finished loading client files")
end

function FrameworkModule:LoadServerFiles()
    fw_print_debug(self,"Loading server files")
    self:LoadVMFiles("server")
    fw_print_debug(self, "Finished loading server files")
end

function FrameworkModule:LoadPredictFiles()
    fw_print_debug(self,"Loading predict files")
    self:LoadVMFiles("predict")
    fw_print_debug(self, "Finished loading predict files")
end

function FrameworkModule:SetupFileHooks()
    fw_print_debug(self, "Setting up filehooks")
    
    local types = { "Halt", "Post", "Pre", "Replace" }

    for j = 1, #types do
        local hookType = types[j]
        local path = self:FormatDir(hookType)
        local files = {}

        Shared.GetMatchingFileNames(path, true, files)

        fw_print_debug(self, "Found %s %s hooks along %s", #files, hookType, path)

        for _,file in ipairs(files) do
            local vpath = file:gsub(string.format("%s/.*/%s/", self.framework:GetModName(), hookType), "")

            fw_print_debug(self, "Hooking file: %s, Vanilla Path: %s, Method: %s", file, vpath, hookType)
            ModLoader.SetupFileHook(vpath, file, hookType:lower())
        end
    end

    fw_print_debug(self, "Finished setting up filehooks")
end

function FrameworkModule:LoadVMFiles(vm)
    local path = self:FormatDir(vm)
    local files = {}

    Shared.GetMatchingFileNames(path, true, files)

    for _,file in ipairs(files) do
        fw_print_debug(self, "Loading file: %s, vm: %s", file, vm)
        Script.Load(file)
    end
end

function FrameworkModule:FormatDir(hookType)
    fw_assert_not_nil(hookType, "HookType must not be nil", self)
    fw_assert_type(hookType, "string", "hookType", self)

    return string.format("lua/%s/ModFramework/Files/%s/%s/*.lua", self.framework:GetModName(), self:GetModuleName(), hookType)
end