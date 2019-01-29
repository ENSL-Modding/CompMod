local Mod = GetMod()

local oldInitTechTree = PlayingTeam.InitTechTree

function PlayingTeam:InitTechTree()
	oldInitTechTree(self)

	local researchToAdd = Mod:GetResearchToAdd()
	local activationToAdd = Mod:GetActivationToAdd()
	local buyToAdd = Mod:GetBuyNodesToAdd()
	local buildToAdd = Mod:GetBuildNodesToAdd()
	local upgradesToAdd = Mod:GetUpgradesToAdd()

	for _, value in ipairs(researchToAdd) do
		Mod:PrintDebug("Adding research node: " .. (EnumToString(kTechId, value[1]) or value[1]) .. ", Team: " .. self:GetTeamNumber(), "all")
		self.techTree:AddResearchNode(value[1], value[2], value[3], value[4])
	end

	for _, value in ipairs(activationToAdd) do
		Mod:PrintDebug("Adding activation node: " .. (EnumToString(kTechId, value[1]) or value[1]) .. ", Team: " .. self:GetTeamNumber(), "all")
		self.techTree:AddActivation(value[1], value[2], value[3])
	end

	for _, value in ipairs(buyToAdd) do
		Mod:PrintDebug("Adding buy node: " .. (EnumToString(kTechId, value[1]) or value[1]) .. ", Team: " .. self:GetTeamNumber(), "all")
		self.techTree:AddBuyNode(value[1], value[2], value[3], value[4])
	end

	for _, value in ipairs(buildToAdd) do
		Mod:PrintDebug("Adding build node: " .. (EnumToString(kTechId, value[1]) or value[1]) .. ", Team: " .. self:GetTeamNumber(), "all")
		self.techTree:AddBuildNode(value[1], value[2], value[3], value[4])
	end

	for _, value in ipairs(upgradesToAdd) do
		if self:GetTeamNumber() == value[4] then
			Mod:PrintDebug("Adding upgrade node: " .. (EnumToString(kTechId, value[1]) or value[1]) .. ", Team: " .. self:GetTeamNumber(), "all")
			self.techTree:AddUpgradeNode(value[1], value[2], value[3])
		end
	end
end
