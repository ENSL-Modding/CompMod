-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/widgets/GUIMenuKeybindEntryWidgetSimple.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--    
--    A GUIObject that includes a GUIMenuBaseKeybindEntryWidget and a background that changes color
--    to indicate status (eg listening, conflicted, etc.)
--
--  Properties:
--      Value           -- The _string_ of the current keybind for this widget (or "None" if
--                         unassigned).
--      IsConflicted    -- Whether or not this keybind has a conflict with another keybind (same
--                         group and same key).
--      IsInherited     -- Whether or not the _current value_ of the widget is inherited from the
--                         "InheritFrom" widget. (Note: must never be true if inheritFrom was
--                         nil)
--      
--  Events:
--      OnEditAccepted      -- Whenever this widget changes its value to the given input.
--      OnEditCancelled     -- Whenever this widget stops listening for input without changing values.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/GUIObject.lua")
Script.Load("lua/GUI/widgets/GUIBaseKeybindEntryWidget.lua")
Script.Load("lua/menu2/widgets/GUIMenuBaseKeybindEntryWidget.lua")
Script.Load("lua/menu2/GUIMenuBasicBox.lua")
Script.Load("lua/menu2/MenuStyles.lua")
Script.Load("lua/GUI/wrappers/FXState.lua")
Script.Load("lua/GUI/wrappers/CursorInteractable.lua")

---@class GUIMenuKeybindEntryWidgetSimple : GUIObject
---@field public GetMouseOver function @From CursorInteractable wrapper
---@field public GetPressed function @From CursorInteractable wrapper
---@field public GetFXState function @From FXState wrapper
---@field public UpdateFXStateOverride function @From FXState wrapper
---@field public AddFXReceiver function @From FXState wrapper
---@field public RemoveFXReceiver function @From FXState wrapper
---@field public GetEditing function @From Editable wrapper
---@field public SetEditing function @From Editable wrapper
---@field protected _BeginEditing function @From Editable wrapper
---@field protected _EndEditing function @From Editable wrapper
local baseClass = GUIObject
baseClass = GetCursorInteractableWrappedClass(baseClass)
baseClass = GetFXStateWrappedClass(baseClass)
baseClass = GetEditableWrappedClass(baseClass)
class "GUIMenuKeybindEntryWidgetSimple" (baseClass)

local kDefaultSize = Vector(64, 64, 0)

GUIMenuKeybindEntryWidgetSimple:AddCompositeClassProperty("Value", "keybind")
GUIMenuKeybindEntryWidgetSimple:AddCompositeClassProperty("IsConflicted", "keybind")
GUIMenuKeybindEntryWidgetSimple:AddCompositeClassProperty("IsInherited", "keybind")

function GUIMenuKeybindEntryWidgetSimple.InitValidation(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    GUIBaseKeybindEntryWidget.InitValidation(params, errorDepth)
end

local function AnimateBackgroundColor(self, color, strokeColor)
    self.back:ClearPropertyAnimations("FillColor")
    self.back:ClearPropertyAnimations("StrokeColor")
    self.back:AnimateProperty("FillColor", color, MenuAnimations.Fade)
    self.back:AnimateProperty("StrokeColor", strokeColor, MenuAnimations.Fade)
end

local function OnFXStateChanged(self, state, prevState)
    if state == "editing" then
        AnimateBackgroundColor(self, MenuStyle.kHighlightBackground, MenuStyle.kHighlightStrokeColor)
    elseif state == "conflicted" then
        AnimateBackgroundColor(self, MenuStyle.kConflictedBackgroundColor, MenuStyle.kConflictedStrokeColor)
    else
        AnimateBackgroundColor(self, MenuStyle.kBasicBoxBackgroundColor, MenuStyle.kDarkGrey)
    end
end

local function OnEditingChanged(self, isListening)
    
    if isListening then
        self:ListenForWheelInteractions()
    else
        self:StopListeningForWheelInteractions()
    end
    
end

local function UpdateBackgroundSize(self, size)
    self.back:SetSize(size)
end

function GUIMenuKeybindEntryWidgetSimple:UpdateFXStateOverride(commonStateResult)
    
    if self:GetIsConflicted() then
        self:SetFXState("conflicted")
        return true
    end
    
    return false
    
end

function GUIMenuKeybindEntryWidgetSimple:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    RequireType({"string", "nil"}, params.altLabel, "params.altLabel", errorDepth)
    
    GUIMenuKeybindEntryWidgetSimple.InitValidation(params, errorDepth)
    
    baseClass.Initialize(self, params, errorDepth)
    
    PushParamChange(params, "editController", self)
    PushParamChange(params, "cursorController", self)
    self.keybind = CreateGUIObject("keybind", GUIMenuBaseKeybindEntryWidget, self, params)
    PopParamChange(params, "cursorController")
    PopParamChange(params, "editController")
    self.keybind:SetLayer(1)
    self.keybind:AlignCenter()
    self.keybind:RemoveFXReceiver(self) -- make it one-way communication.
    
    -- Whenever the keybind object calls "SetModal", it'll actually route to this object instead,
    -- that way clicks on the whole widget get used, not just on the small part that overlaps the
    -- base widget.
    self.keybind:SetModalObject(self)
    
    self:ForwardEvent(self.keybind, "OnEditBegin")
    self:ForwardEvent(self.keybind, "OnEditAccepted")
    self:ForwardEvent(self.keybind, "OnEditCancelled")
    self:ForwardEvent(self.keybind, "OnEditEnd")
    
    self.back = CreateGUIObject("back", GUIMenuBasicBox, self)
    self.back:SetLayer(-1)
    self:HookEvent(self, "OnEditingChanged", OnEditingChanged)
    self:HookEvent(self, "OnSizeChanged", UpdateBackgroundSize)
    self:HookEvent(self, "OnFXStateChanged", OnFXStateChanged)
    self:HookEvent(self, "OnIsConflictedChanged", self.UpdateFXState)
    
    self:SetSize(kDefaultSize)
    
    if params.altLabel then
        self.altLabel = params.altLabel
    end
    
    self.keybind:UpdateFXState()
    
end

function GUIMenuKeybindEntryWidgetSimple:_BeginEditing()
    self.keybind:_BeginEditing()
end

function GUIMenuKeybindEntryWidgetSimple:_EndEditing()
    self.keybind:_EndEditing()
end

function GUIMenuKeybindEntryWidgetSimple:GetKeybindWidget()
    return self.keybind
end

function GUIMenuKeybindEntryWidgetSimple:ResetBinding() self.keybind:ResetBinding() end

-- Forward some interaction events so the keybind behavior will work for interactions with this widget.
function GUIMenuKeybindEntryWidgetSimple:OnMouseEnter()
    baseClass.OnMouseEnter(self)
    local result = self.keybind:OnMouseEnter()
    return result
end
function GUIMenuKeybindEntryWidgetSimple:OnMouseExit()
    baseClass.OnMouseExit(self)
    local result = self.keybind:OnMouseExit()
    return result
end
function GUIMenuKeybindEntryWidgetSimple:OnMouseClick(double)
    baseClass.OnMouseClick(self, double)
    local result = self.keybind:OnMouseClick()
    return result
end
function GUIMenuKeybindEntryWidgetSimple:OnMouseWheel(up)
    baseClass.OnMouseWheel(self, up)
    local result = self.keybind:OnMouseWheel(up)
    return result
end
function GUIMenuKeybindEntryWidgetSimple:OnMouseRelease()
    baseClass.OnMouseRelease(self)
    local result = self.keybind:OnMouseRelease()
    return result
end
function GUIMenuKeybindEntryWidgetSimple:OnMouseUp()
    baseClass.OnMouseUp(self)
    local result = self.keybind:OnMouseUp()
    return result
end
function GUIMenuKeybindEntryWidgetSimple:OnOutsideClick()
    baseClass.OnOutsideClick(self)
    local result = self.keybind:OnOutsideClick()
    return result
end
function GUIMenuKeybindEntryWidgetSimple:OnOutsideWheel(up)
    baseClass.OnOutsideWheel(self)
    local result = self.keybind:OnOutsideWheel(up)
    return result
end

-- Returns the given value formatted as though it were a value of this widget.
-- Simply returns the value, since keybinds are stored as plaintext anyways.
function GUIMenuKeybindEntryWidgetSimple:GetValueString(value)
    local result = self.keybind:GetValueString(value)
    return result
end

-- Need to provide a label for this widget even though it doesn't have one.  This is used by the
-- options menu to display a list of pending changes.
function GUIMenuKeybindEntryWidgetSimple:GetLabel()
    return self.altLabel or self:GetName()
end

function GUIMenuKeybindEntryWidgetSimple:ApplySubOption(name)
    self.keybind:ApplySubOption(name)
end

function GUIMenuKeybindEntryWidgetSimple:RevertSubOption(name, prevValue)
    self.keybind:RevertSubOption(name, prevValue)
end

function GUIMenuKeybindEntryWidgetSimple:GetSubValueChangeDescription(name)
    local result = self.keybind:GetSubValueChangeDescription(name)
    return result
end
