-- ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\DissolveMixin.lua
--
--    Created by:   Max McGuire (max@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

kDissolveSpeed = 2.25
kDissolveDelay = 0

DissolveMixin = CreateMixin(DissolveMixin)
DissolveMixin.type = "Dissolve"

DissolveMixin.expectedMixins =
{
    Live = "Needed for GetIsAlive().",
    Model = "Needed for effects"
}

DissolveMixin.networkVars =
{
    dissolveStart = "time"
}


function DissolveMixin:__initmixin()
    
    PROFILE("DissolveMixin:__initmixin")
    
    self.dissolveStart = 0
    self.dissolveAmount = 0
end

function DissolveMixin:OnKill()

    -- Start the dissolve effect
    local now = Shared.GetTime()
    self.dissolveStart = now + kDissolveDelay
    
    --self:InstanceMaterials()

end

function DissolveMixin:OnUpdateRender()
    
    PROFILE("DissolveMixin:OnUpdateRender")
    
    if self.dissolveStart ~= 0 then
        
        if self.dissolveAmount < 1 then
            local now = Shared.GetTime()
            local t = (now - self.dissolveStart) / kDissolveSpeed
            self.dissolveAmount = Clamp( 1 - (1-t)^3, 0.0, 1.0 )
        end
        
        self:SetOpacity( 1 - self.dissolveAmount, "dissolve" )
    
    end
    
end