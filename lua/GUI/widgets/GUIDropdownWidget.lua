-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/GUI/widgets/GUIDropdownWidget.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Widget that expands to reveal a list of choices.
--
--  Parameters (* = required)
--      choices
--      valueDisplayClass   Class that is used to display the currently selected value.  Defaults
--                          to GUIText.
--  
--  Properties:
--      Choices             Array-style table of "choices".  Each "choice" is a table with two
--                          named fields:
--                               displayString - the string to display for this choice.
--                               value - the value associated with this choice.  Can be any type
--                                   the programmer desires.
--      Editing             Whether or not the dropdown is currently opened (and therefore the
--                          user is making a selection.
--      Value               The value that is currently selected in the dropdown.  If the value
--                          is not found in the "Choices" list, the dropdown selection will
--                          appear blank.
--  
--  Events:
--      OnUserOpened        The dropdown has just been opened due to user interaction.
--      OnUserClosed        The dropdown has just been closed due to user interaction.
--      OnCancelled         The user clicked outside or pressed ESC to cancel the choice.
--      OnAccepted          The user chose something from the dropdown.
--      OnChoicePicked      The user chose something from the dropdown.
--                              chosen -- The value of the choice that was picked.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/GUIObject.lua")
Script.Load("lua/GUI/widgets/GUIScrollPane.lua")
Script.Load("lua/GUI/widgets/GUIScrollBarWidget.lua")
Script.Load("lua/GUI/widgets/GUIDropdownChoice.lua")

Script.Load("lua/GUI/wrappers/Editable.lua")

---@class GUIDropdownWidget : GUIObject
---@field public GetEditing function @From Editable wrapper
---@field public SetEditing function @From Editable wrapper
---@field protected _BeginEditing function @From Editable wrapper
---@field protected _EndEditing function @From Editable wrapper
---@field public GetMouseOver function @From CursorInteractable wrapper
---@field public GetPressed function @From CursorInteractable wrapper
local baseClass = GUIObject
baseClass = GetEditableWrappedClass(baseClass)
baseClass = GetCursorInteractableWrappedClass(baseClass)
class "GUIDropdownWidget" (baseClass)

local kDefaultOpenExtraHeight = 200
local kDefaultSize = Vector(600, 100, 0)
local kScrollSpeedMult = 0.5

GUIDropdownWidget.NoValue = ReadOnly{"GUIDropdownWidget.NoValue"} -- dummy value used when no choice is selected.

GUIDropdownWidget:AddClassProperty("Choices", {}, true)
GUIDropdownWidget:AddClassProperty("Value", GUIDropdownWidget.NoValue)

function GUIDropdownWidget:GetOpenExtraHeight()
    return kDefaultOpenExtraHeight
end

function GUIDropdownWidget:GetChoiceClass()
    return GUIDropdownChoice
end

function GUIDropdownWidget:GetDefaultSize()
    local result = Vector(kDefaultSize)
    return result
end

function GUIDropdownWidget:GetScrollPaneClass()
    return GUIScrollPane
end

function GUIDropdownWidget:_BeginEditing()
    -- Dropdown has just been opened.
    -- Dropdown must be closed before other widgets can be interacted with.
    self:ListenForKeyInteractions()
    self:AllowChildInteractions()
    self:PerformOpening()
end

function GUIDropdownWidget:_EndEditing()
    -- Dropdown has just been closed.
    -- Allow other widgets to be interacted with now.
    self:StopListeningForKeyInteractions()
    self:BlockChildInteractions()
    self:PerformClosing()
end

-- Returns the first choice object found with this value, and the index it was found at.  Returns
-- nil if not found.
local function FindChoiceObjectForValue(self, value)
    
    for i=1, #self.choiceObjs do
        if self.choiceObjs[i]:GetValue() == value then
            return self.choiceObjs[i], i
        end
    end
    
    return nil, nil
    
end

local function ChoiceExistsForValue(self, value)
    
    local choices = self:GetChoices()
    for i=1, #choices do
        if choices[i].value == value then
            return true
        end
    end
    
    return false
    
end

local function OnChoicePicked(self, value)
    self:SetValue(value)
    self:FireEvent("OnUserClosed")
    self:FireEvent("OnChoicePicked", value)
    self:FireEvent("OnAccepted")
end

local function OnChoicesChanged(self)
    
    -- Remove choice objects whose choices no longer exist.
    for i=#self.choiceObjs, 1, -1 do
        if not ChoiceExistsForValue(self, self.choiceObjs[i]:GetValue()) then
            self.choiceObjs[i]:Destroy()
            table.remove(self.choiceObjs, i)
        end
    end
    
    -- Add choice objects for new choices that don't have any.
    local choices = self:GetChoices()
    for i=1, #choices do
        local obj, idx = FindChoiceObjectForValue(self, choices[i].value)
        if not obj then
            local newChoice = CreateGUIObject("choice", self:GetChoiceClass(), self.choicesLayout,
            {
                value = choices[i].value,
                displayString = choices[i].displayString,
            })
            newChoice:AlignTopRight()
            self:HookEvent(newChoice, "OnChosen", OnChoicePicked)
            
            self:PostChoiceCreated(newChoice)
            
            table.insert(self.choiceObjs, newChoice)
        end
    end
    
    -- Set the layers of the choice objects so that they will be arranged in the same order as the
    -- Choices property.
    for i=1, #choices do
        local obj, idx = FindChoiceObjectForValue(self, choices[i].value)
        assert(obj) -- should have been created above if it was missing.
        obj:SetLayer(i)
    end
    
    self:OnValueChanged()
    
end

local function OnSizeChanged(self, size)
    self.contents:SetSize(self:GetDefaultSize().x, size.y - self:GetDefaultSize().y)
end

local function OnLayoutSizeChanged(self, size)
    self.choicesPane:SetPaneSize(self.choicesPane:GetContentsItem():GetSize().x, size.y)
end

function GUIDropdownWidget:PostChoiceCreated(newChoice)
end

function GUIDropdownWidget:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    RequireType({"table", "nil"}, params.choices, "params.choices", errorDepth)
    if params.choices then
        for i=1, #params.choices do
            RequireType("table", params.choices[i], string.format("params.choices[%d]", i), errorDepth)
            RequireType("string", params.choices[i].displayString, string.format("params.choices[%d].displayString", i), errorDepth)
            if params.choices[i].value == nil then
                error(string.format("Expected a value for params.choices[%d].value, got nil instead.", i), errorDepth)
            end
        end
    end
    
    baseClass.Initialize(self, params, errorDepth)
    
    self:SetSize(self:GetDefaultSize())
    
    self.choiceObjs = {} -- array of GUIDropdownChoice objects.
    
    -- The top part of the widget -- doesn't change when dropdown expands.
    self.header = self:CreateLocatorGUIItem()
    self.header:SetSize(self:GetDefaultSize())
    self.header:SetLayer(5)
    
    -- Object that holds the contents of the bottom part of the widget.
    self.contents = self:CreateLocatorGUIItem()
    self.contents:SetSize(self:GetDefaultSize().x, 0)
    self.contents:SetCropMaxCornerNormalized(1, 1) -- enable cropping
    self.contents:AlignBottom()
    self.contents:SetLayer(1)
    
    -- Syncronize the size of the contents to the size of the widget.
    self:HookEvent(self, "OnSizeChanged", OnSizeChanged)
    
    -- Scroll pane that contains the choices.
    self.choicesPane = CreateGUIObject("choicesPane", self:GetScrollPaneClass(), self.contents,
    {
        horizontalScrollBarEnabled = false,
        scrollSpeedMult = kScrollSpeedMult,
    })
    self.choicesPane:SetSize(self:GetDefaultSize().x, self:GetOpenExtraHeight())
    self.choicesPane:GetChildHoldingItem():AlignTopRight()
    
    -- List layout that contains the choices.
    self.choicesLayout = CreateGUIObject("choicesLayout", GUIListLayout, self.choicesPane, {orientation = "vertical"})
    self.choicesLayout:AlignTopRight()
    self:HookEvent(self.choicesLayout, "OnSizeChanged", OnLayoutSizeChanged)
    
    -- Text that displays the currently selected value.
    local valueDisplayClass = params.valueDisplayClass or GUIText
    self.valueDisplay = CreateGUIObject("valueDisplay", valueDisplayClass, self.header, params)
    self.valueDisplay:AlignRight()
    self.valueDisplay:SetText("")
    
    -- Don't allow choices to be selected when dropdown is closed.
    self:BlockChildInteractions()
    
    self:HookEvent(self, "OnChoicesChanged", OnChoicesChanged)
    self:HookEvent(self, "OnValueChanged", self.OnValueChanged)
    
    if params.choices then
        self:SetChoices(params.choices)
    end
    
end

function GUIDropdownWidget:OnValueChanged()
    
    local value = self:GetValue()
    
    for i=1, #self.choiceObjs do
        if self.choiceObjs[i].value == value then
            self.valueDisplay:SetText(self.choiceObjs[i].displayString)
            return
        end
    end
    
    self.valueDisplay:SetText("")
    
end

-- Override for animations
function GUIDropdownWidget:PerformOpening()
    self:SetSize(self:GetSize(true) + Vector(0, self:GetOpenExtraHeight(), 0))
end

-- Override for animations
function GUIDropdownWidget:PerformClosing()
    self:SetSize(self:GetSize(true) - Vector(0, self:GetOpenExtraHeight(), 0))
end

function GUIDropdownWidget:CancelChoice()
    
    assert(self:GetEditing())
    
    self:PauseEvents()
        self:SetEditing(false)
        self:FireEvent("OnUserClosed")
        self:FireEvent("OnCancelled")
    self:ResumeEvents()
    
end

function GUIDropdownWidget:OnMouseClick()
    
    if self:GetEditing() then
        -- If it's already open, and we clicked on the header, close it.
        local mousePos = GetGlobalEventDispatcher():GetMousePosition()
        if self.header:GetIsPointOverItem(mousePos) then
            self:CancelChoice()
            return true
        end
        
        -- Do nothing further if it is open, but not clicked over header.
        return true
    end
    
    self:SetEditing(true)
    self:FireEvent("OnUserOpened")
    
    return true
    
end

function GUIDropdownWidget:OnKey(key, down)
    
    if key == InputKey.Escape then
        self:CancelChoice()
        return true
    end
    
    return false
    
end

-- Returns the given value formatted as though it were a value of this widget.
-- Attempts to find the value in the choices, and if found, returns the choice's display string,
-- otherwise just returns itself.
function GUIDropdownWidget:GetValueString(value)
    
    local choice
    local choices = self:GetChoices()
    for i=1, #choices do
        if choices[i].value == value then
            choice = choices[i]
            break
        end
    end
    
    if choice then
        return choice.displayString
    else
        local result = tostring(value)
        return result
    end
    
end
