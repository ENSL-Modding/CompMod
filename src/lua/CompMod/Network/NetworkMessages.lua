local kGorgeBuildStructureMessage =
{
    origin = "vector",
    direction = "vector",
    -- CompMod: Hack in our tunnel indexes
    -- structureIndex = "integer (1 to 5)",
    structureIndex = "integer (-2 to 5)",
    lastClickedPosition = "vector",
    lastClickedPositionNormal = "vector",
    tunnelNetwork = "integer (0 to 4)"
}

function BuildGorgeDropStructureMessage(origin, direction, structureIndex, lastClickedPosition, lastClickedPositionNormal, tunnelNetwork)   
    local t = {}

    t.origin = origin
    t.direction = direction
    t.structureIndex = structureIndex
    t.lastClickedPosition = lastClickedPosition or Vector(0,0,0)
    t.lastClickedPositionNormal = lastClickedPositionNormal or Vector(0,0,0)
    t.tunnelNetwork = tunnelNetwork

    return t
end

function ParseGorgeBuildMessage(t)
    return t.origin, t.direction, t.structureIndex, t.lastClickedPosition, t.lastClickedPositionNormal, t.tunnelNetwork
end

Shared.RegisterNetworkMessage("GorgeBuildStructure", kGorgeBuildStructureMessage)
