-- ======= Copyright (c) 2018, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/widgets/GUIMenuPasswordToggleButton.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    GUIToggleButton that is themed for the button in password prompts that shows/hides the text.
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
--      Value       Current value of the button's toggle -- true or false.
--  
--  Events:
--      OnPressed   Whenever the button is pressed and released while enabled.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/widgets/GUIToggleButton.lua")
Script.Load("lua/GUI/wrappers/FXState.lua")
Script.Load("lua/menu2/wrappers/MenuFX.lua")

---@class GUIMenuPasswordToggleButton : GUIToggleButton
---@field public GetFXState function @From FXState wrapper
---@field public UpdateFXStateOverride function @From FXState wrapper
---@field public AddFXReceiver function @From FXState wrapper
---@field public RemoveFXReceiver function @From FXState wrapper
---@field protected OnFXStateChangedOverride function @From MenuFX wrapper
local baseClass = GUIToggleButton
baseClass = GetMenuFXWrappedClass(baseClass)
class "GUIMenuPasswordToggleButton" (baseClass)

local kToggleIcon = PrecacheAsset("ui/menu/serverbrowser/eye.dds")
local kDefaultSize = Vector(72, 72, 0)

local function OnPressed(self)
    if self:GetValue() then
        PlayMenuSound("AcceptChoice")
    else
        PlayMenuSound("CancelChoice")
    end
end

function GUIMenuPasswordToggleButton:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    baseClass.Initialize(self, params, errorDepth,
    {
        defaultColor = MenuStyle.kOptionHeadingColor,
    })
    
    self:SetTexture(kToggleIcon)
    self:SetSize(kDefaultSize)
    
    self:HookEvent(self, "OnPressed", OnPressed)
    
end
