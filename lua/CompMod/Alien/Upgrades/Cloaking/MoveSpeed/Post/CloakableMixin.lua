local UpdateCloakState = debug.getupvaluex(CloakableMixin.OnUpdate, "UpdateCloakState", false)
local oldUpdateDesiredCloakFraction = debug.getupvaluex(UpdateCloakState, "UpdateDesiredCloakFraction", false)
local kPlayerMaxCloak = debug.getupvaluex(oldUpdateDesiredCloakFraction, "kPlayerMaxCloak", false)

local function UpdateDesiredCloakFraction(self, deltatime)
    oldUpdateDesiredCloakFraction(self, deltatime)

    local newDesiredCloakFraction = self.cloakingDesired and 1 or 0

    -- Update cloaked fraction according to our speed and max speed
    if newDesiredCloakFraction == 1 and self.GetSpeedScalar then
        newDesiredCloakFraction = 1 - self:GetSpeedScalar()
    end

    if newDesiredCloakFraction ~= nil then
        self.desiredCloakFraction = Clamp(newDesiredCloakFraction, 0, (self:isa("Player") or self:isa("Drifter") or self:isa("Babbler") or self:isa("Web")) and kPlayerMaxCloak or 1)
    end
end

debug.setupvaluex(UpdateCloakState, "UpdateDesiredCloakFraction", UpdateDesiredCloakFraction, false)
debug.setupvaluex(CloakableMixin.OnUpdate, "UpdateCloakState", UpdateCloakState, false)
debug.setupvaluex(CloakableMixin.OnProcessMove, "UpdateCloakState", UpdateCloakState, false)
debug.setupvaluex(CloakableMixin.OnProcessSpectate ,"UpdateCloakState", UpdateCloakState, false)
