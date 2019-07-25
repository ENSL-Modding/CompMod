--=============================================================================
--
-- lua/Commander_ResourcePanel.lua
--
-- Created by Henry Kropf and Charlie Cleveland
-- Copyright 2011, Unknown Worlds Entertainment
--
--=============================================================================

--
-- Get total number of team harvesters.
--
function CommanderUI_GetTeamHarvesterCount()

    PROFILE("CommanderUI_GetTeamHarvesterCount")
    
    local player = Client.GetLocalPlayer()
    if player ~= nil then
    
        local teamInfo = GetEntitiesForTeam("TeamInfo", player:GetTeamNumber())
        if table.icount(teamInfo) > 0 then
            return teamInfo[1]:GetNumResourceTowers()
        end
        
    end
    
    return 0
    
end