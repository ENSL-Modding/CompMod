function RoboticsFactory:GetTechAllowed(techId, techNode, player)
    local allowed, canAfford = ScriptActor.GetTechAllowed(self, techId, techNode, player)
    
    -- Do not allow tech while open or researching or we may lose res.
    -- Research progress is checked here instead of GetIsResearching() because
    -- there is a delay in the tech tree when tech is queued which causes
    -- GetIsResearching() to return true before the research is 100% complete.
    -- Checking the progress is 0 is the sure way to get around that limit.
    -- $AU: Which causes the cancel button to not work anymore. I want to make the tech tree
    -- finally entity based (this will also make both tech trees available for insight) with clearer API.
    allowed = allowed and not self.open and self:GetResearchProgress() == 0
    
    if techId == kTechId.ARC then
        local teamInfo = GetTeamInfoEntity(kTeam1Index)
        assert(teamInfo)
        allowed = allowed and self:GetTechId() == kTechId.ARCRoboticsFactory and teamInfo:CanBuildARC()
    elseif techId == kTechId.Cancel then
        allowed = self:GetResearchProgress() < 1
    end
    
    return allowed, canAfford
end