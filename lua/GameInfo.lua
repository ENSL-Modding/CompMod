-- ======= Copyright (c) 2012, Unknown Worlds Entertainment, Inc. All rights reserved. ==========
--
-- lua/GameInfo.lua
--
-- GameInfo is used to sync information about the game state to clients.
--
-- Created by Brian Cronin (brianc@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Globals.lua")


class 'GameInfo' (Entity)

GameInfo.kMapName = "gameinfo"

local networkVars =
{
    state = "enum kGameState",
    startTime = "time",
    averagePlayerSkill = "integer",
    rookieMode = "boolean",
    numClientsTotal = "integer",
    numPlayers = "integer",
    numBots = "integer",
	isDedicated = "boolean",
    serverIp = "string (16)",
    serverPort = "string (16)",
    team1Skin = "integer (0 to 8)",
    team2Skin = "integer (0 to 8)",
    team2SkinSpecial = "integer (0 to 8)" --Tunnels
}

function GameInfo:OnCreate()

    Entity.OnCreate(self)
    
    if Server then
    
        self:SetPropagate(Entity.Propagate_Always)
        self:SetUpdates(false)
        
        self:SetState(kGameState.NotStarted)

        self.startTime = 0
        self.averagePlayerSkill = 0
        self.numClientsTotal = 0
        self.numPlayers = 0
        self.numBots = 0
        self.isDedicated = Server.IsDedicated()
        self.serverIp = Server.GetIpAddress()
        self.serverPort = Server.GetPort()

    end
    
    self.team1Skin = kDefaultMarineStructureVariant
    self.team2Skin = kDefaultAlienStructureVariant
    self.team2SkinSpecial = kDefaultAlienTunnelVariant
    
end

function GameInfo:GetIsDedicated()
    return self.isDedicated
end

function GameInfo:GetStartTime()
    return self.startTime
end

function GameInfo:GetGameEnded()
    return self.state > kGameState.Started
end

function GameInfo:GetGameStarted()
    return self.state == kGameState.Started
end

function GameInfo:GetCountdownActive()
    return self.state == kGameState.Countdown
end

function GameInfo:GetWarmUpActive()
    return self.state == kGameState.WarmUp
end

function GameInfo:GetState()
    return self.state
end

function GameInfo:GetTeamSkin(teamIndex)
    if teamIndex == kTeam1Index then
        return self.team1Skin
    elseif teamIndex == kTeam2Index then
        return self.team2Skin
    end
end

function GameInfo:GetTeamSkinSpecial(teamIndex)
    
    if teamIndex == kTeam2Index then
        return self.team2SkinSpecial
    end

    return 0
end

if Server then
    function GameInfo:SetTeamSkin( teamIndex, skinIndex )
        if teamIndex == kTeam1Index then
            self.team1Skin = skinIndex
        elseif teamIndex == kTeam2Index then
            self.team2Skin = skinIndex
        end
    end

    function GameInfo:SetTeamSkinSpecial( teamIndex, skinIndex )
        if teamIndex == kTeam2Index then
            self.team2SkinSpecial = skinIndex
        else
            Log("Unsupported Team index for team-special skinIndex")
        end
    end
end

function GameInfo:GetAveragePlayerSkill()
    return self.averagePlayerSkill
end

function GameInfo:GetNumClientsTotal()
    return self.numClientsTotal
end

function GameInfo:GetNumPlayers()
    return self.numPlayers
end

function GameInfo:GetNumBots()
    return self.numBots
end

function GameInfo:GetRookieMode()
    return self.rookieMode
end

if Client then
    --Reset game end stats caches
    function GameInfo:OnResetGame()
        self.prevWinner = nil
        self.prevWinner = nil
        self.prevTeamsSkills = nil
    end

    function GameInfo:OnGameStateChange()
        SetWarmupActive(self.state == kGameState.WarmUp)
        return true -- continue watching the network field
    end

    function GameInfo:OnInitialized()
        Entity.OnInitialized(self)

        self.state = kGameState.NotStarted
        self:AddFieldWatcher("state", GameInfo.OnGameStateChange)
    end
end

if Server then

    function GameInfo:SetStartTime(startTime)
        self.startTime = startTime
    end
    
    function GameInfo:SetState(state)
        self.state = state

        SetWarmupActive(state == kGameState.WarmUp)
    end
    
    function GameInfo:SetAveragePlayerSkill(skill)
        self.averagePlayerSkill = skill
    end
    
    function GameInfo:SetNumClientsTotal( numClientsTotal )
        self.numClientsTotal = numClientsTotal
    end

    function GameInfo:SetNumPlayers( numPlayers )
        self.numPlayers = numPlayers
    end

    function GameInfo:SetNumBots( numBots )
        self.numBots = numBots
    end

    function GameInfo:SetRookieMode(mode)
        self.rookieMode = mode
    end
    
end

Shared.LinkClassToMap("GameInfo", GameInfo.kMapName, networkVars)