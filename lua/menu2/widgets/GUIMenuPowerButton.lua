-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/menu2/widgets/GUIMenuPowerButton.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Menu-themed button in the shape of a power button.
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/GUI/widgets/GUIButton.lua")
Script.Load("lua/menu2/MenuUtilities.lua")
Script.Load("lua/menu2/MenuStyles.lua")

Script.Load("lua/GUI/wrappers/FXState.lua")

---@class GUIMenuPowerButton : GUIButton
---@field public GetFXState function @From FXState wrapper
---@field public UpdateFXStateOverride function @From FXState wrapper
---@field public AddFXReceiver function @From FXState wrapper
---@field public RemoveFXReceiver function @From FXState wrapper
local baseClass = GUIButton
baseClass = GetFXStateWrappedClass(baseClass)
class "GUIMenuPowerButton" (baseClass)

local kShadowTexture = PrecacheAsset("ui/newMenu/soft_shadow.dds")
local kShadowOpacity = 0.5

GUIMenuPowerButton.kTextureRegular = PrecacheAsset("ui/newMenu/powerOff.dds")
GUIMenuPowerButton.kTextureHover   = PrecacheAsset("ui/newMenu/powerOffOver.dds")
GUIMenuPowerButton.kOffset = Vector(-53, 28, 0)

GUIMenuPowerButton.kFlashShader = PrecacheAsset("shaders/GUI/menu/flash.surface_shader")

GUIMenuPowerButton.kShadowScale = Vector(5, 5, 1)

GUIMenuPowerButton:AddClassProperty("HoverGraphicFlash", 0.0)
GUIMenuPowerButton:AddClassProperty("HoverGraphicOpacity", 0.0)

local function OnFXStateChanged(self, state, prevState)
    
    if state == "default" then
        self:AnimateProperty("HoverGraphicOpacity", 0, MenuAnimations.Fade)
    elseif state == "pressed" then
        self:SetHoverGraphicOpacity(0.5)
    elseif state == "hover" then
        if prevState == "pressed" then
            self:AnimateProperty("HoverGraphicOpacity", 1, MenuAnimations.Fade)
        else
            self:SetHoverGraphicFlash(1)
            self:AnimateProperty("HoverGraphicFlash", 0, MenuAnimations.FlashColor)
            self:ClearPropertyAnimations("HoverGraphicOpacity")
            self:SetHoverGraphicOpacity(1)
            PlayMenuSound("ButtonHover")
        end
    end

end

local function UpdateHoverGraphicOpacity(self, value)
    self.hoverGraphic:SetOpacity(value * self:GetOpacity())
end

local function UpdateHoverGraphicFlash(self, value)
    self.hoverGraphic:SetFloatParameter("multAmount", 2*value + 1)
    self.hoverGraphic:SetFloatParameter("screenAmount", 2*value)
end

local function OnPressed(self)
    PlayMenuSound("ButtonClick")
end

local function UpdateOpacity(self)
    self.normalGraphic:SetColor(1, 1, 1, self:GetOpacity())
    UpdateHoverGraphicOpacity(self, self:GetHoverGraphicOpacity())
end

function GUIMenuPowerButton:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    baseClass.Initialize(self, params, errorDepth)
    
    self.normalGraphic = self:CreateGUIItem()
    self.normalGraphic:SetLayer(1)
    self.normalGraphic:SetTexture(self.kTextureRegular)
    self.normalGraphic:SetSizeFromTexture()
    self.normalGraphic:AlignCenter()
    
    self.hoverGraphic = self:CreateGUIItem()
    self.hoverGraphic:SetLayer(2)
    self.hoverGraphic:SetTexture(self.kTextureHover)
    self.hoverGraphic:SetSizeFromTexture()
    self.hoverGraphic:SetColor(Color(1, 1, 1, 0))
    self.hoverGraphic:AlignCenter()
    self.hoverGraphic:SetShader(self.kFlashShader)
    
    self.shadow = self:CreateGUIItem()
    self.shadow:AlignCenter()
    self.shadow:SetLayer(-1)
    self.shadow:SetTexture(kShadowTexture)
    self.shadow:SetSizeFromTexture()
    self.shadow:SetScale(self.kShadowScale)
    self.shadow:SetColor(1, 1, 1, 1)
    self.shadow:SetOpacity(kShadowOpacity)
    
    self:SetSize(self.normalGraphic:GetTextureSize())
    
    self:HookEvent(self, "OnFXStateChanged", OnFXStateChanged)
    self:HookEvent(self, "OnHoverGraphicOpacityChanged", UpdateHoverGraphicOpacity)
    self:HookEvent(self, "OnHoverGraphicFlashChanged", UpdateHoverGraphicFlash)
    self:HookEvent(self, "OnPressed", OnPressed)
    self:HookEvent(self, "OnOpacityChanged", UpdateOpacity)

end

