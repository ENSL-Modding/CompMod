-- ======= Copyright (c) 2003-2017, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\VotingAddCommanderBots.lua
--
--    Created by:   Sebastian Schuck (sebastian@naturalselection2.com)
--
--    A simple vote to add commander bots for missing commnaders.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

local kExecuteVoteDelay = 5

RegisterVoteType("VoteAddCommanderBots", { })

if Client then

    local function SetupAddCommanderBotsVote(voteMenu)

        local function StartAddCommanderBotsVote(data)
            AttemptToStartVote("VoteAddCommanderBots", { })
        end

        voteMenu:AddMainMenuOption(Locale.ResolveString("VOTE_ADD_COMMANDER_BOTS"), nil, StartAddCommanderBotsVote)

        -- This function translates the networked data into a question to display to the player for voting.
        local function GetVoteAddCommanderBotsQuery(data)
            local gameStarted = GetGameInfoEntity():GetGameStarted()
            if gameStarted then
                return Locale.ResolveString("VOTE_ADD_COMMANDER_BOTS_QUERY")
            else
                return Locale.ResolveString("VOTE_START_COMMANDER_BOTS_QUERY")
            end
        end
        AddVoteStartListener("VoteAddCommanderBots", GetVoteAddCommanderBotsQuery)

    end
    AddVoteSetupCallback(SetupAddCommanderBotsVote)

end

if Server then

    function VotingAddCommanderBotsAllowed()
        return GetGamemode() == "ns2"
    end

    local function OnAddCommanderBotsVoteSuccessful(data)
        local gamerules = GetGamerules()
        local botController = gamerules.botTeamController

        if not botController then return end

        if not botController:GetTeamHasCommander(kTeam1Index) then
            OnConsoleAddBots(nil, 1, 1, "com")
            gamerules.removeCommanderBots = true
        end

        if not botController:GetTeamHasCommander(kTeam2Index) then
            OnConsoleAddBots(nil, 1, 2, "com")
            gamerules.removeCommanderBots = true
        end
    end
    SetVoteSuccessfulCallback("VoteAddCommanderBots", kExecuteVoteDelay, OnAddCommanderBotsVoteSuccessful)

end