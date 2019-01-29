local oldGetCurrentTechButtons = Commander.GetCurrentTechButtons
function Commander:GetCurrentTechButtons(techId, entity)
  local techButtons = oldGetCurrentTechButtons(self, techId, entity)

  if not self:GetIsInQuickMenu(techId) and entity then
    if entity:GetTeamNumber() == self:GetTeamNumber() then
      if techId == kTechId.RootMenu then
        local researchMode = (HasMixin(entity, "Research") and entity:GetIsResearching()) or (HasMixin(entity, "GhostStructure") and entity:GetIsGhostStructure())

        if not researchMode and HasMixin(entity, "Consume") and not entity:GetIsResearching() and entity:GetCanConsume() and not entity:GetIsConsumed() then
          techButtons[kRecycleCancelButtonIndex] = kTechId.Consume
        end
      end
    end
  end

  return techButtons
end
