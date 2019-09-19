-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/GUIMainMenuInGame.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--    
--    Empty GUIObject that holds all menu-related items for in-game usage.
--    
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/menu2/GUIMainMenu.lua")
Script.Load("lua/menu2/NavBar/GUIMenuGameNavBar.lua")
Script.Load("lua/menu2/GUIMenuCloseMenuButton.lua")

---@class GUIMainMenuInGame : GUIMainMenu
class "GUIMainMenuInGame" (GUIMainMenu)

local kGridTexture = PrecacheAsset("ui/menu/grid.dds")
local kGridTextureShiftX = -2
local kGridTextureShiftY = -1
local kGridVerticalRepetitions = 6.25
local kGridOpacity = 0.333

function GetMainMenuClass()
    return GUIMainMenuInGame
end

function GUIMainMenuInGame:GetNavBarClass()
    return GUIMenuGameNavBar
end

function GUIMainMenuInGame:GetCornerButtonClass()
    return GUIMenuCloseMenuButton
end

function GUIMainMenuInGame:GetIsInGame()
    return true
end

function GUIMainMenuInGame:OnKey(key, down, held)
    
    if key == InputKey.Escape and down then
        self:Close()
    end
    
    return true
    
end

local function UpdateGridBackground(self, size)
    
    local textureSize = self.gridBackground:GetTextureSize()
    local scale = (size.y / kGridVerticalRepetitions) / textureSize.y
    self.gridBackground:SetScale(scale, scale)
    
    if scale <= 0 then scale = 0.01 end
    
    local itemSizeX = size.x / scale
    local itemSizeY = size.y / scale
    
    self.gridBackground:SetSize(itemSizeX, itemSizeY)
    
    local remainderX = itemSizeX % textureSize.x
    local remainderY = itemSizeY % textureSize.y
    self.gridBackground:SetTexturePixelCoordinates(-remainderX * 0.5 - kGridTextureShiftX, -remainderY * 0.5 - kGridTextureShiftY, -remainderX * 0.5 + itemSizeX - kGridTextureShiftX, -remainderY * 0.5 + itemSizeY - kGridTextureShiftY)
    
end

function GUIMainMenuInGame:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    GUIMainMenu.Initialize(self, params, errorDepth)
    
    self.gridBackground = self:CreateGUIItem()
    self.gridBackground:AlignCenter()
    self.gridBackground:SetTexture(kGridTexture)
    self.gridBackground:SetLayer(-1)
    self.gridBackground:SetColor(1, 1, 1, kGridOpacity)
    
    self:HookEvent(self, "OnSizeChanged", UpdateGridBackground)
    UpdateGridBackground(self, self:GetSize())
    
end
