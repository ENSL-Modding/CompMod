-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/menu2/widgets/GUIMenuSliderWidget.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Menu themeing for GUISliderWidget.
--@class GUIMenuSliderWidget : GUISliderWidget
--
--  Properties:
--      BeingDragged        Whether or not the GUIDraggable held within this object is being dragged.
--      SliderLength        Length of the slider object along its major axis.  The slider object
--                          fills the available space along the minor axis.
--  
--  Events:
--      OnDragBegin         The user has clicked on the slider to begin dragging.
--      OnDrag              The slider has changed position as a result of the user dragging it.
--      OnDragEnd           The user has released the slider to end dragging.
--      OnJump              The value of the slider has jumped (eg the user clicked the
--                          background).
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/GUI/widgets/GUISliderWidget.lua")
Script.Load("lua/menu2/widgets/GUIMenuSliderDraggable.lua")
Script.Load("lua/menu2/MenuStyles.lua")

---@class GUIMenuSliderWidget : GUISliderWidget
class "GUIMenuSliderWidget" (GUISliderWidget)

local function OnJump(self)
    PlayMenuSound("ButtonClick")
end

function GUIMenuSliderWidget:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    PushParamChange(params, "draggableClass", params.draggableClass or GUIMenuSliderDraggable)
    GUISliderWidget.Initialize(self, params, errorDepth)
    PopParamChange(params, "draggableClass")
    
    self:HookEvent(self, "OnJump", OnJump)
    
end

-- Overridden for animations.
function GUIMenuSliderWidget:SetValue(value, disableAnimation)
    
    local constrainedValue = Clamp(value, 0, self:GetSliderMaxValue())
    
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
