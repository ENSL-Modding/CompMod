-- ======= Copyright (c) 2017, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/widgets/GUIMenuPasswordEntryWidget.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    GUIMenuTextEntryWidget that has text censored, but with a toggleable button to un-censor it.
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
--      OnValueChanged      -- The value of the text has changed, and the widget is not in edit
--                             mode, indidcating that they have just accepted or cancelled an edit
--                             that resulted in the value being changed.  (Hint: use OnTextChanged
--                             if you want it to fire after every change even _during_ edit mode.)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/menu2/widgets/GUIMenuTextEntryWidget.lua")
Script.Load("lua/menu2/widgets/GUIMenuPasswordToggleButton.lua")

---@class GUIMenuPasswordEntryWidget : GUIMenuTextEntryWidget
class "GUIMenuPasswordEntryWidget" (GUIMenuTextEntryWidget)

local kCapsWarningTexture = PrecacheAsset("ui/newMenu/caps_lock_warning.dds")

local function UpdateCapsWarningPosition(self)
    local toggleSize = self.toggle:GetSize() * self.toggle:GetScale()
    self.capsWarning:SetX(-MenuStyle.kWidgetPadding*2 - toggleSize.x)
end

local function UpdateCapsLockWarning(self)
    
    local capsLockEnabled = GetGlobalEventDispatcher():GetCapsLock()
    
    if capsLockEnabled then
        
        self.capsWarning:AnimateProperty("Opacity", 1, MenuAnimations.Fade)
        
        self.back:AnimateProperty("FillColor", MenuStyle.kConflictedBackgroundColor, MenuAnimations.Fade)
        self.back:AnimateProperty("StrokeColor", MenuStyle.kConflictedStrokeColor, MenuAnimations.Fade)
        
    else
    
        self.capsWarning:AnimateProperty("Opacity", 0, MenuAnimations.Fade)
    
        self.back:AnimateProperty("FillColor", MenuStyle.kBasicBoxBackgroundColor, MenuAnimations.Fade)
        self.back:AnimateProperty("StrokeColor", MenuStyle.kBasicStrokeColor, MenuAnimations.Fade)
    
    end
    
end

function GUIMenuPasswordEntryWidget:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    PushParamChange(params, "isPassword", true)
    GUIMenuTextEntryWidget.Initialize(self, params, errorDepth)
    PopParamChange(params, "isPassword")
    
    self.toggle = CreateGUIObject("toggle", GUIMenuPasswordToggleButton, self)
    self.toggle:AlignRight()
    self.toggle:SetX(-MenuStyle.kWidgetPadding)
    self.toggle:SetValue(true)
    self.toggle:RemoveFXReceiver(self)
    self:RemoveFXReceiver(self.toggle)
    
    self.capsWarning = CreateGUIObject("capsWarning", GetTooltipWrappedClass(GUIObject), self)
    self.capsWarning:SetTooltip(Locale.ResolveString("CAPS_LOCK_WARNING"))
    self.capsWarning:AlignRight()
    self.capsWarning:SetTexture(kCapsWarningTexture)
    self.capsWarning:SetSizeFromTexture()
    self.capsWarning:SetColor(1, 1, 1, 1)
    self:HookEvent(self.toggle, "OnSizeChanged", UpdateCapsWarningPosition)
    self:HookEvent(self.toggle, "OnScaleChanged", UpdateCapsWarningPosition)
    UpdateCapsWarningPosition(self)
    
    self:HookEvent(GetGlobalEventDispatcher(), "OnCapsLockChanged", UpdateCapsLockWarning)
    UpdateCapsLockWarning(self)
    
    self:HookEvent(self.toggle, "OnValueChanged", self.SetIsPassword)
    
end
