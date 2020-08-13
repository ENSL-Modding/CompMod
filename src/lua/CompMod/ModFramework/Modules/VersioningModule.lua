Script.Load("lua/" .. fw_get_current_mod_name() .. "/ModFramework/Modules/FrameworkModule.lua")

class 'VersioningModule' (FrameworkModule)

function VersioningModule:Initialize(framework)
    FrameworkModule.Initialize(self, "versioning", framework, true)
end

function VersioningModule:ValidateConfig()
    -- First make sure everything is there
    fw_assert_not_nil(self.config.majorVersion, "Major version missing!", self)
    fw_assert_not_nil(self.config.minorVersion, "Minor version missing!", self)
    fw_assert_not_nil(self.config.patchVersion, "Patch version missing!", self)
    fw_assert_not_nil(self.config.preRelease, "Pre release missing!", self)
    fw_assert_not_nil(self.config.display, "Display option missing!", self)

    -- Check types
    fw_assert_type(self.config.majorVersion, "number", "config.versioning.majorVersion", self)
    fw_assert_type(self.config.minorVersion, "number", "config.versioning.minorVersion", self)
    fw_assert_type(self.config.patchVersion, "number", "config.versioning.patchVersion", self)
    fw_assert_type(self.config.preRelease, "string", "config.versioning.preRelease", self)
    fw_assert_type(self.config.display, "boolean", "config.versioning.display", self)

    -- Validate version numbers
    self:ValidateVersionNumber("MajorVersion", self.config.majorVersion)
    self:ValidateVersionNumber("MinorVersion", self.config.minorVersion)
    self:ValidateVersionNumber("PatchVersion", self.config.patchVersion)
end

function VersioningModule:ValidateVersionNumber(name, versionNumber)
    fw_assert(math.floor(versionNumber) == versionNumber, name .. ": Version type must be integer", self)
    fw_assert(versionNumber >= 0, name .. ": Version number cannot be less than zero", self)
end

function VersioningModule:GetFeedbackText()
    return string.format("%s v%s", self.framework:GetModName(), self:GetVersion()) 
end

function VersioningModule:GetVersion()
    local maj   = self:GetMajorVersion()
    local min   = self:GetMinorVersion()
    local patch = self:GetPatchVersion()
    local pre   = self:GetPreRelease()
    local formatString = "%s.%s.%s"

    if pre and pre ~= "" then
        formatString = formatString .. "-%s"
    end

    return formatString:format(maj, min, patch, pre)
end

function VersioningModule:GetMajorVersion()
    return self.config.majorVersion
end

function VersioningModule:GetMinorVersion()
    return self.config.minorVersion
end

function VersioningModule:GetPatchVersion()
    return self.config.patchVersion
end

function VersioningModule:GetPreRelease()
    return self.config.preRelease
end

function VersioningModule:GetShouldDisplay()
    return self.config.display
end
