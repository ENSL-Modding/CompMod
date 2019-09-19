-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/menu2/widgets/GUIMenuSliderEntryWidget.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--    
--    A GUIMenuNumberInputWidget, GUIMenuSliderBarWidget, a label, and a background.
--
--  Params:
--      default
--      minValue
--      maxValue
--      decimalPlaces
--      label
--
--  Properties:
--      Label               -- The label of the widget.
--      Value               -- The value of the widget.
--      MinValue            -- The minimum value that the number entered can have.
--      MaxValue            -- The maximum value that the number entered can have.
--      DecimalPlaces       -- The number of decimal places the number entered can have.  0 means
--                             only integers will be allowed.
--  
--  Events:
--      OnDragBegin         -- The user has clicked on the slider to begin dragging.
--      OnDrag              -- The slider has changed position as a result of the user dragging it.
--      OnDragEnd           -- The user has released the slider to end dragging.
--      OnJump              -- The value of the slider has jumped (eg the user clicked the
--                             background).
--      OnEditBegin         -- The user has started editing the text.
--      OnEditAccepted      -- Editing has ended, with the user accepting the edit.
--      OnEditCancelled     -- Editing has ended, with the user reverting the edit.
--      OnEditEnd           -- Editing has ended.  The text may or may not have changed.
--  
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/GUI/GUIObject.lua")
Script.Load("lua/menu2/widgets/GUIMenuNumberInputWidget.lua")
Script.Load("lua/menu2/widgets/GUIMenuSliderBarWidget.lua")
Script.Load("lua/menu2/GUIMenuBasicBox.lua")
Script.Load("lua/menu2/MenuStyles.lua")
Script.Load("lua/menu2/GUIMenuTruncatedText.lua")

---@class GUIMenuSliderEntryWidget : GUIObject
---@field public GetEditing function @From Editable wrapper
---@field public SetEditing function @From Editable wrapper
---@field protected _BeginEditing function @From Editable wrapper
---@field protected _EndEditing function @From Editable wrapper
local baseClass = GUIObject
baseClass = GetEditableWrappedClass(baseClass)
class "GUIMenuSliderEntryWidget" (baseClass)

local kMaxLabelLength = 475

GUIMenuSliderEntryWidget:AddCompositeClassProperty("Label", "label", "Text")

GUIMenuSliderEntryWidget:AddClassProperty("Value", 0)
GUIMenuSliderEntryWidget:AddCompositeClassProperty("MinValue", "entry")
GUIMenuSliderEntryWidget:AddCompositeClassProperty("MaxValue", "entry")
GUIMenuSliderEntryWidget:AddCompositeClassProperty("DecimalPlaces", "entry")

local function UpdateLayout(self)
    
    local currentX = 0
    
    -- Limit the label size.
    local labelTextSize = self.label:GetTextSize()
    local labelNewWidth = math.min(kMaxLabelLength, labelTextSize.x)
    self.label:SetSize(labelNewWidth, labelTextSize.y)
    currentX = currentX + self.label:GetPosition().x + labelNewWidth
    currentX = currentX + MenuStyle.kLabelSpacing
    
    -- Position the entry.
    self.entry:SetPosition(currentX, 0)
    
    -- Don't use actual width, use estimated max width for stability.  Otherwise, the width would
    -- change as the slider is dragged, causing the slider to be resized, causing the slider value
    -- to change... causing the text to change... causing the slider to be resized... etc.
    currentX = currentX + self.estimatedEntryWidth
    currentX = currentX + MenuStyle.kLabelSpacing -- padding between entry and slider bar.
    
    self.leftSideHolder:SetSize(currentX, self.leftSideHolder:GetSize().y)
    
    local remainingX = self:GetSize().x - currentX
    self.slider:SetPosition(currentX, 0)
    self.slider:SetSize(remainingX, self:GetSize().y)
    
end

local function OnLabelChanged(self)
    
    UpdateLayout(self)
    
end

local function OnEntryValueChanged(self, value, prevValue)
    
    if self.settingEntry then
        -- Entry value change is result of slider change.  Don't set slider from entry.
        return
    end
    
    -- Set value of slider to entry.
    -- Need to remap value of entry to slider's range of values.
    local entryFraction = (value - self:GetMinValue(true)) / (self:GetMaxValue(true) - self:GetMinValue(true))
    local sliderValue = entryFraction * self.slider:GetSliderMaxValue(true)
    
    -- Ensure we don't create an infinite loop due to one item setting the other over and over.
    self.settingSlider = true
    self.settingSelf = true
    self.slider:SetValue(sliderValue)
    self:SetValue(value)
    self.settingSelf = nil
    self.settingSlider = nil
    
    self:FireEvent("OnValueChanged", value, prevValue)
    
end

local function OnSliderValueChanged(self)
    
    if self.settingSlider then
        -- Slider value change is result of entry change.  Don't set entry from slider.
        return
    end
    
    -- Set value of entry to slider.
    -- Need to remap value of slider to range of values accepted by entry.
    local sliderValue = self.slider:GetValue(true)
    local sliderFraction = sliderValue / self.slider:GetSliderMaxValue(true)
    local entryValue = sliderFraction * (self:GetMaxValue() - self:GetMinValue()) + self:GetMinValue()
    entryValue = self.entry:ConstrainValue(entryValue)
    local prevValue = self.entry:GetValue(true)
    
    -- If the widget value didn't actually end up changing (eg mapping of slider values to widget
    -- values is non-injective), just bail out now.
    if prevValue == entryValue then
        return
    end
    
    -- Ensure we don't get stuck in an infinite loop due to one item setting the other over and
    -- over.
    self.settingEntry = true
    self.settingSelf = true
    self.entry:SetEditing(false) -- just in case.
    self.entry:SetValue(entryValue)
    self:SetValue(entryValue)
    self.settingSelf = nil
    self.settingEntry = nil
    
end

local function SetSliderValue(self, value)
    
    local fraction = (value - self:GetMinValue(true)) / (self:GetMaxValue(true) - self:GetMinValue(true))
    local sliderValue = fraction * self.slider:GetSliderMaxValue(true)
    
    self.slider:SetValue(sliderValue)

end

local function OnSizeChanged(self, size, prevSize)
    
    self.back:SetSize(size)
    UpdateLayout(self)
    
    -- Ensure slider goes back to the correct location after a size change.
    if size.x ~= prevSize.x then
        SetSliderValue(self, self:GetValue())
    end
    
end

-- Returns the widest digit.
local function GetWidestDigit(fontName)
    
    local widestDigit
    local widestWidth
    for i=0, 9 do
        local width = GUI.CalculateTextSize(fontName, string.format("%d%d", i, i)).x
        if widestDigit == nil or width > widestWidth then
            widestDigit = i
            widestWidth = width
        end
    end
    
    return widestDigit
    
end

-- Get a good estimate for the widest string that could possibly be displayed.  This is only a very
-- conservative estimate -- not an exhaustive search or proven correctness. (Eg this algorithm
-- assumes that the widest digit for all digits is within the constraints, but it's almost
-- certainly not.
local function EstimateMaxWidth(entry, minValue, maxValue, decimalPlaces)
    
    -- Compute a good maximum width for the numeric entry.
    local widestDigit = GetWidestDigit(entry.displayText:GetFontName())
    local digitsLeftMin = math.max(math.ceil(math.log10(math.abs(minValue)+1)), 1)
    local digitsLeftMax = math.max(math.ceil(math.log10(math.abs(maxValue)+1)), 1)
    local digitsLeft = math.max(digitsLeftMin, digitsLeftMax)
    
    local widestGuess = ""
    
    -- Append minus sign if number can be negative.
    if minValue < 0 or maxValue < 0 then
        widestGuess = "-"
    end
    
    -- Append digits left of decimal place.
    widestGuess = string.format("%s%s", widestGuess, string.rep(tostring(widestDigit), digitsLeft))
    
    -- Add decimal part if applicable.
    if decimalPlaces > 0 then
        widestGuess = string.format("%s.%s", widestGuess, string.rep(widestDigit, decimalPlaces))
    end
    
    -- Return the width of this string.
    local widthEstimate = entry.displayText:CalculateTextSize(widestGuess).x
    
    return widthEstimate
    
end

local function UpdateEstimatedWidth(self)
    
    -- Set the maximum width of the number entry widget to a value that we estimate.
    local estimatedMaxWidth = EstimateMaxWidth(self.entry, self:GetMinValue(), self:GetMaxValue(), self:GetDecimalPlaces()) * self.entry:GetScale().x
    
    self.entry:SetMaxWidth(estimatedMaxWidth)
    
    -- Keep a copy of this value.
    self.estimatedEntryWidth = estimatedMaxWidth
    
    UpdateLayout(self)
    
end

local function EstimateMaxLength(minValue, maxValue, decimalPlaces)
    
    local digitsSum = 0
    
    -- Can number be negative?
    digitsSum = digitsSum + ((minValue < 0) and 1 or 0)
    
    -- Add number of decimal places.
    digitsSum = digitsSum + decimalPlaces
    
    -- Add decimal point.
    digitsSum = digitsSum + ((decimalPlaces > 0) and 1 or 0)
    
    -- Add digits left of decimal point.
    local biggestValue = math.max(math.abs(minValue), math.max(maxValue))
    digitsSum = digitsSum + math.ceil(math.log10(biggestValue+1))
    
    return digitsSum
    
end

local function UpdateEstimatedLength(self)
    
    local estimatedMaxLength = EstimateMaxLength(self:GetMinValue(), self:GetMaxValue(), self:GetDecimalPlaces())
    self.entry:SetMaxCharacterCount(estimatedMaxLength)
    
end

local function UpdateEstimatedWidthAndLength(self)
    
    UpdateEstimatedWidth(self)
    UpdateEstimatedLength(self)
    
end

local function OnDrag(self)
    self.wasDragged = true
    OnSliderValueChanged(self)
end

-- Animate slider into correct position once released.  This is necessary if, for example, only
-- integers are allowed, but the slider has many in-between values..
local function OnDragEnd(self)
    if self.wasDragged then
        self.wasDragged = nil
        local entryValue = self.entry:GetValue()
        local entryFraction = (entryValue - self:GetMinValue(true)) / (self:GetMaxValue(true) - self:GetMinValue(true))
        local sliderValue = entryFraction * self.slider:GetSliderMaxValue(true)
        self.slider:SetValue(sliderValue)
    end
end

local function OnSelfValueChanged(self, value, prevValue)
    
    if self.settingSelf then
        return
    end
    
    self.settingSlider = true
    self.settingEntry = true
    self.entry:SetValue(value)
    SetSliderValue(self, value)
    self.settingSlider = nil
    self.settingEntry = nil
end

local function OnLeftSideHolderMouseRelease(self)
    self:SetEditing(true)
end

function GUIMenuSliderEntryWidget:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    RequireType({"number", "nil"}, params.minValue, "params.minValue", errorDepth)
    RequireType({"number", "nil"}, params.maxValue, "params.maxValue", errorDepth)
    RequireType({"number", "nil"}, params.decimalPlaces, "params.decimalPlaces", errorDepth)
    if params.decimalPlaces and params.decimalPlaces ~= math.floor(params.decimalPlaces) then
        error(string.format("Expected an integer or nil for params.decimalPlaces, got %s instead", params.decimalPlaces), errorDepth)
    end
    RequireType({"string", "nil"}, params.label, "params.label", errorDepth)
    
    baseClass.Initialize(self, params, errorDepth)
    
    self:ListenForCursorInteractions() -- so this widget blocks interactions underneath it.
    
    local leftSideHolderClass = GUIObject
    leftSideHolderClass = GetCursorInteractableWrappedClass(leftSideHolderClass)
    leftSideHolderClass = GetEditableWrappedClass(leftSideHolderClass)
    leftSideHolderClass = GetFXStateWrappedClass(leftSideHolderClass)
    self.leftSideHolder = CreateGUIObject("leftSideHolder", leftSideHolderClass, self,
    {
        editController = self,
    })
    self.leftSideHolder:SetSize(self.leftSideHolder:GetSize().x, MenuStyle.kDefaultWidgetSize.y)
    
    self:HookEvent(self.leftSideHolder, "OnMouseRelease", OnLeftSideHolderMouseRelease)
    
    self.label = CreateGUIObject("label", GUIMenuTruncatedText, self.leftSideHolder,
    {
        cls = GUIMenuText,
    })
    self.label:AlignLeft()
    self.label:SetPosition(MenuStyle.kWidgetPadding, 0)
    self.label:SetFont(MenuStyle.kOptionFont)
    self.leftSideHolder:AddFXReceiver(self.label:GetObject())
    
    self.entry = CreateGUIObject("entry", GUIMenuNumberInputWidget, self.leftSideHolder,
    {
        editController = self,
        cursorController = self.leftSideHolder,
    })
    self.entry:AlignLeft()
    self.entry:SetFont(MenuStyle.kOptionFont)
    self.entry:SetValue(self:GetMinValue())
    
    self.entry:HookEvent(self.leftSideHolder, "OnMouseClick", self.entry.OnMouseClick)
    self.entry:HookEvent(self.leftSideHolder, "OnMouseDrag", self.entry.OnMouseDrag)
    self.entry:HookEvent(self.leftSideHolder, "OnMouseUp", self.entry.OnMouseUp)
    
    self.slider = CreateGUIObject("slider", GUIMenuSliderBarWidget, self,
    {
        orientation = "horizontal",
    })
    self.slider:AlignLeft()
    
    self.back = CreateGUIObject("back", GUIMenuBasicBox, self)
    self.back:SetLayer(-1)
    
    UpdateEstimatedWidth(self) -- calls UpdateLayout(self)
    
    self:HookEvent(self, "OnValueChanged", OnSelfValueChanged)
    
    self:HookEvent(self, "OnLabelChanged", OnLabelChanged)
    self:HookEvent(self.label, "OnTextSizeChanged", OnLabelChanged)
    self:HookEvent(self.entry, "OnValueChanged", OnEntryValueChanged)
    self:HookEvent(self, "OnSizeChanged", OnSizeChanged)
    
    self:HookEvent(self.slider, "OnDragEnd", OnDragEnd)
    self:HookEvent(self.slider, "OnDrag", OnDrag)
    self:HookEvent(self.slider, "OnJump", OnSliderValueChanged)
    
    self:HookEvent(self, "OnMinValueChanged", UpdateEstimatedWidthAndLength)
    self:HookEvent(self, "OnMaxValueChanged", UpdateEstimatedWidthAndLength)
    self:HookEvent(self, "OnDecimalPlacesChanged", UpdateEstimatedWidthAndLength)
    self:HookEvent(self.entry.displayText, "OnInternalFontChanged", UpdateEstimatedWidth)
    self:HookEvent(self.entry.displayText, "OnInternalFontScaleChanged", UpdateEstimatedWidth)
    
    self:ForwardEvent(self.slider, "OnDragBegin")
    self:ForwardEvent(self.slider, "OnDrag")
    self:ForwardEvent(self.slider, "OnDragEnd")
    self:ForwardEvent(self.slider, "OnJump")
    
    self:ForwardEvent(self.entry, "OnEditBegin")
    self:ForwardEvent(self.entry, "OnEditAccepted")
    self:ForwardEvent(self.entry, "OnEditCancelled")
    self:ForwardEvent(self.entry, "OnEditEnd")
    
    self:SetSize(MenuStyle.kDefaultWidgetSize)
    self:SetLabel("LABEL:")
    
    if params.minValue then self:SetMinValue(params.minValue) end
    if params.maxValue then self:SetMaxValue(params.maxValue) end
    if params.decimalPlaces then self:SetDecimalPlaces(params.decimalPlaces) end
    if params.label then self:SetLabel(params.label) end
    if params.default then self:SetValue(params.default) end
    
    -- Ugh... damn sliders resizing and not sticking to the right values... really should have made
    -- sliders store their fractional value, rather than always deriving it...
    self:AddTimedCallback(function()
        SetSliderValue(self, self:GetValue())
    end, 0)
    
end

-- Returns the given value formatted as though it were a value of this widget.
-- Formats the given number with the number of decimal places this widget it set to.  Does not
-- clamp value to range, as it is assumed that the value given was originally a value produced by
-- this widget (Eg a previous value).
function GUIMenuSliderEntryWidget:GetValueString(value)
    local asString = self.entry:GetValueString(value)
    return asString
end

function GUIMenuSliderEntryWidget:_BeginEditing()
    self.entry:_BeginEditing()
end

function GUIMenuSliderEntryWidget:_EndEditing()
    self.entry:_EndEditing()
end

function GUIMenuSliderEntryWidget:GetIsTextInput()
    return true
end
