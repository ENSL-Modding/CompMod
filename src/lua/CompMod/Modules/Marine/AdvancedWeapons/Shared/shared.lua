local techHandler = CompMod:GetModule('techhandler')

-- Delete old tech nodes and update techmap
techHandler:RemoveMarineResearchNode(kTechId.ShotgunTech)
techHandler:ChangeMarineTargetedBuyNode(kTechId.Shotgun, kTechId.MunitionsTech, kTechId.None)
techHandler:ChangeMarineTargetedActivation(kTechId.DropShotgun, kTechId.MunitionsTech, kTechId.None)
techHandler:RemoveMarineTechMapTech(kTechId.ShotgunTech)
techHandler:RemoveMarineTechMapLine(kTechId.Armory, kTechId.ShotgunTech)
techHandler:RemoveTechData(kTechId.ShotgunTech)

techHandler:ChangeMarineTargetedBuyNode(kTechId.HeavyMachineGun, kTechId.MunitionsTech)
techHandler:ChangeMarineTargetedActivation(kTechId.DropHeavyMachineGun, kTechId.MunitionsTech)
techHandler:RemoveTechData(kTechId.HeavyMachineGunTech)

techHandler:ChangeMarineTargetedBuyNode(kTechId.GrenadeLauncher, kTechId.DemolitionsTech)
techHandler:ChangeMarineTargetedActivation(kTechId.DropGrenadeLauncher, kTechId.DemolitionsTech)
techHandler:RemoveMarineResearchNode(kTechId.GrenadeLauncherTech)
techHandler:RemoveTechData(kTechId.GrenadeLauncherTech)

techHandler:ChangeMarineTargetedBuyNode(kTechId.Flamethrower, kTechId.DemolitionsTech)
techHandler:ChangeMarineTargetedActivation(kTechId.DropFlamethrower, kTechId.DemolitionsTech)
techHandler:RemoveMarineTechMapTech(kTechId.FlamethrowerTech)
techHandler:RemoveTechData(kTechId.FlamethrowerTech)

techHandler:RemoveMarineResearchNode(kTechId.AdvancedWeaponry)
techHandler:RemoveMarineTechMapLine(kTechId.AdvancedArmory, kTechId.AdvancedWeaponry)
techHandler:RemoveMarineTechMapTech(kTechId.AdvancedWeaponry)
techHandler:RemoveTechData(kTechId.AdvancedWeaponry)

-- Add new tech
techHandler:AddMarineResearchNode(kTechId.MunitionsTech, kTechId.Armory, kTechId.None, kTechId.PhaseTech)
techHandler:AddMarineResearchNode(kTechId.DemolitionsTech, kTechId.AdvancedArmory, kTechId.None, kTechId.PhaseTech)

-- Update TechMap
techHandler:AddMarineTechMapTech(kTechId.MunitionsTech, 4, 3)
techHandler:AddMarineTechMapTech(kTechId.DemolitionsTech, 2.5, 6)
techHandler:AddMarineTechMapLine(kTechId.AdvancedArmory, kTechId.DemolitionsTech)
techHandler:AddMarineTechMapLine(kTechId.Armory, kTechId.MunitionsTech)

-- Add TechData entries
techHandler:AddTechData({
    [kTechDataId] = kTechId.MunitionsTech,
    [kTechDataCostKey] = kMunitionsTechResearchCost,
    [kTechDataResearchTimeKey] = kMunitionsTechResearchTime,
    [kTechDataDisplayName] = "Research Munitions",
    [kTechDataTooltipInfo] = "Allows Shotguns and Heavy Machine Guns to be purchased at the Armory",
})

techHandler:AddTechData({
    [kTechDataId] = kTechId.DemolitionsTech,
    [kTechDataCostKey] = kDemolitionsTechResearchCost,
    [kTechDataResearchTimeKey] = kDemolitionsTechResearchTime,
    [kTechDataDisplayName] = "Research Demolitions",
    [kTechDataTooltipInfo] = "Allows Flamethowers and Grenade Launchers to be purchased at the Advanced Armory",
})

-- Update material offsets
techHandler:AddMaterialOffset(kTechId.MunitionsTech, 85)
techHandler:AddMaterialOffset(kTechId.DemolitionsTech, 140)

-- Change DropHeavyMachineGun to allow HMG to be dropped from armory
techHandler:ChangeTechData(kTechId.DropHeavyMachineGun, {[kStructureAttachId] = { kTechId.Armory, kTechId.AdvancedArmory }})
