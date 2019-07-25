-- ======= Copyright (c) 2017, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\challenge\GUIChallengeLeaderboardAlien.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    An abstract GUIScript class that extends GUIChallengeLeaderboard to provide an alien-themed
--    leaderboard for the alien-based challenge modes.  At the time of writing, this would be the
--    hive challenge, and the skulk challenge.  This class should not be instantiated, but should
--    be extended to suit the specific needs of the specific challenge.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/challenge/GUIChallengeLeaderboard.lua")

class 'GUIChallengeLeaderboardAlien' (GUIChallengeLeaderboard)

GUIChallengeLeaderboardAlien.kBackgroundShader = "shaders/GUISmokeAlpha.surface_shader"
GUIChallengeLeaderboardAlien.kBackgroundTexture = PrecacheAsset("ui/challenge/leaderboard_background_alien.dds")
GUIChallengeLeaderboardAlien.kBackgroundNoiseTexture = PrecacheAsset("ui/alien_commander_bg_smoke.dds")
GUIChallengeLeaderboardAlien.kBackgroundCorrectionFactor = 2.5
GUIChallengeLeaderboardAlien.kBackgroundOffset = Vector(-115, -49, 0)
GUIChallengeLeaderboardAlien.kArrowIcon = PrecacheAsset("ui/challenge/alien_arrow.dds")
GUIChallengeLeaderboardAlien.kHighlightColor = Color(234/255, 198/255, 128/255, 1)
GUIChallengeLeaderboardAlien.kColor = Color(219/255, 157/255, 35/255, 1)

GUIChallengeLeaderboardAlien.kButtonHoverSound = PrecacheAsset("sound/NS2.fev/alien/common/alien_menu/hover")
GUIChallengeLeaderboardAlien.kButtonClickSound = PrecacheAsset("sound/NS2.fev/alien/common/alien_menu/buy_upgrade")

GUIChallengeLeaderboardAlien.kTooltipBackColor = Color(109/255, 78/255, 17/255, 0.9)

function GUIChallengeLeaderboardAlien:UpdateVisibility()
    
    GUIChallengeLeaderboard.UpdateVisibility(self)
    
    self.backgroundItem:SetIsVisible(self.visible)
    
end

function GUIChallengeLeaderboardAlien:UpdateTransform()
    
    GUIChallengeLeaderboard.UpdateTransform(self)
    
    local backgroundPosition = (self.kBackgroundOffset * self.scale) + self.position
    self.backgroundItem:SetPosition(backgroundPosition)
    local backgroundSize = Vector(self.backgroundItem:GetTextureWidth(), self.backgroundItem:GetTextureHeight(), 0) * self.scale
    self.backgroundItem:SetSize(backgroundSize)
    
end

function GUIChallengeLeaderboardAlien:UpdateLayers()
    
    GUIChallengeLeaderboard.UpdateLayers(self)
    
    self.backgroundItem:SetLayer(self.layer + self.kBackgroundLayerOffset)
    
end

function GUIChallengeLeaderboardAlien:InitGUI()
    
    GUIChallengeLeaderboard.InitGUI(self)
    
    -- Background
    self.backgroundItem = self:CreateGUIItem()
    self.backgroundItem:SetShader(self.kBackgroundShader)
    self.backgroundItem:SetTexture(self.kBackgroundTexture)
    self.backgroundItem:SetAdditionalTexture("noise", self.kBackgroundNoiseTexture)
    self.backgroundItem:SetFloatParameter("correctionX", self.kBackgroundCorrectionFactor * self.scale.x)
    self.backgroundItem:SetFloatParameter("correctionY", self.kBackgroundCorrectionFactor * self.scale.y)
    self.backgroundItem:SetFloatParameter("timeOffset", math.random() * 20)
    
    -- Start out completely invisible.
    self.backgroundItem:SetFloatParameter("fadeStartTime", -1)
    self.backgroundItem:SetFloatParameter("fadeEndTime", 0)
    self.backgroundItem:SetFloatParameter("fadeTarget", 0)
    
end

function GUIChallengeLeaderboardAlien:DoFadeInAnimation(callback)
    
    GUIChallengeLeaderboard.DoFadeInAnimation(self, callback)
    
    self.backgroundItem:SetFloatParameter("fadeStartTime", Shared.GetTime())
    self.backgroundItem:SetFloatParameter("fadeEndTime", Shared.GetTime() + self.kFadeTime)
    self.backgroundItem:SetFloatParameter("fadeTarget", 1.0)
    
end

function GUIChallengeLeaderboardAlien:DoFadeOutAnimation(callback)
    
    GUIChallengeLeaderboard.DoFadeOutAnimation(self, callback)
    
    self.backgroundItem:SetFloatParameter("fadeStartTime", Shared.GetTime())
    self.backgroundItem:SetFloatParameter("fadeEndTime", Shared.GetTime() + self.kFadeTime)
    self.backgroundItem:SetFloatParameter("fadeTarget", 0.0)
    
end