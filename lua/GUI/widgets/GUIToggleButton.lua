-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/GUI/widgets/GUIToggleButton.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Extension of GUIButton that will toggle between two states.
--  
--  Parameters (* = required)
--      enabled
--      value
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

Script.Load("lua/GUI/widgets/GUIButton.lua")

---@class GUIToggleButton : GUIButton
class "GUIToggleButton" (GUIButton)

GUIToggleButton:AddClassProperty("Value", false)

function GUIToggleButton:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    RequireType({"boolean", "nil"}, params.value, "params.value", errorDepth)
    
    GUIButton.Initialize(self, params, errorDepth)
    
    if params.value ~= nil then
        self:SetValue(params.value)
    end
    
end

function GUIToggleButton:OnMouseRelease()
    
    self:PauseEvents()
        
        GUIButton.OnMouseRelease(self)
        self:SetValue(not self:GetValue())
        
    self:ResumeEvents()
    
end
