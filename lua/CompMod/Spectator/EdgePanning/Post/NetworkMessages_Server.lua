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
