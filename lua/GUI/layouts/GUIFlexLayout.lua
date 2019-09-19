-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/GUI/layouts/GUIFlexLayout.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--    
--    Layout that spreads out objects with an even amount of spacing between them.
--  
--  Parameters (* = required)
--      autoArrange
--      backPadding
--      deferredArrange     If true, this layout will _not_ rearrange itself until the end of
--                          the frame.  Saves a lot of performance if it has a lot of objects to
--                          arrange and is updated frequently.  However, any side effects of
--                          _Arrange() will not be seen until the end of the frame.
--      frontPadding
--     *orientation         The orientation of the layout.  Expects either "horizontal" or
--                          "vertical".
--  
--  Properties:
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
--    
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/layouts/GUIOrientedLayout.lua")

---@class GUIFlexLayout : GUIOrientedLayout
class "GUIFlexLayout" (GUIOrientedLayout)

GUIFlexLayout:AddClassProperty("FixedMinorSize", false)

function GUIFlexLayout.GetRelevantPropertyNames(nameTable)
    table.insert(nameTable, "FixedMinorSize")
    table.insert(nameTable, "Size")
end

local function GetExpansion(item)
    local itemOwner = GetOwningGUIObject(item)
    if itemOwner and itemOwner:GetPropertyExists("Expansion") then
        local result = itemOwner:GetExpansion()
        return result
    end
    return 1.0
end

function GUIFlexLayout:_Arrange(items)
    
    PROFILE("GUIFlexLayout:_Arrange")
    
    local majorAxis = self:GetMajorAxis()
    local minorAxis = self:GetMinorAxis()
    
    local size = self:GetSize()
    local frontPadding = self:GetFrontPadding()
    local backPadding = self:GetBackPadding()
    local fixedMinorSize = self:GetFixedMinorSize()
    
    if #items == 0 then
        return -- no items, nothing to do.
    end
    
    -- Calculate the total length of the layout first, without any added padding between items.
    local totalMajorSize = frontPadding + backPadding
    local totalWeight = 0
    for i=1, #items do
        local item = items[i]
    
        if item:GetVisible() then
            
            local expansion = GetExpansion(item)
            local itemLocalSize = item:GetSize() * item:GetScale() * expansion
            totalMajorSize = totalMajorSize + Dot2D(majorAxis, itemLocalSize)
            totalWeight = totalWeight + expansion
            
        end
    end
    
    if totalWeight == 0 then
        return -- all items were either hidden or had expansion value of 0.
    end
    
    -- Calculate the extra padding needed.
    local leftover = Dot2D(majorAxis, size) - totalMajorSize
    local leftoverPerItem = leftover / totalWeight
    
    -- Distribute the extra amongst the items.
    local currentMajor = self:GetFrontPadding()
    local maxMinorSize = 0
    for i=1, #items do
        
        local item = items[i]
        
        if item:GetVisible() then
            
            local expansion = GetExpansion(item)
            local itemLocalSize = item:GetSize() * item:GetScale() * expansion
        
            -- Half in front.
            currentMajor = currentMajor + leftoverPerItem * expansion * 0.5
        
            local newPosition = majorAxis * currentMajor + minorAxis * item:GetPosition()
            local newHotSpot = minorAxis * item:GetHotSpot()
            local newAnchor = minorAxis * item:GetAnchor()
        
            if owner and owner ~= self then
                owner:SetPosition(newPosition)
                owner:SetHotSpot(newHotSpot)
                owner:SetAnchor(newAnchor)
            else
                item:SetPosition(newPosition)
                item:SetHotSpot(newHotSpot)
                item:SetAnchor(newAnchor)
            end
        
            currentMajor = currentMajor + Dot2D(majorAxis, itemLocalSize)
            maxMinorSize = math.max(maxMinorSize, Dot2D(minorAxis, itemLocalSize))
        
            -- Half in back.
            currentMajor = currentMajor + leftoverPerItem * expansion * 0.5
            
        end
        
    end
    
    currentMajor = currentMajor + backPadding
    
    local finalMinorSize
    if fixedMinorSize then
        finalMinorSize = Dot2D(minorAxis, size)
    else
        finalMinorSize = maximumMinorSize
    end
    
    self:SetSize(majorAxis * size + minorAxis * finalMinorSize)
    
end
