-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/widgets/GUIMenuCheckboxWidget.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--    
--    GUICheckboxWidget that is themed appropriately for the menu.  No label.
--
--  Properties:
--      Value               State of the checkbox, expressed as a boolean.
--  
--  Events:
--      OnPressed           Fires whenever the object is clicked and released on, while enabled.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/widgets/GUICheckboxWidget.lua")
Script.Load("lua/menu2/MenuStyles.lua")

---@class GUIMenuCheckboxWidget : GUICheckboxWidget
---@field public GetFXState function @From FXState wrapper
---@field public UpdateFXStateOverride function @From FXState wrapper
---@field public AddFXReceiver function @From FXState wrapper
---@field public RemoveFXReceiver function @From FXState wrapper
local baseClass = GUICheckboxWidget
baseClass = GetFXStateWrappedClass(baseClass)
class "GUIMenuCheckboxWidget" (baseClass)

local kGlowTexture = PrecacheAsset("ui/newMenu/checkboxGlow.dds")

local kBackgroundShader = PrecacheAsset("shaders/GUI/menu/outlinedShadowedBox.surface_shader")
local kBackgroundStrokeWidth = 2
local kBackgroundHoverStrokeWidth = 4
local kBackgroundInnerShadowRadius = 20
local kBackgroundColor = HexToColor("101314")

GUIMenuCheckboxWidget.kPlainBoxSize = Vector(48, 48, 0)
local kSize = GUIMenuCheckboxWidget.kPlainBoxSize

GUIMenuCheckboxWidget:AddClassProperty("_GlowFlash", 0)
GUIMenuCheckboxWidget:AddClassProperty("_GlowOpacity", 0)

GUIMenuCheckboxWidget:AddClassProperty("_StrokeWidth", 1)
GUIMenuCheckboxWidget:AddClassProperty("_StrokeColor", Color(0, 0, 0, 0))

local function UpdateGlowOpacity(self, opacity)
    self.glowGraphic:SetOpacity(opacity)
end

local function UpdateStrokeColor(self, color)
    self.backGraphic:SetFloat4Parameter("strokeColor", color)
end

local function UpdateStrokeWidth(self, width)
    self.backGraphic:SetFloatParameter("strokeWidth", width)
end

local function UpdateInnerShadowRadius(self, scale, prevScale)
    local rScaled = kBackgroundInnerShadowRadius * scale
    local cSqr = Vector(CalculateCSquaredForGaussianBlur(rScaled.x), CalculateCSquaredForGaussianBlur(rScaled.y), 0)
    self.backGraphic:SetFloat2Parameter("innerShadowRadius", rScaled)
    self.backGraphic:SetFloat2Parameter("innerShadowCSqr", cSqr)
end

local function OnFXStateChanged(self, state, prevState)
    if state == "default" then
        self:AnimateProperty("_StrokeWidth", kBackgroundStrokeWidth, MenuAnimations.Fade)
        self:AnimateProperty("_StrokeColor", MenuStyle.kHighlight, MenuAnimations.Fade)
    elseif state == "pressed" then
        self:ClearPropertyAnimations("_StrokeColor")
        self:Set_StrokeColor((MenuStyle.kHighlight + MenuStyle.kLightGrey) * 0.5)
    elseif state == "hover" then
        if prevState == "pressed" then
            self:AnimateProperty("_StrokeWidth", kBackgroundHoverStrokeWidth, MenuAnimations.FlyIn)
            self:ClearPropertyAnimations("_StrokeColor")
            self:Set_StrokeColor(MenuStyle.kHighlight)
        else
            PlayMenuSound("ButtonHover")
            self:AnimateProperty("_StrokeWidth", kBackgroundHoverStrokeWidth, MenuAnimations.FlyIn)
            DoColorFlashEffect(self, "_StrokeColor")
        end
    elseif state == "disabled" then
        self:AnimateProperty("_StrokeColor", MenuStyle.kDarkGrey, MenuAnimations.Fade)
    end
end

local function OnValueChanged(self, value)
    
    if value then
        self:ClearPropertyAnimations("_GlowOpacity")
        self:Set_GlowOpacity(1)
    else
        self:AnimateProperty("_GlowOpacity", 0, MenuAnimations.Fade)
    end

end

local function OnPressed(self)
    
    local checked = self:GetValue()
    if checked then
        PlayMenuSound("BeginChoice")
        DoFlashEffect(self, "_GlowFlash")
    else
        PlayMenuSound("AcceptChoice")
    end
    
end

function GUIMenuCheckboxWidget:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    baseClass.Initialize(self, params, errorDepth)
    
    self:SetSize(kSize)
    
    self.glowGraphic = self:CreateGUIItem()
    self.glowGraphic:SetLayer(1)
    self.glowGraphic:AlignCenter()
    self.glowGraphic:SetTexture(kGlowTexture)
    self.glowGraphic:SetSizeFromTexture()
    self.glowGraphic:SetOpacity(0)
    
    self.backGraphic = self:CreateGUIItem()
    self.backGraphic:SetLayer(-1)
    self.backGraphic:SetShader(kBackgroundShader)
    local surfaceSize = kSize + Vector(kBackgroundHoverStrokeWidth, kBackgroundHoverStrokeWidth, 0) * 2 + Vector(2, 2, 0)
    self.backGraphic:SetFloat2Parameter("surfaceSize", surfaceSize)
    self.backGraphic:SetSize(surfaceSize)
    local offset = kBackgroundHoverStrokeWidth + 1
    offset = Vector(offset, offset, 0)
    self.backGraphic:AlignCenter()
    self.backGraphic:SetFloat2Parameter("cornerOffset", offset)
    self.backGraphic:SetFloat2Parameter("boxSize", kSize)
    self.backGraphic:SetColor(kBackgroundColor)
    
    -- The inner-shadow effect in the shader depends on the absolute scale of the object.  To
    -- ensure we are notified of changes to the scale of not only this object, but any ancestor,
    -- we have to enable a special "OnAbsoluteScaleChanged" event -- too expensive to be enabled by
    -- default.
    EnableOnAbsoluteScaleChangedEvent(self)
    
    self:HookEvent(self, "OnAbsoluteScaleChanged", UpdateInnerShadowRadius)
    UpdateInnerShadowRadius(self, self:GetAbsoluteScale(), Vector(1, 1, 1))
    self:HookEvent(self, "On_StrokeColorChanged", UpdateStrokeColor)
    self:HookEvent(self, "On_StrokeWidthChanged", UpdateStrokeWidth)
    
    self:Set_StrokeColor(MenuStyle.kHighlight)
    self:Set_StrokeWidth(kBackgroundStrokeWidth)
    
    SetupFlashEffect(self, "_GlowFlash", self.glowGraphic)
    self:HookEvent(self, "On_GlowOpacityChanged", UpdateGlowOpacity)
    
    self:HookEvent(self, "OnValueChanged", OnValueChanged)
    self:HookEvent(self, "OnFXStateChanged", OnFXStateChanged)
    
    self:HookEvent(self, "OnPressed", OnPressed)
    
end
