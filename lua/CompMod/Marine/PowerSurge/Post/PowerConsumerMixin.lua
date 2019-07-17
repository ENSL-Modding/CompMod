function PowerConsumerMixin:SetPowerSurgeDuration(duration)

    --if self:GetIsPowered() then
    --    CreateEntity( EMPBlast.kMapName, self:GetOrigin(), self:GetTeamNumber() )
    --end

    self.timePowerSurgeEnds = Shared.GetTime() + duration
    self.powerSurge = true

    --Make sure to call this after setting up the powersurge parameters!
    if self.OnPowerOn then
        self:OnPowerOn()
    end

end