-- remove stampede physics mask
CompMod:RemoveFromEnum(PhysicsMask, "OnosStampede")

-- charging onos get blocked by marines
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

CompMod:UpdateEnum(PhysicsMask, "OnosCharge", chargeMask)
