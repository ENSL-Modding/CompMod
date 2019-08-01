-- ======= Copyright (c) 2012, Unknown Worlds Entertainment, Inc. All rights reserved. ==========
--
-- lua\GUIBabblerMoveIndicator.lua
--
-- Created by: Andreas Urwalek (andi@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUIScript.lua")
Script.Load("lua/Babbler.lua")

class 'GUIBabblerMoveIndicator' (GUIScript)

local kIconSize = GUIScale(Vector(128, 128, 0))
local kIconAnimationVector = GUIScale(Vector(0, 16, 0))
local kIconTexture = "ui/babbler_move_icons.dds"

local kIconOffset = GUIScale(Vector(0, 196, 0))

local kMoveTypeTexCoords = {

    [kBabblerMoveType.Move] = { 0, 0, 128, 128 },
    [kBabblerMoveType.Attack] = { 128, 0, 256, 128 },
    [kBabblerMoveType.Cling] = { 256, 0, 384, 128 },

}

local function GetBabblerMoveType()

    local moveType = kBabblerMoveType.Move
    local player = Client.GetLocalPlayer()
    if player and player:GetActiveWeapon() and player:GetActiveWeapon():isa("BabblerAbility") then
        moveType = player:GetActiveWeapon():GetBabblerMoveType()
    end
    
    return moveType

end

function GUIBabblerMoveIndicator:OnResolutionChanged(oldX, oldY, newX, newY)
    kIconSize = GUIScale(Vector(128, 128, 0))
    kIconAnimationVector = GUIScale(Vector(0, 16, 0))
    kIconOffset = GUIScale(Vector(0, 196, 0))
    
    self:Uninitialize()
    self:Initialize()
end

function GUIBabblerMoveIndicator:Initialize()

    self.icon = GetGUIManager():CreateGraphicItem()
    self.icon:SetSize(kIconSize)
    self.icon:SetTexture(kIconTexture)
    self.icon:SetAnchor(GUIItem.Middle, GUIItem.Center)
    
    self.visible = true
    self.iconVisible = true
    
    self:Update(0)
    
    HelpScreen_AddObserver(self)

end

function GUIBabblerMoveIndicator:OnHelpScreenVisChange(state)
    
    self.visible = not state
    self:UpdateVisibility()
    
end

function GUIBabblerMoveIndicator:UpdateVisibility()
    
    local vis = self.visible and self.iconVisible
    self.icon:SetIsVisible(vis)
    
end

function GUIBabblerMoveIndicator:Uninitialize()

    if self.icon then
        GUI.DestroyItem(self.icon)
        self.icon = nil
    end
    
    HelpScreen_RemoveObserver(self)

end

function GUIBabblerMoveIndicator:Update(deltaTime)
            
    PROFILE("GUIBabblerMoveIndicator:Update")
    
    local currentMoveType = GetBabblerMoveType()
    local texCoords = kMoveTypeTexCoords[currentMoveType]
    
    if texCoords then
    
        self.icon:SetTexturePixelCoordinates(GUIUnpackCoords(texCoords))
        self.iconVisible = true
        
        local animation = math.sin(Shared.GetTime() * 2)
        local iconPos = -kIconSize *.5 + kIconAnimationVector * animation + kIconOffset
        self.icon:SetPosition(iconPos)
        
    else
        self.iconVisible = false
    end
    
    self:UpdateVisibility()
    
end

