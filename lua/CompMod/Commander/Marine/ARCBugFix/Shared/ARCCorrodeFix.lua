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
