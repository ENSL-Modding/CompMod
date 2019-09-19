-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/GUI/widgets/GUITextInputWidget.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    A GUIObject widget to allow a user to input text from the keyboard.
--
--  Parameters:
--      value
--      maxCharacterCount
--      maxWidth
--      isPassword
--
--  Properties:
--      Value               -- The value of this widget (ie the text).
--      MaxCharacterCount   -- The maximum number of characters (unicode characters to be precise)
--                             allowed in the string. <=0 for unlimited.
--      MaxWidth            -- The maximum width of the text, in local space pixels. <=0 for
--                             unlimited.
--      Editing             -- Whether or not the user is entering text for this object.
--      IsPassword          -- Whether or not the text of this object should be censored.
--      CursorIndex         -- The index of the character to the right of the cursor.  Valid range
--                             is 1..N+1, where N is the number of unicode characters.
--      SelectionSize       -- The number of unicode characters to the right of the cursor index
--                             that are selected.
--  
--  Events:
--      OnEditBegin         -- The user has started editing the text.
--      OnCharacterAccepted -- The user has added a character while editing.
--          character           -- Character that was added.
--      OnCharacterDeleted  -- The user has deleted a character while editing.
--      OnEditAccepted      -- Editing has ended, with the user accepting the edit.
--      OnEditCancelled     -- Editing has ended, with the user reverting the edit.
--      OnEditEnd           -- Editing has ended.  The text may or may not have changed.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/GUIObject.lua")

Script.Load("lua/GUI/wrappers/Editable.lua")
Script.Load("lua/GUI/wrappers/CursorInteractable.lua")

---@class GUITextInputWidget : GUIObject
---@field public GetEditing function @From Editable wrapper
---@field public SetEditing function @From Editable wrapper
---@field protected _BeginEditing function @From Editable wrapper
---@field protected _EndEditing function @From Editable wrapper
---@field public GetMouseOver function @From CursorInteractable wrapper
---@field public GetPressed function @From CursorInteractable wrapper
local baseClass = GUIObject
baseClass = GetEditableWrappedClass(baseClass)
baseClass = GetCursorInteractableWrappedClass(baseClass)
class "GUITextInputWidget" (baseClass)

GUITextInputWidget:AddClassProperty("Value", "")
GUITextInputWidget:AddClassProperty("MaxCharacterCount", -1)
GUITextInputWidget:AddClassProperty("MaxWidth", -1)
GUITextInputWidget:AddClassProperty("IsPassword", false)
GUITextInputWidget:AddClassProperty("CursorIndex", 1)
GUITextInputWidget:AddClassProperty("SelectionSize", 0)

local kDefaultFont = ReadOnly{family = "Arial", size = 24}
local kRepeatInitialDelay = 0.5
local kRepeatDelay = 1/40 -- 40 characters per second.

-- See lua/GUI/wrappers/Editable.lua.
function GUITextInputWidget:GetIsTextInput()
    return true
end

function GUITextInputWidget:GetPasswordCharacter()
    return "*"
end

function GUITextInputWidget:GetCursorCharacter()
    return "|"
end

function GUITextInputWidget:GetCursorCharacterOffset()
    local result = Vector(-2, -4, 0)
    return result
end

function GUITextInputWidget:GetValueAsString()
    local result = self:GetValue()
    return result
end

local function SyncFontName(self, fontName)
    self.cursor:SetFontName(fontName)
    self.displayText:SetFontName(fontName)
end

local function UpdateDisplayedText(self)
    
    if self:GetIsPassword() then
        local utf8
        if self:GetEditing() then
            utf8 = self.utf8Array
        else
            utf8 = UTF8FromString(self:GetValueAsString())
        end
        self.displayText:SetText(string.rep(self:GetPasswordCharacter(), #utf8))
    else
        if self:GetEditing() then
            local editAsString = StringFromUTF8(self.utf8Array)
            self.displayText:SetText(editAsString)
        else
            self.displayText:SetText(self:GetValueAsString())
        end
    end
    
    -- The size of the object should be set to the size of the displayed text, since this is what
    -- is being manipulated by the user.
    self:SetSize(self.displayText:GetSize())
    
end

local function OnMaxCharacterCountChanged(self)
    
    -- Enforce new max character count.
    local maxCC = self:GetMaxCharacterCount()
    if maxCC <= 0 then
        return -- no limit on max character count.
    end
    
    -- Remove characters until we're under the limit.
    
    -- Get the string as a UTF-8 array so we can edit it easily.
    local utf8
    if self:GetEditing() then
        utf8 = self.utf8Array
    else
        utf8 = UTF8FromString(self:GetValueAsString())
    end
    
    while #utf8 > maxCC do
        utf8[#utf8] = nil
    end
    
    -- Ensure the cursor position and selection size are within bounds.
    if self:GetCursorIndex() > #utf8 + 1 then
        self:SetCursorIndex(#utf8 + 1)
    end
    
    if self:GetCursorIndex() + self:GetSelectionSize() > #utf8 + 1 then
        self:SetSelectionSize((#utf8+1) - self:GetCursorIndex())
    end
    
    -- Convert the string back to regular string and set it.
    self:UpdateValueFromUTF8(utf8)
    
end

local function OnMaxWidthChanged(self)
    
    -- Enforce new max width.
    local maxWidth = self:GetMaxWidth()
    if maxWidth <= 0 then
        return -- no limit on max character count.
    end
    
    -- Remove characters until we're under the limit.
    
    -- Get the string as a UTF-8 array so we can edit it easily.
    local utf8
    if self:GetEditing() then
        utf8 = self.utf8Array
    else
        utf8 = UTF8FromString(self:GetValueAsString())
    end
    
    while #utf8 > 0 do
        
        local text = StringFromUTF8(utf8)
        local width = self.displayText:CalculateTextSize(text).x
        if width <= maxWidth then
            break
        end
        
        -- Remove one character at a time until we're under the limit... or until all are gone.
        utf8[#utf8] = nil
        
    end
    
    -- Ensure the cursor position and selection size are within bounds.
    if self:GetCursorIndex() > #utf8 + 1 then
        self:SetCursorIndex(#utf8 + 1)
    end
    
    if self:GetCursorIndex() + self:GetSelectionSize() > #utf8 + 1 then
        self:SetSelectionSize((#utf8+1) - self:GetCursorIndex())
    end
    
    -- Convert the string back to regular string and set it.
    self:UpdateValueFromUTF8(utf8)
    
end

local function UpdateCursorAndSelectionVisiblity(self)
    
    self.cursor:SetVisible(self:GetEditing() and self:GetSelectionSize() == 0)
    self.selectionBox:SetVisible(self:GetEditing() and self:GetSelectionSize() > 0)
    
end

local function OnCursorIndexChanged(self)
    
    local cursorPos = Vector(self:GetLocalXOffsetByCursorIndex(self:GetCursorIndex()), 0, 0) + self:GetCursorCharacterOffset()
    self.cursor:SetPosition(cursorPos)
    self.selectionBox:SetPosition(cursorPos.x, 0)
    
end

local function OnSelectionSizeChanged(self)
    
    if self:GetSelectionSize() == 0 then
        return
    end
    
    local xPos = self:GetLocalXOffsetByCursorIndex(self:GetCursorIndex())
    local xSize = self:GetLocalXOffsetByCursorIndex(self:GetCursorIndex() + self:GetSelectionSize()) - xPos
    self.selectionBox:SetSize(xSize, self:GetSize().y)
    self.selectionBox:SetPosition(xPos, 0)
    
end

-- Override for cleaner animations.
function GUITextInputWidget:SetupVisuals()
    
    -- Have to create a separate item to display the text, as we might need to store it separately
    -- from the visuals (password obscuring).
    self.displayText = CreateGUIObject("displayText", GUIText, self)
    
    self.cursor = self:CreateTextGUIItem(self.displayText.text)
    self.cursor:SetFontName(self:GetFontName())
    self.cursor:SetText(self:GetCursorCharacter())
    self.cursor:SetVisible(false)
    
    self.selectionBox = self:CreateGUIItem(self.displayText.text)
    self.selectionBox:SetColor(0, 0.5, 1, 0.5)
    self.selectionBox:SetLayer(-1)
    self.selectionBox:AlignLeft()
    self.selectionBox:SetVisible(false)
    
    self:HookEvent(self, "OnFontNameChanged", SyncFontName)
    
    self:HookEvent(self, "OnEditingChanged", UpdateCursorAndSelectionVisiblity)
    self:HookEvent(self, "OnSelectionSizeChanged", UpdateCursorAndSelectionVisiblity)
    self:HookEvent(self, "OnCursorIndexChanged", UpdateCursorAndSelectionVisiblity)
    self:HookEvent(self, "OnCursorIndexChanged", OnCursorIndexChanged)
    self:HookEvent(self, "OnSelectionSizeChanged", OnSelectionSizeChanged)
    self:HookEvent(self, "OnIsPasswordChanged", OnCursorIndexChanged)
    self:HookEvent(self, "OnIsPasswordChanged", OnSelectionSizeChanged)
    
end

function GUITextInputWidget:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    RequireType({"table", "nil"}, params.font, "params.font", errorDepth)
    if params.font then
        RequireType("string", params.font.family, "params.font.family", errorDepth)
        RequireType("number", params.font.size, "params.font.size", errorDepth)
    end
    
    RequireType({"string", "nil"}, params.value, "params.value", errorDepth)
    RequireType({"number", "nil"}, params.maxCharacterCount, "params.maxCharacterCount", errorDepth)
    if params.maxCharacterCount and math.floor(params.maxCharacterCount) ~= params.maxCharacterCount then
        error(string.format("params.maxCharacterCount must be a whole number!  (Got %s)", params.maxCharacterCount), errorDepth)
    end
    
    RequireType({"number", "nil"}, params.maxWidth, "params.maxWidth", errorDepth)
    RequireType({"boolean", "nil"}, params.isPassword, "params.isPassword", errorDepth)
    
    baseClass.Initialize(self, params, errorDepth)
    
    self:SetupVisuals()
    
    self:HookEvent(self, "OnIsPasswordChanged", UpdateDisplayedText)
    self:HookEvent(self, "OnValueChanged", UpdateDisplayedText)
    
    self:HookEvent(self, "OnMaxCharacterCountChanged", OnMaxCharacterCountChanged)
    self:HookEvent(self, "OnMaxWidthChanged", OnMaxWidthChanged)
    
    self:SetFont(params.font or kDefaultFont)
    
    if params.value then
        self:SetValue(params.value)
    end
    
    if params.maxCharacterCount then
        self:SetMaxCharacterCount(params.maxCharacterCount)
    end
    
    if params.maxWidth then
        self:SetMaxWidth(params.maxWidth)
    end
    
    if params.isPassword ~= nil then
        self:SetIsPassword(params.isPassword)
    end
    
end

function GUITextInputWidget:GetLocalXOffsetByCursorIndex(idx)
    
    -- Should only be called during editing.
    assert(self:GetEditing())
    assert(self.utf8Array ~= nil)
    
    if idx <= 1 then
        return 0
    else
        idx = math.min(idx-1, #self.utf8Array)
        
        local str
        if self:GetIsPassword() then
            str = string.rep(self:GetPasswordCharacter(), idx)
        else
            str = StringFromUTF8(self.utf8Array, idx)
        end
        
        return self.displayText:CalculateTextSize(str).x
    end
    
end

function GUITextInputWidget:GetCursorPosition(static)
    local result = self.cursor:GetPosition(static)
    return result
end

function GUITextInputWidget:CalculateCursorIndexFromLocalSpaceX(x)
    
    -- Iterate over every possible cursor position, and pick the one that is closest.  Could
    -- certainly be improved with some sort of binary search, but not certain this would be worth
    -- the effort yet.
    
    -- Should only be called during editing.
    assert(self.utf8Array ~= nil)
    
    local bestIdx = 1
    local bestDist = math.abs(x)
    
    for i=1, #self.utf8Array do
        
        local cursorPos = self:GetLocalXOffsetByCursorIndex(i + 1)
        local dist = math.abs(x - cursorPos)
        if dist < bestDist then
            bestIdx = i + 1
            bestDist = dist
        else
            -- Cursor position over the character index will only ever increase.  If the distance
            -- begins to increase, we know we've passed the minimum, so we can stop.
            break
        end
        
    end
    
    return bestIdx
    
end

function GUITextInputWidget:OnMouseClick()
    
    if not self:GetEditing() then
        return
    end
    
    local ssMousePos = GetGlobalEventDispatcher():GetMousePosition()
    local localMousePos = self:ScreenSpaceToLocalSpace(ssMousePos)
    
    self.dragStartIndex = self:CalculateCursorIndexFromLocalSpaceX(localMousePos.x)
    self.dragging = true
    
    self:SetCursorIndex(self.dragStartIndex)
    self:SetSelectionSize(0)
    
end

function GUITextInputWidget:OnMouseDrag()
    
    if not self.dragging then
        return
    end
    
    assert(self:GetEditing())
    
    local ssMousePos = GetGlobalEventDispatcher():GetMousePosition()
    local localMousePos = self:ScreenSpaceToLocalSpace(ssMousePos)
    
    local currentIndex = self:CalculateCursorIndexFromLocalSpaceX(localMousePos.x)
    
    local startIndex = math.min(self.dragStartIndex, currentIndex)
    local endIndex = math.max(self.dragStartIndex, currentIndex)
    
    self:SetCursorIndex(startIndex)
    self:SetSelectionSize(endIndex - startIndex)
    assert(self:GetSelectionSize() >= 0)
    
end

function GUITextInputWidget:OnMouseUp()
    
    if not self.dragging then
        return
    end
    
    assert(self:GetEditing())
    
    self.dragging = nil
    self.dragStartIndex = nil
    
end

function GUITextInputWidget:OnMouseRelease()
    
    -- Begin editing if we're not already editing.
    if not self:GetEditing() then
        self:SetEditing(true)
    end
    
end

local kForbiddenCharacters =
{
    ["\n"] = true, -- This widget is designed for single-line text input.
    ["\t"] = true, -- Tabs are nasty.
    ["\r"] = true, -- No.
}

-- DEBUG
---[=[
kForbiddenCharacters["*"] = true
--DebugStuff()
--]=]


-- Called by OnCharacter to determine if a new character is allowed to be added to the string.
function GUITextInputWidget:GetIsValidCharacter(character)
    
    assert(self:GetEditing())
    assert(self.utf8Array ~= nil)
    
    return kForbiddenCharacters[character] == nil
    
end

function GUITextInputWidget:_BeginEditing()
    
    assert(self.utf8Array == nil)
    self.utf8Array = UTF8FromString(self:GetValueAsString())
    self.oldUTF8 = Copy(self.utf8Array)
    
    self:ListenForCharacters()
    self:ListenForKeyInteractions()
    
    -- Ensure CursorIndex, SelectionSize, and Editing are all up-to-date when callbacks fire.
    self:PauseEvents()
        
        self:SetCursorIndex(#self.utf8Array + 1)
        self:SetSelectionSize(0)
        
        OnCursorIndexChanged(self) -- Ensure it's repositioned to where it needs to be.
        self:FireEvent("OnEditBegin")
        
    self:ResumeEvents()
    
end

-- Performs any corrections, applies any constraints required.
function GUITextInputWidget:CleanupAndConstrainUTF8(utf8)
    
    -- No constraints/corrections needed for plain text input widget.
    return utf8
    
end

local function ClearRepeatingKey(self)
    
    if not self.repeatingKeyCallback then
        return
    end
    
    self:RemoveTimedCallback(self.repeatingKeyCallback)
    self.repeatingKeyCallback = nil
    self.repeatingKey = nil
    self.repeatKeyFunc = nil
    
end

function GUITextInputWidget:_EndEditing()
    
    assert(self.utf8Array ~= nil)
    
    self:PauseEvents()
        
        self:StopListeningForCharacters()
        self:StopListeningForKeyInteractions()
        ClearRepeatingKey(self)
        
        -- Ensure the text we're setting it to, accepted or rejected, is valid.
        self.utf8Array = self:CleanupAndConstrainUTF8(self.utf8Array)
        
        -- Constrain the cursor position once again.  Doesn't make a difference for this base class,
        -- but derived classes' animations benefit from the cursor snapping back into place.
        self:SetCursorIndex(Clamp(self:GetCursorIndex(), 1, #self.utf8Array + 1))
        
        self:UpdateValueFromUTF8(self.utf8Array)
        UpdateDisplayedText(self)
        
        self.utf8Array = nil
        self.dragging = nil
        
        self:FireEvent("OnEditEnd")
        
    self:ResumeEvents()
    
end

-- End editing, reverting the changes.
function GUITextInputWidget:CancelEdit()
    
    assert(self:GetEditing())
    assert(self.oldUTF8 ~= nil)
    
    self.utf8Array = self.oldUTF8
    self.oldUTF8 = nil
    
    self:PauseEvents()
        
        self:FireEvent("OnEditCancelled")
        self:SetEditing(false)
        
    self:ResumeEvents()
    
end

function GUITextInputWidget:UpdateValueFromUTF8(utf8)
    
    local newValue = StringFromUTF8(utf8)
    self:SetValue(newValue)
    
end

-- Deletes the selected characters, doesn't update text.
local function DeleteSelectionActual(self)
    
    assert(self:GetEditing())
    assert(self.utf8Array ~= nil)
    
    local selectedCount = self:GetSelectionSize()
    while selectedCount > 0 do
        table.remove(self.utf8Array, self:GetCursorIndex())
        selectedCount = selectedCount - 1
    end
    
end

function GUITextInputWidget:DeleteSelection()
    
    assert(self:GetEditing())
    assert(self.utf8Array ~= nil)
    
    DeleteSelectionActual(self)
    
    self:SetSelectionSize(0)
    self:UpdateValueFromUTF8(self.utf8Array)
    UpdateDisplayedText(self)
    
end

function GUITextInputWidget:OnLeftArrowKey()
    
    if self:GetSelectionSize() > 0 then
        -- Left arrow when selection is made results in the cursor being placed at the left edge
        -- of the selection.
        self:SetSelectionSize(0)
    else
        self:SetCursorIndex(Clamp(self:GetCursorIndex() - 1, 1, #self.utf8Array + 1))
    end
    
end

function GUITextInputWidget:OnRightArrowKey()
    
    assert(self.utf8Array)
    
    if self:GetSelectionSize() > 0 then
        -- Right arrow when selection is made results in the cursor being placed at the right edge
        -- of the selection.
        local cursorIdx = self:GetCursorIndex() + self:GetSelectionSize()
        cursorIdx = Clamp(cursorIdx, 1, #self.utf8Array + 1)
        self:SetSelectionSize(0)
        self:SetCursorIndex(cursorIdx)
    else
        self:SetCursorIndex(Clamp(self:GetCursorIndex() + 1, 1, #self.utf8Array + 1))
    end
    
end

function GUITextInputWidget:OnEscapeKey()
    self:CancelEdit()
end

function GUITextInputWidget:OnEnterKey()
    
    self:PauseEvents()
        self:SetEditing(false)
        self:FireEvent("OnEditAccepted")
    self:ResumeEvents()
    
end

function GUITextInputWidget:OnBackspaceKey()
    
    assert(self.utf8Array)
    
    if self:GetSelectionSize() > 0 then
        self:DeleteSelection()
        return
    end
    
    if self:GetCursorIndex() <= 1 then
        return -- nothing to the left of the cursor to delete.
    end
    
    table.remove(self.utf8Array, self:GetCursorIndex() - 1)
    
    self:SetCursorIndex(self:GetCursorIndex() - 1)
    
    self:UpdateValueFromUTF8(self.utf8Array)
    self:FireEvent("OnCharacterDeleted")
    UpdateDisplayedText(self)
    
end

function GUITextInputWidget:OnDeleteKey()
    
    assert(self.utf8Array)
    
    if self:GetSelectionSize() > 0 then
        self:DeleteSelection()
        return
    end
    
    if self:GetCursorIndex() >= #self.utf8Array + 1 then
        return -- nothing to the right of the cursor to delete.
    end
    
    table.remove(self.utf8Array, self:GetCursorIndex())
    
    self:UpdateValueFromUTF8(self.utf8Array)
    self:FireEvent("OnCharacterDeleted")
    UpdateDisplayedText(self)
    
end

local function RepeatKeyCallback(self)
    
    assert(self.repeatKeyFunc)
    self.repeatKeyFunc(self)
    
end

local function RepeatKeyInitialCallback(self)
    
    self.repeatingKeyCallback = self:AddTimedCallback(RepeatKeyCallback, kRepeatDelay, true)
    
end

local function SetRepeatingKey(self, key)
    
    assert(key)
    assert(self.repeatingKey == nil)
    assert(self.repeatingKeyCallback == nil)
    assert(self.repeatKeyFunc == nil)
    
    self.repeatKeyFunc = self:GetKeyRepeatFunction(key)
    assert(self.repeatKeyFunc) -- there must be a key repeat function for the given key.
    
    self.repeatingKey = key
    self.repeatingKeyCallback = self:AddTimedCallback(RepeatKeyInitialCallback, kRepeatInitialDelay)
    RepeatKeyCallback(self)
    
end

function GUITextInputWidget:OnRepeatableKeyPressed(key)
    
    -- Stop repeating whatever key was being repeated before, if any.
    ClearRepeatingKey(self)
    
    -- Begin repeating the given key.
    SetRepeatingKey(self, key)
    
end

function GUITextInputWidget:OnRepeatableKeyReleased(key)
    
    ClearRepeatingKey(self)
    
end

local kKeyRepeatFunctions =
{
    [InputKey.Left]             = GUITextInputWidget.OnLeftArrowKey,
    [InputKey.Right]            = GUITextInputWidget.OnRightArrowKey,
    [InputKey.Back]             = GUITextInputWidget.OnBackspaceKey,
    [InputKey.Delete]           = GUITextInputWidget.OnDeleteKey,
}
function GUITextInputWidget:GetKeyRepeatFunction(key)
    return kKeyRepeatFunctions[key]
end

local kKeyDownFunctions =
{
    [InputKey.Left]             = GUITextInputWidget.OnRepeatableKeyPressed,
    [InputKey.Right]            = GUITextInputWidget.OnRepeatableKeyPressed,
    [InputKey.Escape]           = GUITextInputWidget.OnEscapeKey,
    [InputKey.Return]           = GUITextInputWidget.OnEnterKey,
    [InputKey.NumPadEnter]      = GUITextInputWidget.OnEnterKey,
    [InputKey.Back]             = GUITextInputWidget.OnRepeatableKeyPressed,
    [InputKey.Delete]           = GUITextInputWidget.OnRepeatableKeyPressed,
}
function GUITextInputWidget:GetKeyDownFunction(key)
    return kKeyDownFunctions[key]
end

local kKeyUpFunctions =
{
    [InputKey.Left]             = GUITextInputWidget.OnRepeatableKeyReleased,
    [InputKey.Right]            = GUITextInputWidget.OnRepeatableKeyReleased,
    [InputKey.Back]             = GUITextInputWidget.OnRepeatableKeyReleased,
    [InputKey.Delete]           = GUITextInputWidget.OnRepeatableKeyReleased,
}
function GUITextInputWidget:GetKeyUpFunction(key)
    return kKeyUpFunctions[key]
end

function GUITextInputWidget:OnKey(key, down)
    
    assert(self:GetEditing())
    
    if down then
        local keyFunc = self:GetKeyDownFunction(key)
        if keyFunc then
            return (keyFunc(self, key))
        end
    else
        local keyFunc = self:GetKeyUpFunction(key)
        if keyFunc then
            return (keyFunc(self, key))
        end
    end
    
end

function GUITextInputWidget:OnCharacter(character)
    
    assert(self:GetEditing())
    assert(self.utf8Array ~= nil)
    
    -- Is it a valid character?
    if not self:GetIsValidCharacter(character) then
        return
    end
    
    -- Will this character make the string too long?
    if self:GetSelectionSize() == 0 and self:GetMaxCharacterCount() > 0 and #self.utf8Array >= self:GetMaxCharacterCount() then
        return
    end
    
    -- Now, add the character to the string, but keep track of the changes made so we can revert
    -- them if the new string is invalid for any reason.
    self.oldUtf8Array = Copy(self.utf8Array)
    
    -- Remember previous selection size so we can revert if the change is no good.
    local prevSelectionSize = self:GetSelectionSize()
    
    -- Delete characters if any are selected, but don't update the text just yet.
    if self:GetSelectionSize() > 0 then
        DeleteSelectionActual(self)
    end
    
    -- Insert new character
    table.insert(self.utf8Array, self:GetCursorIndex(), character)
    
    -- Convert back to regular string.
    local newText = StringFromUTF8(self.utf8Array)
    
    -- Check if the width limit just got exceeded.
    local maxWidth = self:GetMaxWidth()
    if maxWidth > 0 then
        
        local newWidth = self.displayText:CalculateTextSize(newText).x
        
        if newWidth > maxWidth then
            
            -- New character pushed it over the limit, revert it.
            self.utf8Array = self.oldUtf8Array
            
            self:SetSelectionSize(prevSelectionSize)
            
            return -- Do nothing more.
            
        end
        
    end
    
    self:PauseEvents()
        
        -- No way we have a selection still after this.
        self:SetSelectionSize(0)
        
        -- Clean up temporary value to revert to.
        self.oldUtf8Array = nil
        
        -- Advance the cursor.
        self:SetCursorIndex(self:GetCursorIndex() + 1)
        
        self:UpdateValueFromUTF8(self.utf8Array)
        self:FireEvent("OnCharacterAccepted", character)
        
        UpdateDisplayedText(self)
        
    self:ResumeEvents()
    
end

-- Returns the given value formatted as though it were a value of this widget.
-- Simply returns the given value, since this widget's value is always a string-type.  Does not
-- perform any length or width checks, as it is assumed that this value was originally produced by
-- this widget (Eg a previous value).
function GUITextInputWidget:GetValueString(value)
    return value
end
