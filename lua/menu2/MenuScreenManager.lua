-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/MenuScreenManager.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Singleton class for managing the flow of navigation around the new main menu.  Responsible for
--    displaying screens, as well as handling "go back to previous screen"-style behavior.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/OrderedSet.lua")

---@class MenuScreenManager
class 'MenuScreenManager'

local screenManager

function GetScreenManager()
    
    if not screenManager then
        screenManager = MenuScreenManager()
        screenManager:Initialize()
    end
    
    return screenManager
    
end

function MenuScreenManager:Initialize()
    
    -- Dictionary of screenName -> screen instance mappings.
    self.screens = {}
    
    self.currentScreen = nil
    
end

function MenuScreenManager:GetScreen(screenName)
    return self.screens[screenName]
end

function MenuScreenManager:RegisterScreen(screen, screenName)
    
    assert(self.screens[screenName] == nil) -- screen with the same name already exists!
    AssertIsaGUIObject(screen)
    assert(screen:isa("GUIMenuScreen"))
    
    self.screens[screenName] = screen
    
end

-- Displays the screen registered as the given name.  Returns true if the given screen is displayed
-- after this call (eg it changed, or was already on this screen), false if it is not being
-- displayed (eg screen doesn't exist or something blocked the request).
function MenuScreenManager:DisplayScreen(screenName, immediate, backwards)
    
    assert(type(screenName) == "string")
    assert(screenName ~= "")
    
    local screen = self.screens[screenName]
    
    -- Ensure this is a valid screenName...
    if not screen then
        Log("ERROR: Screen named '%s' not found!", screenName)
        return false
    end
    
    -- See if we're already displaying the screen.
    if self.currentScreen and screenName == self.currentScreen:GetName() then
        return true -- we're already displaying this screen!
    end
    
    -- Check if the current screen will allow us to switch off it.  Ignore if immediate mode is set.
    if not immediate and self.currentScreen then
        local delayedCallback = function() GetScreenManager():DisplayScreen(screenName) end
        if not self.currentScreen:RequestHide(delayedCallback) then
            return false -- current screen forbids us from switching off it.
        end
    end
    
    -- Hide the current screen.
    if self.currentScreen then
        self.currentScreen:Hide()
        
        -- Inform the new current screen where we came from.
        if not backwards then
            screen:SetPreviousScreenName(self.currentScreen:GetScreenName())
        end
        
    end
    
    -- Display the new previous screen.
    self.currentScreen = screen
    screen:Display(immediate)
    
    return true
    
end

function MenuScreenManager:GetCurrentScreen()
    return self.currentScreen
end

function MenuScreenManager:GetCurrentScreenName()
    local result = self.currentScreen:GetScreenName()
    return result
end

function MenuScreenManager:DisplayPreviousScreen(immediate)
    
    local currentScreen = self:GetCurrentScreen() or self:GetScreen("NavBar")
    assert(currentScreen ~= nil)
    local previousScreenName = currentScreen:GetPreviousScreenName()
    previousScreenName = previousScreenName or "NavBar" -- default to nav bar if no previous screen.
    
    local previousScreen = self:GetScreen(previousScreenName) or self:GetScreen("NavBar")
    assert(previousScreen)
    
    self:DisplayScreen(previousScreenName, immediate, true)
    
end
