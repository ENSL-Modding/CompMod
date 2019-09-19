-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/NavBar/Screens/ServerBrowser/FilterWindow/GMSBFWSliderWidget.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Slider widget themed for the server browser's filter window.
--  
--  Properties
--      Label           Text displayed in the label for this widget.
--      Value           Value of this widget.
--      MinimumValue    Value of the slider when all the way to the left.
--      MaximumValue    Value of the slider when all the way to the right.
--      DecimalPlaces   Number of decimal places to display in the output.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/menu2/widgets/GUIMenuSliderWidget.lua")
Script.Load("lua/GUI/GUIText.lua")
Script.Load("lua/menu2/NavBar/Screens/ServerBrowser/FilterWindow/GMSBFWSliderDraggable.lua")

---@class GMSBFWSliderWidget : GUIObject
class "GMSBFWSliderWidget" (GUIObject)

local kFont = MenuStyle.kServerBrowserFiltersWindowFont
local kLabelColor = MenuStyle.kOptionHeadingColor

local kSliderBoxHeight = 62
local kDraggerWidth = 40
local kSidesPadding = 5

local kSpacing = 5

GMSBFWSliderWidget:AddCompositeClassProperty("Label", "label", "Text")
GMSBFWSliderWidget:AddClassProperty("Value", 0)
GMSBFWSliderWidget:AddClassProperty("MinimumValue", 0)
GMSBFWSliderWidget:AddClassProperty("MaximumValue", 100)
GMSBFWSliderWidget:AddClassProperty("DecimalPlaces", 0)

GMSBFWSliderWidget.NoOverride = ReadOnly{"NoOverride"}
GMSBFWSliderWidget:AddClassProperty("ValueDisplayOverride", GMSBFWSliderWidget.NoOverride, true)

local function ValueToString(self, value)
    
    local result = string.format(string.format("%%.%df", self:GetDecimalPlaces()), value)
    return result
    
end

local function ReConstrainValue(self)
    
    local value = self:GetValue()
    local minValue = self:GetMinimumValue()
    local maxValue = self:GetMaximumValue()
    
    value = math.min(maxValue, value)
    value = math.max(minValue, value)
    value = tonumber(ValueToString(self, value))
    
    self:SetValue(value)
    
end

local function SliderToWidget(self, sliderValue)
    
    local sliderFraction = sliderValue / self.slider:GetSliderMaxValue(true)
    
    local minValue = self:GetMinimumValue()
    local maxValue = self:GetMaximumValue()
    local range = maxValue - minValue
    local value = sliderFraction * range + minValue
    
    return value
    
end

local function WidgetToSlider(self, value)
    
    local minValue = self:GetMinimumValue()
    local maxValue = self:GetMaximumValue()
    local range = maxValue - minValue
    
    local fraction = 0
    if range ~= 0 then
        fraction = (value - minValue) / range
    end
    
    local sliderValue = fraction * self.slider:GetSliderMaxValue(true)
    
    return sliderValue
    
end

local function UpdateSliderPositionFromValue(self)
    
    local sliderValue = WidgetToSlider(self, self:GetValue())
    self.slider:SetValue(sliderValue)
    
end

local function UpdateDisplayedValue(self)
    
    local override = self:GetValueDisplayOverride()
    
    if override == GMSBFWSliderWidget.NoOverride then
        self.valueDisplay:SetText(ValueToString(self, self:GetValue(true)))
    else
        self.valueDisplay:SetText(override)
    end
    
end

local function OnValueDisplayOverrideChanged(self, override, prevOverride)
    
    UpdateDisplayedValue(self)
    
end

local function OnValueChanged(self, value, prevValue)
    
    if not self.slider:GetBeingDragged() then
        ReConstrainValue(self)
        UpdateSliderPositionFromValue(self)
    end
    
    UpdateDisplayedValue(self)
    
end

local function OnConstraintsChanged(self)
    
    -- Re-constrain the value.
    ReConstrainValue(self, value)
    
    -- Update the slider's position to reflect the new constraints.
    UpdateSliderPositionFromValue(self)
    
end

local function OnSliderValueChanged(self)
    
    local value = SliderToWidget(self, self.slider:GetValue(true))
    
    self:SetValue(value)
    
end

local function OnSliderDragEnd(self)
    
    local value = SliderToWidget(self, self.slider:GetValue(true))
    self:SetValue(value)
    ReConstrainValue(self)
    
end

local function OnSizeChanged(self, size)
    
    -- Update items' widths.
    self.topItems:SetSize(size.x, self.topItems:GetSize().y)
    self.sliderBox:SetSize(size.x, self.sliderBox:GetSize().y)
    self.slider:SetSize(size.x - kSidesPadding * 2, self.slider:GetSize().y)
    
    UpdateSliderPositionFromValue(self)
    
end

function GMSBFWSliderWidget:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    RequireType({"string", "nil"}, params.label, "params.label", errorDepth)
    RequireType({"number", "nil"}, params.minimum, "params.minimum", errorDepth)
    RequireType({"number", "nil"}, params.maximum, "params.maximum", errorDepth)
    RequireType({"number", "nil"}, params.default, "params.default", errorDepth)
    
    GUIObject.Initialize(self, params, errorDepth)
    
    self.layout = CreateGUIObject("layout", GUIListLayout, self, {orientation="vertical"})
    self.layout:SetSpacing(kSpacing)
    
    self.topItems = CreateGUIObject("topItems", GUIObject, self.layout)
    
    self.label = CreateGUIObject("label", GUIText, self.topItems)
    self.label:AlignLeft()
    self.label:SetFont(kFont)
    self.label:SetColor(kLabelColor)
    self.label:SetText("LABEL")
    
    self.valueDisplay = CreateGUIObject("valueDisplay", GUIText, self.topItems)
    self.valueDisplay:AlignRight()
    self.valueDisplay:SetFont(kFont)
    self.valueDisplay:SetColor(kLabelColor)
    
    self.topItems:SetSize(self.topItems:GetSize().x, math.max(self.label:GetSize().y, self.valueDisplay:GetSize().y))
    
    self.sliderBox = CreateGUIObject("sliderBox", GUIMenuBasicBox, self.layout)
    self.sliderBox:SetSize(self.sliderBox:GetSize().x, kSliderBoxHeight)
    
    self.slider = CreateGUIObject("slider", GUIMenuSliderWidget, self.sliderBox,
    {
        orientation = "horizontal",
        draggableClass = GMSBFWSliderDraggable,
    })
    self.slider:AlignCenter()
    self.slider:SetSize(self.slider:GetSize().x, kSliderBoxHeight - kSidesPadding * 2)
    self.slider:SetSliderLength(kDraggerWidth)
    
    self:HookEvent(self.slider, "OnDrag", OnSliderValueChanged)
    self:HookEvent(self.slider, "OnDragEnd", OnSliderDragEnd)
    self:HookEvent(self.slider, "OnJump", OnSliderValueChanged)
    
    self:HookEvent(self, "OnSizeChanged", OnSizeChanged)
    
    self:HookEvent(self, "OnMinimumValueChanged", OnConstraintsChanged)
    self:HookEvent(self, "OnMaximumValueChanged", OnConstraintsChanged)
    self:HookEvent(self, "OnDecimalPlacesChanged", OnConstraintsChanged)
    self:HookEvent(self, "OnValueChanged", OnValueChanged)
    self:HookEvent(self, "OnValueDisplayOverrideChanged", OnValueDisplayOverrideChanged)
    
    self:SetSize(self:GetSize().x, self.layout:GetSize().y)
    
    if params.label then
        self:SetLabel(params.label)
    end
    
    if params.minimum then
        self:SetMinimumValue(params.minimum)
    end
    
    if params.maximum then
        self:SetMaximumValue(params.maximum)
    end
    
    if params.default then
        self:SetValue(params.default)
    end
    
end
