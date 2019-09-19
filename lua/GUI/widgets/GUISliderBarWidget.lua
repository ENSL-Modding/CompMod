-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/GUI/widgets/GUISliderBarWidget.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    A GUIObject that contains a GUISliderWidget and two GUIDirectionalButton objects.
--  Parameters (* = required)
--      sliderWidgetClass           Class to use for the slider.
--      directionalButtonClass      Class to use for both buttons.
--     *orientation                 The orientation of the slider bar.  Must be either "horizontal"
--                                  or "vertical".
--  
--  Properties:
--      BeingDragged        Whether or not the GUIDraggable held within this object is being dragged.
--      SliderLength        Length of the slider object along its major axis.  The slider object
--                          fills the available space along the minor axis.
--      ButtonGap           Amount of spacing to add between the buttons and the slider.
--      OutsidePadding      How much padding to add around the outside.
--  
--  Events:
--      OnDragBegin         The user has clicked on the slider to begin dragging.
--      OnDrag              The slider has changed position as a result of the user dragging it.
--      OnDragEnd           The user has released the slider to end dragging.
--      OnJump              The value of the slider has jumped (eg the user clicked the
--                          background).
--      OnValueChanged      The slider bar has moved some amount, regardless of user interaction.
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/GUI/GUIObject.lua")
Script.Load("lua/GUI/widgets/GUISliderWidget.lua")

Script.Load("lua/GUI/wrappers/Oriented.lua")

---@class GUISliderBarWidget : GUIObject
---@field public GetMajorAxis function @From Oriented wrapper
---@field public GetMinorAxis function @From Oriented wrapper
---@field public GetOrientation function @From Oriented wrapper
local baseClass = GUIObject
baseClass = GetOrientedWrappedClass(baseClass)
class "GUISliderBarWidget" (baseClass)

local kButtonJumpFraction = 0.2
local kDefaultGap = 8
local kDefaultOutsidePadding = 8

GUISliderBarWidget:AddCompositeClassProperty("SliderLength", "slider")
GUISliderBarWidget:AddCompositeClassProperty("BeingDragged", "slider")
GUISliderBarWidget:AddClassProperty("ButtonGap", kDefaultGap)
GUISliderBarWidget:AddClassProperty("OutsidePadding", kDefaultOutsidePadding)

local function OnMinusButtonPressed(self)
    self:JumpFraction(-kButtonJumpFraction)
end

local function OnPlusButtonPressed(self)
    self:JumpFraction(kButtonJumpFraction)
end

local function UpdateContentsConstraints(self)
    
    -- Don't resize the buttons.  Scale them to fit the height of the slider.
    local minor = Dot2D(self:GetMinorAxis(), self:GetSize(true)) - self:GetOutsidePadding(true) * 2
    local buttonSize = self.minusButton:GetSize(true) -- assume both buttons are same size.
    local buttonMinor = Dot2D(self:GetMinorAxis(), buttonSize)
    local scaleFactor = minor / buttonMinor
    local buttonMajor = Dot2D(self:GetMajorAxis(), buttonSize) * scaleFactor
    
    self.minusButton:SetScale(scaleFactor, scaleFactor)
    self.plusButton:SetScale(scaleFactor, scaleFactor)
    
    local major = Dot2D(self:GetMajorAxis(), self:GetSize(true))
    local sliderMajor = major - (buttonMajor * 2) - (self:GetButtonGap(true) * 2) - (self:GetOutsidePadding(true) * 2)
    self.slider:SetSize(self:GetMajorAxis() * sliderMajor + self:GetMinorAxis() * minor)
    
    self.minusButton:SetPosition(self:GetMajorAxis() * self:GetOutsidePadding(true))
    self.plusButton:SetPosition(self:GetMajorAxis() * -self:GetOutsidePadding(true))
    
end

local function UpdateButtonEnabledState(self)
    
    self.minusButton:SetEnabled(self:GetValue(true) >= 0.5)
    self.plusButton:SetEnabled(self:GetSliderMaxValue(true) - self:GetValue(true) >= 0.5)
    
end

function GUISliderBarWidget:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    baseClass.Initialize(self, params, errorDepth)
    
    RequireClassIsa("GUISliderWidget", params.sliderWidgetClass, "params.sliderWidgetClass", errorDepth)
    RequireClassIsa("GUIDirectionalButton", params.directionalButtonClass, "params.directionalButtonClass", errorDepth)
    
    self.slider = CreateGUIObject("slider", params.sliderWidgetClass, self, params)
    self.slider:AlignCenter()
    
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
    
    self:ForwardEvent(self.slider, "OnDragBegin")
    self:ForwardEvent(self.slider, "OnDrag")
    self:ForwardEvent(self.slider, "OnDragEnd")
    self:ForwardEvent(self.slider, "OnJump")
    self:ForwardEvent(self.slider, "OnValueChanged")
    
    self:HookEvent(self, "OnSizeChanged", UpdateContentsConstraints)
    self:HookEvent(self, "OnButtonGapChanged", UpdateContentsConstraints)
    self:HookEvent(self, "OnOutsidePaddingChanged", UpdateContentsConstraints)
    
    self:HookEvent(self, "OnDrag", UpdateButtonEnabledState)
    self:HookEvent(self, "OnJump", UpdateButtonEnabledState)
    self:HookEvent(self, "OnSizeChanged", UpdateButtonEnabledState)
    self:HookEvent(self, "OnSliderLengthChanged", UpdateButtonEnabledState)
    
end

function GUISliderBarWidget:Jump(amount)
    local result = self.slider:Jump(amount)
    return result
end

function GUISliderBarWidget:JumpFraction(fraction)
    local result = self.slider:JumpFraction(fraction)
    return result
end

function GUISliderBarWidget:GetSliderMaxValue(static)
    local result = self.slider:GetSliderMaxValue(static)
    return result
end

function GUISliderBarWidget:GetValue(static)
    local result = self.slider:GetValue(static)
    return result
end

function GUISliderBarWidget:SetValue(value, disableAnimation)
    local result = self.slider:SetValue(value, disableAnimation)
    UpdateButtonEnabledState(self)
    return result
end
