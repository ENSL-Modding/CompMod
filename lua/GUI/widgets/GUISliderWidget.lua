-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/GUI/widgets/GUISliderWidget.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    A GUIDragWidget constrained to movement along only one axis.
--
--  Properties:
--      BeingDragged        Whether or not the GUIDraggable held within this object is being dragged.
--      SliderLength        Length of the slider object along its major axis.  The slider object
--                          fills the available space along the minor axis.
--     *orientation         The orientation of the slider.  Must be either "horizontal" or
--                          "vertical".
--  
--  Events:
--      OnDragBegin         The user has clicked on the slider to begin dragging.
--      OnDrag              The slider has changed position as a result of the user dragging it.
--      OnDragEnd           The user has released the slider to end dragging.
--      OnJump              The value of the slider has jumped (eg the user clicked the
--                          background).
--      OnValueChanged      The slider has moved some amount, regardless of user interaction.
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/GUI/widgets/GUIDragWidget.lua")

Script.Load("lua/GUI/wrappers/Oriented.lua")

---@class GUISliderWidget : GUIDragWidget
---@field public GetMajorAxis function @From Oriented wrapper
---@field public GetMinorAxis function @From Oriented wrapper
---@field public GetOrientation function @From Oriented wrapper
local baseClass = GUIDragWidget
baseClass = GetOrientedWrappedClass(baseClass)
class "GUISliderWidget" (baseClass)

local kDefaultSliderLength = 32
local kJumpFraction = 0.2

GUISliderWidget:AddClassProperty("SliderLength", 32)

local function UpdateDraggerSize(self)
    
    self:GetDraggable():SetSize(self:GetMajorAxis() * self:GetSliderLength() + self:GetMinorAxis() * Dot2D(self:GetMinorAxis(), self:GetSize()))
    
end

local function OnSizeChanged(self, size, prevSize)
    
    local majorSizeBefore = Dot2D(self:GetMajorAxis(), prevSize)
    local majorSizeAfter = Dot2D(self:GetMajorAxis(), size)
    
    local minorSizeBefore = Dot2D(self:GetMinorAxis(), prevSize)
    local minorSizeAfter = Dot2D(self:GetMinorAxis(), size)
    
    -- Need to move the slider so that it represents the same fractional value as before.
    if majorSizeBefore ~= majorSizeAfter then
        local positionBefore = Dot2D(self:GetDraggable():GetPosition(true), self:GetMajorAxis())
        local draggableSize = Dot2D(self:GetMajorAxis(), self:GetDraggable():GetSize(true) * self:GetDraggable():GetScale(true))
        local maxBefore = majorSizeBefore - draggableSize
        
        local fraction = 0
        if maxBefore ~= 0 then
            fraction = positionBefore / maxBefore
        end
        
        local maxAfter = majorSizeAfter - draggableSize
        local positionAfter = (maxAfter * fraction) * self:GetMajorAxis()
        self:GetDraggable():SetPosition(positionAfter)
        
    end
    
    -- Update the dragger size.
    if minorSizeBefore ~= minorSizeAfter then
        UpdateDraggerSize(self)
    end
    
end

function GUISliderWidget:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    baseClass.Initialize(self, params, errorDepth)
    
    self._sliderResizeHook = self:HookEvent(self, "OnSizeChanged", OnSizeChanged)
    self:HookEvent(self, "OnSliderLengthChanged", UpdateDraggerSize)
    self:ForwardEvent(self, "OnMove", "OnValueChanged")
    
    self:ListenForCursorInteractions()
    
end

function GUISliderWidget:OnMouseClick()
    
    local mousePos = GetGlobalEventDispatcher():GetMousePosition()
    local localMousePos = self:ScreenSpaceToLocalSpace(mousePos)
    local mouseDotPos = Dot2D(self:GetMajorAxis(), localMousePos)
    if mouseDotPos < self:GetSliderValue() then
        -- Jump in the negative direction.
        self:JumpFraction(-kJumpFraction)
    else
        -- Jump in the positive direction
        self:JumpFraction(kJumpFraction)
    end
    
end

-- Moves the slider forward by a certain amount (or backwards if negative).
function GUISliderWidget:Jump(amount)
    
    if self:GetDraggable():SetPosition(self:GetDraggable():GetPosition(true) + self:GetMajorAxis() * amount) then
        self:FireEvent("OnJump")
        return true
    end
    
    return false
    
end

-- Moves the slider forward by a certain fraction of the total size (or backwards if negative).
function GUISliderWidget:JumpFraction(fraction)
    local result = self:Jump(self:GetSliderMaxValue() * fraction)
    return result
end

function GUISliderWidget:GetSliderMaxValue(static)
    
    local draggable = self:GetDraggable()
    local draggableSize = Dot2D(self:GetMajorAxis(), draggable:GetSize(static) * draggable:GetScale(static))
    local totalSize = Dot2D(self:GetSize(static), self:GetMajorAxis())
    
    local result = math.max(1, totalSize - draggableSize)
    return result
    
end

function GUISliderWidget:GetSliderValue(static)
    
    local value = Dot2D(self:GetDraggable():GetPosition(static), self:GetMajorAxis())
    local result = Clamp(value, 0, self:GetSliderMaxValue(static))
    return result
    
end

-- This is overridden by scrollbars.
GUISliderWidget.GetValue = GUISliderWidget.GetSliderValue

-- Override for animations.
function GUISliderWidget:SetValue(value, disableAnimation)
    
    local constrainedValue = Clamp(value, 0, self:GetSliderMaxValue())
    
    -- Don't do anything if the value isn't going to change.
    if self:GetSliderValue(true) == constrainedValue then
        return false
    end
    
    local result = self:GetDraggable():SetPosition(constrainedValue * self:GetMajorAxis())
    return result
    
end
