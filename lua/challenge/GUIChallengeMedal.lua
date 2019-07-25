-- ======= Copyright (c) 2017, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\challenge\GUIChallengeMedal.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    An abstract GUIScript class for displaying the medals awarded for completing challenges with a good
--    enough score.  Specific medals are defined in their own classes, extending from this one (defined at
--    the bottom of this file).
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

local kBlankURL = "temptemp"

class 'GUIChallengeMedal' (GUIScript)

-- Override for other medal types
GUIChallengeMedal.kVideoName = nil
GUIChallengeMedal.kVideoLength = 0.01 -- very short default, so it's easy to spot errors.

-- Can override for other medal types... but probably shouldn't...
GUIChallengeMedal.kShaderName = "shaders/GUISideBySideRGBAVideo.surface_shader"
GUIChallengeMedal.kTextureName = "*medal_texture"
GUIChallengeMedal.kViewURL = "file:///ns2/web/client_game/fullscreenvideo_widget_html5.html"
GUIChallengeMedal.kVideoSize = Vector(1024, 512, 0)

GUIChallengeMedal.kSoundEffect = "sound/NS2.fev/skulk_challenge/medal_spin"
Client.PrecacheLocalSound(GUIChallengeMedal.kSoundEffect)

function GUIChallengeMedal:Initialize()
    
    self.item = GUI.CreateItem()
    self.item:SetColor(Color(1,1,1,1))
    self.item:SetTexture(self.kTextureName)
    self.item:SetShader(self.kShaderName)
    self.item:SetIsVisible(false)
    
    self.webView = Client.CreateWebView(self.kVideoSize.x, self.kVideoSize.y)
    self.webView:SetTargetTexture(self.kTextureName)
    self.webView:SetIsVisible(false)
    
    self.state = "hidden-waiting"
    
    self.visible = true
    self.itemVis = false -- keep it invisible until it's loaded
    
end

function GUIChallengeMedal:Uninitialize()
    
    if self.item then 
        GUI.DestroyItem(self.item)
        self.item = nil
    end
    
    if self.webView then
        self.webView:LoadUrl(kBlankURL)
        Client.DestroyWebView(self.webView)
        self.webView = nil
    end
    
    self.state = "done"
    
end

function GUIChallengeMedal:LoadAndPlay()
    
    self.state = "loading"
    local vidJson = 
    {
        videoUrl = self.kVideoName,
        volume = 0.0,
        videoWidth = self.kVideoSize.x,
        videoHeight = self.kVideoSize.y,
    }
    self.webView:LoadUrl(self.kViewURL.."?"..json.encode(vidJson))
    
end

-- Callback function will be called when video is done loading and begins playing.
-- Useful for playing sound effects along with the video.
function GUIChallengeMedal:SetStartCallback(callback)
    
    self.videoBeginCallback = callback
    
end

function GUIChallengeMedal:SetEndCallback(callback)
    
    self.videoEndCallback = callback
    
end

function GUIChallengeMedal:SetLayer(layer)
    
    self.item:SetLayer(layer)
    
end

function GUIChallengeMedal:SetPosition(pos)
    
    self.item:SetPosition(pos)
    
end

function GUIChallengeMedal:SetSize(size)
    
    self.item:SetSize(size)
    
end

function GUIChallengeMedal:SetOpacity(opacity)
    
    local color = Color(1,1,1,opacity)
    
    self.item:SetColor(color)
    
end

function GUIChallengeMedal:SetIsVisible(state)
    
    self.visible = state
    self.item:SetIsVisible(self.visible and self.itemVis)
    self.webView:SetIsVisible(self.visible and self.itemVis)
    
end

function GUIChallengeMedal:Update(deltaTime)
    
    if self.state == "hidden-waiting" or self.state == "done" then
        return
        
    elseif self.state == "loading" then
        if self.webView:GetUrlLoaded() then
            if self.videoBeginCallback then
                self.videoBeginCallback()
            end
            self.state = "playing"
            self.itemVis = true
            self.item:SetIsVisible(self.visible and self.itemVis)
            self.webView:SetIsVisible(self.visible and self.itemVis)
            self.playtimeRemaining = self.kVideoLength
            Shared.PlaySound(nil, self.kSoundEffect)
        end
        
    elseif self.state == "playing" then
        self.playtimeRemaining = self.playtimeRemaining - deltaTime
        if self.playtimeRemaining <= 0.0 then
            if self.videoEndCallback then
                self.videoEndCallback()
            end
            self.state = "done"
        end
    end
    
end

class 'GUIChallengeMedal_AlienBronze' (GUIChallengeMedal)
GUIChallengeMedal_AlienBronze.kVideoName = "file:///ns2/videos/challenge/medal_alien_bronze.webm"
GUIChallengeMedal_AlienBronze.kVideoLength = 70 / 24.0 -- 70 frames @ 24fps

class 'GUIChallengeMedal_AlienSilver' (GUIChallengeMedal)
GUIChallengeMedal_AlienSilver.kVideoName = "file:///ns2/videos/challenge/medal_alien_silver.webm"
GUIChallengeMedal_AlienSilver.kVideoLength = 70 / 24.0 -- 70 frames @ 24fps

class 'GUIChallengeMedal_AlienGold' (GUIChallengeMedal)
GUIChallengeMedal_AlienGold.kVideoName = "file:///ns2/videos/challenge/medal_alien_gold.webm"
GUIChallengeMedal_AlienGold.kVideoLength = 70 / 24.0 -- 70 frames @ 24fps

class 'GUIChallengeMedal_AlienShadow' (GUIChallengeMedal)
GUIChallengeMedal_AlienShadow.kVideoName = "file:///ns2/videos/challenge/medal_alien_shadow.webm"
GUIChallengeMedal_AlienShadow.kVideoLength = 70 / 24.0 -- 70 frames @ 24fps

