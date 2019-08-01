--[[
======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
    
 lua\ScoringMixin.lua    
   ScoringMixin keeps track of a score. It provides function to allow changing the score. 
    Created by:   Brian Cronin (brianc@unknownworlds.com)    
    
========= For more information, visit us at http://www.unknownworlds.com =====================    
--]]

ScoringMixin = CreateMixin(ScoringMixin)
ScoringMixin.type = "Scoring"

local gSessionKills = {}

function GetSessionKills(clientIndex)
    return gSessionKills[clientIndex] or 0
end

ScoringMixin.networkVars =
{
    playerSkill = "integer",
    adagradSum = "float",
    playTime = "private time",
    playerLevel = "integer",
    totalXP = "integer",
    teamAtEntrance = string.format("integer (-1 to %d)", kSpectatorIndex)
}

ScoringMixin.optionalConstants = {
    kMaxScore = "Max score"
}

function ScoringMixin:__initmixin()
    
    PROFILE("ScoringMixin:__initmixin")
    
    self.score = 0
    -- Some types of points are added continuously. These are tracked here.
    self.continuousScores = { }
    
    self.serverJoinTime = Shared.GetTime()

    self.playerLevel = -1
    self.totalXP = -1
    self.playerSkill = -1
    self.adagradSum = 0
    
    self.weightedEntranceTimes = {}
    self.weightedEntranceTimes[kTeam1Index] = {}
    self.weightedEntranceTimes[kTeam2Index] = {}
    
    self.weightedExitTimes = {}
    self.weightedExitTimes[kTeam1Index] = {}
    self.weightedExitTimes[kTeam2Index] = {}
    
end

function ScoringMixin:GetScore()
    return self.score
end

function ScoringMixin:AddScore(points, res, wasKill)

    -- Should only be called on the Server.
    if Server then
    
        -- Tell client to display cool effect.
        if points and points ~= 0 and not GetGameInfoEntity():GetWarmUpActive() then
        
            local displayRes = ConditionalValue(type(res) == "number", res, 0)
            Server.SendNetworkMessage(Server.GetOwner(self), "ScoreUpdate", { points = points, res = displayRes, wasKill = wasKill == true }, true)
            self.score = Clamp(self.score + points, 0, self:GetMixinConstants().kMaxScore or 100)

            if not self.scoreGainedCurrentLife then
                self.scoreGainedCurrentLife = 0
            end

            self.scoreGainedCurrentLife = self.scoreGainedCurrentLife + points    

        end
    
    end
    
end

function ScoringMixin:GetScoreGainedCurrentLife()
    return self.scoreGainedCurrentLife
end

function ScoringMixin:GetPlayerLevel()
    return self.playerLevel
end
  
function ScoringMixin:GetTotalXP()
    return self.totalXP
end

function ScoringMixin:GetPlayerSkill()
    return self.playerSkill
end

function ScoringMixin:GetAdagradSum()
    return self.adagradSum
end

function ScoringMixin:GetSkillTier()
    if self.GetIsVirtual and self:GetIsVirtual() then return -1 end

    local skill = self:GetPlayerSkill()
    if skill < 0 then return -2 end

    if not self.skillTier then
        local isRookie = self:GetPlayerLevel() <= kRookieLevel
        self.skillTier = GetPlayerSkillTier(skill, isRookie, self:GetAdagradSum())
    end

    return self.skillTier
end

if Server then

    function ScoringMixin:CopyPlayerDataFrom(player)
    
        self.scoreGainedCurrentLife = player.scoreGainedCurrentLife    
        self.score = player.score or 0
        self.kills = player.kills or 0
        self.assistkills = player.assistkills or 0
        self.deaths = player.deaths or 0
        self.playTime = player.playTime or 0
        self.commanderTime = player.commanderTime or 0
        self.marineTime = player.marineTime or 0
        self.alienTime = player.alienTime or 0
        
        self.weightedEntranceTimes = player.weightedEntranceTimes
        self.weightedExitTimes = player.weightedExitTimes
        
        self.teamAtEntrance = player.teamAtEntrance
        
        self.totalKills = player.totalKills
        self.totalAssists = player.totalAssists
        self.totalDeaths = player.totalDeaths
        self.playerSkill = player.playerSkill
        self.adagradSum = player.adagradSum
        self.skillTier = player.skillTier
        self.totalScore = player.totalScore
        self.totalPlayTime = player.totalPlayTime
        self.playerLevel = player.playerLevel
        self.totalXP = player.totalXP
        
    end

    function ScoringMixin:OnKill()    
        self.scoreGainedCurrentLife = 0
    end
    
    function ScoringMixin:GetMarinePlayTime()
        return self.marineTime
    end
    
    function ScoringMixin:GetAlienPlayTime()
        return self.alienTime
    end
    
    function ScoringMixin:GetCommanderTime()
        return self.commanderTime or 0
    end
    
    local function SharedUpdate(self, deltaTime)
    
        if not self.commanderTime then
            self.commanderTime = 0
        end
        
        if not self.playTime then
            self.playTime = 0
        end
        
        if not self.marineTime then
            self.marineTime = 0
        end
        
        if not self.alienTime then
            self.alienTime = 0
        end    
        
        if self:GetIsPlaying() then
        
            if self:isa("Commander") then
                self.commanderTime = self.commanderTime + deltaTime
            end
            
            self.playTime = self.playTime + deltaTime
            
            if self:GetTeamType() == kMarineTeamType then
                self.marineTime = self.marineTime + deltaTime
            end
            
            if self:GetTeamType() == kAlienTeamType then
                self.alienTime = self.alienTime + deltaTime
            end
        
        end
    
    end
    
    function ScoringMixin:OnProcessMove(input)
        SharedUpdate(self, input.time)
    end
    
    function ScoringMixin:OnUpdate(deltaTime)
        PROFILE("ScoringMixin:OnUpdate")
        SharedUpdate(self, deltaTime)
    end

end

function ScoringMixin:GetPlayTime()
    return self.playTime
end

function ScoringMixin:GetLastTeam()
    return self.teamAtEntrance
end

function ScoringMixin:AddKill()
    if GetWarmupActive() then return end

    if not self.kills then
        self.kills = 0
    end    

    self.kills = Clamp(self.kills + 1, 0, kMaxKills)
    
    if self.clientIndex and self.clientIndex > 0 then
        if not gSessionKills[self.clientIndex] then
            gSessionKills[self.clientIndex] = 0
        end
        gSessionKills[self.clientIndex] = gSessionKills[self.clientIndex] + 1
    end

end

function ScoringMixin:AddAssistKill()
    if GetWarmupActive() then return end

    if not self.assistkills then
        self.assistkills = 0
    end    

    self.assistkills = Clamp(self.assistkills + 1, 0, kMaxKills)

end

function ScoringMixin:GetKills()
    return self.kills
end

function ScoringMixin:GetAssistKills()
    return self.assistkills
end

function ScoringMixin:GetDeaths()
    return self.deaths
end

function ScoringMixin:AddDeaths()
    if GetWarmupActive() then return end

    if not self.deaths then
        self.deaths = 0
    end

    self.deaths = Clamp(self.deaths + 1, 0, kMaxDeaths)

end

function ScoringMixin:SetEntranceTime( teamNumber, time )
    --RawPrint( "SetEntranceTime", teamNumber, time ) 
    if time and teamNumber and ( teamNumber == kTeam1Index or teamNumber == kTeam2Index ) then
        self.teamAtEntrance = teamNumber
        table.insert( self.weightedEntranceTimes[teamNumber], time )
    end
end

function ScoringMixin:SetExitTime( teamNumber, time ) 
    --RawPrint( "SetExitTime", teamNumber, time ) 
    if time and teamNumber and ( teamNumber == kTeam1Index or teamNumber == kTeam2Index ) then
        table.insert( self.weightedExitTimes[teamNumber], time )
    end
end

function ScoringMixin:GetWeightedPlayTime( forTeamIdx )
    
    if forTeamIdx ~= kTeam1Index and forTeamIdx ~= kTeam2Index then
        return 0
    end
    
    local weightedTime = 0
    local aT = math.pow( 2, 1 / 600 )
    
    --Since time-spent on teams doesn't exceed allotted gameTime, additive is used
    if self.weightedEntranceTimes[forTeamIdx] and #self.weightedEntranceTimes[forTeamIdx] > 0 then
        
        local entrance, exit
        local te, tx = 1, 1
        repeat
            -- get entrance
            repeat 
                entrance, te = self.weightedEntranceTimes[forTeamIdx][te], te + 1
            until not entrance or not exit or entrance > exit -- Ensure non-paired times are skipped.
            
            -- get corresponding exit
            if entrance then
                repeat 
                    exit, tx = self.weightedExitTimes[forTeamIdx][tx], tx + 1
                until not exit or exit > entrance -- Ensure non-paired times are skipped.
               
                if exit then
                    weightedTime = weightedTime + ( math.pow( aT, (entrance * -1) ) - math.pow( aT, (exit * -1) ) )
                end
            end
            
        until not entrance or not exit
        
    end
    
    return weightedTime
    
end

function ScoringMixin:ResetScores()

    self.score = 0
    self.kills = 0
    self.assistkills = 0
    self.deaths = 0    

    self.commanderTime = 0
    self.playTime = 0
    self.marineTime = 0
    self.alienTime = 0
    
    self.weightedEntranceTimes = {}
    self.weightedEntranceTimes[kTeam1Index] = {}
    self.weightedEntranceTimes[kTeam2Index] = {}
    
    self.weightedExitTimes = {}
    self.weightedExitTimes[kTeam1Index] = {}
    self.weightedExitTimes[kTeam2Index] = {}

end

-- Only award the pointsGivenOnScore once the amountNeededToScore are added into the score
-- determined by the passed in name.
-- An example, to give points based on health healed:
-- AddContinuousScore("Heal", amountHealed, 100, 1)
function ScoringMixin:AddContinuousScore(name, addAmount, amountNeededToScore, pointsGivenOnScore)

    if Server then
    
        self.continuousScores[name] = self.continuousScores[name] or { amount = 0 }
        self.continuousScores[name].amount = self.continuousScores[name].amount + addAmount
        while self.continuousScores[name].amount >= amountNeededToScore do
        
            self:AddScore(pointsGivenOnScore, 0)
            self.continuousScores[name].amount = self.continuousScores[name].amount - amountNeededToScore
            
        end
        
    end
    
end

if Server then

    function ScoringMixin:SetTotalKills(totalKills)
        self.totalKills = math.round(totalKills)
    end
    
    function ScoringMixin:SetTotalAssists(totalAssists)
        self.totalAssists = math.round(totalAssists)
    end
    
    function ScoringMixin:SetTotalDeaths(totalDeaths)
        self.totalDeaths = math.round(totalDeaths)
    end
    
    function ScoringMixin:SetPlayerSkill(playerSkill)
        self.playerSkill = math.round(playerSkill)
    end

    function ScoringMixin:SetAdagradSum(adagradSum)
        self.adagradSum = adagradSum
    end
    
    function ScoringMixin:SetTotalScore(totalScore)
        self.totalScore = math.round(totalScore)
    end
    
    function ScoringMixin:SetTotalPlayTime(totalPlayTime)
        self.totalPlayTime = math.round(totalPlayTime)
    end
    
    function ScoringMixin:SetPlayerLevel(playerLevel)
        self.playerLevel = math.round(playerLevel)
    end 

    function ScoringMixin:SetTotalXP(playerLevel)
        self.totalXP = math.round(playerLevel)
    end 
end

