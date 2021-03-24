Script.Load("lua/CompMod/Mixins/AdrenalineRushMixin.lua")

local networkVars =
{
    -- For client animations
    healingActive = "boolean",
    healWaveActive = "boolean",
    
    moving = "boolean"
}

AddMixinNetworkVars(AdrenalineRushMixin, networkVars)

Crag.kHealPercentageLookup = {
    ["Skulk"] = 10 / kSkulkHealth,
    ["Gorge"] = 15 / kGorgeHealth,
    ["Lerk"] = 16 / kLerkHealth,
    ["Fade"] = 25 / kFadeHealth,
    ["Onos"] = 80 / kOnosHealth,
}

local oldOnCreate = Crag.OnCreate
function Crag:OnCreate()
    oldOnCreate(self)
    
    InitMixin(self, AdrenalineRushMixin)
end

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

function Crag:GetHealTargets()
    local targets = {}

    for _, healable in ipairs(GetEntitiesWithMixinForTeamWithinRange("Live", self:GetTeamNumber(), self:GetOrigin(), self:GetHealRadius())) do
        if healable:GetIsAlive() then
            table.insert(targets, healable)
        end
    end

    return targets
end

function Crag:GetHealRadius()
    local range = Crag.kHealRadius
    if self.isAdrenalineRushed then
        range = range * self.adrenalineRushLevel * kAdrenalineRushRangeScalar
    end
    Print("Crag:GetHealRadius() - %s", range)

    return range
end

Shared.LinkClassToMap("Crag", Crag.kMapName, networkVars)