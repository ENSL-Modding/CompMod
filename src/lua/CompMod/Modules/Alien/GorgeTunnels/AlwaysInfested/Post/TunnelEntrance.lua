local oldInit = TunnelEntrance.OnInitialized
function TunnelEntrance:OnInitialized()
    oldInit(self)
    self:UpgradeToTechId(kTechId.InfestedTunnel)
end