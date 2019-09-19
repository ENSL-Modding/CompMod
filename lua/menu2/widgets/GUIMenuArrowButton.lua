-- ======= Copyright (c) 2018, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/widgets/GUIMenuArrowButton.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--    
--    Arrow button.  Used for sliders.
--@class GUIMenuArrowButton : GUIDirectionalButton
--
--  Properties:
--      Enabled     Whether or not the button can be interacted with.
--      MouseOver   Whether or not the mouse is over the button (regardless of enabled-state).
--      Pressed     Whether or not the button is being pressed in by the mouse.
--      Direction   The direction the button points.
--  
--  Events:
--      OnPressed   Whenever the button is pressed and released while enabled.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/menu2/widgets/GUIMenuDirectionalButton.lua")

---@class GUIMenuArrowButton : GUIMenuDirectionalButton
class "GUIMenuArrowButton" (GUIMenuDirectionalButton)

local kArrowGraphic = PrecacheAsset("ui/newMenu/arrow.dds")

function GUIMenuArrowButton:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    PushParamChange(params, "texture", kArrowGraphic)
    PushParamChange(params, "directionOffset", 1)
    GUIMenuDirectionalButton.Initialize(self, params, errorDepth)
    PopParamChange(params, "directionOffset")
    PopParamChange(params, "texture")

end
