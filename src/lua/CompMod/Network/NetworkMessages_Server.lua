local function onSpectatePlayer(client, message)

    local spectatorPlayer = client:GetControllingPlayer()
    if spectatorPlayer then

        -- This only works for players on the spectator team.
        if spectatorPlayer:GetTeamNumber() == kSpectatorIndex then
            client:GetControllingPlayer():SelectEntity(message.entityId)
            if spectatorPlayer.specMode == kSpectatorMode.Overhead then
                if message.entityId == Entity.invalidId then
                    spectatorPlayer:SetOverheadMoveEnabled(true)
                else
                    spectatorPlayer:SetOverheadMoveEnabled(false)
                end
            end
        end

    end

end
Server.HookNetworkMessage("SpectatePlayer", onSpectatePlayer)

function OnCommandGorgeBuildStructure(client, message)
    local player = client:GetControllingPlayer()
    local origin, direction, structureIndex, lastClickedPosition, lastClickedPositionNormal, tunnelNetwork = ParseGorgeBuildMessage(message)
    
    local dropStructureAbility = player:GetWeapon(DropStructureAbility.kMapName)

    --[[
        The player may not have an active weapon if the message is sent
        after the player has gone back to the ready room for example.
    ]]
    if dropStructureAbility then
        dropStructureAbility:OnDropStructure(origin, direction, structureIndex, lastClickedPosition, lastClickedPositionNormal, tunnelNetwork)
    end
end
Server.HookNetworkMessage("GorgeBuildStructure", OnCommandGorgeBuildStructure)
