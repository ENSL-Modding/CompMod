local kNanoShieldPlayerDuration = 4
local kNanoShieldStructureDuration = kNanoShieldDuration

local function GetNanoShieldTimeRemaining(self)
    local percentLeft = 0

    if self.nanoShielded then
        if self:isa("Player") then
            percentLeft = Clamp( (self.timeNanoShieldInit + kNanoShieldPlayerDuration - Shared.GetTime() ) / kNanoShieldDuration, 0.0, 1.0 )
        else
            percentLeft = Clamp( (self.timeNanoShieldInit + kNanoShieldStructureDuration - Shared.GetTime() ) / kNanoShieldDuration, 0.0, 1.0 )
        end
    end

    return percentLeft
end

local function UpdateClientNanoShieldEffects(self)

    assert(Client)

    if self:GetIsNanoShielded() and self:GetIsAlive() then
        self:_CreateEffect()
    else
        self:_RemoveEffect()
    end

end

local function ClearNanoShield(self, destroySound)

    self.nanoShielded = false
    self.timeNanoShieldInit = 0

    if Client then
        self:_RemoveEffect()
    end

    if Server and self.shieldLoopSound and destroySound then
        DestroyEntity(self.shieldLoopSound)
    end

    self.shieldLoopSound = nil

end

local function SharedUpdate(self)

    if Server then

        if not self:GetIsNanoShielded() then
            return
        end

        -- See if nano shield time is over
        if GetNanoShieldTimeRemaining(self) == 0.0 then
            ClearNanoShield(self, true)
        end

    elseif Client and not Shared.GetIsRunningPrediction() then
        UpdateClientNanoShieldEffects(self)
    end

end

function NanoShieldMixin:OnUpdate(deltaTime)
    SharedUpdate(self)
end

function NanoShieldMixin:OnProcessMove(input)
    SharedUpdate(self)
end
