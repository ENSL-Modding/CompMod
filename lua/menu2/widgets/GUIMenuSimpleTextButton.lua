-- ======= Copyright (c) 2018, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/widgets/GUIMenuSimpleTextButton.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--    
--    Menu-themeing for a simple GUIButton that contains text.
--
--  Parameters (* = required)
--      font
--      fontFamily
--      fontSize
--      text
--      defaultColor    The color of the text when not highlighted or disabled.  Defaults to
--                      MenuStyle.kLightGrey.
--
--  Properties:
--      Enabled     Whether or not the button can be interacted with.
--      MouseOver   Whether or not the mouse is over the button (regardless of enabled-state).
--      Pressed     Whether or not the button is being pressed in by the mouse.
--      Label       The text displayed for the button.
--      AutoSize    The button is automatically resized to the size of the text.  Otherwise, it is
--                  explicitly set.  Default is true.
--  
--  Events:
--      OnPressed   Whenever the button is pressed and released while enabled.
--  
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/widgets/GUIButton.lua")
Script.Load("lua/menu2/GUIMenuText.lua")

---@class GUIMenuSimpleTextButton : GUIButton
---@field public GetFXState function @From FXState wrapper
---@field public UpdateFXStateOverride function @From FXState wrapper
---@field public AddFXReceiver function @From FXState wrapper
---@field public RemoveFXReceiver function @From FXState wrapper
local baseClass = GUIButton
baseClass = GetFXStateWrappedClass(baseClass)
class "GUIMenuSimpleTextButton" (baseClass)

GUIMenuSimpleTextButton:AddClassProperty("AutoSize", true)
GUIMenuSimpleTextButton:AddCompositeClassProperty("Label", "text", "Text")

local kDefaultFont = MenuStyle.kBindingFont
local kDefaultText = "X"
local kDefaultSize = Vector(32, 32, 0)

local function OnPressed()
    PlayMenuSound("ButtonClick")
end

local function UpdateSizeFromText(self)
    if self:GetAutoSize() then
        self:SetSize(self.text:GetSize() * self.text:GetScale())
    end
end

function GUIMenuSimpleTextButton:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    baseClass.Initialize(self, params, errorDepth)
    
    self:SetSize(kDefaultSize)
    
    PushParamChange(params, "font", params.font or kDefaultFont)
    PushParamChange(params, "text", params.text or kDefaultText)
    self.text = CreateGUIObject("text", GUIMenuText, self, params)
    PopParamChange(params, "text")
    PopParamChange(params, "font")
    
    self.text:AlignCenter()
    
    self:HookEvent(self, "OnPressed", OnPressed)
    self:HookEvent(self, "OnAutoSizeChanged", UpdateSizeFromText)
    self:HookEvent(self.text, "OnSizeChanged", UpdateSizeFromText)
    
    UpdateSizeFromText(self)
    
end

function GUIMenuSimpleTextButton:SetFont(font)
    self.text:SetFont(font)
end
