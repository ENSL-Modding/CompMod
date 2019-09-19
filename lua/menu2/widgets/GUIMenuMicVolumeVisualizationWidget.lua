-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/widgets/GUIMenuMicVolumeVisualizationWidget.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--    
--    Widget that displays the volume of the player's microphone, so they can more easily tune in
--    their gain values, and test if their mic is working.
--@class GUIMenuMicVolumeVisualizationWidget : GUIObject
--
--  Properties:
--      Label           -- The text displayed on this widget.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/GUIObject.lua")
Script.Load("lua/menu2/GUIMenuBasicBox.lua")
Script.Load("lua/menu2/MenuStyles.lua")

---@class GUIMenuMicVolumeVisualizationWidget : GUIObject
class "GUIMenuMicVolumeVisualizationWidget" (GUIObject)

GUIMenuMicVolumeVisualizationWidget:AddClassProperty("_Intensity", 0)
GUIMenuMicVolumeVisualizationWidget:AddCompositeClassProperty("Label", "label", "Text")

local kMeterShader = PrecacheAsset("shaders/GUI/menu/outlinedShadowedBox.surface_shader")
local kLerpColor1 = HexToColor("d22e2e") -- red
local kLerpColor2 = HexToColor("d0d22e") -- yellow
local kLerpColor3 = HexToColor("33d22e") -- green
local kBackgroundInnerShadowRadius = 20
local kStrokeWidth = 2

local kVolumePeakBarTexture = PrecacheAsset("ui/newMenu/volumePeakBar.dds")

local kTooLoudThreshold = 0.95
local kTooQuietThreshold = 0.5

local kLabelLeftEdge = 18

local function UpdateBarSize(self)
    
    local width = self.volume * self:GetSize().x
    local size = Vector(width, self:GetSize().y, 0)
    self.bar:SetSize(size)
    
    local onScreenSize = size * self.absoluteScale
    self.bar:SetFloat2Parameter("boxSize", onScreenSize)
    local surfaceSize = onScreenSize + Vector(kStrokeWidth + 1, kStrokeWidth + 1, 0) * 2
    self.bar:SetFloat2Parameter("surfaceSize", surfaceSize)
    
end

local function OnAbsoluteScaleChanged(self, scale, prevScale)
    
    -- Update the radius of the inner shadow, and its c-squared value.
    local rScaled = kBackgroundInnerShadowRadius * scale
    local cSqr = Vector(CalculateCSquaredForGaussianBlur(rScaled.x), CalculateCSquaredForGaussianBlur(rScaled.y), 0)
    self.bar:SetFloat2Parameter("innerShadowRadius", rScaled)
    self.bar:SetFloat2Parameter("innerShadowCSqr", cSqr)
    
    self.absoluteScale = scale
    UpdateBarSize(self)
    
end

local function OnRenderingStarted(self)
    self:SetUpdates(true)
end

local function OnRenderingStopped(self)
    self:SetUpdates(false)
end

local function GetColorForVolume(value)
    if value >= kTooLoudThreshold or value <= kTooQuietThreshold then
        return kLerpColor1
    else
        local t = (value - kTooQuietThreshold) / (kTooLoudThreshold - kTooQuietThreshold)
        local i1 = Clamp(1.0 - 2 * t, 0, 1)
        local i2 = Clamp(1-math.abs(2*t - 1), 0, 1)
        local i3 = Clamp(2*t - 1, 0, 1)
        return kLerpColor1 * i1 + kLerpColor2 * i2 + kLerpColor3 * i3
    end
end

local kLowPassFactor1 = 1.0
local kLowPassFactor2 = 0.25
local kPeakFallSpeed = 0.25
function GUIMenuMicVolumeVisualizationWidget:OnUpdate(deltaTime, now)
    
    local prevValue = self.volume
    self.volume = Clamp(Client.GetRecordingVolume(), 0, 1)
    
    local volumeLowPass1 = self.volume * kLowPassFactor1 + prevValue * (1.0 - kLowPassFactor1)
    local volumeLowPass2 = self.volume * kLowPassFactor2 + prevValue * (1.0 - kLowPassFactor2)
    self.volume = math.max(volumeLowPass2, volumeLowPass1)
    
    local color = GetColorForVolume(self.volume)
    
    self.bar:SetColor(color)
    self.bar:SetFloat4Parameter("strokeColor", color)
    UpdateBarSize(self)
    
    -- Update the peak bar
    self.peakVolume = math.max(self.peakVolume - deltaTime * kPeakFallSpeed, self.volume, 0)
    self.peakBar:SetHotSpot(self.peakVolume, 0.5)
    self.peakBar:SetAnchor(self.peakVolume, 0.5)
    self.peakBar:SetColor(GetColorForVolume(self.peakVolume))
    
end

function GUIMenuMicVolumeVisualizationWidget:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    GUIObject.Initialize(self, params, errorDepth)
    
    self:SetSize(MenuStyle.kDefaultWidgetSize)
    
    self.volume = 0
    self.peakVolume = 0
    
    self.back = CreateGUIObject("back", GUIMenuBasicBox, self)
    self.back:SetLayer(-1)
    self.back:SetSize(MenuStyle.kDefaultWidgetSize)
    
    self.bar = self:CreateGUIItem()
    self.bar:SetLayer(1)
    self.bar:SetShader(kMeterShader)
    self.bar:AlignLeft()
    self.bar:SetFloatParameter("strokeWidth", kStrokeWidth)
    self.bar:SetFloat2Parameter("cornerOffset", Vector(kStrokeWidth + 1, kStrokeWidth + 1, 0))
    
    self.peakBar = self:CreateGUIItem()
    self.peakBar:SetSize(self:GetSize().y * 0.25, self:GetSize().y)
    self.peakBar:AlignLeft()
    self.peakBar:SetColor(1, 0, 0, 1)
    self.peakBar:SetTexture(kVolumePeakBarTexture)
    
    self.label = CreateGUIObject("label", GUIText, self)
    self.label:AlignLeft()
    self.label:SetPosition(kLabelLeftEdge, 0)
    self.label:SetFont(MenuStyle.kOptionFont)
    self.label:SetColor(MenuStyle.kLightGrey)
    self.label:SetDropShadowEnabled(true)
    self.label:SetText("LABEL")
    self.label:SetLayer(2)
    
    -- The inner-shadow effect in the shader depends on the absolute scale of the object.  To
    -- ensure we are notified of changes to the scale of not only this object, but any ancestor,
    -- we have to enable a special "OnAbsoluteScaleChanged" event -- too expensive to be enabled by
    -- default.
    EnableOnAbsoluteScaleChangedEvent(self)
    self:HookEvent(self, "OnAbsoluteScaleChanged", OnAbsoluteScaleChanged)
    OnAbsoluteScaleChanged(self, self:GetAbsoluteScale(), Vector(1, 1, 1))
    
    self:TrackRenderStatus(self.back:GetVisibleItem())
    self:HookEvent(self, "OnRenderingStarted", OnRenderingStarted)
    self:HookEvent(self, "OnRenderingStopped", OnRenderingStopped)
    
end


