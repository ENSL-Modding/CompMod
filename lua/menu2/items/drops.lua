-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/menu2/items/drops.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Functions related to item drops.
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/menu2/popup/GUIMenuPopupIconMessage.lua")
Script.Load("lua/menu2/items/itemDefs.lua")

-- Validate item defs
assert(type(kItemDefs) == "table")
for key, value in pairs(kItemDefs) do
    assert(type(key) == "number")
    assert(math.floor(key) == key)
    assert(key >= 0)
    assert(type(value) == "table")
    assert(type(value.title) == "string")
    assert(type(value.message) == "string")
    assert(type(value.icon) == "string")
end

-- Displays a popup to the user informing them that they have received a new item.  The itemId must
-- be present in the kItemDefs table defined in lua/menu2/items/itemDefs.lua.
function DoItemReceivedPopup(itemId)
    
    local itemDef = kItemDefs[itemId]
    if itemDef == nil then
        -- Item isn't drop-related.
        return
    end
    
    local popup = CreateGUIObject("popup", GUIMenuPopupIconMessage, nil,
    {
        title = itemDef.title,
        message = itemDef.message,
        icon = itemDef.icon,
        buttonConfig =
        {
            GUIPopupDialog.OkayButton,
        },
    })
    
    return popup

end

-- Checks to see if there are any new item notifications queued up to display, and displays them
-- one at a time.  When all notifications have been closed, the optional finishedCallback is called.
function DoPopupsForNewlyReceivedItems(finishedCallback)
    
    local new = InventoryNewItemNotifyPop()
    while new do
        
        if GetOwnsItem(new) then
            
            local popup = DoItemReceivedPopup(new)
            if popup then
                popup:HookEvent(popup, "OnClosed", function()
                    DoPopupsForNewlyReceivedItems(finishedCallback)
                end)
                
                return false -- stop here.  Will resume when popup is closed.
            
            end
        end
        
        new = InventoryNewItemNotifyPop()
        
    end
    
    -- If any popups had opened up, we would have returned from this function before now.
    -- We must be done, so fire the callback now.
    if type(finishedCallback) == "function" then
        finishedCallback()
    end
    
    return true
    
end

-- DEBUG
Event.Hook("Console_check_item_notifications", function()
    
    DoPopupsForNewlyReceivedItems(function()
    
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
