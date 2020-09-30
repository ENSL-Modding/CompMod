local TriggerBlinkOutEffects = debug.getupvaluex(Blink.SetEthereal, "TriggerBlinkOutEffects")
local TriggerBlinkInEffects = debug.getupvaluex(Blink.SetEthereal, "TriggerBlinkInEffects")
local kEtherealVerticalForce = debug.getupvaluex(Blink.SetEthereal, "kEtherealVerticalForce")
-- Additional force for initial blink speed with celerity
kEtherealCelerityForcePerSpur = 0.2 -- 0.5
-- Additianal force for blink stacking speed with celerity
kBlinkAddCelerityForcePerSpur = 0.05

-- Speed of first blink
kBlinkSpeed = 15

-- Speed after subsequent blinks
kBlinkAddForce = 2.5

-- Minimum speed gained from blink
kBlinkMinSpeed = 15

-- Force of first blink before blink stack
kEtherealForce = kBlinkSpeed - kBlinkAddForce
kEtherealForceMin = kBlinkMinSpeed - kBlinkAddForce

function Blink:SetEthereal(player, state)
    -- Enter or leave ethereal mode.
    if player.ethereal ~= state then
        if state then
            player.etherealStartTime = Shared.GetTime()
            TriggerBlinkOutEffects(self, player)

            local playerForwardAxis = player:GetViewCoords().zAxis

            local celerityLevel = GetHasCelerityUpgrade(player) and player:GetSpurLevel() or 0
            local currentVelocityVector = player:GetVelocity()
            local forwardVelocity = currentVelocityVector:GetLengthXZ()
            -- Since we're applying this vector to the new one, we should zero out y otherwise we'll start floating from jumps and things
            currentVelocityVector.y = 0

            local blinkSpeed = kEtherealForce + celerityLevel * kEtherealCelerityForcePerSpur
            local minBlinkSpeed = kEtherealForceMin + celerityLevel * kEtherealCelerityForcePerSpur
            -- taperedVelocity is tracked so that if we're for some reason going faster than blink speed, we use that instead of
            -- slowing the player down. This allows for a skilled build up of extra speed.
            local taperedVelocity = math.max(forwardVelocity, blinkSpeed)

            local newVelocityVector = playerForwardAxis * blinkSpeed + currentVelocityVector
            -- Ensure we don't exceed our target blink speed
            if newVelocityVector:GetLength() > taperedVelocity then
                newVelocityVector:Scale(taperedVelocity / newVelocityVector:GetLength())
            end

            -- Ensure we don't go under our minimum blink speed (this can happen when blinking against our velocity vector)
            if newVelocityVector:GetLengthXZ() < minBlinkSpeed then
                newVelocityVector:Scale(minBlinkSpeed / newVelocityVector:GetLength())
            end

            --Apply a minimum y directional speed of kEtherealVerticalForce if on the ground.
            if player:GetIsOnGround() then
                newVelocityVector.y = math.max(newVelocityVector.y, kEtherealVerticalForce)
            end

            newVelocityVector:Add(playerForwardAxis * kBlinkAddForce * (1 + celerityLevel * kBlinkAddCelerityForcePerSpur))

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