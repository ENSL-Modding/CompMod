-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\menu\MenuPoses.lua
--
--    Created by:   Brian Arneson (samusdroid@gmail.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Utility.lua")
Script.Load("lua/AnimatedModel.lua")
Script.Load("lua/tweener/Tweener.lua")

class 'MenuPoses' (AnimatedModel)

local manager

local function CreateManager()
    manager = MenuPoses()
    manager:Initialize()
    return manager
end

local function UpdateManager()
    if not manager then 
        return MenuPoses()
    else
        return manager
    end
end

local kMenuPoseBackground = PrecacheAsset("cinematics/customization_menu_camera.cinematic") 
local kMenuPoseBackgroundInGame = PrecacheAsset("cinematics/customization_menu.cinematic") 
local kMenuCinematic = PrecacheAsset("cinematics/main_menu.cinematic")
local fadeOut = false


local cinematic, animStartTime, model, angles, renderCamera, coords
local modelYaw = 0

function MenuPoses_SetPose(pose, modelType, destroy)
    
    local lastShownModel = Client.GetOptionString("lastShownModel", "")

    if destroy == true or lastShownModel ~= modelType then
        if model then
            model:Destroy()
            model = nil
        end
    end
    
    local options = GetAndSetVariantOptions()

    local sexType = string.lower(options.sexType)

    local modelPath
    
    if modelType == "skulk" then
        modelPath =  "models/alien/" .. modelType .. "/" .. modelType .. GetVariantModel(kSkulkVariantData, options.skulkVariant)
    elseif modelType == "gorge" then
        modelPath =  "models/alien/" .. modelType .. "/" .. modelType .. GetVariantModel(kGorgeVariantData, options.gorgeVariant)
    elseif modelType == "lerk" then
        modelPath =  "models/alien/" .. modelType .. "/" .. modelType .. GetVariantModel(kLerkVariantData, options.lerkVariant)
    elseif modelType == "fade" then
        modelPath =  "models/alien/" .. modelType .. "/" .. modelType .. GetVariantModel(kFadeVariantData, options.fadeVariant)
    elseif modelType == "onos" then
        modelPath =  "models/alien/" .. modelType .. "/" .. modelType .. GetVariantModel(kOnosVariantData, options.onosVariant)
    elseif modelType == "exo" then
        modelPath =  "models/marine/exosuit/exosuit_mm.model"
    elseif modelType == "rifle" then
        modelPath = "models/marine/rifle/rifle" .. GetVariantModel(kRifleVariantData, options.rifleVariant)
    elseif modelType == "pistol" then
        modelPath = "models/marine/pistol/pistol" .. GetVariantModel(kPistolVariantData, options.pistolVariant)
    elseif modelType == "axe" then
        modelPath = "models/marine/axe/axe" .. GetVariantModel(kAxeVariantData, options.axeVariant)
    elseif modelType == "shotgun" then
        modelPath = "models/marine/shotgun/shotgun" .. GetVariantModel(kShotgunVariantData, options.shotgunVariant)
    elseif modelType == "flamethrower" then
        modelPath = "models/marine/flamethrower/flamethrower" .. GetVariantModel(kFlamethrowerVariantData, options.flamethrowerVariant)
    elseif modelType == "grenadeLauncher" then
        modelPath = "models/marine/grenadelauncher/grenadelauncher" .. GetVariantModel(kGrenadeLauncherVariantData, options.grenadeLauncherVariant)
    elseif modelType == "welder" then
        modelPath = "models/marine/welder/welder" .. GetVariantModel(kWelderVariantData, options.welderVariant)
    elseif modelType == "hmg" then
        modelPath = "models/marine/hmg/hmg" .. GetVariantModel(kHMGVariantData, options.hmgVariant)
    elseif modelType == "command_station" then
        modelPath = "models/marine/command_station/command_station.model"
    elseif modelType == "hive" then
        modelPath = "models/alien/hive/hive.model"
    elseif modelType == "tunnel" then
        modelPath = "models/alien/tunnel/mouth" .. GetVariantModel(kAlienTunnelVariantsData, options.alienTunnelsVariant)
    else
        modelPath = "models/marine/" .. sexType .. "/" .. sexType .. GetVariantModel(kMarineVariantData, options.marineVariant)
    end

    if model == nil and modelPath ~= nil then
        model = CreateAnimatedModel(modelPath)
    else
        model = CreateAnimatedModel("models/marine/" .. sexType .. "/" .. sexType .. GetVariantModel(kMarineVariantData, options.marineVariant))
        model:SetIsVisible(false)
    end
    
    if modelType ~= "command_station" and modelType ~= "hive" and modelType ~= "tunnel" then
        if modelType == "rifle" or modelType == "pistol" or modelType == "axe" then
            model:SetAnimation("idle")
            model:SetQueuedAnimation("idle")
        elseif modelType ~= "shotgun" and modelType ~= "flamethrower" and modelType ~= "grenadeLauncher" and modelType ~= "welder" and modelType ~= "hmg" then
            model:SetAnimation("idle")
            model:SetQueuedAnimation(pose)
            model:SetPoseParam("body_yaw", 30)
            model:SetPoseParam("body_pitch", -8)
        end
    elseif modelType == "command_station" then
        model:SetAnimation("idle")
        model:SetQueuedAnimation("idle")
    elseif modelType == "hive" then
        model:SetAnimation("idle_active")
        model:SetQueuedAnimation("idle_active")
    elseif modelType == "tunnel" then
        model:SetAnimation("idle_open")
        model:SetQueuedAnimation("idle_open")
    end

    model.renderModel:InstanceMaterials()
    model:SetCastsShadows(true)
    model:SetIsVisible(false)
    model.renderModel:SetMaterialParameter("highlight", 0)

    if modelType == "exo" then 
        model.renderModel:SetMaterialParameter("textureIndex", options.exoVariant - 1)
    end

    if modelType == "rifle" then
        model.renderModel:SetMaterialParameter("textureIndex", options.rifleVariant - 1)
    end
    
    if modelType == "pistol" then
        model.renderModel:SetMaterialParameter("textureIndex", options.pistolVariant - 1)
    end

    if modelType == "axe" then
        model.renderModel:SetMaterialParameter("textureIndex", options.axeVariant - 1)
    end

    if modelType == "command_station" then
        model.renderModel:SetMaterialParameter("textureIndex", options.marineStructuresVariant - 1)
    end

    if modelType == "hive" then
        model.renderModel:SetMaterialParameter("textureIndex", options.alienStructuresVariant - 1)
    end

    if modelType == "tunnel" then
        if options.alienTunnelsVariant > 2 then --due to Shadow model usage
            model.renderModel:SetMaterialParameter("textureIndex", options.alienTunnelsVariant - 2)
        else
            model.renderModel:SetMaterialParameter("textureIndex", options.alienTunnelsVariant - 1)
        end
    end

    UpdateManager():CycleModel(Shared.GetTime(), true)
    
    MainMenu_OnCustomizationHover()
    
end

function MenuPoses:Initialize()
    if not cinematic and MainMenu_IsInGame() then
        cinematic = Client.CreateCinematic(RenderScene.Zone_ViewModel)
        cinematic:SetCinematic(kMenuPoseBackgroundInGame)
        cinematic:SetRepeatStyle(Cinematic.Repeat_Endless)
        cinematic:SetIsVisible(true)
    end 
end

function MenuPoses_Initialize()
    CreateManager()
    return CreateManager()
end

function MenuPoses_Function()
    return UpdateManager()
end

function MenuPoses:Update(deltaTime)

    PROFILE("MenuPoses:Update")
    
    if not MainMenu_GetIsOpened() then
        
    elseif MainMenu_GetIsOpened() and model == nil then
        MenuPoses_SetPose("idle", Client.GetOptionString("lastShownModel", "marine"), true)
    elseif MainMenu_GetIsOpened() then
    
        if MainMenu_IsInGame() then
        
            local player = Client.GetLocalPlayer()
            player:SetViewAngles(Angles(0, 0, player:GetViewAngles().roll))
            coords = player:GetViewAngles():GetCoords()

            player:SetCameraYOffset(10000)
            
            angles = Angles(player:GetViewAngles())
            angles.pitch = 0
            angles.roll = 0

        else
        
            angles = Angles()
            angles.yaw = -math.pi/2
            angles.pitch = 0
            angles.roll = 0
            coords = angles:GetCoords()
            
        end
        
        self:SetCoordsOffset(Client.GetOptionString("lastShownModel", "marine"))

        self:CycleModel()
        model:Update(deltaTime)
        model.renderModel:SetMaterialParameter("patchIndex", Client.GetOptionInteger("shoulderPad", 1) -2)
        model:SetIsVisible(true)
            
    end
end

armorOffsetY = -1
--armorOffsetZ = 3.75

decalOffsetY = -1.5
--decalOffsetZ = 1.5

rifleOffsetY = -0.075
--rifleOffsetZ = 1.4

axeOffsetY = -0.265
--axeOffsetZ = 0.75

pistolOffsetY = -0.015
--pistolOffsetZ = 1.185

shotgunOffsetY = 0
--shotgunOffsetZ = 1.4

flamethrowerOffsetX = -0.35
--flamethrowerOffsetZ = 1.5
flamethrowerPitchOffset = 1.45

welderOffsetX = 0
welderOffsetY = 0
welderPitchOffset = 0
welderYawOffset = 0
welderRollOffset = 0

glOffsetX = -0.2
glOffsetY = -.0125
glPitchOffset = 0.5
glYawOffset = 0

local modelDisplayOffsets =
{
    ["default"] = 
    {
        offsetX = 0,
        offsetY = -1.1,
        offsetZ = 0,
        offsetPitch = 0,
        offsetYaw = 1.1,
        offsetRoll = 0,
        scale = 0.5,
    },
    
    ["marine"] = 
    {
        offsetX = 0,
        offsetY = -1,
        offsetZ = 0,
        offsetPitch = 0,
        offsetYaw = 1.0,
        offsetRoll = 0,
        scale = 0.5,
    },
    
    ["decal"] = 
    {
        offsetX = -0.2,
        offsetY = -1.625,
        offsetZ = -0.07,
        offsetPitch = 0,
        offsetYaw = 0.6,
        offsetRoll = 0,
        scale = 3,
    },
    
    ["rifle"] = 
    {
        offsetX = -0.09,
        offsetY = 0,
        offsetZ = 0,
        offsetPitch = 1.6,
        offsetYaw = 0,
        offsetRoll = 0.125,
        scale = 1.5,
    },
    
    ["axe"] = 
    {
        offsetX = -0.2,
        offsetY = 0,
        offsetZ = 0,
        offsetPitch = -0.1,
        offsetYaw = 1.5,
        offsetRoll = 0.5,
        scale = 3,
    },
    
    ["pistol"] = 
    {
        offsetX = -0.05,
        offsetY = 0,
        offsetZ = 0,
        offsetPitch = 1.4,
        offsetYaw = 0,
        offsetRoll = 0.2,
        scale = 3,
    },
    
    ["shotgun"] = 
    {
        offsetX = -0.2,
        offsetY = 0,
        offsetZ = 0,
        offsetPitch = 0.4,
        offsetYaw = 0.5,
        offsetRoll = 0.5,
        scale = 1.75,
    },
    
    ["flamethrower"] = 
    {
        offsetX = -0.4,
        offsetY = 0,
        offsetZ = 0,
        offsetPitch = 1.3,
        offsetYaw = 0.25,
        offsetRoll = -0.3,
        scale = 1,
    },
    
    ["welder"] = 
    {
        offsetX = 0,
        offsetY = -0.1,
        offsetZ = -0.035,
        offsetPitch = 0,
        offsetYaw = 0.7,
        offsetRoll = 0.5,
        scale = 3,
    },
    
    ["hmg"] = 
    {
        offsetX = 0,
        offsetY = -0.25,
        offsetZ = 0,
        offsetPitch = 0,
        offsetYaw = 0.25,
        offsetRoll = 0.0625,
        scale = 1.5,
    },
    
    ["grenadeLauncher"] = 
    {
        offsetX = -0.225,
        offsetY = -0.1,
        offsetZ = 0,
        offsetPitch = 0.4,
        offsetYaw = 0.5,
        offsetRoll = 0.5,
        scale = 1.5,
    },
    
    ["exo"] = 
    {
        offsetX = 0,
        offsetY = -1.35,
        offsetZ = 0,
        offsetPitch = 0,
        offsetYaw = 0.9,
        offsetRoll = 0,
        scale = 0.4,
    },
    
    ["onos"] = 
    {
        offsetX = 0,
        offsetY = -1.6,
        offsetZ = 0,
        offsetPitch = 0,
        offsetYaw = 1.1,
        offsetRoll = 0,
        scale = 0.333,
    },

    ["command_station"] = 
    {
        offsetX = -0.25,
        offsetY = -1.75,
        offsetZ = -1.8,
        offsetPitch = 0,
        offsetYaw = 0.94,
        offsetRoll = 0,
        scale = 0.465,
    },

    ["hive"] = 
    {
        offsetX = 2.25,
        offsetY = 0.72,
        offsetZ = -2.185,
        offsetPitch = 0,
        offsetYaw = 1.285,
        offsetRoll = 0,
        scale = 0.44,
    },

    ["tunnel"] = 
    {
        offsetX = 1.5,
        offsetY = -1.8,
        offsetZ = -1.25,
        offsetPitch = 0,
        offsetYaw = 1.285,
        offsetRoll = 0,
        scale = 0.685,
    },
}

function MenuPoses:SetCoordsOffset(name)

    if coords then

        angles.roll = 0
        
        local config = modelDisplayOffsets[name] or modelDisplayOffsets.default
        angles.yaw = (modelYaw + config.offsetYaw) * math.pi
        angles.pitch = config.offsetPitch * math.pi
        angles.roll = config.offsetRoll * math.pi
        coords = angles:GetCoords()
        coords.origin = coords.origin + Vector(0, config.offsetY * config.scale, 2) + coords.xAxis * config.offsetX  * config.scale + coords.zAxis * config.offsetZ * config.scale
        coords.xAxis = coords.xAxis * config.scale
        coords.yAxis = coords.yAxis * config.scale
        coords.zAxis = coords.zAxis * config.scale
        
        model:SetCoords(coords)
    end
    
end

function MenuPoses:CycleModel(time, newLoop)
        
    if time and not animStartTime then
        animStartTime = time
    end
    if newLoop then
        if time then
            animStartTime = time
        end
        fadeOut = false
    end

    if animStartTime then
        if fadeOut == false then
            local animTime = Clamp(Shared.GetTime() - animStartTime, 0, 0.125)
            local animFraction = Easing.outCubic(animTime, 0.0, 1.0, 0.125)
            model.renderModel:SetMaterialParameter("hiddenAmount", 1*Clamp(animFraction, 0, 1))
            if animFraction == 1 then
                fadeOut = true
                animStartTime = Shared.GetTime()
            end
        elseif fadeOut == true then
            local animTime = Clamp(Shared.GetTime() - animStartTime, 0, 0.125)
            local animFraction = Easing.inCubic(animTime, 0.0, 1.0, 0.125)
            model.renderModel:SetMaterialParameter("hiddenAmount", 1-Clamp(animFraction, 0, 1))
            if animFraction == 2 then
                fadeOut = false
                animStartTime = Shared.GetTime()
            end
        end

    end
end

function MenuPoses:Destroy()

    if model then
        model:Destroy()
        model = nil
    end
    
    if cinematic then
        Client.DestroyCinematic(cinematic)
        cinematic = nil
    end
    
    if self.ammoDisplay then
        Client.DestroyGUIView(self.ammoDisplay)
        self.ammoDisplay = nil
    end
    
end

function MenuPoses_SetViewModel(value)
    assert(type(value) == "boolean")
    local player = Client.GetLocalPlayer()
    if player and MainMenu_IsInGame() then
        local viewModel = player:GetViewModelEntity()   --FIXME This causes delay change
        if viewModel then
            viewModel:SetIsVisible( value )
        end
    end
end

function MenuPoses_Update(deltaTime)
    UpdateManager():Update(deltaTime)
end

function MenuPoses_Destroy()
    UpdateManager():Destroy()
end

function MenuPoses_SetModelAngle(yaw)
    modelYaw = (yaw-0.5)*2 or 0
end

local originalCameraOffset
local originalCameraFov
function MenuPoses_GetCameraOffset()
    local player = Client.GetLocalPlayer()
    if player then
        originalCameraFov = Client.GetZoneFov( RenderScene.Zone_ViewModel )
        --Note: Basically all Menu cinematic backgrounds use FOV 90 for their camera, thus we should match that for consistency
        Client.SetZoneFov( RenderScene.Zone_ViewModel, GetScreenAdjustedFov( math.rad(95), 1900/1200 ) ) 
        originalCameraOffset = player:GetCameraYOffset()
        if player:isa("Alien") then 
            player:SetDarkVision(false)
        end
    end
end

function MenuPoses_RestoreCameraOffset()
    local player = Client.GetLocalPlayer()
    if player then
        --Reset View zone back to correct FOV before menu opened
        Client.SetZoneFov( RenderScene.Zone_ViewModel, originalCameraFov ) 
        originalCameraOffset = player:SetCameraYOffset(originalCameraOffset or 0)
    end
end

function MenuPoses_OnMenuOpened()
    if MainMenu_IsInGame() then
        MenuPoses_SetViewModel(false)
        MenuPoses_GetCameraOffset()
        ClientUI.EvaluateUIVisibility(Client.GetLocalPlayer())
    elseif not MainMenu_IsInGame() then
        MenuManager.SetMenuCinematic(kMenuPoseBackground)
    end
end

function MenuPoses_OnMenuClosed()
    if MainMenu_IsInGame() then
        MenuPoses_RestoreCameraOffset()
        MenuPoses_SetViewModel(true)
        ClientUI.EvaluateUIVisibility(Client.GetLocalPlayer())
    else
        MenuManager.RestoreMenuCinematic(kMenuCinematic)
    end
    MenuPoses_Destroy()
end


-- Debug utility for adjusting model coordinates in real-time
--[=[
Log("DEBUG STUFF ENABLED!!!!! (bottom of MenuPoses.lua)")
local keySet = {}
for key, __ in pairs(modelDisplayOffsets) do
    table.insert(keySet, key)
end

local subKeySet = {}
for subKey, __ in pairs(modelDisplayOffsets[keySet[1]]) do
    table.insert(subKeySet, subKey)
end

for i=1, #keySet do
    local key = keySet[i]
    local keyLower = string.lower(key)
    
    for j=1, #subKeySet do
        local subKey = subKeySet[j]
        local subKeyLower = string.lower(subKey)
        
        local command = string.format("Console_set_%s_%s", keyLower, subKeyLower)
        Log("Hooking event '%s'", command)
        Event.Hook(command, function(value)
            
            local numberValue = tonumber(value)
            if not numberValue then
                Log("invalid number")
                return
            end
            
            modelDisplayOffsets[key][subKey] = numberValue
            Log("Set modelDisplayOffsets.%s.%s to %s", key, subKey, numberValue)
            
        end)
        
    end
end
--]=]
