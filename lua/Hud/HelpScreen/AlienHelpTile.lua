-- ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/Hud/HelpScreen/AlienHelpTile.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Displays information about an alien ability.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Hud/HelpScreen/HelpTile.lua")

class "AlienHelpTile" (HelpTile)

AlienHelpTile.blockBackgroundTexture = PrecacheAsset("ui/helpScreen/alien_block_background.dds")
AlienHelpTile.blockBackgroundAnchorPoint = Vector(1, 15, 0)
AlienHelpTile.blockBackgroundWaveMask = PrecacheAsset("ui/helpScreen/alien_block_wavy_mask.dds")
AlienHelpTile.blockBackgroundShader = "shaders/GUIWavySaturation.surface_shader"

AlienHelpTile.descriptionBackgroundTexture = PrecacheAsset("ui/helpScreen/alien_description_background.dds")
AlienHelpTile.descriptionBackgroundAnchorPoint = Vector(47, 75, 0)
AlienHelpTile.descriptionTextColor = Color( 1.0, 196/255, 58/255, 1)
AlienHelpTile.descriptionSmokeyShader = "shaders/GUISmokeSaturation.surface_shader"
AlienHelpTile.kBackgroundNoiseTexture = PrecacheAsset("ui/alien_commander_bg_smoke.dds")
AlienHelpTile.tileSize = 250

function AlienHelpTile:Initialize()
    
    HelpTile.Initialize(self)
    
    self.blockBackground:SetShader(self.blockBackgroundShader)
    self.blockBackground:SetAdditionalTexture("wavyMask", self.blockBackgroundWaveMask)
    
    self.descriptionBackground:SetShader(self.descriptionSmokeyShader)
    self.descriptionBackground:SetAdditionalTexture("noise", self.kBackgroundNoiseTexture)
    self.descriptionBackground:SetFloatParameter("correctionX", self.descriptionBackground:GetSize().x / self.tileSize)
    self.descriptionBackground:SetFloatParameter("correctionY", self.descriptionBackground:GetSize().y / self.tileSize)
    self.descriptionBackground:SetFloatParameter("timeOffset", math.random() * 20)
    
end

function AlienHelpTile:UpdatePositions()
    
    HelpTile.UpdatePositions(self)
    
    self.descriptionBackground:SetFloatParameter("correctionX", self.descriptionBackground:GetSize().x / self.tileSize)
    self.descriptionBackground:SetFloatParameter("correctionY", self.descriptionBackground:GetSize().y / self.tileSize)
    
end