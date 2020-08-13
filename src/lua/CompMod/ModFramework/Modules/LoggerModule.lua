Script.Load("lua/" .. fw_get_current_mod_name() .. "/ModFramework/Modules/FrameworkModule.lua")

class 'LoggerModule' (FrameworkModule)

function LoggerModule:Initialize(framework)
    FrameworkModule.Initialize(self, "logger", framework, true)

    self.levelIdxMap = {}
    self.levelIdxMap.DEBUG = 0
    self.levelIdxMap.FATAL = 1
    self.levelIdxMap.WARN = 2
    self.levelIdxMap.INFO = 3
end

function LoggerModule:ValidateConfig()
    -- First make sure everything is there
    fw_assert_not_nil(self.config.enabled, "config.logger.enabled missing!", self)
    fw_assert_not_nil(self.config.level, "config.logger.level missing!", self)

    -- Validate types
    fw_assert_type(self.config.enabled, "boolean", "config.logger.enabled")
    fw_assert_type(self.config.level, "string", "config.logger.level")

    -- Validate level
    self.config.level = self.config.level:upper()
    fw_assert(self.levelIdxMap[self.config.level], "config.logger.level invalid!", self)
end

local function LoggerPrint(self, level, msg, ...)
    local configLevelIdx = self.levelIdxMap[self.config.level]
    local levelIdx = self.levelIdxMap[level]
    fw_assert_not_nil(configLevelIdx, "Failed to get level index from config level", self)
    fw_assert_not_nil(levelIdx, "Failed to get level index from given level", self)

    if levelIdx >= configLevelIdx then
        local prefix = string.format("[%s - %s] %s:", self.framework:GetModName(), self.framework.vm, level)
        local formattedMsg = msg:format(select(1, ...))
        local finalString = string.format("%s %s", prefix, formattedMsg)
    
        print(finalString)
    end
end

function LoggerModule:PrintDebug(msg, ...)
    LoggerPrint(self, "DEBUG", msg, ...)
end

function LoggerModule:PrintFatal(msg, ...)
    LoggerPrint(self, "FATAL", msg, ...)
end

function LoggerModule:PrintWarn(msg, ...)
    LoggerPrint(self, "WARN", msg, ...)
end

function LoggerModule:PrintInfo(msg, ...)
    LoggerPrint(self, "INFO", msg, ...)
end