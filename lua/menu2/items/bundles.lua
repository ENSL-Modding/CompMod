-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/menu2/items/bundles.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Functions related to item bundles.
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/menu2/popup/GUIMenuPopupIconMessage.lua")

local bundleDefs = {}
local function DefineBundle(params)
    
    RequireType("string", params.title, "params.title", 2)
    RequireType("string", params.message, "params.title", 2)
    RequireType("string", params.icon, "params.icon", 2)
    RequireType("string", params.unpackLabel, "params.unpackLabel", 2)
    RequireType("number", params.bundleItemId, "params.bundleItemId", 2)
    RequireType("number", params.unpackBundleItemId, "params.unpackBundleItemId", 2)
    
    table.insert(bundleDefs, params)
    
end

DefineBundle
{
    title = Locale.ResolveString("TUNDRA_BUNDLE_TITLE"),
    message = Locale.ResolveString("TUNDRA_BUNDLE_MSG"),
    icon = PrecacheAsset("ui/logo_tundra.dds"),
    unpackLabel = Locale.ResolveString("OPEN_TUNDRA_BUNDLE"),
    bundleItemId = kTundraBundleItemId,
    unpackBundleItemId = kUnpackTundraBundleItemId,
}

DefineBundle
{
    title = Locale.ResolveString("NOCTURNE_BUNDLE_TITLE"),
    message = Locale.ResolveString("NOCTURNE_BUNDLE_MSG"),
    icon = PrecacheAsset("ui/logo_nocturne.dds"),
    unpackLabel = Locale.ResolveString("OPEN_NOCTURNE_BUNDLE"),
    bundleItemId = kAnnivAlienPackItemId,
    unpackBundleItemId = kUnpackNocturneBundleItemId,
}

DefineBundle
{
    title = Locale.ResolveString("FORGE_BUNDLE_TITLE"),
    message = Locale.ResolveString("FORGE_BUNDLE_MSG"),
    icon = PrecacheAsset("ui/logo_forge.dds"),
    unpackLabel = Locale.ResolveString("OPEN_FORGE_BUNDLE"),
    bundleItemId = kAnnivMarinePackItemId,
    unpackBundleItemId = kUnpackForgeBundleItemId,
}

DefineBundle
{
    title = Locale.ResolveString("SHADOW_BUNDLE_TITLE"),
    message = Locale.ResolveString("SHADOW_BUNDLE_MSG"),
    icon = PrecacheAsset("ui/logo_shadow.dds"),
    unpackLabel = Locale.ResolveString("OPEN_SHADOW_BUNDLE"),
    bundleItemId = kShadowBundleItemId,
    unpackBundleItemId = kUnpackShadowBundleItemId,
}

local function CreateUnpackWindow(params)
    
    local popup = CreateGUIObject("popup", GUIMenuPopupIconMessage, nil,
    {
        title = params.title,
        message = params.message,
        icon = params.icon,
        buttonConfig =
        {
            {
                name = "openBundle",
                params =
                {
                    label = params.unpackLabel,
                },
                callback = function(popup)
                    popup:Close()
                    Client.ExchangeItem(params.bundleItemId, params.unpackBundleItemId)
                end,
            },
            
            GUIPopupDialog.CancelButton,
        },
    })
    return popup

end

local alreadyAsked = {} -- bundle item id's that have already been asked about this session.
local function DoPopupsForUnopenedBundlesActual(callback, bundleQueue)
    
    while #bundleQueue > 0 do
        local bundleDef = bundleQueue[#bundleQueue]
        bundleQueue[#bundleQueue] = nil
    
        if GetOwnsItem(bundleDef.bundleItemId) and not alreadyAsked[bundleDef.bundleItemId] then
            alreadyAsked[bundleDef.bundleItemId] = true
            local popup = CreateUnpackWindow(bundleDef)
            popup:HookEvent(popup, "OnClosed", function()
                
                DoPopupsForUnopenedBundlesActual(callback, bundleQueue)
                
            end)
            
            return false -- stop here.  Will resume when popup is closed.
            
        end
    end
    
    -- If any popups had opened up, we would have returned from this function before now.
    -- We must be done, so fire the callback now.
    if type(callback) == "function" then
        callback()
    end
    
    return true

end

-- Checks to see if there are any unopened bundles, and if so, prompts the user to open them one
-- at a time.  When all popups have been dismissed by the user (or if no popups were displayed at
-- all), the finishedCallback function is called (optional).
-- Returns true if done, false if a popup was created.
function DoPopupsForUnopenedBundles(finishedCallback)
    
    local bundleQueue = {}
    for i=1, #bundleDefs do
        bundleQueue[i] = bundleDefs[i]
    end
    
    return (DoPopupsForUnopenedBundlesActual(finishedCallback, bundleQueue))
    
end

-- DEBUG
Event.Hook("Console_check_bundles", function()

    DoPopupsForUnopenedBundles(function()
    
        local popup = CreateGUIObject("popup", GUIMenuPopupSimpleMessage, nil,
        {
            title = "YAAAAY!",
            message = "Done with popups",
            buttonConfig =
            {
                GUIPopupDialog.OkayButton,
            },
        })
        
    end)

end)
