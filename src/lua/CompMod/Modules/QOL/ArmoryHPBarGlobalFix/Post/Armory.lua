local kArmoryHealthbarHeight = 1.4
local kAdvancedArmoryHealthbarHeight = 1.7

function Armory:GetHealthbarOffset()
	if self:GetTechId() == kTechId.AdvancedArmory then
		return kAdvancedArmoryHealthbarHeight
	end
    return kArmoryHealthbarHeight
end