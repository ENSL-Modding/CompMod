-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/widgets/GUIMenuExpansionArrowWidget.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Small arrow that points up or down to indicate whether or not an item is "expanded" or not.
--
--  Parameters (* = required)
--      defaultColor    The color of the graphic when not highlighted or disabled.  Defaults to
--                      MenuStyle.kLightGrey.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/GUIObject.lua")
Script.Load("lua/menu2/MenuStyles.lua")
Script.Load("lua/GUI/wrappers/FXState.lua")

---@class GUIMenuExpansionArrowWidget : GUIObject
---@field public GetFXState function @From FXState wrapper
---@field public UpdateFXStateOverride function @From FXState wrapper
---@field public AddFXReceiver function @From FXState wrapper
---@field public RemoveFXReceiver function @From FXState wrapper
local baseClass = GUIObject
baseClass = GetFXStateWrappedClass(baseClass)

class "GUIMenuExpansionArrowWidget" (baseClass)

GUIMenuExpansionArrowWidget.kArrowTexture = PrecacheAsset("ui/newMenu/arrow.dds")
GUIMenuExpansionArrowWidget.kArrowDrawZoneSize = Vector(69, 32, 0)
GUIMenuExpansionArrowWidget.kArrowGap = 24
GUIMenuExpansionArrowWidget.kArrowMovement = 56

GUIMenuExpansionArrowWidget:AddClassProperty("ArrowPositionFactor", 0)
GUIMenuExpansionArrowWidget:AddCompositeClassProperty("ArrowColor", "upArrow", "Color")

local function UpdateArrowPositions(self, factor)
    self.downArrow:SetAnchor(0, factor)
    self.upArrow:SetAnchor(0, factor - 1)
end

local function UpdateArrowColor(self, color)
    self.downArrow:SetColor(color)
    self.upArrow:SetColor(color)
end

local function OnFXStateChanged(self, state, prevState)
    
    if self.OnFXStateChangedOverride and self:OnFXStateChangedOverride(state, prevState) then
        return
    end
    
    if state == "hover" then
        if prevState == "pressed" or prevState == "editing" then
            self:AnimateProperty("ArrowColor", MenuStyle.kHighlight, MenuAnimations.Fade)
        else
            PlayMenuSound("ButtonHover")
            DoColorFlashEffect(self, "ArrowColor")
        end
    elseif state == "pressed" then
        self:ClearPropertyAnimations("ArrowColor")
        self:SetArrowColor((MenuStyle.kHighlight + self.defaultColor) * 0.5)
    elseif state == "disabled" then
        self:AnimateProperty("ArrowColor", MenuStyle.kDarkGrey, MenuAnimations.Fade)
    elseif state == "default" then
        self:AnimateProperty("ArrowColor", self.defaultColor, MenuAnimations.Fade)
    end
end

local function OnArrowColorChanged(self, color)
    self.downArrow:SetColor(color)
end

function GUIMenuExpansionArrowWidget:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    PROFILE("GUIMenuExpansionArrowWidget:Initialize")
    
    RequireType({"Color", "nil"}, params.defaultColor, "params.defaultColor", errorDepth)
    
    baseClass.Initialize(self, params, errorDepth)
    
    self.downArrow = self:CreateGUIItem()
    self.downArrow:SetLayer(1)
    self.downArrow:SetTexture(self.kArrowTexture)
    self.downArrow:SetSizeFromTexture()
    
    self.upArrow = self:CreateGUIItem()
    self.upArrow:SetLayer(2)
    self.upArrow:SetTexture(self.kArrowTexture)
    self.upArrow:SetSizeFromTexture()
    self.upArrow:SetAnchor(0, 1)
    self.upArrow:SetTextureCoordinates(0, 0, 1, -1) -- flip vertically
    
    self:SetSize(self.downArrow:GetSize())
    self:SetCropMin(0, 0)
    self:SetCropMax(1, 1)
    
    self.defaultColor = params.defaultColor or MenuStyle.kDarkGrey
    self.downArrow:SetColor(self.defaultColor)
    self.upArrow:SetColor(self.defaultColor)
    
    UpdateArrowPositions(self, 0)
    self:HookEvent(self, "OnArrowPositionFactorChanged", UpdateArrowPositions)
    self:HookEvent(self, "OnArrowColorChanged", UpdateArrowColor)
    self:HookEvent(self, "OnFXStateChanged", OnFXStateChanged)
    self:HookEvent(self, "OnArrowColorChanged", OnArrowColorChanged)
    
end

function GUIMenuExpansionArrowWidget:PointUp()
    self:AnimateProperty("ArrowPositionFactor", 1, MenuAnimations.FlyIn)
end

function GUIMenuExpansionArrowWidget:PointDown()
    self:AnimateProperty("ArrowPositionFactor", 0, MenuAnimations.FlyIn)
end
