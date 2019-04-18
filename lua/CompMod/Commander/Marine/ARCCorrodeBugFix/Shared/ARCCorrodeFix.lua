-- This function checks if a structure should be corroding due to infestation,
-- and performs the action if it is.
--
-- The problem with this is that it is called repeatedly using a timed callback
-- until the entity is destroyed; unless the entity has a max armour value of 0,
-- in which case it returns false and exits the timed callback loop.
-- This behavious would usually be fine as the maxarmour value doesn't change
-- for any structures, with the notible exception of ARCS. The problem is caused
-- becase ARCs are the only strucures that have a dynamic max armour value and
-- this creates issues with the logic in this function.
--
-- When ARCS are deployed their max armour value is set to 0. In other words
-- they have no armour. This causes the timed callback loop to terminate.
-- If the ARC is then undeployed and moved to infestation (or if the ARC becomes
-- infested) the ARC will not take any corrosion damage as this function won't
-- be called anymore. This is fixed (badly :D) by modifying the max armour check
-- to also check if the entity is an ARC. This prevents the callback loop from
-- terminating.

local function CorrodeOnInfestation(self)

    if self:GetMaxArmor() == 0 and not self:isa("ARC") then
        return false
    end

    if self.updateInitialInfestationCorrodeState and GetIsPointOnInfestation(self:GetOrigin()) then

        self:SetGameEffectMask(kGameEffect.OnInfestation, true)
        self.updateInitialInfestationCorrodeState = false

    end

    if self:GetGameEffectMask(kGameEffect.OnInfestation) and self:GetCanTakeDamage() and (not HasMixin(self, "GhostStructure") or not self:GetIsGhostStructure()) then

        self:SetCorroded()

        if self:isa("PowerPoint") and self:GetArmor() > 0 then
            self:DoDamageLighting()
        end

        if not self:isa("PowerPoint") or self:GetArmor() > 0 then
            -- stop damaging power nodes when armor reaches 0... gets annoying otherwise.
            self:DeductHealth(kInfestationCorrodeDamagePerSecond, nil, nil, false, true, true)
        end

    end

    return true

end

ReplaceLocals(CorrodeMixin.__initmixin, {CorrodeOnInfestation = CorrodeOnInfestation})
