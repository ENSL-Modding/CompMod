-- ======= Copyright (c) 2017, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/widgets/GUIMenuTextEntryWidget.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    GUIMenuTextInputWidget that has a background and a label -- suitable for being used in the
--    options menu.
--
--  Params:
--      default
--      label
--      minVal
--      maxVal
--      decimalPlaces
--      maxCharacterCount
--
--  Properties:
--      MaxCharacterCount   -- The maximum number of characters (unicode characters to be precise)
--                             allowed in the string. <=0 for unlimited.
--      MaxWidth            -- The maximum width of the text, in local space pixels. <=0 for
--                             unlimited.
--      Editing             -- Whether or not the user is entering text for this object.
--      IsPassword          -- Whether or not the text of this object should be censored.
--      Label               -- Label text to display.
--      (number only)
--      MinValue            -- The minimum value that the number entered can have.
--      MaxValue            -- The maximum value that the number entered can have.
--      DecimalPlaces       -- The number of decimal places the number entered can have.  0 means
--                             only integers will be allowed.
--      Value               -- The text value of this widget.
--  
--  Events:
--      OnEditBegin         -- The user has started editing the text.
--      OnCharacterAccepted -- The user has added a character while editing.
--          character           -- Character that was added.
--      OnCharacterDeleted  -- The user has deleted a character while editing.
--      OnEditAccepted      -- Editing has ended, with the user accepting the edit.
--      OnEditCancelled     -- Editing has ended, with the user reverting the edit.
--      OnEditEnd           -- Editing has ended.  The text may or may not have changed.
--      OnValueChanged      -- The value of the text has changed.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/menu2/widgets/GUIMenuTextInputWidget.lua")
Script.Load("lua/menu2/widgets/GUIMenuNumberInputWidget.lua")
Script.Load("lua/menu2/GUIMenuBasicBox.lua")
Script.Load("lua/menu2/MenuStyles.lua")
Script.Load("lua/menu2/widgets/GUIMenuTruncatedDisplayWidget.lua")
Script.Load("lua/menu2/GUIMenuTruncatedText.lua")
Script.Load("lua/GUI/wrappers/CursorInteractable.lua")
Script.Load("lua/GUI/wrappers/Editable.lua")

---@class GUIMenuTextEntryWidget : GUIObject
---@field public GetEditing function @From Editable wrapper
---@field public SetEditing function @From Editable wrapper
---@field protected _BeginEditing function @From Editable wrapper
---@field protected _EndEditing function @From Editable wrapper
---@field public GetMouseOver function @From CursorInteractable wrapper
---@field public GetPressed function @From CursorInteractable wrapper
---@field public GetFXState function @From FXState wrapper
---@field public UpdateFXStateOverride function @From FXState wrapper
---@field public AddFXReceiver function @From FXState wrapper
---@field public RemoveFXReceiver function @From FXState wrapper
local baseClass = GUIObject
baseClass = GetEditableWrappedClass(baseClass)
baseClass = GetCursorInteractableWrappedClass(baseClass)
baseClass = GetFXStateWrappedClass(baseClass)

class "GUIMenuTextEntryWidget" (baseClass)
class "GUIMenuNumberEntryWidget" (baseClass)

local function AddCompositeClassProperty(p1, p2, p3)
    GUIMenuTextEntryWidget:AddCompositeClassProperty(p1, p2, p3)
    GUIMenuNumberEntryWidget:AddCompositeClassProperty(p1, p2, p3)
end

-- Defines a method for both GUIMenuTextEntryWidget and GUIMenuNumberEntryWidget.
local function DefineMethod(name, method)
    GUIMenuTextEntryWidget[name] = method
    GUIMenuNumberEntryWidget[name] = method
end

local kMaxLabelLength = 475

AddCompositeClassProperty("Label", "label", "Text")
AddCompositeClassProperty("Value", "entry", "Value")
AddCompositeClassProperty("MaxCharacterCount", "entry")
AddCompositeClassProperty("MaxWidth", "entry")
AddCompositeClassProperty("IsPassword", "entry")

GUIMenuNumberEntryWidget:AddCompositeClassProperty("MinValue", "entry")
GUIMenuNumberEntryWidget:AddCompositeClassProperty("MaxValue", "entry")
GUIMenuNumberEntryWidget:AddCompositeClassProperty("DecimalPlaces", "entry")

local kManualScrollTolerance = 20

local function SetEntryText(self)
    self.entry:SetText(self:GetText())
end

local function UpdateEntryHolderSize(self)
    
    self.entryHolder:SetSize(self:GetSize().x - (self.label:GetSize().x * self.label:GetScale().x + MenuStyle.kLabelSpacing + MenuStyle.kWidgetPadding * 2), self:GetSize().y)
    
end

local function OnSizeChanged(self)
    
    -- Sync the background size to the widget's size.
    self.back:SetSize(self:GetSize())
    
    -- Compute the size of the area that can be occupied by the entry holder.
    UpdateEntryHolderSize(self)
    
end

local function OnLabelChanged(self)
    
    UpdateEntryHolderSize(self)
    
end

local function UpdateManualScrolling(self)
    
    if not self:GetEditing() then
        return
    end
    
    local scrollWindowMin = self.entryHolder:GetScroll()
    local scrollWindowMax = scrollWindowMin + self.entryHolder:GetSize().x
    local cursorX = self.entry:GetCursorPosition(true).x * self.entry:GetScale(true).x
    local maxScroll = self.entryHolder:GetMaxScroll()
    
    if maxScroll == 0 then
        
        self.entryHolder:AnimateProperty("Scroll", 0, MenuAnimations.FlyIn)
        
    elseif cursorX > scrollWindowMax - kManualScrollTolerance then
        
        self.entryHolder:AnimateProperty("Scroll", math.max(cursorX - self.entryHolder:GetSize().x + kManualScrollTolerance, 0), MenuAnimations.FlyIn)
        
    elseif cursorX < scrollWindowMin + kManualScrollTolerance then
        
        self.entryHolder:AnimateProperty("Scroll", math.max(cursorX - kManualScrollTolerance, 0), MenuAnimations.FlyIn)
        
    end
    
end

local function OnEditingChanged(self, editing)
    
    if editing then
        
        self:FireEvent("OnEditBegin")
        self:ListenForCharacters()
        self:ListenForKeyInteractions()
        self.entry:StopListeningForKeyInteractions()
        self.entryHolder:SetAutoScroll(false)
        
    else
        
        self:FireEvent("OnEditEnd")
        self:StopListeningForCharacters()
        self:StopListeningForKeyInteractions()
        self.entryHolder:SetAutoScroll(true)
        
    end
    
end

local function OnLabelTextSizeChanged(self)
    
    self.label:SetSize(math.min(kMaxLabelLength, self.label:GetTextSize().x), self.label:GetTextSize().y)
    UpdateEntryHolderSize(self)
    
end

-- Define some special subclasses that redefine some of the methods so it works correctly with this object.
class "_GUIMenuTextInputWidgetForEntry" (GUIMenuTextInputWidget)
class "_GUIMenuNumberInputWidgetForEntry" (GUIMenuNumberInputWidget)

local function GetOwnerEditing(self)
    if not self.owner then
        return false
    end
    local result = self.owner:GetEditing()
    return result
end

local function SetOwnerEditing(self, state)
    local result = self.owner:SetEditing(state)
    return result
end

_GUIMenuTextInputWidgetForEntry.GetEditing = GetOwnerEditing
_GUIMenuNumberInputWidgetForEntry.GetEditing = GetOwnerEditing

_GUIMenuTextInputWidgetForEntry.SetEditing = SetOwnerEditing
_GUIMenuNumberInputWidgetForEntry.SetEditing = SetOwnerEditing

do -- Define extended methods for the two classes.
    
    local function GetInitializeBody(cls, compositeClass, defaultType, includeNumeric)
        
        return function(self, params, errorDepth)
            errorDepth = (errorDepth or 1) + 1
            
            RequireType({defaultType, "nil"}, params.default, "params.default", errorDepth)
            if includeNumeric then
                RequireType({"number", "nil"}, params.minValue, "params.minValue", errorDepth)
                RequireType({"number", "nil"}, params.maxValue, "params.maxValue", errorDepth)
                RequireType({"number", "nil"}, params.decimalPlaces, "params.decimalPlaces", errorDepth)
                if params.decimalPlaces and params.decimalPlaces ~= math.floor(params.decimalPlaces) then
                    error(string.format("Expected an integer or nil for params.decimalPlaces, got %s instead", params.decimalPlaces), errorDepth)
                end
                RequireType({"string", "nil"}, params.label, "params.label", errorDepth)
            end
            
            baseClass.Initialize(self, params, errorDepth)
            
            self.label = CreateGUIObject("label", GUIMenuTruncatedText, self,
            {
                cls = GUIMenuText,
            })
            self.label:AlignLeft()
            self.label:SetPosition(MenuStyle.kWidgetPadding, 0)
            self.label:SetFont(MenuStyle.kOptionFont)
            self:HookEvent(self.label, "OnTextSizeChanged", OnLabelTextSizeChanged)
            self:AddFXReceiver(self.label:GetObject())
            
            PushParamChange(params, "cls", compositeClass)
            self.entryHolder = CreateGUIObject("entryHolder", GUIMenuTruncatedDisplayWidget, self, params)
            PopParamChange(params, "cls")
            
            self.entryHolder:SetAutoScroll(true)
            
            -- Right align with some padding.
            self.entryHolder:AlignRight()
            self.entryHolder:SetPosition(-MenuStyle.kWidgetPadding, 0)
            
            self.entry = self.entryHolder:GetObject()
            self.entry:AlignLeft()
            self.entry:SetFont(MenuStyle.kOptionFont)
            
            -- We'll forward the necessary events from this widget.
            self.entry:StopListeningForCursorInteractions()
            self.entry.owner = self -- convenient link.
            
            self.entry:ForwardEvent(self, "OnEditingChanged")
            
            self.back = CreateGUIObject("back", GUIMenuBasicBox, self)
            self.back:SetLayer(-1)
            
            self:HookEvent(self.entry, "OnEditingChanged", OnEditingChanged)
            
            self:ForwardEvent(self.entry, "OnCharacterAccepted")
            self:ForwardEvent(self.entry, "OnCharacterDeleted")
            self:ForwardEvent(self.entry, "OnEditAccepted")
            self:ForwardEvent(self.entry, "OnEditCancelled")
            
            -- Allow "SetText" to be called on this object to set the text of the entry.
            self:HookEvent(self, "OnTextChanged", SetEntryText)
            
            -- Update the background size to this widget's size.
            self:HookEvent(self, "OnSizeChanged", OnSizeChanged)
            
            -- Position the entry based on the label text.
            self:HookEvent(self, "OnLabelChanged", OnLabelChanged)
            
            self:HookEvent(self, "OnValueChanged", UpdateManualScrolling)
            self:HookEvent(self.entry, "On_CursorPositionChanged", UpdateManualScrolling)
            
            self:SetSize(MenuStyle.kDefaultWidgetSize)
            UpdateEntryHolderSize(self)
            self.entryHolder:SetAutoScrollSpeed(MenuStyle.kOptionFont.size * MenuStyle.kTextAutoScrollSpeedMult)
            
            self:SetLabel("LABEL:")
            self:SetText("ENTRY")
            
            if params.label then
                self:SetLabel(params.label)
            end
            
            if includeNumeric and params.minValue then
                self:SetMinValue(params.minValue)
            end
            
            if includeNumeric and params.maxValue then
                self:SetMaxValue(params.maxValue)
            end
            
            if includeNumeric and params.decimalPlaces then
                self:SetDecimalPlaces(params.decimalPlaces)
            end
            
            if params.default then
                self:SetValue(params.default)
            end
            
        end
        
    end
    
    GUIMenuTextEntryWidget.Initialize = GetInitializeBody(GUIMenuTextEntryWidget, _GUIMenuTextInputWidgetForEntry, "string", false)
    GUIMenuNumberEntryWidget.Initialize = GetInitializeBody(GUIMenuNumberEntryWidget, _GUIMenuNumberInputWidgetForEntry, "number", true)
    
end

DefineMethod("_BeginEditing", function(self)
    self.entry:_BeginEditing()
end)

DefineMethod("_EndEditing", function(self)
    self.entry:_EndEditing()
end)

-- Returns the given value formatted as though it were a value of this widget.
-- Simply returns the given value, since this widget's value is always a string-type.  Does not
-- perform any length or width checks, as it is assumed that this value was originally produced by
-- this widget (Eg a previous value).
DefineMethod("GetValueString", function(self, value)
    local result = self.entry:GetValueString(value)
    return result
end)

DefineMethod("OnMouseClick", function(self, double)
    baseClass.OnMouseClick(self, double)
    self.entry:OnMouseClick()
end)

DefineMethod("OnMouseRelease", function(self)
    baseClass.OnMouseRelease(self)
    self.entry:OnMouseRelease()
end)

DefineMethod("OnMouseUp", function(self)
    baseClass.OnMouseUp(self)
    self.entry:OnMouseUp()
end)

DefineMethod("OnMouseEnter", function(self)
    baseClass.OnMouseEnter(self)
    self.entry:OnMouseEnter()
end)

DefineMethod("OnMouseExit", function(self)
    baseClass.OnMouseExit(self)
    self.entry:OnMouseExit()
end)

DefineMethod("OnMouseDrag", function(self)
    baseClass.OnMouseDrag(self)
    self.entry:OnMouseDrag()
end)

DefineMethod("OnKey", function(self, key, down)
    baseClass.OnKey(self, key, down)
    self.entry:OnKey(key, down)
end)

DefineMethod("OnCharacter", function(self, character)
    baseClass.OnCharacter(self, character)
    self.entry:OnCharacter(character)
end)

DefineMethod("CancelEdit", function(self)
    self.entry:CancelEdit()
end)

-- See lua/GUI/wrappers/Editable.lua.
DefineMethod("GetIsTextInput", function()
    return true
end)

