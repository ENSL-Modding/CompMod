-- ======= Copyright (c) 2017, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/menu2/PlayerScreen/FriendsList/GUIMenuFriendsListSearchBox.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Similar to GUIMenuTextEntryWidget, but with label replaced with search icon.
--
--  Params:
--
--  Properties:
--      MaxCharacterCount   -- The maximum number of characters (unicode characters to be precise)
--                             allowed in the string. <=0 for unlimited.
--      MaxWidth            -- The maximum width of the text, in local space pixels. <=0 for
--                             unlimited.
--      Editing             -- Whether or not the user is entering text for this object.
--      IsPassword          -- Whether or not the text of this object should be censored.
--      Label               -- Label text to display.
--
--  Events:
--      OnEditBegin         -- The user has started editing the text.
--      OnCharacterAccepted -- The user has added a character while editing.
--          character           -- Character that was added.
--      OnCharacterDeleted  -- The user has deleted a character while editing.
--      OnEditAccepted      -- Editing has ended, with the user accepting the edit.
--      OnEditCancelled     -- Editing has ended, with the user reverting the edit.
--      OnEditEnd           -- Editing has ended.  The text may or may not have changed.
--      OnValueChanged      -- The value of the text has changed.
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/menu2/widgets/GUIMenuTextEntryWidget.lua")
Script.Load("lua/menu2/GUIMenuBasicBox.lua")
Script.Load("lua/menu2/MenuStyles.lua")
Script.Load("lua/menu2/widgets/GUIMenuTruncatedDisplayWidget.lua")
Script.Load("lua/menu2/GUIMenuTruncatedText.lua")
Script.Load("lua/menu2/GUIMenuGraphic.lua")
Script.Load("lua/GUI/wrappers/CursorInteractable.lua")
Script.Load("lua/GUI/wrappers/Editable.lua")

---@class GUIMenuFriendsListSearchBox : GUIObject
---@field public GetEditing function @From Editable wrapper
---@field public SetEditing function @From Editable wrapper
---@field protected _BeginEditing function @From Editable wrapper
---@field protected _EndEditing function @From Editable wrapper
---@field public GetMouseOver function @From CursorInteractable wrapper
---@field public GetPressed function @From CursorInteractable wrapper
---@field public GetFXState function @From FXState wrapper
---@field public UpdateFXStateOverride function @From FXState wrapper
---@field public AddFXReceiver function @From FXState wrapper
---@field public RemoveFXReceiver function @From FXState wrapper
local baseClass = GUIObject
baseClass = GetEditableWrappedClass(baseClass)
baseClass = GetCursorInteractableWrappedClass(baseClass)
baseClass = GetFXStateWrappedClass(baseClass)
class "GUIMenuFriendsListSearchBox" (baseClass)

-- See lua/GUI/wrappers/Editable.lua.
function GUIMenuFriendsListSearchBox:GetIsTextInput()
    return true
end

local kManualScrollTolerance = 20
local kSpacing = 12

local kFont = ReadOnly{family = "Microgramma", size = 26}
local kMaxCharacterCount = 64

local kSearchIcon = PrecacheAsset("ui/newMenu/server_browser/searching_icon.dds")

GUIMenuFriendsListSearchBox:AddCompositeClassProperty("Value", "entry")

local function SetEntryText(self)
    self.entry:SetText(self:GetText())
end

local function UpdateLayout(self)
    self.entryHolder:SetSize(self:GetSize().x - (self.icon:GetSize().x * self.icon:GetScale().x + kSpacing * 3), self:GetSize().y - kSpacing*2)
end

local function UpdateManualScrolling(self)
    
    if not self:GetEditing() then
        return
    end
    
    local scrollWindowMin = self.entryHolder:GetScroll()
    local scrollWindowMax = scrollWindowMin + self.entryHolder:GetSize().x
    local cursorX = self.entry:GetCursorPosition(true).x * self.entry:GetScale(true).x
    local maxScroll = self.entryHolder:GetMaxScroll()
    
    if maxScroll == 0 then
        
        self.entryHolder:AnimateProperty("Scroll", 0, MenuAnimations.FlyIn)
    
    elseif cursorX > scrollWindowMax - kManualScrollTolerance then
        
        self.entryHolder:AnimateProperty("Scroll", math.max(cursorX - self.entryHolder:GetSize().x + kManualScrollTolerance, 0), MenuAnimations.FlyIn)
    
    elseif cursorX < scrollWindowMin + kManualScrollTolerance then
        
        self.entryHolder:AnimateProperty("Scroll", math.max(cursorX - kManualScrollTolerance, 0), MenuAnimations.FlyIn)
    
    end

end

local function OnEditingChanged(self, editing)
    
    if editing then
        
        self:FireEvent("OnEditBegin")
        self:ListenForCharacters()
        self:ListenForKeyInteractions()
        self.entry:StopListeningForKeyInteractions()
        self.entryHolder:SetAutoScroll(false)
    
    else
        
        self:FireEvent("OnEditEnd")
        self:StopListeningForCharacters()
        self:StopListeningForKeyInteractions()
        self.entryHolder:SetAutoScroll(true)
    
    end

end

local function UpdateIconSize(self)
    
    local height = math.max(self:GetSize().y - kSpacing*2, 2)
    local iconTextureSize = self.icon:GetTextureSize()
    if iconTextureSize.x == -1 then
        return -- no texture, cannot update.
    end
    
    local scaleFactor = height / math.max(iconTextureSize.y, 1)
    self.icon:SetSize(iconTextureSize * scaleFactor)
    
end

function GUIMenuFriendsListSearchBox:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    baseClass.Initialize(self, params, errorDepth)
    
    self.icon = CreateGUIObject("icon", GUIMenuGraphic, self)
    self.icon:SetTexture(kSearchIcon)
    self:HookEvent(self, "OnSizeChanged", UpdateIconSize)
    self.icon:SetX(kSpacing)
    self.icon:AlignLeft()
    
    PushParamChange(params, "cls", _GUIMenuTextInputWidgetForEntry)
    self.entryHolder = CreateGUIObject("entryHolder", GUIMenuTruncatedDisplayWidget, self, params)
    PopParamChange(params, "cls")
    
    self.entryHolder:SetAutoScroll(true)
    
    -- Right align with some padding.
    self.entryHolder:AlignRight()
    self.entryHolder:SetPosition(-MenuStyle.kWidgetPadding, 0)
    
    self.entry = self.entryHolder:GetObject()
    self.entry:AlignLeft()
    self.entry:SetFont(kFont)
    self.entry:SetMaxCharacterCount(kMaxCharacterCount)
    
    -- We'll forward the necessary events from this widget.
    self.entry:StopListeningForCursorInteractions()
    self.entry.owner = self -- convenient link.
    
    self.entry:ForwardEvent(self, "OnEditingChanged")
    
    self.back = CreateGUIObject("back", GUIMenuBasicBox, self)
    self.back:SetLayer(-1)
    self.back:HookEvent(self, "OnSizeChanged", self.back.SetSize)
    
    self:HookEvent(self.entry, "OnEditingChanged", OnEditingChanged)
    
    self:ForwardEvent(self.entry, "OnCharacterAccepted")
    self:ForwardEvent(self.entry, "OnCharacterDeleted")
    self:ForwardEvent(self.entry, "OnEditAccepted")
    self:ForwardEvent(self.entry, "OnEditCancelled")
    
    -- Allow "SetText" to be called on this object to set the text of the entry.
    self:HookEvent(self, "OnTextChanged", SetEntryText)
    
    self:HookEvent(self, "OnSizeChanged", UpdateLayout)
    
    self:HookEvent(self, "OnValueChanged", UpdateManualScrolling)
    self:HookEvent(self.entry, "On_CursorPositionChanged", UpdateManualScrolling)
    
    self:SetSize(MenuStyle.kDefaultWidgetSize)
    UpdateLayout(self)
    self.entryHolder:SetAutoScrollSpeed(MenuStyle.kOptionFont.size * MenuStyle.kTextAutoScrollSpeedMult)
    
end

function GUIMenuFriendsListSearchBox:_BeginEditing()
    self.entry:_BeginEditing()
end

function GUIMenuFriendsListSearchBox:_EndEditing()
    self.entry:_EndEditing()
end

-- Returns the given value formatted as though it were a value of this widget.
-- Simply returns the given value, since this widget's value is always a string-type.  Does not
-- perform any length or width checks, as it is assumed that this value was originally produced by
-- this widget (Eg a previous value).
function GUIMenuFriendsListSearchBox:GetValueString(value)
    local result = self.entry:GetValueString(value)
    return result
end

function GUIMenuFriendsListSearchBox:OnMouseClick(double)
    baseClass.OnMouseClick(self, double)
    self.entry:OnMouseClick()
end

function GUIMenuFriendsListSearchBox:OnMouseRelease()
    baseClass.OnMouseRelease(self)
    self.entry:OnMouseRelease()
end

function GUIMenuFriendsListSearchBox:OnMouseUp()
    baseClass.OnMouseUp(self)
    self.entry:OnMouseUp()
end

function GUIMenuFriendsListSearchBox:OnMouseEnter()
    baseClass.OnMouseEnter(self)
    self.entry:OnMouseEnter()
end

function GUIMenuFriendsListSearchBox:OnMouseExit()
    baseClass.OnMouseExit(self)
    self.entry:OnMouseExit()
end

function GUIMenuFriendsListSearchBox:OnMouseDrag()
    baseClass.OnMouseDrag(self)
    self.entry:OnMouseDrag()
end

function GUIMenuFriendsListSearchBox:OnKey(key, down)
    baseClass.OnKey(self, key, down)
    return (self.entry:OnKey(key, down))
end

function GUIMenuFriendsListSearchBox:OnCharacter(character)
    baseClass.OnCharacter(self, character)
    self.entry:OnCharacter(character)
end

function GUIMenuFriendsListSearchBox:CancelEdit()
    self.entry:CancelEdit()
end
