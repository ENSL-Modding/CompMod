-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/GUIMenuNineBox.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--    
--    A box graphic that is composed of 9 segments, with the middle 5 being stretched to the
--    necessary size.
--                                                   
--                                |---|---------|---|
--                                | 0 |    1    | 2 |
--      |---|---|---|             |---|---------|---|
--      | 0 | 1 | 2 |             |   |         |   |
--      |---|---|---|             |   |         |   |
--      | 3 | 4 | 5 |    ---->    | 3 |    4    | 5 |
--      |---|---|---|             |   |         |   |
--      | 6 | 7 | 8 |             |   |         |   |
--      |---|---|---|             |---|---------|---|
--                                | 6 |    7    | 8 |
--                                |---|---------|---|
--                                                   
--    
--  Parameters (* = required)
--     *col0..2Width        Specify the widths of the columns in the source texture.
--     *row0..2Height       Specify the heights of the rows in the source texture.
--     *texture             Specify the source texture to be used.
--      topLeftOffset       Specify an offset for the top left corner of the graphic.  This is
--                          useful when the visible box is slightly bigger than the _actual_ box
--                          (eg drop shadow, outer stroke effects).  In other words, you take the
--                          top left corner of the box, add this offset to it, and that gets you
--                          the top left corner of the graphic.
--      bottomRightOffset   Same as above, but for the bottom right corner.
--      middleMinimumSize   Specify a minimum size the middle can be before it starts to scale down
--                          the other sections as well.  Defaults to col1Width, row1Height if not
--                          specified.
--    
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/GUIObject.lua")

---@class GUIMenuNineBox : GUIObject
class "GUIMenuNineBox" (GUIObject)

local function ComputeFit(sourceMeasures, outMeasures, sizeToFill, middleMinimumSize)
    
    -- Calculate the size of the middle first.
    outMeasures[2] = math.max(sizeToFill - sourceMeasures[1] - sourceMeasures[3], middleMinimumSize)
    
    if outMeasures[2] == middleMinimumSize then
        -- The target size is so small that we're still too big even with the middle section
        -- at its minimum size.  Shrink all 3 sections proportionally to make it fit.
        local combinedSize = sourceMeasures[1] + middleMinimumSize + sourceMeasures[3]
        local scale = sizeToFill / combinedSize
        outMeasures[1] = sourceMeasures[1] * scale
        outMeasures[2] = middleMinimumSize * scale
        outMeasures[3] = sourceMeasures[3] * scale
    else
        outMeasures[1] = sourceMeasures[1]
        outMeasures[3] = sourceMeasures[3]
    end
    
end

local function UpdateCellScales(self)
    
    local newWidths = {}
    local newHeights = {}
    
    local widthToFill = self:GetSize().x
    local heightToFill = self:GetSize().y
    
    ComputeFit(self.widths, newWidths, widthToFill, self.middleMinimumSize.x)
    ComputeFit(self.heights, newHeights, heightToFill, self.middleMinimumSize.y)
    
    for i=1, 9 do
        local row = math.floor((i-1) / 3) + 1
        local col = ((i-1) - ((row-1) * 3)) + 1
        local item = self.cells[i]
        
        local scaleX = newWidths[col] / self.widths[col]
        local scaleY = newHeights[row] / self.heights[row]
        
        item:SetScale(scaleX, scaleY)
    end
    
end

local function OnBlendTechniqueChanged(self, technique)
    for i=1, 9 do
        local item = self.cells[i]
        item:SetBlendTechnique(technique)
    end
end

local function UpdateItemColors(self)
    
    self:GetRootItem():SetColor(0, 0, 0, 0) -- ensure this color stays 0.
    self:GetRootItem():SetOpacity(0)
    
    local finalColor = self:GetColor() * Color(1, 1, 1, self:GetOpacity())
    for i=1, 9 do
        local item = self.cells[i]
        item:SetColor(finalColor)
    end
end

function GUIMenuNineBox:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    -- Required parameters.
    RequireType({"number"}, params.col0Width, "params.col0Width", errorDepth)
    RequireType({"number"}, params.col1Width, "params.col1Width", errorDepth)
    RequireType({"number"}, params.col2Width, "params.col2Width", errorDepth)
    RequireType({"number"}, params.row0Height, "params.row0Height", errorDepth)
    RequireType({"number"}, params.row1Height, "params.row1Height", errorDepth)
    RequireType({"number"}, params.row2Height, "params.row2Height", errorDepth)
    
    RequireType({"string"}, params.texture, "params.texture", errorDepth)
    
    -- Optional parameters.
    RequireType({"nil", "Vector"}, params.topLeftOffset, "params.topLeftOffset", errorDepth)
    RequireType({"nil", "Vector"}, params.bottomRightOffset, "params.bottomRightOffset", errorDepth)
    RequireType({"nil", "Vector"}, params.middleMinimumSize, "params.middleMinimumSize", errorDepth)
    
    GUIObject.Initialize(self, params, errorDepth)
    
    self.topLeftOffset = params.topLeftOffset or Vector(0, 0, 0)
    self.bottomRightOffset = params.bottomRightOffset or Vector(0, 0, 0)
    self.middleMinimumSize = params.middleMinimumSize or Vector(params.col1Width, params.row1Height, 0)
    
    self.widths = { params.col0Width, params.col1Width, params.col2Width }
    self.heights = { params.row0Height, params.row1Height, params.row2Height }
    
    local actualWidths = {}
    local actualHeights = {}
    actualWidths[1] = self.widths[1] - self.topLeftOffset.x
    actualHeights[1] = self.heights[1] - self.topLeftOffset.y
    actualWidths[2] = self.widths[2]
    actualHeights[2] = self.heights[2]
    actualWidths[3] = self.widths[3] + self.bottomRightOffset.x
    actualHeights[3] = self.heights[3] + self.bottomRightOffset.y
    
    local pixelCoordsX = {}
    local pixelCoordsY = {}
    pixelCoordsX[1] = 0
    pixelCoordsY[1] = 0
    for i=1, 3 do
        pixelCoordsX[i+1] = pixelCoordsX[i] + actualWidths[i]
        pixelCoordsY[i+1] = pixelCoordsY[i] + actualHeights[i]
    end
    
    local hotSpotCoordsX = {}
    local hotSpotCoordsY = {}
    hotSpotCoordsX[1] = -self.topLeftOffset.x
    hotSpotCoordsY[1] = -self.topLeftOffset.y
    hotSpotCoordsX[2] = actualWidths[2] * 0.5
    hotSpotCoordsY[2] = actualHeights[2] * 0.5
    hotSpotCoordsX[3] = actualWidths[3] - self.bottomRightOffset.x
    hotSpotCoordsY[3] = actualHeights[3] - self.bottomRightOffset.y
    
    self.cells = {}
    for i=1, 9 do
        local row = math.floor((i-1) / 3) + 1
        local col = ((i-1) - ((row-1) * 3)) + 1
        
        local newCell = self:CreateGUIItem()
        newCell:SetTexture(params.texture)
        newCell:SetLayer(-1)
        
        local alignmentX = (col - 1) * 0.5
        local alignmentY = (row - 1) * 0.5
        newCell:SetAnchor(alignmentX, alignmentY)
        newCell:SetHotSpot(hotSpotCoordsX[col] / actualWidths[col], hotSpotCoordsY[row] / actualHeights[row])
        newCell:SetSize(actualWidths[col], actualHeights[row])
        newCell:SetTexturePixelCoordinates(pixelCoordsX[col], pixelCoordsY[row], pixelCoordsX[col+1], pixelCoordsY[row+1])
        
        self.cells[i] = newCell
    end
    UpdateCellScales(self)
    
    self:HookEvent(self, "OnSizeChanged", UpdateCellScales)
    
    self:HookEvent(self, "OnBlendTechniqueChanged", OnBlendTechniqueChanged)
    self:HookEvent(self, "OnOpacityChanged", UpdateItemColors)
    self:HookEvent(self, "OnColorChanged", UpdateItemColors)
    
end
