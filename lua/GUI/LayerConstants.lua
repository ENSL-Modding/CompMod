-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/GUI/LayerConstants.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--    
--    Centralized location for layer numbers to be found.  Provides a useful means of reserving
--    layer numbers for the ordering desired (Eg popups should be over the menu, tooltips should be
--    over popups, etc.)
--    
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

-- Mapping of layer name --> layer number.
local layerConstantsByName = {}

-- Sorted list of layer names, sorted by descending layer number (top most layer is first)
local layerNamesSorted = {}

-- Layer number to start at
local kDefaultLayerNumber = 1000

-- How much space to add between layers if using AddAbove/Below with nothing Above/Below.
local kDefaultSeparation = 100

local function ValidateLayerNameNotInUse(name, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    if layerConstantsByName[name] ~= nil then
        error(string.format("Layer constant named '%s' already defined! (defined as %d)", name, layerConstantsByName[name]), errorDepth)
    end
end

local function ValidateLayerValue(value, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    if type(value) ~= "number" then
        error(string.format("Expected an integer between -2,147,483,648 and 2,147,483,647, got %s-type instead.", type(value)), errorDepth)
    elseif value < -2147483648 or value > 2147483647 then
        error(string.format("Layer number must be an integer between -2,147,483,648 and 2,147,483,647.  Got %s", value), errorDepth)
    elseif math.floor(value) ~= value then
        error(string.format("Layer number must be an integer.  Got %s", value), errorDepth)
    end
end

local function SortLayerNames()
    
    table.sort(layerNamesSorted,
        function(a, b)
            local aLayer = layerConstantsByName[a]
            local bLayer = layerConstantsByName[b]
            assert(aLayer)
            assert(bLayer)
            return aLayer > bLayer
        end)
    
end

local function PrintLayerNames()
    Log("%s layer names:", #layerNamesSorted)
    for i=1, #layerNamesSorted do
        local layerName = layerNamesSorted[i]
        Log(string.format("    %12d - %-30s", layerConstantsByName[layerName], layerName))
    end
end

-- Returns the layer number with the given name, or "default" if there is no layer with the given name.
function GetLayerConstant(name, default)
    return layerConstantsByName[name] or default
end

-- Adds a layer name with the given layer number.  Does not check if the layer number is already in-use or not.
function AddLayerConstant(name, value)
    
    ValidateLayerNameNotInUse(name, 2)
    ValidateLayerValue(value, 2)
    
    layerConstantsByName[name] = value
    layerNamesSorted[#layerNamesSorted+1] = name
    
    SortLayerNames()
    
    return value
    
end

-- Adds a layer name with a layer number computed midway between the layer name specified, and the
-- one above the layer name specified.  If there is no layer above the given layer, a reasonable
-- value will be chosen.
-- Example:
--                                                                    
-- 200 - A           -- Add C above B...                       200 - A
-- 100 - B   ---->   AddLayerConstantAbove("C", "B")   ---->   150 - C
--                                                             100 - B
--                                                                    
function AddLayerConstantAbove(name, aboveThisName)
    
    ValidateLayerNameNotInUse(name, 2)
    
    local prev = nil
    local curr = nil
    local found = false
    for i=1, #layerNamesSorted do
        prev = curr
        curr = layerNamesSorted[i]
        if curr == aboveThisName then
            found = true
            break
        end
    end
    
    if found then
        if curr == nil then
            -- There are no layers!  This is the first.
            local result = AddLayerConstant(name, kDefaultLayerNumber)
            return result
        elseif prev == nil then
            -- There isn't any layer above this layer!
            local result = AddLayerConstant(name, layerConstantsByName[curr] + kDefaultSeparation)
            return result
        else
            local upper = layerConstantsByName[prev]
            local lower = layerConstantsByName[curr]
            local midPoint = math.floor((upper + lower) * 0.5)
            local result = AddLayerConstant(name, midPoint)
            return result
        end
    else
        error(string.format("Unable to find layer named '%s'.  Try checking beforehand with 'GetLayerConstant(%s, nil) ~= nil'", aboveThisName, aboveThisName), 2)
    end
    
end

-- Same as above, but puts the new layer beneath the named one.
function AddLayerConstantBelow(name, belowThisName)
    
    ValidateLayerNameNotInUse(name, 2)
    
    local prev = nil
    local curr = nil
    local found = false
    for i=#layerNamesSorted, 1, -1 do
        prev = curr
        curr = layerNamesSorted[i]
        if curr == belowThisName then
            found = true
            break
        end
    end
    
    if found then
        if curr == nil then
            -- There are no layers!  This is the first.
            local result = AddLayerConstant(name, kDefaultLayerNumber)
            return result
        elseif prev == nil then
            -- There isn't any layer below this layer!
            local result = AddLayerConstant(name, layerConstantsByName[curr] - kDefaultSeparation)
            return result
        else
            local upper = layerConstantsByName[prev]
            local lower = layerConstantsByName[curr]
            local midPoint = math.floor((upper + lower) * 0.5)
            local result = AddLayerConstant(name, midPoint)
            return result
        end
    else
        error(string.format("Unable to find layer named '%s'.  Try checking beforehand with 'GetLayerConstant(%s, nil) ~= nil'", belowThisName, belowThisName), 2)
    end
    
end

-- Mods can hook into this to define their own layers.
function DefineLayerConstants()
    
    AddLayerConstant("MainMenu", 1000)
    AddLayerConstantAbove("Popup", "MainMenu")
    AddLayerConstantAbove("Tooltip", "Popup")
    AddLayerConstantAbove("FullscreenVideo", "Tooltip")
    
    AddLayerConstantBelow("BadgesCustomizer", "Tooltip")
    
end

Event.Hook("Console_print_layers", PrintLayerNames)

-- DEBUG
--[=[
Script.Load("lua/GUI/GUIDebug.lua")
DebugStuff()
Event.Hook("Console_add_layer", function(name, value)
    value = tonumber(value)
    AddLayerConstant(name, value)
    PrintLayerNames()
end)

Event.Hook("Console_add_layer_above", function(name, otherName)
    AddLayerConstantAbove(name, otherName)
    PrintLayerNames()
end)

Event.Hook("Console_add_layer_below", function(name, otherName)
    AddLayerConstantBelow(name, otherName)
    PrintLayerNames()
end)
--]=]
