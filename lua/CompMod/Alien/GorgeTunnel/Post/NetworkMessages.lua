local kGorgeBuildStructureMessage = Shared.GetNetworkMessageDefinition("GorgeBuildStructure")
kGorgeBuildStructureMessage.structureIndex = "integer (1 to 6)"
Shared.RegisterNetworkMessage("GorgeBuildStructure", kGorgeBuildStructureMessage)
