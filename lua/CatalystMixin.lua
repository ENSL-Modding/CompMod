-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\CatalystMixin.lua
--
--    Created by:   Andreas Urwalek (andi@unknownworlds.com)
--
--    Used for catalyst abilities. It manages client effects and uses the stackable catalyst game
--    effect mask. GetCatalystScalar returns a value between 0.5 - 1 (0 when not catalysted).
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

CatalystMixin = CreateMixin(CatalystMixin)
CatalystMixin.type = "Catalyst"

CatalystMixin.kDefaultDuration = 10
CatalystMixin.kCatalystSpeedUp = 0.7

CatalystMixin.kEffectIntervall = 1.5
CatalystMixin.kEffectName = "catalyst"

CatalystMixin.kHealPercentage = .03
CatalystMixin.kHealInterval = 2
CatalystMixin.kHealCheckInterval = 0.25
CatalystMixin.kHealEffectInterval = 1
CatalystMixin.kMaxHealTargets = 3

CatalystMixin.optionalCallbacks = {

    OnCatalyst = "Called when catalyst is triggered.",
    OnCatalystEnd = "Called at catalyst time out."

}

CatalystMixin.networkVars = {

    isCatalysted = "boolean",
    activeHealingMistId = "entityid",

}

function CatalystMixin:__initmixin()
    
    PROFILE("CatalystMixin:__initmixin")
    
    self.maxCatalystStacks = CatalystMixin.kDefaultCatalystStacks

    if Client then

        self.isCatalystedClient = false
        self.activeHealingMistId = Entity.invalidId

    elseif Server then

        self.isCatalysted = false
        self.timeUntilCatalystEnd = 0
        self.mistIds = {}
        self.activeHealingMistId = Entity.invalidId

    end

end

function CatalystMixin:GetCatalystScalar()

    if self.isCatalysted then
        return 1
    end

    return 0

end

function CatalystMixin:GetIsCatalysted()
    return self.isCatalysted
end

local function NeedsHealing(ent)
    return ent.AmountDamaged and ent:AmountDamaged() > 0
end

function CatalystMixin:GetCanCatalyst()
    local canBeMatured = ( HasMixin(self, "Maturity") and not self:GetIsMature() )
    local canEvolveFaster = self:isa("Embryo")
    local canBeHealed = self.GetCanCatalyzeHeal and self:GetCanCatalyzeHeal() and NeedsHealing(self)

    local requiresInfestation = not self:isa("Player") and ConditionalValue(self:isa("Whip"), false, LookupTechData(self:GetTechId(), kTechDataRequiresInfestation))
    local canStopStarving = requiresInfestation and not self:GetGameEffectMask(kGameEffect.OnInfestation)
    local canPreventImmaturity = self.maturityStarvation == true

    return canBeMatured or canEvolveFaster or canBeHealed or canStopStarving or canPreventImmaturity
end

if Client then

    function CatalystMixin:UpdateCatalystClientEffects(deltaTime)

        local now = Shared.GetTime()

        local player = Client.GetLocalPlayer()

        if player and player == self and not player:GetIsThirdPerson() then
            return
        end

        if not self.timeLastCatalystEffect then
            self.timeLastCatalystEffect = now
        end

        local showEffect = not GetAreEnemies(self, player) or ( not self:isa("Player") and (not HasMixin(self, "Cloakable") or not self:GetIsCloaked()) )

        if self.timeLastCatalystEffect + CatalystMixin.kEffectIntervall < now then

            if showEffect then
                self:TriggerEffects(CatalystMixin.kEffectName)
            end

            self.timeLastCatalystEffect = now
        end
    end

end

local function SharedUpdate(self, deltaTime)
    PROFILE("CatalystMixin:OnUpdate")
    if self.isCatalysted then

        if Client then

            if self.isCatalystedClient == false then
                if self.OnCatalyst then
                    self:OnCatalyst()
                end
                self.isCatalystedClient = true
            end

            self:UpdateCatalystClientEffects(deltaTime)

        elseif Server then

            self.timeUntilCatalystEnd = self.timeUntilCatalystEnd - deltaTime

            if self.timeUntilCatalystEnd <= 0 then
                self.isCatalysted = false
            end

        end

    else
        if Client then

            if self.isCatalystedClient then
                if self.OnCatalystEnd then
                    self:OnCatalystEnd()
                end
                self.isCatalystedClient = false
            end

        end
    end
end

function CatalystMixin:OnProcessMove(input)
    SharedUpdate(self, input.time)
end

function CatalystMixin:OnUpdate(deltaTime)
    SharedUpdate(self, deltaTime)
end

function CatalystMixin:TriggerCatalyst(duration, mistId)

    if Server and self:GetCanCatalyst() then
        self.timeUntilCatalystEnd = ConditionalValue(duration ~= nil, duration, CatalystMixin.kDefaultDuration)
        self.isCatalysted = true
        table.insert(self.mistIds, mistId)
    end

end

function CatalystMixin:CopyPlayerDataFrom(player)

    if player.isCatalysted then
        self.isCatalysted = player.isCatalysted
    end

    if player.timeUntilCatalystEnd then
        self.timeUntilCatalystEnd = player.timeUntilCatalystEnd
    end

end