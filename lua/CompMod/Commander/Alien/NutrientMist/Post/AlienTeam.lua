-- update every tick but only a small amount of structures
function AlienTeam:UpdateTeamAutoHeal(timePassed)

    PROFILE("AlienTeam:UpdateTeamAutoHeal")

    local time = Shared.GetTime()

    if self.timeOfLastAutoHeal == nil then
        self.timeOfLastAutoHeal = Shared.GetTime()
    end

    if time > (self.timeOfLastAutoHeal + AlienTeam.kStructureAutoHealInterval) then

        local intervalLength = time - self.timeOfLastAutoHeal
        local gameEnts = GetEntitiesWithMixinForTeam("InfestationTracker", self:GetTeamNumber())
        local numEnts = table.icount(gameEnts)
        local toIndex = self.lastAutoHealIndex + AlienTeam.kAutoHealUpdateNum - 1
        toIndex = ConditionalValue(toIndex <= numEnts , toIndex, numEnts)
        for index = self.lastAutoHealIndex, toIndex do

            local entity = gameEnts[index]

            -- players update the auto heal on their own
            if not entity:isa("Player") then

                -- we add whips as an exception here. construction should still be restricted to onInfestation, we only don't want whips to take damage off infestation
                local requiresInfestation   = ConditionalValue(entity:isa("Whip"), false, LookupTechData(entity:GetTechId(), kTechDataRequiresInfestation))
                local isOnInfestation       = entity:GetGameEffectMask(kGameEffect.OnInfestation)
                local isHealable            = entity:GetIsHealable()
                local deltaTime             = 0
                local beingCatalyzed        = HasMixin(entity, "Catalyst") and entity:GetIsCatalysted()

                if not entity.timeLastAutoHeal then
                    entity.timeLastAutoHeal = Shared.GetTime()
                else
                    deltaTime = Shared.GetTime() - entity.timeLastAutoHeal
                    entity.timeLastAutoHeal = Shared.GetTime()
                end

                if requiresInfestation and not isOnInfestation and (not beingCatalyzed or entity:isa("Harvester")) then -- make harvesters take dmg when not on infestation, even when misted

                    -- Take damage!
                    local damage = entity:GetMaxHealth() * kBalanceInfestationHurtPercentPerSecond/100 * deltaTime
                    damage = math.max(damage, kMinHurtPerSecond)

                    local attacker
                    if entity.lastAttackerDidDamageTime and Shared.GetTime() < entity.lastAttackerDidDamageTime + 60 then
                        attacker = entity:GetLastAttacker()
                    end

                    entity:DeductHealth(damage, attacker)

                end

            end

        end

        if self.lastAutoHealIndex + AlienTeam.kAutoHealUpdateNum >= numEnts then
            self.lastAutoHealIndex = 1
        else
            self.lastAutoHealIndex = self.lastAutoHealIndex + AlienTeam.kAutoHealUpdateNum
        end

        self.timeOfLastAutoHeal = Shared.GetTime()

    end

end
