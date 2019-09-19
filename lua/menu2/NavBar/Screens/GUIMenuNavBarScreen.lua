-- ======= Copyright (c) 2017, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/NavBar/Screens/GUIMenuNavBarScreen.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Screen class for the screens that slide down out of the nav bar.
--
--  Dispatched Events:
--      OnScreenDisplay -- fires whenever the screen is displayed.
--      OnScreenHide -- fires whenever the screen is hidden.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/menu2/GUIMenuScreen.lua")

---@class GUIMenuNavBarScreen : GUIMenuScreen
class 'GUIMenuNavBarScreen' (GUIMenuScreen)

function GUIMenuNavBarScreen:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    GUIMenuScreen.Initialize(self, params, errorDepth)
    
    self:SetPosition(0, GUIMenuNavBar.kScreenYOffsetWhenClosed)
    self:SetHotSpot(0, 1)
    
    self:BlockChildInteractions()
    
end

function GUIMenuNavBarScreen:Display(immediate)
    
    if not GUIMenuScreen.Display(self, immediate) then
        return -- already being displayed!
    end
    
    self:AllowChildInteractions()
    
    if immediate then
        self:ClearPropertyAnimations("HotSpot")
        self:ClearPropertyAnimations("Position")
        self:SetHotSpot(self:GetHotSpot().x, 0)
        self:SetPosition(self:GetPosition().x, 0)
    else
        self:AnimateProperty("HotSpot", Vector(self:GetHotSpot().x, 0, 0), MenuAnimations.FlyIn)
        self:AnimateProperty("Position", Vector(self:GetPosition().x, 0, 0), MenuAnimations.FlyIn)
    end
    
end

function GUIMenuNavBarScreen:Hide()
    
    if not GUIMenuScreen.Hide(self) then
        return -- already hidden!
    end
    
    self:BlockChildInteractions()
    
    self:AnimateProperty("HotSpot", Vector(self:GetHotSpot().x, 1, 0), MenuAnimations.FlyIn)
    self:AnimateProperty("Position", Vector(self:GetPosition().x, GUIMenuNavBar.kScreenYOffsetWhenClosed, 0), MenuAnimations.FlyIn)
    
end

