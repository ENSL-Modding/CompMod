function AlienTeamInfo:SetWatchTeam(team)
    if team == self.team or not team then return end

    TeamInfo.SetWatchTeam(self, team)

    if Server then
        local teamNumber = self:GetTeamNumber()
        local tunnelManager = CreateEntity( "alientunnelmanager", Vector(100,100,100), teamNumber)
        tunnelManager:SetParent(self)

        tunnelManager:SetRelevancyDistance(Math.infinity)
        -- CompMod: Change relevancy mask to all players on the team not just commanders
        local mask = 0
        if teamNumber == kTeam1Index then
            -- mask = kRelevantToTeam1Commander
            mask = kRelevantToTeam1
        elseif teamNumber == kTeam2Index then
            -- mask = kRelevantToTeam2Commander
            mask = kRelevantToTeam2
        end
        tunnelManager:SetExcludeRelevancyMask(mask)

        self.tunnelManagerId = tunnelManager:GetId()
    end
end
