-- ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\menu\ServerList.lua
--
--    Created by:   Andreas Urwalek (andi@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/menu/MenuElement.lua")
Script.Load("lua/menu/ServerEntry.lua")
Script.Load("lua/Globals.lua")

local kDefaultWidth = 350
local kDefaultColumnHeight = 64
local kDefaultBackgroundColor = Color(0.5, 0.5, 0.5, 0.4)

kFilterMaxPing = 600
kFilterMinPing = 100

class 'ServerList' (MenuElement)

local gLastSortType = 0
local gSortReversed = false

function UpdateSortOrder(sortType)

    if gLastSortType == sortType then
        gSortReversed = not gSortReversed
    else
        gSortReversed = false
    end
    
    gLastSortType = sortType
    
end

function SortByPerformance(a, b)
    local perf1 = tonumber(a.performanceScore) * tonumber(a.performanceQuality) / 100
    local perf2 = tonumber(b.performanceScore) * tonumber(b.performanceQuality) / 100
    
    if not gSortReversed then
        return perf1 > perf2
    else
        return perf1 < perf2
    end
    
end

function SortByPing(a, b)

    if not gSortReversed then
        return tonumber(a.ping) < tonumber(b.ping)
    else
        return tonumber(a.ping) > tonumber(b.ping)
    end
    
end

function SortByPlayers(a, b)

    local aNumPlayers = tonumber(a.numPlayers)
    local bNumPlayers = tonumber(b.numPlayers)

    if not gSortReversed then
        return aNumPlayers > bNumPlayers
    else
        return aNumPlayers < bNumPlayers
    end
    
end

function SortBySpectators(a, b)

    local aNumSpectators = tonumber(a.numSpectators)
    local bNumSpectators = tonumber(b.numSpectators)

    if not gSortReversed then
        return aNumSpectators > bNumSpectators
    else
        return aNumSpectators < bNumSpectators
    end
    
end

function SortByPrivate(a, b)

    local aValue = a.requiresPassword and 1 or 0
    local bValue = b.requiresPassword and 1 or 0
    
    if not gSortReversed then
        return aValue > bValue
    else
        return aValue < bValue
    end
    
end

function SortByPlayerSkill(a, b)

    local aValue = a.playerSkill
    local bValue =  b.playerSkill
    
    if not gSortReversed then
        return aValue < bValue
    else
        return aValue > bValue
    end
    
end

function SortByFavorite(a, b)

    local aValue = a.favorite and 1 or 0
    local bValue = b.favorite and 1 or 0
    
    if not gSortReversed then
        return aValue == bValue and SortByPlayers(a, b) or aValue > bValue
    else
        return aValue == bValue and SortByPlayers(a, b) or aValue < bValue
    end
    
end

function SortByBlocked(a, b)

    local aValue = a.blocked and 1 or 0
    local bValue = b.blocked and 1 or 0

    if not gSortReversed then
        return aValue == bValue and SortByPlayers(a, b) or aValue > bValue
    else
        return aValue == bValue and SortByPlayers(a, b) or aValue < bValue
    end

end

function SortByMap(a, b)

    if not gSortReversed then
        return a.map:upper() > b.map:upper()
    else
        return a.map:upper() < b.map:upper()
    end
    
end

function SortByName(a, b)

    if not gSortReversed then
        return a.name:upper() > b.name:upper()
    else
        return a.name:upper() < b.name:upper()
    end
    
end

function SortByMode(a, b)

    if not gSortReversed then
        return a.mode:upper() > b.mode:upper()
    else
        return a.mode:upper() < b.mode:upper()
    end
    
end

function SortByRating(a, b)
    local aValue = a.rating or 0
    local bValue = b.rating or 0

    if not gSortReversed then
        return aValue > bValue
    else
        return aValue < bValue
    end
end

kFilterFromCustom = {
    NS2 = true,
    ["?"] = true
}

-- An empty mode string matches every mode. Otherwise, match the mode string of the entry to the passed in mode.
function FilterServerMode(mode)
    return function(entry) return
        string.len(mode) == 0 or
        mode == "all" and entry.mode ~= "?" or
        mode == "custom" and not kFilterFromCustom[string.upper(entry.mode)] or
        string.upper(entry.mode) == string.upper(mode)
    end
end
function FilterServerName(name)
    return function(entry) return string.find(string.UTF8Upper(entry.name), string.UTF8Upper(name), nil, true) ~= nil end
end

function FilterMapName(map)
    return function(entry) return string.find(string.UTF8Upper(entry.map), string.UTF8Upper(map), nil, true) ~= nil end
end

function FilterSearchServer(input)
    input = string.UTF8Upper(input)
    return function(entry) return string.find(string.UTF8Upper(entry.name), input, nil, true) ~= nil or
            string.find(string.UTF8Upper(entry.map), input, nil, true) ~= nil end
end

function FilterMinScore(minScore)
    return function(entry) return entry.performanceScore >= minScore end
end

function FilterMaxPing(maxping)

    -- Don't limit ping.
    if maxping >= kFilterMaxPing then
        return function(entry)
            return true
        end
    else
        maxping = math.max(maxping, kFilterMinPing)

        return function(entry)
            return entry.ping <= maxping
        end
    end
    
end

function FilterPlayerSkill(maxskill)

    return function(entry)
    
        if maxskill == kMaxPlayerSkill then
            return true
        else
            return entry.playerSkill <= maxskill
        end
        
    end
    
end

function FilterEmpty(active)
    return function(entry) return not active or entry.numPlayers ~= 0 end
end

function FilterFull(active)
    return function(entry) return not active or entry.numPlayers < (entry.maxPlayers - entry.numRS) end
end
function FilterModded(active)
    return function(entry) return not active or entry.modded == false end
end

function FilterFavoriteOnly(active)
    return function(entry) return not active or entry.favorite == true end
end

function FilterBlockedOnly(active)
    return function(entry) return not active or entry.blocked == true end
end

function FilterFriendsOnly(active)
    return function(entry) return not active or entry.friendsOnServer == true end
end

function FilterHistoryOnly(active)
    return function(entry) return not active or entry.history == true end
end

function FilterPassworded(active)
    return function(entry) return active or entry.requiresPassword == false end
end

function FilterRookieOnly(active)
    return function(entry) return active or not entry.rookieOnly end
end

function FilterRookie(active)
    return function(entry) return not active or entry.rookieFriendly == false end
end

function FilterRankedOnly(active)
    return function(entry) return not active or entry.ranked end
end

local function CheckShowTableEntry(self, entry)

    for _, filterFunc in ipairs(self.filter) do

        if not filterFunc(entry) then
            return false
        end
        
    end
    
    return true
    
end

local function GetBoundaries(self)

    local minY = -self:GetParent():GetContentPosition().y
    local maxY = minY + self:GetParent().contentStencil:GetSize().y
    
    return minY, maxY
    
end

-- Called after the table has changed (style or data).
local function RenderServerList(self)

    PROFILE("ServerList:RenderServerList")

    local renderPosition = 0
    
    local serverListWidth = self:GetWidth()
    local serverListSize = #self.serverEntries
    local numServers = #self.tableData
    local lastSelectedServerId = MainMenu_GetSelectedServer()
    self.scriptHandle:ResetServerSelection()
    
    -- Add, remove entries, but reuse as many GUIItems as possible.
    if serverListSize < numServers then
    
        for i = 1, numServers - serverListSize do
        
            local entry = CreateMenuElement(self, 'ServerEntry', false)
            entry:SetParentList(self)
            entry:SetWidth(serverListWidth)
            
            table.insert(self.serverEntries, entry)
            
            
        end
        
    elseif serverListSize > numServers then
    
        for i = 1, serverListSize - numServers do
        
            self.serverEntries[#self.serverEntries]:Uninitialize()
            table.remove(self.serverEntries, #self.serverEntries)
            
        end
        
    end
    
    local minY, maxY = GetBoundaries(self)
    self.gameTypes = {}
    
    for i = 1, #self.tableData do
    
        local serverEntry = self.serverEntries[i]
        
        if CheckShowTableEntry(self, self.tableData[i]) then

            serverEntry:SetBackgroundPosition(Vector(0, renderPosition * kServerEntryHeight, 0))
            serverEntry:SetServerData(self.tableData[i], self.tableData[i].serverId)
            
            if self.tableData[i].serverId == lastSelectedServerId then
                SelectServerEntry(serverEntry)
            end
                     
            renderPosition = renderPosition + 1
            serverEntry:SetIsFiltered(false)
            
        else
            serverEntry:SetIsFiltered(true)
        end
        
        serverEntry:UpdateVisibility(minY, maxY, renderPosition * kServerEntryHeight)
        
        local gameType = self.tableData[i].mode
        local rating = self.tableData[i].numPlayers
        
        if gameType then
        
            if not self.gameTypes[gameType] then
                self.gameTypes[gameType] = rating
            else
                self.gameTypes[gameType] = self.gameTypes[gameType] + rating
            end  

        end        
        
    end
    
    self:SetHeight(renderPosition * kServerEntryHeight)

    self.visibleEntries = renderPosition
end

function ServerList:Initialize()

    self:DisableBorders()
    
    MenuElement.Initialize(self)
    
    self:SetWidth(kDefaultWidth)
    self:SetBackgroundColor(kNoColor)
    
    self.tableData = { }
    self.serverEntries = { }
    self.filter = { }
    self.gameTypes = { }
    
    -- Default sorting is set in GUIMainMenu.
    self.comparator = nil

    self.lastSort = 0
    
end

function ServerList:Uninitialize()

    MenuElement.Uninitialize(self)
    
    self.tableData = { }
    self.serverEntries = { }

end

function ServerList:GetGameTypes()
    return self.gameTypes
end

function ServerList:GetTagName()
    return "serverlist"
end

function ServerList:SetEntryCallbacks(callbacks)
    self.entryCallbacks = callbacks
end

function ServerList:SetComparator(comparator, rankUpdate, sortType)

    self.comparator = comparator
    self.rankUpdate = rankUpdate

    if sortType then
        UpdateSortOrder(sortType)
        Client.SetOptionInteger("currentServerBrowerComparator", sortType)
    end

    self:Sort(false)
    
end

function ServerList:OnParentSlide()

    local minY, maxY = GetBoundaries(self)
    
    for _, entry in ipairs(self.serverEntries) do        
        entry:UpdateVisibility(minY, maxY)    
    end

end


function ServerList:Sort(noRender)

    if self.comparator then
        table.sort(self.tableData, self.comparator)
    end

    if not gSortReversed then
        for rank, entry in ipairs(self.tableData) do
            entry.rank = rank
        end

        if not self.rankUpdate then
            --sort after rating then restore the comparator based sorting and save rating rank
            table.sort(self.tableData, SortByRating)
            local newtableData = {}

            for rank, entry in ipairs(self.tableData) do
                newtableData[entry.rank] = entry
                newtableData[entry.rank].rank = rank
            end

            self.tableData = newtableData
        end
    end

    if not noRender then
        RenderServerList(self)
    end
    
end

function ServerList:SetTableData(tableData)

    if tableData then
    
        self.tableData = tableData
        self:Sort()
        
    end
    
end

function ServerList:ClearChildren()

    MenuElement.ClearChildren(self)
    
    self.tableData = { }
    self.serverEntries = { }
    
end

function ServerList:AddEntry(serverEntry, noRender)

    table.insert(self.tableData, serverEntry)

    self:Sort(true)

end

function ServerList:UpdateEntry(serverEntry, noRender)

    for s = 1, #self.tableData do
    
        if self.tableData[s].address == serverEntry.address then

            --Avoid remapping servers we already have a valid id for
            if self.tableData[s].serverId >= 0 then
                serverEntry.serverId = self.tableData[s].serverId
            end

            --Copy over the server's rank
            serverEntry.rank = self.tableData[s].rank or 0

            --Copy over the friend state
            serverEntry.friendsOnServer = self.tableData[s].friendsOnServer or serverEntry.friendsOnServer

            self.tableData[s] = serverEntry

            break
            
        end
        
    end
    
    if not noRender then
        RenderServerList(self)
    end
    
end

function ServerList:RenderNow()
    return RenderServerList(self)
end

function ServerList:GetNumVisibleEntries()
    return self.visibleEntries or 0
end

function ServerList:GetNumEntries()
    return self.tableData and #self.tableData or 0
end

function ServerList:GetEntryExists(serverEntry)

    for s = 1, #self.tableData do
    
        if self.tableData[s].address == serverEntry.address then
            return true
        end
        
    end
    
    return false
    
end

function ServerList:SetFilter(index, func)

    for i = 1, index - 1 do
        if self.filter[i] == nil then
            self.filter[i] = function() return true end
        end
    end

    self.filter[index] = func
    RenderServerList(self)
    
end