CompMod:AppendToEnum(kMinimapBlipType, "TunnelExit")

CompMod:AddTechIdToMaterialOffset(kTechId.GorgeTunnelExit, 103)

CompMod:AddBuildNode(kTechId.GorgeTunnelExit)

CompMod:AddTech({
  [kTechDataId] = kTechId.GorgeTunnelExit,
  [kTechDataCategory] = kTechId.Gorge,
  [kTechDataMaxExtents] = Vector(1.2, 1.2, 1.2),
  [kTechDataTooltipInfo] = "GORGE_TUNNEL_TOOLTIP",
  [kTechDataGhostModelClass] = "AlienGhostModel",
  [kTechDataAllowConsumeDrop] = true,
  [kTechDataAllowStacking] = false,
  [kTechDataMaxAmount] = 1,
  [kTechDataMapName] = TunnelExit.kMapName,
  [kTechDataDisplayName] = "Tunnel Exit",
  [kTechDataHint] = "TUNNEL_ENTRANCE_HINT",
  [kTechDataCostKey] = kGorgeTunnelCost,
  [kTechDataMaxHealth] = kTunnelEntranceHealth,
  [kTechDataMaxArmor] = kTunnelEntranceArmor,
  [kTechDataBuildTime] = kGorgeTunnelBuildTime,
  [kTechDataModel] = TunnelExit.kModelName,
  [kTechDataRequiresInfestation] = false,
  [kTechDataPointValue] = kTunnelEntrancePointValue,
})

CompMod:ChangeTech(kTechId.GorgeTunnel, {
  [kTechDataMaxAmount] = 1,
  [kTechDataDisplayName] = "Tunnel Entrance"
})
