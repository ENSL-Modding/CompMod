-- ======= Copyright (c) 2003-2015, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\menu\GUIMainMenu_PlayNow.lua
--
--    Created by:   Brian Cronin (brianc@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

function FilterServers(playNowWindow)
    local allValidServers = {}
    local backUpServers = {}

    if Client.GetNumServers() > 0 then

        local gamemode = playNowWindow.gamemode or "ns2"
        local now = os.time()

        for s = 0, Client.GetNumServers() - 1 do

            local serverEntry = BuildServerEntry(s)

            --skip servers that tagged themself as unavailable
            local skip = not serverEntry.quickPlayReady

            skip = skip or serverEntry.blocked

            --skip every server with a password
            skip = skip or serverEntry.requiresPassword

            -- skip servers that are full
            skip = skip or serverEntry.numPlayers >= (serverEntry.maxPlayers - serverEntry.numRS)

            -- skip servers that have a different gamemode
            skip = skip or serverEntry.mode ~= gamemode

            if not skip then
                -- determ if the local client is a rookie or not
                -- flag clients as vet if we haven't been able to fetch their skill tier via the hive backend
                local isVet = Client.GetSkillTier() == -1 or Client.GetSkillTier() > kRookieMaxSkillTier

                --only rookies can join rookie only servers
                local rookieOnly = isVet and serverEntry.rookieOnly

                --skip servers that the client can't play on
                skip = rookieOnly
            end

            if not skip then
                --skip servers that the client has connected to less than 10 mins ago and only use them as backup
                if serverEntry.history and now - serverEntry.lastConnect <= 600 then
                    table.insert(backUpServers, serverEntry)
                else
                    table.insert(allValidServers, serverEntry)
                end
            end

        end
    end

    if #allValidServers == 0 then
        return backUpServers
    end
    
    return allValidServers
    
end

function JoinBestServerFromList(playNowWindow, allValidServers, i)
    if #allValidServers < i then
        Client.RebuildServerList()
        return
    end

    local bestServer = allValidServers[i]
    playNowWindow.joining = bestServer.name

    --checks the server before joining it
    local function ConfirmServer(serverId)
        local entry = BuildServerEntry(serverId)

        local gamemode = playNowWindow.gamemode or "ns2"
        local players = entry.numPlayers
        local maxplayer = entry.maxPlayers - entry.numRS

        if players < maxplayer and entry.mode == gamemode then
            Client.SetAchievement("First_0_2")

            playNowWindow.gamemode = nil
            playNowWindow.joining = nil

            AddServerToHistory(entry)
            MainMenu_SBJoinServer(entry.address, nil, entry.map , true)
        else

            JoinBestServerFromList(playNowWindow, allValidServers, i+1)

        end
    end
    Client.RefreshServer(bestServer.serverId, ConfirmServer)
end

function UpdateAutoJoin(playNowWindow)

    if not Client.GetServerListRefreshed() or playNowWindow.joining then return end

    if Client.GetNumServers() > 0 then

        local allValidServers = FilterServers( playNowWindow )

        if #allValidServers > 0 then
            table.sort(allValidServers, function(a , b) return a.rating > b.rating end)

            JoinBestServerFromList(playNowWindow, allValidServers, 1)
        end

    else

        Client.RebuildServerList()

    end

end

function UpdatePlayNowWindowLogic(playNowWindow, mainMenu)

    PROFILE("GUIMainMenu:UpdatePlayNowWindowLogic")

    if playNowWindow:GetIsVisible() then
    
        playNowWindow.searchingForGameText.animateTime = playNowWindow.searchingForGameText.animateTime or Shared.GetTime()
        if Shared.GetTime() - playNowWindow.searchingForGameText.animateTime > 0.85 then
        
            playNowWindow.searchingForGameText.animateTime = Shared.GetTime()
            playNowWindow.searchingForGameText.numberOfDots = playNowWindow.searchingForGameText.numberOfDots or 3
            playNowWindow.searchingForGameText.numberOfDots = playNowWindow.searchingForGameText.numberOfDots + 1
            if playNowWindow.searchingForGameText.numberOfDots > 3 then
                playNowWindow.searchingForGameText.numberOfDots = 0
            end

            local numValidServers = #FilterServers( playNowWindow )
            local numServers = Client.GetNumServers()
            local serverFoundMessage = string.rep(".", playNowWindow.searchingForGameText.numberOfDots)

            if numServers > 0 then
                if numServers > numValidServers then
                    local _, string = pcall(string.format, Locale.ResolveString("SERVER_FOUND_SKIPPED"), numServers, numServers - numValidServers)
                    serverFoundMessage = string
                else
                    local _, string = pcall(string.format, Locale.ResolveString("SERVER_FOUND"), numServers)
                    serverFoundMessage = string
                end
            end

            if playNowWindow.joining then
                serverFoundMessage = string.format("%s %s",Locale.ResolveString("CONNECTING_TO"), playNowWindow.joining) --Todo: Localize
            else
                serverFoundMessage = string.format( "%s %s", Locale.ResolveString("SEARCHING"), serverFoundMessage)
            end

            playNowWindow.searchingForGameText:SetText(serverFoundMessage)
            
        end
        
        UpdateAutoJoin(playNowWindow)
        
    end
    
end

local function CreatePlayNowPage(self)

    self.playNowWindow = self:CreateWindow()
    self.playNowWindow:SetWindowName("PLAY NOW")
    self.playNowWindow:SetInitialVisible(false)
    self.playNowWindow:SetIsVisible(false)
    self.playNowWindow:DisableResizeTile()
    self.playNowWindow:DisableSlideBar()
    self.playNowWindow:DisableContentBox()
    self.playNowWindow:SetCSSClass("playnow_window")
    self.playNowWindow:DisableCloseButton()
    
    self.playNowWindow.UpdateLogic = UpdatePlayNowWindowLogic

    local eventCallbacks =
    {
        OnShow = function(self)

            MainMenu_OnWindowOpen()
            Client.RebuildServerList()

            local playScreen = self.scriptHandle.playScreen
            if playScreen and playScreen:GetIsVisible() then
                self.scriptHandle.playScreen:SetIsEnabled(false)
            end
        end,

        OnHide = function(self)
            Matchmaking_LeaveGlobalLobby()

            local playScreen = self.scriptHandle.playScreen
            if playScreen and playScreen:GetIsVisible() then
                self.scriptHandle.playScreen:SetIsEnabled(true)
            end
        end
    }
    self.playNowWindow:AddEventCallbacks(eventCallbacks)

    self.playNowWindow.searchingForGameText = CreateMenuElement(self.playNowWindow.titleBar, "Font", false)
    self.playNowWindow.searchingForGameText:SetCSSClass("playnow_title")
    self.playNowWindow.searchingForGameText:SetText(Locale.ResolveString("SERVERBROWSER_SEARCHING"))
    
    local cancelButton = CreateMenuElement(self.playNowWindow, "MenuButton")
    cancelButton:SetCSSClass("playnow_cancel")
    cancelButton:SetText(Locale.ResolveString("AUTOJOIN_CANCEL"))
    
    cancelButton:AddEventCallbacks({ OnClick =
    function() 
        self.playNowWindow:SetIsVisible(false)
    end })
    
end

local function CreateJoinServerPage(self)

    self:CreateServerListWindow()
    self:CreateServerDetailsWindow()
    
end

local function CreateHostGamePage(self)
    self.createGame = self:CreateWindow()

    self.createGame:SetWindowName(Locale.ResolveString("SERVERBROWSER_SERVER_DETAILS"))
    self.createGame:SetInitialVisible(false)
    self.createGame:SetIsVisible(false)
    self.createGame:DisableResizeTile()
    self.createGame:DisableContentBox()
    self.createGame:DisableSlideBar()
    self.createGame:SetCSSClass("createserver")

    self.createGame:AddEventCallbacks({
        OnBlur = function(self)
            self:SetIsVisible(false)
        end
    })
    
    self:CreateHostGameWindow()
    
end

function GUIMainMenu:ShowServerWindow()

    self.highlightServer:SetIsVisible(true)
    self.selectServer:SetIsVisible(true)
    self.serverRowNames:SetIsVisible(true)
    self.serverTabs:SetIsVisible(true)
    self.serverList:SetIsVisible(true)
    self.filterForm:SetIsVisible(true)
    self.playFooter:SetIsVisible(true)

    -- Re-enable slide bar.
    self.serverBrowserWindow:SetSlideBarVisible(true)
    self.serverBrowserWindow:ResetSlideBar()
    
end

function GUIMainMenu:HideServerWindow()

    self.highlightServer:SetIsVisible(false)
    self.selectServer:SetIsVisible(false)
    self.serverRowNames:SetIsVisible(false)
    self.serverTabs:SetIsVisible(false)
    self.serverList:SetIsVisible(false)
    self.filterForm:SetIsVisible(false)
    self.playFooter:SetIsVisible(false)

    -- Hide it, but make sure it's at the top position.
    self.serverBrowserWindow:SetSlideBarVisible(false)
    self.serverBrowserWindow:ResetSlideBar()
    
    Matchmaking_LeaveGlobalLobby()
end

function GUIMainMenu:SetPlayContentInvisible(cssClass)

    self:HideServerWindow()
    self.createGame:SetIsVisible(false)
    self.playNowWindow:SetIsVisible(false)
    
    if cssClass then
        self.serverBrowserWindow:GetContentBox():SetCSSClass(cssClass)
    end
    
end

function GUIMainMenu:CreateServerBrowserWindow()

    self.serverBrowserWindow = self:CreateWindow()
    self:SetupWindow(self.serverBrowserWindow, "SERVER BROWSER")
    self.serverBrowserWindow:AddCSSClass("play_window")
    self.serverBrowserWindow.slideBar:AddCSSClass("window_scroller_serverbrowse")
    self.serverBrowserWindow:ResetSlideBar()    -- so it doesn't show up mis-drawn
    self.serverBrowserWindow:GetContentBox():SetCSSClass("serverbrowse_content")    
    
    CreateJoinServerPage(self)
    CreatePlayNowPage(self)
    CreateHostGamePage(self)
    
    self:SetPlayContentInvisible()
    self:ShowServerWindow()
    
end
