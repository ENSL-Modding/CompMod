function LerkBite:GetIsAffectedByNeurotoxin()
    return self.primaryAttacking
end

function LerkBite:GetNeurotoxinTickDamage()
    return kLerkNeurotoxinDamage
end
