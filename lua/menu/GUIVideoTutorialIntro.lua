
Script.Load("lua/GUIFullscreenVideo.lua")

local kVideoName = "file:///ns2/tipvideos/ns2_tutorial_intro.webm"
local kVideoLength = 78
local kAudioFileName = "sound/NS2.fev/video/intro_video"
Client.PrecacheLocalSound(kAudioFileName)

local finishFunction, finishMessageParam

local videoPlayer

function GUIVideoTutorialIntro_Play(onFinishedFunction, messageParameter)

    videoPlayer = GetGUIManager():CreateGUIScript("GUIFullscreenVideo")
    videoPlayer:SetAudioFileName(kAudioFileName)
    
    finishFunction = onFinishedFunction
    finishMessageParam = messageParameter
    
    videoPlayer:PlayVideo(kVideoName, kVideoLength, GUIVideoTutorialIntro_End)
end

function GUIVideoTutorialIntro_End( watchedTime )
    if finishFunction then
        finishFunction(finishMessageParam, watchedTime)
    end
    GetGUIManager():DestroyGUIScript(videoPlayer)
end