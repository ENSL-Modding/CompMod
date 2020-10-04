local techHandler = CompMod:GetModule('techhandler')

-- Delete old tech nodes and update techmap
techHandler:ChangeMarineTargetedBuyNode(kTechId.GrenadeLauncher, kTechId.DemolitionsTech)
techHandler:ChangeMarineTargetedActivation(kTechId.DropGrenadeLauncher, kTechId.DemolitionsTech)
techHandler:RemoveMarineResearchNode(kTechId.GrenadeLauncherTech)
techHandler:RemoveTechData(kTechId.GrenadeLauncherTech)

techHandler:ChangeMarineTargetedBuyNode(kTechId.Flamethrower, kTechId.DemolitionsTech)
techHandler:ChangeMarineTargetedActivation(kTechId.DropFlamethrower, kTechId.DemolitionsTech)
techHandler:RemoveMarineTechMapTech(kTechId.FlamethrowerTech)
techHandler:RemoveTechData(kTechId.FlamethrowerTech)

techHandler:ChangeMarineTargetedBuyNode(kTechId.HeavyMachineGun, kTechId.AdvancedArmory)
techHandler:ChangeMarineTargetedActivation(kTechId.DropHeavyMachineGun, kTechId.AdvancedArmory)

techHandler:RemoveMarineResearchNode(kTechId.AdvancedWeaponry)
techHandler:RemoveMarineTechMapLine(kTechId.AdvancedArmory, kTechId.AdvancedWeaponry)
techHandler:RemoveMarineTechMapTech(kTechId.AdvancedWeaponry)
techHandler:RemoveTechData(kTechId.AdvancedWeaponry)

-- Add new tech
techHandler:AddMarineResearchNode(kTechId.DemolitionsTech, kTechId.AdvancedArmory, kTechId.None, kTechId.PhaseTech)

-- Update TechMap
techHandler:AddMarineTechMapTech(kTechId.DemolitionsTech, 2.5, 6)
techHandler:AddMarineTechMapLine(kTechId.AdvancedArmory, kTechId.DemolitionsTech)

-- Add TechData entries

techHandler:AddTechData({
    [kTechDataId] = kTechId.DemolitionsTech,
    [kTechDataCostKey] = kDemolitionsTechResearchCost,
    [kTechDataResearchTimeKey] = kDemolitionsTechResearchTime,
    [kTechDataDisplayName] = "Research Demolitions",
    [kTechDataTooltipInfo] = "Allows Flamethowers and Grenade Launchers to be purchased at the Advanced Armory",
})

-- Update material offsets
techHandler:AddMaterialOffset(kTechId.DemolitionsTech, 140)
