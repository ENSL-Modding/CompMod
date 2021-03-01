function AlienTeamInfo:SetWatchTeam(team)
    if team == self.team or not team then return end

    TeamInfo.SetWatchTeam(self, team)

    if Server then
        local teamNumber = self:GetTeamNumber()
        local tunnelManager = CreateEntity( "alientunnelmanager", Vector(100,100,100), teamNumber)
        -- local tunnelManager = Server.CreateEntity("alientunnelmanager")
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
    end
end

function AlienTeamInfo:GetTunnelManager()
    Print("[%s]: AlienTeamInfo:GetTunnelManager()", Client and "Client" or Server and "Server" or Predict and "Predict" or "Unknown")
    local ent
    if self.tunnelManagerId ~= Entity.invalidId then
        ent = Shared.GetEntity(self.tunnelManagerId)
        if ent then
            Print("Found ent using id: %s", self.tunnelManagerId)
            return ent 
        end
    end

    -- Looking up id didn't work
    -- Try searching
    Print("Failed to get tunnel manager using id: %s", self.tunnelManagerId)
    Print("Trying to search")
    local tunnelManagerList = GetEntitiesForTeam("alientunnelmanager", self:GetTeamNumber())
    Print("Found %s entities", #tunnelManagerList)
    ent = tunnelManagerList[1]
    if not ent then
        Print("Failed to find entity")
    end

    return ent
end
