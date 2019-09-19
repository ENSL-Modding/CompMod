-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/menu2/popup/GUIMenuPopupSimpleMessage.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    GUIMenuPopupDialog used to deliver a simple message.
--
--  Parameters (* = required)
--      title
--      message
--     *buttonConfig    List of button object configs.
--      escDisabled     True/false if the esc key can be used to close this popup.
--      updateFunc      Function to call to update the popup window.  Called every frame that it is
--                      open.
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

---@class GUIMenuPopupSimpleMessage : GUIMenuPopupDialog
class "GUIMenuPopupSimpleMessage" (GUIMenuPopupDialog)

-- Spacing between edge of inner box and the visible contents.
local kInnerPopupContentsPadding = Vector(72, 48, 0)

GUIMenuPopupSimpleMessage:AddCompositeClassProperty("Message", "message", "Text")

local function UpdateScrollPaneHeight(self)
    self.scrollPane:SetPaneHeight(self.message:GetSize().y + kInnerPopupContentsPadding.y * 2)
end

local function UpdateMessageParagraphSize(self)
    self.message:SetParagraphSize(self.scrollPane:GetSize().x - kInnerPopupContentsPadding.x * 2, -1)
end

function GUIMenuPopupSimpleMessage:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    RequireType({"string", "nil"}, params.title, "params.title", errorDepth)
    RequireType({"string", "nil"}, params.message, "params.message", errorDepth)
    RequireType("table", params.buttonConfig, "params.buttonConfig", errorDepth)
    
    GUIMenuPopupDialog.Initialize(self, params, errorDepth)
    
    self.scrollPane = CreateGUIObject("scrollPane", GUIMenuScrollPane, self.contentsHolder,
    {
        horizontalScrollBarEnabled = false,
    })
    self.scrollPane:SetSyncToParentSize(true)
    
    self.message = CreateGUIObject("message", GUIParagraph, self.scrollPane,
    {
        text = params.message or "Popup dialog message goes here!",
        fontFamily = "Agency",
        fontSize = 55,
        color = MenuStyle.kOptionHeadingColor,
    })
    self.message:SetPosition(kInnerPopupContentsPadding)
    
    -- Make height of scroll pane equal height of paragraph text.
    self:HookEvent(self.message, "OnSizeChanged", UpdateScrollPaneHeight)
    UpdateScrollPaneHeight(self)
    
    -- Make width of paragraph-size resize with the popup.
    self:HookEvent(self.scrollPane, "OnSizeChanged", UpdateMessageParagraphSize)
    UpdateMessageParagraphSize(self)
    
end

-- DEBUG
Event.Hook("Console_test_popup", function()
    local popup = CreateGUIObject("testPopup", GUIMenuPopupSimpleMessage, nil,
    {
        title = "Hello World!",
        message = "I'm a popup!",
        buttonConfig =
        {
            GUIPopupDialog.OkayButton,
        },
    })
end)
