-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/menu2/widgets/GUIMenuScrollerWidget.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Menu themeing for GUIScrollerWidget.
--
--  Properties:
--      BeingDragged        Whether or not the GUIDraggable held within this object is being dragged.
--      SliderLength        Length of the slider object along its major axis.  The slider object
--                          fills the available space along the minor axis.
--      TotalRange          The total amount of area represented by this scroll bar.  This might
--                          correspond to the height of a page being viewed, for example.
--      ViewRange           Representation of the amount of space being viewed with this scroll
--                          bar.  This might correspond to the height of the window where a page is
--                          being displayed, for example.
--  
--  Events:
--      OnDragBegin         The user has clicked on the slider to begin dragging.
--      OnDrag              The slider has changed position as a result of the user dragging it.
--      OnDragEnd           The user has released the slider to end dragging.
--      OnJump              The value of the slider has jumped (eg the user clicked the
--                          background).
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/GUI/widgets/GUIScrollerWidget.lua")
Script.Load("lua/menu2/widgets/GUIMenuScrollerDraggable.lua")
Script.Load("lua/menu2/MenuStyles.lua")

Script.Load("lua/menu2/widgets/GUIMenuSliderWidget.lua")

---@class GUIMenuScrollerWidget : GUIScrollerWidget
class "GUIMenuScrollerWidget" (GUIScrollerWidget)

local function OnOpacityChanged(self, opacity)
    self.draggable:SetOpacity(opacity)
end

function GUIMenuScrollerWidget:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    PushParamChange(params, "draggableClass", params.draggableClass or GUIMenuScrollerDraggable)
    GUIScrollerWidget.Initialize(self, params, errorDepth)
    PopParamChange(params, "draggableClass")
    
    self:HookEvent(self, "OnOpacityChanged", OnOpacityChanged)
    
end

-- Overridden for animations.
function GUIMenuScrollerWidget:SetValue(value, disableAnimation)
    
    local constrainedValue = Clamp(self:ConvertScrollToSlider(value), 0, self:GetSliderMaxValue())
    
    -- Don't do anything if the value isn't going to change.
    if self:GetValue(true) == constrainedValue then
        return false
    end
    
    if disableAnimation or self:GetBeingDragged() then
        local result = self:GetDraggable():SetPosition(constrainedValue * self:GetMajorAxis())
        return result
    else
        self:GetDraggable():AnimateProperty("Position", constrainedValue * self:GetMajorAxis(), MenuAnimations.FlyIn)
        return true
    end

end