local kMaxArcs = 4
local netVars = {
    numArcs = string.format("integer (0 to %d)", kMaxArcs)
}

if Server then
    local oldReset = MarineTeamInfo.Reset
    function MarineTeamInfo:Reset()
        oldReset(self)
        self.numArcs = 0
    end
    
    local oldUpdate = MarineTeamInfo.OnUpdate
    function MarineTeamInfo:OnUpdate(deltaTime)
        oldUpdate(self, deltaTime)
        
        local team = self:GetTeam()
        if team then
            self.numArcs = math.min(team:GetNumActiveARCs(), kMaxArcs)
        end
    end
end

function MarineTeamInfo:CanBuildARC()
    return self.numArcs < kMaxArcs
end

Shared.LinkClassToMap("MarineTeamInfo", MarineTeamInfo.kMapName, netVars, true)