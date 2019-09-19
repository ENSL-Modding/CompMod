-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/GUI/widgets/GUIBaseKeybindEntryWidget.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--    
--    Widget the allows the user to input a desired key for some action.  This widget will also
--    keep track of conflicts between keybind entries (eg Jump and Crouch cannot be the same key).
--    The widget requires a "bindGroup" to be specified.  This ensures that keybinds for actions
--    that will never conflict with each other cannot be considered conflicting.  For example, any
--    commander keybinds can happily coexist with non-commander keybinds, since a player will never
--    be filling both roles at the same time.
--    
--    This widget is JUST the keybind text -- it does not include any background, labels, buttons
--    or anything outside of the base functionality.
--  
--  Parameters (* = required)
--     *bindGroup       The name of a group of keys within which all key bindings must be unique.
--                      For example, the commander bindings can share some of the same keys as
--                      general bindings since it's not possible to command and shoot at the same
--                      time.
--     *default         Default keybind name.  Must be either the name of a keybind, or "None".
--      inheritFrom     Name of a keybind to possibly inherit value from.  For example, the
--                      commander talk key is, by default, inherited from the regular talk key.
--                      Changing the default talk key also changes the commander talk key when it
--                      is in this state.
--  
--  Properties
--      Value           The _string_ of the current keybind for this widget (or "None" if
--                      unassigned).
--      IsConflicted    Whether or not this keybind has a conflict with another keybind (same
--                      group and same key).
--      IsInherited     Whether or not the _current value_ of the widget is inherited from the
--                      "InheritFrom" widget. (Note: must never be true if inheritFrom was
--                      nil)
--      
--  Events:
--      OnEditAccepted      Whenever this widget changes its value to the given input.
--      OnEditCancelled     Whenever this widget stops listening for input without changing values.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/GUIText.lua")
Script.Load("lua/UnorderedSet.lua")
Script.Load("lua/GUI/wrappers/CursorInteractable.lua")
Script.Load("lua/GUI/wrappers/Editable.lua")

-- The result of Client.ConvertKeyCodeToString is not always the same as the key of the InputKey
-- table used to retrieve that value.  Eg Client.ConvertKeyCodeToString(InputKey.Num1) == "1", but
-- InputKey["1"] is nil.  Create our own mapping, with blackjack, and hookers, and you know what,
-- forget the blackjack... ... ...ah screw the whole thing.
local kInputKeyValueToString
local kStringToInputKeyValue

local function BuildKeyMapping(value)
    local asString = Client.ConvertKeyCodeToString(value)
    kStringToInputKeyValue[asString] = value
    kInputKeyValueToString[value] = asString
end

local function BuildKeyMappings()
    assert(InputKey)
    assert(Client.ConvertKeyCodeToString) -- function wasn't loaded yet!
    kInputKeyValueToString = {}
    kStringToInputKeyValue = {}
    for key, value in pairs(InputKey) do
        if value ~= InputKey.FirstScanCode and value ~= InputKey.LastScanCode then
            BuildKeyMapping(value)
        end
    end
    
    -- Add unnamed key codes to mapping as well.
    for value=InputKey.FirstScanCode, InputKey.LastScanCode do
        BuildKeyMapping(value)
    end
    
end

function KeyValueToString(value)
    if not kInputKeyValueToString then
        BuildKeyMappings()
    end
    return kInputKeyValueToString[value]
end

function StringToKeyValue(str)
    if not kInputKeyValueToString then
        BuildKeyMappings()
    end
    return kStringToInputKeyValue[str]
end

---@class GUIBaseKeybindEntryWidget : GUIText
---@field public GetEditing function @From Editable wrapper
---@field public SetEditing function @From Editable wrapper
---@field protected _BeginEditing function @From Editable wrapper
---@field protected _EndEditing function @From Editable wrapper
---@field public GetMouseOver function @From CursorInteractable wrapper
---@field public GetPressed function @From CursorInteractable wrapper
local baseClass = GUIText
baseClass = GetEditableWrappedClass(baseClass)
baseClass = GetCursorInteractableWrappedClass(baseClass)
class "GUIBaseKeybindEntryWidget" (baseClass)

GUIBaseKeybindEntryWidget:AddClassProperty("Value", "")
GUIBaseKeybindEntryWidget:AddClassProperty("IsConflicted", false)
GUIBaseKeybindEntryWidget:AddClassProperty("IsInherited", false)

-- BindGroup --> keybind value string --> { 1..n keybind widgets that have this value }
local assignments = {}

local function UpdateConflictedForWidgetSet(widgetSet)

    local conflicted = false
    if #widgetSet > 1 then
        
        -- Special case for TertiaryAttack and EvolveMenu.  TertiaryAttack is exclusive to marine
        -- team (for now), and EvolveMenu is exclusive to aliens.  This is totally a hack, and needs
        -- to be rewritten better if we ever want to do something like per-lifeform bindings.
        local containsOther = false
        for i=1, #widgetSet do
            local widget = widgetSet[i]
            if widget.optionPath ~= "input/TertiaryAttack" and widget.optionPath ~= "input/Buy" then
                containsOther = true
            end
        end
        
        if containsOther then
            conflicted = true
        end
    end
    
    for i=1, #widgetSet do
        widgetSet[i]:SetIsConflicted(conflicted)
    end

end

-- Disassociate a keybind widget from its old value.
local function RemoveAssignment(obj, oldValue)
    
    if oldValue == "None" or oldValue == "" then
        return -- nothing to remove.
    end
    
    local bindGroup = assignments[obj.bindGroup]
    assert(bindGroup)
    
    local widgetSet = bindGroup[oldValue]
    assert(widgetSet)
    
    assert(widgetSet:RemoveElement(obj))
    obj:SetIsConflicted(false) -- can't be conflicted if it isn't assigned to anything!
    
    UpdateConflictedForWidgetSet(widgetSet)
    
end

-- Associate a keybind widget with a new value.
local function AddAssignment(obj, newValue)
    
    if newValue == "None" or newValue == "" then
        return -- nothing to add.  "None" can never conflict with anything.
    end
    
    local bindGroup = assignments[obj.bindGroup]
    if not bindGroup then
        bindGroup = {}
        assignments[obj.bindGroup] = bindGroup
    end
    
    local widgetSet = bindGroup[newValue]
    if not widgetSet then
        widgetSet = UnorderedSet()
        bindGroup[newValue] = widgetSet
    end
    
    assert(widgetSet:Add(obj))
    
    UpdateConflictedForWidgetSet(widgetSet)
    
end

local function OnInheriteeValueChanged(self, value, prevValue)
    
    if not self:GetIsInherited() then
        return
    end
    
    self:SetValue(value)
    
end

-- Widgets that have not yet been setup because they inherit from a widget that has not yet been
-- created.
local pendingInheritanceSetups = {}

local function SetupInheritance(self, inheritFrom, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    -- See if this widget is being inherited by another pending widget.
    for i=#pendingInheritanceSetups, 1, -1 do
        local pendingWidget = pendingInheritanceSetups[i]
        if pendingWidget.inheritFromName == self:GetName() then
            table.remove(pendingInheritanceSetups, i)
            SetupInheritance(pendingWidget, pendingWidget.inheritFromName, errorDepth)
        end
    end
    
    -- If this widget doesn't inherit from any others, no need to process further.
    if inheritFrom == nil or inheritFrom == "" then
        return
    end
    
    -- Find the widget we inherit from.
    local inheriteeWidget = GetOptionsMenu():GetOptionWidget(inheritFrom)
    if not inheriteeWidget then
        -- Cannot setup this widget's inheritance yet -- waiting on another widget to be created
        -- first.
        self.inheritFromName = inheritFrom
        pendingInheritanceSetups.insert(self)
        return
    end
    
    -- Inherit from the keybind widget, not the pretty menu-themed wrapper.
    if inheriteeWidget.GetKeybindWidget then
        inheriteeWidget = inheriteeWidget:GetKeybindWidget()
    end
    self.inheritFrom = inheriteeWidget
    
    -- Whenver the inheritee's value changes, see if we need to update our own value (if we're inheriting).
    self:HookEvent(inheriteeWidget, "OnValueChanged", OnInheriteeValueChanged)
    
    -- Setup the initial inheritance state of this object.
    local thisOptionValue = Client.GetOptionString(self.optionPath, self.default)
    local inheritedOptionValue = Client.GetOptionString(inheriteeWidget.optionPath, inheriteeWidget.default)
    
    -- Set the inheritance of this keybind based on the saved inherit state option value.  If the
    -- option does not exist (implying this is the first time the player has run the new menu),
    -- then set inheritance to true if the two keybinds match, otherwise don't inherit.
    local shouldDefaultToTrue = thisOptionValue == inheritedOptionValue
    local inherit = Client.GetOptionBoolean(self.optionPath.."_inherit", shouldDefaultToTrue)
    
    -- Handle the edge case where inherit is true, yet the options do not match (user could have
    -- manually edited their options file).
    self:SetIsInherited(inherit and shouldDefaultToTrue)
    
end

local function OnValueChanged(self, value, prevValue)
    
    RemoveAssignment(self, prevValue)
    AddAssignment(self, value)
    
    -- TODO set text to some nicer, locale-friendly value.  Eg "period" instead of ".", and use
    -- locale for "Unbound".
    self:SetText(value)
    
end

function GUIBaseKeybindEntryWidget.InitValidation(params, errorDepth)
    errorDepth = errorDepth or 1
    errorDepth = errorDepth + 1
    
    RequireType("table", params, "params", errorDepth)
    
    -- bindGroup must be provided.
    -- The name of a group of keys within which all key bindings must be unique.  For example,
    -- commander bindings can share some of the same keys as general bindings since it's not
    -- possible to both command and shoot at the same time.
    RequireType("string", params.bindGroup, "params.bindGroup", errorDepth)
    
    -- inheritFrom is optional.
    -- Must be the name of a keybind to inherit from, or nil.
    -- Keybind widgets can default to the value of another keybind widget when unbound.  For
    -- example, the commander talk key is inherited from the regular talk key.  Most players will
    -- keep these the same, and will reasonably expect that changing the regular talk key will also
    -- change the commander talk key.  There are a few, however, who wish to use different keys for
    -- each.
    RequireType({"string", "nil"}, params.inheritFrom, "params.inheritFrom", errorDepth)
    
    -- default must be provided.
    -- Must be either "None" or the name of a key.
    RequireType("string", params.default, "params.default", errorDepth)
    
    if params.default ~= "None" and StringToKeyValue(params.default) == nil then
        error(string.format("GUIBaseKeybindEntryWidget params.default invalid!  Must be either 'None' or a valid InputKey name.  Got '%s' instead.", params.default), errorDepth)
    end
    
end

local function OnIsConflictedChanged(self, conflicted)
    
    local methodName
    if conflicted then
        methodName = "AddConflictedKeybindWidget"
    else
        methodName = "RemoveConflictedKeybindWidget"
    end
    
    local currentObj = self:GetParent(true)
    while currentObj do
        
        if currentObj[methodName] and type(currentObj[methodName]) == "function" then
            currentObj[methodName](currentObj, self)
        end
        
        currentObj = currentObj:GetParent(true)
    end
    
end

function GUIBaseKeybindEntryWidget:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    GUIBaseKeybindEntryWidget.InitValidation(params, errorDepth)
    
    baseClass.Initialize(self, params, errorDepth)
    
    self.optionPath = params.optionPath
    self.bindGroup = params.bindGroup
    self.default = params.default
    SetupInheritance(self, params.inheritFrom, errorDepth)
    
    self:HookEvent(self, "OnValueChanged", OnValueChanged)
    self:HookEvent(self, "OnIsConflictedChanged", OnIsConflictedChanged)
    
    if self.default ~= "None" then
        self:SetValue(self.default)
    else
        if self.inheritFrom then
            self:SetValue(self.inheritFrom:GetValue())
            self:SetIsInherited(true)
        else
            self:SetValue("None")
        end
    end
    
end

function GUIBaseKeybindEntryWidget:Uninitialize()
    
    baseClass.Uninitialize(self)
    
    -- Un-link from inheritee
    if self.inheritFrom then
        local inheritorList = inheritanceMapping[self.inheritFrom]
        assert(inheritorList)
        for i=1, #inheritorList do
            if inheritorList[i] == self then
                table.remove(inheritorList, i)
                break
            else
                assert(i ~= #inheritorList) -- must be found in list.
            end
        end
        
        -- Cleanup list if last inheritor is removed.
        if #inheritorList == 0 then
            inheritanceMapping[self.inheritFrom] = nil
        end
    end
    
    -- Un-link from inheritors.
    local inheritorList = inheritanceMapping[self]
    if inheritorList then
        for i=1, #inheritorList do
            local inheritor = inheritorList[i]
            inheritor.inheritFrom = nil
            inheritor:SetIsInherited(false) -- no harm if it's already not inheriting.
        end
        inheritanceMapping[self] = nil
    end
    
    -- Remove this widget from the bindings conflict table.
    if self:GetValue() ~= "" and self:GetValue() ~= "None" then
        RemoveAssignment(self, self:GetValue())
    end
    
end

function GUIBaseKeybindEntryWidget:_BeginEditing()
    
    self:SetModal()
    self:ListenForKeyInteractions()
    self:ListenForWheelInteractions()
    self:SetText("_")
    
end

function GUIBaseKeybindEntryWidget:_EndEditing()
    
    self:ClearModal()
    self:StopListeningForKeyInteractions()
    self:StopListeningForWheelInteractions()
    self:SetText(self:GetValue())
    
end

function GUIBaseKeybindEntryWidget:OnMouseRelease()
    
    -- Allow mouse button to be used as a key.
    if self:GetEditing() then
        self:OnKey(InputKey.MouseButton0, true)
        return true
    end
    
    -- Begin listening.
    self:SetEditing(true)
    
end

local function SharedMouseClick(self)
    
    if not self:GetEditing() then
        return true -- nothing to do if we're not listening, but still consume it.
    end
    
    -- Prevent this keybind from starting to listen again on the mouse release.
    self:CancelPendingMouseRelease()
    
    -- Act like this mouse button press was received as a regular key press.
    self:OnKey(InputKey.MouseButton0, true)
    
end

function GUIBaseKeybindEntryWidget:OnMouseClick()
    SharedMouseClick(self)
end

function GUIBaseKeybindEntryWidget:OnOutsideClick()
    SharedMouseClick(self)
end

function GUIBaseKeybindEntryWidget:OnMouseWheel(up)
    
    -- should only be listening for wheel events when listening for keybinds.
    assert(self:GetEditing())
    
    if up then
        self:OnKey(InputKey.MouseWheelUp, true)
    else
        self:OnKey(InputKey.MouseWheelDown, true)
    end
    
    return true
    
end

function GUIBaseKeybindEntryWidget:OnOutsideWheel(up)
    self:OnMouseWheel(up)
end

function GUIBaseKeybindEntryWidget:OnKey(key, down)
    
    -- should only ever be listening for key events when listening for keybinds.
    assert(self:GetEditing())
    
    if not down then
        return true -- don't care about releases.
    end
    
    if key == InputKey.Escape then
        -- Escape can never be used as an input key.
        self:PauseEvents()
            self:SetEditing(false)
            self:FireEvent("OnEditCancelled")
        self:ResumeEvents()
        return true
    end
    
    self:PauseEvents()
        self:SetEditing(false)
        self:SetIsInherited(false)
        local keyString = KeyValueToString(key)
        assert(keyString)
        if self:SetValue(keyString) then
            self:FireEvent("OnEditAccepted")
        else
            self:FireEvent("OnEditCancelled")
        end
    self:ResumeEvents()
    
    return true
    
end

-- Resets the binding to the next available value, depending on the current state.
--      Value is not None and not inherited --> Inherit value if possible, otherwise None
--      Value is inherited --> None
--      Value is None --> Default value if default is not None, otherwise inherit if possible,
--          otherwise leave at None.
function GUIBaseKeybindEntryWidget:ResetBinding()
    
    if self:GetValue() ~= "None" and not self:GetIsInherited() then
        if self.inheritFrom then
            self:PauseEvents()
                self:SetValue(self.inheritFrom:GetValue())
                self:SetIsInherited(true)
            self:ResumeEvents()
        else
            self:SetValue("None")
        end
    elseif self:GetIsInherited() then
        self:PauseEvents()
            self:SetValue("None")
            self:SetIsInherited(false)
        self:ResumeEvents()
    else -- value is none
        assert(self:GetValue() == "None")
        if self.default == "None" then
            if self.inheritFrom then
                self:PauseEvents()
                    self:SetValue(self.inheritFrom:GetValue())
                    self:SetIsInherited(true)
                self:ResumeEvents()
            else
                -- leave at None
                Log("ResetBinding() nothing to do!  Button should have been disabled.")
            end
        else
            self:PauseEvents()
                self:SetValue(self.default)
                self:SetIsInherited(false)
            self:ResumeEvents()
        end
    end
    
end

-- Returns the given value formatted as though it were a value of this widget.
-- Simply returns the value, since keybinds are stored as plaintext anyways.
function GUIBaseKeybindEntryWidget:GetValueString(value)
    return value
end

function GUIBaseKeybindEntryWidget:ApplySubOption(name)
    Client.SetOptionBoolean(self.optionPath.."_inherit", self:GetIsInherited())
end

function GUIBaseKeybindEntryWidget:RevertSubOption(name, prevValue)
    self:SetIsInherited(prevValue)
    Client.SetOptionBoolean(self.optionPath.."_inherit", prevValue)
end

function GUIBaseKeybindEntryWidget:GetSubValueChangeDescription(name, prevValue)
    
    local inherited = self:GetIsInherited()
    local result = string.format("copy value: %s --> %s", (not inherited) and Locale.ResolveString("YES") or Locale.ResolveString("NO"), inherited and Locale.ResolveString("YES") or Locale.ResolveString("NO"))
    return result
    
end
