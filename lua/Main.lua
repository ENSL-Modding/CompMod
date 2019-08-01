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

Script.Load("lua/ModLoader.lua")
Script.Load("lua/Globals.lua")
Script.Load("lua/Render.lua")
Script.Load("lua/GUIManager.lua")
Script.Load("lua/NS2Utility.lua")
Script.Load("lua/MainMenu.lua")
Script.Load("lua/Utility.lua")
Script.Load("lua/Matchmaking.lua")

Script.Load("lua/Analytics.lua")

Script.Load("lua/menu/GUIVideoTutorialIntro.lua")

local menusList = MainMenu_GetMenuBackgrounds()
local menuMusicList = MainMenu_GetMusicList()
local menu = Client.GetOptionInteger("menu/menuBackground", 1)
local music = Client.GetOptionInteger("menu/menuMusic", 1)

local renderCamera
local kMenuCinematic = PrecacheAsset("cinematics/main_menu.cinematic")
local menuNum = 1
local musicNum = 1
local kDefaultBackgroundIndex = 2 -- Unearthed
local kDefaultMusic = "Eclipse Remix"
local kMusicPath = kDefaultMusic

math.randomseed(Shared.GetSystemTime())
for i = 1, 20 do math.random() end

if menu == 1 then
    menuNum = kDefaultBackgroundIndex
elseif menu == #menusList then
    menuNum = math.random(2, #menusList-1)
else
    menuNum = menu
end

if music == #menuMusicList then
    local number = math.random(1, #menuMusicList-1)
    musicNum = number
else
    musicNum = music
end

if menuNum and menuNum > 1 then
    kMenuCinematic = PrecacheAsset("cinematics/menus/main_menu_" .. menusList[menuNum] .. ".cinematic")
end

if musicNum and musicNum > 1 then
    kMusicPath = menuMusicList[musicNum]
end

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
end

local function OnUpdateRender()

    local cullingMode = RenderCamera.CullingMode_Occlusion
    local camera = MenuManager.GetCinematicCamera()
    
    if camera ~= false then
    
        renderCamera:SetCoords(camera:GetCoords())
        renderCamera:SetFov(camera:GetFov())
        renderCamera:SetNearPlane(0.01)
        renderCamera:SetFarPlane(10000.0)
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
    
    MenuManager.SetMenuCinematic(kMenuCinematic, true)
    MenuMenu_PlayMusic("sound/NS2.fev/" .. kMusicPath .. " Menu")
    MainMenu_Open()

    if message then
        MainMenu_SetAlertMessage(message)
    end
    
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
    
    SetNameWithSteamPersona()
    
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