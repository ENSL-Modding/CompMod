--[[
    ==========================================================
                          Mod Framework
    ==========================================================
    
    This is the main config file for your mod.

    For information on how to use this file see the wiki.
]]

function GetModFrameworkConfigCompMod()
    -- Main config
    local config = {}

    -- Logger
    config.logger = {}
    config.logger.enabled = true
    config.logger.level = "fatal"

    -- Versioning
    config.versioning = {}
    config.versioning.majorVersion = 3
    config.versioning.minorVersion = 4
    config.versioning.patchVersion = 0
    config.versioning.preRelease = ""
    config.versioning.display = true

    -- Tech Handler
    config.techhandler = {}
    config.techhandler.techIdsToAdd = {
        "AdvancedSwipe",
        "MunitionsTech",
        "DemolitionsTech",
    }

    return config
end
