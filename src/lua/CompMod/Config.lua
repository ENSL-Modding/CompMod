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
    config.versioning.minorVersion = 5
    config.versioning.patchVersion = 1
    config.versioning.preRelease = "pre1"
    config.versioning.display = true

    -- Tech Handler
    config.techhandler = {}
    config.techhandler.techIdsToAdd = {
        "AdvancedSwipe",
        "DemolitionsTech",
    }

    return config
end
