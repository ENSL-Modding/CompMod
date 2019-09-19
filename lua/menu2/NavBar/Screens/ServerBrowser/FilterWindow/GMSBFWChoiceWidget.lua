-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. ============
--
-- lua/menu2/NavBar/Screens/ServerBrowser/FilterWindow/GMSBFWChoiceWidget.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    A widget that lets the user make a choice.  Not a dropdown, but kind of like a horizontal spin box.
--  
--  Properties
--      Choices     Array-style table of "choices"  Each "choice" is a table with two named fields:
--                      displayString       the string to display for this choice.
--                      value               the value associated with this choice.  Can be any type
--                                          the programmer desires.
--      Label       Text displayed in the label for this widget.
--      Value       The value that is currently selected.  If the value is not found in the
--                  "choices" list, selection will appear blank.
--  
-- ========= For more information, visit us at http://www.unknownworlds.com =======================

Script.Load("lua/GUI/GUIText.lua")
Script.Load("lua/menu2/GUIMenuBasicBox.lua")
Script.Load("lua/menu2/widgets/GUIMenuScrollBarButton.lua")

---@class GMSBFWChoiceWidget : GUIObject
class "GMSBFWChoiceWidget" (GUIObject)

local kFont = MenuStyle.kServerBrowserFiltersWindowFont
local kLabelColor = MenuStyle.kOptionHeadingColor

local kChoiceBoxHeight = 62
local kButtonPadding = 14

local kChoiceFont = MenuStyle.kServerBrowserFiltersWindowChoiceFont

local kSpacing = 5

GMSBFWChoiceWidget.NoValue = ReadOnly{"GMSBFWChoiceWidget.NoValue"}

GMSBFWChoiceWidget:AddCompositeClassProperty("Label", "label", "Text")
GMSBFWChoiceWidget:AddClassProperty("Choices", {}, true)
GMSBFWChoiceWidget:AddClassProperty("Value", GMSBFWChoiceWidget.NoValue)

local function SetChoiceBoxWidth(choiceBox, size)
    choiceBox:SetSize(size.x, choiceBox:GetSize().y)
end

local function GetChoiceIndexMatchingValue(self, value)
    local choices = self:GetChoices()
    for i=1, #choices do
        if choices[i].value == value then
            return i
        end
    end
    return -1
end

local function OnLeftClicked(self)
    PlayMenuSound("ButtonClick")
    local idx = GetChoiceIndexMatchingValue(self, self:GetValue())
    local choices = self:GetChoices()
    idx = ((idx - 2) % #choices) + 1
    
    self:PauseEvents()
        local prevValue = self:GetValue()
        self:SetValue(choices[idx].value)
        self:FireEvent("OnValueChangedByUser", self:GetValue(), prevValue)
    self:ResumeEvents()
end

local function OnRightClicked(self)
    PlayMenuSound("ButtonClick")
    local idx = GetChoiceIndexMatchingValue(self, self:GetValue())
    local choices = self:GetChoices()
    idx = (idx % #choices) + 1
    
    self:PauseEvents()
        local prevValue = self:GetValue()
        self:SetValue(choices[idx].value)
        self:FireEvent("OnValueChangedByUser", self:GetValue(), prevValue)
    self:ResumeEvents()
end

local function UpdateDisplayedChoice(self)
    
    local value = self:GetValue()
    local idx = GetChoiceIndexMatchingValue(self, value)
    
    local xPos = self:GetSize().x * (1 - idx)
    self.choicesHolder:AnimateProperty("Position", Vector(xPos, 0, 0), MenuAnimations.FlyIn)
    
end

local function UpdateChoicesObjects(self)
    
    local choices = self:GetChoices()
    
    -- Add more choice objects until we have no fewer than the number of choices.
    while #self.choiceObjs < #choices do
        local newChoice = CreateGUIObject("choice", GUIText, self.choicesHolder)
        newChoice:SetFont(kChoiceFont)
        newChoice:SetColor(kLabelColor)
        newChoice:SetHotSpot(0.5, 0.5)
        newChoice:SetAnchor(0, 0.5)
        table.insert(self.choiceObjs, newChoice)
    end
    
    -- Remove choice objects until we have no more than the number of choices.
    while #self.choiceObjs > #choices do
        local destroyingChoice = self.choiceObjs[#self.choiceObjs]
        table.remove(self.choiceObjs, destroyingChoice)
        destroyingChoice:Destroy()
    end
    
    assert(#choices == #self.choiceObjs)
    
    -- Configure the choice objects.
    for i=1, #choices do
        local choiceObj = self.choiceObjs[i]
        local choice = choices[i]
        choiceObj:SetText(choice.displayString)
        choiceObj:SetPosition(self:GetSize().x * (i-0.5), 0, 0)
    end
    
    self.choicesHolder:SetSize(self:GetSize().x * #choices, kChoiceBoxHeight)
    
    UpdateDisplayedChoice(self)
    
end

function GMSBFWChoiceWidget:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    RequireType({"string", "nil"}, params.label, "params.label", errorDepth)
    RequireType({"table", "nil"}, params.choices, "params.choices", errorDepth)
    if params.choices then
        for key, value in pairs(params.choices) do
            if type(key) ~= "number" or math.floor(key) ~= key or key < 1 or key > #params.choices then
                error(string.format("Expected an array-style table of choices for params.choices, but found some non-array keys present (got '%s' as a key)", key), errorDepth)
            end
            
            RequireType("table", params.choices[key], string.format("params.choices[%d]", key), errorDepth)
            for key2, value2 in pairs(value) do
                if key2 ~= "displayString" and key2 ~= "value" then
                    error(string.format("Choices are expected to be tables with exactly two keys: 'displayString' and 'value', but found key '%s'", key2), errorDepth)
                end
                RequireType("string", params.choices[key].displayString, string.format("params.choices[%d].displayString", key), errorDepth)
                if key2 == "value" and value2 == nil then
                    error(string.format("Got nil for params.choices[%d].value.  Nil is not allowed as a choice value.", key), errorDepth)
                end
            end
        end
    end
    
    GUIObject.Initialize(self, params, errorDepth)
    
    self.layout = CreateGUIObject("layout", GUIListLayout, self, {orientation="vertical"})
    self.layout:SetSpacing(kSpacing)
    
    self.label = CreateGUIObject("label", GUIText, self.layout)
    self.label:SetFont(kFont)
    self.label:SetColor(kLabelColor)
    
    self.choiceBox = CreateGUIObject("choiceBox", GUIMenuBasicBox, self.layout)
    self.choiceBox:SetSize(self.choiceBox:GetSize().x, kChoiceBoxHeight)
    self.choiceBox:HookEvent(self, "OnSizeChanged", SetChoiceBoxWidth)
    
    self.leftButton = CreateGUIObject("leftButton", GUIMenuScrollBarButton, self.choiceBox, {direction="Left"})
    self.leftButton:AlignLeft()
    self.leftButton:SetPosition(kButtonPadding, 0)
    self:HookEvent(self.leftButton, "OnPressed", OnLeftClicked)
    
    self.rightButton = CreateGUIObject("rightButton", GUIMenuScrollBarButton, self.choiceBox, {direction="Right"})
    self.rightButton:AlignRight()
    self.rightButton:SetPosition(-kButtonPadding, 0)
    self:HookEvent(self.rightButton, "OnPressed", OnRightClicked)
    
    self.choicesViewArea = CreateGUIObject("choicesViewArea", GUIObject, self.choiceBox)
    self.choicesViewArea:HookEvent(self.choiceBox, "OnSizeChanged", self.choicesViewArea.SetSize)
    self.choicesViewArea:SetCropMin(0, 0)
    self.choicesViewArea:SetCropMax(1, 1)
    
    self.choicesHolder = CreateGUIObject("choicesHolder", GUIObject, self.choicesViewArea)
    
    self.choiceObjs = {}
    
    self:HookEvent(self, "OnChoicesChanged", UpdateChoicesObjects)
    self:HookEvent(self, "OnValueChanged", UpdateDisplayedChoice)
    self:HookEvent(self, "OnSizeChanged", UpdateChoicesObjects)
    
    self:SetSize(self:GetSize().x, kChoiceBoxHeight + kSpacing + self.label:GetSize().y)
    
    if params.label then
        self:SetLabel(params.label)
    end
    
    if params.default ~= nil then
        self:SetValue(params.default)
    end
    
    if params.choices then
        self:SetChoices(params.choices)
    end
    
end
