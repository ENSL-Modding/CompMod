local UpdateCloakState = CompMod:GetLocalVariable(CloakableMixin.OnUpdate, "UpdateCloakState")
local kPlayerMaxCloak = CompMod:GetLocalVariable(UpdateCloakState, "kPlayerMaxCloak")

local function UpdateDesiredCloakFraction(self, deltaTime)

    if Server then

        self.cloakingDesired = false

        -- Animate towards uncloaked if triggered
        if Shared.GetTime() > self.timeUncloaked and (not HasMixin(self, "Detectable") or not self:GetIsDetected()) and ( not GetConcedeSequenceActive() ) then

            -- Uncloaking takes precedence over cloaking
            if Shared.GetTime() < self.timeCloaked then
                self.cloakingDesired = true
                self.cloakRate = 3
            elseif self.GetIsCamouflaged and self:GetIsCamouflaged() then

                self.cloakingDesired = true

                if self:isa("Player") then
                    self.cloakRate = self:GetVeilLevel()
                elseif self:isa("Babbler") then
                    local babblerParent = self:GetParent()
                    if babblerParent and HasMixin(babblerParent, "Cloakable") then
                        self.cloakRate = babblerParent.cloakRate
                    end
                else
                    self.cloakRate = 3
                end

            end

        end

    end

    local newDesiredCloakFraction = self.cloakingDesired and 1 or 0

    -- Update cloaked fraction according to our speed and max speed
    if newDesiredCloakFraction == 1 and self.GetSpeedScalar then
        newDesiredCloakFraction = 1 - self:GetSpeedScalar()
    end

    if newDesiredCloakFraction ~= nil then
        self.desiredCloakFraction = Clamp(newDesiredCloakFraction, 0, (self:isa("Player") or self:isa("Drifter") or self:isa("Babbler")) and kPlayerMaxCloak or 1)
    end

end

ReplaceLocals(UpdateCloakState, {UpdateDesiredCloakFraction = UpdateDesiredCloakFraction})
