-- ======= Copyright (c) 2012, Unknown Worlds Entertainment, Inc. All rights reserved. ==========
--
-- lua\GUILeftMinigunDisplay.lua
--
-- Created by: Brian Cronin (brianc@unknownworlds.com)
--
-- Displays the heat amount for the Exo's Minigun.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

local animHeatAmount = 0
local animHeatDir = 1

local background

local foreground, foregroundMask

local alertLight

local time = 0

local kTexture = "models/marine/exosuit/exosuit_view_panel_mini2.dds"

-- Allow the interface to be scaled down.  This helps avoid aliasing artifacts due to the resulting
-- texture of this script not generating mipmap levels.
scaleFactor = 1.0
prevScaleFactor = nil

function UpdateOverHeat(dt, heatAmount)

    PROFILE("GUILeftMinigunDisplay:Update")
    
    foregroundMask:SetSize(Vector(242, 720 * (1 - heatAmount), 0) * scaleFactor)
    
    local alertColor = Color(1, 1, 1, 1)
    if heatAmount > 0.5 then
    
        animHeatAmount = animHeatAmount + ((animHeatDir * dt) * 10 * heatAmount)
        if animHeatAmount > 1 then
        
            animHeatAmount = 1
            animHeatDir = -1
            
        elseif animHeatAmount < 0 then
        
            animHeatAmount = 0
            animHeatDir = 1
            
        end
        alertColor = Color(heatAmount, animHeatAmount * (1 - ((heatAmount - 0.5) / 0.5)), 0, 1)
        
    end
    alertLight:SetColor(alertColor)
    
    time = time + dt
    
    if scaleFactor ~= prevScaleFactor then
        prevScaleFactor = scaleFactor
        
        GUI.SetSize(242 * scaleFactor, 720 * scaleFactor)
        background:SetSize(Vector(242, 720, 0) * scaleFactor)
        foreground:SetSize(Vector(242, 720, 0) * scaleFactor)
        foregroundMask:SetSize(Vector(242, 720, 0) * scaleFactor)
        alertLight:SetSize(Vector(60, 720, 0) * scaleFactor)
    end
    
end

function Initialize()
    
    GUI.SetSize(242 * scaleFactor, 720 * scaleFactor)
    
    background = GUI.CreateItem()
    background:SetPosition(Vector(0, 0, 0))
    background:SetTexturePixelCoordinates(0, 0, 242, 720)
    background:SetTexture(kTexture)
    
    foreground = GUI.CreateItem()
    foreground:SetPosition(Vector(0, 0, 0))
    foreground:SetTexturePixelCoordinates(330, 0, 572, 720)
    foreground:SetTexture(kTexture)
    foreground:SetStencilFunc(GUIItem.Equal)
    
    foregroundMask = GUI.CreateItem()
    foregroundMask:SetPosition(Vector(0, 0, 0))
    foregroundMask:SetIsStencil(true)
    foregroundMask:SetClearsStencilBuffer(true)
    
    foregroundMask:AddChild(foreground)
    
    alertLight = GUI.CreateItem()
    alertLight:SetPosition(Vector(0, 0, 0))
    alertLight:SetTexturePixelCoordinates(264, 0, 324, 720)
    alertLight:SetTexture(kTexture)
    
    background:AddChild(foregroundMask)
    background:AddChild(alertLight)
    
end

Initialize()