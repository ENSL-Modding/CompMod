-- thx based Dragon <3
-- https://github.com/xToken/CompMod/blob/master/lua/CompMod/Weapons/Marine/Axe/shared.lua

local kAxeWebDamageVector = Vector(0.1, 0.2, 0.1)
function Axe:GetWebTraceVector()
	return kAxeWebDamageVector
end

function Axe:FirePrimary()

	local player = self:GetParent()
    if player then
        local didHit, target = AttackMeleeCapsule(self, player, kAxeDamage, self:GetRange())
        if not (didHit and target) then
			local startPoint = player:GetEyePos()
			local coords = player:GetViewAngles():GetCoords()
			local endPoint = startPoint + coords.zAxis * (self:GetRange() + 0.50)
            local boxTrace = Shared.TraceBox(self:GetWebTraceVector(), startPoint, startPoint + coords.zAxis * (0.50 + self:GetRange()), CollisionRep.Default, PhysicsMask.AllButPCsAndRagdolls, EntityFilterTwo(player, self))
            if boxTrace.entity and boxTrace.entity:isa("Web") then
                self:DoDamage(kAxeDamage, boxTrace.entity, boxTrace.endPoint, coords.zAxis, "organic", false)
            end
        end
    end

end

function Axe:OnTag(tagName)

    PROFILE("Axe:OnTag")

    if tagName == "swipe_sound" then

        local player = self:GetParent()
        if player then
            player:TriggerEffects("axe_attack")
        end

    elseif tagName == "hit" then
        self:FirePrimary()
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
