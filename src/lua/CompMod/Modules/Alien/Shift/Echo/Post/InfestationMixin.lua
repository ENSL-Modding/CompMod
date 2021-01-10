local kUpdateInterval = 0.5
local kGrowingUpdateInterval = 0.025 -- 40 Hz should be smooth enough

function InfestationMixin:UpdateInfestation()

    PROFILE("InfestationMixin:UpdateInfestation")
    local hasInfestation = not HasMixin(self, "Construct") or self:GetIsBuilt()

    if hasInfestation and not self.infestationGenerated then
        print("Creating infestation")
        self:CreateInfestation()
        self.desiredInfestationRadius = self:GetInfestationMaxRadius()
    end


    local radius = self:GetCurrentInfestationRadius()

    local cloakFraction = 0
    local visible = false
    
    if Client then
        local playerIsEnemy = Client and GetAreEnemies(self, Client.GetLocalPlayer()) or false
        if not playerIsEnemy then
            cloakFraction = 0
        elseif self.GetCloakInfestation then
            cloakFraction = self:GetCloakInfestation() and 1 or 0
        elseif HasMixin(self, "Cloakable") then
            cloakFraction = self:GetCloakFraction()
        end

        visible = self:GetIsVisible()
    end

    -- update infestation patches
    for i = 1, #self.infestationPatches do

        local infestation = self.infestationPatches[i]

        infestation:SetRadius(radius)

        if Client then
            infestation:SetCloakFraction(cloakFraction)
            infestation:SetIsVisible(visible and (not PlayerUI_IsOverhead() or infestation.coords.yAxis.y > 0.55))
        end

    end

    if not self:GetIsAlive() and radius == 0 then
        self.allowDestruction = true
    end

    self.currentInfestationRadius = radius
    -- if we have reached our full radius, we can update less often
    return radius == self.desiredInfestationRadius and kUpdateInterval or kGrowingUpdateInterval
end
