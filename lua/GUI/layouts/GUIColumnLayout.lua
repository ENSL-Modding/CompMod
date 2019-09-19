-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. ============
--
-- lua/GUI/layouts/GUIColumnLayout.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Arranges objects into vertical columns.  Objects are added to columns left-to-right in a
--    row-major order.  The layout will expand vertically to accommodate the height of the columns,
--    and the columns will stretch horizontally to fill the width of the layout.
--  
--  Parameters (* = required)
--      autoArrange
--      backPadding
--      deferredArrange     If true, this layout will _not_ rearrange itself until the end of
--                          the frame.  Saves a lot of performance if it has a lot of objects to
--                          arrange and is updated frequently.  However, any side effects of
--                          _Arrange() will not be seen until the end of the frame.
--      frontPadding
--  
--  Properties
--      AutoArrange         Whether or not the layout will update the arrangement on its own.
--                          If false, the programmer must either call ArrangeNow() or set auto
--                          arrange back to true, otherwise the layout will never update!
--      ColumnSpacing       How much spacing to add between columns.
--      ColumnWidthPadding  Extra padding to add to the width of the columns when calculating
--                          their size.
--      LeftPadding         How much padding to add to the left of the first column.
--      NumColumns          How many columns to distribute the objects amongst.
--      RightPadding        How much padding to add to the right of the last column.
--      Spacing             How much vertical spacing to add between objects within the same
--                          column.
--  
-- ========= For more information, visit us at http://www.unknownworlds.com =======================

Script.Load("lua/GUI/layouts/GUILayout.lua")

---@class GUIColumnLayout : GUILayout
class "GUIColumnLayout" (GUILayout)

GUIColumnLayout:AddClassProperty("ColumnSpacing", 0)
GUIColumnLayout:AddClassProperty("ColumnWidthPadding", 0)
GUIColumnLayout:AddClassProperty("LeftPadding", 0)
GUIColumnLayout:AddClassProperty("NumColumns", 3)
GUIColumnLayout:AddClassProperty("RightPadding", 0)
GUIColumnLayout:AddClassProperty("Spacing", 0)

function GUIColumnLayout.GetRelevantPropertyNames(nameTable)
    table.insert(nameTable, "LeftPadding")
    table.insert(nameTable, "RightPadding")
    table.insert(nameTable, "ColumnSpacing")
    table.insert(nameTable, "ColumnWidthPadding")
    table.insert(nameTable, "Spacing")
    table.insert(nameTable, "NumColumns")
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

function GUIColumnLayout:_Arrange(items)
    
    PROFILE("GUIColumnLayout:_Arrange")
    
    local topPadding = self:GetFrontPadding()
    local bottomPadding = self:GetBackPadding()
    local leftPadding = self:GetLeftPadding()
    local rightPadding = self:GetRightPadding()
    local spacing = self:GetSpacing()
    local columnSpacing = self:GetColumnSpacing()
    local numColumns = self:GetNumColumns()
    local columnWidthPadding = self:GetColumnWidthPadding()
    local size = self:GetSize()
    
    -- Compute the maximum width of each column.
    local columnWidths = {}
    for i=1, #items do
        
        local item = items[i]
        
        if item:GetVisible() then
            
            local columnIndex = ((i - 1) % numColumns) + 1
            columnWidths[columnIndex] = columnWidths[columnIndex] or 0
            
            local itemLocalSize = item:GetSize() * item:GetScale()
            columnWidths[columnIndex] = math.max(columnWidths[columnIndex], itemLocalSize.x)
            
        end
    end
    
    -- Compute how much width that leaves for the columns to be spaced within.
    local remainingWidth = size.x - leftPadding - rightPadding - ((numColumns-1) * columnSpacing) - (numColumns * columnWidthPadding)
    for i=1, numColumns do
        remainingWidth = remainingWidth - (columnWidths[i] or 0)
    end
    local extraWidthPerColumn = remainingWidth / numColumns
    
    -- Compute each column's x position.
    local currentYValues = {}
    local columnXPositions = {}
    local currentXPos = leftPadding
    for i=1, numColumns do
        
        currentXPos = currentXPos + extraWidthPerColumn * 0.5
        columnXPositions[i] = currentXPos
        currentXPos = currentXPos + (columnWidths[i] or 0) + extraWidthPerColumn * 0.5 + columnSpacing
        currentYValues[i] = topPadding
        
    end
    
    for i=1, #items do
        
        local item = items[i]
    
        if item:GetVisible() then
        
            local owner = GetOwningGUIObject(item)
            local itemLocalSize = item:GetSize() * item:GetScale()
        
            local columnIndex = ((i - 1) % numColumns) + 1
        
            local newPositionX = columnXPositions[columnIndex]
            local newPositionY = currentYValues[columnIndex]
        
            if owner and owner ~= self then
                owner:SetPosition(newPositionX, newPositionY)
                owner:SetHotSpot(0, 0)
                owner:SetAnchor(0, 0)
            else
                item:SetPosition(newPositionX, newPositionY)
                item:SetHotSpot(0, 0)
                item:SetAnchor(0, 0)
            end
        
            local expansion = GetExpansion(item)
            local ySize = (itemLocalSize.y + spacing) * expansion
            currentYValues[columnIndex] = currentYValues[columnIndex] + ySize
            
        end
        
    end
    
    local maxY = 0
    for i=1, numColumns do
        currentYValues[i] = currentYValues[i] + bottomPadding
        currentYValues[i] = math.max(0, currentYValues[i] - spacing)
        maxY = math.max(maxY, currentYValues[i])
    end
    
    self:SetSize(size.x, maxY)
    
end

