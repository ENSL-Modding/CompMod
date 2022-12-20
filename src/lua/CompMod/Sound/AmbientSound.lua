-- mutes the ambient sound, if the lowest option (20%) is selected. 

local OldAmbientSoundStartPlaying = AmbientSound.StartPlaying
function AmbientSound:StartPlaying()

    if Client.kAmbientVolume == 0.2 then 
        Client.kAmbientVolume = 0.0
    end

    OldAmbientSoundStartPlaying(self)
end

local OldAmbientSoundUpdateVolume = AmbientSound.UpdateVolume
function AmbientSound:UpdateVolume()

    if Client.kAmbientVolume == 0.2 then 
        Client.kAmbientVolume = 0.0
    end

    OldAmbientSoundUpdateVolume(self)
end

local OldAmbientSoundStartPlayingAgain = AmbientSound.StartPlayingAgain
function AmbientSound:StartPlayingAgain()

    if Client.kAmbientVolume == 0.2 then 
        Client.kAmbientVolume = 0.0
    end

    OldAmbientSoundStartPlayingAgain(self)
end