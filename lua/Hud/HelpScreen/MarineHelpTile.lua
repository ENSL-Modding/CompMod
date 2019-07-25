-- ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/Hud/HelpScreen/MarineHelpTile.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Displays information about a marine weapon.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Hud/HelpScreen/HelpTile.lua")

class "MarineHelpTile" (HelpTile)

MarineHelpTile.scanlinesShader = "shaders/GUIPlayMenuScanLinesMult.surface_shader"

MarineHelpTile.blockBackgroundTexture = PrecacheAsset("ui/helpScreen/marine_block_background.dds")
MarineHelpTile.blockBackgroundAnchorPoint = Vector(10, 12, 0)
MarineHelpTile.blockScanlinesLayer = 8
MarineHelpTile.blockScanlinesColor = Color(0.75, 0.75, 0.75, 1.0)

MarineHelpTile.descriptionBackgroundTexture = PrecacheAsset("ui/helpScreen/marine_description_background.dds")
MarineHelpTile.descriptionBackgroundAnchorPoint = Vector(3, 3, 0)
MarineHelpTile.descriptionScanlinesLayer = 8
MarineHelpTile.descriptionScanlinesColor = Color(0.875, 0.875, 0.875, 1.0)

MarineHelpTile.descriptionTextColor = Color( 139/255, 204/255, 241/255, 1)

function MarineHelpTile:Initialize()
    
    HelpTile.Initialize(self)
    
    self.blockScanlines = GUI.CreateItem()
    self.blockScanlines:SetTexture(self.blockBackgroundTexture)
    self.blockScanlines:SetShader(self.scanlinesShader)
    self.blockScanlines:SetBlendTechnique(GUIItem.Multiply)
    self.blockScanlines:SetLayer(self.blockScanlinesLayer)
    self.blockScanlines:SetColor(self.blockScanlinesColor)
    
    self.descriptionScanlines = GUI.CreateItem()
    self.descriptionScanlines:SetTexture(self.descriptionBackgroundTexture)
    self.descriptionScanlines:SetShader(self.scanlinesShader)
    self.descriptionScanlines:SetBlendTechnique(GUIItem.Multiply)
    self.descriptionScanlines:SetLayer(self.descriptionScanlinesLayer)
    self.descriptionScanlines:SetColor(self.descriptionScanlinesColor)
    
end

function MarineHelpTile:UpdatePositions()
    
    HelpTile.UpdatePositions(self)
    
    if self.blockScanlines then
        self.blockScanlines:SetPosition(self.blockBackground:GetPosition())
        self.blockScanlines:SetSize(self.blockBackground:GetSize())
        self.blockScanlines:SetScale(self.blockBackground:GetScale())
        self.blockScanlines:SetFloatParameter("rcpFrameX", 1.0 / (self.blockScanlines:GetSize().x * self.blockScanlines:GetScale().x))
        self.blockScanlines:SetFloatParameter("rcpFrameY", 1.0 / (self.blockScanlines:GetSize().y * self.blockScanlines:GetScale().y))
        self.blockScanlines:SetFloatParameter("resScale", self.scaling * 2.0)
    end
    
    if self.descriptionScanlines then
        self.descriptionScanlines:SetPosition(self.descriptionBackground:GetPosition())
        self.descriptionScanlines:SetSize(self.descriptionBackground:GetSize())
        self.descriptionScanlines:SetScale(self.descriptionBackground:GetScale())
        self.descriptionScanlines:SetFloatParameter("rcpFrameX", 1.0 / (self.descriptionScanlines:GetSize().x * self.descriptionScanlines:GetScale().x))
        self.descriptionScanlines:SetFloatParameter("rcpFrameY", 1.0 / (self.descriptionScanlines:GetSize().y * self.descriptionScanlines:GetScale().y))
        self.descriptionScanlines:SetFloatParameter("resScale", self.scaling)
    end
    
end

local function DestroyItem(item)
    
    if item == nil then
        return
    end
    
    if type(item) == "table" then
        for i=1, #item do
            DestroyItem(item[i])
        end
    else
        GUI.DestroyItem(item)
    end
    
end

function MarineHelpTile:Uninitialize()
    
    HelpTile.Uninitialize(self)
    
    DestroyItem(self.blockScanlines)
    self.blockScanlines = nil
    
    DestroyItem(self.descriptionScanlines)
    self.descriptionScanlines = nil
    
end

function MarineHelpTile:SetIsVisible(state)
    
    HelpTile.SetIsVisible(self, state)
    
    if self.blockScanlines then
        self.blockScanlines:SetIsVisible(self.visible)
    end
    
    if self.descriptionScanlines then
        self.descriptionScanlines:SetIsVisible(self.visible)
    end
    
end
