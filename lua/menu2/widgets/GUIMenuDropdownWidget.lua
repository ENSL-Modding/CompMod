-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/widgets/GUIMenuDropdownWidget.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--    
--    GUIDropdownWidget that is themed appropriately for the menu.
--
--  Properties:
--      Choices             -- Array-style table of "choices".  Each "choice" is a table with two
--                             named fields:
--                                  displayString - the string to display for this choice.
--                                  value - the value associated with this choice.  Can be any type
--                                      the programmer desires.
--      Editing             -- Whether or not the dropdown is currently opened (and therefore the
--                             user is making a selection.
--      Value               -- The value that is currently selected in the dropdown.  If the value
--                             is not found in the "Choices" list, the dropdown selection will
--                             appear blank.
--      Label               -- The text that appears in the top left of this widget.
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

Script.Load("lua/GUI/widgets/GUIDropdownWidget.lua")
Script.Load("lua/menu2/widgets/GUIMenuScrollPane.lua")
Script.Load("lua/menu2/widgets/GUIMenuDropdownChoice.lua")
Script.Load("lua/menu2/widgets/GUIMenuExpansionArrowWidget.lua")
Script.Load("lua/menu2/GUIMenuBasicBox.lua")
Script.Load("lua/menu2/MenuStyles.lua")
Script.Load("lua/menu2/GUIMenuTruncatedText.lua")
Script.Load("lua/GUI/wrappers/FXState.lua")

---@class GUIMenuDropdownWidget : GUIDropdownWidget
---@field public GetFXState function @From FXState wrapper
---@field public UpdateFXStateOverride function @From FXState wrapper
---@field public AddFXReceiver function @From FXState wrapper
---@field public RemoveFXReceiver function @From FXState wrapper
local baseClass = GUIDropdownWidget
baseClass = GetFXStateWrappedClass(baseClass)
class "GUIMenuDropdownWidget" (baseClass)

local kMaxLabelLength = 475

GUIMenuDropdownWidget:AddCompositeClassProperty("Label", "label", "Text")

local kOpenExtraHeight = 200

function GUIMenuDropdownWidget:PostChoiceCreated(newChoice)
    if newChoice.SetMaxWidth then
        newChoice:SetMaxWidth(self.choicesPane:GetContentsItem():GetSize().x - MenuStyle.kWidgetPadding * 2)
    end
end

function GUIMenuDropdownWidget:GetOpenExtraHeight()
    return kOpenExtraHeight
end

function GUIMenuDropdownWidget:GetChoiceClass()
    return GUIMenuDropdownChoice
end

function GUIMenuDropdownWidget:GetDefaultSize()
    local result = Vector(MenuStyle.kDefaultWidgetSize)
    return result
end

function GUIMenuDropdownWidget:GetScrollPaneClass()
    return GUIMenuScrollPane
end

local function UpdateBackgroundSize(self, size)
    self.back:SetSize(self:GetSize())
end

local function FindChoiceObjectWithValue(self, value)
    for i=1, #self.choiceObjs do
        if self.choiceObjs[i]:GetValue() == value then
            return self.choiceObjs[i]
        end
    end
    return nil
end

local function UpdateLabelConstrainedArea(self)
    
    local labelTextSize = self.label:GetTextSize()
    self.label:SetSize(math.min(labelTextSize.x, kMaxLabelLength), labelTextSize.y)
    
end

local function GetValueDisplayTextMaxWidth(self)
    
    local remainingWidth = self:GetDefaultSize().x
    
    -- Label size and padding to left edge.
    remainingWidth = remainingWidth - self.label:GetPosition().x
    remainingWidth = remainingWidth - self.label:GetSize().x * self.label:GetScale().x
    
    -- Minimum spacing between label and choice text
    remainingWidth = remainingWidth - MenuStyle.kWidgetPadding
    
    -- Arrow size is static, already taken into account.
    remainingWidth = remainingWidth + self.decoyValueDisplay:GetPosition().x
    
    return remainingWidth
    
end

local function UpdateDisplayTextWidth(self)
    
    local remainingWidth = GetValueDisplayTextMaxWidth(self)
    
    self.valueDisplay:SetSize(math.min(remainingWidth, self.valueDisplay:GetTextSize().x), self.valueDisplay:GetTextSize().y)
    self.decoyValueDisplay:SetSize(math.min(remainingWidth, self.decoyValueDisplay:GetTextSize().x), self.decoyValueDisplay:GetTextSize().y)
    
end

function GUIMenuDropdownWidget:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    RequireType({"string", "nil"}, params.label, "params.label", errorDepth)
    
    -- Use a GUIMenuTruncatedText widget for value display
    PushParamChange(params, "valueDisplayClass", GUIMenuTruncatedText)
    PushParamChange(params, "cls", GUIMenuText)
    baseClass.Initialize(self, params, errorDepth)
    PopParamChange(params, "cls")
    PopParamChange(params, "valueDisplayClass")
    
    -- Theme value text appropriately.
    self.valueDisplay:SetColor(MenuStyle.kLightGrey)
    self.valueDisplay:SetFont(MenuStyle.kOptionFont)
    self:AddFXReceiver(self.valueDisplay:GetObject())
    
    -- Arrow widget to indicate that this is an expandable widget.
    self.arrow = CreateGUIObject("arrow", GUIMenuExpansionArrowWidget, self.header,
    {
        defaultColor = MenuStyle.kLightGrey,
    })
    self.arrow:AlignRight()
    self.arrow:SetPosition(-MenuStyle.kWidgetPadding, 0)
    self:AddFXReceiver(self.arrow)
    
    -- Text that displays the previously selected value (fades away while new choice flies in).
    self.decoyValueDisplay = CreateGUIObject("decoyValueDisplay", GUIMenuTruncatedText, self.header)
    self.decoyValueDisplay:AlignRight()
    self.decoyValueDisplay:SetText("")
    self.decoyValueDisplay:SetColor(MenuStyle.kLightGrey)
    self.decoyValueDisplay:SetFont(MenuStyle.kOptionFont)
    self.decoyValueDisplay:SetOpacity(0)
    self.decoyValueDisplay:SetPosition(self.arrow:GetPosition().x - self.arrow:GetSize().x * self.arrow:GetScale().x -MenuStyle.kWidgetPadding, 0)
    self.decoyValueDisplay:SetAutoScroll(false)
    self.valueDisplay:SetPosition(self.decoyValueDisplay:GetPosition())
    
    self:HookEvent(self.valueDisplay, "OnTextSizeChanged", UpdateDisplayTextWidth)
    
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
    self.label:SetSize(kMaxLabelLength, self:GetDefaultSize().y)
    self:AddFXReceiver(self.label:GetObject())
    
    -- Adjust list layout
    self.choicesLayout:SetSpacing(0)
    self.choicesLayout:SetPosition(-MenuStyle.kWidgetPadding, 0)
    
    -- Background box.
    self.back = CreateGUIObject("back", GUIMenuBasicBox, self)
    self.back:SetLayer(-1)
    self.back:SetSize(self:GetDefaultSize())
    
    -- Update background size.
    self:HookEvent(self, "OnSizeChanged", UpdateBackgroundSize)
    
    -- Update the size of the label.
    self:HookEvent(self.label, "OnTextSizeChanged", UpdateLabelConstrainedArea)
    
    -- Update the maximum width a choice can be.
    self:HookEvent(self.label, "OnSizeChanged", UpdateDisplayTextWidth)
    
    if params.label then
        self:SetLabel(params.label)
    end
    
end

function GUIMenuDropdownWidget:OnValueChanged()
    
    local value = self:GetValue()
    local obj = FindChoiceObjectWithValue(self, value)
    local displayString = obj and obj:GetText() or ""
    
    -- If the dropdown is open, this indicates the value change is due to the user making a
    -- selection, so animate that choice.
    if self:GetEditing() and obj then
        
        -- Fade out previous displayed value in header.  This creates the illusion that the old
        -- text is fading away with a new one flying in from the menu.
        self.decoyValueDisplay:ClearPropertyAnimations("Color")
        self.decoyValueDisplay:SetColor(MenuStyle.kLightGrey)
        self.decoyValueDisplay:SetText(self.valueDisplay:GetText())
        self.decoyValueDisplay:SetScroll(self.valueDisplay:GetScroll())
        self.decoyValueDisplay:AnimateProperty("Color", MenuStyle.kLightGrey * Color(1, 1, 1, 0), MenuAnimations.Fade)
        
        -- Make value display fly from the choice that was made to the header.
        local choiceSSPos = obj:GetScreenPosition(1, 0.5)
        local choiceLocalPos = self.header:ScreenSpaceToLocalSpace(choiceSSPos)
        
        -- Compensate for anchor.
        choiceLocalPos.x = choiceLocalPos.x - self.header:GetSize().x
        choiceLocalPos.y = choiceLocalPos.y - self.header:GetSize().y * 0.5
        
        self.valueDisplay:ClearPropertyAnimations("Position")
        self.valueDisplay:SetPosition(choiceLocalPos)
        self.valueDisplay:SetSize(obj:GetSize())
        self.valueDisplay:SetText(displayString)
        
        local maximumWidth = GetValueDisplayTextMaxWidth(self)
        local targetSize = Vector(math.min(self.valueDisplay:GetTextSize().x, maximumWidth), self.valueDisplay:GetTextSize().y, 0)
        
        self.valueDisplay:AnimateProperty("Size", targetSize, MenuAnimations.FlyIn)
        self.valueDisplay:AnimateProperty("Position", self.decoyValueDisplay:GetPosition(), MenuAnimations.FlyIn)
        
        -- Animate color of value from highlight blue to regular color.
        self.valueDisplay:ClearPropertyAnimations("Color")
        self.valueDisplay:SetColor(MenuStyle.kHighlight)
    
        PlayMenuSound("ButtonClick")
        
    else
        
        self.valueDisplay:SetText(displayString)
        
    end
    
end

function GUIMenuDropdownWidget:PerformOpening()
    self:AnimateProperty("Size", MenuStyle.kDefaultWidgetSize + Vector(0, self:GetOpenExtraHeight(), 0), MenuAnimations.FlyIn)
    self.arrow:PointUp()
end

function GUIMenuDropdownWidget:PerformClosing()
    self:AnimateProperty("Size", MenuStyle.kDefaultWidgetSize, MenuAnimations.FlyIn)
    self.arrow:PointDown()
end
