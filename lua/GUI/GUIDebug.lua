-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/GUI/GUIDebug.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--    
--    Contains all the debug functionality for the new GUI system.
--    
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/OrderedIterableDict.lua")

-- Spams console with warnings about debug functionality being present, making it nearly impossible to miss.
function DebugStuff()
    Log("DEBUG STUFF DETECTED!!!!!!  REMOVE BEFORE RELEASE!!!!!!!")
    Log("%s", debug.traceback())
end

local kStateToBool =
{
    ["0"] = false,
    ["f"] = false,
    ["F"] = false,
    ["false"] = false,
    ["False"] = false,
    
    ["1"] = true,
    ["t"] = true,
    ["T"] = true,
    ["true"] = true,
    ["True"] = true,
}

local guiDebugCommands = {}
local function AddDebugCommand(name, desc, func)
    table.insert(guiDebugCommands, {name=name, desc=desc})
    table.sort(guiDebugCommands, function(a, b) return a.name < b.name end)
    Event.Hook("Console_"..name, func)
end

AddDebugCommand("g_help", "Displays this list of commands.", function()
    Log("GUI Debug Commands:")
    local longestNameLength = 0
    for i=1, #guiDebugCommands do
        longestNameLength = math.max(longestNameLength, #guiDebugCommands[i].name)
    end
    longestNameLength = math.floor((longestNameLength + 7) / 4) * 4
    for i=1, #guiDebugCommands do
        local cmd = guiDebugCommands[i]
        local nameFormat = string.format("%%-%ds", longestNameLength)
        local nameFormatted = string.format(nameFormat, cmd.name)
        Log("    %s%s", nameFormatted, cmd.desc)
    end
end)

-- Due to the queueing system, it's not always clear which code paths fired to produce the
-- schedule of events.
--[=[
DebugStuff()
dbgStoreEventStackTraces = true -- uncomment to enable at start
--]=]

local itemList = OrderedIterableDict()
local currentItemTbl = nil
local itemArray = GUIItemArray()
local storedPropData = {}
local highlightEnabled = false
local highlightItem = nil
local kHighlightColors =
{
    Color(1, 0, 0, 0.5),
    Color(0, 1, 0, 0.5),
    Color(0, 0, 1, 0.5),
}
for i=1, #kHighlightColors do
    kHighlightColors[kHighlightColors[i]] = i
end
local currentHighlightColor = kHighlightColors[1]

local function SetHighlightEnabled(state)
    state = state == true
    if highlightEnabled == state then
        return
    end
    
    highlightEnabled = state
    
    if highlightEnabled then
        assert(highlightItem == nil)
        highlightItem = GUI.CreateItem()
        highlightItem:SetColor(currentHighlightColor)
        highlightItem:SetLayer(999999)
        highlightItem:SetIsVisible(false)
    else
        assert(highlightItem)
        GUI.DestroyItem(highlightItem)
        highlightItem = nil
    end
    
end
function Debug_SetHighlightEnabled(state) SetHighlightEnabled(state == true) end

AddDebugCommand("g_highlight", "Sets or toggles current item highlighting on/off.", function(state)
    if state == nil then
        SetHighlightEnabled(not highlightEnabled)
    else
        state = kStateToBool[state] == true
        SetHighlightEnabled(state)
    end
    Log("gui highlighting %s", highlightEnabled and "enabled" or "disabled")
end)

AddDebugCommand("g_highlight_color", "Cycles through the item highlight colors.", function()
    local currentIndex = (((currentHighlightColor and kHighlightColors[currentHighlightColor]) or 0) % #kHighlightColors) + 1
    currentHighlightColor = kHighlightColors[currentIndex]
    if highlightItem then
        highlightItem:SetColor(currentHighlightColor)
    end
end)

local function ClearCurrentItem()
    
    if currentItemTbl ~= nil then
        currentItemTbl = nil
        Log("cleared currentItemTbl.")
    end
    
end

Event.Hook("NotifyGUIItemDestroyed", function(destroyedItem)
    
    -- If the current item is destroyed, clear the current item.
    if currentItemTbl and currentItemTbl.item == destroyedItem then
        ClearCurrentItem()
    end
    
    -- Remove the destroyed item from the item list, if present.
    local keysToRemove = {}
    for i=1, #itemList do
        local key = itemList:GetKeyAtIndex(i)
        local value = itemList:GetValueAtIndex(i)
        if value == destroyedItem then
            table.insert(keysToRemove, key)
        end
    end
    for i=1, #keysToRemove do
        itemList[keysToRemove[i]] = nil
    end
    
end)

Event.Hook("UpdateClient", function(deltaTime)
    if highlightItem then
        local hasItem = currentItemTbl ~= nil and currentItemTbl.item ~= nil
        highlightItem:SetIsVisible(hasItem)
        if hasItem then
            highlightItem:SetPosition(currentItemTbl.item:GetScreenPosition())
            highlightItem:SetSize(currentItemTbl.item:GetAbsoluteSize())
        end
    end
end, "GUIDebug")

local function GetItemClassName(item)
    
    local obj = GetOwningGUIObject(item)
    local typeName = "GUIItem"
    if obj and item == obj:GetRootItem() then
        typeName = obj.classname
    end
    return typeName
    
end

-- Returns a "better-known-as..." name for the item, in case it isn't a GUIObject whose name we can simply return.
local function GetBKAForItem(item)
    
    local obj = GetOwningGUIObject(item)
    if obj then
        
        if obj:GetRootItem() == item then
            local result = obj:GetName()
            return result
        elseif obj:GetChildHoldingItem() == item then
            local result = obj:GetName().."_child_holder"
            return result
        else
            -- search owning object for a field that contains the item, and use that name.
            local env = debug.getfenv(obj) or {}
            for key, value in pairs(env) do
                if type(key) == "string" and value == item then
                    return obj:GetName().."."..key
                end
            end
            
            return "unowned_item"
        end
        
    else
        
        -- no object owns this item... see if parent has an owner we can relate to.
        local parentItem = item:GetParent()
        if parentItem then
            return GetBKAForItem(parentItem)..".".."anonymous_unowned_item"
        else
            return "unowned_item"
        end
        
    end
    
end
Debug_GetBKAForItem = GetBKAForItem

local function PrintItemList()
    
    local maxClassNameLength = 0
    for i=1, #itemList do
        local className = GetItemClassName(itemList:GetValueAtIndex(i))
        maxClassNameLength = math.max(maxClassNameLength, #className)
    end
    
    if #itemList > 0 then
        maxClassNameLength = math.floor(math.ceil(((maxClassNameLength + 2) / 4)) * 4)
        Log(string.format("%%6s    %%%ds  %%s", maxClassNameLength), "index", "classname", "name (possibly auto-generated for the list)")
    else
        Log("<empty item list>")
    end
    for i=1, #itemList do
        Log(string.format("%%6s    %%%ds  %%s", maxClassNameLength), i, GetItemClassName(itemList:GetValueAtIndex(i)), itemList:GetKeyAtIndex(i))
    end
    
end

local function SetItemList(itemTable)
    
    itemList = OrderedIterableDict()
    for i=1, #itemTable do
        local item = itemTable[i]
        
        local result = GetBKAForItem(item)
        assert(result ~= nil)
        
        -- Ensure the bka is unique for the item list.
        local bka = result
        local attempt = 1
        while itemList[bka] ~= nil do
            -- try adding numbers to the end to find a unique name.
            attempt = attempt + 1 -- start at 2
            bka = result .. "_" .. tostring(attempt)
        end
        
        itemList[bka] = item
        
    end
    
    Log("itemList set to %s items.", #itemList)
    PrintItemList()
    
end

local function SetCurrentItem(item, bka)
    
    currentItemTbl = {item = item, bka = bka}
    Log("currentItemTbl set to %s (%s)", bka, GetItemClassName(item))
    
    item:GetChildren(itemArray)
    Log("itemList set to children.")
    SetItemList(GUIItemArrayToTable(itemArray))
    
end
Debug_SetCurrentItem = SetCurrentItem

local function DoNoCurrentItemErrorMessage()
    Log("no currentItemTbl set!  Set currentItemTbl using one of the gather commands (g_cursor, g_cursor_all or g_root), and then g_select.")
end

local function ProcessItemListSelection(nameOrIndex)
    
    local item
    local index = tonumber(nameOrIndex)
    local bka
    if index then
        item = itemList:GetValueAtIndex(index)
        if not item then
            Log("Unable to find item at index %s of item list.", index)
            return false
        end
        bka = itemList:GetKeyAtIndex(index)
    else
        item = itemList[nameOrIndex]
        if not item then
            Log("Unable to find item by the name of %s in item list.", nameOrIndex)
            return false
        end
        bka = nameOrIndex
    end
    
    assert(item)
    assert(bka)
    
    return true, item, bka
    
end

-- Gathers a list of all the GUIItems underneath the cursor (interactable or not), gives them
-- temporary names if necessary, stores them in a list, and lists the items in the console.  Any
-- debug operations that follow this will use the list of objects gathered in this step, or will
-- find a named object from this list.
AddDebugCommand("g_cursor_all", "Gathers a list of all guiitems under the cursor, regardless of interaction state.", function()
    
    local cursorPosition = GetGlobalEventDispatcher():GetMousePosition()
    
    GUI.GetInteractionsUnderPoint(itemArray, cursorPosition.x, cursorPosition.y, 0)
    ClearCurrentItem()
    SetItemList(GUIItemArrayToTable(itemArray))
    
end)

-- Gathers a list of all the GUIItems underneath the cursor that are setup to interact with the
-- cursor, gives them temporary names if necessary, stores them in a list, and lists the items in
-- the console.  Any debug operations that follow this will use the list of objects gathered in
-- this step, or will find a named object from this list.
AddDebugCommand("g_cursor", "Gathers a list of all guiitems under the cursor that are setup to receive cursor interactions.", function()
    
    local cursorPosition = GetGlobalEventDispatcher():GetMousePosition()
    
    GUI.GetInteractionsUnderPoint(itemArray, cursorPosition.x, cursorPosition.y, GUIInteractionManager.Interaction_Cursor)
    ClearCurrentItem()
    SetItemList(GUIItemArrayToTable(itemArray))
    
end)

AddDebugCommand("g_root", "Gathers a list of all top-level guiitems.", function()
    
    GUI.GetRootItems(itemArray)
    ClearCurrentItem()
    SetItemList(GUIItemArrayToTable(itemArray))
    
end)

-- Sets currentItemTbl to the item from the list, and then sets the item list to the children of this item.
AddDebugCommand("g_select", "[nameOrIndex] Sets the current item to the item in the list with the given name or index.", function(nameOrIndex)
    
    if not nameOrIndex then
        Log("usage g_select nameOrIndex")
        Log("    nameOrIndex -- name or index of item in list of GUIItems previously acquired, eg via g_cursor_grab.")
        return
    end
    
    local success, item, bka = ProcessItemListSelection(nameOrIndex)
    if not success then
        return
    end
    
    SetCurrentItem(item, bka)
    
end)

-- Sets the currentItemTbl to the parent of the current currentItemTbl.
AddDebugCommand("g_parent", "Sets the current item to the current item's parent.", function()
    
    if currentItemTbl == nil then
        DoNoCurrentItemErrorMessage()
        return
    end
    
    local parentItem = currentItemTbl.item:GetParent()
    if parentItem == nil then
        Log("currentItemTbl has no parent.  currentItemTbl has not been changed.")
    else
        SetCurrentItem(parentItem, GetBKAForItem(parentItem))
    end
    
end)

-- Prints the item list without changing it.
AddDebugCommand("g_list", "Re-prints the item list.", function()
    Log("itemList")
    PrintItemList()
end)

-- Prints a list of the option flags that this object is setup to receive.
AddDebugCommand("g_options", "Prints a list of the option flags that the current item is setup to receive.", function()
    
    local item
    local bka
    if currentItemTbl == nil then
        DoNoCurrentItemErrorMessage()
        return
    else
        item = currentItemTbl.item
        bka = currentItemTbl.bka
    end
    
    local kOptions =
    {
        "ManageRender",
        "CorrectScaling",
        "PerLineTextAlignment",
        "CorrectRotationOffset",
        "DistanceFieldFont",
        "Interaction_BlockChildren",
        "Interaction_1",
        "Interaction_2",
        "Interaction_3",
        "Interaction_4",
        "Interaction_5",
        "Interaction_6",
        "Interaction_7",
        "Interaction_8",
        "Interaction_9",
        "Interaction_10",
    }
    
    Log("Info for item '%s' (%s):", bka, GetItemClassName(item))
    for i=1, #kOptions do
        Log("    GUIItem.%-29s = %s", kOptions[i], item:IsOptionFlagSet(GUIItem[kOptions[i]]))
    end
    
end)

local function GetPropertyListForObject(obj)
    
    local propList = {}
    
    -- Add the fake property names.
    for propName, __ in pairs(g_GUIItemFakeProperties) do
        table.insert(propList, propName)
    end
    
    -- Add the class property names.
    if obj._classPropList then
        for i=1, #obj._classPropList do
            table.insert(propList, obj._classPropList[i])
        end
    end
    
    -- Add the composite class property names.
    if obj._classCompositePropList then
        for i=1, #obj._classCompositePropList do
            table.insert(propList, obj._classCompositePropList[i])
        end
    end
    
    -- Add the instance property names.
    if obj._instancePropList then
        for i=1, #obj._instancePropList do
            table.insert(propList, obj._instancePropList[i])
        end
    end
    
    -- Sort by name.
    table.sort(propList)
    
    return propList
    
end

local kItemPropertyList =
{
    "Anchor",
    "Angle",
    "BlendTechnique",
    "ClearsStencilBuffer",
    "Color",
    "CropMaxCornerNormalized",
    "CropMinCornerNormalized",
    "DropShadowColor",
    "DropShadowEnabled",
    "DropShadowOffset",
    "FontName",
    "HotSpot",
    "InheritsParentScaling",
    "InheritsParentStencilSettings",
    "IsStencil",
    "IsVisible",
    "Layer",
    "Position",
    "RotationOffsetNormalized",
    "Scale",
    "Shader",
    "Size",
    "SnapsToPixels",
    "StencilFunc",
    "Text",
    "Texture",
}
for i=1, #kItemPropertyList do
    kItemPropertyList[kItemPropertyList[i] ] = i -- also make it a set.
end

AddDebugCommand("g_props", "Prints a list of all the properties and their values of the current item.", function()
    
    local item
    local bka
    if currentItemTbl == nil then
        DoNoCurrentItemErrorMessage()
        return
    else
        item = currentItemTbl.item
        bka = currentItemTbl.bka
    end
    
    local obj = GetOwningGUIObject(item)
    
    if obj and item == obj:GetRootItem() then
        
        -- Print GUIObject properties.
        local propList = GetPropertyListForObject(obj)
        
        Log("Info for object '%s' (%s):", bka, GetItemClassName(item))
        for i=1, #propList do
            -- Under some circumstances, composite properties' composite objects might not exist
            --yet, so using Get() on these properties will fail.  Catch this with a pcall.
            pcall(function()
                Log("    %s:Get%s() = %s", bka, propList[i], obj:Get(propList[i]))
            end)
        end
        
    else
        
        -- Print basic GUIItem properties.
        Log("Info for item '%s' (%s):", bka, GetItemClassName(item))
        for i=1, #kItemPropertyList do
            local propertyName = kItemPropertyList[i]
            Log("    %s:Get%s() = %s", bka, propertyName, item["Get"..propertyName](item))
        end
        
    end
    
end)

local function GatherItemPropData(item)
    
    local obj = GetOwningGUIObject(item)
    local owner
    local propertyList
    if obj and item == obj:GetRootItem() then
        owner = obj
        propertyList = GetPropertyListForObject(obj)
    else
        owner = item
        propertyList = kItemPropertyList
    end
    
    local propData = {}
    propData.__item = item
    for i=1, #propertyList do
        local propertyName = propertyList[i]
        propData[#propData+1] = propertyName
        propData[propertyName] = owner["Get"..propertyName](owner)
    end
    
    return propData
    
end

AddDebugCommand("g_props_store", "Stores the list of properties and values of the current item for it to be diffed against with g_props_diff later.", function()
    
    local item
    local bka
    if currentItemTbl == nil then
        DoNoCurrentItemErrorMessage()
        return
    else
        item = currentItemTbl.item
        bka = currentItemTbl.bka
    end
    
    storedPropData = GatherItemPropData(item)
    
    Log("Storing property data for object '%s'", bka)
    
end)

AddDebugCommand("g_props_diff", "Diffs the property values of the current item with the stored list, and prints out only the differences.", function()
    
    local item
    local bka
    if currentItemTbl == nil then
        DoNoCurrentItemErrorMessage()
        return
    else
        item = currentItemTbl.item
        bka = currentItemTbl.bka
    end
    
    -- Gather prop data for the item now.
    local newPropData = GatherItemPropData(item)
    
    -- Gather a list of property names that is the union of the two data sets.
    local nameSet = {}
    local nameList = {}
    for i=1, #storedPropData do
        local propName = storedPropData[i]
        if not nameSet[propName] then
            nameSet[propName] = true
            table.insert(nameList, propName)
        end
    end
    for i=1, #newPropData do
        local propName = newPropData[i]
        if not nameSet[propName] then
            nameSet[propName] = true
            table.insert(nameList, propName)
        end
    end
    
    table.sort(nameList)
    
    -- Display the changes between the two sets, keeping in mind that the properties of one might
    -- not align with the properties of the other.
    local oldBKA = storedPropData.__item and GetBKAForItem(storedPropData.__item) or "nil"
    local newBKA = bka
    Log("Displaying diff from %s to %s", oldBKA, newBKA)
    local foundDiff = false
    for i=1, #nameList do
        local propName = nameList[i]
        local oldValue = storedPropData[propName]
        local newValue = newPropData[propName]
        
        if oldValue == nil then
            -- Property didn't exist in old data set.
            Log("    %s:Get%s() = nil --> %s (property added)", bka, propName, newValue)
            foundDiff = true
            
        elseif newValue == nil then
            -- Property doesn't exist in new data set.
            Log("    %s:Get%s() = %s --> nil (property removed)", bka, propName, oldValue)
            foundDiff = true
            
        elseif oldValue ~= newValue then
            -- Property has chanaged from one data set to the next.
            Log("    %s:Get%s() = %s --> %s (property changed)", bka, propName, oldValue, newValue)
            foundDiff = true
            
        end
        
    end
    if not foundDiff then
        Log("    <no differences>")
    end
    
end)

AddDebugCommand("g_mem_stats", "Prints out the total script memory usage, in kilobytes", function()
    
    local kB = collectgarbage("count")
    Log("lua memory usage: %s kB", string.format("%.2f", kB))
    
end)

local function SplitIntoLines(x)
    lines = {}
    for s in string.gmatch(x, "[^\n]+") do
        table.insert(lines, s)
    end
    return lines
end

local function RemoveLines(x, lineSubstring)
    local lines = SplitIntoLines(x)
    local cleanLines = {}
    for i=1, #lines do
        if string.find(lines[i], lineSubstring) == nil then
            table.insert(cleanLines, lines[i])
        end
    end
    local result = table.concat(cleanLines, "\n")
    return result
end

function Debug_GetStackTraceForEvent(noWarning)
    
    if not dbgStoreEventStackTraces then
        
        if not noWarning then
            Log("attempted to use Debug_GetStackTraceForEvent() without dbgStoreEventStackTraces enabled!  Returning regular stack trace instead.")
        end
        
        local result = debug.traceback()
        return result
    end
    
    local stackTrace = debug.traceback()
    
    -- Remove everything before and including the line that contains "Debug_GetStackTraceForEvent".
    local functionNamePos = string.find(stackTrace, "Debug_GetStackTraceForEvent")
    local newlineAfter = string.find(stackTrace, "\n", functionNamePos)
    stackTrace = string.sub(stackTrace, newlineAfter + 1, #stackTrace)
    
    -- Remove lines we don't care about.
    stackTrace = RemoveLines(stackTrace, "'EnqueueEventCallback'") -- The event being added to the queue.
    stackTrace = RemoveLines(stackTrace, "'FireEvent'") -- GUIObject firing the event
    stackTrace = RemoveLines(stackTrace, "'FirePropertyChangeEvent'") -- GUIObject firing an automatic property change event
    
    -- Cut off the stack trace where we find mention of "ProcessEventQueue" -- this is the end of
    -- the relevant portion of the stack (it might not exist, so be sure to check).
    local processEventQueueFind = string.find(stackTrace, "ProcessEventQueue")
    if processEventQueueFind then
        local newlineBeforePEQ1 = 0
        local newlineBeforePEQ2 = 0
        while newlineBeforePEQ1 and newlineBeforePEQ1 < processEventQueueFind do
            newlineBeforePEQ2 = newlineBeforePEQ1
            newlineBeforePEQ1 = string.find(stackTrace, "\n", newlineBeforePEQ2 + 1)
        end
        stackTrace = string.sub(stackTrace, 1, newlineBeforePEQ2)
    end
    
    if not dbgQueuedEventStack then
        dbgQueuedEventStack = {}
    end
    
    -- Append the previous stack trace to complete this stack trace.
    if #dbgQueuedEventStack > 0 then
        stackTrace = stackTrace .. dbgQueuedEventStack[#dbgQueuedEventStack]
    end
    
    return stackTrace
    
end

AddDebugCommand("g_cursor_event_log", "Sets/Toggles logging mouse cursor hovering (OnMouseEnter, OnMouseExit) events (excluding OnMouseHover to avoid spam, see g_cursor_hover_event_log).", function(state)
    if state == nil then
        gCursorEventLog = not gCursorEventLog
    else
        gCursorEventLog = kStateToBool[state] == true
    end
    Log("%s cursor event logging.", gCursorEventLog and "Enabled" or "Disabled")
end)

AddDebugCommand("g_cursor_hover_event_log", "Sets/Toggles logging mouse cursor hovering (OnMouseHover) event, including which items are considered, and which item is chosen.  This is separate from g_cursor_event_log simply to avoid spamming console.", function(state)
    if state == nil then
        gHoverEventLog = not gHoverEventLog
    else
        gHoverEventLog = kStateToBool[state] == true
    end
    Log("%s cursor hover event logging.", gHoverEventLog and "Enabled" or "Disabled")
end)

AddDebugCommand("g_click_event_log", "Sets/Toggles logging mouse click events, including which items are considered, and which item is chosen.", function(state)
    if state == nil then
        gClickEventLog = not gClickEventLog
    else
        gClickEventLog = kStateToBool[state] == true
    end
    Log("%s click event logging.", gClickEventLog and "Enabled" or "Disabled")
end)

AddDebugCommand("g_wheel_event_log", "Sets/Toggles logging mouse wheel events, including which items are considered, and which item is chosen.", function(state)
    if state == nil then
        gWheelEventLog = not gWheelEventLog
    else
        gWheelEventLog = kStateToBool[state] == true
    end
    Log("%s wheel event logging.", gWheelEventLog and "Enabled" or "Disabled")
end)

AddDebugCommand("g_key_event_log", "Sets/Toggles logging keyboard events, including which items are considered, and which item is chosen.", function(state)
    if state == nil then
        gKeyEventLog = not gKeyEventLog
    else
        gKeyEventLog = kStateToBool[state] == true
    end
    Log("%s key event logging.", gKeyEventLog and "Enabled" or "Disabled")
end)

local function CreateObject(className, name, asChild)
    
    if asChild and currentItemTbl == nil then
        Log("no current item to use as a parent.")
        return
    end
    
    local cls = _G[className]
    if cls == nil then
        Log("'%s' isn't a class (was nil, did you forget to load a script?)", className)
    elseif not GetIsClass(cls) then
        Log("'%s' isn't a class", className)
        return
    elseif not classisa(className, "GUIObject") then
        Log("'%s' is not a GUIObject-derived class.", className)
        return
    end
    
    local parent = nil
    if asChild then
        parent = currentItemTbl.item
    end
    
    local result = CreateGUIObject(name, cls, parent)
    SetCurrentItem(result:GetRootItem(), name)
    
end

AddDebugCommand("g_create_object", "Creates a new GUIObject with the given class name", function(className, objName)
    if not className or not objName then
        Log("usage g_create_object className objName")
        return
    end
    
    CreateObject(className, objName)
    
end)

AddDebugCommand("g_create_child_object", "Creates a new GUIObject with the given class name as a child of the current item", function(className, objName)
    if not className or not objName then
        Log("usage g_create_child_object className objName")
        return
    end
    
    CreateObject(className, objName, true)
    
end)

local function ParseVector(varTbl)
    
    if #varTbl < 2 or #varTbl > 3 then
        Log("Vector type requires 2 or 3 values, got %s", #varTbl)
        return
    end
    
    local result = Vector(0, 0, 0)
    
    local x = tonumber(varTbl[1])
    if not x then
        Log("unable to convert '%s' to a number.", varTbl[1])
        return
    end
    result.x = x
    
    local y = tonumber(varTbl[2])
    if not y then
        Log("unable to convert '%s' to a number.", varTbl[2])
        return
    end
    result.y = y
    
    local z
    if varTbl[3] == nil then
        z = 0
    else
        z = tonumber(varTbl[3])
        if not z then
            Log("unable to convert '%s' to a number.", varTbl[3])
            return
        end
    end
    result.z = z
    
    return result
    
end

local function ParseColor(varTbl)
    
    if #varTbl < 3 or #varTbl > 4 then
        Log("Color type requires 3 or 4 values, got %s", #varTbl)
        return
    end
    
    local result = Color(0, 0, 0, 0)
    
    local r = tonumber(varTbl[1])
    if not r then
        Log("unable to convert '%s' to a number.", varTbl[1])
        return
    end
    result.r = r
    
    local g = tonumber(varTbl[2])
    if not g then
        Log("unable to convert '%s' to a number.", varTbl[2])
        return
    end
    result.g = g
    
    local b = tonumber(varTbl[3])
    if not b then
        Log("unable to convert '%s' to a number.", varTbl[3])
        return
    end
    result.b = b
    
    local a
    if varTbl[4] == nil then
        a = 1
    else
        a = tonumber(varTbl[4])
        if not a then
            Log("unable to convert '%s' to a number.", varTbl[4])
            return
        end
    end
    result.a = a
    
    return result
    
end

local function ParseNumber(varTbl)
    
    if #varTbl ~= 1 then
        Log("Number type requires 1 value, got %s", #varTbl)
        return
    end
    
    local result = tonumber(varTbl[1])
    if not result then
        Log("unable to convert '%s' to a number", varTbl[1])
        return
    end
    
    return result
    
end

local function ParseString(varTbl)
    
    local result = table.concat(varTbl, " ")
    return result
    
end

local kBooleanStrings =
{
    ["0"]       = false,
    ["1"]       = true,
    ["f"]       = false,
    ["t"]       = true,
}

local function ParseBoolean(varTbl)
    
    if #varTbl ~= 1 then
        Log("Boolean type requires 1 value, got %s", #varTbl)
        return
    end
    
    local input = string.lower(string.sub(varTbl[1], 1, 1))
    local result = kBooleanStrings[input]
    if result == nil then
        Log("Unable to convert '%s' to a boolean value", varTbl[1])
        return
    end
    
    return result
    
end

AddDebugCommand("g_set_prop", "Sets a property value of the current item.", function(propName, ...)
    if not currentItemTbl then
        Log("no item selected!")
        return
    end
    
    if not propName then
        Log("usage g_set_prop propertyName propertyValue propertyValuePart2 etc...")
        Log("    examples:")
        Log("    g_set_prop Position 100 100 -- valid")
        Log("    g_set_prop Position 100 -- invalid, needs at least 2 values for vector types")
        Log("    g_set_prop Opacity 0.5 -- valid, not a property, but there are SetOpacity and GetOpacity methods defined.")
        Log("    g_set_prop Color 0.5 1 0.25 -- valid, alpha is assumed to be 1")
        return
    end
    
    -- If we're a GUIObject, use this instead of the GUIItem.
    local itemOrObj = currentItemTbl.item
    do
        local owner = GetOwningGUIObject(currentItemTbl.item)
        if owner and owner:GetRootItem() == itemOrObj then
            itemOrObj = owner
        end
    end
    
    -- Get the current value to deduce the type we're parsing for. (Yes, the type can change, but
    -- that's rare, and not something I really care to worry about here.)
    local currentValue
    if itemOrObj:isa("GUIItem") then
        if not kItemPropertyList[propName] then
            Log("currentItem (GUIItem) does not have property '%s'", propName)
            return
        end
        local getterName = "Get"..propName
        local getter = GUIItem[getterName]
        assert(getter)
        currentValue = getter(itemOrObj)
    else
        if not itemOrObj:GetPropertyExists(propName) then
            Log("currentItem (%s) does not have property '%s'", itemOrObj.classname, propName)
            return
        end
        currentValue = itemOrObj:Get(propName)
    end
    assert(currentValue ~= nil)
    
    -- Parse the property value according to the type of the current value.
    local typeName = GetTypeName(currentValue)
    local varTbl = {...}
    local value
    if typeName == "Vector" then
        value = ParseVector(varTbl)
    elseif typeName == "Color" then
        value = ParseColor(varTbl)
    elseif typeName == "number" then
        value = ParseNumber(varTbl)
    elseif typeName == "string" then
        value = ParseString(varTbl)
    elseif typeName == "boolean" then
        value = ParseBoolean(varTbl)
    else
        Log("unrecognized property type! (typeName = %s", typeName)
        return
    end
    
    if value == nil then
        return
    end
    
    -- Set value.
    if itemOrObj:isa("GUIItem") then
        local setterName = "Set"..propName
        local setter = GUIItem[setterName]
        assert(setter) -- should exist if the getter exists.
        setter(itemOrObj, value)
    else
        itemOrObj:Set(propName, value)
    end
    
    Log("Set '%s' of item %s to %s", propName, currentItemTbl.bka, value)
    
end)

AddDebugCommand("g_log_prop", "Logs the property changes of the given object.", function(...)
    
    local propNames = {...}
    if #propNames == 0 then
        Log("usage: g_log_prop PropertyName1 PropertyName2 .... etc.")
        return
    end
    
    local item
    local bka
    if currentItemTbl == nil then
        DoNoCurrentItemErrorMessage()
        return
    else
        item = currentItemTbl.item
        bka = currentItemTbl.bka
    end
    
    local obj = GetOwningGUIObject(item)
    if not obj then
        Log("No owning object found!")
        return
    elseif obj:GetRootItem() ~= item then
        Log("Not the root item!")
        return
    end
    
    if not obj.debugLogProperties then
        obj.debugLogProperties = {}
    end
    
    -- Attempt to add the given list of property names to the debug log set.  Make note of which
    -- are added, and which were already present.
    local processed = {}
    local added = {}
    local alreadyAdded = {}
    for i=1, #propNames do
        local propName = propNames[i]
        if not processed[propName] then
            processed[propName] = true -- keep track of duplicates
            if obj.debugLogProperties[propName] then
                table.insert(alreadyAdded, propName)
            else
                table.insert(added, propName)
                obj.debugLogProperties[propNames[i]] = true
            end
        end
    end
    
    if #added == 0 then
        Log("Added 0 properties to log (all properties were already setup to be logged)")
    else
        if #alreadyAdded == 0 then
            Log("Added %d properties: %s", #added, table.concat(added, ", "))
        else
            Log("Added %d properties: %s (skipped %d already present: %s)", #added, table.concat(added, ", "), #alreadyAdded, table.concat(alreadyAdded, ", "))
        end
    end
    
end)

AddDebugCommand("g_rem_log_prop", "Removes the given property names from the log set.", function(...)
    
    local propNames = {...}
    if #propNames == 0 then
        Log("usage: g_rem_log_prop PropertyName1 PropertyName2 .... etc.")
        return
    end
    
    local item
    local bka
    if currentItemTbl == nil then
        DoNoCurrentItemErrorMessage()
        return
    else
        item = currentItemTbl.item
        bka = currentItemTbl.bka
    end
    
    local obj = GetOwningGUIObject(item)
    if not obj then
        Log("No owning object found!")
        return
    elseif obj:GetRootItem() ~= item then
        Log("Not the root item!")
        return
    end
    
    -- Attempt to remove the given property list from the debug logging set.  Make note of which
    -- are removed, and which were already removed.
    local processed = {}
    local removed = {}
    local notPresent = {}
    if obj.debugLogProperties then
        for i=1, #propNames do
            local propName = propNames[i]
            if not processed[propName] then
                processed[propName] = true
                if obj.debugLogProperties[propName] then
                    table.insert(removed, propName)
                    obj.debugLogProperties[propName] = nil
                else
                    table.insert(notPresent, propName)
                end
            end
        end
        
        -- Delete the table if it's empty.
        local isEmpty = true
        for key, value in pairs(obj.debugLogProperties) do
            isEmpty = false
            break
        end
        if isEmpty then
            obj.debugLogProperties = nil
        end
    end
    
    if #removed == 0 then
        if obj.debugLogProperties == nil then
            Log("Removed 0 properties (set is empty)")
        else
            Log("Removed 0 properties (none of the given properties were found in the set)")
        end
    else
        if #notPresent == 0 then
            Log("Removed %d properties: %s", #removed, table.concat(removed, ", "))
        else
            Log("Removed %d properties: %s (skipped %d that weren't found: %s)", #removed, table.concat(removed, ", "), #notPresent, table.concat(notPresent, ", "))
        end
    end
    
end)

AddDebugCommand("g_clear_log_prop", "Removes all property logging from this object.", function()
    
    local item
    local bka
    if currentItemTbl == nil then
        DoNoCurrentItemErrorMessage()
        return
    else
        item = currentItemTbl.item
        bka = currentItemTbl.bka
    end
    
    local obj = GetOwningGUIObject(item)
    if not obj then
        Log("No owning object found!")
        return
    elseif obj:GetRootItem() ~= item then
        Log("Not the root item!")
        return
    end
    
    if obj.debugLogProperties then
        obj.debugLogProperties = nil
        Log("Cleared property logging from this object.")
    else
        Log("Logging was not enabled for this object.")
    end

end)

