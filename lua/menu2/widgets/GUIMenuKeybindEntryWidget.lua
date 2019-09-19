-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/widgets/GUIMenuKeybindEntryWidget.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--    
--    Adds a label and a reset/clear button to GUIMenuKeybindEntryWidgetSimple.
--@class GUIMenuKeybindEntryWidget : GUIMenuKeybindEntryWidgetSimple
--
--  Properties:
--      Value           -- The _string_ of the current keybind for this widget (or "None" if
--                         unassigned).
--      IsConflicted    -- Whether or not this keybind has a conflict with another keybind (same
--                         group and same key).
--      IsInherited     -- Whether or not the _current value_ of the widget is inherited from the
--                         "InheritFrom" widget. (Note: must never be true if inheritFrom was
--                         nil)
--      Label           -- The text to display for the label of this widget.
--      
--  Events:
--      OnEditBegin         -- Whenver this widget begins listeing for key inputs.
--      OnEditAccepted      -- Whenver this widget changes its value to the given input.
--      OnEditCancelled     -- Whenver this widget stops listening for input without changing values.
--      OnEditEnd           -- Whenver this widget is no longer listening for input.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/menu2/widgets/GUIMenuKeybindEntryWidgetSimple.lua")
Script.Load("lua/menu2/widgets/GUIMenuSimpleTextButton.lua")
Script.Load("lua/menu2/GUIMenuTruncatedText.lua")
Script.Load("lua/menu2/wrappers/Tooltip.lua")

---@class GUIMenuKeybindEntryWidget : GUIMenuKeybindEntryWidgetSimple
class "GUIMenuKeybindEntryWidget" (GUIMenuKeybindEntryWidgetSimple)

-- A bit of a hack... GUIMenuKeybindEntryWidgetSimple has defined GetLabel() to deal with the fact
-- that it doesn't have a label of its own... so we need to remove it now otherwise GetLabel() will
-- forever be defined as this for all derived classes.
GUIMenuKeybindEntryWidget.GetLabel = nil

local kMaxLabelWidth = 500

GUIMenuKeybindEntryWidget:AddCompositeClassProperty("Label", "label", "Text")

local kClearButtonSize = Vector(80, 75, 0)

local function UpdateResetButtonStatus(self)
    
    local clear = 0
    local inherit = 1
    local reset = 2
    local disabled = 3
    local action
    
    -- Figure out which action the button press will represent (from ResetBinding() in GUIBaseKeybindEntryWidget.lua)
    if self:GetValue() ~= "None" and not self:GetIsInherited() then
        if self.keybind.inheritFrom then
            action = inherit
        else
            action = clear
        end
    elseif self:GetIsInherited() then
        action = clear
    else -- value is None
        if self.keybind.default == "None" then
            if self.keybind.inheritFrom then
                action = inherit
            else
                action = disabled
            end
        else
            action = reset
        end
    end
    
    -- Setup the button according to the predicted action.
    if action == clear then
        self.resetButton:SetEnabled(true)
        self.resetButton:SetTooltip(Locale.ResolveString("OPTION_CLEAR_BIND"))
        self.resetButton:SetLabel("X")
    elseif action == inherit then
        self.resetButton:SetEnabled(true)
        self.resetButton:SetTooltip(Locale.ResolveString("OPTION_INHERIT_BIND"))
        self.resetButton:SetLabel("<")
    elseif action == reset then
        self.resetButton:SetEnabled(true)
        self.resetButton:SetTooltip(Locale.ResolveString("OPTION_RESET_BIND"))
        self.resetButton:SetLabel("R")
    else -- action == disabled
        self.resetButton:SetEnabled(false)
        self.resetButton:SetTooltip("")
        self.resetButton:SetLabel("")
    end
    
end

local function OnEditingChanged(self)
    
    -- If listening is active, disable child interactions so we cannot, for example, click the
    -- reset button.
    if self:GetEditing() then
        self.resetButton:StopListeningForCursorInteractions()
    else
        self.resetButton:ListenForCursorInteractions()
    end
    
end

local function OnLabelTextSizeChanged(self)
    self.label:SetSize(math.min(kMaxLabelWidth, self.label:GetTextSize().x), self.label:GetTextSize().y)
end

function GUIMenuKeybindEntryWidget:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    GUIMenuKeybindEntryWidgetSimple.Initialize(self, params, errorDepth)
    
    self.resetButton = CreateGUIObject("resetButton", GetTooltipWrappedClass(GUIMenuSimpleTextButton), self)
    self.resetButton:AlignRight()
    self.resetButton:SetPosition(-MenuStyle.kWidgetPadding, 0)
    self.resetButton:SetAutoSize(false)
    self.resetButton:SetSize(kClearButtonSize)
    
    -- Reset button has its own state.
    self.resetButton:RemoveFXReceiver(self)
    self:RemoveFXReceiver(self.resetButton)
    
    self.keybind:AlignRight()
    self.keybind:SetPosition(-MenuStyle.kWidgetPadding - kClearButtonSize.x - MenuStyle.kWidgetContentsSpacing, 0)
    
    PushParamChange(params, "cls", GUIMenuText)
    self.label = CreateGUIObject("label", GUIMenuTruncatedText, self, params)
    PopParamChange(params, "cls")
    
    self.label:SetFont(MenuStyle.kOptionFont)
    self.label:SetText("LABEL")
    self.label:AlignLeft()
    self.label:SetPosition(MenuStyle.kWidgetPadding, 0)
    self.label:SetColor(MenuStyle.kLightGrey)
    self:HookEvent(self.label, "OnTextSizeChanged", OnLabelTextSizeChanged)
    self.keybind:AddFXReceiver(self.label:GetObject())
    
    self.keybind:HookEvent(self.resetButton, "OnPressed", self.keybind.ResetBinding)
    self:HookEvent(self.keybind, "OnValueChanged", UpdateResetButtonStatus)
    self:HookEvent(self.keybind, "OnIsInheritedChanged", UpdateResetButtonStatus)
    self:HookEvent(self, "OnEditingChanged", OnEditingChanged)
    
    self:SetSize(MenuStyle.kKeybindWidgetSize)
    
    UpdateResetButtonStatus(self)
    
end
