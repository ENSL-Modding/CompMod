function SpitSpray:GetIsAffectedByNeurotoxin()
    return self.primaryAttacking
end

function SpitSpray:GetNeurotoxinTickDamage()
    return kGorgeNeurotoxinDamage
end
