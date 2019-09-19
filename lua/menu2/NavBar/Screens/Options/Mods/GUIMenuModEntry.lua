-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/menu2/NavBar/Screens/Options/Mods/GUIMenuModEntry.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    A single entry in the list of mods (the list on the right side of the mods menu -- not the
--    list of mod names on the left).
--
--  Properties:
--      Selected            Whether or not this entry is selected (determines color).
--      ModTitle            The name of the mod.
--      ModDescription      The description of the mod.
--      Subscribed          Whether or not the user is subscribed to this mod.
--      Active              Whether or not the user has set this mod to be active. (requires a
--                          restart to kick-in for-real though).
--      DownloadProgress    Number between 0 and 1 representing the download fraction.
--      ModState            String describing the state of the mod.  5 possible values:
--                              getting_info
--                              downloading
--                              unavailable
--                              available
--                              none
--      ModEngineId         The id of this mod that engine functions use.
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/menu2/GUIMenuBasicBox.lua")
Script.Load("lua/menu2/GUIMenuTruncatedText.lua")
Script.Load("lua/menu2/GUIMenuText.lua")
Script.Load("lua/menu2/MenuStyles.lua")
Script.Load("lua/menu2/widgets/GUIMenuCheckboxWidget.lua")
Script.Load("lua/menu2/NavBar/Screens/Options/Mods/GUIMenuModsEntryDownloadBar.lua")

Script.Load("lua/menu2/wrappers/Expandable.lua")

---@class GUIMenuModEntry : GUIButton
---@field public GetFXState function @From FXState wrapper
---@field public UpdateFXStateOverride function @From FXState wrapper
---@field public AddFXReceiver function @From FXState wrapper
---@field public RemoveFXReceiver function @From FXState wrapper
local baseClass = GUIButton
baseClass = GetFXStateWrappedClass(baseClass)
class "GUIMenuModEntry" (baseClass)

local kHeaderHeight = 146
local kXPaddingRight = 106
local kXPaddingLeft = 36
local kXSpacing = 50
local kXSpacingForStatusText = 172
local kContentsPadding = 24 -- padding all around details part of the box.
local kContentsHeight = 384 -- height of details area (total size, padding inside this).
local kDescriptionPadding = Vector(48, 16, 0)

GUIMenuModEntry:AddClassProperty("Selected", false)
GUIMenuModEntry:AddClassProperty("ModTitle", "")
GUIMenuModEntry:AddClassProperty("ModDescription", "")
GUIMenuModEntry:AddClassProperty("Subscribed", false)
GUIMenuModEntry:AddCompositeClassProperty("Active", "activeButton", "Value")
GUIMenuModEntry:AddClassProperty("DownloadProgress", 0)
GUIMenuModEntry:AddClassProperty("ModState", "none")
GUIMenuModEntry:AddClassProperty("ModEngineId", 0) -- 0 is invalid.

local function UpdateLabelSize(self)
    
    local labelTextSize = self.label:GetTextSize()
    local entryWidth = self:GetSize().x
    
    local widthRemaining = entryWidth
    widthRemaining = widthRemaining - kXPaddingLeft -- label padding
    widthRemaining = widthRemaining - -self.statusText:GetPosition().x
    widthRemaining = widthRemaining - self.statusText:GetSize().x
    widthRemaining = widthRemaining - kXSpacing -- spacing between status text and maximum label size.
    
    local labelWidth = math.max(math.min(widthRemaining, labelTextSize.x), 1)
    
    self.label:SetSize(labelWidth, labelTextSize.y)
    
end

local function UpdatePaddedContentsSize(paddedContents, size)
    paddedContents:SetSize(size.x - kContentsPadding*2, size.y - kContentsPadding*2)
end

local function UpdatePaneSizeFromDescription(scrollPane, descSize)
    scrollPane:SetPaneSize(descSize + kDescriptionPadding*2)
end

local function UpdateDescriptionMaxWidthFromSize(desc, size)
    local maxWidth = size.x - kContentsPadding*2 - kDescriptionPadding.x*2
    desc:SetParagraphSize(maxWidth, -1)
end

local function UpdateVisuals(self)
    
    local state = self:GetModState()
    local subscribed = self:GetSubscribed()
    local downloadFrac = self:GetDownloadProgress()
    local width = self:GetSize().x
    
    -- Update status text.
    if state == "downloading" then
        local downloadPercent = Clamp(math.floor(downloadFrac * 100), 0, 99)
        local text = string.format("%s... %d%%", Locale.ResolveString("MODS_STATE_3"), downloadPercent)
        self.statusText:SetText(text)
    elseif state == "getting_info" then
        self.statusText:SetText(Locale.ResolveString("MODS_STATE_1"))
    elseif state == "unavailable" or state == "none" then
        self.statusText:SetText(Locale.ResolveString("MODS_STATE_4"))
    elseif state == "available" then
        if subscribed then
            self.statusText:SetText(Locale.ResolveString("MODS_SUBSCRIBED"))
        else
            self.statusText:SetText(Locale.ResolveString("MODS_STATE_5"))
        end
    end
    
    -- Update size of download bar.
    local goalSize = Vector(width * downloadFrac, self.downloadBar:GetSize().y, 0)
    self.downloadBar:AnimateProperty("Size", goalSize, MenuAnimations.FadeFast, "progressBarSize")
    
    -- Update opacity of download bar.
    local progressBarOpacity = state == "downloading" and 1 or 0
    self.downloadBar:AnimateProperty("Opacity", progressBarOpacity, MenuAnimations.Fade)
    
end

local selectedModEntry = nil
local function ToggleSelected(self)
    
    self:SetSelected(not self:GetSelected())
    
    if self:GetSelected() then
        if selectedModEntry ~= nil then
            selectedModEntry:SetSelected(false)
            selectedModEntry = nil
        end
        PlayMenuSound("BeginChoice")
        selectedModEntry = self
    else
    
        PlayMenuSound("AcceptChoice")
        assert(selectedModEntry == self)
        selectedModEntry = nil
        
    end
end

local function OnCheckboxValueChanged(self)
    Client.SetModActive(self:GetModEngineId(), self:GetActive())
end

local function EnsureNotSelected(self)
    if self == selectedModEntry then
        selectedModEntry = nil
    end
end

local function UpdateSelectionVisuals(self)
    
    local selected = self:GetSelected()
    
    self.contents:SetExpanded(selected)
    
    if selected then
        self.back:AnimateProperty("FillColor", MenuStyle.kHighlightBackground, MenuAnimations.Fade)
        self.back:AnimateProperty("StrokeColor", MenuStyle.kHighlightStrokeColor, MenuAnimations.Fade)
    else
        self.back:AnimateProperty("FillColor", MenuStyle.kBasicBoxBackgroundColor, MenuAnimations.Fade)
        self.back:AnimateProperty("StrokeColor", MenuStyle.kDarkGrey, MenuAnimations.Fade)
    end
    
end

function GUIMenuModEntry:UpdateData()
    
    local id = self:GetModEngineId()
    self:SetModTitle(Client.GetModTitle(id))
    self:SetModDescription(Client.GetModDescription(id))
    self:SetSubscribed(Client.GetIsSubscribedToMod(id))
    self:SetActive(Client.GetIsModActive(id))
    self:SetModState(Client.GetModState(id))
    
    local downloading, bytesDownloaded, totalBytes = Client.GetModDownloadProgress(id)
    local downloadFraction = 1.0
    if downloading then
        downloadFraction = 0.0
        if totalBytes > 0 then
            downloadFraction = bytesDownloaded / totalBytes
        end
    end
    self:SetDownloadProgress(downloadFraction)
    
end

local function UpdateDescription(self)
    self.description:SetText(string.sub(self:GetModDescription(), 1, gGUIItemMaxCharacters))
end

function GUIMenuModEntry:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    baseClass.Initialize(self, params, errorDepth)
    
    -- Layout to hold header and contents.
    self.holder = CreateGUIObject("holder", GUIListLayout, self,
    {
        orientation = "vertical",
        spacing = 0,
        frontPadding = 0,
        backPadding = 0,
    })
    
    self:HookEvent(self.holder, "OnSizeChanged", self.SetHeight)
    
    -- Object to hold stuff in the header of the object (eg stuff that is always visible).
    self.header = CreateGUIObject("header", GUIObject, self.holder)
    self.header:SetSize(self.header:GetSize().x, kHeaderHeight)
    self.header:HookEvent(self, "OnSizeChanged", self.header.SetWidth)
    
    self.label = CreateGUIObject("label", GUIMenuTruncatedText, self.header,
    {
        cls = GUIMenuText,
        defaultColor = MenuStyle.kOptionHeadingColor,
    })
    self.label:AlignLeft()
    self.label:SetX(kXPaddingLeft)
    self.label:HookEvent(self, "OnModTitleChanged", self.label.SetText)
    self.label:SetFont(MenuStyle.kOptionHeadingFont)
    
    self.activeButton = CreateGUIObject("activeButton", GUIMenuCheckboxWidget, self.header)
    self.activeButton:AlignRight()
    self.activeButton:SetX(-kXPaddingRight)
    self.activeButton:SetLayer(2)
    self:HookEvent(self.activeButton, "OnValueChanged", OnCheckboxValueChanged)
    
    self.statusText = CreateGUIObject("statusText", GUIText, self.header)
    self.statusText:AlignRight()
    self.statusText:SetX(-kXPaddingRight - self.activeButton:GetSize().x*self.activeButton:GetScale().x - kXSpacing - kXSpacingForStatusText)
    self.statusText:SetFont(MenuStyle.kOptionFont)
    self.statusText:SetColor(MenuStyle.kOptionHeadingColor)
    
    self:HookEvent(self.statusText, "OnSizeChanged", UpdateLabelSize)
    self:HookEvent(self.label, "OnTextSizeChanged", UpdateLabelSize)
    self:HookEvent(self, "OnSizeChanged", UpdateLabelSize)
    
    -- Object to hold stuff that expands.
    local contentsClass = GUIObject
    contentsClass = GetExpandableWrappedClass(contentsClass)
    self.contents = CreateGUIObject("contents", contentsClass, self.holder,
    {
        expanded = false,
    })
    self.contents:HookEvent(self, "OnSizeChanged", self.contents.SetWidth)
    self.contents:SetHeight(kContentsHeight)
    
    self.paddedContents = CreateGUIObject("paddedContents", GUIMenuBasicBox, self.contents)
    self.paddedContents:HookEvent(self.contents, "OnSizeChanged", UpdatePaddedContentsSize)
    self.paddedContents:AlignCenter()
    
    self.contentsScrollPane = CreateGUIObject("contentsScrollPane", GUIMenuScrollPane, self.paddedContents,
    {
        horizontalScrollBarEnabled = false,
    })
    self.contentsScrollPane:HookEvent(self.paddedContents, "OnSizeChanged", self.contentsScrollPane.SetSize)
    
    self.description = CreateGUIObject("horizontalScrollBarEnabled", GUIParagraph, self.contentsScrollPane)
    self:HookEvent(self, "OnModDescriptionChanged", UpdateDescription)
    self.description:SetPosition(kDescriptionPadding)
    self.contentsScrollPane:HookEvent(self.description, "OnSizeChanged", UpdatePaneSizeFromDescription)
    self.description:HookEvent(self, "OnSizeChanged", UpdateDescriptionMaxWidthFromSize)
    self.description:SetFont(MenuStyle.kModDescriptionFont)
    self.description:SetColor(MenuStyle.kModDescriptionColor)
    
    self.back = CreateGUIObject("back", GUIMenuBasicBox, self)
    self.back:HookEvent(self, "OnSizeChanged", self.back.SetSize)
    self.back:SetLayer(-1)
    
    self.downloadBar = CreateGUIObject("downloadBar", GUIMenuModsEntryDownloadBar, self)
    self.downloadBar:SetLayer(2)
    self.downloadBar:SetBlendTechnique(GUIItem.Add)
    self.downloadBar:HookEvent(self, "OnSizeChanged", self.downloadBar.SetHeight)
    
    self:HookEvent(self, "OnSubscribedChanged", UpdateVisuals)
    self:HookEvent(self, "OnModStateChanged", UpdateVisuals)
    self:HookEvent(self, "OnDownloadProgressChanged", UpdateVisuals)
    self:HookEvent(self, "OnSizeChanged", UpdateVisuals)
    
    self:HookEvent(self, "OnPressed", ToggleSelected)
    self:HookEvent(self, "OnDestroy", EnsureNotSelected)
    
    self:HookEvent(self, "OnSelectedChanged", UpdateSelectionVisuals)
    
end
