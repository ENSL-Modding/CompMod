-- ======= Copyright (c) 2017, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/widgets/GUIMenuTextInputWidget.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Menu themeing for GUITextInputWidget and GUINumberInputWidget.
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
--      (number only)
--      MinValue            -- The minimum value that the number entered can have.
--      MaxValue            -- The maximum value that the number entered can have.
--      DecimalPlaces       -- The number of decimal places the number entered can have.  0 means
--                             only integers will be allowed.
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

Script.Load("lua/GUI/widgets/GUITextInputWidget.lua")
Script.Load("lua/GUI/widgets/GUINumberInputWidget.lua")
Script.Load("lua/GUI/wrappers/FXState.lua")
Script.Load("lua/menu2/MenuStyles.lua")

---@class GUIMenuTextInputWidget : GUITextInputWidget
---@field public GetFXState function @From FXState wrapper
---@field public UpdateFXStateOverride function @From FXState wrapper
---@field public AddFXReceiver function @From FXState wrapper
---@field public RemoveFXReceiver function @From FXState wrapper
local textBaseClass = GUITextInputWidget
textBaseClass = GetFXStateWrappedClass(textBaseClass)
class "GUIMenuTextInputWidget" (textBaseClass)

---@class GUIMenuNumberInputWidget : GUINumberInputWidget
---@field public GetFXState function @From FXState wrapper
---@field public UpdateFXStateOverride function @From FXState wrapper
---@field public AddFXReceiver function @From FXState wrapper
---@field public RemoveFXReceiver function @From FXState wrapper
local numberBaseClass = GUINumberInputWidget
numberBaseClass = GetFXStateWrappedClass(numberBaseClass)
class "GUIMenuNumberInputWidget" (numberBaseClass)

-- Adds a composite class property for both GUIMenuTextInputWidget and GUIMenuNumberInputWidget.
local function AddCompositeClassProperties(p1, p2, p3)
    GUIMenuTextInputWidget:AddCompositeClassProperty(p1, p2, p3)
    GUIMenuNumberInputWidget:AddCompositeClassProperty(p1, p2, p3)
end

-- Defines a method for both GUIMenuTextInputWidget and GUIMenuNumberInputWidget.
local function DefineMethod(name, method)
    GUIMenuTextInputWidget[name] = method
    GUIMenuNumberInputWidget[name] = method
end

AddCompositeClassProperties("_CursorColor", "cursor", "Color")
AddCompositeClassProperties("_CursorPosition", "cursor", "Position")
AddCompositeClassProperties("_SelectionBoxColor", "selectionBox", "Color")
AddCompositeClassProperties("_SelectionBoxPosition", "selectionBox", "Position")
AddCompositeClassProperties("_SelectionBoxSize", "selectionBox", "Size")

local kDefaultFont = MenuStyle.kOptionFont
local kNormalColor = MenuStyle.kLightGrey
local kSelectionBoxColor = Color(0, 0.5, 1, 0.5)

DefineMethod("GetCursorCharacterOffset",
        function(self)
            local result = Vector(-2, -4, 0)
            return result
        end)

local function UpdateSelectionVisuals(self)
    
    if not self:GetEditing() then
        return
    end
    
    -- Fade out cursor when selection box is visible, and back up when it's not.
    local cursorColor = Color(self:Get_CursorColor(true))
    if self:GetSelectionSize() == 0 then
        cursorColor.a = 1
    else
        cursorColor.a = 0
    end
    self:AnimateProperty("_CursorColor", cursorColor, MenuAnimations.Fade)
    
    -- Move selection box to cover selection.
    local xPos = self:GetLocalXOffsetByCursorIndex(self:GetCursorIndex())
    local xSize = self:GetLocalXOffsetByCursorIndex(self:GetCursorIndex() + self:GetSelectionSize()) - xPos
    
    self:AnimateProperty("_SelectionBoxSize", Vector(xSize, self:GetSize().y, 0), MenuAnimations.FlyIn)
    self:AnimateProperty("_SelectionBoxPosition", Vector(xPos, 0, 0), MenuAnimations.FlyIn)
    
end

local function UpdateCursorVisuals(self)
    
    if not self:GetEditing() then
        return
    end
    
    local cursorPos = Vector(self:GetLocalXOffsetByCursorIndex(self:GetCursorIndex()), 0, 0) + self:GetCursorCharacterOffset()
    
    local animationParams
    if self.repeatingKey then
        -- If a key is being repeated, the action is happening fast, so move the carat faster.
        animationParams = MenuAnimations.FlyInFast
    else
        animationParams = MenuAnimations.FlyIn
    end
    
    self:AnimateProperty("_CursorPosition", cursorPos, animationParams)
    
end

local function OnEditAccepted(self)
    PlayMenuSound("AcceptChoice")
end

local function OnEditCancelled(self)
    PlayMenuSound("CancelChoice")
end

local function OnFXStateChanged(self, state, prevState)
    if state == "editing" then
        
        PlayMenuSound("BeginChoice")
        
        -- Make cursor flash
        self:Set_CursorColor(MenuStyle.kOffWhite)
        self:AnimateProperty("_CursorColor", nil, MenuAnimations.HighlightFlashColor)
        
        -- Make cursor pulse
        self:AnimateProperty("_CursorColor", nil, MenuAnimations.PulseOpacityLight)
        
        -- Fade up selection box.
        self:AnimateProperty("_SelectionBoxColor", kSelectionBoxColor, MenuAnimations.Fade)
        
        -- Clear cursor animation so it is instantly where it should be.
        self:ClearPropertyAnimations("_CursorPosition")
    
    else
        
        -- Make cursor fade out.
        self:ClearPropertyAnimations("_CursorColor")
        local cursorColor = Color(MenuStyle.kOffWhite)
        cursorColor.a = 0
        self:AnimateProperty("_CursorColor", cursorColor, MenuAnimations.Fade)
        
        -- Make selection box fade out.
        local boxColor = Color(kSelectionBoxColor)
        boxColor.a = 0
        self:AnimateProperty("_SelectionBoxColor", boxColor, MenuAnimations.Fade)
    
    end
end

DefineMethod("SetupVisuals", function(self)
    
    self.cursor = self:CreateTextGUIItem()
    self.cursor:SetFontName(self:GetFontName())
    self.cursor:SetText(self:GetCursorCharacter())
    self.cursor:SetColor(kNormalColor)
    self.cursor:SetOpacity(0)
    self.cursor:AlignLeft()
    
    self.selectionBox = self:CreateGUIItem()
    self.selectionBox:SetColor(kSelectionBoxColor)
    self.selectionBox:SetOpacity(0)
    self.selectionBox:SetLayer(-1)
    self.selectionBox:AlignLeft()
    
    -- Have to create a separate item to display the text, as we might need to store it separately
    -- from the visuals (password obscuring).
    self.displayText = CreateGUIObject("displayText", GUIMenuText, self)
    self.displayText:AlignLeft()
    self.displayText:SetColor(kNormalColor)
    
    self:HookEvent(self, "OnSelectionSizeChanged", UpdateSelectionVisuals)
    self:HookEvent(self, "OnCursorIndexChanged", UpdateCursorVisuals)
    self:HookEvent(self, "OnIsPasswordChanged", UpdateCursorVisuals)
    self:HookEvent(self.displayText, "OnInternalFontChanged", UpdateCursorVisuals)
    self:HookEvent(self, "OnIsPasswordChanged", UpdateSelectionVisuals)
    self:HookEvent(self, "OnFXStateChanged", OnFXStateChanged)
    
    self:HookEvent(self, "OnEditAccepted", OnEditAccepted)
    self:HookEvent(self, "OnEditCancelled", OnEditCancelled)
    
end)

DefineMethod("GetCursorPosition", function(self, static)
    local result = self:Get_CursorPosition(static)
    return result
end)

do -- Define extended methods for the two classes.
    
    local function GetInitializeBody(thisClass, baseClass)
        
        return function(self, params, errorDepth)
            errorDepth = (errorDepth or 1) + 1
            
            PushParamChange(params, "font", params.font or kDefaultFont)
            baseClass.Initialize(self, params, errorDepth)
            PopParamChange(params, "font")
            
        end
        
    end
    
    GUIMenuTextInputWidget.Initialize = GetInitializeBody(GUIMenuTextInputWidget, textBaseClass)
    GUIMenuNumberInputWidget.Initialize = GetInitializeBody(GUIMenuNumberInputWidget, numberBaseClass)
    
end

DefineMethod("SetFont", function(self, ...)
    self.displayText:SetFont(...)
    self.cursor:SetFontName(self.displayText.text:GetFontName())
    self.cursor:SetScale(self.displayText.text:GetScale())
    self:SetFontName(self.displayText.text:GetFontName())
end)
