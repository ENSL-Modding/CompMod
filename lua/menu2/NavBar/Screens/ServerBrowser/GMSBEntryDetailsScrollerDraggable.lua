-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/menu2/NavBar/Screens/ServerBrowser/GMSBEntryDetailsScrollerDraggable.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    A GUIDraggable themed for the server browser entry details (it's blue instead of grey...).
--
--  Properties:
--      BeingDragged    Whether or not this object is currently being dragged by the user.
--  
--  Events:
--      OnDragBegin         The user has clicked on the slider to begin dragging.
--      OnDrag              The slider has changed position as a result of the user dragging it.
--      OnDragEnd           The user has released the slider to end dragging.
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/GUI/widgets/GUIDraggable.lua")
Script.Load("lua/menu2/MenuStyles.lua")

---@class GMSBEntryDetailsScrollerDraggable : GUIMenuScrollerDraggable
class "GMSBEntryDetailsScrollerDraggable" (GUIMenuScrollerDraggable)

function GMSBEntryDetailsScrollerDraggable:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    PushParamChange(params, "defaultColor", MenuStyle.kServerBrowserEntryDetailsScrollerColor)
    GUIMenuScrollerDraggable.Initialize(self, params, errorDepth)
    PopParamChange(params, "defaultColor")
    
end
