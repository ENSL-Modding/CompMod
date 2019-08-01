-- ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\InfestationMixin.lua
--
--    Created by:   Brian Cronin (brianc@unknownworlds.com)
--
--    Anything that spawns Infestation should use this.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

InfestationMixin = CreateMixin(InfestationMixin)
InfestationMixin.type = "Infestation"

-- Whatever uses the InfestationMixin needs to implement the following callback functions.
InfestationMixin.expectedCallbacks = 
{
    GetInfestationRadius = "How far infestation should spread from entity." 
}

local gInfestationMultiplier = 1
local gInfestationRecedeMultiplier = 2

InfestationMixin.networkVars =
{
    desiredInfestationRadius = "float",
    infestationRadius = "float",
    infestationChangeTime = "time",
    growthRate = "float"

}

local function GenerateInfestationCoords(origin, normal)

    local coords = Coords.GetIdentity()
    coords.origin = origin
    coords.yAxis = normal
    coords.zAxis = normal:GetPerpendicular()
    coords.xAxis = coords.zAxis:CrossProduct(coords.yAxis)
    
    return coords
    
end

function InfestationMixin:CreateInfestation()

    self.infestationPatches = {}
    local coords = self:GetCoords()
    local attached = self:GetAttached()
    local blobMultiplier = self.GetInfestationBlobMultiplier and self.GetInfestationBlobMultiplier() or 1

    if attached then

        -- Add a small offset, otherwise we are not able to track the infested state of the techpoint.
        coords = attached:GetCoords()
        coords.origin = coords.origin + Vector(0.1, 0, 0.1)

    end

    -- Floor.
    local radius = self:GetInfestationRadius()
    table.insert(self.infestationPatches, CreateStructureInfestation(self, coords, self:GetTeamNumber(), radius, blobMultiplier))

    -- Ceiling.
    local trace = Shared.TraceRay(self:GetOrigin() + coords.yAxis * 0.1, self:GetOrigin() + coords.yAxis * radius,  CollisionRep.Default,  PhysicsMask.Bullets, EntityFilterAll())
    local roomMiddlePoint = self:GetOrigin() + coords.yAxis * 0.1
    if trace.fraction ~= 1 then

        table.insert(self.infestationPatches, CreateStructureInfestation(self, GenerateInfestationCoords(trace.endPoint, trace.normal), self:GetTeamNumber(), radius, blobMultiplier))
        roomMiddlePoint = (trace.endPoint - self:GetOrigin()) * 0.5 + self:GetOrigin()

    end

    -- Front wall.
    trace = Shared.TraceRay(roomMiddlePoint, roomMiddlePoint + coords.zAxis * radius, CollisionRep.Default,  PhysicsMask.Bullets, EntityFilterAll())
    if trace.fraction ~= 1 then
        table.insert(self.infestationPatches, CreateStructureInfestation(self, GenerateInfestationCoords(trace.endPoint, trace.normal), self:GetTeamNumber(), radius, blobMultiplier))
    end

    -- Back wall.
    trace = Shared.TraceRay(roomMiddlePoint, roomMiddlePoint - coords.zAxis * radius, CollisionRep.Default,  PhysicsMask.Bullets, EntityFilterAll())
    if trace.fraction ~= 1 then
        table.insert(self.infestationPatches, CreateStructureInfestation(self, GenerateInfestationCoords(trace.endPoint, trace.normal), self:GetTeamNumber(), radius, blobMultiplier))
    end

    -- Left wall.
    trace = Shared.TraceRay(roomMiddlePoint, roomMiddlePoint + coords.xAxis * radius, CollisionRep.Default,  PhysicsMask.Bullets, EntityFilterAll())
    if trace.fraction ~= 1 then
        table.insert(self.infestationPatches, CreateStructureInfestation(self, GenerateInfestationCoords(trace.endPoint, trace.normal), self:GetTeamNumber(), radius, blobMultiplier))
    end

    -- Right wall.
    trace = Shared.TraceRay(roomMiddlePoint, roomMiddlePoint - coords.xAxis * radius, CollisionRep.Default,  PhysicsMask.Bullets, EntityFilterAll())
    if trace.fraction ~= 1 then
        table.insert(self.infestationPatches, CreateStructureInfestation(self, GenerateInfestationCoords(trace.endPoint, trace.normal), self:GetTeamNumber(), radius, blobMultiplier))
    end

    if self.startGrown or GetAndCheckBoolean(self.startsBuilt, "startsBuilt", false) then
        self:SetInfestationFullyGrown()
    else
        -- start growing from this point in time
        self:SetInfestationRadius(0)
    end

    self.infestationGenerated = true

end

function InfestationMixin:DestroyInfestation()

    for i = 1, #self.infestationPatches do
    
        local infestation = self.infestationPatches[i]
        infestation:Uninitialize()
    
    end

    self.infestationPatches = {}    
    self.infestationGenerated = false

end

function InfestationMixin:__initmixin()
    
    PROFILE("InfestationMixin:__initmixin")
    
    self.growthRate = self:GetInfestationGrowthRate() * gInfestationMultiplier
    self.desiredInfestationRadius = 0
    self.infestationPatches = {}
    self.infestationRadius = 0
    self.infestationChangeTime = Shared.GetTime()
    
    self:AddTimedCallback(InfestationMixin.UpdateInfestation, 0)
    
end

function InfestationMixin:GetIsPointOnInfestation(point)

    local onInfestation = false

    for i = 1, #self.infestationPatches do
    
        local infestation = self.infestationPatches[i]
        if infestation:GetIsPointOnInfestation(point) then
            onInfestation = true
            break
        end
    
    end

    return onInfestation

end

function InfestationMixin:GetInfestationGrowthRate()
    return 0.25
end

function InfestationMixin:GetInfestationMaxRadius()
    return 7.5
end

function InfestationMixin:OnDestroy()
    
    if self.infestationGenerated then
        self:DestroyInfestation()
    end
    
end

function InfestationMixin:OnKill()
    
    -- trigger receed
    self:SetDesiredInfestationRadius(0)
    
end

function InfestationMixin:SetInfestationFullyGrown()
    self.startGrown = true
    self:SetDesiredInfestationRadius(self:GetInfestationMaxRadius())
    self:SetInfestationRadius(self.desiredInfestationRadius)
end

function InfestationMixin:SetDesiredInfestationRadius(desiredInfestationRadius)

    self:SetInfestationRadius(self:GetCurrentInfestationRadius())    
    self.desiredInfestationRadius = desiredInfestationRadius
    
end

function InfestationMixin:SetInfestationRadius(radius)
    
    self.infestationRadius = radius
    self.infestationChangeTime = Shared.GetTime()
    
end

function InfestationMixin:GetCurrentInfestationRadius()

    if self.infestationRadius == self.desiredInfestationRadius then
        return self.desiredInfestationRadius
    end

    local growing = self.desiredInfestationRadius < self.infestationRadius
    local growthRateMultiplier = growing and gInfestationRecedeMultiplier or gInfestationMultiplier
    if self.GetInfestationRateMultiplier then
        growthRateMultiplier = growthRateMultiplier * self:GetInfestationRateMultiplier(growing)
    end

    local growth = (Shared.GetTime() - self.infestationChangeTime) * self.growthRate * growthRateMultiplier
    local radius = Slerp(self.infestationRadius, self.desiredInfestationRadius, growth)
    return radius

end

local kUpdateInterval = 0.5
local kGrowingUpdateInterval = 0.025 -- 40 Hz should be smooth enough

function InfestationMixin:UpdateInfestation()

    PROFILE("InfestationMixin:UpdateInfestation")
    local hasInfestation = not HasMixin(self, "Construct") or self:GetIsBuilt()

    if hasInfestation and not self.infestationGenerated then
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

function InfestationMixin:GetCurrentInfestationRadiusCached()
    return self.currentInfestationRadius or 0
end

function InfestationMixin:GetDestructionAllowed(destructionAllowedTable)
    destructionAllowedTable.allowed = destructionAllowedTable.allowed and self.allowDestruction
end

if Server then

    local function OnCommandInfestationSpeed(_, value)

        if (Shared.GetCheatsEnabled() or Shared.GetTestsEnabled()) and value then
        
            local infestationMultiplier = tonumber(value)
            if infestationMultiplier then
                gInfestationMultiplier = infestationMultiplier
            end
            
        end

    end

    Event.Hook("Console_infestationspeed", OnCommandInfestationSpeed)

end
