function BoneShield:OnPrimaryAttack(player)
    if not self.primaryAttacking then
        if player:GetIsOnGround() and self:GetCanUseBoneShield(player) then
            self:SetFuel( self:GetFuel() - kBoneShieldInitialFuelCost ) -- set it now, because it will go down from this point
            self.primaryAttacking = true

            if Server then
                player:TriggerEffects("onos_shield_start")
            end
        end
    end
end
