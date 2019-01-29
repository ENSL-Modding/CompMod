function Hive:GetTechAllowed(techId, techNode, player)

    local allowed, canAfford = CommandStructure.GetTechAllowed(self, techId, techNode, player)

    if techId == kTechId.Consume then
        allowed = allowed and not self:GetIsOccupied()
    end

    return allowed, canAfford

end
