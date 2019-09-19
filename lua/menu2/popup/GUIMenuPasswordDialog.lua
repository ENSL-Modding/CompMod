-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/menu2/popup/GUIMenuPasswordDialog.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    GUIMenuPopupDialog used to prompt the user for a password input.
--
--  Parameters (* = required)
--      title
--      message
--     *buttonConfig    List of button object configs.
--      escDisabled     True/false if the esc key can be used to close this popup.
--      updateFunc      Function to call to update the popup window.  Called every frame that it is
--                      open.
--      password        Pre-filled-in password contents (eg a previous attempt).
--
--  Properties:
--      Title           The text displayed for the title of this dialog box.
--      Message         The text displayed in the body of this dialog box.
--
--  Events:
--      OnClosed        The dialog was closed.  Fires _after_ button callbacks -- if any.
--      OnEscape        The dialog was closed via ESC.  Fires immediately before OnClosed, and
--                      before OnCancelled.
--      OnCancelled     The dialog was closed via a cancel button (if using default implementation)
--                      or ESC key press.
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/menu2/popup/GUIMenuPopupDialog.lua")

---@class GUIMenuPasswordDialog : GUIMenuPopupDialog
class "GUIMenuPasswordDialog" (GUIMenuPopupDialog)

-- Spacing between edge of inner box and the visible contents.
local kInnerPopupContentsPadding = Vector(72, 48, 0)

-- Spacing between contents of dialog (when there is more than one type of content).
local kContentsSpacing = 16

GUIMenuPasswordDialog:AddCompositeClassProperty("Message", "message", "Text")

local function UpdateScrollPaneHeight(self)
    self.scrollPane:SetPaneHeight(self.message:GetSize().y + kInnerPopupContentsPadding.y * 2)
end

local function UpdateMessageParagraphSize(self)
    self.message:SetParagraphSize(math.max(100, self.scrollPane:GetSize().x - kInnerPopupContentsPadding.x * 2), -1)
end

local function UpdateScrollPaneWidth(self)
    self.scrollPane:SetWidth(math.max(100, self.contentsHolder:GetSize().x - kInnerPopupContentsPadding.x*2))
end

local function UpdateScrollPaneViewHeight(self)
    self.scrollPane:SetHeight(self.contentsHolder:GetSize().y - self.layout:GetSpacing() - self.layout:GetFrontPadding() - self.layout:GetBackPadding() - self.password:GetSize().y)
end

function GUIMenuPasswordDialog:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    RequireType({"string", "nil"}, params.title, "params.title", errorDepth)
    RequireType({"string", "nil"}, params.message, "params.message", errorDepth)
    RequireType("table", params.buttonConfig, "params.buttonConfig", errorDepth)
    RequireType({"string", "nil"}, params.password, "params.password", errorDepth)
    
    GUIMenuPopupDialog.Initialize(self, params, errorDepth)
    
    self.layout = CreateGUIObject("layout", GUIListLayout, self.contentsHolder,
    {
        orientation = "vertical",
        spacing = kContentsSpacing,
        frontPadding = kInnerPopupContentsPadding.y,
        backPadding = kInnerPopupContentsPadding.y,
    })
    self.layout:SetX(kInnerPopupContentsPadding.x)
    
    self.scrollPane = CreateGUIObject("scrollPane", GUIMenuScrollPane, self.layout,
    {
        horizontalScrollBarEnabled = false,
    })
    
    -- Make width of scroll pane match width of contents holder.
    self:HookEvent(self.contentsHolder, "OnSizeChanged", UpdateScrollPaneWidth)
    UpdateScrollPaneWidth(self)
    
    self.message = CreateGUIObject("message", GUIParagraph, self.scrollPane,
    {
        text = params.message or "Popup dialog message goes here!",
        fontFamily = "Agency",
        fontSize = 55,
        color = MenuStyle.kOptionHeadingColor,
    })
    
    -- Make height of scroll pane equal height of paragraph text.
    self:HookEvent(self.message, "OnSizeChanged", UpdateScrollPaneHeight)
    UpdateScrollPaneHeight(self)
    
    -- Make width of paragraph-size resize with the popup.
    self:HookEvent(self.scrollPane, "OnSizeChanged", UpdateMessageParagraphSize)
    UpdateMessageParagraphSize(self)
    
    self.password = CreateGUIObject("password", GUIMenuPasswordEntryWidget, self.layout,
    {
        label = Locale.ResolveString("PASSWORD"),
    })
    self.password:AlignTop()
    
    -- Resize the scroll pane's display height to make room for the password at the bottom.
    self:HookEvent(self.password, "OnSizeChanged", UpdateScrollPaneViewHeight)
    self:HookEvent(self.layout, "OnFrontPaddingChanged", UpdateScrollPaneViewHeight)
    self:HookEvent(self.layout, "OnBackPaddingChanged", UpdateScrollPaneViewHeight)
    self:HookEvent(self.layout, "OnSpacingChanged", UpdateScrollPaneViewHeight)
    self:HookEvent(self.contentsHolder, "OnSizeChanged", UpdateScrollPaneViewHeight)
    UpdateScrollPaneViewHeight(self)
    UpdateScrollPaneHeight(self)
    
    if params.password then
        self.password:SetValue(params.password)
    end
    
    -- Convenience.  Enable editing on the password field so user doesn't have to click it.
    self.password:SetEditing(true)
    
end

function GUIMenuPasswordDialog:GetPasswordWidget()
    return self.password
end
