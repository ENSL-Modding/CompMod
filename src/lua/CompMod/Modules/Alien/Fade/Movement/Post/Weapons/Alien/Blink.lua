kEtherealForce = 13.5

local kBlinkAddForce = 2
local TriggerBlinkOutEffects = debug.getupvaluex(Blink.SetEthereal, "TriggerBlinkOutEffects", false)
local TriggerBlinkInEffects = debug.getupvaluex(Blink.SetEthereal, "TriggerBlinkInEffects", false)
local kEtherealVerticalForce = debug.getupvaluex(Blink.SetEthereal, "kEtherealVerticalForce", false)

function Blink:SetEthereal(player, state)
    if player.ethereal ~= state then
        if state then
            player.etherealStartTime = Shared.GetTime()
            TriggerBlinkOutEffects(self, player)

            local celerityLevel = GetHasCelerityUpgrade(player) and player:GetSpurLevel() or 0
            local oldSpeed = player:GetVelocity():GetLengthXZ()
            local oldVelocity = player:GetVelocity()
            oldVelocity.y = 0

            local newSpeed = math.max(oldSpeed, kEtherealForce + celerityLevel * 0.5)

            local celerityMultiplier = 1 + celerityLevel * 0.10

            local newVelocity = player:GetViewCoords().zAxis * (kEtherealForce + celerityLevel * 0.5) + oldVelocity
            if newVelocity:GetLength() > newSpeed then
                newVelocity:Scale(newSpeed / newVelocity:GetLength())
            end

            if player:GetIsOnGround() then
                newVelocity.y = math.max(newVelocity.y, kEtherealVerticalForce)
            end

            newVelocity:Add(player:GetViewCoords().zAxis * kBlinkAddForce * celerityMultiplier)

            player:SetVelocity(newVelocity)
            player.onGround = false
            player.jumping = true
        else
            TriggerBlinkInEffects(self, player)
            player.etherealEndTime = Shared.GetTime()
        end

        player.ethereal = state

        if player.ethereal then
            player:DeductAbilityEnergy(kStartBlinkEnergyCost)
            player:TriggerBlink()
        elseif player.OnBlinkEnd then
            player:OnBlinkEnd()
        end
    end
end
