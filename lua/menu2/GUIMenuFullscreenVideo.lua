-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/menu2/GUIMenuFullscreenVideo.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Displays a fullscreen video (like the intro).
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

Script.Load("lua/GUI/GUIVideo.lua")
Script.Load("lua/GUI/LayerConstants.lua")

---@class GUIMenuFullscreenVideo : GUIVideo
class "GUIMenuFullscreenVideo" (GUIVideo)

local function OnVideoStateChanged(self, state)
    if state == "finished" then
        self:Destroy()
    end
end

function GUIMenuFullscreenVideo:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    PushParamChange(params, "muteGame", true)
    GUIVideo.Initialize(self, params, errorDepth)
    PopParamChange(params, "muteGame")
    
    self:SetModal()
    
    Client.SetMouseVisible(false)
    
    self:ListenForKeyInteractions()
    
    self:HookEvent(self, "OnVideoStateChanged", OnVideoStateChanged)
    
    self:SetSize(Client.GetScreenWidth(), Client.GetScreenHeight())
    self:SetLayer(GetLayerConstant("FullscreenVideo", 2000))
    
end

function GUIMenuFullscreenVideo:Uninitialize()
    
    Client.SetMouseVisible(true)
    
end

function GUIMenuFullscreenVideo:OnKey(key, down)
    
    if not down then
        return
    end
    
    if key == InputKey.Escape or key == InputKey.Return or key == InputKey.Space then
        self:StopPlaying()
    end
    
end
