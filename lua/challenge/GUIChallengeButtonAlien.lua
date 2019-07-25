-- ======= Copyright (c) 2017, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\challenge\GUIChallengeButtonAlien.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Alien-themed button for use in the many popups in the challenge mode.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/challenge/GUIChallengeButton.lua")

class 'GUIChallengeButtonAlien' (GUIChallengeButton)

GUIChallengeButtonAlien.kTextLayerOffset = 2
GUIChallengeButtonAlien.kVeinsLayerOffset = 1
GUIChallengeButtonAlien.kBackgroundLayerOffset = 0

GUIChallengeButtonAlien.kTexture = PrecacheAsset("ui/alien_buymenu.dds")
GUIChallengeButtonAlien.kTextureCoords = {396, 428, 706, 511}
GUIChallengeButtonAlien.kVeinsTextureCoords = { 600, 350, 915, 419}
GUIChallengeButtonAlien.kVeinsMargin = 4
GUIChallengeButtonAlien.kVeinsPulsePeriod = math.pi -- pulse once every two seconds.

GUIChallengeButtonAlien.kHoverSound = PrecacheAsset("sound/NS2.fev/alien/common/alien_menu/hover")
GUIChallengeButtonAlien.kClickSound = PrecacheAsset("sound/NS2.fev/alien/common/alien_menu/close_menu")

function GUIChallengeButtonAlien:UpdateLayers()
    
    GUIChallengeButton.UpdateLayers(self)
    
    self.back:SetLayer(self.layer + self.kBackgroundLayerOffset)
    self.veins:SetLayer(self.layer + self.kVeinsLayerOffset)
    
end

function GUIChallengeButtonAlien:Update(deltaTime)
    
    GUIChallengeButton.Update(self, deltaTime)
    
    if self.over then
        self.veinsPulse = 0.0
    else
        self.veinsPulse = self.veinsPulse + deltaTime
    end
    
    local pulse = math.cos(self.veinsPulse * self.kVeinsPulsePeriod) * 0.5 + 0.5
    self.veins:SetColor(Color(1,1,1,self.opacity * pulse))
    
end

function GUIChallengeButtonAlien:InitGUI()
    
    GUIChallengeButton.InitGUI(self)
    
    self.back = self:CreateGUIItem()
    self.back:SetTexture(self.kTexture)
    self.back:SetTexturePixelCoordinates(GUIUnpackCoords(self.kTextureCoords))
    
    self.veins = self:CreateGUIItem()
    self.veins:SetTexture(self.kTexture)
    self.veins:SetTexturePixelCoordinates(GUIUnpackCoords(self.kVeinsTextureCoords))
    
    self.veinsPulse = 0.0
    
end

function GUIChallengeButtonAlien:UpdateColor()
    
    GUIChallengeButton.UpdateColor(self)
    
    self.back:SetColor(Color(1,1,1,self.opacity))
    
end

function GUIChallengeButtonAlien:UpdateTransform()
    
    GUIChallengeButton.UpdateTransform(self)
    
    local size
    if self.over then
        size = Vector(self.kButtonOverSize)
    else
        size = Vector(self.kButtonSize)
    end
    
    local veinsSize = size - (Vector(self.kVeinsMargin, self.kVeinsMargin, 0) * 2.0)
    
    size = size * self.scale
    veinsSize = veinsSize * self.scale
    
    local backPos = self.position - (size * 0.5)
    local veinsPos = self.position - (veinsSize * 0.5)
    
    self.back:SetPosition(backPos)
    self.back:SetSize(size)
    
    self.veins:SetPosition(veinsPos)
    self.veins:SetSize(veinsSize)
    
end





