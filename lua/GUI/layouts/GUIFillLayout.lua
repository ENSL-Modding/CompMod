-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/GUI/layouts/GUIFillLayout.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--    
--    A layout that resizes its contents to fill its space.  All objects expand to fill the space.
--    Objects are given a weight to control how much of the space they should fill relative to
--    other objects.
--
--  Parameters (* = required)
--      autoArrange
--      backPadding
--      deferredArrange     If true, this layout will _not_ rearrange itself until the end of
--                          the frame.  Saves a lot of performance if it has a lot of objects to
--                          arrange and is updated frequently.  However, any side effects of
--                          _Arrange() will not be seen until the end of the frame.
--      fixedMinorSize
--      frontPadding
--     *orientation         The orientation of the layout.  Expects either "horizontal" or
--                          "vertical".
--  
--  Child Parameters
--      weight              Value that determines how much space each child will be given in the
--                          layout.  Must be a number > 0.  If nil, will default to 1.0.  Can be
--                          adjusted later using SetItemWeight().
--  
--  Properties
--      AutoArrange         Whether or not the layout will update the arrangement on its own.
--                          If false, the programmer must either call ArrangeNow() or set auto
--                          arrange back to true, otherwise the layout will never update!
--      BackPadding         How much extra space to add to the back of the layout (right padding
--                          in horizontal layout, bottom padding in vertical layout).
--      FixedMinorSize      Whether or not the minor size (eg height in a horizontal layout) is
--                          fixed to the size it's set to, or if it adjusts to the size of the
--                          contents.
--      FrontPadding        How much extra space to add to the front of the layout (left padding
--                          in horizontal layout, top padding in vertical layout).
--      Spacing             How much spacing to add between items.
--    
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/layouts/GUIOrientedLayout.lua")

---@class GUIFillLayout : GUIOrientedLayout
class "GUIFillLayout" (GUIOrientedLayout)

GUIFillLayout:AddClassProperty("Spacing", 0)
GUIFillLayout:AddClassProperty("FixedMinorSize", false)

function GUIFillLayout.GetRelevantPropertyNames(nameTable)
    table.insert(nameTable, "Size")
    table.insert(nameTable, "Spacing")
    table.insert(nameTable, "FixedMinorSize")
end

local function OnChildAdded(self, childItem, params)
    
    assert(self.itemWeights[childItem] == nil)
    
    local weight = params and params.weight
    
    if weight == nil then
        weight = 1.0
    elseif type(weight) ~= "number" then
        error(string.format("Expected a number for weight, got %s-type instead", GetTypeName(weight)), 2)
    elseif weight <= 0.0 then
        error(string.format("Weight must be greater than 0, got %f instead", weight), 2)
    end
    
    self.itemWeights[childItem] = weight
    self:SetNeedsArrange()
    
end

function GUIFillLayout:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    RequireType({"boolean", "nil"}, params.fixedMinorSize, "params.fixedMinorSize", errorDepth)
    
    GUIOrientedLayout.Initialize(self, params, errorDepth)
    
    if params.fixedMinorSize then
        self:SetFixedMinorSize(params.fixedMinorSize)
    end
    
    -- Mapping of GUIItem -> item weight.
    self.itemWeights = {}
    
    self:HookEvent(self, "OnChildAdded", OnChildAdded)
    
end

function GUIFillLayout:OnChildRemoved(childItem)
    
    self.itemWeights[childItem] = nil
    self:SetNeedsArrange()
    
end

function GUIFillLayout:SetItemWeight(objOrItem, weight)
    
    local item
    if GetIsaGUIObject(objOrItem) then
        item = objOrItem:GetRootItem()
    elseif GetIsaGUIItem(objOrItem) then
        item = objOrItem
    else
        error(string.format("Expected a GUIObject or GUIItem, got %s-type instead", GetTypeName(objOrItem)), 2)
    end
    
    if not self.itemWeights[item] then
        error("Cannot call SetItemWeight with an item that is not a child of the layout!", 2)
    end
    
    if type(weight) ~= "number" then
        error(string.format("Expected a number for weight, got %s-type instead", GetTypeName(weight)), 2)
    elseif weight <= 0.0 then
        error(string.format("Weight must be at greater than 0, got %f instead", weight), 2)
    end
    
    self.itemWeights[item] = weight
    self:SetNeedsArrange()
    
end

local function GetExpansion(item)
    
    PROFILE("GUIFillLayout GetExpansion")
    
    local itemOwner = GetOwningGUIObject(item)
    if itemOwner and itemOwner:GetPropertyExists("Expansion") then
        local result = itemOwner:GetExpansion()
        return result
    end
    return 1.0
end

local frontCompletionFactors = {}
local backCompletionFactors = {}
function GUIFillLayout:_Arrange(items)
    
    PROFILE("GUIFillLayout:_Arrange")
    
    local majorAxis = self:GetMajorAxis()
    local minorAxis = self:GetMinorAxis()
    
    local size = self:GetSize()
    local frontPadding = self:GetFrontPadding()
    local backPadding = self:GetBackPadding()
    local fixedMinorSize = self:GetFixedMinorSize()
    local spacing = self:GetSpacing() * 0.5 -- half in front, half in back.
    
    if #items == 0 then
        return -- no items, nothing to do.
    end
    
    -- Cache items expansion, for performance.
    local itemsExpansion = {}
    for i=1, #items do
        itemsExpansion[i] = GetExpansion(items[i])
    end
    
    local frontCompletion = 0
    for i=1, #items do
        frontCompletionFactors[i] = frontCompletion
        frontCompletion = math.min(frontCompletion + itemsExpansion[i], 1)
    end
    
    local backCompletion = 0
    for i=#items, 1, -1 do
        backCompletionFactors[i] = backCompletion
        backCompletion = math.min(backCompletion + itemsExpansion[i], 1)
    end
    
    -- Calculate the total weight of all the child objects.  Also calculate the amount of space
    -- between objects that will be needed.
    local majorSizeToFill = Dot2D(majorAxis, size) - frontPadding - backPadding
    local totalWeight = 0
    for i=1, #items do
        local item = items[i]
    
        if item:GetVisible() then
        
            local itemWeight = self.itemWeights[item]
            if type(itemWeight) ~= "number" then
                itemWeight = 1
            end
            assert(itemWeight > 0)
            local expansion = itemsExpansion[i]
            totalWeight = totalWeight + itemWeight * expansion
            majorSizeToFill = majorSizeToFill - spacing * frontCompletionFactors[i] * expansion - spacing * backCompletionFactors[i] * expansion
            
        end
        
    end
    
    if totalWeight == 0 then
        -- All items were either not visible or had expansion of zero.
        return
    end
    
    local majorSizePerWeightUnit = majorSizeToFill / totalWeight
    
    -- Arrange items.
    local currentMajor = frontPadding
    local maxMinorSize = 0
    for i=1, #items do
        
        local item = items[i]
    
        if item:GetVisible() then
        
            local owner = GetOwningGUIObject(item)
            local itemWeight = self.itemWeights[item]
            if type(itemWeight) ~= "number" then
                itemWeight = 1
            end
            local expansion = itemsExpansion[i]
            local weight = itemWeight * expansion / (Dot2D(majorAxis, item:GetScale()))
        
            -- Add front spacing to the item.
            currentMajor = currentMajor + spacing * frontCompletionFactors[i] * expansion
        
            local itemMajorSize = majorSizePerWeightUnit * weight
            local itemMajorScale = Dot2D(majorAxis, item:GetScale())
        
            local newPosition = majorAxis * currentMajor + minorAxis * item:GetPosition()
            local newSize
            if expansion > 0 then
                newSize = majorAxis * itemMajorSize / expansion + minorAxis * item:GetSize()
            else
                newSize = minorAxis * item:GetSize()
            end
            local newHotSpot = minorAxis * item:GetHotSpot()
            local newAnchor = minorAxis * item:GetAnchor()
        
            if owner and owner ~= self then
                owner:SetPosition(newPosition)
                owner:SetSize(newSize)
                owner:SetHotSpot(newHotSpot)
                owner:SetAnchor(newAnchor)
            else
                item:SetPosition(newPosition)
                item:SetSize(newSize)
                item:SetHotSpot(newHotSpot)
                item:SetAnchor(newAnchor)
            end
        
            maxMinorSize = math.max(maxMinorSize, Dot2D(minorAxis, item:GetSize() * item:GetScale()))
        
            currentMajor = currentMajor + itemMajorSize * itemMajorScale
        
            -- Add back spacing to the item.
            currentMajor = currentMajor + spacing * backCompletionFactors[i] * expansion
            
        end
        
    end
    
    if not fixedMinorSize then
        self:SetSize(majorAxis * size + minorAxis * maxMinorSize)
    end
    
end
