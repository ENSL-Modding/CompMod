PhaseGateUserMixin.OnProcessMove = nil

-- for non players
if Server then
    -- Only process the move server side, this will incur a slight delay on the client due to the poor tickrate
    function PhaseGateUserMixin:OnProcessMove(input)
        if self:GetCanPhase() then
            for _, phaseGate in ipairs(GetEntitiesForTeamWithinRange("PhaseGate", self:GetTeamNumber(), self:GetOrigin(), 0.5)) do
                if phaseGate:GetIsDeployed() and GetIsUnitActive(phaseGate) and phaseGate:Phase(self) then
                    self.timeOfLastPhase = Shared.GetTime()
                    local id = self:GetId()
                    Server.SendNetworkMessage(self:GetClient(), "OnPhase", { phaseGateId = phaseGate:GetId(), phasedEntityId = id or Entity.invalidId }, true)
                    return
                end
            end
        end

        self.phasedLastUpdate = false
    end

    -- This is never called??
    -- function PhaseGateUserMixin:OnUpdate(deltaTime)
    --     SharedUpdate(self)
    -- end
end

local kOnPhase =
{
    phaseGateId = "entityid",
    phasedEntityId = "entityid"
}
Shared.RegisterNetworkMessage("OnPhase", kOnPhase)

if Client then
    local function OnMessagePhase(message)
        PROFILE("PhaseGateUserMixin:OnMessagePhase")
        -- TODO: Is there a better way to do this?
        local phaseGate = Shared.GetEntity(message.phaseGateId)
        local phasedEnt = Shared.GetEntity(message.phasedEntityId)
        phasedEnt.timeOfLastPhaseClient = Shared.GetTime()
        phaseGate:Phase(phasedEnt)
        local viewAngles = phasedEnt:GetViewAngles()
        Client.SetYaw(viewAngles.yaw)
        Client.SetPitch(viewAngles.pitch)
    end
    Client.HookNetworkMessage("OnPhase", OnMessagePhase)
end
