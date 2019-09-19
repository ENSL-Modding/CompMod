-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/NavBar/Screens/ServerBrowser/Columns/GMSBColumnPlayers.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Defines the header and contents classes for the "players" column of the server browser.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/GUIGraphic.lua")
Script.Load("lua/menu2/NavBar/Screens/ServerBrowser/GMSBColumn.lua")
Script.Load("lua/menu2/NavBar/Screens/ServerBrowser/GMSBColumnHeadingText.lua")

---@class GMSBColumnHeadingPlayers : GMSBColumnHeadingText
class "GMSBColumnHeadingPlayers" (GMSBColumnHeadingText)

kFriendIconTexture = PrecacheAsset("ui/newMenu/server_browser/friend_on_server.dds")

local function OnHeadingPressed(self)
    
    local serverBrowser = GetServerBrowser()
    assert(serverBrowser)
    
    if serverBrowser:GetSortFunction() == ServerBrowserSortFunctions.PlayerCount then
        serverBrowser:SetSortFunction(ServerBrowserSortFunctions.PlayerCountReversed)
    else
        serverBrowser:SetSortFunction(ServerBrowserSortFunctions.PlayerCount)
    end
    
end

function GMSBColumnHeadingPlayers:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    PushParamChange(params, "label", Locale.ResolveString("SERVERBROWSER_PLAYERS"))
    GMSBColumnHeadingText.Initialize(self, params, errorDepth)
    PopParamChange(params, "label")
    
    self:HookEvent(self, "OnPressed", OnHeadingPressed)
    
end


---@class GMSBColumnContentsPlayers : GMSBColumnContents
class "GMSBColumnContentsPlayers" (GMSBColumnContents)

local function UpdatePlayerCount(self)
    local exists = self.entry:GetExists()
    local playerCount = self.entry:GetPlayerCount()
    local playerMax = self.entry:GetPlayerMax()
    if exists then
        self.playerCount:SetText(string.format("  %d/%d", math.max(0, playerCount), playerMax))
    else
        self.playerCount:SetText("???")
    end
end

local function UpdateSpectatorCount(self)
    local exists = self.entry:GetExists()
    local spectatorCount = self.entry:GetSpectatorCount()
    local spectatorMax = self.entry:GetSpectatorMax()
    if (spectatorCount == 0 and spectatorMax == 0) or not exists then
        self.spectatorCount:SetText("")
    else
        self.spectatorCount:SetText(string.format("  [%d/%d]", math.max(0, spectatorCount), spectatorMax))
    end
end
local function UpdateColors(self)
    local selected = self.entry:GetSelected()
    local exists = self.entry:GetExists()
    
    if exists then
        if selected then
            self.friendIcon:SetColor(MenuStyle.kHighlight)
            self.playerCount:SetColor(MenuStyle.kHighlight)
            self.spectatorCount:SetColor(MenuStyle.kServerBrowserEntrySpecSelectedColor)
        else
            self.friendIcon:SetColor(MenuStyle.kServerNameColor)
            self.playerCount:SetColor(MenuStyle.kServerNameColor)
            self.spectatorCount:SetColor(MenuStyle.kServerBrowserIconDim)
        end
    else
        self.playerCount:SetColor(MenuStyle.kServerBrowserIconDim)
    end
end

local function UpdateFriendsOnServer(self)
    local friendsOnServer = self.entry:GetFriendsOnServer()
    local exists = self.entry:GetExists()
    self.friendIcon:SetVisible(friendsOnServer and exists)
end

local function UpdateShared(self)
    UpdatePlayerCount(self)
    UpdateSpectatorCount(self)
    UpdateColors(self)
    UpdateFriendsOnServer(self)
end

function GMSBColumnContentsPlayers:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    GMSBColumnContents.Initialize(self, params, errorDepth)
    
    self.layout = CreateGUIObject("layout", GUIListLayout, self, {orientation = "horizontal"})
    self.layout:AlignCenter()
    
    self.friendIcon = CreateGUIObject("friendIcon", GUIGraphic, self.layout)
    self.friendIcon:SetTexture(kFriendIconTexture)
    self.friendIcon:SetSizeFromTexture()
    self.friendIcon:SetColor(MenuStyle.kServerBrowserIconDim)
    self.friendIcon:AlignLeft()
    
    self.playerCount = CreateGUIObject("playerCount", GUIText, self.layout)
    self.playerCount:SetFont(MenuStyle.kServerNameFont)
    self.playerCount:SetColor(MenuStyle.kServerNameColor)
    self.playerCount:AlignLeft()
    
    self.spectatorCount = CreateGUIObject("spectatorCount", GUIText, self.layout)
    self.spectatorCount:SetFont(MenuStyle.kServerNameFont)
    self.spectatorCount:SetColor(MenuStyle.kServerBrowserIconDim)
    self.spectatorCount:AlignLeft()
    
    assert(self.entry)
    self:HookEvent(self.entry, "OnPlayerCountChanged", UpdatePlayerCount)
    self:HookEvent(self.entry, "OnPlayerMaxChanged", UpdatePlayerCount)
    self:HookEvent(self.entry, "OnExistsChanged", UpdateShared)
    self:HookEvent(self.entry, "OnSpectatorCountChanged", UpdateSpectatorCount)
    self:HookEvent(self.entry, "OnSpectatorMaxChanged", UpdateSpectatorCount)
    self:HookEvent(self.entry, "OnFriendsOnServerChanged", UpdateFriendsOnServer)
    self:HookEvent(self.entry, "OnSelectedChanged", UpdateColors)
    
    UpdateShared(self)
    
end

RegisterServerBrowserColumnType("Players", GMSBColumnHeadingPlayers, GMSBColumnContentsPlayers, 420, 896)
