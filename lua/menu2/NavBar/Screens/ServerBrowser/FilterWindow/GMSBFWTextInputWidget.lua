-- ======= Copyright (c) 2017, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/NavBar/Screens/ServerBrowser/FilterWindow/GMSBFWTextInputWidget.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Server browser filter window themeing for GUIMenuTextInputWidget.
--
--  Properties:
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
--      OnValueChanged      -- The value of the text has changed, and the widget is not in edit
--                             mode, indidcating that they have just accepted or cancelled an edit
--                             that resulted in the value being changed.  (Hint: use OnTextChanged
--                             if you want it to fire after every change even _during_ edit mode.)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/menu2/widgets/GUIMenuTextInputWidget.lua")

---@class GMSBFWTextInputWidget : GUIMenuTextInputWidget
class "GMSBFWTextInputWidget" (GUIMenuTextInputWidget)

local kFont = MenuStyle.kServerBrowserFiltersWindowChoiceFont
local kColor = MenuStyle.kOptionHeadingColor

function GMSBFWTextInputWidget:SetupVisuals()
    
    GUIMenuTextInputWidget.SetupVisuals(self)
    
    self.cursor:SetColor(kColor)
    self.cursor:SetOpacity(0)
    
    self.displayText:SetColor(kColor)
    
end

function GMSBFWTextInputWidget:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    PushParamChange(params, "font", params.font or kFont)
    GUIMenuTextInputWidget.Initialize(self, params, errorDepth)
    PopParamChange(params, "font")
    
end

function GMSBFWTextInputWidget:GetCursorCharacterOffset()
    local result = Vector(-11, -4, 0)
    return result
end

