--=============================================================================
--
-- lua\bots\Bot.lua
--
-- Created by Max McGuire (max@unknownworlds.com)
-- Copyright (c) 2011, Unknown Worlds Entertainment, Inc.
--
--=============================================================================

if (not Server) then
    error("Bot.lua should only be included on the Server")
end

Script.Load("lua/bots/BotDebug.lua")

-- Stores all of the bots
gServerBots = {}
kMaxBots = 100

class 'Bot'

Script.Load("lua/TechMixin.lua")
Script.Load("lua/ExtentsMixin.lua")
Script.Load("lua/PathingMixin.lua")
Script.Load("lua/OrdersMixin.lua")


function Bot:Initialize(forceTeam, active, tablePosition)
    PROFILE("Bot:Initialize")

    InitMixin(self, TechMixin)
    InitMixin(self, ExtentsMixin)
    InitMixin(self, PathingMixin)
    InitMixin(self, OrdersMixin, { kMoveOrderCompleteDistance = kAIMoveOrderCompleteDistance })

    -- Create a virtual client for the bot
    self.client = Server.AddVirtualClient()
    self.team = forceTeam
    self.active = active

    if tablePosition then
        table.insert(gServerBots, tablePosition, self)
    else
        gServerBots[#gServerBots + 1] = self
    end

    return true
end

function Bot:GetMapName()
    return "bot"
end

function Bot:GetIsFlying()
    return false
end

function Bot:UpdateTeam()
    PROFILE("Bot:UpdateTeam")

    local player = self:GetPlayer()

    -- Join random team (could force join if needed but will enter respawn queue if game already started)
    if player and player:GetTeamNumber() == 0 then
    
        if not self.team then
            self.team = math.random(1, 2)
        end

        local gamerules = GetGamerules()
        if gamerules and gamerules:GetCanJoinTeamNumber(player, self.team) then
            gamerules:JoinTeam(player, self.team)
        end
        
    end

end

function Bot:GetTeamNumber()
    return self.team
end

function Bot:Disconnect()
    local client = self.client
    self:OnDestroy()

    Server.DisconnectClient(client)
end

function Bot:GetPlayer()
    PROFILE("Bot:GetPlayer")

    if self.client and self.client:GetId() ~= Entity.invalidId then
        return self.client:GetControllingPlayer()
    else
        return nil
    end
end

------------------------------------------
--  NOTE: There is no real reason why this is different from GenerateMove - the C++ just calls one after another.
--  For now, just put higher-level book-keeping here I guess.
------------------------------------------
function Bot:OnThink()
    PROFILE("Bot:OnThink")

    self:UpdateTeam()

end

function Bot:OnDestroy()
    for i = #gServerBots, 1, -1 do
        local bot = gServerBots[i]
        if bot == self then
            table.remove(gServerBots, i)
            break
        end
    end

    self.client = nil
end

------------------------------------------
--  Console commands for managing bots
------------------------------------------

local function GetIsClientAllowedToManage(client)

    return client == nil    -- console command from server
    or Shared.GetCheatsEnabled()
    or Shared.GetDevMode()
    or client:GetIsLocalClient()    -- the client that started the listen server

end

function OnConsoleAddPassiveBots(client, numBotsParam, forceTeam, className)
    OnConsoleAddBots(client, numBotsParam, forceTeam, className, true)  
end

function OnConsoleAddBots(client, numBotsParam, forceTeam, botType, passive)

    if GetIsClientAllowedToManage(client) then

        local kType2Class =
        {
            test = TestBot,
            com = CommanderBot
        }
        local class = kType2Class[ botType ] or PlayerBot

        local numBots = 1
        if numBotsParam then
            numBots = math.max(tonumber(numBotsParam), 1)
        end

        for index = 1, numBots do
        
            local bot = class()
            bot:Initialize(tonumber(forceTeam), not passive)
        end
        
    end
    
end

function OnConsoleRemoveBots(client, numBotsParam, teamNum)

    if GetIsClientAllowedToManage(client) then
    
        local numBots = 1
        if numBotsParam then
            numBots = math.max(tonumber(numBotsParam), 1)
        end
        
        teamNum = teamNum and tonumber(teamNum) or nil
        
        local numRemoved = 0
        for index = #gServerBots, 1, -1 do

            local bot = gServerBots[index]
            if not teamNum or bot:GetTeamNumber() == teamNum then
                bot:Disconnect()
                numRemoved = numRemoved + 1
            end

            if numRemoved == numBots then
                break
            end

        end
        
    end
    
end

local gFreezeBots = false
function OnConsoleFreezeBots(client)
    if GetIsClientAllowedToManage(client) then
        gFreezeBots = not gFreezeBots
    end
end

function OnConsoleListBots(client)
    if not GetIsClientAllowedToManage(client) then return end

    Shared.Message("List of currently active bots:")
    for i = 1, #gServerBots do
        local bot = gServerBots[i]
        local player = bot and bot:GetPlayer()
        local name = player and player:GetName() or "No Name"
        local team = bot:GetTeamNumber()
        local cTeam = player and player:GetTeamNumber() or 0
        Shared.Message(string.format("%s: %s (%s)- Team: %s->%s", i, name, bot.classname, cTeam, team))
    end
end

function OnVirtualClientMove(client)

    if gFreezeBots then return Move() end

    -- If the client corresponds to one of our bots, generate a move for it.
    for _,bot in ipairs(gServerBots) do
        if client == bot.client then
            return bot:GenerateMove()
        end
    end

    return Move()

end

function OnVirtualClientThink(client, deltaTime)

    if gFreezeBots then return true end
    
    -- If the client corresponds to one of our bots, allow it to think.
    for _, bot in ipairs(gServerBots) do

        if bot.client == client then
            bot:OnThink()
        end
        
    end

    return true
    
end


-- Make sure to load these after Bot is defined
Script.Load("lua/bots/TestBot.lua")
Script.Load("lua/bots/PlayerBot.lua")
Script.Load("lua/bots/CommanderBot.lua")

-- Register the bot console commands
Event.Hook("Console_addpassivebot",  OnConsoleAddPassiveBots)
Event.Hook("Console_addbot",         OnConsoleAddBots)
Event.Hook("Console_removebot",      OnConsoleRemoveBots)
Event.Hook("Console_addbots",        OnConsoleAddBots)
Event.Hook("Console_removebots",     OnConsoleRemoveBots)
Event.Hook("Console_freezebots",     OnConsoleFreezeBots)
Event.Hook("Console_listbots",       OnConsoleListBots)

-- Register to handle when the server wants this bot to
-- process orders
Event.Hook("VirtualClientThink",    OnVirtualClientThink)

-- Register to handle when the server wants to generate a move
-- for one of the virtual clients
Event.Hook("VirtualClientMove",     OnVirtualClientMove)
