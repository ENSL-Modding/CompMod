CompMod:RemoveResearch(kTechId.ShotgunTech)
CompMod:DeleteMarineTechmapTech(kTechId.ShotgunTech)
CompMod:RemoveTech(kTechId.ShotgunTech)

CompMod:RemoveResearch(kTechId.FlamethrowerTech)
CompMod:DeleteMarineTechmapTech(kTechId.FlamethrowerTech)
CompMod:RemoveTech(kTechId.FlamethrowerTech)

CompMod:RemoveResearch(kTechId.GrenadeLauncherTech)
CompMod:DeleteMarineTechmapTech(kTechId.GrenadeLauncherTech)
CompMod:RemoveTech(kTechId.GrenadeLauncherTech)

CompMod:RemoveResearch(kTechId.HeavyMachineGunTech)
CompMod:DeleteMarineTechmapTech(kTechId.HeavyMachineGunTech)
CompMod:RemoveTech(kTechId.HeavyMachineGunTech)

CompMod:RemoveResearch(kTechId.AdvancedWeaponry)
CompMod:DeleteMarineTechmapTech(kTechId.AdvancedWeaponry)
CompMod:RemoveTech(kTechId.AdvancedWeaponry)

CompMod:AddTech({
    [kTechDataId] = kTechId.MunitionsTech,
    [kTechDataCostKey] = kMunitionsTechResearchCost,
    [kTechDataResearchTimeKey] = kMunitionsTechResearchTime,
    [kTechDataDisplayName] = "Research Munitions",
    [kTechDataTooltipInfo] = "Allows shotguns and heavy machine guns to be purchased at the Advanced Armory",
})
CompMod:AddTechIdToMaterialOffset(kTechId.MunitionsTech, 85)

CompMod:AddTech({
    [kTechDataId] = kTechId.DemolitionsTech,
    [kTechDataCostKey] = kDemolitionsTechResearchCost,
    [kTechDataResearchTimeKey] = kDemolitionsTechResearchTime,
    [kTechDataDisplayName] = "Research Demolitions",
    [kTechDataTooltipInfo] = "Allows flamethowers and grenade launchers to be purchased at the Advanced Armory",
})
CompMod:AddTechIdToMaterialOffset(kTechId.DemolitionsTech, 140)

CompMod:ChangeTech(kTechId.Shotgun, {[kStructureAttachId] = kTechId.AdvancedArmory})
CompMod:ChangeTech(kTechId.DropShotgun, {[kStructureAttachId] = kTechId.AdvancedArmory})
