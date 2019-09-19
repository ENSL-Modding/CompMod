-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\ReadyRoomTeam.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
--                  Max McGuire (max@unknownworlds.com)
--
-- This class is used for the team that is for players that are in the ready room.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Team.lua")
Script.Load("lua/TeamDeathMessageMixin.lua")

class 'ReadyRoomTeam' (Team)

function ReadyRoomTeam:Initialize(teamName, teamNumber)
    Team.Initialize(self, teamName, teamNumber)
    self:OnCreate()
    self:OnInitialized()
end

function ReadyRoomTeam:OnInitialized()
    Team.OnInitialized(self)

    InitMixin(self, TeamDeathMessageMixin)
end

function ReadyRoomTeam:GetRespawnMapName(player)

    local mapName = player.kMapName    
    
    if mapName == nil then
        mapName = ReadyRoomPlayer.kMapName
    end
    
    -- Use previous life form if dead or in commander chair
    if mapName == MarineCommander.kMapName
       or mapName == AlienCommander.kMapName
       or mapName == Spectator.kMapName
       or mapName == AlienSpectator.kMapName
       or mapName == MarineSpectator.kMapName then 
    
        mapName = player:GetPreviousMapName()
        
    end
    
    if mapName == MarineCommander.kMapName
       or mapName == AlienCommander.kMapName
       or mapName == Spectator.kMapName
       or mapName == AlienSpectator.kMapName
       or mapName == MarineSpectator.kMapName then
           
        mapName = ReadyRoomPlayer.kMapName
        
    elseif mapName == Embryo.kMapName then
        mapName = ReadyRoomEmbryo.kMapName
    elseif mapName == Exo.kMapName then
        mapName = ReadyRoomExo.kMapName
    end
            
    return mapName
    
end

--
-- Transform player to appropriate team respawn class and respawn them at an appropriate spot for the team.
--
function ReadyRoomTeam:ReplaceRespawnPlayer(player, origin, angles)

    local mapName = self:GetRespawnMapName(player)
    
    -- We do not support Commanders in the ready room. The ready room is chaos!
    if mapName == MarineCommander.kMapName or mapName == AlienCommander.kMapName then
        mapName = ReadyRoomPlayer.kMapName
    end
    
    local isEmbryo = player:isa("Embryo") or (player:isa("Spectator") and player:GetPreviousMapName() == Embryo.kMapName)
    local newPlayer = player:Replace(mapName, self:GetTeamNumber(), false, origin)
    
    -- Spawn embryos as ready room players with embryo model, so they can still move.
    if isEmbryo then
        newPlayer:SetModel(Embryo.kModelName)
    end
    
    self:RespawnPlayer(newPlayer, origin, angles)
    
    newPlayer:ClearGameEffects()
    
    return (newPlayer ~= nil), newPlayer
    
end

function ReadyRoomTeam:GetSupportsOrders()
    return false
end

function ReadyRoomTeam:TriggerAlert(techId, entity)
    return false
end