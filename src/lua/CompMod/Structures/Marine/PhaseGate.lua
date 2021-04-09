local kPhaseGateTimeout = 0.6 -- 0.3

if Server then
    local GetDestinationGate = debug.getupvaluex(PhaseGate.Update, "GetDestinationGate")
    local ComputeDestinationLocationId = debug.getupvaluex(PhaseGate.Update, "ComputeDestinationLocationId")
    local DestroyRelevancyPortal = debug.getupvaluex(PhaseGate.Update, "DestroyRelevancyPortal")

    function PhaseGate:Update()
        local destinationPhaseGate = GetDestinationGate(self)

        if self.performedPhaseLastUpdate then
            self:TriggerEffects("phase_gate_player_teleport", { effecthostcoords = self:GetCoords() })

            if destinationPhaseGate ~= nil then
            --Force destination gate to trigger effect so the teleporting FX is not visible to enemy with sight on self
                local destinationCoords = Angles(0, self.targetYaw, 0):GetCoords()
                destinationCoords.origin = self.destinationEndpoint
                destinationPhaseGate:TriggerEffects("phase_gate_player_teleport", { effecthostcoords = destinationCoords })
            end

            self.performedPhaseLastUpdate = false
        end

        self.phase = (self.timeOfLastPhase ~= nil) and (Shared.GetTime() < (self.timeOfLastPhase + kPhaseGateTimeout))

        if destinationPhaseGate ~= nil and GetIsUnitActive(self) and self.deployed and destinationPhaseGate.deployed then        
            self.destinationEndpoint = destinationPhaseGate:GetOrigin()
            self.linked = true
            self.targetYaw = destinationPhaseGate:GetAngles().yaw
            self.destLocationId = ComputeDestinationLocationId(self, destinationPhaseGate)
            
            if self.relevancyPortalIndex == -1 then
                -- Create a relevancy portal to the destination to smooth out entity propagation.
                local mask = 0
                local teamNumber = self:GetTeamNumber()
                if teamNumber == 1 then
                    mask = kRelevantToTeam1Unit
                elseif teamNumber == 2 then
                    mask = kRelevantToTeam2Unit
                end
                
                if mask ~= 0 then
                    self.relevancyPortalIndex = Server.CreateRelevancyPortal(self:GetOrigin(), self.destinationEndpoint, mask, self.kRelevancyPortalRadius)
                end
            end
        else
            self.linked = false
            self.targetYaw = 0
            self.destLocationId = Entity.invalidId
            
            DestroyRelevancyPortal(self)
        end

        return true 
    end
end