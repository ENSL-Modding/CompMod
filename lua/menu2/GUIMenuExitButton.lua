-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/GUIMenuExitButton.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--    
--    The power symbol that appears in the upper-right corner of the screen of the main menu, to
--    quit the game.
--    
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/GUIGlobalEventDispatcher.lua")
Script.Load("lua/menu2/widgets/GUIMenuPowerButton.lua")

---@class GUIMenuExitButton : GUIMenuPowerButton
class "GUIMenuExitButton" (GUIMenuPowerButton)

GUIMenuExitButton.kShadowScale = Vector(10, 5, 1)

local function UpdateResolutionScalingAndPosition(self, newX, newY, oldX, oldY)
    
    local mockupRes = Vector(3840, 2160, 0)
    local res = Vector(newX, newY, 0)
    local scale = res / mockupRes
    scale = math.min(scale.x, scale.y)
    
    self:SetScale(scale, scale)
    self:SetPosition(self.kOffset * scale)

end

function GUIMenuExitButton:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    GUIMenuPowerButton.Initialize(self, params, errorDepth)
    
    self:HookEvent(self, "OnPressed", self.OnPressed)
    self:HookEvent(GetGlobalEventDispatcher(), "OnResolutionChanged", UpdateResolutionScalingAndPosition)
    
    UpdateResolutionScalingAndPosition(self, Client.GetScreenWidth(), Client.GetScreenHeight())
    
    self:AlignTopRight()
    
end

function GUIMenuExitButton:OnPressed()
    
    local currentScreen = GetScreenManager():GetCurrentScreen()
    if not currentScreen then
        Client.Exit()
        return
    end
    
    -- Request the current screen to be hidden so it can protest if needed (eg "unsaved changes!")
    if currentScreen:RequestHide(Client.Exit) then
        Client.Exit()
    end
    
end
