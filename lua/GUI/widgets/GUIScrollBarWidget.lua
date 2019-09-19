-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. ============
--
-- lua/GUI/widgets/GUIScrollBarWidget.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    A GUIObject that contains a GUIScrollerWidget and two GUIDirectionalButton objects.
--  
--  Parameters (* = required)
--     *scrollerWidgetClass         Class that is used for the scroller.
--     *directionalButtonClass      Class that is used for the two buttons on either side of the
--                                  scroller.
--     *orientation                 The orientation of the scroll bar.  Must be either "horizontal"
--                                  or "vertical".
--  
--  Properties:
--      BeingDragged        Whether or not the GUIDraggable held within this object is being
--                          dragged.
--      ButtonGap           Amount of spacing to add between the buttons and the slider.
--      OutsidePadding      How much padding to add around the outside.
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
--      OnValueChanged      The scroll bar has moved some amount, regardless of user interaction.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =======================

Script.Load("lua/GUI/GUIObject.lua")
Script.Load("lua/GUI/widgets/GUISliderWidget.lua")
Script.Load("lua/GUI/widgets/GUIScrollerWidget.lua")
Script.Load("lua/GUI/widgets/GUISliderBarWidget.lua")

Script.Load("lua/GUI/wrappers/Oriented.lua")

---@class GUIScrollBarWidget : GUIObject
---@field public GetMajorAxis function @From Oriented wrapper
---@field public GetMinorAxis function @From Oriented wrapper
---@field public GetOrientation function @From Oriented wrapper
local baseClass = GUIObject
baseClass = GetOrientedWrappedClass(baseClass)
class "GUIScrollBarWidget" (baseClass)

local kDefaultGap = 0
local kDefaultOutsidePadding = 0

GUIScrollBarWidget:AddCompositeClassProperty("SliderLength", "scroller")
GUIScrollBarWidget:AddCompositeClassProperty("BeingDragged", "scroller")
GUIScrollBarWidget:AddCompositeClassProperty("TotalRange", "scroller")
GUIScrollBarWidget:AddCompositeClassProperty("ViewRange", "scroller")
GUIScrollBarWidget:AddClassProperty("ButtonGap", kDefaultGap)
GUIScrollBarWidget:AddClassProperty("OutsidePadding", kDefaultOutsidePadding)

local function OnMinusButtonPressed(self)
    self:Scroll(true)
end

local function OnPlusButtonPressed(self)
    self:Scroll(false)
end

local function UpdateContentsConstraints(self)
    
    local size = self:GetSize(true)
    local outsidePadding = self:GetOutsidePadding(true)
    local buttonGap = self:GetButtonGap(true)
    local minorAxis = self:GetMinorAxis()
    local majorAxis = self:GetMajorAxis()
    
    -- Don't resize the buttons.  Scale them to fit the height of the scroller.
    local minor = Dot2D(minorAxis, size) - outsidePadding * 2
    local buttonSize = self.minusButton:GetSize(true) -- assume both buttons are same size.
    local buttonMinor = Dot2D(minorAxis, buttonSize)
    local scaleFactor = minor / buttonMinor
    local buttonMajor = Dot2D(majorAxis, buttonSize) * scaleFactor
    
    self.minusButton:SetScale(scaleFactor, scaleFactor)
    self.plusButton:SetScale(scaleFactor, scaleFactor)
    
    local major = Dot2D(majorAxis, size)
    local scrollerMajor = major - (buttonMajor * 2) - (buttonGap * 2) - (outsidePadding * 2)
    local scrollerNewSize = majorAxis * scrollerMajor + minorAxis * minor
    self.scroller:SetSize(scrollerNewSize)
    
    self.minusButton:SetPosition(majorAxis * outsidePadding)
    self.plusButton:SetPosition(majorAxis * -outsidePadding)
    
end

local function UpdateButtonEnabledState(self)
    
    local value = self:GetValue(true)
    local scrollRange = self:GetScrollRange(true)
    
    self.minusButton:SetEnabled(value >= 0.5)
    self.plusButton:SetEnabled(scrollRange >= 0.5)
    
end

function GUIScrollBarWidget:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    baseClass.Initialize(self, params, errorDepth)
    
    RequireClassIsa("GUIScrollerWidget", params.scrollerWidgetClass, "params.scrollerWidgetClass", errorDepth)
    RequireClassIsa("GUIDirectionalButton", params.directionalButtonClass, "params.directionalButtonClass", errorDepth)
    
    self.scroller = CreateGUIObject("scroller", params.scrollerWidgetClass, self, params)
    self.scroller:AlignCenter()
    
    self.minusButton = CreateGUIObject("minusButton", params.directionalButtonClass, self, params)
    local minusAlignment = Vector(0.5, 0.5, 0) * self:GetMinorAxis()
    self.minusButton:SetHotSpot(minusAlignment)
    self.minusButton:SetAnchor(minusAlignment)
    self.minusButton:Flip() -- point negative direction instead of positive direction
    self:HookEvent(self.minusButton, "OnPressed", OnMinusButtonPressed)
    
    self.plusButton = CreateGUIObject("plusButton", params.directionalButtonClass, self, params)
    local plusAlignment = self:GetMajorAxis() + (Vector(0.5, 0.5, 0) * self:GetMinorAxis())
    self.plusButton:SetHotSpot(plusAlignment)
    self.plusButton:SetAnchor(plusAlignment)
    self:HookEvent(self.plusButton, "OnPressed", OnPlusButtonPressed)
    
    self:ForwardEvent(self.scroller, "OnDragBegin")
    self:ForwardEvent(self.scroller, "OnDrag")
    self:ForwardEvent(self.scroller, "OnDragEnd")
    self:ForwardEvent(self.scroller, "OnJump")
    self:ForwardEvent(self.scroller, "OnValueChanged")
    
    self:HookEvent(self, "OnSizeChanged", UpdateContentsConstraints)
    self:HookEvent(self, "OnButtonGapChanged", UpdateContentsConstraints)
    self:HookEvent(self, "OnOutsidePaddingChanged", UpdateContentsConstraints)
    
    self:HookEvent(self, "OnDrag", UpdateButtonEnabledState)
    self:HookEvent(self, "OnJump", UpdateButtonEnabledState)
    self:HookEvent(self, "OnSizeChanged", UpdateButtonEnabledState)
    self:HookEvent(self, "OnSliderLengthChanged", UpdateButtonEnabledState)
    
end

function GUIScrollBarWidget:Scroll(up)
    local result = self.scroller:Scroll(up)
    return result
end

function GUIScrollBarWidget:GetValue(static)
    local result = self.scroller:GetValue(static)
    return result
end

function GUIScrollBarWidget:GetScrollRange(static)
    local result = self.scroller:GetScrollRange(static)
    return result
end

function GUIScrollBarWidget:ConvertSliderToScroll(value, altSliderMax, altScrollRange)
    local result = self.scroller:ConvertSliderToScroll(value, altSliderMax, altScrollRange)
    return result
end

function GUIScrollBarWidget:ConvertScrollToSlider(value, altSliderMax, altScrollRange)
    local result = self.scroller:ConvertScrollToSlider(value, altSliderMax, altScrollRange)
    return result
end

function GUIScrollBarWidget:SetValue(value, disableAnimation)
    local result = self.scroller:SetValue(value, disableAnimation)
    return result
end
