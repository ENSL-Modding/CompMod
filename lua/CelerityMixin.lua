-- ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\CelerityMixin.lua
--
--    Created by:   Andreas Urwalek (andi@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

CelerityMixin = CreateMixin( CelerityMixin )
CelerityMixin.type = "Celerity"

CelerityMixin.networkVars =
{
    celeritySpeedScalar = "private float",
}

CelerityMixin.optionalCallbacks =
{
    ModifyCelerityBonus = "Allows children to change the amount of bonus speed you get from celerity"
}

function CelerityMixin:__initmixin()
    PROFILE("CelerityMixin:__initmixin")
    self.celeritySpeedScalar = 0
end

function CelerityMixin:ModifyMaxSpeed(maxSpeedTable)
    local celerityBonus = self.celeritySpeedScalar * kCelerityAddSpeed
    if self.ModifyCelerityBonus then
        celerityBonus = self:ModifyCelerityBonus( celerityBonus )
    end
    maxSpeedTable.maxSpeed = maxSpeedTable.maxSpeed + celerityBonus
end

if Server then
    function CelerityMixin:OnProcessMove(input)
    
        if GetHasCelerityUpgrade(self) then
            self.celeritySpeedScalar = Clamp(self:GetSpurLevel() / 3, 0, 1)
        else
            self.celeritySpeedScalar = 0
        end    
    end
end

