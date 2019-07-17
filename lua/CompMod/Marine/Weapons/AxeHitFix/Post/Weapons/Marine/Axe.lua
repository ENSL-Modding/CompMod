function Axe:OnTag(tagName)

    PROFILE("Axe:OnTag")

    if tagName == "swipe_sound" then

        local player = self:GetParent()
        if player then
            player:TriggerEffects("axe_attack")
        end

    elseif tagName == "hit" then

        local player = self:GetParent()
        local coords = player:GetViewAngles():GetCoords()
        local didHit, target = AttackMeleeCapsule(self, player, kAxeDamage, self:GetRange())

        if not (didHit and target) and coords then -- Only for webs
            self:Axe_HitCheck(coords)
        end

    elseif tagName == "attack_end" then
        self.sprintAllowed = true
    elseif tagName == "deploy_end" then
        self.sprintAllowed = true
    elseif tagName == "idle_toss_start" then
        self:TriggerEffects("axe_idle_toss")
    elseif tagName == "idle_fiddle_start" then
        self:TriggerEffects("axe_idle_fiddle")
    end

end

function Axe:Axe_HitCheck(coords)
    local player = self:GetParent()
    if player and player:GetIsAlive() then

        local boxTrace = Shared.TraceBox(Vector(0.07,0.07,0.07),
                player:GetEyePos(),
                player:GetEyePos() + coords.zAxis * (0.50 + self:GetRange()),
                CollisionRep.Default, PhysicsMask.AllButPCsAndRagdolls,
                EntityFilterTwo(player, self))
        -- Log("Boxtrace entity: %s, target: %s", boxTrace.entity, target)
        if boxTrace.entity and boxTrace.entity:isa("Web") then
            self:DoDamage(kAxeDamage, boxTrace.entity, boxTrace.endPoint, coords.zAxis, "organic", false)
        else
            -- local rayTrace = Shared.TraceRay(eyePos, targetOrigin, CollisionRep.LOS, PhysicsMask.All, EntityFilterAll())
            local rayTrace = Shared.TraceRay(player:GetEyePos(), player:GetEyePos() + coords.zAxis * (0.50 + self:GetRange()), CollisionRep.Default, PhysicsMask.AllButPCsAndRagdolls, EntityFilterTwo(player, self))
            -- Log("Raytrace entity: %s", rayTrace.entity)
            if rayTrace.entity and rayTrace.entity:isa("Web") then
                self:DoDamage(kAxeDamage, boxTrace.entity, boxTrace.endPoint, coords.zAxis, "organic", false)
            end
        end

    end
end