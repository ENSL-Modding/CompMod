Script.Load("lua/Weapons/Alien/StructureAbility.lua")

class 'TunnelAbility' (StructureAbility)

function TunnelAbility:GetDropRange()
    return 1.5
end

function TunnelAbility:GetEnergyCost()
    return kDropStructureEnergyCost
end

-- TODO: Add skins
function TunnelAbility:GetGhostModelName(ability)
    return TunnelEntrance.kModelName
end

-- child must override
function TunnelAbility:GetDropStructureId()
    assert(false)
end

-- child must override
function TunnelAbility:GetTechIds()
    assert(false)
end

local kExtents = Vector(0.4, 0.5, 0.4)
local function IsPathable(position)
    local noBuild = Pathing.GetIsFlagSet(position, kExtents, Pathing.PolyFlag_NoBuild)
    local walk = Pathing.GetIsFlagSet(position, kExtents, Pathing.PolyFlag_Walk)
    return not noBuild and walk
end

local kUpVector = Vector(0, 1, 0)
local kCheckDistance = 0.8 -- bigger than onos
local kVerticalOffset = 0.3
local kVerticalSpace = 1.75
local kBoxSweepOutset = 0.2
local kBoxSweepHeight = 0.5
local kGroundCheckDistance = 2.0

-- maximum distance the centroid of the trace end points can be from original position before being
-- considered too bent
local kBentThreshold = 0.235
local kBentThresholdSq = kBentThreshold * kBentThreshold

local function CalculateTunnelPosition(position, player, surfaceNormal)
    PROFILE("CalculateTunnelPosition")

    local xAxis
    local zAxis
    local dot

    local valid = true

    if surfaceNormal.x == 0.0 and surfaceNormal.y == 0.0 and surfaceNormal.z == 0.0 then
        return false, nil
    end

    if not surfaceNormal then
        return false, nil
    end

    dot = surfaceNormal:DotProduct(kUpVector)
    if dot < 0.86603 then
        valid = false
    end

    if math.abs(kUpVector:DotProduct(surfaceNormal)) >= 0.9999 then
        xAxis = Vector(1,0,0)
    else
        xAxis = kUpVector:CrossProduct(surfaceNormal):GetUnit()
    end

    zAxis = xAxis:CrossProduct(surfaceNormal)
    
    local pts = 
    {
        xAxis * -kCheckDistance + surfaceNormal * kGroundCheckDistance,
        xAxis * -kCheckDistance * 0.707 + zAxis * -kCheckDistance * 0.707 + surfaceNormal * kGroundCheckDistance,
        zAxis * -kCheckDistance + surfaceNormal * kGroundCheckDistance,
        xAxis *  kCheckDistance * 0.707 + zAxis * -kCheckDistance * 0.707 + surfaceNormal * kGroundCheckDistance,
        xAxis *  kCheckDistance + surfaceNormal * kGroundCheckDistance,
        xAxis *  kCheckDistance * 0.707 + zAxis *  kCheckDistance * 0.707 + surfaceNormal * kGroundCheckDistance,
        zAxis *  kCheckDistance + surfaceNormal * kGroundCheckDistance,
        xAxis * -kCheckDistance * 0.707 + zAxis *  kCheckDistance * 0.707 + surfaceNormal * kGroundCheckDistance,
    }

    local groundHits = {}
    for i = 1, #pts do
        local traceStart = pts[i] + position
        local traceEnd = pts[i] + position - (surfaceNormal * kGroundCheckDistance * 1.5)
        local trace = Shared.TraceRay(traceStart, traceEnd, CollisionRep.Default, PhysicsMask.AllButPCsAndRagdolls, EntityFilterOneAndIsa(player, "Babbler"))

        if trace.entity ~= nil then
            valid = false
        end

        if not IsPathable(trace.endPoint) and trace.surface ~= "tunnel_allowed" then
            valid = false
        end

        if trace.fraction == 1 then
            valid = false
        else
            groundHits[#groundHits+1] = trace.endPoint
        end
    end

    local centroid = Vector(0,0,0)
    for i=1, #groundHits do
        centroid = centroid + groundHits[i]
    end
    centroid = centroid / #groundHits

    if (centroid - position):GetLengthSquared() > kBentThresholdSq then
        valid = false
    end

    for i=1, #groundHits do
        groundHits[i] = groundHits[i] - centroid
    end

    local avgNorm = Vector(0,0,0)
    for i=1,#groundHits do
        local p0 = groundHits[i]
        local p1 = groundHits[(i % #groundHits) + 1]
        avgNorm = avgNorm + p1:CrossProduct(p0):GetUnit()
    end
    avgNorm = avgNorm:GetUnit()

    local traceStart
    local traceEnd
    local extents
    if valid then
        local xDot = math.abs(xAxis:DotProduct(kUpVector))
        local zDot = math.abs(zAxis:DotProduct(kUpVector))

        local yOffset = dot * kVerticalOffset + xDot * kCheckDistance + zDot * kCheckDistance

        extents = Vector(kCheckDistance, kBoxSweepHeight, kCheckDistance)
        traceStart = position + Vector(0, yOffset, 0) + avgNorm * kBoxSweepOutset
        traceEnd = traceStart + avgNorm * (kVerticalSpace / dot)

        local trace = Shared.TraceBox(extents, traceStart, traceEnd, CollisionRep.Move, PhysicsMask.Movement, EntityFilterAll())

        if trace.fraction ~= 1 then
            valid = false
        end
    end

    if valid then
        local startPoint2 = traceEnd
        local endPoint2 = traceStart
        endPoint2 = (endPoint2 - startPoint2) * 0.667 + startPoint2
        local trace2 = Shared.TraceBox(extents * 0.5, startPoint2, endPoint2, CollisionRep.Move, PhysicsMask.Movement, EntityFilterAll())

        if trace2.fraction ~= 1 then
            valid = false
        end
    end

    local newCoords = Coords()
    newCoords.origin = centroid
    newCoords.yAxis = avgNorm
    newCoords.zAxis = Vector(1,0,0):CrossProduct(avgNorm):GetUnit()
    newCoords.xAxis = newCoords.yAxis:CrossProduct(newCoords.zAxis)

    return valid, newCoords
end

function TunnelAbility:GetIsPositionValid(position, player, surfaceNormal)
    PROFILE("TunnelAbility:GetIsPositionValid")
    local valid, _ CalculateTunnelPosition(position, player, surfaceNormal)
    return valid
end

function TunnelAbility:SetNetwork(networkNum)
    self.networkNum = networkNum
end

function TunnelAbility:CreateStructure(coords, player, lastClickedPosition)
    local teamInfo = GetTeamInfoEntity(kTeam2Index)
    local tunnelManager = teamInfo:GetTunnelManager()
    local techId = self:GetTechIds()[self.networkNum]
    local selectTechId = self:GetSelectTechIds()[self.networkNum]
    local existingTunnel = tunnelManager:GetTunnelEntrance(selectTechId)

    if existingTunnel then
        if existingTunnel:GetCanDie() then
            existingTunnel:Kill()
        else
            DestroyEntity(existingTunnel)
        end
    end

    return tunnelManager:CreateTunnelEntrance(coords.origin, techId)
end

function TunnelAbility:GetNetwork()
    return self.networkNum
end

function TunnelAbility:IsAllowed(player)
    local teamInfo = GetTeamInfoEntity(kTeam2Index)
    local tunnelManager = teamInfo:GetTunnelManager()
    local allowed = tunnelManager:GetTechAllowed(self:GetTechIds()[self.networkNum])
    return allowed
end
