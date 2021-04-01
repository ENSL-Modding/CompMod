local kAlienStructureMoveSound = debug.getupvaluex(UpdateAlienStructureMove, "kAlienStructureMoveSound")
function UpdateAlienStructureMove(self, deltaTime)
    if Server then
        local currentOrder = self:GetCurrentOrder()
        if GetIsUnitActive(self) and currentOrder and currentOrder:GetType() == kTechId.Move and (not HasMixin(self, "TeleportAble") or not self:GetIsTeleporting()) then
            local speed = self:GetMaxSpeed()
            if self.shiftBoost then
                speed = speed * kShiftStructurespeedScalar
            end

            if not self:GetIsInCombat() then
                speed = speed * kAlienStructureOutOfCombatMoveScalar
            end

            self:MoveToTarget(PhysicsMask.AIMovement, currentOrder:GetLocation(), speed, deltaTime)

            if not self.distanceMoved then
                self.distanceMoved = 0
            end

            self.distanceMoved = self.distanceMoved + speed * deltaTime

            if self.distanceMoved > 1 then
                if HasMixin(self, "StaticTarget") then
                    self:StaticTargetMoved()
                end

                self.distanceMoved = 0
            end

            if self:IsTargetReached(currentOrder:GetLocation(), kAIMoveOrderCompleteDistance) then
                self:CompletedCurrentOrder()
                self.moving = false
                self.distanceMoved = 0
            else
                self.moving = true
            end
        else
            self.moving = false
            self.distanceMoved = 0
        end

        if HasMixin(self, "Obstacle") then
            if currentOrder and currentOrder:GetType() == kTechId.Move then
                self:RemoveFromMesh()

                if not self.removedMesh then
                    self.removedMesh = true
                    self:OnObstacleChanged()
                end
            elseif self.removedMesh then
                self:AddToMesh()
                self.removedMesh = false
            end
        end
    elseif Client then
        if self.clientMoving ~= self.moving then
            if self.moving then
                Shared.PlaySound(self, kAlienStructureMoveSound, 1)
            else
                Shared.StopSound(self, kAlienStructureMoveSound)
            end

            self.clientMoving = self.moving
        end

        if self.moving and (not self.timeLastDecalCreated or self.timeLastDecalCreated + 1.1 < Shared.GetTime() ) then
            self:TriggerEffects("structure_move")
            self.timeLastDecalCreated = Shared.GetTime()
        end
    end
end