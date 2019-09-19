-- ======= Copyright (c) 2018, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/widgets/GUIMenuCustomizeTabButton.lua
--
--    Created by:   Brock Gillespie (brock@naturalselection2.com)
--
--    Menu-theme applied to button.
--
--  Parameters (* = required)
--      label
--
--  Properties:
--      Label       Text displayed inside the button.  Alias for Text.
--
--  Events:
--      OnPressed - whenever the button is clicked and released.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/widgets/GUIButton.lua")
Script.Load("lua/menu2/MenuUtilities.lua")
Script.Load("lua/menu2/GUIMenuCoolShadowBox.lua")

Script.Load("lua/GUI/wrappers/FXState.lua")

---@class GUIMenuCustomizeTabButton : GUIButton
---@field public GetFXState function @From FXState wrapper
---@field public UpdateFXStateOverride function @From FXState wrapper
---@field public AddFXReceiver function @From FXState wrapper
---@field public RemoveFXReceiver function @From FXState wrapper
local baseClass = GUIButton
baseClass = GetFXStateWrappedClass(baseClass)
class "GUIMenuCustomizeTabButton" (baseClass)

GUIMenuCustomizeTabButton:AddCompositeClassProperty("Label", "text", "Text")

-- Texture of the glossy coat applied on top of both the inner box and the outer box.
local kGlossTexture = PrecacheAsset("ui/newMenu/gloss.dds")

-- Amount of room between edge of inner box and edge of button-text content.
local kInnerPadding = Vector(14, 6, 0)

-- Amount of room between edge of outer box, and edge of inner-box.  Applied to all sides.
local kPadding = Vector(6, 2, 0)


local function OnTextSizeChanged(self, size)
    self.innerBox:SetSize(size + kInnerPadding * 2)
    self.innerBoxGloss:SetSize(self.innerBox:GetSize() * Vector(2, 0.5, 1))
    self.outerBox:SetSize(self.innerBox:GetSize() + kPadding * 2)
    self.outerBoxGloss:SetSize(self.outerBox:GetSize() * Vector(2, 0.5, 1))
    self:SetSize(self.outerBox:GetSize())
end

local function OnLabelChanged(self, text)
    self.glowyText:SetText(text)
end

local function OnTextChanged(self, text)
    self:SetLabel(text)
end

local function OnPressed(self)
    PlayMenuSound("ButtonClick")
end

local function OnFXStateChanged(self, state)    --??Update?
    if state == "disabled" then
        self.text:AnimateProperty("Color", MenuStyle.kDarkGrey, MenuAnimations.Fade)
    else
        self.text:AnimateProperty("Color", MenuStyle.kOptionHeadingColor, MenuAnimations.FadeFast)
    end
end

function GUIMenuCustomizeTabButton:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    RequireType({"string", "nil"}, params.label, "params.label", errorDepth)
    
    baseClass.Initialize(self, params, errorDepth)
    
    self.outerBox = CreateGUIObject("outerBox", GUIMenuCoolBox, self)
    self.outerBox:SetLayer(-2)
    self.outerBox:AlignCenter()
    
    self.outerBoxGloss = self.outerBox:CreateGUIItem()
    self.outerBoxGloss:SetLayer(1)
    self.outerBoxGloss:SetTexture(kGlossTexture)
    self.outerBoxGloss:SetColor(MenuStyle.kGlossColor)
    self.outerBoxGloss:SetBlendTechnique(GUIItem.Add)
    self.outerBoxGloss:SetAnchor(0.5, 0.5)
    self.outerBoxGloss:SetHotSpot(0.5, 1)
    self.outerBoxGloss:SetMinCrop(0.25, 0)
    self.outerBoxGloss:SetMaxCrop(0.75, 1)
    
    self.innerBox = CreateGUIObject("innerBox", GUIMenuCoolShadowBox, self)
    self.innerBox:SetLayer(-1)
    self.innerBox:AlignCenter()
    
    self.innerBoxGloss = self.innerBox:CreateGUIItem()
    self.innerBoxGloss:SetLayer(1)
    self.innerBoxGloss:SetTexture(kGlossTexture)
    self.innerBoxGloss:SetColor(MenuStyle.kGlossColor)
    self.innerBoxGloss:SetBlendTechnique(GUIItem.Add)
    self.innerBoxGloss:SetAnchor(0.5, 0.5)
    self.innerBoxGloss:SetHotSpot(0.5, 1)
    self.innerBoxGloss:SetMinCrop(0.25, 0)
    self.innerBoxGloss:SetMaxCrop(0.75, 1)
    
    self.text = CreateGUIObject("text", GUIText, self)
    self.text:SetLayer(1)
    self.text:SetFont(params.font)
    self.text:SetColor(params.fontColor)
    self.text:AlignCenter()
    
    self.glowyText = CreateGUIObject("glowyText", GUIMenuGlowyText, self)
    self.glowyText:SetLayer(2)
    self.glowyText:SetFont(params.fontGlow)
    self.glowyText:SetStyle(params.fontGlowStyle)
    self.glowyText:AlignCenter()
    
    -- Resize button based on text.
    self:HookEvent(self.text, "OnSizeChanged", OnTextSizeChanged)
    
    -- Set glowy text.
    self:HookEvent(self, "OnLabelChanged", OnLabelChanged)
    
    -- Let SetText() be used also.
    self:HookEvent(self, "OnTextChanged", OnTextChanged)
    
    -- Play click sound when pressed.
    self:HookEvent(self, "OnPressed", OnPressed)
    
    -- Change color of bottom text based on enabled/disabled state.
    self:HookEvent(self, "OnFXStateChanged", OnFXStateChanged)
    
    if params.label then
        self:SetLabel(params.label)
    end
    
end
