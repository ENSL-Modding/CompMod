function ARC:UpdateOrders(deltaTime)

    -- If deployed, check for targets.
    local currentOrder = self:GetCurrentOrder()

    if self:GetInAttackMode() then

        if self.targetPosition then

            local targetEntity = Shared.GetEntity(self.targetedEntity)
            if targetEntity then
                -- self.targetPosition = targetEntity:GetOrigin()
                self.targetPosition = GetTargetOrigin(targetEntity)
            end

            if self:ValidateTargetPosition(self.targetPosition) then
                self:SetTargetDirection(self.targetPosition)
            else
                self.targetPosition = nil
                self.targetedEntity = Entity.invalidId
            end

        else

            -- Check for new target every so often, but not every frame.
            local time = Shared.GetTime()
            if self.timeOfLastAcquire == nil or (time > self.timeOfLastAcquire + 0.2) then

                self:AcquireTarget()
                self.timeOfLastAcquire = time

            end

        end

    elseif currentOrder then

        self.targetPosition = nil
        self.targetedEntity = Entity.invalidId

        -- Move ARC if it has an order and it can be moved.
        local canMove = self.deployMode == ARC.kDeployMode.Undeployed
        if currentOrder:GetType() == kTechId.Move and canMove then
            self:UpdateMoveOrder(deltaTime)
        elseif currentOrder:GetType() == kTechId.ARCDeploy then
            self:Deploy()
        end

    else
        self.targetPosition = nil
        self.targetedEntity = Entity.invalidId
    end

end

function ARC:AcquireTarget()

    local finalTarget = self.targetSelector:AcquireTarget()

    if finalTarget ~= nil and self:ValidateTargetPosition(finalTarget:GetOrigin()) then

        self:SetMode(ARC.kMode.Targeting)
        self.targetPosition = GetTargetOrigin(finalTarget)
        self.targetedEntity = finalTarget:GetId()

    else

        self:SetMode(ARC.kMode.Stationary)
        self.targetPosition = nil
        self.targetedEntity = Entity.invalidId

    end

end

function ARC:OnTag(tagName)

    PROFILE("ARC:OnTag")

    if tagName == "fire_start" then
        PerformAttack(self)
    elseif tagName == "target_start" then
        self:TriggerEffects("arc_charge")
    elseif tagName == "attack_end" then
        self:SetMode(ARC.kMode.Targeting)
    elseif tagName == "deploy_start" then
        self:TriggerEffects("arc_deploying")
    elseif tagName == "undeploy_start" then
        self:TriggerEffects("arc_stop_charge")
    elseif tagName == "deploy_end" then
        if self.deployMode ~= ARC.kDeployMode.Deployed then

            -- Clear orders when deployed so new ARC attack order will be used
            self.deployMode = ARC.kDeployMode.Deployed
            self:ClearOrders()
            -- notify the target selector that we have moved.
            self.targetSelector:AttackerMoved()

            self:AdjustMaxHealth(kARCDeployedHealth)
            self.undeployedArmor = self:GetArmor()

            self:SetMaxArmor(kARCDeployedArmor)
            self:SetArmor(self.deployedArmor)

        end
    elseif tagName == "undeploy_end" then
        if self.deployMode ~= ARC.kDeployMode.Undeployed then

            self.deployMode = ARC.kDeployMode.Undeployed

            self:AdjustMaxHealth(kARCHealth)
            self.deployedArmor = self:GetArmor()

            self:SetMaxArmor(kARCArmor)
            self:SetArmor(self.undeployedArmor)
        end
    end

end
