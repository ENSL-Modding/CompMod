function AlienTeam:OnResetComplete()

    local commander = self:GetCommander()
    local gameInfo = GetGameInfoEntity()

    if commander then

        local commStructSkin = commander:GetCommanderStructureSkin()
        local commTunnelSkin = commander:GetCommanderTunnelSkin()

        if commStructSkin then
            self.activeStructureSkin = commStructSkin
            gameInfo:SetTeamSkin( self:GetTeamNumber(), commStructSkin )
        end

        if commTunnelSkin then
            self.activeTunnelSkin = commTunnelSkin
            gameInfo:SetTeamSkinSpecial( self:GetTeamNumber(), commTunnelSkin )
        end
    else
        gameInfo:SetTeamSkin( self:GetTeamNumber(), kDefaultAlienStructureVariant )
    end

end
