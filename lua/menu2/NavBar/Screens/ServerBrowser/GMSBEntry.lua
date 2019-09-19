-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. ============
--
-- lua/menu2/NavBar/Screens/ServerBrowser/GMSBEntry.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    The data and visual representation of a single server displayable in the server browser list.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =======================

Script.Load("lua/GUI/GUIObject.lua")

Script.Load("lua/GUI/layouts/GUIListLayout.lua")
Script.Load("lua/GUI/layouts/GUIFillLayout.lua")
Script.Load("lua/menu2/NavBar/Screens/ServerBrowser/GMSBEntryDetailsBox.lua")
Script.Load("lua/menu2/NavBar/Screens/ServerBrowser/GMSBEntryDetailsScrollerDraggable.lua")
Script.Load("lua/menu2/NavBar/Screens/ServerBrowser/GMSBEntryDetailsScrollBarButton.lua")
Script.Load("lua/menu2/NavBar/Screens/ServerBrowser/GMSBEntryDetailsPlayerRow.lua")
Script.Load("lua/menu2/NavBar/Screens/ServerBrowser/GMSBEntryGlowyBackground.lua")

Script.Load("lua/ServerPerformanceData.lua")

Script.Load("lua/menu2/wrappers/Expandable.lua")

---@class GMSBEntry : GUIObject
class "GMSBEntry" (GUIObject)

local kColumnContentsHeight = 120

local kDetailsInsetMargin = Vector(18, 12, 0)
local kDetailsBoxShader = PrecacheAsset("shaders/GUI/menu/serverEntryDetails.surface_shader")
local kDetailsBoxLeftWidth = 1140
local kDetailsBoxTabHeight = 50
local kDetailsBoxHeight = 460
local kDetailsInteriorMargin = Vector(12, 8, 0)
local kModsBoxMargin = 20
local kModsBoxWidth = 900

local kDetailsRightColumnXOffset = 40
local kDetailsRightListTopPadding = 10
local kDetailsRightListBottomPadding = 10

local kOddColor = HexToColor("181b21", 0.4)
local kEvenColor = HexToColor("14141b", 0.3)
local kOddRookieColor = HexToColor("137933", 0.3)
local kEvenRookieColor = HexToColor("137933", 0.2)

GMSBEntry:AddClassProperty("Blocked", false)
GMSBEntry:AddClassProperty("CurrentPerformanceScore", 60)
GMSBEntry:AddClassProperty("CustomNetworkSettings", false)
GMSBEntry:AddClassProperty("Exists", false) -- If false, the server only exists in the user's history.
GMSBEntry:AddClassProperty("Favorited", false)
GMSBEntry:AddClassProperty("FilteredOut", true) -- If true, this server is not visible because it has been filtered out.
GMSBEntry:AddClassProperty("FriendsOnServer", false)
GMSBEntry:AddClassProperty("GameMode", "ns2")
GMSBEntry:AddClassProperty("Historical", false) -- server is in the user's history.
GMSBEntry:AddClassProperty("Index", -1) -- ENGINE index, not related to the sorted list of server entries.
GMSBEntry:AddClassProperty("IndexEven", false) -- Not related to Index.  Used to determine coloring so adjacent entries have alternating colors.
GMSBEntry:AddClassProperty("IndexColoringLerp", 0) -- smoothly animate between even and odd coloring in list.
GMSBEntry:AddClassProperty("LastConnect", 0)
GMSBEntry:AddClassProperty("MapName", "ns2_summit")
GMSBEntry:AddClassProperty("Modded", false)
GMSBEntry:AddClassProperty("ModsList", {}) -- list of mod name strings
GMSBEntry:AddClassProperty("Passworded", false)
GMSBEntry:AddClassProperty("PerformanceQuality", 85)
GMSBEntry:AddClassProperty("PerformanceRating", "")
GMSBEntry:AddClassProperty("PerformanceScore", 60)
GMSBEntry:AddClassProperty("Ping", 0)
GMSBEntry:AddClassProperty("PlayerCount", 0)
GMSBEntry:AddClassProperty("PlayerMax", 0)
GMSBEntry:AddClassProperty("PlayerScores", {}, true) -- list of score entry tables: {name="", timePlayed=999, points=999}
GMSBEntry:AddClassProperty("QuickPlayRankIndex", -1) -- index of this entry in the list sorted by "Ranking"
GMSBEntry:AddClassProperty("QuickPlayReady", false)
GMSBEntry:AddClassProperty("Ranked", false)
GMSBEntry:AddClassProperty("Ranking", 0) -- the quick play ranking of the server.
GMSBEntry:AddClassProperty("ReservedSlotCount", 0)
GMSBEntry:AddClassProperty("RookieOnly", false)
GMSBEntry:AddClassProperty("Selected", false)
GMSBEntry:AddClassProperty("ServerName", "Frank's Rookie Ballpit of Safety [Rookie Friendly](Floaties Required)")
GMSBEntry:AddClassProperty("ServerNameNoBS", "franksrookieballpitofsafetyrookiefriendlyfloatiesrequired") -- the "no bullshit" variant of the server name, for sorting.
GMSBEntry:AddClassProperty("Skill", 0)
GMSBEntry:AddClassProperty("SpectatorCount", 0)
GMSBEntry:AddClassProperty("SpectatorMax", 0)

local function CreateColumnContent(self, columnDef)
    
    local newContent = CreateGUIObject("column"..columnDef.name, columnDef.contentsClass, self.columnsHolder,
    {
        weight = columnDef.weight,
        entry = self,
    })
    newContent:SetSize(newContent:GetSize().x, kColumnContentsHeight)
    
end

local function CreateColumnsContents(self)
    
    local columnTypeDefs = GetSortedColumnTypeDefs()
    for i=1, #columnTypeDefs do
        CreateColumnContent(self, columnTypeDefs[i])
    end
    
end

local function OnSizeChanged(self, size, prevSize)
    
    if size.x ~= prevSize.x then
        -- We only care about width changes here.
        self.layout:SetSize(size.x, self.layout:GetSize().y)
        self.columnsHolder:SetSize(size.x, kColumnContentsHeight)
        self.detailsHolder:SetSize(size.x, self.detailsHolder:GetSize().y)
    end
    
    self.dimBackground:SetSize(self:GetSize())
    self.glowyBackground:SetSize(self:GetSize() - Vector(8, 0, 0))
    
end

local function UpdateDetailsBoxWidth(detailsBox, size, prevSize)
    
    if prevSize and size.x == prevSize.x then
        return -- Don't care unless width has changed (or called manually).
    end
    
    detailsBox:SetSize(size.x - (kDetailsInsetMargin.x * 2), kDetailsBoxHeight)
    
end

local function UpdateDetailsLeftHolderSize(leftDetailsHolder, size)
    leftDetailsHolder:SetSize(kDetailsBoxLeftWidth - kDetailsInteriorMargin.x * 2, size.y - kDetailsInteriorMargin.y * 2)
end

local function UpdateModsListHolderHeight(self)
    self.modsListHolder:SetHeight(self.detailsLeftHolder:GetSize().y - self.detailsTextLayout:GetSize().y)
end

local function OnDetailsLeftHolderHeightChanged(self, size, prevSize)
    
    if prevSize and size.y == prevSize.y then
        return -- only care about height changes.
    end
    
    UpdateModsListHolderHeight(self)
    
end

local function UpdateDetailsRightColumnsHolderWidth(rightColumnsHolder, size, prevSize)
    
    if prevSize and size.x == prevSize.x then
        return -- only care about width changes.
    end
    
    rightColumnsHolder:SetSize(size.x - kDetailsBoxTabHeight - kDetailsBoxLeftWidth - kDetailsRightColumnXOffset, rightColumnsHolder:GetSize().y)
    
end

local function UpdatePlayerStatsBoxSize(self)
    
    local detailsBoxHeight = self.detailsBox:GetSize().y
    local detailsRightColumnsHolderWidth = self.detailsRightColumnsHolder:GetSize().x
    local tabHeight = self.detailsBox:GetTabHeight()
    
    self.playerStatsBox:SetSize(detailsRightColumnsHolderWidth, detailsBoxHeight - tabHeight)
    
end

local function OnModsListChanged(self, list)
    
    -- Destroy mod list entries until we have no more than the new list.
    while #self.modsListEntries > #list do
        local destroyingObject = self.modsListEntries[#self.modsListEntries]
        AssertIsaGUIObject(destroyingObject)
        self.modsListEntries[#self.modsListEntries] = nil
        destroyingObject:Destroy()
    end
    
    -- Add mod list entries until we have no fewer than the new list.
    while #self.modsListEntries < #list do
        local newObject = CreateGUIObject("modListEntry", GUIText, self.modsList)
        newObject:SetFont(MenuStyle.kServerNameFont)
        newObject:SetColor(MenuStyle.kServerBrowserHighlightDarker)
        self.modsListEntries[#self.modsListEntries+1] = newObject
    end
    
    assert(#list == #self.modsListEntries)
    
    -- Update the text to reflect the new list.
    for i=1, #list do
        self.modsListEntries[i]:SetText(list[i])
    end
    
end

local function OnPlayerScoresChanged(self, list)
    
    -- Destroy player scores entries until we have no more than the new list.
    while #self.playerScoresListEntries > #list do
        local destroyingObject = self.playerScoresListEntries[#self.playerScoresListEntries]
        AssertIsaGUIObject(destroyingObject)
        self.playerScoresListEntries[#self.playerScoresListEntries] = nil
        destroyingObject:Destroy()
    end
    
    -- Add player score list entries until we have no fewer than the new list.
    while #self.playerScoresListEntries < #list do
        local newObject = CreateGUIObject("playerScoreListEntry", GMSBEntryDetailsPlayerRow, self.playerScoresList)
        self.playerScoresListEntries[#self.playerScoresListEntries+1] = newObject
    end
    
    assert(#list == #self.playerScoresListEntries)
    
    -- Update the contents of the entries to the new list.
    for i=1, #list do
        local newEntry = list[i]
        
        local entry = self.playerScoresListEntries[i]
        
        entry:SetPlayerName(newEntry.name)
        entry:SetTimePlayed(newEntry.timePlayed)
        entry:SetScore(newEntry.score)
    end
    
end

local kPerfRatingColors =
{
    SERVER_PERF_GOOD    = MenuStyle.kPingColorGood,
    SERVER_PERF_OK      = MenuStyle.kPingColorOkay,
    SERVER_PERF_LOADED  = MenuStyle.kPingColorBad,
    SERVER_PERF_BAD     = MenuStyle.kPingColorTerrible,
}

local function OnPerformanceRatingChanged(self, perfRating)
    
    self.performanceRatingText:SetText(Locale.ResolveString(perfRating))
    self.performanceRatingText:SetColor(kPerfRatingColors[perfRating] or MenuStyle.kLightGrey)
    
end

local function UpdatePerfRating(self)
    local perfQuality = self:GetPerformanceQuality()
    local perfScore = self:GetPerformanceScore()
    self:SetPerformanceRating(ServerPerformanceData.GetPerformanceTextNoResolve(perfQuality, perfScore))
end

local function UpdateAddressText(self)
    
    local serverIndex = self:GetIndex()
    local rawAddress = self.address
    local dns = Client.GetServerKeyValue(serverIndex, "sv_dyndns")
    
    local addressString
    if dns and dns ~= "" then
        local _, port = string.match(rawAddress, "(.+):(%d+)")
        addressString = string.format("%s:%s", dns, port)
    else
        addressString = rawAddress
    end
    
    self.serverAddressText:SetText(string.format("%s: %s", Locale.ResolveString("SERVERBROWSER_SERVER_DETAILS_ADDRESS"), addressString))
    
end

local function CreateDetailsContents(self)
    
    -- Inset details box by a certain margin all around.
    self.detailsBox = CreateGUIObject("detailsBox", GMSBEntryDetailsBox, self.detailsHolder)
    self.detailsBox:HookEvent(self, "OnSizeChanged", UpdateDetailsBoxWidth)
    self.detailsBox:SetLeftWidth(kDetailsBoxLeftWidth)
    self.detailsBox:SetTabHeight(kDetailsBoxTabHeight)
    self.detailsBox:SetPosition(kDetailsInsetMargin)
    
    self.detailsLeftHolder = CreateGUIObject("detailsLeftHolder", GUIObject, self.detailsBox)
    self.detailsLeftHolder:HookEvent(self.detailsBox, "OnSizeChanged", UpdateDetailsLeftHolderSize)
    self.detailsLeftHolder:SetPosition(kDetailsInteriorMargin)
    
    self.detailsTextLayout = CreateGUIObject("detailsTextLayout", GUIListLayout, self.detailsLeftHolder, {orientation = "vertical"})
    
    self.serverAddressText = CreateGUIObject("serverAddressText", GUIText, self.detailsTextLayout)
    self.serverAddressText:SetFont(MenuStyle.kServerNameFont)
    self.serverAddressText:SetColor(MenuStyle.kServerNameColor)
    self.serverAddressText:SetText(string.format("%s: %s", Locale.ResolveString("SERVERBROWSER_SERVER_DETAILS_ADDRESS"), self.address))
    
    self.performanceRatingLayout = CreateGUIObject("performanceRatingLayout", GUIListLayout, self.detailsTextLayout, {orientation = "horizontal"})
    
    self.performanceRatingTitle = CreateGUIObject("performanceRatingTitle", GUIText, self.performanceRatingLayout)
    self.performanceRatingTitle:SetFont(MenuStyle.kServerNameFont)
    self.performanceRatingTitle:SetColor(MenuStyle.kServerNameColor)
    self.performanceRatingTitle:SetText(Locale.ResolveString("SERVERBROWSER_SERVER_DETAILS_PERF")..": ")
    
    self.performanceRatingText = CreateGUIObject("performanceRatingText", GUIText, self.performanceRatingLayout)
    self.performanceRatingText:SetFont(MenuStyle.kServerNameFont)
    self.performanceRatingText:SetText("???")
    self.performanceRatingText:SetColor(MenuStyle.kDarkGrey)
    self:HookEvent(self, "OnPerformanceScoreChanged", UpdatePerfRating)
    self:HookEvent(self, "OnPerformanceQualityChanged", UpdatePerfRating)
    self:HookEvent(self, "OnPerformanceRatingChanged", OnPerformanceRatingChanged)
    
    self.installedModsText = CreateGUIObject("installedModsText", GUIText, self.detailsTextLayout)
    self.installedModsText:SetFont(MenuStyle.kServerNameFont)
    self.installedModsText:SetColor(MenuStyle.kServerNameColor)
    self.installedModsText:SetText(Locale.ResolveString("SERVERBROWSER_SERVER_DETAILS_MODS"))
    
    self.modsListHolder = CreateGUIObject("modsListHolder", GUIMenuBasicBox, self.detailsLeftHolder)
    self.modsListHolder:SetStrokeColor(MenuStyle.kServerBrowserEntryModsListStrokeColor)
    self.modsListHolder:SetStrokeWidth(MenuStyle.kStrokeWidth)
    self.modsListHolder:SetFillColor(MenuStyle.kServerBrowserEntryModsListFillColor)
    self.modsListHolder:SetSize(kModsBoxWidth, self.modsListHolder:GetSize().y)
    self.modsListHolder:AlignBottomLeft()
    self:HookEvent(self.detailsLeftHolder, "OnSizeChanged", OnDetailsLeftHolderHeightChanged)
    self:HookEvent(self.detailsTextLayout, "OnSizeChanged", UpdateModsListHolderHeight)
    
    assert(GMSBEntryDetailsScrollBarButton)
    self.modsListScrollPane = CreateGUIObject("modsListScrollPane", GUIMenuScrollPane, self.modsListHolder,
    {
        horizontalScrollBarEnabled = false,
        draggableClass = GMSBEntryDetailsScrollerDraggable,
        directionalButtonClass = GMSBEntryDetailsScrollBarButton,
    })
    self.modsListScrollPane:HookEvent(self.modsListHolder, "OnSizeChanged", self.SetSize)
    self.modsListScrollPane:SetPaneSize(1, 1)
    
    self.modsList = CreateGUIObject("modsList", GUIListLayout, self.modsListScrollPane, {orientation = "vertical"})
    self.modsList:SetFrontPadding(kModsBoxMargin)
    self.modsList:SetBackPadding(kModsBoxMargin)
    self.modsList:SetPosition(kModsBoxMargin, 0)
    self.modsListScrollPane:HookEvent(self.modsList, "OnSizeChanged", self.modsListScrollPane.SetPaneSize)
    self.modsListEntries = {}
    self:HookEvent(self, "OnModsListChanged", OnModsListChanged)
    
    self.detailsRightColumnsHolder = CreateGUIObject("detailsRightColumnsHolder", GUIObject, self.detailsBox)
    self.detailsRightColumnsHolder:AlignTopRight()
    self.detailsRightColumnsHolder:SetSize(self.detailsRightColumnsHolder:GetSize().x, kDetailsBoxTabHeight)
    self.detailsRightColumnsHolder:HookEvent(self.detailsBox, "OnSizeChanged", UpdateDetailsRightColumnsHolderWidth)
    
    self.rightColumnNameLabel = CreateGUIObject("rightColumnNameLabel", GUIText, self.detailsRightColumnsHolder)
    self.rightColumnNameLabel:SetFont(MenuStyle.kServerNameFont)
    self.rightColumnNameLabel:SetColor(MenuStyle.kHighlight)
    self.rightColumnNameLabel:SetText(Locale.ResolveString("SERVERBROWSER_NAME"))
    self.rightColumnNameLabel:AlignLeft()
    
    self.rightColumnTimePlayedLabel = CreateGUIObject("rightColumnTimePlayedLabel", GUIText, self.detailsRightColumnsHolder)
    self.rightColumnTimePlayedLabel:SetFont(MenuStyle.kServerNameFont)
    self.rightColumnTimePlayedLabel:SetColor(MenuStyle.kHighlight)
    self.rightColumnTimePlayedLabel:SetText(Locale.ResolveString("SERVERBROWSER_TIME_PLAYED"))
    self.rightColumnTimePlayedLabel:AlignLeft()
    self.rightColumnTimePlayedLabel:SetPosition(GMSBEntryDetailsPlayerRow.kTimeXOffset, 0)
    
    self.rightColumnScoreLabel = CreateGUIObject("rightColumnScoreLabel", GUIText, self.detailsRightColumnsHolder)
    self.rightColumnScoreLabel:SetFont(MenuStyle.kServerNameFont)
    self.rightColumnScoreLabel:SetColor(MenuStyle.kHighlight)
    self.rightColumnScoreLabel:SetText(Locale.ResolveString("SERVERBROWSER_SCORE"))
    self.rightColumnScoreLabel:AlignLeft()
    self.rightColumnScoreLabel:SetPosition(GMSBEntryDetailsPlayerRow.kScoreXOffset, 0)
    
    self.playerStatsBox = CreateGUIObject("playerStatsBox", GUIMenuScrollPane, self.detailsBox,
    {
        horizontalScrollBarEnabled = false,
        draggableClass = GMSBEntryDetailsScrollerDraggable,
        directionalButtonClass = GMSBEntryDetailsScrollBarButton,
    })
    self.playerStatsBox:AlignBottomRight()
    self.playerStatsBox:SetPaneSize(1, 1)
    self:HookEvent(self.detailsBox, "OnSizeChanged", UpdatePlayerStatsBoxSize)
    self:HookEvent(self.detailsBox, "OnTabHeightChanged", UpdatePlayerStatsBoxSize)
    self:HookEvent(self.detailsRightColumnsHolder, "OnSizeChanged", UpdatePlayerStatsBoxSize)
    
    self.playerScoresList = CreateGUIObject("playerScoresList", GUIListLayout, self.playerStatsBox, {orientation = "vertical"})
    self.playerScoresList:SetFrontPadding(kDetailsRightListTopPadding)
    self.playerScoresList:SetBackPadding(kDetailsRightListBottomPadding)
    self.playerStatsBox:HookEvent(self.playerScoresList, "OnSizeChanged", self.playerStatsBox.SetPaneSize)
    self.playerScoresListEntries = {}
    self:HookEvent(self, "OnPlayerScoresChanged", OnPlayerScoresChanged)
    
end

local function UpdateBackground(self)
    
    local selected = self:GetSelected()
    local rookieOnly = self:GetRookieOnly()
    local indexLerp = self:GetIndexColoringLerp()
    
    if selected then
        
        self.glowyBackground:SetVisible(true)
        self.dimBackground:SetVisible(false)
        
    else
        
        self.glowyBackground:SetVisible(false)
        self.dimBackground:SetVisible(true)
        
        local a, b
        if rookieOnly then
            a = kOddRookieColor
            b = kEvenRookieColor
        else
            a = kOddColor
            b = kEvenColor
        end
        
        self.dimBackground:SetColor(Lerp(a, b, indexLerp))
        
    end
    
end

local function OnSelectedChanged(self, selected, prevSelected)
    self.detailsHolder:SetExpanded(selected)
    UpdateBackground(self)
end

local function UpdateIndexColoringLerp(self, even)
    
    local target = even and 1 or 0
    
    self:AnimateProperty("IndexColoringLerp", target, MenuAnimations.FadeFast)
    
end

local function OnLayoutSizeChanged(self, size, prevSize)
    
    if size.y == prevSize.y then
        return -- we only care about height changes.
    end
    
    self:SetSize(self:GetSize().x, size.y)
    
end

local function OnWhiteListChanged(self, whitelist)
    self:SetRanked(whitelist[self:GetAddress()] ~= nil)
end

function GMSBEntry:GetAddress()
    return self.address
end

local function UpdateServerRanking(serverEntry)
    
    PROFILE("GMSBEntry UpdateServerRanking")
    
    local exp = math.exp
    local sqrt = math.sqrt
    local players = serverEntry:GetPlayerCount()
    local maxplayer = serverEntry:GetPlayerMax() - serverEntry:GetReservedSlotCount()

    local playerskill = GetLocalPlayerProfileData():GetSkill()
    local playerlevel = GetLocalPlayerProfileData():GetLevel()
    local playertier = GetLocalPlayerProfileData():GetSkillTier()

    local viability = 1/(1 + exp( -0.5 * (players - 12)))
    local dViability = (201.714 * exp(0.5 * players))/(403.429 + exp(0.5 * players))^2
    local player = 0.5 * viability + 0.5 * dViability *  math.max(0, math.min(maxplayer, 24) - players - 1)

    local ping = 1 / (1 + exp( 1/40 * (serverEntry:GetPing() - 150)))
    local skill = (players < 2 or playerskill == -1) and 1 or exp(- 0.1 * math.abs(serverEntry:GetSkill() - playerskill) * sqrt(players - 1) / 346.41) -- 346.41 ~= 100*sqrt(12)

    local perfscore = serverEntry:GetPerformanceScore() * serverEntry:GetPerformanceQuality() / 100
    local perf = 1/(1 + exp( - perfscore / 5 ))

    local empty = players > 0 and 1 or 0.5
    local fav = serverEntry:GetFavorited() and 2 or 1
    local blocked = serverEntry:GetBlocked() and 0.000001 or 1
    local full = players >= maxplayer and not serverEntry:GetFavorited() and 0.5 or 1
    local joinable = (not serverEntry:GetPassworded() or serverEntry:GetFavorited() or serverEntry:GetFriendsOnServer()) and 1 or 0.02
    local friend = serverEntry:GetFriendsOnServer() and 1.2 or 1
    local ranked = serverEntry:GetGameMode() == "ns2" and serverEntry:GetRanked() and 1.5 or 1

    local rookieonly = joinable == 1 and 0.3 or 1
    if serverEntry:GetRookieOnly() then
        if playerlevel == -1 or playerlevel < kRookieLevel or playertier <= kRookieMaxSkillTier then
            rookieonly = 1 + (1/exp(0.125*(playerlevel - kRookieOnlyLevel)))
        end
    else
        if playerlevel == -1 or playerlevel > kRookieOnlyLevel then
            rookieonly = 1
        end
    end

    -- rank servers the user has connected to less than 10 mins ago similar to empty ones
    local history = serverEntry:GetHistorical() and Shared.GetSystemTime() - serverEntry:GetLastConnect() <= 600 and 0.5 or 1
    
    -- arcade servers get less priority.
    local arcade = serverEntry:GetGameMode() == "ns2" and 1.0 or 0.6
    
    local ranking = player * ping * perf * skill * full * joinable * empty * fav * blocked * friend * rookieonly * ranked * history * arcade
    
    serverEntry:SetRanking(ranking)
    
end

local function RemoveBullshit(self)
    self:SetServerNameNoBS(GetBullshitFreeServerName(self:GetServerName()))
end

function GMSBEntry:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    RequireType("string", params.address, "params.address", errorDepth)
    
    GUIObject.Initialize(self, params, errorDepth)
    
    self.address = params.address
    
    self:SetFavorited(GetServerBrowser():GetFavorites()[self.address] or false)
    self:SetBlocked(GetServerBrowser():GetBlocked()[self.address] or false)
    self:SetRanked(GetServerBrowser():GetWhiteList()[self.address] or false)
    
    self.layout = CreateGUIObject("layout", GUIListLayout, self, {orientation = "vertical"})
    self.layout:SetFixedMinorSize(true)
    
    self.columnsHolder = CreateGUIObject("columnsHolder", GUIFillLayout, self.layout,
    {
        orientation = "horizontal",
        deferredArrange = true,
    })
    
    self.columnsHolder:SetSpacing(GUIMenuServerBrowser.kColumnHeadersSpacing)
    self.columnsHolder:SetFrontPadding(GUIMenuServerBrowser.kColumnHeadersSpacing * 0.5)
    self.columnsHolder:SetBackPadding(GUIMenuServerBrowser.kColumnHeadersSpacing * 0.5)
    CreateColumnsContents(self)
    
    self.detailsHolder = CreateGUIObject("detailsHolder", GetExpandableWrappedClass(GUIObject), self.layout)
    self.detailsHolder:SetExpanded(false) 
    self.detailsHolder:ClearPropertyAnimations("Expansion")
    self.detailsHolder:SetSize(self.detailsHolder:GetSize().x, kDetailsBoxHeight + kDetailsInsetMargin.y * 2)
    CreateDetailsContents(self)
    
    self.dimBackground = self:CreateGUIItem()
    self.dimBackground:SetSize(self:GetSize())
    self.dimBackground:SetLayer(-1)
    self.dimBackground:SetColor(kOddColor)
    
    self.glowyBackground = CreateGUIObject("glowyBackground", GMSBEntryGlowyBackground, self)
    self.glowyBackground:AlignCenter()
    self.glowyBackground:SetSize(self:GetSize() - Vector(8, 0, 0))
    self.glowyBackground:SetLayer(-1)
    self.glowyBackground:SetVisible(false)
    
    self:HookEvent(self, "OnSelectedChanged", OnSelectedChanged)
    
    self:HookEvent(self, "OnIndexEvenChanged", UpdateIndexColoringLerp)
    self:HookEvent(self, "OnRookieOnlyChanged", UpdateBackground)
    self:HookEvent(self, "OnIndexColoringLerpChanged", UpdateBackground)
    
    self:HookEvent(self, "OnSizeChanged", OnSizeChanged)
    self:HookEvent(self.layout, "OnSizeChanged", OnLayoutSizeChanged)
    self:SetSize(self:GetSize().x, self.layout:GetSize().y)
    
    self:HookEvent(self, "OnIndexChanged", UpdateAddressText)
    
    assert(GetServerBrowser())
    
    -- Update ranked status if the whitelist changes.
    self:HookEvent(GetServerBrowser(), "OnWhiteListChanged", OnWhiteListChanged)
    
    self:ListenForCursorInteractions()
    
    -- Server ranking has a huge number of dependencies...
    self:HookEvent(self, "OnBlockedChanged",            UpdateServerRanking)
    self:HookEvent(self, "OnFavoritedChanged",          UpdateServerRanking)
    self:HookEvent(self, "OnFriendsOnServerChanged",    UpdateServerRanking)
    self:HookEvent(self, "OnGameModeChanged",           UpdateServerRanking)
    self:HookEvent(self, "OnHistoricalChanged",         UpdateServerRanking)
    self:HookEvent(self, "OnLastConnectChanged",        UpdateServerRanking)
    self:HookEvent(self, "OnMaxPlayersChanged",         UpdateServerRanking)
    self:HookEvent(self, "OnPasswordedChanged",         UpdateServerRanking)
    self:HookEvent(self, "OnPerformanceQualityChanged", UpdateServerRanking)
    self:HookEvent(self, "OnPerformanceScoreChanged",   UpdateServerRanking)
    self:HookEvent(self, "OnPingChanged",               UpdateServerRanking)
    self:HookEvent(self, "OnPlayerCountChanged",        UpdateServerRanking)
    self:HookEvent(self, "OnRankedChanged",             UpdateServerRanking)
    self:HookEvent(self, "OnReservedSlotCountChanged",  UpdateServerRanking)
    self:HookEvent(self, "OnRookieOnlyChanged",         UpdateServerRanking)
    self:HookEvent(self, "OnSkillChanged",              UpdateServerRanking)
    self:HookEvent(GetLocalPlayerProfileData(), "OnSkillChanged",      UpdateServerRanking)
    self:HookEvent(GetLocalPlayerProfileData(), "OnLevelChanged",      UpdateServerRanking)
    self:HookEvent(GetLocalPlayerProfileData(), "OnAdagradSumChanged", UpdateServerRanking)
    
    -- Maintain a "no bullshit"-sanitized name of the server to use when sorting.
    self:HookEvent(self, "OnServerNameChanged", RemoveBullshit)
    
end

function GMSBEntry:GetCanBeDoubleClicked()
    return true
end

function GMSBEntry:OnMouseClick(double)
    
    if not double then return end
    if not self:GetExists() then return end
    
    GetServerBrowser():SetSelectedEntry(self)
    GetServerBrowser():JoinSelectedServer()
    
end

function GMSBEntry:OnMouseRelease()
    
    if not self:GetExists() then
        return
    end
    
    if self:GetSelected() then
        GetServerBrowser():SetSelectedEntry(GUIMenuServerBrowser.NoEntry)
    else
        GetServerBrowser():SetSelectedEntry(self)
    end
    
end
