-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/menu2/widgets/GUIMenuSatBrightPicker.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    A widget that lets the user pick a saturation and brightness value (photoshop-like) in a 2d
--    picker.
--
--  Params:
--      saturation
--      brightness
--      hue
--
--  Properties:
--      Saturation          The saturation value.  Between 0 and 1.
--      Brightness          The brightness value.  Between 0 and 1.
--      Hue                 The hue value to use to produce a complete color.
--
--  Events:
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/GUI/GUIObject.lua")
Script.Load("lua/GUI/GUIUtils.lua")

local baseClass = GUIObject
class "GUIMenuSatBrightPicker" (baseClass)

local kSatValueTexture = PrecacheAsset("ui/newMenu/saturationValueRange.dds")
local kCircleTexture = PrecacheAsset("ui/newMenu/circle.dds")

local kDefaultSize = Vector(668, 668, 0)
local kCircleScale = 0.5

GUIMenuSatBrightPicker:AddClassProperty("Saturation", 1.0)
GUIMenuSatBrightPicker:AddClassProperty("Brightness", 1.0)
GUIMenuSatBrightPicker:AddClassProperty("Hue", 1.0)

local function UpdateCirclePos(self)
    local sat = Clamp(self:GetSaturation(), 0, 1)
    local bright = Clamp(self:GetBrightness(), 0, 1)
    self.circle:SetAnchor(sat, 1-bright)
end

local function UpdateHue(self)
    local hue = self:GetHue()
    self.hueFill:SetColor(HSVToRGB(hue, 1, 1))
end

function GUIMenuSatBrightPicker:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    PushParamChange(params, "size", params.size or kDefaultSize)
    baseClass.Initialize(self, params, errorDepth)
    PopParamChange(params, "size")
    
    self:SetColor(1, 1, 1, 1)
    self:SetTexture(kSatValueTexture)
    
    self.circle = CreateGUIObject("circle", GUIObject, self)
    self.circle:SetLayer(1)
    self.circle:SetTexture(kCircleTexture)
    self.circle:SetSizeFromTexture()
    self.circle:SetColor(1, 1, 1, 1)
    self.circle:SetHotSpot(0.5, 0.5)
    self.circle:SetScale(kCircleScale, kCircleScale)
    
    self.hueFill = CreateGUIObject("hueFill", GUIObject, self)
    self.hueFill:SetLayer(-1)
    self.hueFill:HookEvent(self, "OnSizeChanged", self.hueFill.SetSize)
    self.hueFill:SetSize(self:GetSize())
    
    self:HookEvent(self, "OnSaturationChanged", UpdateCirclePos)
    self:HookEvent(self, "OnBrightnessChanged", UpdateCirclePos)
    UpdateCirclePos(self)
    
    self:HookEvent(self, "OnHueChanged", UpdateHue)
    UpdateHue(self)
    
    self:ListenForCursorInteractions()
    
end

local function SharedMouseUpdate(self)
    
    local screenPos = self:GetScreenPosition()
    local absSize = self:GetAbsoluteSize()
    local globalMousePos = GetGlobalEventDispatcher():GetMousePosition()
    
    local sat = globalMousePos.x - screenPos.x
    local bright = globalMousePos.y - screenPos.y
    
    if absSize.x > 0 then    sat =    sat / absSize.x end
    if absSize.y > 0 then bright = bright / absSize.y end
    
    sat = Clamp(sat, 0, 1)
    bright = Clamp(1-bright, 0, 1)
    
    self:SetSaturation(sat)
    self:SetBrightness(bright)

end

function GUIMenuSatBrightPicker:OnMouseClick()
    SharedMouseUpdate(self)
end

function GUIMenuSatBrightPicker:OnMouseDrag()
    SharedMouseUpdate(self)
end