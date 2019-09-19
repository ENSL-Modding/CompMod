-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/GUIMenuDropShadow.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--    
--    A large, soft, box-shaped drop shadow effect.  A specialization of GUIMenuNineBox.
--    
--  Parameters (* = required)
--      color       Shadow color and opacity.  Default is (0, 0, 0, 0.70)
--      offset      Shadow offset.  Default is (-10, -17.32, 0)
--  
--  Properties
--      Offset      Shadow offset.
--      (Use color to set shadow color).
--  
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/menu2/GUIMenuNineBox.lua")

---@class GUIMenuDropShadow : GUIMenuNineBox
class "GUIMenuDropShadow" (GUIMenuNineBox)

local kDefaultColor = Color(0, 0, 0, 0.70)
local kDefaultOffset = Vector(10, 17.32, 0) -- 120 degree angle, 20 distance

GUIMenuDropShadow:AddClassProperty("Offset", kDefaultOffset)

local kParams =
{
    texture = PrecacheAsset("ui/newMenu/nine_box_shadow.dds"),
    
    col0Width = 19,
    col1Width = 2,
    col2Width = 19,
    
    row0Height = 19,
    row1Height = 2,
    row2Height = 19,
    
    topLeftOffset = Vector(-19, -19, 0),
    bottomRightOffset = Vector(19, 19, 0),
    middleMinimumSize = Vector(2, 2, 0),
}
local kParamKeys = {}
for key, __ in pairs(kParams) do
    table.insert(kParamKeys, key)
end

local function UpdateColor(self)
    local color = self:GetColor()
    for i=1, #self.cells do
        self.cells[i]:SetColor(color)
    end
end

local function UpdateOffset(self)
    local offset = self:GetOffset()
    for i=1, #self.cells do
        self.cells[i]:SetPosition(offset)
    end
end

function GUIMenuDropShadow:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    RequireType({"Color", "nil"}, params.color, "params.color", errorDepth)
    RequireType({"Vector", "nil"}, params.offset, "params.offset", errorDepth)
    
    -- Save potentially conflicting values set in params, and set to our own.
    local prevParamValues = {}
    for i=1, #kParamKeys do
        local key = kParamKeys[i]
        prevParamValues[key] = params[key]
        params[key] = kParams[key]
    end
    
    GUIMenuNineBox.Initialize(self, params, errorDepth)
    
    -- Restore old values.
    for i=1, #kParamKeys do
        local key = kParamKeys[i]
        params[key] = prevParamValues[key]
    end
    
    -- Set this object to be a stencil for the drop shadow (so that the drop shadow doens't render
    -- underneath the box.  A bit strange, but that's how photoshop does it.
    self:SetIsStencil(true)
    self:SetClearsStencilBuffer(true) -- start fresh when this object renders.
    
    self:SetColor(kDefaultColor)
    
    for i=1, #self.cells do
        self.cells[i]:SetStencilFunc(GUIItem.Equal) -- only render outside the parent item.
        self.cells[i]:SetLayer(2) -- render after the parent item.
    end
    
    if params.color then
        self:SetColor(params.color)
    end
    
    if params.offset then
        self:SetOffset(params.offset)
    end
    
    -- Send color change to cell sub-objects.
    self:HookEvent(self, "OnColorChanged", UpdateColor)
    
    -- Update cell object positions with offset.
    self:HookEvent(self, "OnOffsetChanged", UpdateOffset)
    
    UpdateColor(self)
    UpdateOffset(self)
    
end
