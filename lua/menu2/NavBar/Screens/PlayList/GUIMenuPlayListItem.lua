-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/NavBar/Screens/PlayList/GUIMenuPlayListItem.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Menu item for the "Play" button dropdown from the nav bar.
--
--  Parameters (* = required)
--      label
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/widgets/GUIButton.lua")

Script.Load("lua/menu2/MenuUtilities.lua")
Script.Load("lua/menu2/MenuStyles.lua")

---@class GUIMenuPlayListItem : GUIButton
---@field public GetFXState function @From FXState wrapper
---@field public UpdateFXStateOverride function @From FXState wrapper
---@field public AddFXReceiver function @From FXState wrapper
---@field public RemoveFXReceiver function @From FXState wrapper
local baseClass = GUIButton
baseClass = GetFXStateWrappedClass(baseClass)
class 'GUIMenuPlayListItem' (baseClass)

GUIMenuPlayListItem.kHoverColor = MenuStyle.kHighlight
GUIMenuPlayListItem.kNonHoverColor = MenuStyle.kOffWhite
GUIMenuPlayListItem.kBackTexture = PrecacheAsset("ui/newMenu/playListItemSelect.dds")
GUIMenuPlayListItem.kTextPosition = Vector(124, 0, 0)
GUIMenuPlayListItem.kFont = MenuStyle.kPlayMenuFont

GUIMenuPlayListItem.kFlashShader = PrecacheAsset("shaders/GUI/menu/flash.surface_shader")

GUIMenuPlayListItem:AddClassProperty("_Flash", 0.0)
GUIMenuPlayListItem:AddClassProperty("_HoverOpacity", 0.0)

local function SharedUpdateFlashAndTextColor(self, flash, textColor)
    
    self.backgroundGraphic:SetFloatParameter("multAmount", 2*flash+1)
    self.backgroundGraphic:SetFloatParameter("screenAmount", 2*flash)
    
    flash = 2 * flash - flash * flash
    local color = (Color(2, 2, 2, 1) * flash) + (textColor * (1.0-flash))
    self.textItem:SetColor(color)
    
end

local function On_TextColorChanged(self, value)
    local flash = self:Get_Flash()
    local textColor = value
    SharedUpdateFlashAndTextColor(self, flash, textColor)
end

local function On_FlashChanged(self, flash)
    local textColor = self:Get_TextColor()
    SharedUpdateFlashAndTextColor(self, flash, textColor)
end

local function On_HoverOpacityChanged(self, opacity)
    self.backgroundGraphic:SetColor(1, 1, 1, opacity)
end

local function OnFXStateChanged(self, state, prevState)
    if state == "pressed" then
        self:ClearPropertyAnimations("_HoverOpacity")
        self:Set_HoverOpacity(0.5)
    elseif state == "hover" then
        self:Set_TextColor(Color(self.kHoverColor))
        if prevState == "pressed" then
            self:ClearPropertyAnimations("_HoverOpacity")
            self:Set_HoverOpacity(1)
        else
            PlayMenuSound("ButtonHover")
            self:Set_HoverOpacity(1)
            self:ClearPropertyAnimations("_HoverOpacity")
            self:Set_Flash(1)
            self:AnimateProperty("_Flash", 0, MenuAnimations.FlashColor)
        end
    elseif state == "default" then
        self:AnimateProperty("_HoverOpacity", 0, MenuAnimations.Fade)
        self:AnimateProperty("_TextColor", Color(self.kNonHoverColor), MenuAnimations.Fade)
    end
end

function GUIMenuPlayListItem:CreateVisuals()
    
    self:AddInstanceProperty("_TextColor", Color(self.kNonHoverColor))
    
    self.textItem = CreateGUIObject("textItem", GUIText, self)
    self.textItem:SetLayer(1)
    self.textItem:SetPosition(self.kTextPosition)
    self.textItem:SetFont(self.kFont)
    self.textItem:AlignLeft()
    
    self.backgroundGraphic = self:CreateGUIItem()
    self.backgroundGraphic:SetLayer(-1)
    self.backgroundGraphic:SetTexture(self.kBackTexture)
    self.backgroundGraphic:SetShader(self.kFlashShader)
    self.backgroundGraphic:SetColor(1, 1, 1, 0)
    self.backgroundGraphic:SetSizeFromTexture()
    
    self:SetSize(self.backgroundGraphic:GetSize())
    
    self:HookEvent(self, "On_FlashChanged", On_FlashChanged)
    self:HookEvent(self, "On_HoverOpacityChanged", On_HoverOpacityChanged)
    self:HookEvent(self, "OnFXStateChanged", OnFXStateChanged)
    self:HookEvent(self, "On_TextColorChanged", On_TextColorChanged)
    
    self:HookEvent(self, "OnTextChanged", self.OnTextChanged)
    
    SharedUpdateFlashAndTextColor(self, self:Get_Flash(), self:Get_TextColor())
    
end

local function PlayPressedSound()
    PlayMenuSound("ButtonClick")
end

function GUIMenuPlayListItem:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    RequireType({"string", "nil"}, params.label, "params.label", errorDepth)
    
    baseClass.Initialize(self, params, errorDepth)
    
    self:CreateVisuals()
    
    self:HookEvent(self, "OnPressed", PlayPressedSound)
    
    if params.label then
        self:SetText(params.label)
    end
    
end

function GUIMenuPlayListItem:OnTextChanged(text)
    self.textItem:SetText(text)
end
