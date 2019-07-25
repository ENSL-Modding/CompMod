-- ======= Copyright (c) 2003-2014, Unknown Worlds Entertainment, Inc. All rights reserved. ======
--
-- lua\menu\ServerTabs.lua
--
--    Created by:   Andreas Urwalek (andi@unknownworlds.com)
--
-- ========= For more inTableation, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/menu/MenuElement.lua")
Script.Load("lua/menu/WindowUtility.lua")
Script.Load("lua/menu/ServerList.lua")

class 'ServerTabs' (MenuElement)

function ServerTabs:Initialize()
    MenuElement.Initialize(self)

    self:SetCSSClass("main_server_tabs")

    self:CreateTabs()

    self.playerCountDisplay = CreateMenuElement(self, "Font")
    self.playerCountDisplay:SetCSSClass("server_tab_players")
    --FIXME Below always breaks or just isn't enough space (due to size of tabs) on 4:3 all resolutions
    self.playerCountDisplay:SetLeftOffset(GUIScale(20)) --Todo: Scale on resolution change
    
    self:CreateRefresh()

    self.serverCountDisplay = CreateMenuElement(self, "MenuButton")
    self.serverCountDisplay:SetCSSClass("server_count_display")
    self.serverCountDisplay.backgroundHoverColor = nil
    self.serverCountDisplay.clickCallbacks = {}
    self.serverCountDisplay:AddEventCallbacks{
        OnMouseIn = function()
            local kTooltip = GetGUIManager():CreateGUIScriptSingle("menu/GUIHoverTooltip")
            kTooltip:SetText(Locale.ResolveString("SB_SERVERCOUNT"))
            kTooltip:Show()
        end,
        OnMouseOut = function()
            GetGUIManager():CreateGUIScriptSingle("menu/GUIHoverTooltip"):Hide()
        end
    }
end

function ServerTabs:GetTagName()
    return "servertabs"
end

function ServerTabs:SetServerList(serverList)
    self.serverList = serverList

    self:SelectTabByName(Client.GetOptionString("currentGameModeFilter", "ALL"))
end

function ServerTabs:EnableFilter(filters)

    if self.serverList then

        for index, filterFunc in pairs(filters) do
            self.serverList:SetFilter(index, filterFunc)
        end


    else
        Print("Warning: No server list set for ServerTabs item.")
    end

end

function ServerTabs:SetGameTypes(gameTypes)

    local types = {}
    for gameType, playerCount in pairs(gameTypes) do
        table.insert(types, {name = gameType, count = playerCount})
    end

    local playercounts = {0,0,0}

    for _, type in ipairs(types) do

        local gameType = type.name

        if gameType == "ns2" then

            playercounts[1] = type.count

        else

            playercounts[2] = playercounts[2] + type.count

        end

        playercounts[3] = playercounts[3] + type.count

    end
    
    local numSearching = Matchmaking_GetNumInGlobalLobby() or 0

    --At resolutions with a with lower 1200 the player count display just doesn't fit in
    local playercountText = ""
    if Client.GetScreenWidth() > 1200 then
        playercountText = string.format(Locale.ResolveString("SERVERBROWSER_PLAYERCOUNT"), playercounts[3], numSearching)
    end
    self.playerCountDisplay:SetText(playercountText)

    self.tabs.NS2.player:SetText(tostring(playercounts[1]))
    self.tabs.MODDED.player:SetText(tostring(playercounts[2]))
    self.tabs.ALL.player:SetText(tostring(playercounts[3]))
end

function ServerTabs:SetFontName(fontName)
    self.fontName = fontName
end

function ServerTabs:SetTextColor(color)
    self.textColor = color
end

function ServerTabs:SetHoverTextColor(color)
    self.highLightColor = color
end


local gametabBackground = PrecacheAsset("ui/menu/serverbrowser/gametagbackground.dds")
local gametabHighlight = PrecacheAsset("ui/menu/serverbrowser/menuhighlight.dds")

function ServerTabs:CreateGameTab(name, css)
    local background = CreateMenuElement(self, "Image")
    background:SetCSSClass(string.format("%s_%s",css, "background"))

    local tab = CreateMenuElement(background, "Image")
    tab.backgroundTexture = gametabBackground
    tab.backgroundTextureActive = gametabHighlight

    tab.name = CreateMenuElement(tab, "Font")
    tab.name:SetCSSClass("server_tab_name")
    tab.name:SetText(Locale.ResolveString(name))

    local textOffset = tab.name:GetTextWidth()/3
    tab.name:SetLeftOffset(-2*textOffset)

    tab.player = CreateMenuElement(tab, "Font")
    tab.player:SetCSSClass("server_tab_player")
    tab.player:SetLeftOffset(textOffset)

    tab.isGameTab = true

    return tab
end

function ServerTabs:CreateImage()
    return CreateMenuElement(self, "Image")
end

function ServerTabs:CreateDivider()
    return CreateMenuElement(self, "Image")
end

local createFunction =
{
    default = ServerTabs.CreateImage,
    gameTab = ServerTabs.CreateGameTab,
    divider = ServerTabs.CreateDivider,
}

function ServerTabs:CreateElement(type, css, name)
    local element = createFunction[type](self, name, css)
    element:SetCSSClass(css)

    return element
end

--Deprecated
function ServerTabs:Reset()
end

function ServerTabs:UnSelectAllTabs()
    for _, tab in ipairs(self.tabs) do
        tab.selected = false
        tab:OnMouseOut()
    end
end

function ServerTabs:SelectTab(tab)
    self:UnSelectAllTabs()

    self:GetParent():ResetSlideBar()

    tab.selected = true
    tab:OnMouseIn()

    if tab.isGameTab then
        self.lastGameTab = tab
    end

    Client.SetOptionString("currentGameModeFilter", tab.tabName or "ALL")
end

function ServerTabs:SelectTabByName(name)
    local tab = self.tabs[name] or self.tabs.NS2
    tab:OnClick()

    --Hide the tooltip that OnClick shows
    GetGUIManager():CreateGUIScriptSingle("menu/GUIHoverTooltip"):Hide(0)
end

function ServerTabs:CreateTab(name, type, css, onClick, background, activeBackground, tooltip)
    local tab = self:CreateElement(type or "default", css, name)

    --some create methods allready set these
    tab.tabName = tab.tabName or name
    tab.backgroundTexture = tab.backgroundTexture or background
    tab.backgroundTextureActive = tab.backgroundTextureActive or activeBackground

    tab:SetBackgroundTexture(tab.backgroundTexture)

    tab:AddEventCallbacks{
        OnClick = function()
            onClick()
            if not tab.selected or tab.isGameTab then
                self:SelectTab(tab)
            else
                self.lastGameTab:OnClick()
            end

        end,
        OnMouseIn = function(self)
            self:SetBackgroundTexture(self.backgroundTextureActive)
            if tooltip then
                local kTooltip = GetGUIManager():CreateGUIScriptSingle("menu/GUIHoverTooltip")
                kTooltip:SetText(Locale.ResolveString(name))
                kTooltip:Show()
            end
        end,
        OnMouseOut = function(self)
            if not self.selected then
                self:SetBackgroundTexture(self.backgroundTexture)
            end
            
            if tooltip then
                GetGUIManager():CreateGUIScriptSingle("menu/GUIHoverTooltip"):Hide()
            end
        end
    }

    table.insert(self.tabs,tab) -- to iterate over tabs
    self.tabs[name] = tab -- to easily get a given tab by name

    return tab
end

function ServerTabs:CreateRefresh()
    self.serverRefresh = CreateMenuElement(self, "Image")
    self.serverRefresh:SetCSSClass("server_refresh")
    self.serverRefresh.backgroundTexture = PrecacheAsset("ui/menu/refresh_icon.dds")
    self.serverRefresh.backgroundTextureActive = PrecacheAsset("ui/menu/refresh_icon_lit.dds")
    self.serverRefresh:SetBackgroundTexture(self.serverRefresh.backgroundTexture)

    self.serverRefresh:AddEventCallbacks{
        OnClick = function()
            GetGUIMainMenu():UpdateServerList()
        end,
        OnMouseIn = function(self)
            self:SetBackgroundTexture(self.backgroundTextureActive)
            local kTooltip = GetGUIManager():CreateGUIScriptSingle("menu/GUIHoverTooltip")
            kTooltip:SetText(Locale.ResolveString("REFRESH"))
            kTooltip:Show()
        end,
        OnMouseOut = function(self)
            if not self.rotating then
                self:SetBackgroundTexture(self.backgroundTexture)
            end

            GetGUIManager():CreateGUIScriptSingle("menu/GUIHoverTooltip"):Hide()
        end
    }
end

--Todo: Generalize this method
function ServerTabs:CreateTabs()
    self.tabs = {}

    self.lastGameTab = self:CreateTab(
        "ALL",
        "gameTab",
        "server_tab_all",
        function()
            self:EnableFilter{
                [1] = FilterServerMode("all"),
                [8] = FilterFavoriteOnly(false),
                [11] = FilterHistoryOnly(false),
                [13] = FilterFriendsOnly(false),
                [14] = FilterBlockedOnly(false)
            }
        end
    )

    self:CreateTab(
        "NS2",
        "gameTab",
        "server_tab_ns2",
        function()
            self:EnableFilter{
                [1] = FilterServerMode("ns2"),
                [8] = FilterFavoriteOnly(false),
                [11] = FilterHistoryOnly(false),
                [13] = FilterFriendsOnly(false),
                [14] = FilterBlockedOnly(false)
            }
        end
    )

    self:CreateTab(
        "MODDED",
        "gameTab",
        "server_tab_custom",
        function()
            self:EnableFilter{
                [1] = FilterServerMode("custom"),
                [8] = FilterFavoriteOnly(false),
                [11] = FilterHistoryOnly(false),
                [13] = FilterFriendsOnly(false),
                [14] = FilterBlockedOnly(false)
            }
        end
    )

    self:CreateTab(
        "FRIENDS",
        nil,
        "server_friends",
        function()
            Analytics.RecordEvent( "serverbrowser_friendstab" )
            self:EnableFilter{
                [1] = FilterServerMode(""),
                [8] = FilterFavoriteOnly(false),
                [11] = FilterHistoryOnly(false),
                [13] = FilterFriendsOnly(true),
                [14] = FilterBlockedOnly(false)
            }
        end,
        PrecacheAsset("ui/menu/friends_icon.dds"),
        PrecacheAsset("ui/menu/friends_icon_lit.dds"),
        true
    )

    self:CreateTab(
        "FAVORITES",
        nil,
        "server_favorite",
        function()
            self:EnableFilter{
                [1] = FilterServerMode(""),
                [8] = FilterFavoriteOnly(true),
                [11] = FilterHistoryOnly(false),
                [13] = FilterFriendsOnly(false),
                [14] = FilterBlockedOnly(false)
            }
        end,
        PrecacheAsset("ui/menu/favorites_icon.dds"),
        PrecacheAsset("ui/menu/favorites_icon_lit.dds"),
        true
    )

    self:CreateTab(
            "BLOCKED",
            nil,
            "server_blocked",
            function()
                self:EnableFilter{
                    [1] = FilterServerMode(""),
                    [8] = FilterFavoriteOnly(false),
                    [11] = FilterHistoryOnly(false),
                    [13] = FilterFriendsOnly(false),
                    [14] = FilterBlockedOnly(true)
                }
            end,
            PrecacheAsset("ui/menu/blocked_icon.dds"),
            PrecacheAsset("ui/menu/blocked_icon_lit.dds"),
            true
    )

    self:CreateTab(
        "HISTORY",
        nil,
        "server_history",
        function()
            self:EnableFilter{
                [1] = FilterServerMode(""),
                [8] = FilterFavoriteOnly(false),
                [11] = FilterHistoryOnly(true),
                [13] = FilterFriendsOnly(false),
                [14] = FilterBlockedOnly(false)
            }
        end,
        PrecacheAsset("ui/menu/history_icon.dds"),
        PrecacheAsset("ui/menu/history_icon_lit.dds"),
        true
    )
end