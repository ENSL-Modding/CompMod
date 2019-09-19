-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/GUI/widgets/GUIButton.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Base button class.  Has no visuals or sounds associated with it.  These can be hooked in via
--    events.
--  
--  Properties:
--      MouseOver   Whether or not the mouse is over the button (regardless of enabled-state).
--      Pressed     Whether or not the button is being pressed in by the mouse.
--      Enabled     Whether or not the button can be interacted with.
--  
--  Events:
--      OnPressed   Whenever the button is pressed and released while enabled.
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/GUI/GUIObject.lua")
Script.Load("lua/GUI/wrappers/CursorInteractable.lua")

---@class GUIButton : GUIObject
---@field public GetMouseOver function @From CursorInteractable wrapper
---@field public GetPressed function @From CursorInteractable wrapper
local baseClass = GUIObject
baseClass = GetCursorInteractableWrappedClass(baseClass)
class "GUIButton" (baseClass)

GUIButton:AddClassProperty("Enabled", true)

function GUIButton:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    baseClass.Initialize(self, params, errorDepth)
end
