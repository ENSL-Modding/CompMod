-- Delete old tech nodes and update techmap
CompMod:RemoveResearch(kTechId.ShotgunTech)
CompMod:ChangeTargetedBuy(kTechId.Shotgun, kTechId.MunitionsTech, kTechId.None)
CompMod:ChangeTargetedActivation(kTechId.DropShotgun, kTechId.MunitionsTech, kTechId.None)
CompMod:DeleteMarineTechmapTech(kTechId.ShotgunTech)
CompMod:DeleteMarineTechmapLineWithTech(kTechId.Armory, kTechId.ShotgunTech)
CompMod:RemoveTech(kTechId.ShotgunTech)

CompMod:ChangeTargetedBuy(kTechId.HeavyMachineGun, kTechId.MunitionsTech)
CompMod:ChangeTargetedActivation(kTechId.DropHeavyMachineGun, kTechId.MunitionsTech)
CompMod:RemoveTech(kTechId.HeavyMachineGunTech)

CompMod:ChangeTargetedBuy(kTechId.GrenadeLauncher, kTechId.DemolitionsTech)
CompMod:ChangeTargetedActivation(kTechId.DropGrenadeLauncher, kTechId.DemolitionsTech)
CompMod:RemoveResearch(kTechId.GrenadeLauncherTech)
CompMod:RemoveTech(kTechId.GrenadeLauncherTech)

CompMod:ChangeTargetedBuy(kTechId.Flamethrower, kTechId.DemolitionsTech)
CompMod:ChangeTargetedActivation(kTechId.DropFlamethrower, kTechId.DemolitionsTech)
CompMod:DeleteMarineTechmapTech(kTechId.FlamethrowerTech)
CompMod:RemoveTech(kTechId.FlamethrowerTech)

CompMod:RemoveResearch(kTechId.AdvancedWeaponry)
CompMod:DeleteMarineTechmapTech(kTechId.AdvancedWeaponry)
CompMod:DeleteMarineTechmapLineWithTech(kTechId.AdvancedArmory, kTechId.AdvancedWeaponry)
CompMod:RemoveTech(kTechId.AdvancedWeaponry)

-- Add new tech
CompMod:AddResearchNode(kTechId.MunitionsTech, kTechId.Armory, kTechId.None, kTechId.PhaseTech)
CompMod:AddResearchNode(kTechId.DemolitionsTech, kTechId.AdvancedArmory, kTechId.None, kTechId.PhaseTech)

-- Update TechMap
CompMod:AddMarineTechmapTech(kTechId.MunitionsTech, 4, 3)
CompMod:AddMarineTechmapTech(kTechId.DemolitionsTech, 2.5, 6)
CompMod:AddMarineTechmapLineWithTech(kTechId.AdvancedArmory, kTechId.DemolitionsTech)
CompMod:AddMarineTechmapLineWithTech(kTechId.Armory, kTechId.MunitionsTech)

-- Add TechData entries
CompMod:AddTech({
    [kTechDataId] = kTechId.MunitionsTech,
    [kTechDataCostKey] = kMunitionsTechResearchCost,
    [kTechDataResearchTimeKey] = kMunitionsTechResearchTime,
    [kTechDataDisplayName] = "Research Munitions",
    [kTechDataTooltipInfo] = "Allows shotguns and heavy machine guns to be purchased at the Armory",
})

CompMod:AddTech({
    [kTechDataId] = kTechId.DemolitionsTech,
    [kTechDataCostKey] = kDemolitionsTechResearchCost,
    [kTechDataResearchTimeKey] = kDemolitionsTechResearchTime,
    [kTechDataDisplayName] = "Research Demolitions",
    [kTechDataTooltipInfo] = "Allows flamethowers and grenade launchers to be purchased at the Advanced Armory",
})

-- Update material offsets
CompMod:AddTechIdToMaterialOffset(kTechId.MunitionsTech, 85)
CompMod:AddTechIdToMaterialOffset(kTechId.DemolitionsTech, 140)

-- Change DropHeavyMachineGun to allow HMG to be dropped from armory
CompMod:ChangeTech(kTechId.DropHeavyMachineGun, {[kStructureAttachId] = { kTechId.Armory, kTechId.AdvancedArmory }})
