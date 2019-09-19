-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/menu2/popup/GUIMenuPopupIconMessage.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    GUIMenuPopupDialog used to deliver a simple message that also displays an icon.
--
--  Parameters (* = required)
--      title
--      message
--     *buttonConfig    List of button object configs.
--      escDisabled     True/false if the esc key can be used to close this popup.
--      updateFunc      Function to call to update the popup window.  Called every frame that it is
--                      open.
--      icon
--
--  Properties:
--      Title           The text displayed for the title of this dialog box.
--      Message         The text displayed in the body of this dialog box.
--      Icon            Texture file to use for the icon.  The icon will be scaled uniformly to fit
--                      into the popup, but is constrained so as to not take up too much space.
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

---@class GUIMenuPopupIconMessage : GUIMenuPopupDialog
class "GUIMenuPopupIconMessage" (GUIMenuPopupDialog)

-- Spacing between edge of inner box and the visible contents.
local kInnerPopupContentsPadding = Vector(72, 48, 0)

-- Spacing between contents of dialog (when there is more than one type of content).
local kContentsSpacing = 16

-- Maximum fraction of the total width that the icon can be, wide.
local kIconMaxWidthFraction = 0.33333

GUIMenuPopupIconMessage:AddCompositeClassProperty("Message", "message", "Text")
GUIMenuPopupIconMessage:AddCompositeClassProperty("Icon", "icon", "Texture")

local function UpdateScrollPaneHeight(self)
    self.scrollPane:SetPaneHeight(self.message:GetSize().y + kInnerPopupContentsPadding.y)
end

local function UpdateMessageParagraphSize(self)
    self.message:SetParagraphSize(self.scrollPane:GetSize().x - kInnerPopupContentsPadding.x * 2, -1)
end

local function UpdateContentsSize(self)
    self.contents:SetSize(self.contentsHolder:GetSize().x - kInnerPopupContentsPadding.x*2,
                          self.contentsHolder:GetSize().y - kInnerPopupContentsPadding.y*2)
end

local function UpdateScrollPaneSize(self)
    self.scrollPane:SetSize(self.contents:GetSize().x - self.icon:GetSize().x - kContentsSpacing, self.contents:GetSize().y)
end

local function UpdateIconSize(self)
    
    local textureSize = self.icon:GetTextureSize()
    if textureSize.x <= 0 or textureSize.y <= 0 then
        self.icon:SetColor(0, 0, 0, 0)
        return -- no (valid) texture assigned, skip for now.
    end
    
    local availableSize = self.contents:GetSize()
    if availableSize.x <= 0 or availableSize.y <= 0 then
        return -- invalid available size, come back later once that's cleared up.
    end
    
    local maxWidth = availableSize.x * kIconMaxWidthFraction
    local scaleHeight = availableSize.y / textureSize.y
    local scaleWidth = maxWidth / textureSize.x
    local scaleFactor = math.min(scaleHeight, scaleWidth)
    
    self.icon:SetSize(textureSize * scaleFactor)
    self.icon:SetColor(1, 1, 1, 1)
    
end

function GUIMenuPopupIconMessage:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    RequireType({"string", "nil"}, params.title, "params.title", errorDepth)
    RequireType({"string", "nil"}, params.message, "params.message", errorDepth)
    RequireType("table", params.buttonConfig, "params.buttonConfig", errorDepth)
    RequireType({"string", "nil"}, params.icon, "params.icon", errorDepth)
    
    GUIMenuPopupDialog.Initialize(self, params, errorDepth)
    
    self.contents = CreateGUIObject("contents", GUIObject, self.contentsHolder)
    self.contents:AlignCenter()
    self:HookEvent(self.contentsHolder, "OnSizeChanged", UpdateContentsSize)
    UpdateContentsSize(self)
    
    self.layout = CreateGUIObject("layout", GUIListLayout, self.contents,
    {
        orientation = "horizontal",
        spacing = kContentsSpacing,
    })
    
    self.icon = CreateGUIObject("icon", GUIObject, self.layout)
    self.icon:AlignLeft()
    self:HookEvent(self, "OnIconChanged", UpdateIconSize)
    self:HookEvent(self.contents, "OnSizeChanged", UpdateIconSize)
    if params.icon then
        self.icon:SetTexture(params.icon)
    end
    
    self.scrollPane = CreateGUIObject("scrollPane", GUIMenuScrollPane, self.layout,
    {
        horizontalScrollBarEnabled = false,
    })
    self:HookEvent(self.contents, "OnSizeChanged", UpdateScrollPaneSize)
    self:HookEvent(self.icon, "OnSizeChanged", UpdateScrollPaneSize)
    UpdateScrollPaneSize(self)
    
    self.message = CreateGUIObject("message", GUIParagraph, self.scrollPane,
    {
        text = params.message or "Popup dialog message goes here!",
        fontFamily = "Agency",
        fontSize = 55,
        color = MenuStyle.kOptionHeadingColor,
    })
    self.message:SetX(kInnerPopupContentsPadding.x)
    
    -- Make height of scroll pane equal height of paragraph text.
    self:HookEvent(self.message, "OnSizeChanged", UpdateScrollPaneHeight)
    UpdateScrollPaneHeight(self)
    
    -- Make width of paragraph-size resize with the popup.
    self:HookEvent(self.scrollPane, "OnSizeChanged", UpdateMessageParagraphSize)
    UpdateMessageParagraphSize(self)
    
end
