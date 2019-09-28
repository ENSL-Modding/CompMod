-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/GUIMainMenu.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--    
--    Empty GUIObject that holds all menu-related items.
--
--  Events
--      OnOpened        Menu was opened.
--      OnClosed        Menu was closed.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/GUIObject.lua")
Script.Load("lua/GUI/GUIGlobalEventDispatcher.lua")
Script.Load("lua/menu2/GUIMenuTooltipManager.lua")
Script.Load("lua/menu2/GUIMenuExitButton.lua")
Script.Load("lua/menu2/GUIMenuWikiButton.lua")
Script.Load("lua/menu2/MenuScreenManager.lua")
Script.Load("lua/menu2/NavBar/GUIMenuNavBar.lua")
Script.Load("lua/menu2/GUILocalPlayerProfileData.lua")
Script.Load("lua/menu2/ExtraMenuButtons/GUIMenuExtraButtons.lua")

Script.Load("lua/menu2/MissionScreen/GUIMenuMissionScreen.lua")
Script.Load("lua/menu2/popup/GUIMenuPopupIconMessage.lua")

Script.Load("lua/menu2/items/bundles.lua")
Script.Load("lua/menu2/items/drops.lua")

---@class GUIMainMenu : GUIObject
class "GUIMainMenu" (GUIObject)

function GetMainMenuClass()
    return GUIMainMenu
end

local mainMenu
function CreateMainMenu()
    assert(not mainMenu)
    mainMenu = CreateGUIObject("mainMenu", GetMainMenuClass())
end

function GetMainMenu()
    return mainMenu
end

function GUIMainMenu:GetNavBarClass()
    return GUIMenuNavBar
end

function GUIMainMenu:GetCornerButtonClass()
    return GUIMenuExitButton
end

local function UpdateSizeFromResolution(self, width, height)
    self:SetSize(width, height)
end

function GUIMainMenu:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    mainMenu = self
    
    GUIObject.Initialize(self, params, errorDepth)
    self:GetRootItem():SetDebugName("mainMenu")
    
    Shared.Message("Main Menu Initialized at Version: " .. Shared.GetBuildNumber())
    Shared.Message("Steam Id: " .. Client.GetSteamId())
    
    -- Reasonably high, should be above most everything else.
    self:SetLayer(GetLayerConstant("MainMenu", 500))
    
    -- Ensure player profile data object exists, and is getting up-to-date data.
    CreateGUIObject("profileDataObject", GUILocalPlayerProfileData)
    
    -- Hook up restartmain command if player isn't in-game.
    if not Client.GetIsConnected() then
        Event.Hook("Console_restartmain", function() Client.RestartMain() end)
    end
    
    -- Set initial state of mouse cursor.  We want it visible, but not clipped if this isn't in-game.
    MouseTracker_SetIsVisible(true, "ui/Cursor_MenuDefault.dds", self:GetIsInGame())
    
    self:HookEvent(GetGlobalEventDispatcher(), "OnResolutionChanged", UpdateSizeFromResolution)
    UpdateSizeFromResolution(self, Client.GetScreenWidth(), Client.GetScreenHeight())
    
    self:HookEvent(self, "OnVisibleChanged",
        function(self, visible)
            if visible then
                MouseTracker_SetIsVisible(true, "ui/Cursor_MenuDefault.dds", self:GetIsInGame())
            else
                MouseTracker_SetIsVisible(false)
            end
        end)
    
    -- Main menu consumes mouse clicks when it is open (visible).
    self:ListenForCursorInteractions()
    self:ListenForKeyInteractions()
    self:ListenForWheelInteractions()
    
    -- Create disconnect/exit button in the upper-right corner.
    CreateGUIObject("cornerButton", self:GetCornerButtonClass(), self)

    -- Create wiki button in the upper-left corner.
    CreateGUIObject("wikiButton", GUIMenuWikiButton, self)

    -- Create navigation bar.
    self.navBar = CreateGUIObject("navBar", self:GetNavBarClass(), self)
    local screenManager = GetScreenManager()
    if screenManager:GetCurrentScreen() == nil then
        screenManager:DisplayScreen("NavBar")
    end
    
    -- Create mission screen.
    self.missionScreen = CreateGUIObject("missionScreen", GUIMenuMissionScreen, self)

    -- Check for new items received whenever the user opens the menu.
    self:HookEvent(self, "OnOpened", function()
        DoPopupsForNewlyReceivedItems( GetCustomizeScreen().RefreshOwnedItems )
    end)
    
    self:SetVisible(false)
    if not self:GetIsInGame() then
        self:Open() -- open menu by default if player not in-game.
    end
    
end

-- List of functions to call, in order, to display notifications to the user.  Each function is
-- expected to return true if the next function can be called immediately, or false if it should
-- wait to be called again at a later time (eg a popup was opened).
local kNotificationFuncs =
{
    DoPopupsForNewlyReceivedItems,
    DoPopupsForUnopenedBundles,
}
local kNotificationActive = false -- whether or not a notification popup is active.
function CheckForNotificationsHelper(idx)
    
    kNotificationActive = true
    
    while idx <= #kNotificationFuncs do
        
        local func = kNotificationFuncs[idx]
        local nextFunc =
            function()
                CheckForNotificationsHelper(idx + 1)
            end
    
        -- If a popup was opened, terminate the loop here.  If there is still work to be done, it
        -- will be picked up again via the call to nextFunc, which just calls this function again
        -- with the index of the next notification function to be called.
        
        if not func(nextFunc) then
            return
        end
        
        idx = idx + 1
        
    end
    
    kNotificationActive = false
    
end

function GUIMainMenu:CheckForNewNotifications()
    
    if kNotificationActive then
        return -- there is already a notification popup being presented
    end
    
    CheckForNotificationsHelper(1)
end

function GUIMainMenu:Open()
    
    if self:GetVisible() then
        return -- already open.
    end
    
    self:SetVisible(true)
    self:SetModal()
    
    self:FireEvent("OnOpened")
    
    PlayMenuSound("MenuLoop")
    
end

function GUIMainMenu:Close()
    
    if not self:GetVisible() then
        return -- already closed.
    end
    
    self:ClearModal()
    self:SetVisible(false)
    
    if self:GetIsInGame() then
        ClientUI.EvaluateUIVisibility(Client.GetLocalPlayer())
    end
    
    self:FireEvent("OnClosed")
    
    StopMenuSound("MenuLoop")
    
end

function GUIMainMenu:GetIsInGame()
    return false
end

function GUIMainMenu:OnKey(key, down, held)
    
    -- Close menu if player hits escape in the main menu.
    if self:GetIsInGame() and key == InputKey.Escape and down then
        self:Close()
        return true
    end
    
    return false
    
end

function GUIMainMenu:PlayMusic(fileName)
    
    if fileName ~= nil and type(fileName) ~= "string" then
        error(string.format("Expected either a fileName for music to play, or nil to stop the music.  Got '%s' instead.", fileName), 2)
    end
    
    if self.currentMusic ~= nil then
        Client.StopMusic(self.currentMusic)
    end
    
    self.currentMusic = fileName
    
    if self.currentMusic ~= nil then
        Client.PlayMusic(self.currentMusic)
    end
    
end

function GUIMainMenu:DisplayPopupMessage(message, title)
    
    if not message or message == "" then return end
    title = title or ""
    
    local popup = CreateGUIObject("popup", GUIMenuPopupSimpleMessage, nil,
    {
        title = title, -- already run through locale.
        message = message,
        buttonConfig =
        {
            GUIPopupDialog.OkayButton,
        },
    })
    
end

-- Special command for returning veteran  players to skip tutorials.
Event.Hook("Console_iamsquad5", function()
    Shared.Message("Welcome back!")
    Log("Welcome back!")
    Client.SetAchievement("First_0_1")
end)

---------------------------------------------------------
-- LEGACY FUNCTIONS (kept for backwards compatibility) --
---------------------------------------------------------

function LeaveMenu()
    
    GetMainMenu():Close()
    GetMainMenu():PlayMusic(nil)
    
end

function MainMenu_GetIsOpened()
    local menu = GetMainMenu()
    local result = menu ~= nil and menu:GetVisible()
    return result
end

function MainMenu_GetIsInGame()
    return (Client.GetIsConnected())
end

--
-- Called when the user selects the "Host Game" button in the main menu.
--
function MainMenu_HostGame(mapFileName, _, hidden)

    local port = 27015
    local maxPlayers = Client.GetOptionInteger("playerLimit", 16)
    local password = Client.GetOptionString("serverPassword", "")
    local serverName = Client.GetOptionString("serverName", "Listen Server")
    
    MainMenu_OnConnect()
    
    Client.StartServer(mapFileName, serverName, password, port, maxPlayers, false, hidden)
    
end

local kConnectSound = "sound/NS2.fev/common/connect"
Client.PrecacheLocalSound(kConnectSound)
function MainMenu_OnConnect()
    StartSoundEffect(kConnectSound)
end
