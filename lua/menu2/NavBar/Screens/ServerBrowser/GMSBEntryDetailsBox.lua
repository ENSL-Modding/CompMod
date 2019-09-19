-- ======= Copyright (c) 2017, Unknown Worlds Entertainment, Inc. All rights reserved. ============
--
-- lua/menu2/NavBar/Screens/ServerBrowser/GMSBEntryDetailsBox.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--    
--    Box used for displaying details of a server entry.
--
--  Properties:
--      LeftWidth               -- The width of the tab spanning from the left edge of the box to
--                                 where the tab begins dropping.
--      StrokeColor             -- The color of the stroke effect applied to the outside of the
--                                 box.
--      StrokeWidth             -- The _screen space_ width of the stroke effect.  Screen space is
--                                 used instead of local space for aesthetic reasons.
--      TabHeight               -- The height (or maybe better, the depth) of the tab.
--    
-- ========= For more information, visit us at http://www.unknownworlds.com =======================

Script.Load("lua/GUI/GUIObject.lua")

---@class GMSBEntryDetailsBox : GUIObject
class "GMSBEntryDetailsBox" (GUIObject)

local kShader = PrecacheAsset("shaders/GUI/menu/serverEntryDetails.surface_shader")

GMSBEntryDetailsBox:AddClassProperty("LeftWidth", 100)
GMSBEntryDetailsBox:AddClassProperty("StrokeColor", Color(1, 1, 1, 1))
GMSBEntryDetailsBox:AddClassProperty("StrokeWidth", 0)
GMSBEntryDetailsBox:AddClassProperty("TabHeight", 40)

local function UpdateSize(self)
    
    local surfaceSize = self:GetSize() * self.absScale + Vector(self:GetStrokeWidth(true) + 1, self:GetStrokeWidth(true) + 1, 0) * 2
    self.box:SetFloat2Parameter("surfaceSize", surfaceSize)
    
    local localSize = Vector(0, 0, 0)
    if self.absScale.x ~= 0 then localSize.x = surfaceSize.x / self.absScale.x end
    if self.absScale.y ~= 0 then localSize.y = surfaceSize.y / self.absScale.y end
    
    self.box:SetSize(localSize)
    self.box:SetFloat2Parameter("boxSize", self:GetSize() * self.absScale)
    
end

local function UpdateLeftWidth(self)
    self.box:SetFloatParameter("highWidth", self:GetLeftWidth() * self.absScale.x)
end

local function UpdateStrokeColor(self)
    if self:GetStrokeWidth() <= 0 then
        self.box:SetFloat4Parameter("strokeColor", self:GetStrokeColor())
    else
        self.box:SetFloat4Parameter("strokeColor", Color(0, 0, 0, 0))
    end
end

local function OnStrokeColorChanged(self, strokeColor)
    UpdateStrokeColor(self)
end

local function OnStrokeWidthChanged(self, width)
    self.box:SetFloatParameter("strokeWidth", math.max(width, 0))
    UpdateSize(self)
    UpdateStrokeColor(self)
end

local function UpdateTabHeight(self)
    self.box:SetFloatParameter("tabHeight", self:GetTabHeight() * self.absScale.y)
end

local function OnAbsoluteScaleChanged(self, aScale, prevAScale)
    self.absScale = aScale
    UpdateSize(self)
    UpdateTabHeight(self)
    UpdateLeftWidth(self)
end

function GMSBEntryDetailsBox:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    GUIObject.Initialize(self, params, errorDepth)
    
    self.box = self:CreateGUIItem()
    self.box:SetShader(kShader)
    self.box:AlignCenter()
    
    EnableOnAbsoluteScaleChangedEvent(self)
    self.absScale = self:GetAbsoluteScale()
    
    self:HookEvent(self, "OnAbsoluteScaleChanged", OnAbsoluteScaleChanged)
    self:HookEvent(self, "OnLeftWidthChanged", UpdateLeftWidth)
    self:HookEvent(self, "OnStrokeColorChanged", OnStrokeColorChanged)
    self:HookEvent(self, "OnStrokeWidthChanged", OnStrokeWidthChanged)
    self:HookEvent(self, "OnTabHeightChanged", UpdateTabHeight)
    self:HookEvent(self, "OnSizeChanged", UpdateSize)
    
    self.box:SetFloat4Parameter("gradColor1", MenuStyle.kServerBrowserEntryDetailsGradientColor1)
    self.box:SetFloat4Parameter("gradColor2", MenuStyle.kServerBrowserEntryDetailsGradientColor2)
    
    self:SetStrokeWidth(MenuStyle.kStrokeWidth)
    self:SetStrokeColor(MenuStyle.kServerBrowserEntryDetailsBoxStrokeColor)
    
end
