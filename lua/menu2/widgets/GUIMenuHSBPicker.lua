-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/menu2/widgets/GUIMenuHSBPicker.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    A widget that lets the user pick a color using the intuitive HSB model.
--
--  Params:
--      saturation
--      brightness
--      hue
--
--  Properties:
--      Saturation          The saturation value.  Between 0 and 1.
--      Brightness          The brightness value.  Between 0 and 1.
--      Hue                 The hue value.  Between 0 and 1.
--
--  Events:
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/menu2/widgets/GUIMenuSatBrightPicker.lua")
Script.Load("lua/menu2/widgets/GUIMenuHuePickerWidget.lua")

---@class GUIMenuHSBPicker : GUIObject
local baseClass = GUIObject
class "GUIMenuHSBPicker" (baseClass)

local kDefaultSize = Vector(822, 668, 0)
local kSpacing = 16
local kHuePickerWidth = 138
local kMinColorPickerWidth = 100

GUIMenuHSBPicker:AddCompositeClassProperty("Hue", "huePicker", "Value")
GUIMenuHSBPicker:AddCompositeClassProperty("Saturation", "satBrightPicker")
GUIMenuHSBPicker:AddCompositeClassProperty("Brightness", "satBrightPicker")

local function UpdateLayout(self)
    
    local size = self:GetSize()
    
    self.huePicker:SetWidth(kHuePickerWidth)
    self.huePicker:SetHeight(size.y)
    
    local leftoverWidth = size.x - kSpacing - self.huePicker:GetSize().x
    self.satBrightPicker:SetWidth(math.max(kMinColorPickerWidth, leftoverWidth))
    self.satBrightPicker:SetHeight(size.y)
    
end

function GUIMenuHSBPicker:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    PushParamChange(params, "size", params.size or kDefaultSize)
    baseClass.Initialize(self, params, errorDepth)
    PopParamChange(params, "size")
    
    self.huePicker = CreateGUIObject("huePicker", GUIMenuHuePickerWidget, self)
    self.huePicker:AlignTopRight()
    
    self.satBrightPicker = CreateGUIObject("satBrightPicker", GUIMenuSatBrightPicker, self)
    self.satBrightPicker:HookEvent(self, "OnHueChanged", self.satBrightPicker.SetHue)
    
    self:HookEvent(self, "OnSizeChanged", UpdateLayout)
    
end
