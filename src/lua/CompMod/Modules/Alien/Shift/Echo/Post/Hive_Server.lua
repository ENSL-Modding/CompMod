function Hive:OnTeleport()
    print("On Teleport")
    self:SetDesiredInfestationRadius(0)
end

function Hive:OnTeleportFailed()
    print("On Teleport Failed")
    self:SetDesiredInfestationRadius(self:GetInfestationMaxRadius())
end

function Hive:OnTeleportEnd(destinationEntity)
    print("On Teleport End")
    local attachedTechPoint = self:GetAttached()
    if attachedTechPoint then
        attachedTechPoint:SetIsSmashed(true)
    end

    self.startGrown = false
    self:DestroyInfestation()

    local commander = self:GetCommander()

    if commander then
        -- we assume Onos extents for now, save lastExtents in commadner
        local extents = LookupTechData(kTechId.Onos, kTechDataMaxExtents, nil)
        local randomSpawn = GetRandomSpawnForCapsule(extents.y, extents.x, self:GetOrigin(), 2, 4, EntityFilterAll())
        commander.lastGroundOrigin = randomSpawn
    end

    for _, id in ipairs(self.cystChildren) do
        local child = Shared.GetEntity(id)
        if child then
            child.parentId = Entity.invalidId
        end
    end

    self.cystChildren = { }
end
