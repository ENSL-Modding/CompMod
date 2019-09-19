-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. ============
--
-- lua/menu2/NavBar/Screens/ServerBrowser/GMSBTextButton.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Text button for the server browser that can optionally glow.  The button is automatically
--    sized to the text.
--  
--  Properties:
--      Enabled     Whether or not the button can be interacted with.
--      MouseOver   Whether or not the mouse is over the button (regardless of enabled-state).
--      Pressed     Whether or not the button is being pressed in by the mouse.
--      State       The current state of the button.  Can by the following:
--                      disabled    -- The button cannot be interacted with.
--                      pressed     -- The button is currently being hovered over and pressed down
--                                         on by the user.
--                      hover       -- The mouse is hovering over the button, but not pressed.
--                      active      -- The button is enabled and not being interacted with.
--      Glowing     Whether or not the text is glowing.
--      Label       The text displayed for this button.
--  
--  Events:
--      OnPressed   Whenever the button is pressed and released while enabled.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =======================

Script.Load("lua/GUI/widgets/GUIButton.lua")
Script.Load("lua/GUI/GUIText.lua")
Script.Load("lua/GUI/style/GUIStyledText.lua")
Script.Load("lua/menu2/MenuStyles.lua")
Script.Load("lua/GUI/wrappers/FXState.lua")

local kDefaultStyle = MenuStyle.kMainBarButtonGlow
local kDefaultFont = MenuStyle.kServerAllFilterFont

---@class GMSBTextButton : GUIButton
---@field public GetFXState function @From FXState wrapper
---@field public UpdateFXStateOverride function @From FXState wrapper
---@field public AddFXReceiver function @From FXState wrapper
---@field public RemoveFXReceiver function @From FXState wrapper
local baseClass = GUIButton
baseClass = GetFXStateWrappedClass(baseClass)
class "GMSBTextButton" (baseClass)

GMSBTextButton:AddClassProperty("Glowing", true)
GMSBTextButton:AddClassProperty("Label", "LABEL")

local function OnLabelChanged(self, label)
    self.dimText:SetText(label)
    self.glowText:SetText(label)
    self.glowFlashText:SetText(label)
end

local function OnGlowingChanged(self, glowing)
    self.dimText:SetVisible(not glowing)
    self.glowText:SetVisible(glowing)
    self.glowFlashText:SetVisible(glowing)
end

local function OnPressed(self)
    PlayMenuSound("ButtonClick")
end

local function OnFXStateChanged(self, state, prevState)
    if state == "disabled" then
        self.dimText:AnimateProperty("Color", MenuStyle.kDarkGrey, MenuAnimations.Fade)
        self.glowText:AnimateProperty("Opacity", 0.5, MenuAnimations.Fade)
    elseif state == "pressed" then
        self.dimText:ClearPropertyAnimations("Color")
        self.dimText:SetColor((MenuStyle.kHighlight + MenuStyle.kOptionHeadingColor) * 0.5)
        self.glowFlashText:ClearPropertyAnimations("Opacity")
        self.glowFlashText:SetOpacity(0)
    elseif state == "hover" then
        if prevState == "pressed" then
            self.dimText:AnimateProperty("Color", MenuStyle.kHighlight, MenuAnimations.Fade)
            self.glowFlashText:AnimateProperty("Opacity", 0.5, MenuAnimations.Fade)
        else
            DoColorFlashEffect(self.dimText)
            self.glowFlashText:SetOpacity(1)
            self.glowFlashText:AnimateProperty("Opacity", 0.5, MenuAnimations.Fade)
            PlayMenuSound("ButtonHover")
        end
    elseif state == "default" then
        self.dimText:AnimateProperty("Color", MenuStyle.kOptionHeadingColor, MenuAnimations.Fade)
        self.glowText:AnimateProperty("Opacity", 1, MenuAnimations.Fade)
        self.glowFlashText:AnimateProperty("Opacity", 0, MenuAnimations.Fade)
    end
end

function GMSBTextButton:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    RequireType({"boolean", "nil"}, params.glowing, "params.glowing", errorDepth)
    RequireType({"string", "nil"}, params.label, "params.label", errorDepth)
    
    baseClass.Initialize(self, params, errorDepth)
    
    self.dimText = CreateGUIObject("dimText", GUIText, self)
    self.dimText:SetColor(MenuStyle.kOptionHeadingColor)
    self.dimText:SetFont(kDefaultFont)
    self.dimText:AlignCenter()
    self:HookEvent(self.dimText, "OnSizeChanged", self.SetSize)
    self.dimText:SetVisible(false)
    
    self.glowText = CreateGUIObject("glowText", GUIStyledText, self)
    self.glowText:SetStyle(kDefaultStyle)
    self.glowText:SetFont(kDefaultFont)
    self.glowText:SetVisible(true)
    self.glowText:AlignCenter()
    
    self.glowFlashText = CreateGUIObject("glowFlashText", GUIStyledText, self)
    self.glowFlashText:SetLayer(1)
    self.glowFlashText:SetBlendTechnique(GUIItem.Add)
    self.glowFlashText:SetStyle(kDefaultStyle)
    self.glowFlashText:SetFont(kDefaultFont)
    self.glowFlashText:AlignCenter()
    self.glowFlashText:SetVisible(true)
    self.glowFlashText:SetColor(1, 1, 1, 0)
    
    self:HookEvent(self, "OnLabelChanged", OnLabelChanged)
    self:HookEvent(self, "OnGlowingChanged", OnGlowingChanged)
    self:HookEvent(self, "OnFXStateChanged", OnFXStateChanged)
    
    if params.glowing ~= nil then
        self:SetGlowing(params.glowing)
    end
    
    if params.label then
        self:SetLabel(params.label)
    end
    
    self:HookEvent(self, "OnPressed", OnPressed)
    
end
