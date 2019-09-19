-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/widgets/GUIMenuCommanderKeybindGrid.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--    
--    A GUIObject that contains the 11 keybinds for the grid of commander keys.
--@class GUIMenuCommanderKeybindGrid : GUIObject
--
--  Properties:
--      ResetButtonLabel    -- Text displayed on the reset button.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/GUIObject.lua")
Script.Load("lua/menu2/widgets/GUIMenuKeybindEntryWidgetSimple.lua")
Script.Load("lua/menu2/widgets/GUIMenuSimpleTextButton.lua")
Script.Load("lua/GUI/GUIText.lua")
Script.Load("lua/menu2/MenuUtilities.lua")

Script.Load("lua/menu2/wrappers/Option.lua")

---@class GUIMenuCommanderKeybindGrid : GUIObject
class "GUIMenuCommanderKeybindGrid" (GUIObject)

GUIMenuCommanderKeybindGrid:AddCompositeClassProperty("ResetButtonLabel", "resetButton", "Label")

local kButtonWidth = 206
local kTabHeight = 134
local kButtonHeight = 206
local kSpacing = 16
local kDividerLineThickness = 3

local keybindClass = GetOptionWrappedClass(GUIMenuKeybindEntryWidgetSimple)

local kDefaultKeys = { "Q", "W", "E", "A", "S", "D", "F", "Z", "X", "G", "V" }

local function OnSizeChanged(self, size)
    
    self:SetSize(size.x + kSpacing * 4, size.y + kSpacing * 2)
    
    -- Resize background to match this widget's size.
    self.back:SetSize(size.x + kSpacing * 2, size.y)
    
    -- Inset contents item.
    self.contents:SetSize(size)
    
end

local function OnResetButtonPressed(self)
    
    for i=1, #self.buttons do
        local button = self.buttons[i]
        repeat
            button:ResetBinding()
        until button:GetValue() ~= "None"
    end
    
end

function GUIMenuCommanderKeybindGrid:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    GUIObject.Initialize(self, params, errorDepth)
    
    self.back = CreateGUIObject("back", GUIMenuBasicBox, self)
    self.back:AlignCenter()
    self.back:SetLayer(-1)
    
    self.contents = self:CreateLocatorGUIItem()
    self.contents:AlignCenter()
    
    self.contentsLayout = CreateGUIObject("contentsLayout", GUIListLayout, self.contents, {orientation = "vertical"})
    self.contentsLayout:SetFrontPadding(kSpacing)
    self.contentsLayout:SetBackPadding(kSpacing)
    self.contentsLayout:SetSpacing(kSpacing)
    
    self:HookEvent(self.contentsLayout, "OnSizeChanged", OnSizeChanged)
    
    self.buttonHolder = CreateGUIObject("buttonHolder", GUIObject, self.contentsLayout)
    self.buttonHolder:AlignTop()
    
    self.resetButton = CreateGUIObject("resetButton", GUIMenuSimpleTextButton, self.contentsLayout)
    self.resetButton:SetLabel("RESET")
    self.resetButton:AlignTop()
    self:HookEvent(self.resetButton, "OnPressed", OnResetButtonPressed)
    
    self.buttons = {}
    
    local gridIdx = 1
    self.tabs = {}
    for i=1, 3 do
        local newTab = CreateGUIObject("tab"..tostring(i), keybindClass, self.buttonHolder,
        {
            optionPath = "input/Grid"..tostring(gridIdx),
            optionType = "string",
            default = kDefaultKeys[gridIdx],
            bindGroup = "commander",
            altLabel = "Commander Tab "..tostring(gridIdx),
        })
        newTab:SetSize(kButtonWidth, kTabHeight)
        newTab:SetPosition((kButtonWidth + kSpacing) * (i-1), 0)
        self.tabs[i] = newTab
        self.buttons[#self.buttons+1] = newTab
        gridIdx = gridIdx + 1
    end
    
    local row1YPosition = kTabHeight + kSpacing
    self.row1Buttons = {}
    for i=1, 4 do
        local newButton = CreateGUIObject("row1Button"..tostring(i), keybindClass, self.buttonHolder,
        {
            optionPath = "input/Grid"..tostring(gridIdx),
            optionType = "string",
            default = kDefaultKeys[gridIdx],
            bindGroup = "commander",
            altLabel = "Commander Row 1, Column "..tostring(gridIdx-3),
        })
        newButton:SetSize(kButtonWidth, kButtonHeight)
        newButton:SetPosition((kButtonWidth + kSpacing) * (i-1), row1YPosition)
        self.row1Buttons[i] = newButton
        self.buttons[#self.buttons+1] = newButton
        gridIdx = gridIdx + 1
    end
    
    local row2YPosition = row1YPosition + kButtonHeight + kSpacing
    self.row2Buttons = {}
    for i=1, 4 do
        local newButton = CreateGUIObject("row2Button"..tostring(i), keybindClass, self.buttonHolder,
        {
            optionPath = "input/Grid"..tostring(gridIdx),
            optionType = "string",
            default = kDefaultKeys[gridIdx], 
            bindGroup = "commander",
            altLabel = "Commander Row 2, Column "..tostring(gridIdx-7),
        })
        newButton:SetSize(kButtonWidth, kButtonHeight)
        newButton:SetPosition((kButtonWidth + kSpacing) * (i-1), row2YPosition)
        self.row2Buttons[i] = newButton
        self.buttons[#self.buttons+1] = newButton
        gridIdx = gridIdx + 1
    end
    
    self.buttonHolder:SetSize(kButtonWidth * 4 + kSpacing * 3, kButtonHeight * 2 + kTabHeight + kSpacing * 2)
    
end
