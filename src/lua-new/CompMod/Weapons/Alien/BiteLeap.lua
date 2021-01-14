kBiteLeapWidth = 0.8
kBiteLeapHeight = 1.2

function BiteLeap:GetMeleeBase()
    -- width, height
    return kBiteLeapWidth, kBiteLeapHeight
end

function BiteLeap:GetIsAffectedByNeurotoxin()
    return self.primaryAttacking
end

function BiteLeap:GetNeurotoxinTickDamage()
    return kSkulkNeurotoxinDamage
end

