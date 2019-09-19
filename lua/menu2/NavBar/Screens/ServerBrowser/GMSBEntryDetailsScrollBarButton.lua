-- ======= Copyright (c) 2018, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/NavBar/Screens/ServerBrowser/GMSBEntryDetailsScrollBarButton.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    GUIMenuScrollBarButton themed for the server browser entry details (blue instead of grey).
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

Script.Load("lua/menu2/widgets/GUIMenuScrollBarButton.lua")

---@class GMSBEntryDetailsScrollBarButton : GUIMenuScrollBarButton
class "GMSBEntryDetailsScrollBarButton" (GUIMenuScrollBarButton)

function GMSBEntryDetailsScrollBarButton:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    PushParamChange(params, "defaultColor", MenuStyle.kServerBrowserEntryDetailsScrollerColor)
    PushParamChange(params, "disabledColor", MenuStyle.kServerBrowserEntryDetailsScrollerDimColor)
    GUIMenuScrollBarButton.Initialize(self, params, errorDepth)
    PopParamChange(params, "disabledColor")
    PopParamChange(params, "defaultColor")
    
end
