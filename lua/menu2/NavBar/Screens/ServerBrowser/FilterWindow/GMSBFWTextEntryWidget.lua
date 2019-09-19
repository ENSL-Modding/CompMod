-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. ============
--
-- lua/menu2/NavBar/Screens/ServerBrowser/FilterWindow/GMSBFWTextEntryWidget.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    A widget that lets the user enter some text.
--  
--  Properties
--      Label       Text displayed left of the checkbox.
--      Value       The text that the user has entered.
--  
-- ========= For more information, visit us at http://www.unknownworlds.com =======================

Script.Load("lua/GUI/GUIText.lua")
Script.Load("lua/menu2/NavBar/Screens/ServerBrowser/FilterWindow/GMSBFWTextInputWidget.lua")
Script.Load("lua/menu2/GUIMenuBasicBox.lua")
Script.Load("lua/menu2/MenuStyles.lua")
Script.Load("lua/GUI/layouts/GUIListLayout.lua")

---@class GMSBFWTextEntryWidget : GUIObject
local baseClass = GUIObject
class "GMSBFWTextEntryWidget" (baseClass)

local kFont = MenuStyle.kServerBrowserFiltersWindowFont
local kLabelColor = MenuStyle.kOptionHeadingColor

local kEntryBoxHeight = 62
local kEntryPadding = 14

local kSpacing = 5

GMSBFWTextEntryWidget:AddCompositeClassProperty("Label", "label", "Text")

GMSBFWTextEntryWidget:AddCompositeClassProperty("Value", "inputWidget", "Value")
GMSBFWTextEntryWidget:AddCompositeClassProperty("MaxCharacterCount", "inputWidget")
GMSBFWTextEntryWidget:AddCompositeClassProperty("MaxWidth", "inputWidget")
GMSBFWTextEntryWidget:AddCompositeClassProperty("Editing", "inputWidget")

local function SetEntryBoxWidth(entryBox, size)
    entryBox:SetSize(size.x, entryBox:GetSize().y)
end

local function UpdateInputWidgetMaxWidth(inputWidget, size)
    inputWidget:SetMaxWidth(size.x - kEntryPadding * 2)
end

local function FWD_OnMouseClick(self, double)       self.inputWidget:OnMouseClick(double)       end
local function FWD_OnMouseRelease(self)             self.inputWidget:OnMouseRelease()           end
local function FWD_OnMouseUp(self)                  self.inputWidget:OnMouseUp()                end
local function FWD_OnMouseEnter(self)               self.inputWidget:OnMouseEnter()             end
local function FWD_OnMouseExit(self)                self.inputWidget:OnMouseExit()              end
local function FWD_OnMouseDrag(self)                self.inputWidget:OnMouseDrag()              end
local function FWD_OnOutsideClick(self)             self.inputWidget:OnOutsideClick()           end
local function FWD_OnOutsideWheel(self, up)         self.inputWidget:OnOutsideWheel(up)         end
local function FWD_OnKey(self, key, down)           self.inputWidget:OnKey(key, down)           end
local function FWD_OnCharacter(self, character)     self.inputWidget:OnCharacter(character)     end

local function EntryBoxBeginEditing(self)
    self.owner.inputWidget:_BeginEditing()
    self:ListenForCharacters()
    self:ListenForKeyInteractions()
end

local function EntryBoxEndEditing(self)
    self.owner.inputWidget:_EndEditing()
    self:StopListeningForCharacters()
    self:StopListeningForKeyInteractions()
end

local entryBoxBaseClass = GUIMenuBasicBox
entryBoxBaseClass = GetEditableWrappedClass(entryBoxBaseClass)
entryBoxBaseClass = GetCursorInteractableWrappedClass(entryBoxBaseClass)
entryBoxBaseClass = GetFXStateWrappedClass(entryBoxBaseClass)
class "GMSBFWTextEntryWidget_EntryBoxClass" (entryBoxBaseClass)
entryBoxBaseClass = GMSBFWTextEntryWidget_EntryBoxClass
assert(entryBoxBaseClass)

-- See lua/GUI/wrappers/Editable.lua.
function GMSBFWTextEntryWidget_EntryBoxClass:GetIsTextInput()
    return true
end

function GMSBFWTextEntryWidget:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    RequireType({"string", "nil"}, params.label, "params.label", errorDepth)
    RequireType({"string", "nil"}, params.default, "params.default", errorDepth)
    
    baseClass.Initialize(self, params, errorDepth)
    
    self.layout = CreateGUIObject("layout", GUIListLayout, self, {orientation="vertical"})
    self.layout:SetSpacing(kSpacing)
    
    self.label = CreateGUIObject("label", GUIText, self.layout)
    self.label:SetFont(kFont)
    self.label:SetColor(kLabelColor)
    
    self.entryBox = CreateGUIObject("entryBox", entryBoxBaseClass, self.layout)
    self.entryBox:SetSize(self.entryBox:GetSize().x, kEntryBoxHeight)
    self.entryBox:HookEvent(self, "OnSizeChanged", SetEntryBoxWidth)
    self.entryBox._BeginEditing = EntryBoxBeginEditing
    self.entryBox._EndEditing = EntryBoxEndEditing
    self.entryBox.owner = self
    
    self.inputWidget = CreateGUIObject("inputWidget", GMSBFWTextInputWidget, self.entryBox,
    {
        editController = self.entryBox,
        cursorController = self.entryBox,
    })
    self.inputWidget:HookEvent(self.entryBox, "OnSizeChanged", UpdateInputWidgetMaxWidth)
    self.inputWidget:SetPosition(kEntryPadding, 0)
    self.inputWidget:AlignLeft()
    
    -- Whenever inputWidget calls SetModal() for itself, the whole box will be made modal.
    self.inputWidget:SetModalObject(self.entryBox)
    
    self:HookEvent(self.entryBox, "OnMouseClick",      FWD_OnMouseClick)
    self:HookEvent(self.entryBox, "OnMouseRelease",    FWD_OnMouseRelease)
    self:HookEvent(self.entryBox, "OnMouseUp",         FWD_OnMouseUp)
    self:HookEvent(self.entryBox, "OnMouseEnter",      FWD_OnMouseEnter)
    self:HookEvent(self.entryBox, "OnMouseExit",       FWD_OnMouseExit)
    self:HookEvent(self.entryBox, "OnMouseDrag",       FWD_OnMouseDrag)
    self:HookEvent(self.entryBox, "OnOutsideClick",    FWD_OnOutsideClick)
    self:HookEvent(self.entryBox, "OnOutsideWheel",    FWD_OnOutsideWheel)
    self:HookEvent(self.entryBox, "OnKey",             FWD_OnKey)
    self:HookEvent(self.entryBox, "OnCharacter",       FWD_OnCharacter)
    
    self:HookEvent(self.layout, "OnSizeChanged", self.SetSize)
    
    if params.label then
        self:SetLabel(params.label)
    end
    
    if params.default then
        self:SetValue(params.default)
    end
    
end
