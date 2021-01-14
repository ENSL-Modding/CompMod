local kTechIdToMaterialOffset = debug.getupvaluex(GetMaterialToXYOffset, "kTechIdToMaterialOffset")

local toAdd = {
    {kTechId.AdvancedSwipe, 105},
    {kTechId.Neurotoxin, 174}
}

local toChange = {}

local toRemove = {}


-- Process changes first
for _,v in ipairs(toChange) do
    if kTechIdToMaterialOffset[v[1]] then
        kTechIdToMaterialOffset[v[1]] = v[2]
    end
end

-- Process removals next
for _,v in ipairs(toRemove) do
    if kTechIdToMaterialOffset[i] then
        table.remove(kTechIdToMaterialOffset, v)
    end
end

-- Process additions last
for _,v in ipairs(toAdd) do
    if not kTechIdToMaterialOffset[v[1]] then
        kTechIdToMaterialOffset[v[1]] = v[2]
    end
end
