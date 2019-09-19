-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/ItemUtils.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Functions related to items, and debugging item drops.
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/UnorderedSet.lua")

local spoofedItems = UnorderedSet()

Event.Hook("Console_spoof_items", function(...)
    
    local itemIds = {...}
    local gotInvalid = false
    for i=1, #itemIds do
        itemIds[i] = tonumber(itemIds[i])
        if not itemIds[i] or math.floor(itemIds[i]) ~= itemIds[i] then
            gotInvalid = true
            break
        end
    end
    
    if gotInvalid or #itemIds == 0 then
        Log("usage: spoof_items itemId1 itemId2 ... itemIdN")
        return
    end
    
    -- Requires cheats or dev-mode to be used in-game.
    if kInGame and not Shared.GetCheatsEnabled() and not Shared.GetDevMode() then
        Log("command spoof_items requires cheats or dev-mode to be enabled on the server.")
        return
    end
    
    local addedItems = {}
    for i=1, #itemIds do
        if spoofedItems:Add(itemIds[i]) then
            table.insert(addedItems, itemIds[i])
        end
    end
    
    if #addedItems > 0 then
        Log("Added %d items to the spoofed set: %s", #addedItems, table.concat(addedItems, ", "))
    else
        Log("No items were added (they were all already present in the set)")
    end
    
    for i=1, #addedItems do
        InventoryNewItemHandler( addedItems[i], false )
    end
    
end)

function GetOwnsItem( item )
    
    -- Check for debug spoofed items first.
    if spoofedItems:Contains(item) then
        return true
    end
    
    if Client then
        return (Client.GetOwnsItem( item ))
    else
        return true
    end
    
end

Event.Hook("LoadComplete", function()
    
    local old_Client_ExchangeItem = Client.ExchangeItem
    assert(old_Client_ExchangeItem)
    function Client.ExchangeItem(inItemId, outItemId)
    
        if spoofedItems:Contains(inItemId) then
            spoofedItems:Add(outItemId)
            spoofedItems:RemoveElement(inItemId)
            
            Log(string.format("Exchanged spoofed item %d for spoofed item %d", inItemId, outItemId))
            
            return
        end
        
        return (old_Client_ExchangeItem(inItemId, outItemId))
    
    end
    
end)


