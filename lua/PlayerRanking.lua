--[[
======= Copyright (c) 2003-2016, Unknown Worlds Entertainment, Inc. All rights reserved. =====

    lua\PlayerRanking.lua
    
    Created by:   Andreas Urwalek (andi@unknownworlds.com)
    Modified by:  Brock Gillespie (brock@naturalselection2.com)

========= For more information, visit us at http://www.unknownworlds.com =====================
--]]

local kRoundRankingUrl = "http://hive2.ns2cdt.com/api/post/matchEnd"
local kPlayerRankingRequestUrl = "http://hive2.ns2cdt.com/api/get/playerData/"

--don't track games which are shorter than a minute
local kMinMatchTime = 60    --TODO Move to global (or Engine def)

gRankingDisabled = false

--TODO Move into PlayerRanking class
local avgNumPlayersSum = 0
local numPlayerCountSamples = 0

kXPBonusPerWin = 250;
kXPBonusPerGame = 500;
kXPGainPerSecond = 2000 / ( 14 * 60 );
kMaxLevel = 100;
kMaxPrestige = 5;


--client side utility functions
function PlayerRanking_GetXPNeededForLevel( level )
    local base = ( (level - 1 ) % kMaxLevel ) + 1
    local prestige = math.max( 0, math.floor(( level - 1 ) / kMaxLevel ) )

    if base == 1 and 0 < prestige then
        return 16500 -- Wrapping from 100 to 1 should be harder than 0 to 1
    end

    return math.min( 16500,                    -- Maximum 16500 between levels
            math.min( base, 7 ) * 1250             -- 1250 extra per level up to level 8
                    + Clamp( base - 7, 0, 14 - 7 ) * 750   -- 750 extra per level up to level 15
                    + math.max( 0, base - 14 ) * 500       -- 500 extra per level after
    )
end

function PlayerRanking_GetTotalXpNeededForLevel( level )

    local s1 = Clamp( level, 0, 7 )
    local s2 = Clamp( level - 7, 0, 14 - 7 )
    local s3 = Clamp( level - 14, 0, 19 - 14 )
    local s4 = math.max( 0, level - 19 )

    local needed = 0
            + ( s1 / 2.0 ) * ( PlayerRanking_GetXPNeededForLevel(1) + PlayerRanking_GetXPNeededForLevel( s1 ) ) -- 1250 series from 2 to 7
            + ( s2 / 2.0 ) * ( PlayerRanking_GetXPNeededForLevel(8) + PlayerRanking_GetXPNeededForLevel( s2 + 7 ) )   -- 750 series from 8 to 14
            + ( s3 / 2.0 ) * ( PlayerRanking_GetXPNeededForLevel(15) + PlayerRanking_GetXPNeededForLevel( s3 + 14 ) )    -- 500 series from 15 to 19
            + ( s4 * 16500 )    -- constant from 20 up

    return needed
end

function PlayerRankingUI_GetRelativeSkillFraction()

    local relativeSkillFraction = 0

    local gameInfo = GetGameInfoEntity()
    local player = Client.GetLocalPlayer()

    if gameInfo and player and HasMixin(player, "Scoring") then

        local averageSkill = gameInfo:GetAveragePlayerSkill()
        if averageSkill > 0 then
            relativeSkillFraction = Clamp(player:GetPlayerSkill() / averageSkill, 0, 1)
        else
            relativeSkillFraction = 1
        end

    end

    return relativeSkillFraction

end

function PlayerRankingUI_GetLevelFraction()

    local levelFraction = 0

    local player = Client.GetLocalPlayer()
    if player and HasMixin(player, "Scoring") then
        levelFraction = Clamp(player:GetPlayerLevel() / kMaxPlayerLevel, 0, 1)
    end

    return levelFraction

end

class 'PlayerRanking'
function PlayerRanking:StartGame()

    self.gameStartTime = Shared.GetTime()

    self.gameStarted = true
    self.capturedPlayerData = {}

    avgNumPlayersSum = 0
    numPlayerCountSamples = 0

    self.roundTimeWeighted = 0

end

function PlayerRanking:GetTrackServer()
    return GetGamemode() == "ns2" and Server.IsDedicated()
            and not ( Shared.GetCheatsEnabled() or Shared.GetTestsEnabled() or Shared.GetDevMode() )
end

function PlayerRanking:GetRelativeRoundTime()
    return math.max(0, Shared.GetTime() - (self.gameStartTime or 0 )) --to prevent float underflow
end

local steamIdToClientIdMap = {}
function PlayerRanking:LogPlayer( player )

    if gRankingDisabled then
        return
    end

    if not self.capturedPlayerData then
        return
    end

    local client = player:GetClient()
    -- only consider players who are connected to the server and ignore any uncontrolled players / ragdolls
    if client then  --Includes Bots

        local steamId = client:GetUserId()

        if steamId > 0 then
            steamIdToClientIdMap[steamId] = client:GetId()
        end

        local playerData =
        {
            steamId = steamId,  --Note: Bots are determined by this value being 0
            nickname = player:GetName() or "",
            playTime = player:GetPlayTime(),
            marineTime = player:GetMarinePlayTime(),
            alienTime = player:GetAlienPlayTime(),
            kills = player:GetKills(),
            deaths = player:GetDeaths(),
            assists = player:GetAssistKills(),
            score = player:GetScore(),
            teamNumber = player:GetTeamNumber(),
            commanderTime = player:GetCommanderTime(),
            weightedTimeTeam1 = player:GetWeightedPlayTime( kTeam1Index ),
            weightedTimeTeam2 = player:GetWeightedPlayTime( kTeam2Index ),
            debug_marineEntranceTimes = player.weightedEntranceTimes[kTeam1Index],
            debug_marineExitTimes = player.weightedExitTimes[kTeam1Index],
            debug_alienEntranceTimes = player.weightedEntranceTimes[kTeam2Index],
            debug_alienExitTimes = player.weightedExitTimes[kTeam2Index],
        }

        table.insert( self.capturedPlayerData, playerData )

    end

end

--Sets the commanders scores to the teams averange
function PlayerRanking:CalcCommanderScores()
    local commanders = {{0,0}, {0,0}}
    local stats = {{0,0}, {0,0}}

    for _, data in ipairs(self.capturedPlayerData) do
        if data.teamNumber == kTeam1Index or data.teamNumber == kTeam2Index then
            if data.commanderTime > 1 and data.commanderTime > commanders[data.teamNumber][2] then
                commanders[data.teamNumber] = {data.steamId, data.commanderTime}
            end

            if data.teamNumber == 1 or data.teamNumber == 2 then
                stats[data.teamNumber] = {stats[data.teamNumber][1] + data.score, stats[data.teamNumber][2] + 1}
            end
        end
    end

    for i = 1,2 do
        if commanders[i][1] > 0 and stats[i][2] > 0 then
            self.capturedPlayerData[commanders[i][1]].score = math.max(self.capturedPlayerData[commanders[i][1]].score,
                    stats[i][1] / stats[i][2])
        end
    end

end

function PlayerRanking:SetEntranceTime( player, teamNumber )
    player:SetEntranceTime( teamNumber, self:GetRelativeRoundTime() )
end

function PlayerRanking:SetExitTime( player, teamNumber )
    player:SetExitTime( teamNumber, self:GetRelativeRoundTime() )
end

function PlayerRanking:EndGame(winningTeam)

    PROFILE("PlayerRanking:EndGame")

    if gRankingDisabled then
        return
    end

    local roundLength = math.max(0, Shared.GetTime() - self.gameStartTime)

    if self.gameStarted and self:GetTrackServer() and roundLength >= kMinMatchTime then

        local marineSkill, alienSkill = self:GetAveragePlayerSkill(kMarineTeamType), self:GetAveragePlayerSkill(kAlienTeamType)

        local gameEndTime = self:GetRelativeRoundTime()
        local aT = math.pow( 2, 1 / 600 )
        local sT = 1 -- start time is always 0 = math.pow( aT, self.gameStartTime * -1 )
        local eT = math.pow( aT, gameEndTime * -1 )
        self.roundTimeWeighted = sT - eT

        local LogPlayer = Closure [=[
            self this gameEndTime
            args player
            player:SetExitTime( player:GetTeamNumber(), gameEndTime )
            this:LogPlayer( player )
        ]=]{self, gameEndTime}

        GetGamerules():GetTeam1():ForEachPlayer(LogPlayer)
        GetGamerules():GetTeam2():ForEachPlayer(LogPlayer)
        GetGamerules():GetWorldTeam():ForEachPlayer(LogPlayer)
        GetGamerules():GetSpectatorTeam():ForEachPlayer(LogPlayer)

        -- dont send data of games lasting shorter than a minute. Those are most likely over because of players leaving the server / team.
        local gameInfo =
        {
            serverIp = Server.GetIpAddress(),
            dns = Server.GetConfigSetting("dyndns") or nil,
            port = Server.GetPort(),
            name = Server.GetName(),
            host_os = jit.os,
            mapName = Shared.GetMapName(),
            player_slots = Server.GetMaxPlayers(),
            --password = ,  --FIXME Have no means to fetch bool for "is passworded", need Lua-Bind/API change
            build = Shared.GetBuildNumber(),
            tournamentMode = GetTournamentModeEnabled(),
            rookie_only = ( Server.GetConfigSetting("rookie_only") == true ),
            conceded = ( GetGamerules():GetTeam1():GetHasConceded() or GetGamerules():GetTeam2():GetHasConceded() ),
            gameMode = GetGamemode(),
            avgPlayers = ( avgNumPlayersSum / numPlayerCountSamples ),
            gameTime = roundLength,
            winner = winningTeam:GetTeamNumber(),
            marineTeamSkill = marineSkill or 0,
            alienTeamSkill = alienSkill or 0,
            numBots = GetGameInfoEntity():GetNumBots(),
            roundTimeWeighted = self.roundTimeWeighted,
            players = {}
        }

        --319 introduced an error for commander score. removed. Score is not used for Level or Skill calculations
        --self:CalcCommanderScores()

        for _, playerData in ipairs(self.capturedPlayerData) do
            self:InsertPlayerData(gameInfo.players, playerData, winningTeam, roundLength, marineSkill, alienSkill, self.roundTimeWeighted)
        end

        --DebugPrint("PlayerRanking-HIVE2: game info ------------------")
        --DebugPrint("%s", gameInfo)

        --DebugPrint("HIVE2: %s", json.encode(gameInfo) )
        Shared.SendHTTPRequest( kRoundRankingUrl, "POST", { data = json.encode(gameInfo) }, function(data)

            local obj = json.decode(data, 1, nil)

            if obj and obj.status == true then

                if obj.recorded then
                    for _,v in ipairs(obj.players) do

                        local steamId = v.steamid
                        local pd = gPlayerData[steamId]
                        if pd then
                            pd.level = obj.level
                            pd.skill = obj.skill
                            pd.xp = obj.xp

                            local clientId = steamIdToClientIdMap[steamId]
                            local client = clientId and Server.GetClientById(clientId)
                            if client then
                                PlayerRanking_SetPlayerParams(client, pd)
                            end
                        end
                    end
                end
            end

        end)

    end

    self.roundTimeWeighted = 0
    self.gameStarted = false

end

function PlayerRanking:InsertPlayerData(playerTable, recordedData, winningTeam, gameTime, marineSkill, alienSkill, roundTimeWeighted)

    PROFILE("PlayerRanking:InsertPlayerData")

    -- Can't calculate isCommander or weightedTimeTeam values until the game is over, which is why this part is deferred
    local playerData =
    {
        steamId = recordedData.steamId, --Note: will be 0 for Bots
        nickname = recordedData.nickname or "",
        playTime = recordedData.playTime,
        marineTime = recordedData.marineTime,
        alienTime = recordedData.alienTime,
        teamNumber = recordedData.teamNumber,
        kills = recordedData.kills,
        deaths = recordedData.deaths,
        assists = recordedData.assists,
        score = recordedData.score or 0, --319 introduced an error for commander score. removed. Score is not used for Level or Skill calculations
        isCommander = ( recordedData.commanderTime / gameTime ) > 0.75,
        commanderTime = recordedData.commanderTime,
        weightedTimeTeam1 = recordedData.weightedTimeTeam1 / roundTimeWeighted,
        weightedTimeTeam2 = recordedData.weightedTimeTeam2 / roundTimeWeighted,

        debug_weightedTimeTeam1 = recordedData.weightedTimeTeam1,
        debug_weightedTimeTeam2 = recordedData.weightedTimeTeam2,
        debug_marineEntranceTimes = recordedData.debug_marineEntranceTimes,
        debug_marineExitTimes = recordedData.debug_marineExitTimes,
        debug_alienEntranceTimes = recordedData.debug_alienEntranceTimes,
        debug_alienExitTimes = recordedData.debug_alienExitTimes
    }

    table.insert(playerTable, playerData)

end

function PlayerRanking:UpdatePlayerSkills()

    PROFILE("PlayerRanking:UpdatePlayerSkill")

    -- update this only max once per frame
    if not self.timeLastSkillUpdate or self.timeLastSkillUpdate < Shared.GetTime() then

        self.playerSkills = {
            [kNeutralTeamType] = {},
            [kMarineTeamType] = {},
            [kAlienTeamType] = {},
            [3] = {},
        }

        for _, player in ipairs(GetEntitiesWithMixin("Scoring")) do

            local client = Server.GetOwner(player)
            local skill = player:GetPlayerSkill() and math.max(player:GetPlayerSkill(), 0)
            -- DebugPrint("%s skill: %s", ToString(player:GetName()), ToString(skill))

            if client and not client:GetIsVirtual() and skill then

                local teamType = HasMixin(player, "Team") and player:GetTeamType() or 0
                table.insert(self.playerSkills[teamType], skill)
                table.insert(self.playerSkills[3], skill)

            end

        end

        self.timeLastSkillUpdate = Shared.GetTime()

    end

end

function PlayerRanking:GetPlayerSkills()
    if not self.playerSkills then self:UpdatePlayerSkills() end

    return self.playerSkills
end

function PlayerRanking:GetAveragePlayerSkill(teamtype)
    teamtype = teamtype or 3

    self:UpdatePlayerSkills()

    return table.mean(self.playerSkills[teamtype])
end

if Server then

    local gPlayerData = {}

    function GetHiveDataBySteamId(steamid)
        return gPlayerData[steamid]
    end

    function PlayerRanking_SetPlayerParams(client, obj)
        local player = client and client:GetControllingPlayer()

        if player then
            Badges_FetchBadges(client:GetId(), obj.badges)

            player:SetTotalKills(obj.kills)
            player:SetTotalAssists(obj.assists)
            player:SetTotalDeaths(obj.deaths)
            player:SetPlayerSkill(obj.skill)
            player:SetAdagradSum(obj.adagrad_sum)
            player:SetTotalScore(obj.score)
            player:SetTotalPlayTime(obj.playTime)
            player:SetPlayerLevel(obj.level)
            player:SetTotalXP(obj.xp)

            if player:GetPlayerLevel() ~= -1 and player:GetPlayerLevel() < kRookieLevel then
                player:SetRookie(true)
            end
        end

    end

    local function PlayerDataResponse(steamId,clientId)
        return function (playerData)

            PROFILE("PlayerRanking:PlayerDataResponse")

            local obj = json.decode(playerData, 1, nil)

            if obj then

                -- its possible that the server does not send all data we want,
                -- need to check for nil here to not cause any script errors later:
                obj.kills = obj.kills or 0
                obj.assists = obj.assists or 0
                obj.deaths = obj.deaths or 0
                obj.skill = obj.skill or 0
                obj.score = obj.score or 0
                obj.playTime = obj.playTime or 0
                obj.level = obj.level or 0
                obj.xp    = obj.xp or 0

                gPlayerData[steamId] = obj

                local client = Server.GetClientById(clientId)
                if client then
                    PlayerRanking_SetPlayerParams(client, obj)
                end

            end

            --DebugPrint("player data of %s: %s", ToString(steamId), ToString(obj))

        end
    end

    local function OnConnect(client)
        PROFILE("PlayerRanking:OnConnect")

        if client and not client:GetIsVirtual() then

            local steamId = client:GetUserId()
            local playerData = gPlayerData[steamId]

            if not playerData or playerData.steamId ~= steamId then --no playerdata or invalid ones

                --DebugPrint("send player data request for %s", ToString(steamId))

                local requestUrl = string.format("%s%s", kPlayerRankingRequestUrl, steamId)
                Shared.SendHTTPRequest(requestUrl, "GET", { }, PlayerDataResponse(steamId, client:GetId()))

            else --set badges and values
                PlayerRanking_SetPlayerParams(client, playerData)
            end

        end

    end

    local gConfigChecked
    local function UpdatePlayerStats()

        PROFILE("PlayerRanking:UpdatePlayerStats")

        if not gConfigChecked and Server.GetConfigSetting then
            gRankingDisabled = gRankingDisabled or Server.GetConfigSetting("hiveranking") == false
            gConfigChecked = true
        end

        if Shared.GetCheatsEnabled() then
            gRankingDisabled = true
        end

        if gRankingDisabled then
            return
        end

        local gameRules = GetGamerules()

        if gameRules then
            local team1PlayerNum = gameRules:GetTeam1():GetNumPlayers()
            local team2PlayerNum = gameRules:GetTeam2():GetNumPlayers()

            avgNumPlayersSum = avgNumPlayersSum + team1PlayerNum + team2PlayerNum
            numPlayerCountSamples = numPlayerCountSamples + 1
        end

    end

    Event.Hook("ClientConnect", OnConnect)
    Event.Hook("UpdateServer", UpdatePlayerStats)
end