-- ======= Copyright (c) 2017, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\challenge\GUIReplayDownloader.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Extends GUIReplayDownloader to provide the alien theme.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/challenge/GUIReplayDownloader.lua")

class 'GUIReplayDownloaderAlien' (GUIReplayDownloader)

GUIReplayDownloaderAlien.kColor = Color(219/255, 157/255, 35/255, 1)
GUIReplayDownloaderAlien.kButtonFontColor = Color(0,0,0,1)

GUIReplayDownloaderAlien.kButtonTexture = PrecacheAsset("ui/alien_buymenu.dds")
GUIReplayDownloaderAlien.kButtonTextureCoords = {396, 428, 706, 511}
GUIReplayDownloaderAlien.kButtonVeinsTextureCoords = { 600, 350, 915, 419}
local kVeinsMargin = 4
GUIReplayDownloaderAlien.kVeinsPulsePeriod = math.pi -- pulse once every two seconds.

GUIReplayDownloaderAlien.kButtonTextLayerOffset = 2
GUIReplayDownloaderAlien.kButtonVeinsLayerOffset = 1
GUIReplayDownloaderAlien.kButtonGraphicLayerOffset = 0

GUIReplayDownloaderAlien.kForegroundBarLayerOffset = 2
GUIReplayDownloaderAlien.kBarOuterLayerOffset = 1
GUIReplayDownloaderAlien.kBackgroundBarLayerOffset = 0

GUIReplayDownloaderAlien.kInfestedGraphicPosition = Vector(36, 95, 0)
GUIReplayDownloaderAlien.kInfestedGraphicSize = Vector(568, 60, 0)
GUIReplayDownloaderAlien.kBarPosition = Vector(46, 111, 0)
GUIReplayDownloaderAlien.kBarSize = Vector(540, 31, 0)
GUIReplayDownloaderAlien.kInfestedGraphicTexture = PrecacheAsset("ui/infested_marines/air_quality_bar_infestation.dds")
GUIReplayDownloaderAlien.kBarGraphicTexture = PrecacheAsset("ui/infested_marines/air_quality_bar_blue.dds")
GUIReplayDownloaderAlien.kFrontBarOpacity = 0.15

GUIReplayDownloaderAlien.kBackgroundShader = "shaders/GUISmokeAlpha.surface_shader"
GUIReplayDownloaderAlien.kBackgroundNoiseTexture = PrecacheAsset("ui/alien_commander_bg_smoke.dds")
GUIReplayDownloaderAlien.kBackgroundCorrectionFactor = 0.0025
GUIReplayDownloaderAlien.kBackgroundTexture = PrecacheAsset("ui/challenge/downloader_background_alien.dds")
GUIReplayDownloaderAlien.kBackgroundPosition = Vector( -92, -127, 0)
GUIReplayDownloaderAlien.kBackgroundSize = Vector(834, 496, 0)

GUIReplayDownloaderAlien.kButtonHoverSound = PrecacheAsset("sound/NS2.fev/alien/common/alien_menu/hover")
GUIReplayDownloaderAlien.kButtonClickSound = PrecacheAsset("sound/NS2.fev/alien/common/alien_menu/close_menu")

function GUIReplayDownloaderAlien:InitButton(newButton, buttonText)
    
    GUIReplayDownloader.InitButton(self, newButton, buttonText)
    
    local graphic = self:CreateGUIItem()
    graphic:SetTexture(self.kButtonTexture)
    graphic:SetTexturePixelCoordinates(GUIUnpackCoords(self.kButtonTextureCoords))
    newButton.graphic = graphic
    
    local veins = self:CreateGUIItem()
    veins:SetTexture(self.kButtonTexture)
    veins:SetTexturePixelCoordinates(GUIUnpackCoords(self.kButtonVeinsTextureCoords))
    newButton.veins = veins
    
    newButton.veinsPulse = 0
    
    local old_newButton_SetLayer = newButton.SetLayer
    newButton.SetLayer = function(button, layer)
        old_newButton_SetLayer(button, layer)
        button.graphic:SetLayer(layer + self.kButtonGraphicLayerOffset)
        button.veins:SetLayer(layer + self.kButtonVeinsLayerOffset)
    end
    
end

function GUIReplayDownloaderAlien:InitProgressBarGUI()
    
    GUIReplayDownloader.InitProgressBarGUI(self)
    
    local pb = self.progressBar
    
    local frame = self:CreateGUIItem()
    frame:SetTexture(self.kInfestedGraphicTexture)
    pb.frame = frame
    
    local backBar = self:CreateGUIItem()
    backBar:SetTexture(self.kBarGraphicTexture)
    backBar:SetIsVisible(false)
    pb.backBar = backBar
    
    local frontBar = self:CreateGUIItem()
    frontBar:SetTexture(self.kBarGraphicTexture)
    frontBar:SetColor(Color(1,1,1,self.kFrontBarOpacity))
    frontBar:SetIsVisible(false)
    pb.frontBar = frontBar
    
    pb.SetLayer = function(bar, layer)
        bar.backBar:SetLayer(layer + self.kBackgroundBarLayerOffset)
        bar.frame:SetLayer(layer + self.kBarOuterLayerOffset)
        bar.frontBar:SetLayer(layer + self.kForegroundBarLayerOffset)
    end
    
    pb.SetOpacity = function(bar, opacity)
        bar.backBar:SetColor(Color(1,1,1,opacity))
        bar.frame:SetColor(Color(1,1,1,opacity))
        bar.frontBar:SetColor(Color(1,1,1, self.kFrontBarOpacity * opacity))
    end
    
end

function GUIReplayDownloaderAlien:UpdateColor()
    
    GUIReplayDownloader.UpdateColor(self)
    
    local opacity = self:GetOpacity()
    
    local fullWhite = Color(1,1,1,opacity)
    if self.backItem then
        self.backItem:SetColor(fullWhite)
    end
    
    if self.progressBar then
        self.progressBar:SetOpacity(opacity)
    end
    
    for i=1, #self.buttons do
        self.buttons[i].graphic:SetColor(fullWhite)
    end
    
    self:UpdateVeinsOpacity(0)
    
end

function GUIReplayDownloaderAlien:UpdateVeinsOpacity(deltaTime)
    
    local opacity = self:GetOpacity()
    
    for i=1, #self.buttons do
        local button = self.buttons[i]
        button.veinsPulse = button.veinsPulse + deltaTime
        if button.over then
            button.veinsPulse = 0
        end
        
        local veinOpacity = (math.cos(button.veinsPulse * self.kVeinsPulsePeriod) * 0.5 + 0.5) * opacity
        button.veins:SetColor(Color(1,1,1,veinOpacity))
    end
    
end

function GUIReplayDownloaderAlien:Update(deltaTime)
    
    GUIReplayDownloader.Update(self, deltaTime)
    
    self:UpdateVeinsOpacity(deltaTime)
    
end

function GUIReplayDownloaderAlien:DestroyButton(button)
    
    GUIReplayDownloader.DestroyButton(self, button)
    
    self:DestroyGUIItem(button.graphic)
    self:DestroyGUIItem(button.veins)
    
end

function GUIReplayDownloaderAlien:UpdateProgressBarFill()
    
    GUIReplayDownloader.UpdateProgressBarFill(self)
    
    self:UpdateProgressFraction()
    local fill = self.progressFraction or 0.0
    
    if fill <= 0.0 then
        self.progressBar.frontBar:SetIsVisible(false)
        self.progressBar.backBar:SetIsVisible(false)
    else
        self.progressBar.frontBar:SetIsVisible(true)
        self.progressBar.backBar:SetIsVisible(true)
        local barSize = self.kBarSize * self.scale * Vector(fill, 1, 0)
        self.progressBar.frontBar:SetSize(barSize)
        self.progressBar.backBar:SetSize(barSize)
        self.progressBar.frontBar:SetTextureCoordinates(0, 0, fill, 1)
        self.progressBar.backBar:SetTextureCoordinates(0, 0, fill, 1)
    end
    
end

function GUIReplayDownloaderAlien:UpdateProgressBarTransform()
    
    GUIReplayDownloader.UpdateProgressBarTransform(self)
    
    local framePos = (self.kInfestedGraphicPosition * self.scale) + self.position
    local frameSize = self.kInfestedGraphicSize * self.scale
    self.progressBar.frame:SetPosition(framePos)
    self.progressBar.frame:SetSize(frameSize)
    
    local barPos = (self.kBarPosition * self.scale) + self.position
    self.progressBar.frontBar:SetPosition(barPos)
    self.progressBar.backBar:SetPosition(barPos)
    
    -- Update progress bar fill
    self:UpdateProgressBarFill()
    
end

function GUIReplayDownloaderAlien:UpdateButtonTransform(button)
    
    GUIReplayDownloader.UpdateButtonTransform(self, button)
    
    local buttonSize = self.kButtonSize
    if button.over then
        buttonSize = self.kButtonOverSize
    end
    
    local veinsSize = buttonSize - (Vector(kVeinsMargin, kVeinsMargin, 0) * 2.0)
    
    buttonSize = buttonSize * self.scale
    veinsSize = veinsSize * self.scale
    
    local graphicPos = button.position - (buttonSize * 0.5)
    local veinsPos = button.position - (veinsSize * 0.5)
    
    button.graphic:SetPosition(graphicPos)
    button.graphic:SetSize(buttonSize)
    
    button.veins:SetPosition(veinsPos)
    button.veins:SetSize(veinsSize)
    
end

function GUIReplayDownloaderAlien:UpdateLayers()
    
    GUIReplayDownloader.UpdateLayers(self)
    
    if self.backItem then
        self.backItem:SetLayer(self.layer + self.kBackgroundLayerOffset)
    end
    
end

function GUIReplayDownloaderAlien:UpdateTransform()
    
    GUIReplayDownloader.UpdateTransform(self)
    
    if self.backItem then
        self.backItem:SetPosition((self.kBackgroundPosition * self.scale) + self.position)
        self.backItem:SetSize(self.kBackgroundSize * self.scale)
        
        local texSize = Vector(self.backItem:GetTextureWidth(), self.backItem:GetTextureHeight(), 0)
        self.backItem:SetFloatParameter("correctionX", self.kBackgroundCorrectionFactor * texSize.x)
        self.backItem:SetFloatParameter("correctionY", self.kBackgroundCorrectionFactor * texSize.y)
    end
    
end

function GUIReplayDownloaderAlien:InitializeGUI()
    
    GUIReplayDownloader.InitializeGUI(self)
    
    self.backItem = self:CreateGUIItem()
    self.backItem:SetShader(self.kBackgroundShader)
    self.backItem:SetTexture(self.kBackgroundTexture)
    self.backItem:SetAdditionalTexture("noise", self.kBackgroundNoiseTexture)
    self.backItem:SetFloatParameter("timeOffset", math.random() * 20)
    
    local texSize = Vector(self.backItem:GetTextureWidth(), self.backItem:GetTextureHeight(), 0)
    self.backItem:SetFloatParameter("correctionX", self.kBackgroundCorrectionFactor * texSize.x)
    self.backItem:SetFloatParameter("correctionY", self.kBackgroundCorrectionFactor * texSize.y)
    
end

function GUIReplayDownloaderAlien:DoFadeIn()
    
    GUIReplayDownloader.DoFadeIn(self)
    
    self.backItem:SetFloatParameter("fadeStartTime", Shared.GetTime())
    self.backItem:SetFloatParameter("fadeEndTime", Shared.GetTime() + self.kFadeTime)
    self.backItem:SetFloatParameter("fadeTarget", 1.0)
    
end

function GUIReplayDownloaderAlien:DoFadeOut()
    
    GUIReplayDownloader.DoFadeOut(self)
    
    self.backItem:SetFloatParameter("fadeStartTime", Shared.GetTime())
    self.backItem:SetFloatParameter("fadeEndTime", Shared.GetTime() + self.kFadeTime)
    self.backItem:SetFloatParameter("fadeTarget", 0.0)
    
end




