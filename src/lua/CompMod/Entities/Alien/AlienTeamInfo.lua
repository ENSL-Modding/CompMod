function AlienTeamInfo:SetWatchTeam(team)
    if team == self.team or not team then return end

    TeamInfo.SetWatchTeam(self, team)

    -- if Server then
        local teamNumber = self:GetTeamNumber()
        local tunnelManager = CreateEntity( "alientunnelmanager", Vector(100,100,100), teamNumber)
        tunnelManager:SetParent(self)

        tunnelManager:SetRelevancyDistance(Math.infinity)
        local mask = 0
        if teamNumber == kTeam1Index then
            mask = kRelevantToTeam1Commander
        elseif teamNumber == kTeam2Index then
            mask = kRelevantToTeam2Commander
        end
        tunnelManager:SetExcludeRelevancyMask(mask)

        self.tunnelManagerId = tunnelManager:GetId()
    -- end
end
