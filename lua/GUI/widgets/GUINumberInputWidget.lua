-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/GUI/widgets/GUINumberInputWidget.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    A GUITextInputWidget that only accepts numbers.
--
--  Properties:
--      MaxCharacterCount       The maximum number of characters (unicode characters to be precise)
--                              allowed in the string. <=0 for unlimited.
--      MaxWidth                The maximum width of the text, in local space pixels. <=0 for
--                              unlimited.
--      Editing                 Whether or not the user is entering text for this object.
--      IsPassword              Whether or not the text of this object should be censored.
--      CursorIndex             The index of the character to the right of the cursor.  Valid range
--                              is 1..N+1, where N is the number of unicode characters.
--      SelectionSize           The number of unicode characters to the right of the cursor index
--                              that are selected.
--      MinValue                The minimum value that the number entered can have.
--      MaxValue                The maximum value that the number entered can have.
--      DecimalPlaces           The number of decimal places the number entered can have.  0 means
--                              only integers will be allowed.
--  
--  Events:
--      OnEditBegin             The user has started editing the text.
--      OnCharacterAccepted     The user has added a character while editing.
--          character               Character that was added.
--      OnCharacterDeleted      The user has deleted a character while editing.
--      OnEditAccepted          Editing has ended, with the user accepting the edit.
--      OnEditCancelled         Editing has ended, with the user reverting the edit.
--      OnEditEnd               Editing has ended.  The text may or may not have changed.
--      OnValueChanged          The value of the text has changed.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/widgets/GUITextInputWidget.lua")

---@class GUINumberInputWidget : GUITextInputWidget
class "GUINumberInputWidget" (GUITextInputWidget)

GUINumberInputWidget:AddClassProperty("MinValue", 0)
GUINumberInputWidget:AddClassProperty("MaxValue", 100)
GUINumberInputWidget:AddClassProperty("DecimalPlaces", 1)

local UTF8FromString = string.UTF8Encode

local kAllowedCharacters =
{
    ["0"] = true,
    ["1"] = true,
    ["2"] = true,
    ["3"] = true,
    ["4"] = true,
    ["5"] = true,
    ["6"] = true,
    ["7"] = true,
    ["8"] = true,
    ["9"] = true,
    ["."] = true,
    ["-"] = true,
}

local function OnConstraintsChanged(self)
    
    if not self:GetEditing() then
        self.utf8Array = UTF8FromString(self:GetText())
    end
    
    self.utf8Array = self:CleanupAndConstrainUTF8(self.utf8Array)
    self:UpdateValueFromUTF8(self.utf8Array)
    
    if not self:GetEditing() then
        self.utf8Array = nil
    end
    
end

function GUINumberInputWidget:GetValueAsString()
    local value = self:GetValue()
    local asString = tostring(value)
    
    return asString
end

function GUINumberInputWidget:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    GUITextInputWidget.Initialize(self, params, errorDepth)
    
    self:SetValue(0) -- initialize to zero.
    
    self:HookEvent(self, "OnMinValueChanged", OnConstraintsChanged)
    self:HookEvent(self, "OnMaxValueChanged", OnConstraintsChanged)
    self:HookEvent(self, "OnDecimalPlacesChanged", OnConstraintsChanged)
    
end

-- Override to force this value to always be a number.
function GUINumberInputWidget:UpdateValueFromUTF8(utf8)
    
    local value = StringFromUTF8(utf8)
    value = tonumber(value) or 0
    
    self:SetValue(value)
    
end

function GUINumberInputWidget:GetIsValidCharacter(character)
    
    assert(self:GetEditing())
    assert(self.utf8Array ~= nil)
    
    if not GUITextInputWidget.GetIsValidCharacter(self, character) then
        return false
    end
    
    -- Character must be either a number, a decimal point, or a minus sign.
    return kAllowedCharacters[character] ~= nil
    
end

function GUINumberInputWidget:CleanupAndConstrainUTF8(utf8)
    
    utf8 = GUITextInputWidget.CleanupAndConstrainUTF8(self, utf8)
    
    -- Clean up the number, make it as valid as we can hope for.  The user might have entered
    -- multiple minus signs, or minus signs in the wrong place, or extra decimal places, or decimal
    -- digits when the output is restricted to integers only.
    
    -- Discard characters not in the allowed set.  Shouldn't be able to happen, but just in case.
    for i=#utf8, 1, -1 do
        if not kAllowedCharacters[utf8[i]] then
            table.remove(utf8, i)
        end
    end
    
    -- Discard minus signs not at index 1.
    for i=#utf8, 2, -1 do
        if utf8[i] == "-" then
            table.remove(utf8, i)
        end
    end
    
    -- Find the first decimal point location.
    local decimalPointIndex = nil
    for i=1, #utf8 do
        if utf8[i] == "." then
            decimalPointIndex = i
            break
        end
    end
    
    -- Discard extra decimal points.
    if decimalPointIndex then
        for i=#utf8, decimalPointIndex + 1, -1 do
            if utf8[i] == "." then
                table.remove(utf8, i)
            end
        end
        
        -- Drop decimal digits past the precision limit.
        for i=#utf8, decimalPointIndex + self:GetDecimalPlaces() + 1, -1 do
            table.remove(utf8, i)
        end
        
        -- Remove decimal point if no decimal places are allowed.
        if self:GetDecimalPlaces() == 0 then
            assert(decimalPointIndex == #utf8)
            table.remove(utf8, decimalPointIndex)
        end
        
    end
    
    -- Convert to a regular string, and then to a number.
    local str = StringFromUTF8(utf8)
    local number = tonumber(str)
    number = number or 0 -- just in case it's somehow invalid and won't convert to a number.
    
    -- Constrain the number to the minimum and maximum values, if possible.
    if self:GetMinValue() <= self:GetMaxValue() then
        number = Clamp(number, self:GetMinValue(), self:GetMaxValue())
    end
    
    str = string.format(string.format("%%.%df", self:GetDecimalPlaces()), number)
    local result = UTF8FromString(str)
    return result
    
end

local old_SetValue = GUINumberInputWidget.SetValue
function GUINumberInputWidget:SetValue(value)
    
    -- Constrain the value to the minimum and maximum values.
    local constrainedValue = Clamp(value, self:GetMinValue(), self:GetMaxValue())
    local asText = string.format(string.format("%%.%df", self:GetDecimalPlaces()), constrainedValue)
    
    local result = old_SetValue(self, tonumber(asText))
    return result
    
end

-- Apply constraints of this object to some other value -- useful for collaboration between widgets
-- (eg slider constraining its value according to this widget).
function GUINumberInputWidget:ConstrainValue(value)
    local constrainedValue = Clamp(value, self:GetMinValue(), self:GetMaxValue())
    local asText = string.format(string.format("%%.%df", self:GetDecimalPlaces()), constrainedValue)
    local result = tonumber(asText)
    return result
end

-- Returns the given value formatted as though it were a value of this widget.
-- Formats the given number with the number of decimal places this widget it set to.  Does not
-- clamp value to range, as it is assumed that the value given was originally a value produced by
-- this widget (Eg a previous value).
function GUINumberInputWidget:GetValueString(value)
    local result = string.format(string.format("%%.%df", self:GetDecimalPlaces()), value)
    return result
end
