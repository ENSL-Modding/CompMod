
Script.Load("lua/menu2/GUIMenuFullscreenVideo.lua")

local kVideoName = "file:///ns2/tipvideos/ns2_tutorial_intro.webm"
local kVideoLength = 78
local kVideoSize = Vector(1920, 1080, 0)
local kAudioFileName = "sound/NS2.fev/video/intro_video"
Client.PrecacheLocalSound(kAudioFileName)

function GUIVideoTutorialIntro_Play(onFinishedFunction, messageParameter)
    
    local video = CreateGUIObject("video", GUIMenuFullscreenVideo, nil,
    {
        videoPath = kVideoName,
        duration = kVideoLength,
        videoSize = kVideoSize,
        audioPath = kAudioFileName,
        muteGame = true,
    })
    video:HookEvent(video, "OnStopped",
        function(video2, watchedTime)
            if onFinishedFunction then
                onFinishedFunction(messageParameter, watchedTime)
            end
        end)
    
end
