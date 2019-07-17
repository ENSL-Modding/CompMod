-- embryo hp depends on lifeform

local kMinGestationTime = CompMod:GetLocalVariable(Embryo.SetGestationData, "kMinGestationTime")

function Embryo:SetGestationData(techIds, previousTechId, healthScalar, armorScalar)

    -- Save upgrades so they can be given when spawned
    self.evolvingUpgrades = {}
    table.copy(techIds, self.evolvingUpgrades)

    self.gestationClass = nil

    for i, techId in ipairs(techIds) do
        self.gestationClass = LookupTechData(techId, kTechDataGestateName)
        if self.gestationClass then
            -- Remove gestation tech id from "upgrades"
            self.gestationTypeTechId = techId
            table.removevalue(self.evolvingUpgrades, self.gestationTypeTechId)
            break
        end
    end

    -- Upgrades don't have a gestate name, we want to gestate back into the
    -- current alien type, previousTechId.
    if not self.gestationClass then
        self.gestationTypeTechId = previousTechId
        self.gestationClass = LookupTechData(previousTechId, kTechDataGestateName)
    end
    self.gestationStartTime = Shared.GetTime()

    local lifeformTime = ConditionalValue(self.gestationTypeTechId ~= previousTechId, self:GetGestationTime(self.gestationTypeTechId), 0)

    local newUpgradesAmount = 0
    local currentUpgrades = self:GetUpgrades()

    for _, upgradeId in ipairs(self.evolvingUpgrades) do

        if not table.icontains(currentUpgrades, upgradeId) then
            newUpgradesAmount = newUpgradesAmount + 1
        end

    end

    self.gestationTime = ConditionalValue(Shared.GetDevMode() or GetGameInfoEntity():GetWarmUpActive(), 1, lifeformTime + newUpgradesAmount * kUpgradeGestationTime)

    self.gestationTime = math.max(kMinGestationTime, self.gestationTime)

    if Embryo.gFastEvolveCheat then
        self.gestationTime = 5
    end

    self.evolveTime = 0

    local maxHealth = LookupTechData(self.gestationTypeTechId, kTechDataMaxHealth) * 0.3 + 100
    maxHealth = math.round(maxHealth * 0.1) * 10

    self.storedHealthScalar = healthScalar
    self.storedArmorScalar = armorScalar

    self:SetMaxHealth(maxHealth)
    self:SetHealth(maxHealth * healthScalar)
    self:SetMaxArmor(0)
    self:SetArmor(0)

    -- we reset the upgrades entirely and set them again, simplifies the code
    self:ClearUpgrades()

end
