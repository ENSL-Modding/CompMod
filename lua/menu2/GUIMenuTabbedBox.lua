-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/GUIMenuTabbedBox.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--    
--    Box with an outer stroke effect, a gradient fill, a drop shadow, an inner-glow, and a tab
--    at the bottom for buttons to sit inside.
--    The Size of this widget includes the tab at the bottom, so be sure to include that in your
--    calculations.
--
--  Properties:
--      TabSize             -- The size of the tab at the bottom of the box.  This does not include
--                             the width of the diagonal edges.
--    
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/GUIObject.lua")

---@class GUIMenuTabbedBox : GUIObject
class "GUIMenuTabbedBox" (GUIObject)

GUIMenuTabbedBox:AddClassProperty("TabSize", Vector(64, 32, 0))

local kShader = PrecacheAsset("shaders/GUI/menu/tabbedBox.surface_shader")

local kDropShadowRadius = MenuStyle.kDropShadowRadius
local kDropShadowOffset = Vector(0, 7.5, 0)
local kDropShadowColor = MenuStyle.kDropShadowColor

local kStrokeWidth = MenuStyle.kStrokeWidth
local kStrokeColor = MenuStyle.kServerBrowserBackgroundStrokeColor

local kGlowRadius = MenuStyle.kInnerGlowRadius
local kGlowColor = MenuStyle.kServerBrowserBackgroundInnerGlowColor

local kHorizontalMargin = math.abs(kDropShadowOffset.x) + kDropShadowRadius
local kVerticalMargin = math.abs(kDropShadowOffset.y) + kDropShadowRadius

local function UpdateSurfaceSize(self)
    
    local paddedLocalSize = self:GetSize() + Vector(kHorizontalMargin, kVerticalMargin, 0) * 2
    local surfaceSize = paddedLocalSize * self.absScale
    self.box:SetFloat2Parameter("surfaceSize", surfaceSize)
    self.box:SetSize(paddedLocalSize)
    
end

local function UpdateBoxSize(self)
    self.box:SetFloat2Parameter("boxSize", self:GetSize() * self.absScale)
end

local function UpdateTabSize(self)
    self.box:SetFloat2Parameter("tabSize", self:GetTabSize() * self.absScale)
end

local function OnTabSizeChanged(self)
    UpdateTabSize(self)
end

local function OnSizeChanged(self)
    UpdateBoxSize(self)
    UpdateSurfaceSize(self)
end

local function OnAbsoluteScaleChanged(self, scale, prevScale)
    self.absScale = scale
    UpdateTabSize(self)
    UpdateBoxSize(self)
    UpdateSurfaceSize(self)
    self.box:SetFloat2Parameter("shadowOffset", self.absScale * kDropShadowOffset)
    self.box:SetFloatParameter("shadowRadius", self.absScale.x * kDropShadowRadius)
    self.box:SetFloatParameter("glowRadius", self.absScale.x * kGlowRadius)
end

function GUIMenuTabbedBox:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    GUIObject.Initialize(self, params, errorDepth)
    
    -- Create another item to use to display the actual graphics themselves.  This is necessary
    -- because the box's visuals extend outside its logical size (eg we don't count the outside
    -- stroke effect as part of the box, yet we still need an item big enough to display it).
    
    self.box = self:CreateGUIItem()
    self.box:SetShader(kShader)
    self.box:SetFloat4Parameter("strokeColor", kStrokeColor)
    self.box:SetFloat4Parameter("shadowColor", kDropShadowColor)
    self.box:SetFloat4Parameter("glowColor", kGlowColor)
    self.box:SetFloatParameter("strokeWidth", kStrokeWidth)
    self.box:AlignCenter()
    
    -- Need OnAbsoluteScaleChanged event to properly scale shader inputs.
    EnableOnAbsoluteScaleChangedEvent(self)
    self.absScale = self:GetAbsoluteScale()
    
    self:HookEvent(self, "OnAbsoluteScaleChanged", OnAbsoluteScaleChanged)
    self:HookEvent(self, "OnSizeChanged", OnSizeChanged)
    self:HookEvent(self, "OnTabSizeChanged", OnTabSizeChanged)
    
end
