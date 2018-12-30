local oldInitTechTree = PlayingTeam.InitTechTree

function PlayingTeam:InitTechTree()
	oldInitTechTree(self)
	
	local researchToAdd = GetResearchToAdd()
	local activationToAdd = GetActivationToAdd()

    for _, value in pairs(researchToAdd) do
		ModPrintDebug("Adding research node: " .. (EnumToString(kTechId, value[1]) or value[1]) .. ", Team: " .. self:GetTeamNumber(), "all")
        self.techTree:AddResearchNode(value[1], value[2], value[3], value[4])
    end

    for _, value in pairs(activationToAdd) do
        ModPrintDebug("Adding activation node: " .. (EnumToString(kTechId, value[1]) or value[1]) .. ", Team: " .. self:GetTeamNumber(), "all")
        self.techTree:AddActivation(value[1], value[2], value[3])
    end
end