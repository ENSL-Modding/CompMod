--=============================================================================
--
-- lua/MainMenu.lua
--
-- Created by Max McGuire (max@unknownworlds.com)
-- Copyright 2011, Unknown Worlds Entertainment
--
--=============================================================================

Script.Load("lua/OptionsDialog.lua")
Script.Load("lua/MenuManager.lua")
Script.Load("lua/SoundEffect.lua")

-- DEPRECATED

--[===[

Script.Load("lua/InterfaceSounds_Client.lua")
Script.Load("lua/CreateServer.lua")

Script.Load("lua/BindingsDialog.lua")

Script.Load("lua/DSPEffects.lua")

Script.Load("lua/ServerPerformanceData.lua")

CreateDSPs()

-- Change this to false if loading the main menu is slowing down debugging too much
local kAllowDebuggingMainMenu = true

local mainMenuMusic, mainMenuAlertMessage

mods = { "ns2" }
mapnames, maps = GetInstalledMapList()

local loadLuaMenu = true
local gMainMenu
local gForceJoin = false

--[==[
function MainMenu_GetIsOpened()
    
    return GetMainMenu():GetIsVisible()
    --[=[
    -- Don't load or open main menu while debugging (too slow).
    if not GetIsDebugging() or kAllowDebuggingMainMenu then
    
        if loadLuaMenu then
        
            if not gMainMenu then
                return false
            else
                return gMainMenu:GetIsVisible()
            end
            
        else
            return MenuManager.GetMenu() ~= nil
        end
        
    end
    
    return false
    --]=]
    
end
--]==]

function LeaveMenu()

    MainMenu_OnCloseMenu()
    
    if gMainMenu then
        gMainMenu:SetVisible(false)
    end
    
    --MenuManager.SetMenuCinematic(nil)
    GetMainMenu():PlayMusic(nil)
    
end



local gSelectedServerNum, gSelectedServerData, gSelectedServerEntry
function MainMenu_SelectServer(serverNum, serverData, serverEntry)
    gSelectedServerNum = serverNum
    gSelectedServerData = serverData
    gSelectedServerEntry = serverEntry
end

function MainMenu_GetSelectedServer()
    return gSelectedServerNum
end

function MainMenu_GetSelectedServerData()
    return gSelectedServerData
end

local gPassword
function MainMenu_SetSelectedServerPassword(password)
    gPassword = password
end

function MainMenu_GetSelectedRequiresPassword()

    if gSelectedServerNum and gSelectedServerData then
        return gSelectedServerData.requiresPassword
    end
    
    return false
    
end

function MainMenu_GetSelectedIsFull()
    
    if gSelectedServerNum and gSelectedServerData then
        local numReservedSlots = GetNumServerReservedSlots(gSelectedServerNum)
        return Client.GetServerNumPlayers(gSelectedServerNum) >= Client.GetServerMaxPlayers(gSelectedServerNum) - numReservedSlots
    end
    
end

function MainMenu_GetSelectedHasSpectatorSlots()

    if gSelectedServerNum and gSelectedServerData then
        return Client.GetServerNumSpectators(gSelectedServerNum) < Client.GetServerMaxSpectators(gSelectedServerNum)
    end

end

function MainMenu_GetSelectedIsFullWithNoRS()

    if gSelectedServerNum and gSelectedServerData then
        return Client.GetServerNumPlayers(gSelectedServerNum) >= Client.GetServerMaxPlayers(gSelectedServerNum)
    end
    
end

function MainMenu_GetSelectedIsHighPlayerCount()
    
    if gSelectedServerNum and gSelectedServerData then
        return gSelectedServerData.maxPlayers > 24
    end
    
end

function MainMenu_GetSelectedIsFavorited()
    if gSelectedServerNum and gSelectedServerData then
        return gSelectedServerData.favorite
    end
end

function MainMenu_GetSelectedIsNetworkModded()
    if gSelectedServerNum and gSelectedServerData then
        return gSelectedServerData.customNetworkSettings
    end
end

function MainMenu_GetSelectedIsRookieOnly()
    if gSelectedServerNum and gSelectedServerData then
        return gSelectedServerData.rookieOnly
    end
end

function MainMenu_ForceJoin(forceJoin)
    if forceJoin ~= nil then
        gForceJoin = forceJoin
    end
    return gForceJoin
end

function MainMenu_GetSelectedServerName()
    
    if gSelectedServerNum then
        return Client.GetServerName(gSelectedServerNum)
    end
    
end

function MainMenu_JoinSelected()

    local address, mapName, entry
    
    if gSelectedServerNum >= 0 then
    
        address = GetServerAddress(gSelectedServerNum)
        mapName = Client.GetServerMapName(gSelectedServerNum)
        entry = BuildServerEntry(gSelectedServerNum)
        
    else
    
        local storedServers = GetStoredServers()
    
        address = storedServers[-gSelectedServerNum].address
        entry = storedServers[-gSelectedServerNum]

    end
    
    if entry then
        AddServerToHistory(entry)
        MainMenu_SBJoinServer(address, gPassword, mapName, entry.rookieOnly)
    else
        MainMenu_SBJoinServer(address, gPassword, mapName)
    end
    
end

function GetModName(mapFileName)

    for _, mapEntry in ipairs(maps) do
    
        if mapEntry.fileName == mapFileName then
            return mapEntry.modName
        end
        
    end
    
    return nil
    
end

--
-- Returns true if we hit ESC while playing to display menu, false otherwise.
-- Indicates to display the "Back to game" button.
--
function MainMenu_IsInGame()
    return Client.GetIsConnected()    
end

--
-- Called when button clicked to return to game.
--
function MainMenu_ReturnToGame()
    LeaveMenu()
end

--
-- Set a message that will be displayed in window in the main menu the next time
-- it's updated.
--
function MainMenu_SetAlertMessage(alertMessage)
    mainMenuAlertMessage = alertMessage
end

--
-- Called every frame to see if a dialog should be popped up.
-- Return string to show (one time, message should not continually be returned!)
-- Return "" or nil for no message to pop up
--
function MainMenu_GetAlertMessage()

    local alertMessage = mainMenuAlertMessage
    mainMenuAlertMessage = nil
    
    return alertMessage
    
end

function MainMenu_Open()
    
    GetMainMenu():Open()
    
end

function MainMenu_GetMapNameList()
    return mapnames
end

function MainMenu_GetMenuBackground()
    
    local list = {}
    MainMenu_GetMenuBackgroundList(list)
    
    local selection = Client.GetOptionString("menu/menuBackgroundName", "random")
    
    if selection ~= "random" then
        -- ensure selection exists in the list
        for i=1, #list do
            if list[i].value == selection then
                return list[i].cinematicPath
            end
        end
        
        Log("WARNING:  Unable to locate menu background named '%s'.  Choosing random background for now.", selection)
        selection = "random"
    end
    
    if selection == "random" then
        -- remove random from the list.  Can't just assume it's #1 b/c some modder might screw
        -- this up...
        for i=#list, 1, -1 do
            if list[i].value == "random" then
                table.remove(list, i)
            end
        end
        
        return list[math.random(1, #list)].cinematicPath
        
    end
    
    error("MainMenu_GetMenuBackground() failed to return background!  Yell at Beige, this shouldn't happen!")
    
end

function MainMenu_GetMusic()
    
    local list = {}
    MainMenu_GetMusicList(list)
    
    local selection = Client.GetOptionString("menu/menuMusicName", "random")
    
    if selection ~= "random" then
        -- ensure selection exists in the list
        for i=1, #list do
            if list[i].value == selection then
                return list[i].path
            end
        end
        
        Log("WARNING:  Unable to locate menu background music named '%s'.  Choosing random music for now.", selection)
        selection = "random"
    end
    
    if selection == "random" then
        -- remove random from the list.  Can't just assume it's #1 b/c some modder might screw
        -- this up...
        for i=#list, 1, -1 do
            if list[i].value == "random" then
                table.remove(list, i)
            end
        end
        
        return list[math.random(1, #list)].path
        
    end
    
    error("MainMenu_GetMusic() failed to return music!  Yell at Beige, this shouldn't happen!")
    
end

-- Table is passed by reference.  MODDERS: To add to this list, just hook into this
-- function and add more to the tail-end of it.
function MainMenu_GetMenuBackgroundList(addToList)
    
    table.insert(addToList, { optionValue = "random", localeString = "MENU_BACKGROUND_RANDOM"})    
    table.insert(addToList, {   value = "derelict",
                                localeString = "MENU_BACKGROUND_DERELICT",
                                cinematicPath = "cinematics/menus/main_menu_derelict.cinematic"})
    
    table.insert(addToList, {   value = "eclipse",
                                localeString = "MENU_BACKGROUND_ECLIPSE",
                                cinematicPath = "cinematics/menus/main_menu_eclipse.cinematic"})
    
    table.insert(addToList, {   value = "kodiak",
                                localeString = "MENU_BACKGROUND_KODIAK",
                                cinematicPath = "cinematics/menus/main_menu_kodiak.cinematic"})
    
    table.insert(addToList, {   value = "biodome",
                                localeString = "MENU_BACKGROUND_BIODOME",
                                cinematicPath = "cinematics/menus/main_menu_biodome.cinematic"})
    
    table.insert(addToList, {   value = "descent",
                                localeString = "MENU_BACKGROUND_DESCENT",
                                cinematicPath = "cinematics/menus/main_menu_descent.cinematic"})
    
    table.insert(addToList, {   value = "docking",
                                localeString = "MENU_BACKGROUND_DOCKING",
                                cinematicPath = "cinematics/menus/main_menu_docking.cinematic"})
    
    table.insert(addToList, {   value = "mineshaft",
                                localeString = "MENU_BACKGROUND_MINESHAFT",
                                cinematicPath = "cinematics/menus/main_menu_mineshaft.cinematic"})
    
    table.insert(addToList, {   value = "refinery",
                                localeString = "MENU_BACKGROUND_REFINERY",
                                cinematicPath = "cinematics/menus/main_menu_refinery.cinematic"})
    
    table.insert(addToList, {   value = "summit",
                                localeString = "MENU_BACKGROUND_SUMMIT",
                                cinematicPath = "cinematics/menus/main_menu_summit.cinematic"})
    
    table.insert(addToList, {   value = "tram",
                                localeString = "MENU_BACKGROUND_TRAM",
                                cinematicPath = "cinematics/menus/main_menu_tram.cinematic"})
    
    table.insert(addToList, {   value = "veil",
                                localeString = "MENU_BACKGROUND_VEIL",
                                cinematicPath = "cinematics/menus/main_menu_veil.cinematic"})
    
    table.insert(addToList, {   value = "caged",
                                localeString = "MENU_BACKGROUND_CAGED",
                                cinematicPath = "cinematics/menus/main_menu_caged.cinematic"})
    
    table.insert(addToList, {   optionValue = "unearthed",
                                localeString = "MENU_BACKGROUND_UNEARTHED",
                                cinematicPath = "cinematics/menus/main_menu_unearthed.cinematic"})
    
end

-- Table is passed by reference.  MODDERS: To add to this list, just hook into this
-- function and add more to the tail-end of it.
function MainMenu_GetMusicList(addToList)
    
    table.insert(addToList, { value = "random", localeString = "MENU_MUSIC_RANDOM"})
    
    table.insert(addToList, {   value = "eclipseRemix",
                                localeString = "MENU_MUSIC_ECLIPSE_REMIX",
                                path = "sound/NS2.fev/Eclipse Remix Menu"})
    
    table.insert(addToList, {   value = "exo",
                                localeString = "MENU_MUSIC_EXO",
                                path = "sound/NS2.fev/Exo (Original Music) Menu"})
    
    table.insert(addToList, {   value = "beta",
                                localeString = "MENU_MUSIC_BETA",
                                path = "sound/NS2.fev/Beta Menu"})
    
    table.insert(addToList, {   value = "ns1",
                                localeString = "MENU_MUSIC_NS1",
                                path = "sound/NS2.fev/NS1 Menu"})
    
    table.insert(addToList, {   value = "frontiersmen",
                                localeString = "MENU_MUSIC_FRONTIERSMEN",
                                path = "sound/NS2.fev/Frontiersmen Menu"})
    
    
end

function MainMenu_OnServerRefreshed(serverIndex)
    gMainMenu:OnServerRefreshed(serverIndex)
end

--
-- Called when the user types the "map" command at the console.
--
--[[
local function OnCommandMap(mapFileName, hidden)

    if mapFileName ~= nil then
        MainMenu_HostGame(mapFileName, nil, hidden == "hidden")
        
        if Client then
            Client.SetOptionString("lastServerMapName", mapFileName)
        end
    end

end
--]]

--
-- Called when the user types the "connect" command at the console.
--
--[[
local function OnCommandConnect(address, password)
    MainMenu_SBJoinServer(address, password, nil, true)
end
--]]

--
-- This is called if the user tries to join a server through the
-- Steam UI.
--
--[[
local function OnConnectRequested(address, password)
    MainMenu_SBJoinServer(address, password)
end
--]]

--
-- Sound events
--
local kMouseInSound = "sound/NS2.fev/common/hovar"
local kMouseOutSound = "sound/NS2.fev/common/tooltip"
local kClickSound = "sound/NS2.fev/common/button_click"
local kCheckboxOnSound = "sound/NS2.fev/common/checkbox_off"
local kCheckboxOffSound = "sound/NS2.fev/common/checkbox_on"

local kOpenMenuSound = "sound/NS2.fev/common/menu_confirm"
local kCloseMenuSound = "sound/NS2.fev/common/menu_confirm"
local kLoopingMenuSound = "sound/NS2.fev/common/menu_loop"
local kWindowOpenSound = "sound/NS2.fev/common/open"
local kDropdownSound = "sound/NS2.fev/common/button_enter"
local kArrowSound = "sound/NS2.fev/common/arrow"
local kButtonSound = "sound/NS2.fev/common/tooltip_off"
local kButtonClickSound = "sound/NS2.fev/common/button_click"
local kTooltip = "sound/NS2.fev/common/tooltip_on"
local kPlayButtonSound = "sound/NS2.fev/marine/commander/give_order"
local kSlideSound = "sound/NS2.fev/marine/commander/hover_ui"
local kTrainigLinkSound = "sound/NS2.fev/common/tooltip"
local kLoadingSound = "sound/NS2.fev/common/loading"
local kCustomizeHoverSound = kArrowSound  --"sound/NS2.fev/alien/fade/vortex_start_2D"
--TODO Add customize hover sound specific to Aliens
local kUnlockSound = "sound/NS2.fev/alien/fade/swipe"

Client.PrecacheLocalSound(kMouseInSound)
Client.PrecacheLocalSound(kMouseOutSound)
Client.PrecacheLocalSound(kClickSound)
Client.PrecacheLocalSound(kCheckboxOnSound)
Client.PrecacheLocalSound(kCheckboxOffSound)

Client.PrecacheLocalSound(kOpenMenuSound)
Client.PrecacheLocalSound(kCloseMenuSound)
Client.PrecacheLocalSound(kLoopingMenuSound)
Client.PrecacheLocalSound(kWindowOpenSound)
Client.PrecacheLocalSound(kDropdownSound)
Client.PrecacheLocalSound(kArrowSound)
Client.PrecacheLocalSound(kButtonSound)
Client.PrecacheLocalSound(kButtonClickSound)
Client.PrecacheLocalSound(kTooltip)
Client.PrecacheLocalSound(kPlayButtonSound)
Client.PrecacheLocalSound(kSlideSound)
Client.PrecacheLocalSound(kTrainigLinkSound)
Client.PrecacheLocalSound(kLoadingSound)
Client.PrecacheLocalSound(kCustomizeHoverSound)
Client.PrecacheLocalSound(kUnlockSound)

function MainMenu_OnMouseIn()
    StartSoundEffect(kMouseInSound)
end

function MainMenu_OnMouseOut()
    --StartSoundEffect(kMouseOutSound)
end

function MainMenu_OnMouseOver()
    if MainMenu_GetIsOpened() then
        StartSoundEffect(kMouseOutSound)
    end
end

function MainMenu_OnMouseClick()
    StartSoundEffect(kClickSound)
end

function MainMenu_OnWindowOpen()
    StartSoundEffect(kWindowOpenSound)
end

function MainMenu_OnCheckboxOn()
    StartSoundEffect(kCheckboxOnSound)
end

function MainMenu_OnCheckboxOff()
    StartSoundEffect(kCheckboxOffSound)
end



function MainMenu_OnOpenMenu()
    StartSoundEffect(kLoopingMenuSound)    
end

function MainMenu_OnCloseMenu()
    Shared.StopSound(nil, kLoopingMenuSound)
end

function MainMenu_OnDropdownClicked()
    StartSoundEffect(kDropdownSound)
end

function MainMenu_OnHover()
    StartSoundEffect(kArrowSound)
end

function MainMenu_OnButtonEnter()
    StartSoundEffect(kButtonSound, 0.25)
end

function MainMenu_OnButtonClicked()
    StartSoundEffect(kButtonClickSound, 0.5)
end

function MainMenu_OnTooltip()
    StartSoundEffect(kTooltip, 0.5)
end

function MainMenu_OnPlayButtonClicked()
    StartSoundEffect(kPlayButtonSound)
end

function MainMenu_OnSlide()
    if MainMenu_GetIsOpened() then
        StartSoundEffect(kSlideSound)
    end
end

function MainMenu_OnTrainingLinkedClicked()
    if MainMenu_GetIsOpened() then
        StartSoundEffect(kTrainigLinkSound)
    end
end

function MainMenu_OnLoadingSound()
    if MainMenu_GetIsOpened() then
        StartSoundEffect(kLoadingSound)
    end
end
    
function MainMenu_OnCustomizationHover()
    StartSoundEffect(kCustomizeHoverSound)    
end

function MainMenu_OnUnlock()
    StartSoundEffect(kUnlockSound)
end

function MainMenu_OnHideProgress()
    Shared.StopSound(nil, kUnlockSound)
end

function MainMenu_LoadNewsURL(url)
    if gMainMenu.newsScript then
        gMainMenu.newsScript:LoadURL(url)
    end
end

--[[
local function OnClientDisconnected()
    LeaveMenu()
end
--]]

--[[
Event.Hook("ClientDisconnected", OnClientDisconnected)
Event.Hook("ConnectRequested", OnConnectRequested)

Event.Hook("Console_connect",  OnCommandConnect)
Event.Hook("Console_map",  OnCommandMap)
--]]

--]===]