-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/NavBar/Screens/ServerBrowser/Columns/GMSBColumnServerName.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Defines the header and contents classes for the "server name" column of the server browser.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/menu2/NavBar/Screens/ServerBrowser/GMSBColumn.lua")
Script.Load("lua/menu2/NavBar/Screens/ServerBrowser/GMSBColumnHeadingText.lua")
Script.Load("lua/GUI/layouts/GUIListLayout.lua")

---@class GMSBColumnHeadingServerName : GMSBColumnHeadingText
class "GMSBColumnHeadingServerName" (GMSBColumnHeadingText)

local function OnHeadingPressed(self)
    
    local serverBrowser = GetServerBrowser()
    assert(serverBrowser)
    
    if serverBrowser:GetSortFunction() == ServerBrowserSortFunctions.ServerName then
        serverBrowser:SetSortFunction(ServerBrowserSortFunctions.ServerNameReversed)
    else
        serverBrowser:SetSortFunction(ServerBrowserSortFunctions.ServerName)
    end
    
end

function GMSBColumnHeadingServerName:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    PushParamChange(params, "label", Locale.ResolveString("SERVERBROWSER_SERVERNAME"))
    GMSBColumnHeadingText.Initialize(self, params, errorDepth)
    PopParamChange(params, "label")
    
    self:HookEvent(self, "OnPressed", OnHeadingPressed)
    
end


---@class GMSBColumnContentsServerName : GMSBColumnContents
class "GMSBColumnContentsServerName" (GMSBColumnContents)

local function OnServerNameChanged(self, serverName, prevServerName)
    self.serverName:SetText(serverName)
end

local function UpdateMapNameText(self)
    
    local mapName = self.entry:GetMapName()
    local rookieOnly = self.entry:GetRookieOnly()
    
    if rookieOnly then
        self.rookieText:SetText(Locale.ResolveString("SERVERBROWSER_ROOKIEONLY"))
        self.mapName:SetText("  |  "..mapName)
    else
        self.rookieText:SetText("")
        self.mapName:SetText(mapName)
    end
    
end

local function OnSelectedChanged(self, selected, prevSelected)
    
    if selected then
        self.serverName:SetColor(MenuStyle.kHighlight)
        self.mapName:SetColor(MenuStyle.kServerBrowserHighlightDarker)
    else
        self.serverName:SetColor(MenuStyle.kServerNameColor)
        self.mapName:SetColor(MenuStyle.kServerBrowserIconDim)
    end
    
end

function GMSBColumnContentsServerName:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    GMSBColumnContents.Initialize(self, params, errorDepth)
    
    self.textLayout = CreateGUIObject("textLayout", GUIListLayout, self, {orientation = "vertical"})
    self.textLayout:SetSpacing(4)
    self.textLayout:AlignLeft()
    
    self.serverName = CreateGUIObject("serverName", GUIText, self.textLayout)
    self.serverName:SetFont(MenuStyle.kServerNameFont)
    self.serverName:SetColor(MenuStyle.kServerNameColor)
    
    self.mapNameLayout = CreateGUIObject("mapNameLayout", GUIListLayout, self.textLayout, {orientation = "horizontal"})
    
    self.rookieText = CreateGUIObject("rookieText", GUIText, self.mapNameLayout)
    self.rookieText:SetFont(MenuStyle.kServerNameFont)
    self.rookieText:SetColor(MenuStyle.kRookieTextColor)
    
    self.mapName = CreateGUIObject("mapName", GUIText, self.mapNameLayout)
    self.mapName:SetFont(MenuStyle.kServerNameFont)
    self.mapName:SetColor(MenuStyle.kServerBrowserIconDim)
    
    assert(self.entry)
    self:HookEvent(self.entry, "OnServerNameChanged", OnServerNameChanged)
    self:HookEvent(self.entry, "OnMapNameChanged", UpdateMapNameText)
    self:HookEvent(self.entry, "OnRookieOnlyChanged", UpdateMapNameText)
    self:HookEvent(self.entry, "OnSelectedChanged", OnSelectedChanged)
    
    OnServerNameChanged(self, self.entry:GetServerName())
    UpdateMapNameText(self)
    OnSelectedChanged(self, self.entry:GetSelected())
    
end

RegisterServerBrowserColumnType("ServerName", GMSBColumnHeadingServerName, GMSBColumnContentsServerName, 1120, 640)
