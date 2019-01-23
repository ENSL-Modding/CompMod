function TunnelUserMixin:OnCapsuleTraceHit(entity)
  PROFILE("TunnelUserMixin:OnCapsuleTraceHit")

  if entity and entity:isa("TunnelEntrance") or entity:isa("TunnelExit") then
    self.enableTunnelEntranceCheck = true
    self.tunnelNearby = true
  end
end

local function GetNearbyTunnelEntrance(self)
  local tunnelEntrances = GetEntitiesWithinRange("TunnelEntrance", self:GetOrigin(), 1.3)
  local tunnelExits = GetEntitiesWithinRange("TunnelExit", self:GetOrigin(), 1.3)
  if #tunnelEntrances > 0 then
    return tunnelEntrances[1]
  end

  if #tunnelExits > 0 then
    return tunnelExits[1]
  end
end

CompMod:ReplaceLocal(TunnelUserMixin.OnProcessMove, "GetNearbyTunnelEntrance", GetNearbyTunnelEntrance, true)
CompMod:ReplaceLocal(TunnelUserMixin.OnUpdate, "GetNearbyTunnelEntrance", GetNearbyTunnelEntrance, true)
CompMod:ReplaceLocal(TunnelUserMixin.SetOrigin, "GetNearbyTunnelEntrance", GetNearbyTunnelEntrance, true)
CompMod:ReplaceLocal(TunnelUserMixin.SetCoords, "GetNearbyTunnelEntrance", GetNearbyTunnelEntrance, true)
