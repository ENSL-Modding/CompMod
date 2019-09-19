-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/menu2/widgets/GUIMenuHuePickerWidget.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    A widget that lets the user pick a hue value.  Could be useful on its own, but usually as part
--    of a color picker.
--
--  Params:
--      value
--
--  Properties:
--      Value               The hue value of this widget, value between 0 and 1.
--
--  Events:
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/GUI/GUIObject.lua")
Script.Load("lua/menu2/MenuStyles.lua")

local baseClass = GUIObject
class "GUIMenuHuePickerWidget" (baseClass)

local kHueTexture = PrecacheAsset("ui/newMenu/hueRange.dds")
local kArrowTexture = PrecacheAsset("ui/newMenu/scrollbarArrow.dds")

local kSpacing = 16 -- spacing between hue range and arrow.
local kDefaultSize = Vector(138, 668, 0)
local kHueMinWidth = 32

GUIMenuHuePickerWidget:AddClassProperty("Value", 0.0)

local function UpdateLayout(self)
    
    local size = self:GetSize()
    local arrowSize = self.arrow:GetSize()
    
    local hueRangeSize = size.x - arrowSize.x - kSpacing
    
    self.hueRange:SetWidth(math.max(kHueMinWidth, hueRangeSize))
    self.hueRange:SetHeight(size.y)
    
end

local function UpdateArrowPosition(self)
    self.arrow:SetAnchor(1, 1.0 - self:GetValue())
end

function GUIMenuHuePickerWidget:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    PushParamChange(params, "size", params.size or kDefaultSize)
    baseClass.Initialize(self, params, errorDepth)
    PopParamChange(params, "size")
    
    self.hueRange = CreateGUIObject("hueRange", GUIObject, self)
    self.hueRange:SetTexture(kHueTexture)
    self.hueRange:SetColor(1, 1, 1, 1)
    
    self.arrow = CreateGUIObject("arrow", GUIObject, self.hueRange)
    self.arrow:SetColor(MenuStyle.kOptionHeadingColor)
    self.arrow:SetTexture(kArrowTexture)
    self.arrow:SetSizeFromTexture()
    self.arrow:SetSize(self.arrow:GetSize().y, self.arrow:GetSize().x) -- transpose for rotation.
    self.arrow:SetHotSpot(0, 0.5)
    self.arrow:SetRotationOffset(0.5, 0.5)
    self.arrow:SetX(kSpacing)
    self.arrow:SetAngle(math.pi * 0.5)
    self:HookEvent(self, "OnValueChanged", UpdateArrowPosition)
    UpdateArrowPosition(self)
    
    self:ListenForCursorInteractions()
    
    self:HookEvent(self, "OnSizeChanged", UpdateLayout)
    UpdateLayout(self)
    
end

local function SharedMouseUpdate(self)
    
    local screenPos = self:GetScreenPosition()
    local absSize = self:GetAbsoluteSize()
    local globalMousePos = GetGlobalEventDispatcher():GetMousePosition()
    local value = globalMousePos.y - screenPos.y
    if absSize.y > 0 then
        value = value / absSize.y
    end
    value = Clamp(1.0 - value, 0, 1)
    self:SetValue(value)

end

function GUIMenuHuePickerWidget:OnMouseClick()
    SharedMouseUpdate(self)
end

function GUIMenuHuePickerWidget:OnMouseDrag()
    SharedMouseUpdate(self)
end

