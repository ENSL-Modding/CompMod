--=============================================================================
--
-- lua/Main.lua
--
-- Created by Max McGuire (max@unknownworlds.com)
-- Copyright 2012, Unknown Worlds Entertainment
--
-- This file is loaded when the game first starts up and displays the main menu.
--
--=============================================================================
decoda_name = "Main"

--require("jit").off() -- disable lua-JIT for debugging.

Script.Load("lua/ModLoader.lua")
Script.Load("lua/Globals.lua")
Script.Load("lua/Render.lua")
Script.Load("lua/GUIManager.lua")
Script.Load("lua/NS2Utility.lua")

Script.Load("lua/OptionSavingManager.lua")

Script.Load("lua/menu2/GUIMainMenu.lua")
Script.Load("lua/MainMenu.lua")

-- Precache current/active menu background before its set, helps combat asset pop-in
PrecacheAsset(MenuBackgrounds.GetCurrentMenuBackgroundCinematicPath())

Script.Load("lua/Utility.lua")
Script.Load("lua/Matchmaking.lua")

Script.Load("lua/Analytics.lua")

Script.Load("lua/menu/GUIVideoTutorialIntro.lua")

-- Don't ask...
math.randomseed(Shared.GetSystemTime())
for i = 1, 20 do math.random() end

local renderCamera = nil

PrecacheAsset('ui/menu/arrow_vert.dds')
PrecacheAsset('ui/menu/tv_glare.dds')
PrecacheAsset('ui/menu/logo.dds')
PrecacheAsset('ui/menu/buttonbg.dds')
PrecacheAsset('ui/menu/checked.dds')
PrecacheAsset('ui/menu/tabbackground.dds')
PrecacheAsset('ui/menu/server_select_bg.dds')
PrecacheAsset('ui/menu/main_link_bg.dds')
PrecacheAsset('ui/menu/profile_bg.dds')
PrecacheAsset('ui/menu/link_bg.dds')
PrecacheAsset('ui/menu/link_icon_bg.dds')
PrecacheAsset('cinematics/menu/dropship_thrusters_flight.cinematic')
PrecacheAsset('cinematics/menu/dropship_thrusters_down.cinematic')
PrecacheAsset('models/marine/Dropship/dropship_fx_thrusters_02.model')
PrecacheAsset('cinematics/vfx_materials/vfx_enzyme_loop_01_animated.material')
PrecacheAsset('cinematics/vfx_materials/vfx_fireball_03_animated.material')
PrecacheAsset('cinematics/vfx_materials/vfx_enzymeloop_01_animated.dds')
PrecacheAsset('cinematics/menu/dropship_thrusters_approach.cinematic')

-- Precache the common surface shaders.
PrecacheAsset("shaders/Model.surface_shader")
PrecacheAsset("shaders/Emissive.surface_shader")
PrecacheAsset("shaders/Model_emissive.surface_shader")
PrecacheAsset("shaders/Model_alpha.surface_shader")
PrecacheAsset("shaders/ViewModel.surface_shader")
PrecacheAsset("shaders/ViewModel_emissive.surface_shader")
PrecacheAsset("shaders/Decal.surface_shader")
PrecacheAsset("shaders/Decal_emissive.surface_shader")

local function InitializeRenderCamera()
    renderCamera = Client.CreateRenderCamera()
    renderCamera:SetRenderSetup("renderer/Deferred.render_setup")
    renderCamera:SetNearPlane(0.01)
    renderCamera:SetFarPlane(10000.0)
    --Required in order to not render any customize camera content, default of 0, will render everything.
    renderCamera:SetRenderMask( kDefaultRenderMask )
    renderCamera:SetUsesTAA(true) -- render camera _can_ be used with TAA (won't if option isn't set)
end

local function OnUpdateRender()

    local cullingMode = RenderCamera.CullingMode_Occlusion
    local camera = MenuManager.GetCinematicCamera()
    
    if camera ~= false then
        renderCamera:SetCoords(camera:GetCoords())
        renderCamera:SetFov(camera:GetFov())
        renderCamera:SetCullingMode(cullingMode)
        Client.SetRenderCamera(renderCamera)
    else
        Client.SetRenderCamera(nil)
    end
    
end

local function OnVideoEnded(message, watchedTime)

    Client.SetOptionBoolean( "introViewed", true )
    Client.SetOptionBoolean( "system/introViewed", true )
    
    g_introVideoWatchTime = watchedTime
    
    MouseTracker_SetIsVisible(false)
    
    MenuManager.SetMenuCinematic(MenuBackgrounds.GetCurrentMenuBackgroundCinematicPath(), true)
    
    -- "Re-roll" the menu background for next time, in case it's set to random, we need to know
    -- which one to pre-load ahead of time.
    MenuBackgrounds.PickNextMenuBackgroundPath()
    
    CreateMainMenu()
    local menu = GetMainMenu()
    menu:PlayMusic(MenuData.GetCurrentMenuMusicSoundName())
    
    if message then
        PlayMenuSound("Notification")
        
        -- If the message is an invalid password, prompt the user to try again, otherwise just do
        -- the standard popup.
        local invalidPasswordMessage = Locale.ResolveString("DISCONNECT_REASON_2")
        if message == invalidPasswordMessage then
        
            local serverBrowser = GetServerBrowser()
            local address = Client.GetOptionString(kLastServerConnected, "")
            local prevPassword = Client.GetOptionString(kLastServerPassword, "")
            
            if address ~= "" and serverBrowser ~= nil then
            
                serverBrowser:_AttemptToJoinServer(
                {
                    address = address,
                    prevPassword = prevPassword,
                
                    -- The user has presumably already clicked through all the checks (eg unranked
                    -- warning, network settings warning, etc.)  No need to hit them with it again.
                    onlyPassword = true,
                
                })
        
            end
    
        else
            
            menu:DisplayPopupMessage(message, Locale.ResolveString("DISCONNECTED"))
            
        end
        
    end
    
    Client.SetOptionString(kLastServerPassword, "")
    
end

local function OnResetIntro()
    Client.SetOptionBoolean("introViewed",false)
    Client.SetOptionBoolean("system/introViewed",false)
    Print("Intro first-viewing status reset")
end

local function LoadRemotePatch( data )
	Shared.Message( "Remote patch received. Loading...") 
	local ok, err = xpcall( function() loadstring( data )() end, debug.traceback )
	if ok then
		Shared.Message( "Remote patch applied succesfully.") 
	else
		Shared.Message( "Remote patch error:\n"..err) 
	end
end

local function OnLoadComplete(message)
    
    Render_SyncRenderOptions()
    OptionsDialogUI_SyncSoundVolumes()
    
    kRemoteConfig = {}
    Shared.SendHTTPRequest( "http://storage.naturalselection2.com/game/main_patch_v2.lua", "GET", {}, LoadRemotePatch )
    
    UpdatePlayerNicknameFromOptions()
    
    local introViewed = 
        Client.GetOptionBoolean("introViewed", false )
        or Client.GetOptionBoolean("system/introViewed", false )
    
    if introViewed then
        -- Skip intro video if they've already seen it
        OnVideoEnded(message, nil)
    else
        -- Play intro video if this is the first view
        GUIVideoTutorialIntro_Play(OnVideoEnded, message)
    end
    
end

Event.Hook("UpdateRender", OnUpdateRender)
Event.Hook("LoadComplete", OnLoadComplete)
Event.Hook("Console_resetintro", OnResetIntro)

-- Run bot-related unit tests. These are quick and silent.
Script.Load("lua/bots/UnitTests.lua")

-- Initialize the camera at load time, so that the render setup will be
-- properly precached during the loading screen.
InitializeRenderCamera()