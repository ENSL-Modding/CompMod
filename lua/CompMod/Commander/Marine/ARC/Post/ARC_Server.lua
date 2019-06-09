function ARC:UpdateOrders(deltaTime)

    -- If deployed, check for targets.
    local currentOrder = self:GetCurrentOrder()

    if self:GetInAttackMode() then

        if self.targetPosition then

            local targetEntity = Shared.GetEntity(self.targetedEntity)
            if targetEntity then
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

function ARC:PerformAttack()

    local distToTarget = self.targetPosition and (self.targetPosition - self:GetOrigin()):GetLengthXZ()

    if distToTarget and distToTarget >= ARC.kMinFireRange and distToTarget <= ARC.kFireRange then

        self:TriggerEffects("arc_firing")
        -- Play big hit sound at origin

        -- don't pass triggering entity so the sound / cinematic will always be relevant for everyone
        GetEffectManager():TriggerEffects("arc_hit_primary", {effecthostcoords = Coords.GetTranslation(self.targetPosition)})

        local hitEntities = GetEntitiesWithMixinWithinRange("Live", self.targetPosition, ARC.kSplashRadius)

        -- Do damage to every target in range
        RadiusDamage(hitEntities, self.targetPosition, ARC.kSplashRadius, ARC.kAttackDamage, self, true, nil, true)

        -- Play hit effect on each
        for _, target in ipairs(hitEntities) do

            if HasMixin(target, "Effects") then
                target:TriggerEffects("arc_hit_secondary")
            end

        end

    end

    -- reset target position and acquire new target
    self.targetPosition = nil
    self.targetedEntity = Entity.invalidId

end


function ARC:OnTag(tagName)

    PROFILE("ARC:OnTag")

    if tagName == "fire_start" then
        self:PerformAttack()
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
