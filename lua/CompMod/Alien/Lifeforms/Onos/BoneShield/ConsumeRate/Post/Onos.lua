local oldProcessMove = Onos.OnProcessMove
function Onos:OnProcessMove(input)
    oldProcessMove(self, input)

    if self:GetIsBoneShieldActive() then
        -- we already know our active weapon is boneshield at this point
        local boneshield = self:GetActiveWeapon()
        local speedScalar =  self:GetVelocity():GetLength() / self:GetMaxSpeed()
        local movementPenalty = speedScalar * kBoneShieldMoveFuelMaxReduction
        local newFuel = boneshield:GetFuel() - movementPenalty

        boneshield:SetFuel(math.max(0, newFuel))
    end
end