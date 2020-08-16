--[[
    ==========================================================
                          Mod Framework
    ==========================================================
    
    This is the main config file for your mod.

    For information on how to use this file see the wiki.
]]

function ModFramework:LoadConfig()
    -- Main config
    self.config = {}

    -- Logger
    self.config.logger = {}
    self.config.logger.enabled = true
    self.config.logger.level = "fatal"

    -- Versioning
    self.config.versioning = {}
    self.config.versioning.majorVersion = 3
    self.config.versioning.minorVersion = 2
    self.config.versioning.patchVersion = 1
    self.config.versioning.preRelease = ""
    self.config.versioning.display = true

    -- Tech Handler
    self.config.techhandler = {}
    self.config.techhandler.techIdsToAdd = {
        "AdvancedSwipe",
        "MunitionsTech",
        "DemolitionsTech",
    }
end
