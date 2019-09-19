-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/menu2/widgets/GUIMenuColorPickerWidget.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Widget to allow users to pick an arbitrary color.
--
--  Parameters (* = required)
--      value
--      label
--
--  Properties:
--      Editing             Whether or not the color is currently being edited (widget open).
--      Value               The color value of the widget.
--      Label               The text that appears in the top left of this widget.
--
--  Events:
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/GUI/wrappers/Editable.lua")
Script.Load("lua/GUI/wrappers/CursorInteractable.lua")
Script.Load("lua/GUI/wrappers/FXState.lua")

Script.Load("lua/menu2/widgets/GUIMenuHSBPicker.lua")
Script.Load("lua/menu2/widgets/GUIMenuSliderWidget.lua")
Script.Load("lua/menu2/GUIMenuTruncatedText.lua")
Script.Load("lua/menu2/GUIMenuText.lua")
Script.Load("lua/menu2/GUIMenuBasicBox.lua")

---@class GUIMenuColorPickerWidget : GUIObject
---@field public GetEditing function @From Editable wrapper
---@field public SetEditing function @From Editable wrapper
---@field protected _BeginEditing function @From Editable wrapper
---@field protected _EndEditing function @From Editable wrapper
---@field public GetMouseOver function @From CursorInteractable wrapper
---@field public GetPressed function @From CursorInteractable wrapper
local baseClass = GUIObject
baseClass = GetEditableWrappedClass(baseClass)
baseClass = GetCursorInteractableWrappedClass(baseClass)
baseClass = GetFXStateWrappedClass(baseClass)
class "GUIMenuColorPickerWidget" (baseClass)

local kMaxLabelLength = 475
local kMinColorDisplayWidth = 64
local kHeaderHeight = MenuStyle.kDefaultWidgetSize.y
local kSpacing = 16

local kSliderHeight = 64

local kRedSliderDefaultColor = HexToColor("850e0e")
local kGreenSliderDefaultColor = HexToColor("0e850e")
local kBlueSliderDefaultColor = HexToColor("0e0e85")

local kRedSliderHighlightColor = HexToColor("ff1c1c")
local kGreenSliderHighlightColor = HexToColor("1cff1c")
local kBlueSliderHighlightColor = HexToColor("1c1cff")

GUIMenuColorPickerWidget:AddCompositeClassProperty("Label", "label", "Text")
GUIMenuColorPickerWidget:AddClassProperty("Value", Color(1, 1, 1, 1))

local function UpdateLabelConstrainedArea(self)
    local labelTextSize = self.label:GetTextSize()
    local labelWidth = math.min(labelTextSize.x, kMaxLabelLength)
    self.label:SetSize(labelWidth, labelTextSize.y)
end

local function UpdateHeaderLayout(self)
    
    local colorDisplayWidth = self:GetSize().x - self.label:GetSize().x - MenuStyle.kWidgetPadding*3
    colorDisplayWidth = math.max(colorDisplayWidth, kMinColorDisplayWidth)
    self.valueDisplay:SetWidth(colorDisplayWidth)
    
end

local function UpdateSliderWidths(self)
    local width = self:GetSize().x - MenuStyle.kWidgetPadding*2
    self.redSlider:SetWidth(width)
    self.greenSlider:SetWidth(width)
    self.blueSlider:SetWidth(width)
end

local function UpdateSubWidgetsFromValue(self)
    
    if not self.settingColorFromHSB then
        
        self.settingColorFromHSB = true
        local hue, sat, val = RGBToHSV(self:GetValue())
        if sat > 0 and val > 0 then -- otherwise, hue is undefined.
            self.hsbPicker:SetHue(hue)
        end
        if val > 0 then -- otherwise, saturation is undefined.
            self.hsbPicker:SetSaturation(sat)
        end
        self.hsbPicker:SetBrightness(val)
        self.settingColorFromHSB = nil
        
    end
    
    if not self.settingColorFromSliders then
        
        self.settingColorFromSliders = true
        local color = self:GetValue()
        self.redSlider:SetValue(self.redSlider:GetSliderMaxValue() * color.r)
        self.greenSlider:SetValue(self.redSlider:GetSliderMaxValue() * color.g)
        self.blueSlider:SetValue(self.redSlider:GetSliderMaxValue() * color.b)
        self.settingColorFromSliders = nil
        
    end

end

local function UpdateColorFromHSB(self)
    
    if self.settingColorFromHSB then
        return -- avoid splashback (eg change color, which changes HSB... which then changes color...)
    end
    
    local hue = self.hsbPicker:GetHue()
    local sat = self.hsbPicker:GetSaturation()
    local val = self.hsbPicker:GetBrightness()
    local colorFromHSB = HSVToRGB(hue, sat, val)
    
    self.settingColorFromHSB = true
    self:SetValue(colorFromHSB)
    self.settingColorFromHSB = nil
    
end

local function UpdateColorFromSliders(self)
    
    if self.settingColorFromSliders then
        return -- avoid splashback
    end
    
    local r = self.redSlider:GetValue(true)   / math.max(1, self.redSlider:GetSliderMaxValue(true))
    local g = self.greenSlider:GetValue(true) / math.max(1, self.greenSlider:GetSliderMaxValue(true))
    local b = self.blueSlider:GetValue(true)  / math.max(1, self.blueSlider:GetSliderMaxValue(true))
    
    self.settingColorFromSliders = true
    self:SetValue(Color(r, g, b, 1))
    self.settingColorFromSliders = nil
    
end

function GUIMenuColorPickerWidget:_BeginEditing()
    self.contents:AllowChildInteractions()
    self:AnimateProperty("Size", self.layout:GetSize(), MenuAnimations.FlyIn)
    self:ListenForKeyInteractions()
end

function GUIMenuColorPickerWidget:_EndEditing()
    self.contents:BlockChildInteractions()
    self:AnimateProperty("Size", self.header:GetSize(), MenuAnimations.FlyIn)
    self:StopListeningForKeyInteractions()
end

function GUIMenuColorPickerWidget:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    RequireType({"Color", "nil"}, params.value, "params.value", errorDepth)
    RequireType({"string", "nil"}, params.label, "params.label", errorDepth)
    
    PushParamChange(params, "size", MenuStyle.kDefaultWidgetSize)
    baseClass.Initialize(self, params, errorDepth)
    PopParamChange(params, "size")
    
    -- Layout holds two objects: header and contents.  Contents is the bit that expands/contracts
    -- with editing mode.
    self.layout = CreateGUIObject("layout", GUIListLayout, self,
    {
        orientation = "vertical",
        fixedMinorSize = true,
    })
    self:HookEvent(self.layout, "OnSizeChanged", self.SetHeight)
    self.layout:HookEvent(self, "OnSizeChanged", self.layout.SetWidth)
    
    self.header = CreateGUIObject("header", GUIObject, self.layout)
    self.header:SetHeight(kHeaderHeight)
    self.header:HookEvent(self.layout, "OnSizeChanged", self.header.SetWidth)
    
    -- Label for this widget.
    self.label = CreateGUIObject("label", GUIMenuTruncatedText, self.header,
    {
        cls = GUIMenuText,
    })
    self.label:AlignLeft()
    self.label:SetPosition(MenuStyle.kWidgetPadding, 0)
    self.label:SetText("LABEL")
    self.label:SetColor(MenuStyle.kLightGrey)
    self.label:SetFont(MenuStyle.kOptionFont)
    self.label:SetSize(kMaxLabelLength, kHeaderHeight)
    self:AddFXReceiver(self.label:GetObject())
    
    self.valueDisplay = CreateGUIObject("valueDisplay", GUIMenuBasicBox, self.header)
    self.valueDisplay:SetX(-MenuStyle.kWidgetPadding)
    self.valueDisplay:AlignRight()
    self.valueDisplay:SetHeight(kHeaderHeight - MenuStyle.kWidgetPadding*2)
    self.valueDisplay:HookEvent(self, "OnValueChanged", self.valueDisplay.SetFillColor)
    
    -- Update the size of the label.
    self:HookEvent(self.label, "OnTextSizeChanged", UpdateLabelConstrainedArea)
    self:HookEvent(self, "OnSizeChanged", UpdateHeaderLayout)
    self:HookEvent(self.label, "OnSizeChanged", UpdateHeaderLayout)
    UpdateHeaderLayout(self)
    
    self.contents = CreateGUIObject("contents", GetExpandableWrappedClass(GUIObject), self.layout)
    self.contents:HookEvent(self, "OnEditingChanged", self.contents.SetExpanded)
    self.contents:BlockChildInteractions()
    self.contents:SetExpanded(false)
    self.contents:ClearPropertyAnimations("Expansion")
    self.contents:AlignTop()
    
    self.contentsLayout = CreateGUIObject("contentsLayout", GUIListLayout, self.contents,
    {
        orientation = "vertical",
        spacing = kSpacing,
        frontPadding = kSpacing,
        backPadding = kSpacing,
    })
    self.contentsLayout:AlignTop()
    self.contents:HookEvent(self.contentsLayout, "OnSizeChanged", self.contents.SetSize)
    
    self.hsbPicker = CreateGUIObject("hsbPicker", GUIMenuHSBPicker, self.contentsLayout)
    self.hsbPicker:AlignTop()
    self:HookEvent(self.hsbPicker, "OnHueChanged", UpdateColorFromHSB)
    self:HookEvent(self.hsbPicker, "OnSaturationChanged", UpdateColorFromHSB)
    self:HookEvent(self.hsbPicker, "OnBrightnessChanged", UpdateColorFromHSB)
    
    self.redSlider = CreateGUIObject("redSlider", GUIMenuSliderBarWidget, self.contentsLayout,
    {
        orientation = "horizontal",
        defaultColor = kRedSliderDefaultColor,
        highlightColor = kRedSliderHighlightColor,
    })
    self.redSlider:AlignTop()
    
    self.greenSlider = CreateGUIObject("greenSlider", GUIMenuSliderBarWidget, self.contentsLayout,
    {
        orientation = "horizontal",
        defaultColor = kGreenSliderDefaultColor,
        highlightColor = kGreenSliderHighlightColor,
    })
    self.greenSlider:AlignTop()
    
    self.blueSlider = CreateGUIObject("blueSlider", GUIMenuSliderBarWidget, self.contentsLayout,
    {
        orientation = "horizontal",
        defaultColor = kBlueSliderDefaultColor,
        highlightColor = kBlueSliderHighlightColor,
    })
    self.blueSlider:AlignTop()
    
    self.redSlider:SetHeight(kSliderHeight)
    self.greenSlider:SetHeight(kSliderHeight)
    self.blueSlider:SetHeight(kSliderHeight)
    
    self:HookEvent(self.redSlider, "OnValueChanged", UpdateColorFromSliders)
    self:HookEvent(self.greenSlider, "OnValueChanged", UpdateColorFromSliders)
    self:HookEvent(self.blueSlider, "OnValueChanged", UpdateColorFromSliders)
    
    self:HookEvent(self, "OnSizeChanged", UpdateSliderWidths)
    UpdateSliderWidths(self)
    
    self:HookEvent(self, "OnValueChanged", UpdateSubWidgetsFromValue)
    
    self.back = CreateGUIObject("back", GUIMenuBasicBox, self)
    self.back:HookEvent(self, "OnSizeChanged", self.back.SetSize)
    self.back:SetSize(self:GetSize())
    self.back:SetLayer(-10)
    
    if params.label then
        self:SetLabel(params.label)
    end
    
    if params.value then
        self:SetValue(params.value)
    end
    UpdateSubWidgetsFromValue(self)
    
end

function GUIMenuColorPickerWidget:OnMouseClick()
    
    if self:GetEditing() then
        -- If it's already open, and we clicked on the header, close it.
        local mousePos = GetGlobalEventDispatcher():GetMousePosition()
        if self.header.rootItem:GetIsPointOverItem(mousePos) then
            self:SetEditing(false)
            return true
        end
    
        -- Do nothing further if it is open, but not clicked over header.
        return true
    end
    
    self:SetEditing(true)

end

function GUIMenuColorPickerWidget:OnKey(key, down)
    
    if self:GetEditing() and key == InputKey.Escape then
        self:SetEditing(false)
        return true
    end
    
    return false

end

-- Returns the given value formatted as though it were a value of this widget.
function GUIMenuColorPickerWidget:GetValueString(value)
    return (string.format("%.2f, %.2f, %.2f", value.r, value.g, value.b))
end
