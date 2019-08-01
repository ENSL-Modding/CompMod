-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\BabblerClingMixin.lua
--
--    Created by:   Andreas Urwalek (andi@unknownworlds.com)
--
--    Handles babblers attaching to units.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

-- TODO: create better effect
PrecacheAsset("cinematics/vfx_materials/parasited.surface_shader")
local kMaterialName = PrecacheAsset("cinematics/vfx_materials/parasited.material")

BabblerClingMixin = CreateMixin(BabblerClingMixin)
BabblerClingMixin.type = "BabblerCling"

BabblerClingMixin.expectedMixins =
{
}

local kBabblerAttachPoints =
{
    "babbler_attach1",
    "babbler_attach2",
    "babbler_attach3",
    "babbler_attach4",
    "babbler_attach5",
    "babbler_attach6",
}

local kMaxShield = kBabblerShieldMaxAmount
BabblerClingMixin.networkVars =
{
    numBabblers = "integer (0 to 6)",
    babblerShieldRemaining = string.format("float (0 to %f by 0.0625)", kMaxShield)
}

function BabblerClingMixin:__initmixin()
    
    PROFILE("BabblerClingMixin:__initmixin")
    
    self.attachedBabblers = {}
    self.freeAttachPoints = {}
    table.copy(kBabblerAttachPoints, self.freeAttachPoints)

    self.babblerShieldRemaining = 0

    local babblerShieldPercent = self.GetBabblerShieldPercentage and self:GetBabblerShieldPercentage() or kBabblerShieldPercent
    self.babblerShieldMaxAmount = math.min(math.round(self:GetBaseHealth() * babblerShieldPercent), kMaxShield)
    self.babblerShieldPerBabbler = self.babblerShieldMaxAmount / #kBabblerAttachPoints
end

function BabblerClingMixin:GetNumClingedBabblers()
    return self.numBabblers
end

function BabblerClingMixin:GetCanAttachBabbler()
    local numClingedBabbler = self:GetNumClingedBabblers()
    local numAttachPoints = #kBabblerAttachPoints

    if HasMixin(self, "BabblerOwner") then
        return self:GetBabblerCount() < self:GetMaxBabblers() and numClingedBabbler < numAttachPoints
    end

    return numClingedBabbler < numAttachPoints
end

function BabblerClingMixin:ModifyDamageTaken(damageTable, attacker, _, damageType, hitPoint, weapon)
    local damage = damageTable.damage or 0
    if damage > 0 and self:GetApplyBabblerShield(damageType) then
        local amount = math.min(damage, self.babblerShieldRemaining)

        if Server then
            self.babblerShieldRemaining = self.babblerShieldRemaining - amount
            self:DestroyNumClingedBabbler(math.floor((self.numBabblers * self.babblerShieldPerBabbler - self.babblerShieldRemaining) / self.babblerShieldPerBabbler ))

            if HitSound_IsEnabledForWeapon( weapon ) then
                -- Damage message will be sent at the end of OnProcessMove by the HitSound system
                HitSound_RecordHit( attacker, self, amount, hitPoint, 0, weapon )
            else
                SendDamageMessage( attacker, self, amount, hitPoint, 0, weapon )
            end

            SendMarkEnemyMessage( attacker, self, amount, weapon )
        end

        damageTable.damage = damage - amount
    end
end

local kBabblerShieldIgnoreDamageTypes = {
    [kDamageType.NerveGas] = true,
    [kDamageType.Corrode] = true,
    [kDamageType.ArmorOnly] = true
}
function BabblerClingMixin:GetApplyBabblerShield(damageType)
    return self:GetHasBabblerShield() and not kBabblerShieldIgnoreDamageTypes[damageType]
end

function BabblerClingMixin:GetHasBabblerShield()
    return self.numBabblers > 0
end

function BabblerClingMixin:GetBabblerShieldAmount()
    return self.babblerShieldRemaining
end

function BabblerClingMixin:GetMaxBabblerShieldAmount()
    return self.babblerShieldMaxAmount
end

if Server then

    function BabblerClingMixin:AttachBabbler(babbler)

        if not self:GetIsAlive() then return false end

        local freeAttachPoint = #self.freeAttachPoints > 0 and table.remove(self.freeAttachPoints)
        if freeAttachPoint then

            self.attachedBabblers[babbler:GetId()] = freeAttachPoint
            self.numBabblers = self.numBabblers + 1
            self.babblerShieldRemaining = self.babblerShieldRemaining + self.babblerShieldPerBabbler

            babbler:SetParent(self)
            babbler:SetOwner(self)
            babbler:SetAttachPoint(freeAttachPoint)
            babbler:DestroyHitbox()

            return true

        end

        return false

    end

    function BabblerClingMixin:DetachBabbler(babbler)

        local babblerId = babbler:GetId()
        local usedAttachPoint = self.attachedBabblers[babblerId]

        if usedAttachPoint then
            table.insert(self.freeAttachPoints, usedAttachPoint)
            local origin = self:GetAttachPointOrigin(usedAttachPoint)
            if origin then
                babbler:SetOrigin(origin)
            end

            self.numBabblers = self.numBabblers - 1
            self.babblerShieldRemaining = math.min(self.babblerShieldRemaining, self.numBabblers * self.babblerShieldPerBabbler)
        end

        self.attachedBabblers[babblerId] = nil
        babbler:SetParent(nil)

    end

    function BabblerClingMixin:DestroyNumClingedBabbler(num)
        if num == 0 then return end

        local babblers = GetChildEntities(self, "Babbler")
        num = math.min(#babblers, num)

        for i = 1, num do
            local babbler = babblers[i]
            babbler:Kill()
        end
    end

    function BabblerClingMixin:DestroyAllClingedBabbler()
        local babblers = GetChildEntities(self, "Babbler")

        for i = 1, #babblers do
            local babbler = babblers[i]
            babbler:Kill()
        end
    end

    function BabblerClingMixin:DetachAll()

        local babblers = GetChildEntities(self, "Babbler")
        for i = 1, #babblers do
            local babbler = babblers[i]

            babbler:Detach()
        end

        self.attachedBabblers = {}
        self.numBabblers = 0
        self.babblerShieldRemaining = 0

    end

    function BabblerClingMixin:OnKill()
        self:DestroyAllClingedBabbler()
    end

    function BabblerClingMixin:Reset()
        self:DestroyAllClingedBabbler()
    end

    function BabblerClingMixin:TriggerCloak()
        local babblers = GetChildEntities(self, "Babbler")
        for i = 1, #babblers do
            local babbler = babblers[i]
            babbler:TriggerCloak()
        end
    end

    function BabblerClingMixin:TriggerUncloak()
        local babblers = GetChildEntities(self, "Babbler")
        for i = 1, #babblers do
            local babbler = babblers[i]
            babbler:TriggerUncloak()
        end
    end

    function BabblerClingMixin:GetFreeBabblerAttachPointOrigin()

        local freeAttachPoint = #self.freeAttachPoints > 0 and self.freeAttachPoints[1]
        if freeAttachPoint then
            return self:GetAttachPointOrigin(freeAttachPoint)
        end

    end

end