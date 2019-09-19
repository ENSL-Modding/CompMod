-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. ============
--
-- lua/menu2/NavBar/Screens/ServerBrowser/GMSBEntryGlowyBackground.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    The glowing background of a GMSBEntry.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =======================

---@class GMSBEntryGlowyBackground : GUIObject
class "GMSBEntryGlowyBackground" (GUIObject)

local kShader = PrecacheAsset("shaders/GUI/menu/serverEntrySelected.surface_shader")
local kStrokeWidth = 2

local function UpdateSize(self)
    
    local surfaceSize = self:GetSize() * self.absScale + Vector(kStrokeWidth + 1, kStrokeWidth + 1, 0) * 2
    self.box:SetFloat2Parameter("surfaceSize", surfaceSize)
    
    local localSize = Vector(0, 0, 0)
    if self.absScale.x ~= 0 then localSize.x = surfaceSize.x / self.absScale.x end
    if self.absScale.y ~= 0 then localSize.y = surfaceSize.y / self.absScale.y end
    
    self.box:SetSize(localSize)
    self.box:SetFloat2Parameter("boxSize", self:GetSize() * self.absScale)
    
end

local function OnAbsoluteScaleChanged(self, aScale, prevAScale)
    self.absScale = aScale
    UpdateSize(self)
end

function GMSBEntryGlowyBackground:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    GUIObject.Initialize(self, params, errorDepth)
    
    self.box = self:CreateGUIItem()
    self.box:SetShader(kShader)
    self.box:AlignCenter()
    
    self.box:SetFloat4Parameter("strokeColor", MenuStyle.kServerEntryHighlightStrokeColor)
    self.box:SetFloatParameter("strokeWidth", kStrokeWidth)
    self.box:SetFloatParameter("fillOpacity", 0.51)
    self.box:SetFloatParameter("opacity", 1.0)
    self.box:SetFloat4Parameter("gradColor1", MenuStyle.kServerEntryHighlightGradientColor1)
    self.box:SetFloat4Parameter("gradColor2", MenuStyle.kServerEntryHighlightGradientColor2)
    
    EnableOnAbsoluteScaleChangedEvent(self)
    self.absScale = self:GetAbsoluteScale()
    
    self:HookEvent(self, "OnAbsoluteScaleChanged", OnAbsoluteScaleChanged)
    self:HookEvent(self, "OnSizeChanged", UpdateSize)
    
end
