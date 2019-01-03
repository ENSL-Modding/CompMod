-- move boneshield requirement to bio4
PhoneMod:ChangeResearch(kTechId.BoneShield, kTechId.BioMassFour, kTechId.None, kTechId.AllAliens)

-- update techtree
PhoneMod:ChangeAlienTechmapTech(kTechId.BoneShield, 6, 9)

-- remove stampede physics mask
PhoneMod:DeleteFromEnum(PhysicsMask, "OnosStampede")

-- charging onos get blocked by marines again
local chargeMask = CreateMaskExcludingGroups(PhysicsGroup.WhipGroup,
                                       PhysicsGroup.SmallStructuresGroup,
                                       PhysicsGroup.MediumStructuresGroup,
                                       PhysicsGroup.RagdollGroup,
                                       PhysicsGroup.PlayerGroup,
                                       PhysicsGroup.PlayerControllersGroup,
                                       PhysicsGroup.BabblerGroup,
                                       PhysicsGroup.ProjectileGroup,
                                       PhysicsGroup.WeaponGroup,
                                       PhysicsGroup.DroppedWeaponGroup,
                                       PhysicsGroup.CommanderBuildGroup,
                                       PhysicsGroup.PathingGroup,
                                       PhysicsGroup.WebsGroup)

PhoneMod:UpdateEnum(PhysicsMask, "OnosCharge", chargeMask)
