function StabBlink:GetIsAffectedByNeurotoxin()
    return self.primaryAttacking
end

function StabBlink:GetNeurotoxinTickDamage()
    return kFadeNeurotoxinDamage
end
