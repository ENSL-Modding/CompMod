local kMACMinRange = 2.5
local kMACMaxRange = 10

function CommandStation:CreateInitialMAC()
    local origin = self:GetModelOrigin()
    local extents = LookupTechData(kTechId.MAC, kTechDataMaxExtents, nil)
    local capsuleHeight, capsuleRadius = GetTraceCapsuleFromExtents(extents)

    -- Try 20 times to create a MAC
    for i=1,20 do
        local spawnPoint = GetRandomSpawnForCapsule(capsuleHeight, capsuleRadius, origin, kMACMinRange, kMACMaxRange, EntityFilterAll())
        if not spawnPoint then
            goto continue
        end

        local nearResourcePoint = #GetEntitiesWithinRange("ResourcePoint", spawnPoint, 2) ~= 0
        if nearResourcePoint then
            goto continue
        end

        spawnPoint = GetGroundAtPosition(spawnPoint, nil, PhysicsMask.AllButPCs, extents)

        local location = GetLocationForPoint(spawnPoint)
        local locationName = location and location:GetName() or ""
        local commandStationLocationName = self:GetLocationName()

        local sameLocation = spawnPoint ~= nil and locationName == commandStationLocationName
        if not sameLocation then
            goto continue
        end

        local mac = CreateEntity(MAC.kMapName, spawnPoint, self:GetTeamNumber())
        mac:SetOrigin(mac:GetOrigin() + Vector(0, mac:GetHoverHeight(), 0))
        -- local macExtents = mac:GetExtents()
        -- Print("Vector(%s, %s, %s)", macExtents.x, macExtents.y, macExtents.z)

        do return mac end
        ::continue::
    end

    return nil
end
