--[[
    Fade base reverted to Nostalgia movement

    Blink speed without celerity increased to match speed with 1.25 spurs, speed gained through spurs lowered to compensate
]]

local TriggerBlinkOutEffects = debug.getupvaluex(Blink.SetEthereal, "TriggerBlinkOutEffects", false)
local TriggerBlinkInEffects = debug.getupvaluex(Blink.SetEthereal, "TriggerBlinkInEffects", false)
local kEtherealVerticalForce = debug.getupvaluex(Blink.SetEthereal, "kEtherealVerticalForce", false)

local kEtherealForce = 13.5
local kBlinkAddForce = 2
local kSpeedPerSpur = 0.5
local kAddForcePerSpur = 0.1

-- TODO:
-- We're iterating a lot on this at the moment, it's faster to have a variable controlling the base spur speed instead of recalculating all variables
-- After we've settled on a speed we like, these calculations should be removed. kEtherealForce and kBlinkAddForce should be recalculated to apply
-- these changes and the code changed to reflect it
local baseSpur = 1.25
local kAdjustedSpeedPerSpur = (kSpeedPerSpur * (3 - baseSpur)) / 3
local kEtherealForceAdditional = (kSpeedPerSpur * 3) - (kAdjustedSpeedPerSpur * 3)

local kAdjustedAddForcePerSpur = (kAddForcePerSpur * (3 - baseSpur)) / 3
local kBlinkAddForceAdditional = (kAddForcePerSpur * 3) - (kAdjustedAddForcePerSpur * 3)

function Blink:SetEthereal(player, state)
    if player.ethereal ~= state then
        if state then
            player.etherealStartTime = Shared.GetTime()
            TriggerBlinkOutEffects(self, player)

            local celerityLevel = GetHasCelerityUpgrade(player) and player:GetSpurLevel() or 0
            local oldSpeed = player:GetVelocity():GetLengthXZ()
            local oldVelocity = player:GetVelocity()
            oldVelocity.y = 0

            local blinkSpeed = kEtherealForce + kEtherealForceAdditional + celerityLevel * kAdjustedSpeedPerSpur

            local newSpeed = math.max(oldSpeed, blinkSpeed)

            local celerityMultiplier = 1.0 + kBlinkAddForceAdditional + celerityLevel * kAdjustedAddForcePerSpur

            local newVelocity = player:GetViewCoords().zAxis * blinkSpeed + oldVelocity
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
