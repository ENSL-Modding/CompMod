Crag.kHealPercentageLookup = {
    ["Skulk"] = 10 / kSkulkHealth,
    ["Gorge"] = 15 / kGorgeHealth,
    ["Lerk"] = 16 / kLerkHealth,
    ["Fade"] = 25 / kFadeHealth,
    ["Onos"] = 80 / kOnosHealth,
}

-- From B336
function Crag:TryHeal(target)
    local lookup = Crag.kHealPercentageLookup[target:GetClassName()]

    local heal
    if lookup then
        heal = target:GetMaxHealth() * lookup
    else
        heal = Clamp(target:GetMaxHealth() * Crag.kHealPercentage, Crag.kMinHeal, Crag.kMaxHeal)
    end
    
    if self.healWaveActive then
        heal = heal * Crag.kHealWaveMultiplier
    end
    
    if target:GetHealthScalar() ~= 1 and (not target.timeLastCragHeal or target.timeLastCragHeal + Crag.kHealInterval <= Shared.GetTime()) then
    
        local amountHealed = target:AddHealth(heal, false, false, false, self, true)
        target.timeLastCragHeal = Shared.GetTime()
        return amountHealed
        
    else
        return 0
    end
end