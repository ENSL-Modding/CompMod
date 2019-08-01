-- ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\Team.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
--                  Max McGuire (max@unknownworlds.com)
--
-- Tracks players on a team.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

class 'Team'

function Team:Initialize(teamName, teamNumber)

    self.teamName = teamName
    self.teamNumber = teamNumber
    self.playerIds = unique_set()
    self.respawnQueue = unique_set() -- doesn't maintain order!
    -- This is a special queue to place players in if the
    -- teams become unbalanced.
    self.respawnQueueTeamBalance = unique_list()
    self.kills = 0
    
end

function Team:Uninitialize()
end

function Team:OnCreate()
end

function Team:OnInitialized()
end

function Team:OnEntityKilled(targetEntity, killer, doer, point, direction)

    local killerOnTeam = HasMixin(killer, "Team") and killer:GetTeamNumber() == self.teamNumber
    if killer and targetEntity and killerOnTeam and GetAreEnemies(killer, targetEntity) and killer:isa("Player") and targetEntity:isa("Player") then
        self:AddKills(1)
    end
    
end

--
-- If a team doesn't support orders then any player changing to the team will have it's
-- orders cleared.
--
function Team:GetSupportsOrders()
    return true
end

--
-- Called only by Gamerules.
--
function Team:AddPlayer(player)

    if player and player:isa("Player") then
    
        -- Update scores when switching teams.
        player:SetRequestsScores(true)
        local id = player:GetId()
        return self.playerIds:Insert(id)
        
    else
        Print("Team:AddPlayer(): Entity must be player (was %s)", SafeClassName(player))
    end
    
    return false
    
end

function Team:UpdateRespawnQueueTeamBalance()

    -- Check if a player needs to be removed from the holding area.
    while self.respawnQueueTeamBalance:GetCount() > (self.autoTeamBalanceAmount or 0) do

        local playerId = self.respawnQueueTeamBalance:GetValueAtIndex(1)
        local spawnPlayer = Shared.GetEntity(playerId)
        self.respawnQueueTeamBalance:Remove(playerId)
        
        spawnPlayer:SetRespawnQueueEntryTime(Shared.GetTime())
        self.respawnQueue:Insert(playerId)
        
        spawnPlayer:SetWaitingForTeamBalance(false)

    end
    
end

function Team:OnEntityChange(oldId, newId)

    -- Replace any entities in the respawn queue
    if oldId then
    
        -- Keep queue entry time the same
        self.respawnQueue:ReplaceValue(oldId, newId)

        if self.respawnQueueTeamBalance:ReplaceValue(oldId, newId) and newId then
            Shared.GetEntity(newId):SetWaitingForTeamBalance(true)
        end
        
    end

    self:UpdateRespawnQueueTeamBalance()

end
--
-- Called only by Gamerules.
--
function Team:RemovePlayer(player)

    assert(player)
    
    self.playerIds:Remove(player:GetId())
    
    self:RemovePlayerFromRespawnQueue(player)
    
    player:SetTeamNumber(kTeamInvalid)
    
end

local numPlayers = 0
local numRookies = 0
local numBots = 0
local function CountPlayers( player )
    numPlayers = numPlayers + 1

    if player:GetIsRookie() then
        numRookies = numRookies + 1
    end

    if player:GetIsVirtual() then
        numBots = numBots + 1
    end
end

function Team:GetNumPlayers()

    numPlayers = 0
    numRookies = 0
    numBots = 0

    self:ForEachPlayer(CountPlayers)
    
    return numPlayers, numRookies, numBots
    
end

function Team:GetNumPlayersInQueue()
    return self.respawnQueue:GetCount()
end

local function CountDeadPlayer( player )
    if not player:GetIsAlive() then
        numPlayers = numPlayers + 1
    end
end

function Team:GetNumDeadPlayers()

    numPlayers = 0
    self:ForEachPlayer(CountDeadPlayer)
    
    return numPlayers    
end


local playerList = {}
local function CollectPlayers(player)
    table.insert(playerList, player)
end

function Team:GetPlayers()

    table.clear(playerList)
    self:ForEachPlayer(CollectPlayers)

    return playerList

end

function Team:GetTeamNumber()
    return self.teamNumber
end

-- Called on game start or end. Reset everything but teamNumber and teamName.
function Team:Reset()

    self.kills = 0
    
    self:ClearRespawnQueue()
    
    -- Clear players
    self.playerIds:Clear()
    
end

function Team:ResetPreservePlayers(techPoint)

    local playersOnTeam = {}
    table.copy(self.playerIds:GetList(), playersOnTeam)
    
    if Shared.GetCheatsEnabled() and techPoint ~= nil then
        Print("Setting team %d team location: %s", self:GetTeamNumber(), techPoint:GetLocationName())
    end
    
    if techPoint then
        self.initialTechPointId = techPoint:GetId()
    end
    
    self:Reset()
    self.playerIds:InsertAll(playersOnTeam)
end

--
-- Play sound for every player on the team.
--
function Team:PlayPrivateTeamSound(soundName, origin, commandersOnly, excludePlayer, ignoreDistance, triggeringPlayer)

    ignoreDistance = ignoreDistance or false

    -- Play alerts for commander at commander origin, so they always hear them
    local PlayPrivateSound = Closure [==[
        self soundName origin commandersOnly excludePlayer ignoreDistance triggeringPlayer
        args player
        if ( not commandersOnly or player:isa("Commander") ) and (not triggeringPlayer or not triggeringPlayer:isa("Player") or GetGamerules():GetCanPlayerHearPlayer(player, triggeringPlayer, VoiceChannel.Global)) then
            if excludePlayer ~= player then
                if not origin or (player:isa("Commander") and commandersOnly) then
                    Server.PlayPrivateSound(player, soundName, player, 1.0, Vector(0, 0, 0), ignoreDistance)
                else
                    Server.PlayPrivateSound(player, soundName, nil, 1.0, origin, ignoreDistance)
                end
            end
        end
    ]==] {soundName, origin, commandersOnly, excludePlayer, ignoreDistance, triggeringPlayer}
    
    self:ForEachPlayer(PlayPrivateSound)
    
end

function Team:TriggerEffects(eventName)

    local TriggerEffects = Closure [=[
        self eventName
        args player
        player:TriggerEffects(eventName)
    ]=]{eventName}
    self:ForEachPlayer(TriggerEffects)
end

--[[
McG: Removed as this functionality is only used when round is in CountDown state.
It is also duplicate functionality of PLayer:OnProcessMove.
function Team:SetFrozenState(state)
    local SetFrozen = Closure [=[
        self state
        args player
        player.state = state
    ]=]{state}
    self:ForEachPlayer(SetFrozen)
end
--]]

function Team:SetAutoTeamBalanceEnabled(enabled, unbalanceAmount)

    self.autoTeamBalanceEnabled = enabled
    self.autoTeamBalanceAmount = enabled and unbalanceAmount or nil

    self:UpdateRespawnQueueTeamBalance()
    
end

--
-- Queues a player to be spawned.
--
function Team:PutPlayerInRespawnQueue(player)

    assert(player)
    
    -- don't add to respawn queue during concede sequence.
    if GetConcedeSequenceActive() then
        return
    end
    
    -- Place player in a "holding area" if auto-team balance is enabled.
    if self.autoTeamBalanceEnabled then
    
        -- Place this new player into the holding area.
        self.respawnQueueTeamBalance:Insert(player:GetId())
        
        player:SetWaitingForTeamBalance(true)

        self:UpdateRespawnQueueTeamBalance()
        
    else
    
        local extraTime = 0
        if player.spawnBlockTime then
            extraTime = math.max(0, player.spawnBlockTime - Shared.GetTime())
        end
        
        if player.spawnReductionTime then
            extraTime = extraTime - player.spawnReductionTime
            player.spawnReductionTime = nil
        end
    
        player:SetRespawnQueueEntryTime(Shared.GetTime() + extraTime)
        self.respawnQueue:Insert(player:GetId())
        
        if self.OnRespawnQueueChanged then
            self:OnRespawnQueueChanged()
        end
        
    end
    
end

function Team:GetPlayerPositionInRespawnQueue(player)

    local playerId = player:GetId()
    local position = self.respawnQueue:GetValueListIndex(playerId)
    return position or -1

end

--
-- Removes the player from the team's spawn queue (if he's in it, otherwise has
-- no effect).
--
function Team:RemovePlayerFromRespawnQueue(player)

    local playerId = player:GetId()
    self.respawnQueueTeamBalance:Remove(playerId)
    self.respawnQueue:Remove(playerId)

    self:UpdateRespawnQueueTeamBalance()
    
    player:SetWaitingForTeamBalance(false)
    
end

function Team:ClearRespawnQueue()

    for p = 1, self.respawnQueueTeamBalance:GetCount() do
    
        local player = Shared.GetEntity(self.respawnQueueTeamBalance:GetValueAtIndex(p))
        player:SetWaitingForTeamBalance(false)
        
    end
    
    self.respawnQueueTeamBalance:Clear()
    self.respawnQueue:Clear()
    
end

-- Find player that's been dead and waiting the longest. Return nil if there are none.
function Team:GetOldestQueuedPlayer()

    local playerToSpawn
    local earliestTime = -1
    
    for i = 1, self.respawnQueue:GetCount() do

        local playerid = self.respawnQueue:GetValueAtIndex(i)
        local player = Shared.GetEntity(playerid)
        
        if player and player.GetRespawnQueueEntryTime then
        
            local currentPlayerTime = player:GetRespawnQueueEntryTime()
            
            if currentPlayerTime and (earliestTime == -1 or currentPlayerTime < earliestTime) then
            
                playerToSpawn = player
                earliestTime = currentPlayerTime
                
            end
            
        end
        
    end
    
    if playerToSpawn and ( not playerToSpawn.spawnBlockTime or playerToSpawn.spawnBlockTime <= Shared.GetTime() ) then    
        return playerToSpawn
    end
    
end

local function SortByEntryTime(player1, player2)

    local time1 = player1.GetRespawnQueueEntryTime and player1:GetRespawnQueueEntryTime() or 0
    local time2 = player2.GetRespawnQueueEntryTime and player2:GetRespawnQueueEntryTime() or 0

    return time1 < time2

end

function Team:GetSortedRespawnQueue()

    local sortedQueue = {}
    
    for i = 1, self.respawnQueue:GetCount() do

        local player = Shared.GetEntity(self.respawnQueue:GetValueAtIndex(i))
        if player then
            table.insert(sortedQueue, player)
        end
    
    end
    
    table.sort(sortedQueue, SortByEntryTime)
    
    return sortedQueue

end

function Team:GetKills()
    return self.kills
end

function Team:AddKills(num)
    self.kills = self.kills + num
end

-- Structure was created. May or may not be built or active.
function Team:StructureCreated(entity)
end

-- Entity that supports the tech tree was just added (it's built/active).
function Team:TechAdded(entity) 
end

-- Entity that supports the tech tree was just removed (no longer built/active).
function Team:TechRemoved(entity)    
end

function Team:GetIsPlayerOnTeam(player)
    return player:GetTeamNumber() == self:GetTeamNumber()
end

-- For every player on team, call functor(player)
function Team:ForEachPlayer(functor)
    local playerIds = self.playerIds:GetList()

    for i = #playerIds, 1, -1 do
        local playerId = playerIds[i]
        local player = Shared.GetEntity(playerId)
        if player and player:isa("Player") and player:GetClient() then
            if functor(player, self.teamNumber) == false then
                break
            end
        else
            self.playerIds:Remove(playerId)
        end
        
    end
    
end

function Team:SendCommand(command)

    local function PlayerSendCommand(player)
        Server.SendCommand(player, command)
    end
    self:ForEachPlayer(PlayerSendCommand)
    
end

local hasActivePlayers = false
local function HasActivePlayers(player)
    if player:GetIsAlive() then
        hasActivePlayers = true
        return false
    end
end
function Team:GetHasActivePlayers()
    hasActivePlayers = false

    self:ForEachPlayer(HasActivePlayers)
    return hasActivePlayers

end

function Team:GetHasAbilityToRespawn()
    return true
end

function Team:Update(timePassed)
end

function Team:GetNumCommandStructures()

    local commandStructures = GetEntitiesForTeam("CommandStructure", self:GetTeamNumber())
    return #commandStructures
    
end

function Team:GetNumAliveCommandStructures()

    local commandStructures = GetEntitiesForTeam("CommandStructure", self:GetTeamNumber())
    
    local numAlive = 0
    for c = 1, #commandStructures do
        numAlive = commandStructures[c]:GetIsAlive() and (numAlive + 1) or numAlive
    end
    return numAlive
    
end

function Team:GetHasTeamLost()
    return false    
end

function Team:RespawnPlayer(player, origin, angles)

    assert(self:GetIsPlayerOnTeam(player), "Player isn't on team!")
    
    if origin == nil or angles == nil then
    
        -- Randomly choose unobstructed spawn points to respawn the player
        local spawnPoint
        local spawnPoints = Server.readyRoomSpawnList
        local numSpawnPoints = table.icount(spawnPoints)
        
        if numSpawnPoints > 0 then
        
            local spawnPoint = GetRandomClearSpawnPoint(player, spawnPoints)
            if spawnPoint ~= nil then
            
                origin = spawnPoint:GetOrigin()
                angles = spawnPoint:GetAngles()
                
            end
            
        end
        
    end
    
    -- Move origin up and drop it to floor to prevent stuck issues with floating errors or slightly misplaced spawns
    if origin then
    
        SpawnPlayerAtPoint(player, origin, angles)
        
        player:ClearEffects()
        
        return true
        
    else
        DebugPrint("Team:RespawnPlayer(player, %s, %s) - Must specify origin.", ToString(origin), ToString(angles))
    end
    
    return false
    
end

function Team:BroadcastMessage(message)

    local SendMessage = Closure [=[
        self message
        args player
        Server.Broadcast(player, message)
    ]=]{message}
    self:ForEachPlayer(SendMessage)
    
end

function Team:GetSpectatorMapName()
    return Spectator.kMapName
end