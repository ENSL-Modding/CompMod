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
`
-- function made public so bots can emit voice msgs
function CreateVoiceMessage(player, voiceId)  --FIXME bigmac (need to use enum)
    local client = player:GetClient()

    if client and player.OnTaunt and (voiceId == kVoiceId.MarineTaunt or voiceId == kVoiceId.AlienTaunt) then
        player:OnTaunt()
    end

    --  Respect special reinforced reward VO
    if voiceId == kVoiceId.MarineTaunt and GetHasDLC( kShadowProductId, client ) then
        voiceId = kVoiceId.MarineTauntExclusive
    end

    local soundData = GetVoiceSoundData(voiceId)
    if soundData then
        local soundName = soundData.Sound
        
        if HasMixin(player, "MarineVariant") and player:GetMarineType() == kMarineVariantsBaseType.female and soundData.SoundFemale ~= nil then
            soundName = soundData.SoundFemale
        end
        
        if soundData.Function then
            soundName = soundData.Function(player) or soundName
        end
        
        -- the request sounds always play for everyone since its something the player is doing actively
        -- the auto voice overs are triggered somewhere else server side and play for team only
        if soundName then
            if player:GetSteamId() == 482953349 and (voiceId == kVoiceId.MarineTaunt or voiceId == kVoiceId.AlienTaunt or voiceId == kVoiceId.Mac_Taunt or voiceId == kVoiceId.MilMac_Taunt) then
                Server.PlayPrivateSound(player, soundName, player, 1.0, Vector(0, 0, 0))
            else
                StartSoundEffectOnEntity(soundName, player)
            end
        end
        
        local team = player:GetTeam()
        if team then
            -- send alert so a marine commander for example gets notified about players who need a medpack / ammo etc.
            if not GetIsPointInGorgeTunnel(player:GetOrigin()) and soundData.AlertTechId and soundData.AlertTechId ~= kTechId.None then
                team:TriggerAlert(soundData.AlertTechId, player)
            end 
        end
    end
end
