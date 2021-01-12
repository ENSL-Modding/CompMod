--[[
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
    config.versioning.revision = 8
    config.versioning.display = true

    -- Tech Handler
    config.techhandler = {}
    config.techhandler.techIdsToAdd = {
        "AdvancedSwipe",
        "CyberneticBoots",
        "DemolitionsTech",
        "Neurotoxin",
    }

    return config
end
