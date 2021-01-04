local TriggerBlinkInEffects = debug.getupvaluex(Blink.SetEthereal, "TriggerBlinkInEffects")
local TriggerBlinkOutEffects = debug.getupvaluex(Blink.SetEthereal, "TriggerBlinkOutEffects")
local kEtherealVerticalForce = debug.getupvaluex(Blink.SetEthereal, "kEtherealVerticalForce")
local kEtherealBoost = 0.833

kEtherealForce = 16.25
local kEtherealCelerityForcePerSpur = 0.5

function Blink:SetEthereal(player, state)
    -- Enter or leave ethereal mode.
    if player.ethereal ~= state then
        if state then
            player.etherealStartTime = Shared.GetTime()
            TriggerBlinkOutEffects(self, player)

            local playerForwardAxis = player:GetViewCoords().zAxis

            local celerityLevel = GetHasCelerityUpgrade(player) and player:GetSpurLevel() or 0
            local currentVelocityVector = player:GetVelocity()

            -- Add a speedboost to the current velocity.
            currentVelocityVector:Add(playerForwardAxis * kEtherealBoost * celerityLevel)
            -- Extract the player's velocity in the player's forward direction:
            local forwardVelocity = currentVelocityVector:DotProduct(playerForwardAxis)

            local blinkSpeed = kEtherealForce + celerityLevel * kEtherealCelerityForcePerSpur
            -- taperedVelocity is tracked so that if we're for some reason going faster than blink speed, we use that instead of
            -- slowing the player down. This allows for a skilled build up of extra speed.
            local taperedVelocity = math.max(forwardVelocity, blinkSpeed)

            local newVelocityVector = (playerForwardAxis * taperedVelocity)

            --Apply a minimum y directional speed of kEtherealVerticalForce if on the ground.
            if player:GetIsOnGround() then
                newVelocityVector.y = math.max(newVelocityVector.y, kEtherealVerticalForce)
            end

            -- There is no need to check for a max speed here, since the logic in the active blink code will keep it
            -- from exceeding the limit.
            player:SetVelocity(newVelocityVector)
            player.onGround = false
            player.jumping = true
        else
            TriggerBlinkInEffects(self, player)
            player.etherealEndTime = Shared.GetTime()
        end
        
        player.ethereal = state

        -- Give player initial velocity in direction we're pressing, or forward if not pressing anything.
        if player.ethereal then
            -- Deduct blink start energy amount.
            player:DeductAbilityEnergy(kStartBlinkEnergyCost)
            player:TriggerBlink()
        elseif player.OnBlinkEnd then
            player:OnBlinkEnd()
        end 
    end
end
