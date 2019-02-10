local oldKilled = NS2Gamerules.OnEntityKilled
function NS2Gamerules:OnEntityKilled(targetEntity, attacker, doer, point, direction)
  if not targetEntity:isa("Web") then
    oldKilled(self, targetEntity, attacker, doer, point, direction)
  end
end
