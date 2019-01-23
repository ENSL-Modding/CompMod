DropStructureAbility.kSupportedStructures = { HydraStructureAbility, ClogAbility, WebsAbility, BabblerEggAbility, GorgeTunnelEntranceAbility, GorgeTunnelExitAbility }

local originalOnCreate = DropStructureAbility.OnCreate
function DropStructureAbility:OnCreate(sef)
  originalOnCreate(self)
  self.numEntrancesLeft = 0
  self.numExitsLeft = 0
end

local originalGetNumStructuresBuilt = DropStructureAbility.GetNumStructuresBuilt
function DropStructureAbility:GetNumStructuresBuilt(techId)
  if techId == kTechId.GorgeTunnel then
    return self.numEntrancesLeft
  end

  if techId == kTechId.GorgeTunnelExit then
    return self.numExitsLeft
  end

  return originalGetNumStructuresBuilt(self, techId)
end

local originalProcessMoveOnWeapon = DropStructureAbility.ProcessMoveOnWeapon
function DropStructureAbility:ProcessMoveOnWeapon(input)
  originalProcessMoveOnWeapon(self, input)
  local player = self:GetParent()
  if player then

    if Server then

      local team = player:GetTeam()
      local numAllowedEntrances = LookupTechData(kTechId.GorgeTunnel, kTechDataMaxAmount, -1)
      local numAllowedExits = LookupTechData(kTechId.GorgeTunnelExit, kTechDataMaxAmount, -1)

      if numAllowedEntrances >= 0 then
          self.numEntrancesLeft = team:GetNumDroppedGorgeStructures(player, kTechId.GorgeTunnel)
      end

      if numAllowedExits >= 0 then
          self.numExitsLeft = team:GetNumDroppedGorgeStructures(player, kTechId.GorgeTunnelExit)
      end

    end

  end
end

Shared.LinkClassToMap("DropStructureAbility", nil, {numEntrancesLeft = "private integer (0 to 20)", numExitsLeft = "private integer (0 to 20)"})
