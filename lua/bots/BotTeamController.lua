--[[
 File: lua/bots/BotTeamController.lua

 Description: This Singleton controls how player bots get assigned automatically to the playing teams.
    The controller only starts to assign bots if there is a human player in any of the playing teams
    and if the given maxbot value is et higher than 0. In case the last human player left the controller
    will also remove all bots

 Creator: Sebastian Schuck (ghoulofgsg9@gmail.com)

 Copyright (c) 2015, Unknown Worlds Entertainment, Inc.
]]
class 'BotTeamController'

BotTeamController.MaxBots = 0

--[[
-- Returns how many humans and bots given team has
 ]]
function BotTeamController:GetPlayerNumbersForTeam(teamNumber, humanOnly)
    PROFILE("BotTeamController:GetPlayerNumbersForTeam")

    local botNum = 0
    local humanNum = 0

    local team = GetGamerules():GetTeam(teamNumber)

    local function count(player)
        if not player:GetIsVirtual() then
            humanNum = humanNum + 1
        end
    end
    team:ForEachPlayer(count)

    if humanOnly then return humanNum end

    for _, bot in ipairs(gServerBots) do
        if bot:GetTeamNumber() == teamNumber then
            botNum = botNum + 1
        end
    end

    return humanNum, botNum
end

function BotTeamController:GetCommanderBot(teamNumber)
    for _, commander in ipairs(gCommanderBots) do
        if commander:GetTeamNumber() == teamNumber then
            return commander
        end
    end
end

function BotTeamController:RemoveCommanderBots()
    while gCommanderBots[1] do
        gCommanderBots[1]:Disconnect()
    end
end

function BotTeamController:GetTeamHasCommander(teamNumber)
    if self:GetCommanderBot(teamNumber) then return true end

    local commandStructures = GetEntitiesForTeam("CommandStructure", teamNumber)

    for _, commandStructure in ipairs(commandStructures) do
        if commandStructure.occupied or commandStructure.gettingUsed then return true end
    end

    return false
end

function  BotTeamController:GetTeamNeedsCommander(teamNumber)
    if not self.addCommander then return end

    return not self:GetTeamHasCommander(teamNumber)
end

function BotTeamController:AddBots(teamIndex, amount)
    if amount < 1 then return end

    if self:GetTeamNeedsCommander(teamIndex) then
        OnConsoleAddBots(nil, 1, teamIndex, "com")
        amount = amount - 1
    end

    if amount < 1 then return end
    OnConsoleAddBots(nil, amount, teamIndex)
end

function BotTeamController:RemoveBots(teamIndex, amount)
    OnConsoleRemoveBots(nil, amount, teamIndex)
end

function BotTeamController:UpdateBotsForTeam(teamNumber)
    local teamHumanNum, teamBotsNum = self:GetPlayerNumbersForTeam(teamNumber)

    local teamCount = teamBotsNum + teamHumanNum 
    local maxTeamBots = math.floor(self.MaxBots / 2)

    if teamCount < maxTeamBots then
        self:AddBots(teamNumber, maxTeamBots - teamCount)
    elseif teamCount > maxTeamBots then
        if teamBotsNum > 0 then
            local amount = math.min(teamCount - maxTeamBots, teamBotsNum)
            self:RemoveBots(teamNumber, amount)
        end
    elseif self:GetTeamNeedsCommander(teamNumber) then
        self:RemoveBots(teamNumber, 1)
        self:AddBots(teamNumber, 1)
    end

end

function BotTeamController:DisableUpdate()
    self.updateLock = true
end

function BotTeamController:EnableUpdate()
    self.updateLock = false
end
--[[
-- Adds/removes a bot if needed, calling this method will trigger a recursive loop
-- over the PostJoinTeam method rebalancing the bots.
 ]]
function BotTeamController:UpdateBots()
    PROFILE("BotTeamController:UpdateBots")

    if self.updateLock then return end -- avoid getting called by itself while updating
    self:DisableUpdate()

    if self.MaxBots < 1 then --BotTeamController is disabled
        self:EnableUpdate()
        return
    end

    local team1HumanNum = self:GetPlayerNumbersForTeam(kTeam1Index, true)
    local team2HumanNum = self:GetPlayerNumbersForTeam(kTeam2Index, true)
    local humanCount = team1HumanNum + team2HumanNum

    -- Remove all bots if all humans left the playing teams
    if humanCount == 0 then
        self:RemoveBots(nil, #gServerBots)
        self:EnableUpdate()
        return
    end

    self:UpdateBotsForTeam(kTeam1Index)
    self:UpdateBotsForTeam(kTeam2Index)

    self:EnableUpdate()
end

--[[
--Sets the amount of maximal allowed bots totally (without considering the amount of human players)
 ]]
function BotTeamController:SetMaxBots(newMaxBots, com)
    self.MaxBots = newMaxBots
    self.addCommander = com

    if newMaxBots == 0 then
        while gServerBots[1] do
            gServerBots[1]:Disconnect()
        end
    end
end
