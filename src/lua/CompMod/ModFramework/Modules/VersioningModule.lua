Script.Load("lua/CompMod/ModFramework/Modules/FrameworkModule.lua")

class 'VersioningModule' (FrameworkModule)

function VersioningModule:Initialize(framework)
    FrameworkModule.Initialize(self, "versioning", framework, true)
end

function VersioningModule:ValidateConfig()
    -- First make sure everything is there
    fw_assert_not_nil(self.config.revision, "Revision missing!", self)
    fw_assert_not_nil(self.config.display, "Display option missing!", self)

    -- Check types
    fw_assert_type(self.config.revision, "number", "config.versioning.revision", self)
    fw_assert_type(self.config.display, "boolean", "config.versioning.display", self)

    -- Validate revision number
    local revision = self.config.revision
    fw_assert(math.floor(revision) == revision, "Revision type must be integer", self)
    fw_assert(revision >= 0, "Revision cannot be <= 0")
end

function VersioningModule:GetFeedbackText()
    return string.format("%s revision %s", self.framework:GetModName(), self:GetRevision()) 
end

function VersioningModule:GetRevision()
    return self.config.revision
end

function VersioningModule:GetShouldDisplay()
    return self.config.display
end
