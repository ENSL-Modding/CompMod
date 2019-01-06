function Alien:GetRecuperationRate()

    local scalar = ConditionalValue(self:GetGameEffectMask(kGameEffect.OnFire), kOnFireEnergyRecuperationScalar, 1)
    scalar = scalar * (self.electrified and kElectrifiedEnergyRecuperationScalar or 1)
    local rate = 0

    if self.hasAdrenalineUpgrade then -- re-add this because it was removed but the variable remains. spooky ns2
        rate = (( Alien.kEnergyAdrenalineRecuperationRate - Alien.kEnergyRecuperationRate) * (GetSpurLevel(self:GetTeamNumber()) / 3) + Alien.kEnergyRecuperationRate)
    else
        rate = Alien.kEnergyRecuperationRate
    end
    
    rate = rate * scalar
    return rate
    
end