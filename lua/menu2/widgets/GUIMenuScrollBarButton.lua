-- ======= Copyright (c) 2018, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/widgets/GUIMenuScrollBarButton.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Menu scroll-bar themed button object.
--
--  Parameters (* = required)
--      defaultColor    The color of the graphic when not highlighted or disabled.  Defaults to
--                      MenuStyle.kLightGrey.
--      disabledColor   The color of the graphic when disabled.  Defaults to MenuStyle.kDarkGrey.
--      highlightColor  The color of the graphic when highlighted.  Defaults to
--                      MenuStyle.kHighlight.
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

---@class GUIMenuScrollBarButton : GUIMenuDirectionalButton
class "GUIMenuScrollBarButton" (GUIMenuDirectionalButton)

local kArrowGraphic = PrecacheAsset("ui/newMenu/scrollbarArrow.dds")

function GUIMenuScrollBarButton:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    PushParamChange(params, "defaultColor", params.defaultColor or MenuStyle.kScrollBarWidgetForegroundColor)
    PushParamChange(params, "highlightColor", params.highlightColor or MenuStyle.kWhite)
    PushParamChange(params, "texture", kArrowGraphic)
    PushParamChange(params, "directionOffset", 3)
    GUIMenuDirectionalButton.Initialize(self, params, errorDepth)
    PopParamChange(params, "directionOffset")
    PopParamChange(params, "texture")
    PopParamChange(params, "highlightColor")
    PopParamChange(params, "defaultColor")
    
end
