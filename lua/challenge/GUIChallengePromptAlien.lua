-- ======= Copyright (c) 2017, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\challenge\GUIChallengePromptAlien.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Alien theme for the cloud nag screen.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/challenge/GUIChallengePrompt.lua")
Script.Load("lua/challenge/GUIChallengeButtonAlien.lua")

class 'GUIChallengePromptAlien' (GUIChallengePrompt)

GUIChallengePromptAlien.kButtonClass = "GUIChallengeButtonAlien"

GUIChallengePromptAlien.kFontColor = Color(219/255, 157/255, 35/255, 1)

GUIChallengePromptAlien.kIcons = GUIChallengePromptAlien.kIcons or {}
GUIChallengePromptAlien.kIcons["choice"] = PrecacheAsset("ui/challenge/sad_babbler.dds")
GUIChallengePromptAlien.kIcons["halt"] = PrecacheAsset("ui/challenge/halt_gorge.dds")

GUIChallengePromptAlien.kBackgroundPosition = Vector(-61, -77, 0)
GUIChallengePromptAlien.kBackgroundSize = Vector(911, 536, 0)
GUIChallengePromptAlien.kBackgroundShader = "shaders/GUISmokeAlpha.surface_shader"
GUIChallengePromptAlien.kBackgroundTexture = PrecacheAsset("ui/challenge/prompt_screen_background_alien.dds")
GUIChallengePromptAlien.kBackgroundNoiseTexture = PrecacheAsset("ui/alien_commander_bg_smoke.dds")
GUIChallengePromptAlien.kBackgroundCorrectionFactor = 0.01

GUIChallengePromptAlien.kTextLayerOffset = 3
GUIChallengePromptAlien.kTextShadowLayerOffset = 2
GUIChallengePromptAlien.kButtonLayerOffset = 2
GUIChallengePromptAlien.kIconLayerOffset = 2
GUIChallengePromptAlien.kBackgroundLayerOffset = 1
GUIChallengePromptAlien.kDimmerLayerOffset = 0

function GUIChallengePromptAlien:UpdateColor()
    
    GUIChallengePrompt.UpdateColor(self)
    
    self.back:SetColor(Color(1,1,1,self.opacity))
    
end

function GUIChallengePromptAlien:UpdateLayers()
    
    GUIChallengePrompt.UpdateLayers(self)
    
    self.back:SetLayer(self.layer + self.kBackgroundLayerOffset)
    
end

function GUIChallengePromptAlien:UpdateTransform()
    
    GUIChallengePrompt.UpdateTransform(self)
    
    self.back:SetPosition(self.kBackgroundPosition * self.scale + self.position)
    self.back:SetSize(self.kBackgroundSize * self.scale)
    
    local texSize = Vector(self.back:GetTextureWidth(), self.back:GetTextureHeight(), 0)
    self.back:SetFloatParameter("correctionX", self.kBackgroundCorrectionFactor * texSize.x)
    self.back:SetFloatParameter("correctionY", self.kBackgroundCorrectionFactor * texSize.y)
    
end

function GUIChallengePromptAlien:InitGUI()
    
    GUIChallengePrompt.InitGUI(self)
    
    self.back = self:CreateGUIItem()
    self.back:SetShader(self.kBackgroundShader)
    self.back:SetTexture(self.kBackgroundTexture)
    self.back:SetAdditionalTexture("noise", self.kBackgroundNoiseTexture)
    self.back:SetFloatParameter("timeOffset", math.random() * 20)
    
    -- Start out completely invisible.
    self.back:SetFloatParameter("fadeStartTime", -1)
    self.back:SetFloatParameter("fadeEndTime", 0)
    self.back:SetFloatParameter("fadeTarget", 0)
    
end

function GUIChallengePromptAlien:Show(callback)
    
    local visState = self.visState 
    
    GUIChallengePrompt.Show(self, callback)
    
    if visState ~= "visible" then
        self.back:SetFloatParameter("fadeStartTime", Shared.GetTime())
        self.back:SetFloatParameter("fadeEndTime", Shared.GetTime() + self.kFadeTime)
        self.back:SetFloatParameter("fadeTarget", 1)
    end
    
end

function GUIChallengePromptAlien:Hide(callback)
    
    local visState = self.visState 
    
    GUIChallengePrompt.Hide(self, callback)
    
    if visState ~= "invisible" then
        self.back:SetFloatParameter("fadeStartTime", Shared.GetTime())
        self.back:SetFloatParameter("fadeEndTime", Shared.GetTime() + self.kFadeTime)
        self.back:SetFloatParameter("fadeTarget", 0)
    end
    
end


