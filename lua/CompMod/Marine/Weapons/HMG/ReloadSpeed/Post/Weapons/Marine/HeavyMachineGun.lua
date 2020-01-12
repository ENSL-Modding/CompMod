HeavyMachineGun.kReloadAnimationLength = 5.0 -- from art asset.
HeavyMachineGun.kReloadLength = 4.5 -- desired reload time.
local kIdleChangeThrottle = 0.25
local idleWeights =
{
    { name = "idle",  weight = 10 },
    { name = "idle2", weight = 1 },
    { name = "idle3", weight = 1 },
    { name = "idle4", weight = 3 },
}
local totalIdleWeight = 0.0
for i=1, #idleWeights do
    idleWeights[i].totalWeight = totalIdleWeight
    totalIdleWeight = totalIdleWeight + idleWeights[i].weight
end

function HeavyMachineGun:OnUpdateAnimationInput(modelMixin)

    PROFILE("HeavyMachineGun:OnUpdateAnimationInput")

    ClipWeapon.OnUpdateAnimationInput(self, modelMixin)

    -- Randomize the idle animation used, based on a set of weights.
    local now = Shared.GetTime()
    if now >= self.nextIdleChange then

        self.nextIdleChange = now + kIdleChangeThrottle

        local idleWeight = math.random() * totalIdleWeight
        for i=#idleWeights, 1, -1 do
            if idleWeight >= idleWeights[i].totalWeight then
                self.idleName = idleWeights[i].name
                break
            end
        end

    end

    modelMixin:SetAnimationInput("idleName", self.idleName)

    local reloadMultiplier = HeavyMachineGun.kReloadAnimationLength / HeavyMachineGun.kReloadLength
    if self.GetCatalystSpeedBase then
        reloadMultiplier = reloadMultiplier * self:GetCatalystSpeedBase()
    end
    local player = self:GetParent()
    if player then
        if player:GetHasCatPackBoost() then
            reloadMultiplier = reloadMultiplier * kCatPackWeaponSpeed
        end
    end

    modelMixin:SetAnimationInput("reload_mult", reloadMultiplier)

end