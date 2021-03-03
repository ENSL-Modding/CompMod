local function CreateMapBlip(self, blipType, blipTeam, _)
    local mapName = MapBlip.kMapName
    --special mapblips
    if self:isa("Player") then
        mapName = PlayerMapBlip.kMapName
    elseif self:isa("Scan") then
        mapName = ScanMapBlip.kMapName
    elseif self:isa("TunnelEntrance") then
        mapName = TunnelMapBlip.kMapName
    end

    local mapBlip = Server.CreateEntity(mapName)
    -- This may fail if there are too many entities.
    if mapBlip then
        mapBlip:SetOwner(self:GetId(), blipType, blipTeam)
        self.mapBlipId = mapBlip:GetId()
    end
end

debug.setupvaluex(MapBlipMixin.__initmixin, "CreateMapBlip", CreateMapBlip)
