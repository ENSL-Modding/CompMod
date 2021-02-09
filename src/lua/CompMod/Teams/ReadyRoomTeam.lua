function ReadyRoomTeam:ReplaceRespawnPlayer(player, origin, angles)
    local mapName = self:GetRespawnMapName(player)
    
    -- We do not support Commanders in the ready room. The ready room is chaos!
    if mapName == MarineCommander.kMapName or mapName == AlienCommander.kMapName then
        mapName = ReadyRoomPlayer.kMapName
    end
    
    local extras = {}
    if player.lastExoLayout then
        extras.lastExoLayout = player.lastExoLayout
        extras.lastExoVariant = player.lastExoVariant
    end

    local isEmbryo = player:isa("Embryo")
    local isSpecEmbryo = player:isa("Spectator") and player:GetPreviousMapName() == Embryo.kMapName
    -- CompMod: fix vanilla servers errors when joining readyroom 
    -- local gestationTechId = isEmbryo and player:GetGestationTechId() or kTechId.None
    
    local gestationTechId
    if isEmbryo then
        gestationTechId = player:GetGestationTechId()
    end

    local newPlayer = player:Replace(mapName, self:GetTeamNumber(), false, origin, extras)

    if isSpecEmbryo then
        gestationTechId = newPlayer:GetPreviousGestationTechId()
    else
        gestationTechId = kTechId.None
    end
    
    -- Spawn embryos as ready room players with embryo model, so they can still move.
    if isEmbryo or isSpecEmbryo then
        newPlayer:SetModel(Embryo.kModelName)
        newPlayer:SetPreviousGestationTechId(gestationTechId)
    end
    
    self:RespawnPlayer(newPlayer, origin, angles)
    
    newPlayer:ClearGameEffects()
    
    return (newPlayer ~= nil), newPlayer 
end