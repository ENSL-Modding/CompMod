-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/GUIMenuScreen.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Base class for any "screen" in the options menu (eg "ServerBrowser", "Options",
--    "CustomizePlayer", etc.)
--  
--  Parameters (* = required)
--     *screenName          The name of this screen, which will be used to show or hide it.  Must
--                          be unique to this screen class.
--      parentScreenName    The name of the screen that this screen will return to when "back" is
--                          used.  If nil, no screen will display when back is used.
--  
--  Events:
--      OnScreenDisplay -- fires whenever the screen is displayed.
--          screen -- this menu screen
--      OnScreenHide -- fires whenever the screen is hidden.
--          screen -- this menu screen
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/GUIObject.lua")
Script.Load("lua/menu2/MenuScreenManager.lua")

---@class GUIMenuScreen : GUIObject
class 'GUIMenuScreen' (GUIObject)

-- Whether or not the screen is currently in its display position.
GUIMenuScreen:AddClassProperty("ScreenDisplayed", false)

function GUIMenuScreen:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    GUIObject.Initialize(self, params, errorDepth)
    
    AbstractClassCheck(self, "GUIMenuScreen")
    
    RequireType("string", params.screenName, "params.screenName", errorDepth)
    self.screenName = params.screenName
    GetScreenManager():RegisterScreen(self, params.screenName)
    
    self:ListenForKeyInteractions()
    
end

function GUIMenuScreen:GetScreenName()
    return self.screenName
end

function GUIMenuScreen:GetPreviousScreenName()
    return self.prevScreenName
end

function GUIMenuScreen:SetPreviousScreenName(name)
    RequireType({"string", "nil"}, name, "name", 2)
    if self.prevScreenName == name then
        return false
    end
    self.prevScreenName = name
    return true
end

-- Returns true if the screen can be hidden immediately, or false if there is some unfinished
-- business that requires user input.  The delayedCallback is expected to be called once whatever
-- was preventing the screen change has been rectified.
function GUIMenuScreen:RequestHide(delayedCallback)
    return true
end

function GUIMenuScreen:OnKey(key, down)
    
    -- Ignore if we're in-game.  This allows the call to fall through to GUIMainMenu, and thus
    -- close the menu immediately.  We don't want to get players killed by making the menu hard to
    -- close, now do we? :)
    if GetMainMenu():GetIsInGame() then
        return false
    end
    
    -- Ignore if this screen isn't active.
    if GetScreenManager():GetCurrentScreen() ~= self then
        return false
    end
    
    if key == InputKey.Escape and down and self:GetScreenDisplayed() then
        self:OnBack()
        return true
    end
    
    return false
    
end

function GUIMenuScreen:Display(immediate)
    
    if self:GetScreenDisplayed() then
        return false
    end
    
    self:SetScreenDisplayed(true)
    
    self:FireEvent("OnScreenDisplay", self)
    
    return true
    
end

function GUIMenuScreen:Hide()
    
    if not self:GetScreenDisplayed() then
        return false
    end
    
    self:SetScreenDisplayed(false)
    
    self:FireEvent("OnScreenHide", self)
    
    return true
    
end

function GUIMenuScreen:OnBack()
    GetScreenManager():DisplayPreviousScreen()
end

