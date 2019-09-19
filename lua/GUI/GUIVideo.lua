-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/GUI/GUIVideo.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    A GUIObject used for displaying a video.
--
--  Parameters (* = required)
--     *videoPath       The path of the video file to use.  Must be relative to the ns2 base
--                      directory (the "Natural Selection 2" directory where steam installed the
--                      game.  Videos are loaded inside of webpages, and displayed using the
--                      steam web view, so the usual Spark file system doesn't work).
--     *duration        The length of the video, in seconds (looping video not supported at this
--                      time).
--     *videoSize       The width and height of the video, in pixels.  Necessary to ensure the web
--                      view is the correct size to display the video.  The size of this GUIObject
--                      doesn't need to match this size.
--      audioPath       Optional audio event name to play along-side the video.  Audio will not play
--                      from the video itself -- it needs to be added to FMOD.
--      muteGame        If true, mutes all other audio while this video is playing.
--
--  Properties:
--      VideoState      The state the video playback is currently in.  Can be:
--                          "initializing"  -- The video object is being created.
--                          "loadingHTML"   -- The video is being loaded into the webpage.
--                          "playing"       -- The video is currently playing.
--                          "finished"      -- The video has finished playing.
--
--  Events:
--      OnStopped           The video was stopped, either because it was finished, or something
--                          stopped it prematurely.
--          watchedTime     The number of seconds the video played before it was stopped.
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/GUI/GUIObject.lua")

---@class GUIVideo : GUIObject
class "GUIVideo" (GUIObject)

local kViewURL = "file:///ns2/web/client_game/fullscreenvideo_widget_html5.html"

GUIVideo:AddClassProperty("VideoState", "initializing")

local inUseNames = {}
local function GetUniqueTextureNameForVideo()
    local idx = 1
    local name = "*video_webview_texture_" .. tostring(idx)
    while inUseNames[name] do
        idx = idx + 1
        name = "*video_webview_texture_" .. tostring(idx)
    end
    inUseNames[name] = idx
    return name
end

local function ReleaseUniqueTextureNameForVideo(name)
    assert(type(name) == "string")
    inUseNames[name] = nil
end

function GUIVideo:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    RequireType("string", params.videoPath, "params.videoPath", errorDepth)
    RequireType("number", params.duration, "params.duration", errorDepth)
    RequireType("Vector", params.videoSize, "params.videoSize", errorDepth)
    RequireType({"string", "nil"}, params.audioPath, "params.audioPath", errorDepth)
    RequireType({"boolean", "nil"}, params.muteGame, "params.muteGame", errorDepth)
    
    GUIObject.Initialize(self, params, errorDepth)
    
    local videoSizeX = math.max(math.floor(params.videoSize.x), 32)
    local videoSizeY = math.max(math.floor(params.videoSize.y), 32)
    
    self.textureName = GetUniqueTextureNameForVideo()
    self.duration = math.max(params.duration, 0)
    self.audioPath = params.audioPath
    
    self.webView = Client.CreateWebView(videoSizeX, videoSizeY)
    self.webView:SetTargetTexture(self.textureName)
    
    local soundVolume = OptionsDialogUI_GetSoundVolume() / 100.0
    if params.muteGame then
        self.oldSoundVolume = soundVolume
        self.oldMusicVolume = OptionsDialogUI_GetMusicVolume() / 100.0
        self.oldVoiceVolume = OptionsDialogUI_GetVoiceVolume() / 100.0
        Client.SetSoundVolume(0)
        Client.SetMusicVolume(0)
        Client.SetVoiceVolume(0)
    end
    Client.SetVideoVolume(soundVolume)
    
    local videoJSON =
    {
        videoUrl = params.videoPath,
        volume = 0, -- not hooked up to anything....
        videoWidth = videoSizeX,
        videoHeight = videoSizeY,
    }
    self.webView:LoadUrl(kViewURL.."?"..json.encode(videoJSON))
    self:SetVideoState("loadingHTML")
    
    self:SetUpdates(true) -- keep checking for when video is loaded.  No callback system for this.
    
end

local function Cleanup(self)
    
    -- Release the texture name we were using.
    if self.textureName then
        ReleaseUniqueTextureNameForVideo(self.textureName)
        self.textureName = nil
    end
    
    -- Reset sound volumes to what they were before (if changed).
    if self.oldSoundVolume then
        assert(self.oldMusicVolume)
        assert(self.oldVoiceVolume)
        Client.SetSoundVolume(self.oldSoundVolume)
        Client.SetMusicVolume(self.oldMusicVolume)
        Client.SetVoiceVolume(self.oldVoiceVolume)
        self.oldSoundVolume = nil
    end
    
    -- Destroy the WebView.
    if self.webView then
        Client.DestroyWebView(self.webView)
        self.webView = nil
    end
    
end

function GUIVideo:Uninitialize()
    Cleanup(self)
end

function GUIVideo:StopPlaying()
    
    -- Stop audio
    if self.audioPath then
        Shared.StopSound(nil, self.audioPath)
    end
    
    -- Send event saying that we've stopped, and how much of the video we saw.
    local time = Shared.GetTime()
    local watchedTime = 0
    if self.startTime then
        watchedTime = Clamp(time - self.startTime, 0, self.duration)
    end
    self:FireEvent("OnStopped", watchedTime)
    
    self:SetVideoState("finished")
    Cleanup(self)
    
end

function GUIVideo:OnUpdate(deltaTime, now)
    
    assert(self:GetVideoState() == "loadingHTML")
    if self.webView:GetUrlLoaded() then
        
        self:SetVideoState("playing")
        self:SetUpdates(false)
        self:SetTexture(self.textureName)
        self:SetColor(1, 1, 1, 1)
        self:AddTimedCallback(self.StopPlaying, self.duration, false)
    
        if self.audioPath then
            Shared.PlaySound(nil, self.audioPath)
        end
    
        self.startTime = Shared.GetTime()
        
    end
    
end
