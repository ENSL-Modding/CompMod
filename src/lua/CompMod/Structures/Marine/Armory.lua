local kArmoryHealthbarHeight = 1.4
local kAdvancedArmoryHealthbarHeight = 1.7

function Armory:GetHealthbarOffset()
	if self:GetTechId() == kTechId.AdvancedArmory then
		return kAdvancedArmoryHealthbarHeight
	end
    return kArmoryHealthbarHeight
end

function Armory:GetTechButtons(techId)

    local techButtons = 
    {
        kTechId.ShotgunTech, kTechId.MinesTech, kTechId.GrenadeTech, kTechId.None,
        kTechId.None, kTechId.None, kTechId.None, kTechId.None 
    }

    -- Show button to upgraded to advanced armory
    if self:GetTechId() == kTechId.Armory and self:GetResearchingId() ~= kTechId.AdvancedArmoryUpgrade then
        techButtons[kMarineUpgradeButtonIndex] = kTechId.AdvancedArmoryUpgrade
    end

    if self:GetTechId() == kTechId.AdvancedArmory then
        techButtons[5] = kTechId.DemolitionsTech
    end

    return techButtons

end

function Armory:GetItemList(forPlayer)

    local itemList = {
        kTechId.Welder,
        kTechId.LayMines,
        kTechId.Shotgun,
        kTechId.HeavyMachineGun,
        kTechId.ClusterGrenade,
        kTechId.GasGrenade,
        kTechId.PulseGrenade
    }

    if self:GetTechId() == kTechId.AdvancedArmory then

        itemList = {
            kTechId.Welder,
            kTechId.LayMines,
            kTechId.Shotgun,
            kTechId.HeavyMachineGun,
            kTechId.GrenadeLauncher,
            kTechId.Flamethrower,
            kTechId.ClusterGrenade,
            kTechId.GasGrenade,
            kTechId.PulseGrenade,
        }

    end

    return itemList

end
