local GetAttachDestination = debug.getupvaluex(TeleportMixin.OnUpdate, "GetAttachDestination", GetAttachDestination, true)
local AddObstacle = debug.getupvaluex(TeleportMixin.OnUpdate, "AddObstacle", AddObstacle, true)

local function PerformTeleport(self)
    local destinationEntity = Shared.GetEntity(self.destinationEntityId)
    
    if destinationEntity then
        local destinationCoords
        local attachTo = LookupTechData(self:GetTechId(), kStructureAttachClass, nil)
        
        -- find a free attach entity
        if attachTo then
            destinationCoords = GetAttachDestination(self, attachTo, self.destinationPos)
        else
            destinationCoords = Coords.GetTranslation(self.destinationPos)
        end
        
        if destinationCoords then
            if HasMixin(self, "Obstacle") then
                self:RemoveFromMesh()
            end
        
            self:SetCoords(destinationCoords)

            -- Fix model coords not updating until next think
            self:UpdateModelCoords()

            if HasMixin(self, "Obstacle") then
                -- this needs to be delayed, otherwise the obstacle is created too early and stacked up structures would not be able to push each other away
                self:AddTimedCallback(AddObstacle, 3)
            end
            
            local location = GetLocationForPoint(self:GetOrigin())
            local locationName = location and location:GetName() or ""
            
            self:SetLocationName(locationName, true)
            
            self:TriggerEffects("teleport_end", { classname = self:GetClassName() })
            
            if self.OnTeleportEnd then
                self:OnTeleportEnd(destinationEntity)
            end
            
            if HasMixin(self, "StaticTarget") then
                self:StaticTargetMoved()
            end

        else
            -- teleport has failed, give back resources to shift
            if destinationEntity then
                destinationEntity:GetTeam():AddTeamResources(self.teleportCost)
            end

            if self.OnTeleportFailed then
                self:OnTeleportFailed()
            end
        end
    end
    
    self.destinationEntityId = Entity.invalidId
    self.isTeleporting = false
    self.timeUntilPort = 0
    self.teleportDelay = 0
end 

debug.setupvaluex(TeleportMixin.OnUpdate, "PerformTeleport", PerformTeleport, true)
