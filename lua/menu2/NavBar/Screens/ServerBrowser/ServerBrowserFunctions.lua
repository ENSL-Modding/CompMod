-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/menu2/ServerBrowser/ServerBrowserFunctions.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Non-GUI related functionality of the server browser.
--    
--    Also storing the filter/sorting functions for the server browser in here, to prevent the gui
--    class from getting too cluttered.
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/menu2/popup/GUIMenuPopupDialog.lua")
Script.Load("lua/menu2/MenuData.lua")
Script.Load("lua/menu2/popup/GUIMenuPopupSimpleMessage.lua")

local function GetMapNameForAddress(address)
    
    local serverBrowser = GetServerBrowser()
    if not serverBrowser then
        return ""
    end
    
    local serverEntry = serverBrowser:GetServerSet()[address]
    if not serverEntry then
        return ""
    end
    
    local result = serverEntry:GetMapName()
    return result
    
end

local function SetLastServerMapNameFromAddress(address)
    
    local mapName = GetMapNameForAddress(address)
    Client.SetOptionString(kLastServerMapName, mapName)
    
end

local function SetLastServerMapName(mapName)
    Client.SetOptionString(kLastServerMapName, mapName)
end

-- Immediately attempt to join server -- no password prompts, full warnings, or anything.  For these
-- extra checks, use TryToJoinServer(address, password) instead.
function JoinServer(address, password)
    
    if address == nil or address == "" then
        HPrint("Invalid server address!  Got '%s'", ToString(address))
        error()
        return
    end
    
    Matchmaking_LeaveGlobalLobby()
    
    Client.Disconnect()
    
    GetServerBrowser():NotifyJoiningServer(address)
    
    password = password or ""
    SetLastServerMapNameFromAddress(address)
    
    Client.Connect(address, password)
    
end

-- Legacy
function MainMenu_SBJoinServer(address, password, mapname)
    JoinServer(address, password)
end

function HostGame(mapName, hidden, serverName, password, maxPlayers, port, disableMods)
    
    -- Tell the loading screen which map we're loading.
    SetLastServerMapName(mapName)
    
    port = port or Client.GetOptionInteger(kStartServer_PortKey, kStartServer_DefaultPort)
    maxPlayers = maxPlayers or Client.GetOptionInteger(kStartServer_PlayerLimitKey, kStartServer_DefaultPlayerLimit)
    password = password or Client.GetOptionString(kStartServer_PasswordKey, kStartServer_DefaultPassword)
    serverName = servername or Client.GetOptionString(kStartServer_ServerNameKey, kStartServer_DefaultServerName)
    
    Client.StartServer(mapName, serverName, password, port, maxPlayers, disableMods == true, hidden == true)
    
end

local function DefaultPostRefreshUpdate(popup)
    
    local address = popup.addressToConnectTo
    popup:Close()
    
    if address then
    
        local serverBrowser = GetServerBrowser()
        local serverEntry
        if serverBrowser then
            serverEntry = serverBrowser:GetServerEntryFromAddress(address)
        end
    
        if serverEntry then
            TryToJoinServer(address, nil)
        else
            -- Server entry for address wasn't found, even after refresh... just try to join.
            JoinServer(address, nil)
        end
    end

end

-- 1 level of abstraction above JoinServer().  This function attempts to find the server in the
-- server browser to display warnings, password prompts, full server, etc., potentially saving the
-- user some time (eg not attempting to connect to a full server).
-- postRefreshUpdate is an optional parameter that will be called when the server browser is done
-- refreshing, just in case the address needs to be changed (eg to follow a friend to another
-- server).
function TryToJoinServer(address, password, postRefreshUpdate)
    
    RequireType("string", address, "address", 2)
    RequireType({"string", "nil"}, password, "password", 2)
    RequireType({"function", "nil"}, postRefreshUpdate, "postRefreshUpdate", 2)
    
    -- If possible, join this server via the server browser.  This will provide the extra facilities
    -- like prompting for a password, or giving warnings about performance.
    local serverBrowser = GetServerBrowser()
    if serverBrowser then
    
        local serverEntry = serverBrowser:GetServerEntryFromAddress(address)
        if serverEntry and serverEntry:GetExists() then
            
            serverBrowser:_AttemptToJoinServer({address = address, password = password})
            return
            
        else
            
            local popup = CreateGUIObject("popup", GUIMenuPopupSimpleMessage, nil,
            {
                title = Locale.ResolveString("FRIEND_JOINING_TITLE"),
                message = Locale.ResolveString("FRIEND_JOINING_DESC"),
                buttonConfig = { GUIPopupDialog.CancelButton, },
            })
            popup.addressToConnectTo = address
    
            if not postRefreshUpdate then
                postRefreshUpdate = DefaultPostRefreshUpdate
            end
    
            popup:HookEvent(serverBrowser, "OnRefreshFinished", postRefreshUpdate)
            serverBrowser:RefreshServerList()
            
            return
            
        end
        
    end
    
    -- Server browser wasn't loaded, or the procedure to join via the server browser failed for some
    -- reason (eg no server entry found for the given address).  Just try to connect anyways.
    JoinServer(address, password)
    
end

-- User is trying to join a server through the Steam UI.
Event.Hook("ConnectRequested",
function(address, password)
    TryToJoinServer(address, password)
end)

-- User is trying to connect to a server through the console.
Event.Hook("Console_connect",
function(address, password)
    JoinServer(address, password)
end)

-- User is starting a listen server on the given map.
Event.Hook("Console_map",
function(mapName, hidden)
    if type(mapName) ~= "string" then
        HPrint("'map' usage: map mapName [\"hidden\"]")
        HPrint("    mapName: name of the map relative to the \"maps\" directory, without the extension, eg. \"ns2_tram\".")
        HPrint("    hidden: optional.  Specify 'hidden' if the server should not be visible to others via steam browser.")
        return
    end
    
    HostGame(mapName, hidden)
    
end)

local function OnRetryCommand()
    
    local address = Client.GetOptionString(kLastServerConnected, "")
    local password = Client.GetOptionString(kLastServerPassword, "")
    
    if address == nil or address == "" then
        HPrint("No previous server address recorded.  Unable to reconnect.")
        return
    end
    
    HPrint("Reconnecting to '%s'", ToString(address))
    Client.Disconnect()
    JoinServer(address, password)
    
end

Event.Hook("Console_retry", OnRetryCommand)
Event.Hook("Console_reconnect", OnRetryCommand)

Event.Hook("GameInviteAccepted", function(connectString, friendSteamId64)
    
    -- Figure out the server address (actually server address:port for server browser...)
    if string.sub(connectString, 1, 9) ~= "+connect " then
        Log("Invalid connect string \"%s\" received.", connectString)
        return -- invalid connect string... WE didn't send that!
    end
    
    local serverAddress = string.sub(connectString, 10, #connectString)
    if serverAddress == "" then
        Log("Invalid connect string \"%s\" received.", connectString)
        return -- invalid connect string... WE didn't send that!
    end
    
    TryToJoinServer(serverAddress)
    
end)

-- Legacy Functions
-- Backwards compatibility

function GetServerIsFavorite(address)
    local serverBrowser = GetServerBrowser()
    if not serverBrowser then
        return false -- server browser not yet loaded.
    end
    
    local serverEntry = serverBrowser:GetServerEntryFromAddress(address)
    if not serverEntry then
        return false -- server entry with that address not found (must be still loading).
    end
    
    local result = serverEntry:GetFavorited()
    return result
end

function GetServerIsBlocked(address)
    
    local serverBrowser = GetServerBrowser()
    if not serverBrowser then
        return false -- server browser not yet loaded.
    end
    
    local serverEntry = serverBrowser:GetServerEntryFromAddress(address)
    if not serverEntry then
        return false -- server entry with that address not found (must be still loading).
    end
    
    local result = serverEntry:GetBlocked()
    return result
    
end

function GetServerIsHistory(address)
    
    local serverBrowser = GetServerBrowser()
    if not serverBrowser then
        return false -- server browser not yet loaded.
    end
    
    local serverEntry = serverBrowser:GetServerEntryFromAddress(address)
    if not serverEntry then
        return false -- server entry with that address not found (must be still loading).
    end

    if serverEntry:GetHistorical() then
        local lastConnect = serverEntry:GetLastConnect()
        return true, lastConnect
    end

    return false
    
end

function GetServerIsRanked(address)
    
    local serverBrowser = GetServerBrowser()
    if not serverBrowser then
        return false -- server browser not yet loaded.
    end
    
    local serverEntry = serverBrowser:GetServerEntryFromAddress(address)
    if not serverEntry then
        return false -- server entry with that address not found (must be still loading).
    end
    
    local result = serverEntry:GetRanked()
    return result
    
end

function SetServerIsBlocked(serverDataTable, state, dontDoSound)
    
    local address = serverDataTable.address
    if not address then
        return
    end
    
    local serverBrowser = GetServerBrowser()
    if not serverBrowser then
        return
    end
    
    local serverEntry = serverBrowser:GetServerEntryFromAddress(address)
    if not serverEntry then
        return
    end
    
    if not serverEntry:SetBlocked(state) then
        return -- the state didn't change because it was already in this state.
    end
    
    if not dontDoSound then
        PlayMenuSound("AcceptChoice")
    end
    
end

function SetServerIsFavorite(serverDataTable, state, dontDoSound)
    
    local address = serverDataTable.address
    if not address then
        return
    end
    
    local serverBrowser = GetServerBrowser()
    if not serverBrowser then
        return
    end
    
    local serverEntry = serverBrowser:GetServerEntryFromAddress(address)
    if not serverEntry then
        return
    end
    
    if not serverEntry:SetFavorited(state) then
        return -- the state didn't change because it was already in this state.
    end
    
    if not dontDoSound then
        PlayMenuSound("AcceptChoice")
    end
    
end

function DoQuickJoin()
    CreateGUIObject("quickPlayPopup", GUIMenuQuickPlayPopup, nil)
end

-- SORT FUNCTIONS --
-- Tables:
-- {
--      func             -- the comparator function used.
--      defaultReverse   -- boolean.  If true, the default sorting order is descending instead of
--                          ascending.
-- }
--
-- Functions should take two parameters: a and b, and return -1, 0, or 1.
--     -1 - entryA should come before entryB
--      0 - entryA and entryB are tied for the same position
--      1 - entryA should come after entryB

ServerBrowserSortFunctions = {}

local playerCountSort = function(a, b)
    local result = SB_CompareValues(math.max(0, b:GetPlayerCount()), math.max(0, a:GetPlayerCount())) -- Swapped so that default is descending.
    return result
end

local serverNameSort = function(a, b)
    local result = SB_CompareStrings(a:GetServerNameNoBS(), b:GetServerNameNoBS())
    return result
end

local gameModeSort = function(a, b)
    local result = SB_CompareStrings(a:GetGameMode(), b:GetGameMode())
    return result
end

local pingSort = function(a, b)
    local result = SB_CompareValues(a:GetPing(), b:GetPing())
    return result
end

local skillSort = function(a, b)
    
    -- Empty servers are considered to have undefined skill.  They always sort after servers with
    -- players playing on them.
    local aPlayerCount = a:GetPlayerCount()
    local bPlayerCount = b:GetPlayerCount()
    
    if aPlayerCount <= 0 then
        if bPlayerCount <= 0 then
            return 0
        else
            return 1
        end
    elseif bPlayerCount <= 0 then
        return -1
    end
    
    local aSkill = math.max(a:GetSkill(), 0)
    local bSkill = math.max(b:GetSkill(), 0)
    
    local result = SB_CompareValues(aSkill, bSkill)
    return result
end

local skillReverseSort = function(a, b)
    
    -- Empty servers are considered to have undefined skill.  They always sort after servers with
    -- players playing on them.
    local aPlayerCount = a:GetPlayerCount()
    local bPlayerCount = b:GetPlayerCount()
    
    if aPlayerCount <= 0 then
        if bPlayerCount <= 0 then
            return 0
        else
            return 1
        end
    elseif bPlayerCount <= 0 then
        return -1
    end
    
    local aSkill = math.max(a:GetSkill(), 0)
    local bSkill = math.max(b:GetSkill(), 0)
    
    local result = SB_CompareValues(bSkill, aSkill)
    return result
    
end

local quickPlayRankSort = function(a, b)
    local result = SB_CompareValues(a:GetQuickPlayRankIndex(), b:GetQuickPlayRankIndex())
    return result
end

local favoritesSort = function(a, b)
    local result = SB_CompareBooleans(a:GetFavorited(), b:GetFavorited())
    return result
end

local blockedSort = function(a, b)
    local result = SB_CompareBooleans(a:GetBlocked(), b:GetBlocked())
    return result
end

local rankedSort = function(a, b)
    local result = SB_CompareBooleans(a:GetRanked(), b:GetRanked())
    return result
end

local passwordedSort = function(a, b)
    local result = SB_CompareBooleans(a:GetPassworded(), b:GetPassworded())
    return result
end

-- Combines multiple sorting functions into one.  The first sort function is the primary, with the
-- second one being the tiebreaker of the first one.  The third one is the tiebreaker of the second
-- one, and so on...
function CombineSorts(...)
    
    local sorts = {...}
    
    if #sorts == 0 then
        error(string.format("Expected a list of sorting functions, got an empty list."), 2)
    end
    
    for i=1, #sorts do
        RequireType("function", sorts[i], string.format("parameter %d", i), 2)
    end
    
    return
        function(a, b)
            for i=1, #sorts do
                local result = sorts[i](a, b)
                if result ~= 0 then
                    return result == -1
                end
            end
            return false
        end
    
end

function CreateReversedSort(sortFunc)
    return
        function(a, b)
            local result = sortFunc(b, a)
            return result
        end
end

ServerBrowserSortFunctions.QuickPlayRank = CombineSorts(quickPlayRankSort)
ServerBrowserSortFunctions.QuickPlayRankReversed = CombineSorts(CreateReversedSort(quickPlayRankSort))

ServerBrowserSortFunctions.Favorites = CombineSorts(favoritesSort, quickPlayRankSort)
ServerBrowserSortFunctions.FavoritesReversed = CombineSorts(CreateReversedSort(favoritesSort), quickPlayRankSort)

ServerBrowserSortFunctions.Blocked = CombineSorts(blockedSort, quickPlayRankSort)
ServerBrowserSortFunctions.BlockedReversed = CombineSorts(CreateReversedSort(blockedSort), quickPlayRankSort)

ServerBrowserSortFunctions.Ranked = CombineSorts(rankedSort, quickPlayRankSort)
ServerBrowserSortFunctions.RankedReversed = CombineSorts(CreateReversedSort(rankedSort), quickPlayRankSort)

ServerBrowserSortFunctions.Passworded = CombineSorts(passwordedSort, quickPlayRankSort)
ServerBrowserSortFunctions.PasswordedReversed = CombineSorts(CreateReversedSort(passwordedSort), quickPlayRankSort)

ServerBrowserSortFunctions.Skill = CombineSorts(skillSort, quickPlayRankSort)
ServerBrowserSortFunctions.SkillReversed = CombineSorts(skillReverseSort, quickPlayRankSort)

ServerBrowserSortFunctions.ServerName = CombineSorts(serverNameSort, quickPlayRankSort)
ServerBrowserSortFunctions.ServerNameReversed = CombineSorts(CreateReversedSort(serverNameSort), quickPlayRankSort)

ServerBrowserSortFunctions.GameMode = CombineSorts(gameModeSort, quickPlayRankSort)
ServerBrowserSortFunctions.GameModeReversed = CombineSorts(CreateReversedSort(gameModeSort), quickPlayRankSort)

ServerBrowserSortFunctions.PlayerCount = CombineSorts(playerCountSort, quickPlayRankSort)
ServerBrowserSortFunctions.PlayerCountReversed = CombineSorts(CreateReversedSort(playerCountSort), quickPlayRankSort)

ServerBrowserSortFunctions.Ping = CombineSorts(pingSort, quickPlayRankSort)
ServerBrowserSortFunctions.PingReversed = CombineSorts(CreateReversedSort(pingSort), quickPlayRankSort)
