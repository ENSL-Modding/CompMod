--=============================================================================
--
-- lua/ServerBrowser.lua
--
-- Created by Henry Kropf and Charlie Cleveland
-- Copyright 2012, Unknown Worlds Entertainment
--
--=============================================================================

Script.Load("lua/Utility.lua")
Script.Load("lua/menu/GUIMainMenu.lua")

local kFavoritesFileName = "FavoriteServers.json"
local kHistoryFileName = "HistoryServers.json"
local kRankedFileName = "RankedServers.json"
local kBlockedFileName = "BlockedServers.json"

local kFavoriteAddedSound = "sound/NS2.fev/common/checkbox_on"
Client.PrecacheLocalSound(kFavoriteAddedSound)

local kFavoriteRemovedSound = "sound/NS2.fev/common/checkbox_off"
Client.PrecacheLocalSound(kFavoriteRemovedSound)

function FormatServerName(serverName, rookieOnly)

    local maxLen = rookieOnly and 45 or 60
    if string.len(serverName) > maxLen then
        local post = string.format("... %s", rookieOnly and Locale.ResolveString("ROOKIE_ONLY") or "")
        serverName = string.sub(serverName, maxLen - 3) .. post
    end

    return serverName
    
end

function FormatGameMode(gameMode , maxPlayers)
    gameMode = gameMode:sub(0, 12)
    if gameMode == "ns2" and maxPlayers > 24 then gameMode = "ns2Large" end
    return gameMode
end

function GetNumServerReservedSlots(serverIndex)
    return Client.GetServerNumReservedSlots(serverIndex)
end

function GetServerPlayerSkill(serverIndex)
    return Client.GetServerAvgPlayerSkill(serverIndex)
end

function GetServerTickRate(serverIndex)
    return Client.GetServerTickRate(serverIndex)
end

function GetDynDNS(serverIndex)
    local dns = Client.GetServerKeyValue(serverIndex, "sv_dyndns")
    return dns ~= "" and dns
end

--use the dyndns as adrress if there is any
function GetServerAddress(serverIndex)
    local dns = GetDynDNS(serverIndex)
    local address = Client.GetServerAddress(serverIndex)
    if not dns then return address end

    local _, port = string.match(address, "(.+):(%d+)")
    return string.format("%s:%s", dns, port)
end

local function CalculateSeverRanking(serverEntry)
    
    local exp = math.exp
    local sqrt = math.sqrt
    local players = serverEntry.numPlayers
    local maxplayer = serverEntry.maxPlayers - serverEntry.numRS

    local playerskill = Client.GetSkill()
    local playerlevel = Client.GetLevel()
    local playertier = Client.GetSkillTier()

    local viability = 1/(1 + exp( -0.5 * (players - 12)))
    local dViability = (201.714 * exp(0.5 * players))/(403.429 + exp(0.5 * players))^2
    local player = 0.5 * viability + 0.5 * dViability *  math.max(0, math.min(maxplayer, 24) - players - 1)

    local ping = 1 / (1 + exp( 1/40 * (serverEntry.ping - 150)))
    local skill = (players < 2 or playerskill == -1) and 1 or exp(- 0.1 * math.abs(serverEntry.playerSkill - playerskill) * sqrt(players - 1) / 346.41) -- 346.41 ~= 100*sqrt(12)

    local perfscore = serverEntry.performanceScore * serverEntry.performanceQuality / 100
    local perf = 1/(1 + exp( - perfscore / 5 ))

    local empty = players > 0 and 1 or 0.5
    local fav = serverEntry.favorite and 2 or 1
    local blocked = serverEntry.blocked and 0.000001 or 1
    local full = players >= maxplayer and not serverEntry.favorite and 0.5 or 1
    local joinable = (not serverEntry.requiresPassword or serverEntry.favorite or serverEntry.friendsOnServer) and 1 or 0.02
    local friend = serverEntry.friendsOnServer and 1.2 or 1
    local ranked = serverEntry.mode == "ns2" and serverEntry.ranked and 1.5 or 1

    local rookieonly = joinable == 1 and 0.3 or 1
    if serverEntry.rookieOnly then
        if playerlevel == -1 or playerlevel < kRookieLevel or playertier <= kRookieMaxSkillTier then
            rookieonly = 1 + (1/exp(0.125*(playerlevel - kRookieOnlyLevel)))
        end
    else
        if playerlevel == -1 or playerlevel > kRookieOnlyLevel then
            rookieonly = 1
        end
    end

    -- rank servers the user has connected to less than 10 mins ago similair to empty ones
    local history = serverEntry.history and Shared.GetSystemTime() - serverEntry.lastConnect <= 600 and 0.5 or 1

    return player * ping * perf * skill * full * joinable * empty * fav * blocked * friend * rookieonly * ranked * history
end

local function CalculateSeverRankingForArcade(serverEntry)
    local ranking = CalculateSeverRanking(serverEntry)
    local custom = 0.6

    return custom * ranking
end


local kServerRankingFunctions =
{
	CalculateSeverRanking, -- NS2
	CalculateSeverRankingForArcade --Arcade
}

local function GetServerHasCustomNetVars(serverIndex)
    local tickrate = Client.GetServerPerformanceTickrate(serverIndex)
    local sendrate = Client.GetServerPerformanceSendrate(serverIndex)
    local moverate = Client.GetServerPerformanceMoverate(serverIndex)
    local interp = Client.GetServerPerformanceInterpMs(serverIndex)

    return tickrate ~= 30 or sendrate ~= 20 or moverate ~= 26 or interp ~= 100
end

function BuildServerEntry(serverIndex)

    -- local mods = Client.GetServerKeyValue(serverIndex, "mods")
    
    local serverEntry = { }
    serverEntry.name = Client.GetServerName(serverIndex)
    serverEntry.maxPlayers = Client.GetServerMaxPlayers(serverIndex)
    serverEntry.mode = FormatGameMode(Client.GetServerGameMode(serverIndex), serverEntry.maxPlayers)
    serverEntry.map = GetTrimmedMapName(Client.GetServerMapName(serverIndex))
    serverEntry.numPlayers = Client.GetServerNumPlayers(serverIndex)
    serverEntry.numSpectators = Client.GetServerNumSpectators(serverIndex)
    serverEntry.maxSpectators = Client.GetServerMaxSpectators(serverIndex)
    serverEntry.numRS = GetNumServerReservedSlots(serverIndex)
    serverEntry.ping = Client.GetServerPing(serverIndex)
    serverEntry.address = GetServerAddress(serverIndex)
    serverEntry.requiresPassword = Client.GetServerRequiresPassword(serverIndex)
    serverEntry.playerSkill = GetServerPlayerSkill(serverIndex)
    serverEntry.rookieOnly = Client.GetServerHasTag(serverIndex, "rookie_only")
    serverEntry.quickPlayReady = Client.GetServerIsQuickPlayReady(serverIndex)
    serverEntry.friendsOnServer = Client.GetServerContainsFriends(serverIndex)
    serverEntry.lanServer = false
    serverEntry.tickrate = GetServerTickRate(serverIndex)
    serverEntry.currentScore = Client.GetServerCurrentPerformanceScore(serverIndex)
    serverEntry.performanceScore = Client.GetServerPerformanceScore(serverIndex)
    serverEntry.performanceQuality = Client.GetServerPerformanceQuality(serverIndex)
    serverEntry.serverId = serverIndex
    serverEntry.modded = Client.GetServerIsModded(serverIndex)
    serverEntry.ranked = GetServerIsRanked(serverEntry.address)
    serverEntry.favorite = GetServerIsFavorite(serverEntry.address)
    serverEntry.blocked = GetServerIsBlocked(serverEntry.address)
    serverEntry.history, serverEntry.lastConnect = GetServerIsHistory(serverEntry.address)
    serverEntry.customNetworkSettings = GetServerHasCustomNetVars(serverIndex)
    
    serverEntry.name = FormatServerName(serverEntry.name, serverEntry.rookieOnly)

    serverEntry.rating = ( serverEntry.mode == "ns2" and kServerRankingFunctions[1] or kServerRankingFunctions[2] )(serverEntry)
    
    return serverEntry
    
end

local function SetLastServerInfo(address, password, mapname)

    Client.SetOptionString(kLastServerConnected, address)
    Client.SetOptionString(kLastServerPassword, password)
    Client.SetOptionString(kLastServerMapName, GetTrimmedMapName(mapname))
    
end

local function GetLastServerInfo()

    local address = Client.GetOptionString(kLastServerConnected, "")
    local password = Client.GetOptionString(kLastServerPassword, "")
    local mapname = Client.GetOptionString(kLastServerMapName, "")
    
    return address, password, mapname
    
end

do
    local function SkipTut()
        Shared.Message("Welcome back!")
        Client.SetAchievement("First_0_1")
    end
    Event.Hook("Console_iamsquad5", SkipTut)
end


--Join the server specified by UID and password.
--If password is empty string there is no password.
function MainMenu_SBJoinServer(address, password, mapname)

    Matchmaking_LeaveGlobalLobby()

    Client.Disconnect()
    LeaveMenu()

    if address == nil or address == "" then
    
        Shared.Message("No valid server to connect to.")
        return
        
    end
    
    if password == nil then
        password = ""
    end
    Client.Connect(address, password)
    
    SetLastServerInfo(address, password, mapname)
    
end

function OnRetryCommand()

    local address, password, mapname = GetLastServerInfo()
    
    if address == nil or address == "" then
    
        Shared.Message("No valid server to connect to.")
        return
        
    end
    
    Client.Disconnect()
    LeaveMenu()
    Shared.Message("Reconnecting to " .. address)
    MainMenu_SBJoinServer(address, password, mapname, true)
    
end
Event.Hook("Console_retry", OnRetryCommand)
Event.Hook("Console_reconnect", OnRetryCommand)

local gFavoriteServers
local gBlockedServers
local gHistoryServers
local gRankedServers

local function RemoveServerEntry(serverTable, index)
    if index > #serverTable then return end

    local address = serverTable[index].address
    serverTable._addressMap[address] = nil

    table.remove(serverTable, index)

    -- Update the indexes of the address map
    for i = index, #serverTable do
        address = serverTable[i].address
        serverTable._addressMap[address] = i
    end
end

local function GetServerEntryIndex(serverTable, address)
    return serverTable._addressMap[address]
end

local function InsertServerEntry(serverTable, serverData, index)
    if not serverData.address then return end

    if GetServerEntryIndex(serverTable, serverData.address) then return end

    if index then
        table.insert(serverTable, index, serverData)
    else
        index = #serverTable + 1
        serverTable[index] = serverData
    end

    serverTable._addressMap[serverData.address] = index

    -- Update the indexes of the address map
    for i = index + 1, #serverTable do
        local address = serverTable[i].address
        serverTable._addressMap[address] = i
    end
end

local function FixCorruptedServerTable(serverTable)
    local newServerTable = {
        _addressMap = {
            version = 1
        }
    }

    for _, v in pairs(serverTable) do
        if type(v) == "table" and v.address then
            InsertServerEntry(newServerTable, v)
        end
    end

    return newServerTable
end

local function UpdateAddressMap(serverTable)
    local addressMap = { version = 1 }
    for i = #serverTable, 1, -1 do
        local v = serverTable[i]
        local address = v.address
        if address then
            addressMap[address] = i
        else
            -- Remove any entries lacking a server address. These are bogus entries.
            table.remove(serverTable, i)
        end
    end

    serverTable._addressMap = addressMap
end

-- Move adressMap into last field of serverarray before encodig it into json to save it properly
local function SaveServerTable(fileName, serverTable)
    serverTable[#serverTable+1] = serverTable._addressMap
    serverTable._addressMap = nil

    SaveConfigFile(fileName, serverTable)

    serverTable._addressMap = serverTable[#serverTable]
    serverTable[#serverTable] = nil
end

-- Last field of json array is the address map if it has a version field
-- Otehrwise the json is still in a previous server table format and needs to be converted/fixed
local function LoadServerTable(fileName)
    local serverTable = LoadConfigFile(fileName) or {}

    if #serverTable > 0 and serverTable[#serverTable].version then
        serverTable._addressMap = serverTable[#serverTable]
        serverTable[#serverTable] = nil
    elseif #serverTable > 0 and serverTable[#serverTable].address then
        UpdateAddressMap(serverTable)
        SaveServerTable(fileName, serverTable)
    else
        serverTable = FixCorruptedServerTable(serverTable)
        SaveServerTable(fileName, serverTable)
    end

    return serverTable
end

function SetServerIsFavorite(serverData, isFavorite, muteSound)

    local foundIndex
    for f = 1, #gFavoriteServers do
    
        if gFavoriteServers[f].address == serverData.address then
        
            foundIndex = f
            break
            
        end
        
    end
    
    if isFavorite and not foundIndex then

        if GetServerIsBlocked() then
            SetServerIsBlocked(serverData, false, true)
        end
    
        local savedServerData = serverData
        InsertServerEntry(gFavoriteServers, savedServerData)
        if not muteSound then
            StartSoundEffect(kFavoriteAddedSound)
        end
        
    elseif foundIndex then

        RemoveServerEntry(gFavoriteServers, foundIndex)
        if not muteSound then
            StartSoundEffect(kFavoriteAddedSound)
        end
        
    end

    SaveServerTable(kFavoritesFileName, gFavoriteServers)
    
end

function SetServerIsBlocked(serverData, isBlocked, muteSound)

    local foundIndex
    for f = 1, #gBlockedServers do

        if gBlockedServers[f].address == serverData.address then

            foundIndex = f
            break

        end

    end

    if isBlocked and not foundIndex then

        if GetServerIsFavorite() then
            SetServerIsFavorite(serverData, false, true)
        end

        local savedServerData = serverData
        InsertServerEntry(gBlockedServers, savedServerData)
        if not muteSound then
            StartSoundEffect(kFavoriteAddedSound)
        end

    elseif foundIndex then

        RemoveServerEntry(gBlockedServers, foundIndex)
        if not muteSound then
            StartSoundEffect(kFavoriteAddedSound)
        end

    end

    SaveServerTable(kBlockedFileName, gBlockedServers)

end

local kMaxServerHistory = 10

-- first in, first out
function AddServerToHistory(serverData)

    local foundIndex
    for f = 1, #gHistoryServers do
    
        if gHistoryServers[f].address == serverData.address then
        
            foundIndex = f
            break
            
        end
        
    end

    --save timestamp of last connect for being used by quick join etc
    serverData.lastConnect = Shared.GetSystemTime()

    if not foundIndex then

        if #gHistoryServers > kMaxServerHistory then
            RemoveServerEntry(gHistoryServers, 1)
        end

        InsertServerEntry(gHistoryServers, serverData)

    else

        gHistoryServers[foundIndex] = serverData

    end

    SaveServerTable(kHistoryFileName, gHistoryServers)

end

function GetServerIsFavorite(address)
    if GetServerEntryIndex(gFavoriteServers, address) then return true end

    return false
end

function GetServerIsBlocked(address)
    if GetServerEntryIndex(gBlockedServers, address) then return true end

    return false
end

function GetServerIsHistory(address)
    local i = GetServerEntryIndex(gHistoryServers, address)
    if i then return true, gHistoryServers[i].lastConnect or 0 end

    return false
end

function UpdateRankedServers(rankedList)
    gRankedServers = rankedList

    SaveConfigFile(kRankedFileName, gRankedServers)
end

function GetServerIsRanked(address)
    return gRankedServers[address]
end

local function UpdateServerEntry(serverTable, serverData)
    local address = serverData.address
    local i = GetServerEntryIndex(serverTable, address)

    if i then
        serverTable[i] = serverData
    end
end

function UpdateFavoriteServerData(serverData)
    UpdateServerEntry(gFavoriteServers, serverData)
end

function UpdateBlockedServerData(serverData)
    UpdateServerEntry(gBlockedServers, serverData)
end

function UpdateHistoryServerData(serverData)
    UpdateServerEntry(gHistoryServers, serverData)
end

function GetFavoriteServers()
    return gFavoriteServers
end

function GetBlockedServers()
    return gBlockedServers
end

function GetHistoryServers()
    return gHistoryServers
end

function GetStoredServers()

    local servers = {
        _addressMap = {}
    }
    
    local function UpdateHistoryFlag(address, list)

        local i = GetServerEntryIndex(list, address)
        if i then
            list[i].history = true
            return true
        end

        return false
    
    end
    
    for f = 1, #gFavoriteServers do

        InsertServerEntry(servers, gFavoriteServers[f])
        servers[f].favorite = true
        servers[f].blocked = false

    end

    for f = 1, #gBlockedServers do

        InsertServerEntry(servers, gBlockedServers[f])
        servers[f].blocked = true
        servers[f].favorite = false

    end
    
    for f = 1, #gHistoryServers do
 
        if not UpdateHistoryFlag(gHistoryServers[f].address, servers) then

            InsertServerEntry(servers, gHistoryServers[f])
            servers[#servers].favorite = false
            servers[#servers].blocked = false
            servers[#servers].history = true

        end
        
    end
    
    return servers

end

do
    gFavoriteServers = LoadServerTable(kFavoritesFileName)
    gBlockedServers = LoadServerTable(kBlockedFileName)
    gHistoryServers = LoadServerTable(kHistoryFileName)
    gRankedServers = LoadConfigFile(kRankedFileName) -- just a address map without any data
end
