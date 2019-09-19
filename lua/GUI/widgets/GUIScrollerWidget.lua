-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/GUI/widgets/GUIScrollerWidget.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    A GUISliderWidget with additional "scroller" capabilities, making it more suitable for use in
--    a scroll bar.
--  
--  Parameters (* = required)
--      scrollSpeedMult
--     *orientation         The orientation of the scroller.  Must be either "horizontal"
--                          or "vertical".
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
--      ScrollSpeedMult     Multiplier for scroll speed.
--  
--  Events:
--      OnDragBegin         The user has clicked on the slider to begin dragging.
--      OnDrag              The slider has changed position as a result of the user dragging it.
--      OnDragEnd           The user has released the slider to end dragging.
--      OnJump              The value of the slider has jumped (eg the user clicked the
--                          background).
--      OnValueChanged      The scroller has moved some amount, regardless of user interaction.
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/GUI/widgets/GUISliderWidget.lua")

---@class GUIScrollerWidget : GUISliderWidget
class "GUIScrollerWidget" (GUISliderWidget)

GUIScrollerWidget:AddClassProperty("TotalRange", 100)
GUIScrollerWidget:AddClassProperty("ViewRange", 25)
GUIScrollerWidget:AddClassProperty("ScrollSpeedMult", 1)

local kScrollAmount = 75

local function UpdateRange(self)
    
    local totalRange = self:GetTotalRange()
    local viewRange = self:GetViewRange()
    
    local sliderFraction = math.min(viewRange / totalRange, 1)
    
    local sliderLength = Dot2D(self:GetMajorAxis(), self:GetSize()) * sliderFraction
    
    self:SetSliderLength(sliderLength)
    self.draggable:SetEnabled(totalRange > viewRange)
    
end

function GUIScrollerWidget:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    RequireType({"number", "nil"}, params.scrollSpeedMult, "params.scrollSpeedMult", errorDepth)
    
    GUISliderWidget.Initialize(self, params, errorDepth)
    
    assert(self:UnHookEventsByCallback(self._sliderResizeHook))
    
    self:HookEvent(self, "OnTotalRangeChanged", UpdateRange)
    self:HookEvent(self, "OnViewRangeChanged", UpdateRange)
    self:HookEvent(self, "OnSizeChanged", UpdateRange)
    
    -- Scrollers can be scrolled by rolling the mouse wheel while the cursor is over them.
    self:ListenForWheelInteractions()
    
    if params.scrollSpeedMult then
        self:SetScrollSpeedMult(params.scrollSpeedMult)
    end
    
end

-- Override SetSize so that whenever the size of the widget is changed, the scroll bar is
-- automatically shifted to represent the same value it had before.
function GUIScrollerWidget:SetSize(p1, p2, p3)
    
    -- Remember previous scroll value.
    local prevScroll = self:GetValue()
    
    -- Set size like normal.
    local result = GUISliderWidget.SetSize(self, p1, p2, p3)
    
    -- If it was changed, set the scroll value to the remembered value.
    if result then
        self:SetValue(prevScroll)
    end
    
    -- Return result of SetSize() like normal.
    return result
    
end

function GUIScrollerWidget:OnMouseWheel(up)
    local result = self:Scroll(up)
    return result
end

function GUIScrollerWidget:Scroll(up)
    
    -- Convert the scroll speed from "scroll units" to slider units.  (Eg we don't want shorter
    -- scrollbars to scroll faster than longer scrollbars, assuming the represented values are the
    -- same.)
    local scrollAmount = kScrollAmount
    local scrollRange = self:GetScrollRange()
    if scrollRange ~= 0 then
        scrollAmount = scrollAmount * (self:GetSliderMaxValue(true) / self:GetScrollRange())
    end
    local result = self:Jump((up and -1 or 1) * scrollAmount * self:GetScrollSpeedMult())
    return result
end

function GUIScrollerWidget:GetScrollRange(static)
    return self:GetTotalRange(static) - self:GetViewRange(static)
end

-- Converts a slider value to a scroller value.  By default, will use current state of object in the
-- calculations, but you can alternatively provide your own slider max and/or scroll range.
function GUIScrollerWidget:ConvertSliderToScroll(value, altSliderMax, altScrollRange)
    
    local sliderMax = altSliderMax or self:GetSliderMaxValue()
    local scrollRange = math.max(0, altScrollRange or self:GetScrollRange())
    
    local fraction = 0
    if sliderMax ~= 0 then
        fraction = value / sliderMax
    end
    fraction = Clamp(fraction, 0, 1)
    
    return fraction * scrollRange
    
end

-- Converts a scroll value to a slider value.  By default will use current state of object in the
-- calculations, but you can alternatively provide your own slider max and/or scroll range.
function GUIScrollerWidget:ConvertScrollToSlider(value, altSliderMax, altScrollRange)
    
    local sliderMax = altSliderMax or self:GetSliderMaxValue()
    local scrollRange = altScrollRange or self:GetScrollRange()
    
    local fraction = 0
    if scrollRange ~= 0 then
        fraction = value / scrollRange
    end
    
    return fraction * sliderMax
    
end

-- Returns the slider value converted to be within the scroll range.
function GUIScrollerWidget:GetValue(static)
    local sliderWidgetValue = GUISliderWidget.GetValue(self, static)
    local result = self:ConvertSliderToScroll(sliderWidgetValue)
    return result
end

-- Sets the value of the slider, converted from a scroll value.
function GUIScrollerWidget:SetValue(value, disableAnimation)
    local result = GUISliderWidget.SetValue(self, self:ConvertScrollToSlider(value), disableAnimation)
    return result
end
