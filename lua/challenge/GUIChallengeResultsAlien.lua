-- ======= Copyright (c) 2017, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\challenge\GUIChallengeResultsAlien.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Extension of GUIChallengeResults for an alien-themed results screen.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/challenge/GUIChallengeResults.lua")

class 'GUIChallengeResultsAlien' (GUIChallengeResults)

GUIChallengeResultsAlien.kButtonTexture = PrecacheAsset("ui/alien_buymenu.dds")
GUIChallengeResultsAlien.kButtonTextureCoords = {396, 428, 706, 511}
GUIChallengeResultsAlien.kButtonVeinsTextureCoords = { 600, 350, 915, 419}
local kVeinsMargin = 4
GUIChallengeResultsAlien.kVeinsPulsePeriod = math.pi -- pulse once every two seconds.

GUIChallengeResultsAlien.kButtonHoverSound = PrecacheAsset("sound/NS2.fev/alien/common/alien_menu/hover")
GUIChallengeResultsAlien.kButtonClickSound = PrecacheAsset("sound/NS2.fev/alien/common/alien_menu/close_menu")

GUIChallengeResultsAlien.kButtonBackgroundLayerOffset = GUIChallengeResults.kContentLayerOffset
GUIChallengeResultsAlien.kVeinsLayerOffset = GUIChallengeResultsAlien.kButtonBackgroundLayerOffset + 1
GUIChallengeResultsAlien.kButtonTextLayerOffset = GUIChallengeResultsAlien.kButtonBackgroundLayerOffset + 2

GUIChallengeResultsAlien.kButtonShader = "shaders/GUIBasicSaturation.surface_shader"

GUIChallengeResultsAlien.kMedalNameToClassName = 
{
    bronze  = "GUIChallengeMedal_AlienBronze",
    silver  = "GUIChallengeMedal_AlienSilver",
    gold    = "GUIChallengeMedal_AlienGold",
    shadow  = "GUIChallengeMedal_AlienShadow",
}

GUIChallengeResultsAlien.kBackgroundShader = "shaders/GUISmokeAlpha.surface_shader"
GUIChallengeResultsAlien.kBackgroundTexture = PrecacheAsset("ui/challenge/results_background_alien.dds")
GUIChallengeResultsAlien.kBackgroundNoiseTexture = PrecacheAsset("ui/alien_commander_bg_smoke.dds")
GUIChallengeResultsAlien.kBackgroundCorrectionFactor = 0.0025
GUIChallengeResultsAlien.kBackgroundOffset = Vector(-112, -86, 0)

GUIChallengeResultsAlien.kColor = Color(219/255, 157/255, 35/255, 1)

function GUIChallengeResultsAlien:UpdateButtonLayers(index, button)
    
    GUIChallengeResults.UpdateButtonLayers(self, index, button)
    
    button.graphic:SetLayer(self.layer + self.kButtonBackgroundLayerOffset)
    button.veins:SetLayer(self.layer + self.kVeinsLayerOffset)
    
end

function GUIChallengeResultsAlien:UpdateLayers()
    
    GUIChallengeResults.UpdateLayers(self)
    
    self.bgItem:SetLayer(self.layer + self.kBackgroundLayerOffset)
    
end

function GUIChallengeResultsAlien:UpdateButtonTransform(index, button)
    
    GUIChallengeResults.UpdateButtonTransform(self, index, button)
    
    local size
    if button.over then
        size = Vector(self.kButtonOverSize)
    else
        size = Vector(self.kButtonSize)
    end
    
    local veinsSize = size - (Vector(kVeinsMargin, kVeinsMargin, 0) * 2.0)
    
    size.x = size.x * self.scale.x
    size.y = size.y * self.scale.y
    veinsSize.x = veinsSize.x * self.scale.x
    veinsSize.y = veinsSize.y * self.scale.y
    
    local graphicPos = button.position - (size * 0.5)
    local veinsPos = button.position - (veinsSize * 0.5)
    
    button.graphic:SetPosition(graphicPos)
    button.graphic:SetSize(size)
    
    button.veins:SetPosition(veinsPos)
    button.veins:SetSize(veinsSize)
    
end

function GUIChallengeResultsAlien:UpdateButtonVisibility(button)
    
    GUIChallengeResults.UpdateButtonVisibility(self, button)
    
    button.graphic:SetIsVisible(self.visible)
    button.veins:SetIsVisible(self.visible)
    
end

function GUIChallengeResultsAlien:UpdateVisibility()
    
    GUIChallengeResults.UpdateVisibility(self)
    
    self.bgItem:SetIsVisible(self.visible)
    
end

function GUIChallengeResultsAlien:UpdateTransform()
    
    GUIChallengeResults.UpdateTransform(self)
    
    local pos = Vector(self.kBackgroundOffset)
    pos.x = pos.x * self.scale.x
    pos.y = pos.y * self.scale.y
    pos = pos + self.position
    self.bgItem:SetPosition(pos)
    
    local size = Vector(self.bgItem:GetTextureWidth(), self.bgItem:GetTextureHeight(), 0)
    size.x = size.x * self.scale.x
    size.y = size.y * self.scale.y
    self.bgItem:SetSize(size)
    
    local texSize = Vector(self.bgItem:GetTextureWidth(), self.bgItem:GetTextureHeight(), 0)
    self.bgItem:SetFloatParameter("correctionX", self.kBackgroundCorrectionFactor * texSize.x )
    self.bgItem:SetFloatParameter("correctionY", self.kBackgroundCorrectionFactor * texSize.y )
    
end

function GUIChallengeResultsAlien:InitGUI()
    
    GUIChallengeResults.InitGUI(self)
    
    -- Smokey background
    self.bgItem = self:CreateGUIItem()
    self.bgItem:SetShader(self.kBackgroundShader)
    self.bgItem:SetTexture(self.kBackgroundTexture)
    self.bgItem:SetAdditionalTexture("noise", self.kBackgroundNoiseTexture)
    
    local texSize = Vector(self.bgItem:GetTextureWidth(), self.bgItem:GetTextureHeight(), 0)
    self.bgItem:SetFloatParameter("correctionX", self.kBackgroundCorrectionFactor * texSize.x )
    self.bgItem:SetFloatParameter("correctionY", self.kBackgroundCorrectionFactor * texSize.y )
    self.bgItem:SetFloatParameter("timeOffset", math.random() * 20)
    
    -- Start out completely invisible
    self.bgItem:SetFloatParameter("fadeStartTime", -1)
    self.bgItem:SetFloatParameter("fadeEndTime", 0)
    self.bgItem:SetFloatParameter("fadeTarget", 0)
    
end

function GUIChallengeResultsAlien:SetButtonEnabled(button, state)
    
    GUIChallengeResults.SetButtonEnabled(self, button, state)
    
    button.graphic:SetFloatParameter("saturation", button.enabled and 1.0 or 0.0)
    button.veins:SetFloatParameter("saturation", button.enabled and 1.0 or 0.0)
    
end

function GUIChallengeResultsAlien:AddButton_InitGUI(localeString, newButton)
    
    GUIChallengeResults.AddButton_InitGUI(self, localeString, newButton)
    
    local graphic = self:CreateGUIItem()
    graphic:SetTexture(self.kButtonTexture)
    graphic:SetTexturePixelCoordinates(GUIUnpackCoords(self.kButtonTextureCoords))
    graphic:SetShader(self.kButtonShader)
    graphic:SetFloatParameter("saturation", 1.0)
    newButton.graphic = graphic
    
    local veins = self:CreateGUIItem()
    veins:SetTexture(self.kButtonTexture)
    veins:SetTexturePixelCoordinates(GUIUnpackCoords(self.kButtonVeinsTextureCoords))
    veins:SetShader(self.kButtonShader)
    veins:SetFloatParameter("saturation", 1.0)
    newButton.veins = veins
    
    newButton.veinsPulse = 0
    
end

function GUIChallengeResultsAlien:Update(deltaTime)
    
    GUIChallengeResults.Update(self, deltaTime)
    
    for i=1, #self.buttons do
        
        local button = self.buttons[i]
        
        button.veinsPulse = self.buttons[i].veinsPulse + deltaTime
        
        if button.over then
            button.veinsPulse = 0
        elseif not button.enabled then
            button.veinsPulse = self.kVeinsPulsePeriod * 0.5
        end
        
        local opacity = math.cos(button.veinsPulse * self.kVeinsPulsePeriod) * 0.5 + 0.5
        button.veins:SetColor(Color(1,1,1,opacity))
        
    end
    
end

function GUIChallengeResultsAlien:UpdateButtonOpacity(button, opacity)
    
    GUIChallengeResults.UpdateButtonOpacity(self, button, opacity)
    
    local fadeColor = Color(1,1,1,opacity)
    
    button.graphic:SetColor(fadeColor)
    button.veins:SetColor(fadeColor)
    
end

function GUIChallengeResultsAlien:DoFadeIn(callback)
    
    GUIChallengeResults.DoFadeIn(self, callback)
    
    self.bgItem:SetFloatParameter("fadeStartTime", Shared.GetTime())
    self.bgItem:SetFloatParameter("fadeEndTime", Shared.GetTime() + self.kFadeTime)
    self.bgItem:SetFloatParameter("fadeTarget", 1.0)
    
end

function GUIChallengeResultsAlien:DoFadeOut(callback)
    
    GUIChallengeResults.DoFadeOut(self, callback)
    
    self.bgItem:SetFloatParameter("fadeStartTime", Shared.GetTime())
    self.bgItem:SetFloatParameter("fadeEndTime", Shared.GetTime() + self.kFadeTime)
    self.bgItem:SetFloatParameter("fadeTarget", 0.0)
    
end




