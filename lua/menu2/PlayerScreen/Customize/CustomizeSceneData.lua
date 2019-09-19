-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/PlayerScreen/Customize/CustomizeSceneData.lua
--
--    Created by:   Brock Gillespie (brock@naturalselection2.com)
--
--    TODO Add doc/descriptor
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Globals.lua")
Script.Load("lua/Vector.lua")
Script.Load("lua/NS2Utility.lua")


--Global for sake of ease of access
gCustomizeSceneData = {}

-------------------------------------------------------------------------------
--General Assets
gCustomizeSceneData.kSkyBoxCinematic = PrecacheAsset("maps/skyboxes/descent_clear.cinematic")

gCustomizeSceneData.kMacFlyby = PrecacheAsset("cinematics/menu/customize_mac_flyby.cinematic")

gCustomizeSceneData.kHiveWisps = PrecacheAsset("cinematics/alien/hive/specks.cinematic")
gCustomizeSceneData.kHiveWisps_Toxin = PrecacheAsset("cinematics/alien/hive/specks_catpack.cinematic")

gCustomizeSceneData.kHiveMist = PrecacheAsset("cinematics/alien/hive/idle_mist.cinematic")
gCustomizeSceneData.kHiveTechpointFX = PrecacheAsset("cinematics/common/techpoint.cinematic")
gCustomizeSceneData.kHiveTechpointLightFX = PrecacheAsset("cinematics/menu/customize_techpoint_light.cinematic")
gCustomizeSceneData.kLavaFallFX = PrecacheAsset("cinematics/menu/customize_lava_fall.cinematic")
gCustomizeSceneData.kLavaPoolFountainFX = PrecacheAsset("cinematics/environment/smelting_bucket_pourring_base.cinematic")
gCustomizeSceneData.kLavaPoolSmokeFX = PrecacheAsset("cinematics/environment/fire_room_smoke_low.cinematic")
gCustomizeSceneData.kLavaBubbleFX = PrecacheAsset("cinematics/menu/customize_lava_bubble.cinematic")
--gCustomizeSceneData.kWallSparksFX = PrecacheAsset("cinematics/environment/sparks_loop_3s.cinematic")
gCustomizeSceneData.kMoseyingDrifter = PrecacheAsset("cinematics/environment/origin/alien_zoo_drifter.cinematic")
--gCustomizeSceneData.kLavaHeat = PrecacheAsset("cinematics/environment/origin/heat_distortion.cinematic")

--TODO either write a custom one, or find something better
gCustomizeSceneData.kMarineTeamHighlightMaterial = PrecacheAsset("cinematics/vfx_materials/modelMouse_marines.material")
gCustomizeSceneData.kAlienTeamHighlightMaterial = PrecacheAsset("cinematics/vfx_materials/modelMouse_aliens.material")

gCustomizeSceneData.kMarineTeamSelectableMaterial = PrecacheAsset("cinematics/vfx_materials/customize_marine_selectable.material")
gCustomizeSceneData.kAlienTeamSelectableMaterial = PrecacheAsset("cinematics/vfx_materials/customize_alien_selectable.material")

-------------------------------------------------------------------------------
---Scene Timings / Constants

gCustomizeSceneData.kMacFlybyMinInterval = 12
gCustomizeSceneData.kMacFlybyInterval = 48

gCustomizeSceneData.kZoomedBaseCameraOffset = Vector( 0, 0, 0 ) --model position offset (not angles) from Camera transform

-------------------------------------------------------------------------------
---Customize Render Scene Data / Settings

--Labels to denote camera position data (and other references)
gCustomizeSceneData.kViewLabels = 
enum({

    --Primary Marine Views
    "DefaultMarineView",
    "Marines",
    "ShoulderPatches",
    "ExoBay",
    "MarineStructures",     --Extractor is in-view
    "Armory",               --All weapons are in-view

    --Marine Sub-Views
    "Rifle",
    "Axe",
    "Pistol",
    "Welder",
    "Shotgun",
    "Flamethrower",
    "GrenadeLauncher",
    "HeavyMachinegun",


    --Primary Alien Views
    "DefaultAlienView",
    "AlienLifeforms",
    "AlienStructures",      --Harvester and cyst are in-view
    "AlienTunnels",

    --Alien Sub-Views
    "Skulk",
    "Gorge",
    "Lerk",
    "Fade",
    "Onos",


    "TeamTransition"        --"Special" view used to go between Team areas
})

--Reference table to denote which View belongs to which team
gCustomizeSceneData.kTeamViews = 
{
    [kTeam1Index] = 
    {
        gCustomizeSceneData.kViewLabels.DefaultMarineView,
        gCustomizeSceneData.kViewLabels.Armory,
        gCustomizeSceneData.kViewLabels.Marines,
        gCustomizeSceneData.kViewLabels.ShoulderPatches,
        gCustomizeSceneData.kViewLabels.ExoBay,
        gCustomizeSceneData.kViewLabels.MarineStructures,
        gCustomizeSceneData.kViewLabels.Rifle,
        gCustomizeSceneData.kViewLabels.Pistol,
        gCustomizeSceneData.kViewLabels.Axe,
        gCustomizeSceneData.kViewLabels.Welder,
        gCustomizeSceneData.kViewLabels.Shotgun,
        gCustomizeSceneData.kViewLabels.Flamethrower,
        gCustomizeSceneData.kViewLabels.GrenadeLauncher,
        gCustomizeSceneData.kViewLabels.HeavyMachinegun,
    },
    [kTeam2Index] = 
    {
        gCustomizeSceneData.kViewLabels.DefaultAlienView,
        gCustomizeSceneData.kViewLabels.AlienLifeforms,
        gCustomizeSceneData.kViewLabels.AlienStructures,
        gCustomizeSceneData.kViewLabels.AlienTunnels,
        gCustomizeSceneData.kViewLabels.Skulk,
        gCustomizeSceneData.kViewLabels.Gorge,
        gCustomizeSceneData.kViewLabels.Lerk,
        gCustomizeSceneData.kViewLabels.Fade,
        gCustomizeSceneData.kViewLabels.Onos,
    }
}

gCustomizeSceneData.kDefaultviews =
{
    gCustomizeSceneData.kViewLabels.DefaultMarineView,
    gCustomizeSceneData.kViewLabels.DefaultAlienView,
}

gCustomizeSceneData.kSceneObjectReferences = enum({ 
    "CommandStation", "Extractor", 
    "Marine", "Exo", "Patches", 

    "Rifle", "Axe", "Welder", "Pistol",
    "Shotgun", "Flamethrower", "GrenadeLauncher",
    "HeavyMachineGun",

    "Hive", "Harvester", "Egg", 
    "Tunnel",
    "Skulk", "Lerk", "Gorge", "Fade", "Onos" 
})
gCustomizeSceneData.kSceneObjectVariantsMap = 
{
    [gCustomizeSceneData.kSceneObjectReferences.CommandStation] = kMarineStructureVariants,
    [gCustomizeSceneData.kSceneObjectReferences.Extractor] = kMarineStructureVariants,
    [gCustomizeSceneData.kSceneObjectReferences.Marine] = kMarineVariant,
    [gCustomizeSceneData.kSceneObjectReferences.Exo] = kExoVariant,

    [gCustomizeSceneData.kSceneObjectReferences.Rifle] = kRifleVariant,
    [gCustomizeSceneData.kSceneObjectReferences.Axe] = kAxeVariant,
    [gCustomizeSceneData.kSceneObjectReferences.Welder] = kWelderVariant,
    [gCustomizeSceneData.kSceneObjectReferences.Pistol] = kPistolVariant,
    [gCustomizeSceneData.kSceneObjectReferences.Shotgun] = kShotgunVariant,
    [gCustomizeSceneData.kSceneObjectReferences.GrenadeLauncher] = kGrenadeLauncherVariant,
    [gCustomizeSceneData.kSceneObjectReferences.Flamethrower] = kFlamethrowerVariant,
    [gCustomizeSceneData.kSceneObjectReferences.HeavyMachineGun] = kHMGVariant,

    [gCustomizeSceneData.kSceneObjectReferences.Hive] = kAlienStructureVariants,
    [gCustomizeSceneData.kSceneObjectReferences.Harvester] = kAlienStructureVariants,
    [gCustomizeSceneData.kSceneObjectReferences.Egg] = kAlienStructureVariants,
    [gCustomizeSceneData.kSceneObjectReferences.Tunnel] = kAlienTunnelVariants,
    [gCustomizeSceneData.kSceneObjectReferences.Skulk] = kSkulkVariant,
    [gCustomizeSceneData.kSceneObjectReferences.Gorge] = kGorgeVariant,
    [gCustomizeSceneData.kSceneObjectReferences.Lerk] = kLerkVariant,
    [gCustomizeSceneData.kSceneObjectReferences.Fade] = kFadeVariant,
    [gCustomizeSceneData.kSceneObjectReferences.Onos] = kOnosVariant,
}

gCustomizeSceneData.kSceneObjectVariantsDataMap =
{
    [gCustomizeSceneData.kSceneObjectReferences.CommandStation] = kMarineStructureVariantsData,
    [gCustomizeSceneData.kSceneObjectReferences.Extractor] = kMarineStructureVariantsData,
    [gCustomizeSceneData.kSceneObjectReferences.Marine] = kMarineVariantData,
    [gCustomizeSceneData.kSceneObjectReferences.Exo] = kExoVariantData,

    [gCustomizeSceneData.kSceneObjectReferences.Rifle] = kRifleVariantData,
    [gCustomizeSceneData.kSceneObjectReferences.Axe] = kAxeVariantData,
    [gCustomizeSceneData.kSceneObjectReferences.Welder] = kWelderVariantData,
    [gCustomizeSceneData.kSceneObjectReferences.Pistol] = kPistolVariantData,
    [gCustomizeSceneData.kSceneObjectReferences.Shotgun] = kShotgunVariantData,
    [gCustomizeSceneData.kSceneObjectReferences.GrenadeLauncher] = kGrenadeLauncherVariantData,
    [gCustomizeSceneData.kSceneObjectReferences.Flamethrower] = kFlamethrowerVariantData,
    [gCustomizeSceneData.kSceneObjectReferences.HeavyMachineGun] = kHMGVariantData,

    [gCustomizeSceneData.kSceneObjectReferences.Hive] = kAlienStructureVariantsData,
    [gCustomizeSceneData.kSceneObjectReferences.Harvester] = kAlienStructureVariantsData,
    [gCustomizeSceneData.kSceneObjectReferences.Egg] = kAlienStructureVariantsData,
    [gCustomizeSceneData.kSceneObjectReferences.Tunnel] = kAlienTunnelVariantsData,
    [gCustomizeSceneData.kSceneObjectReferences.Skulk] = kSkulkVariantData,
    [gCustomizeSceneData.kSceneObjectReferences.Gorge] = kGorgeVariantData,
    [gCustomizeSceneData.kSceneObjectReferences.Lerk] = kLerkVariantData,
    [gCustomizeSceneData.kSceneObjectReferences.Fade] = kFadeVariantData,
    [gCustomizeSceneData.kSceneObjectReferences.Onos] = kOnosVariantData,
}


gCustomizeSceneData.kSceneObjects = 
{
    
---------------------------------------
--Marine Zone Objects
    {
        name = "CommandStation",
        defaultPos = { origin = Vector(0.04, 0.53, 11), angles = Vector(0,0,0) },
        inputParams = 
        {
            { name = "occupied", value = false },
        },
        defaultTexIndex = 0,
        modelFile = PrecacheAsset("models/marine/command_station/command_station.model"),
        graphFile = "cinematics/menu/customize_command_station.animation_graph",
        team = kTeam1Index,
        customizable = true,
        cosmeticId = gCustomizeSceneData.kSceneObjectReferences.CommandStation,
        zoomedInputParams =  --Denotes what params should be set when object _begins_ to be Zoomed
        { 
            { name = "occupied", value = true }, 
        },
        zoomedRotationLocks = 
        { 
            pitch = {min = -20, max = 20},  --Only allow +/- 20 degrees of Pitch
            yaw = { min = nil, max = nil }, --Allow any degree of Yaw
            roll = false                    --Prevent any rotation
        },
        zoomedPositionOffset = Vector( 0, 0, 0 )
    },
    {
        name = "Extractor", 
        defaultPos = { origin = Vector(4.9, -0.3, 9.705), angles = Vector(0,180,0) },
        defaultTexIndex = 0,
        modelFile = PrecacheAsset("models/marine/extractor/extractor.model"),
        graphFile = "cinematics/menu/customize_extractor.animation_graph",
        team = kTeam1Index,
        customizable = true,
        cosmeticId = gCustomizeSceneData.kSceneObjectReferences.Extractor,
        zoomedRotationLocks = 
        { 
            pitch = {min = -20, max = 20},
            yaw = { min = nil, max = nil },
            roll = false
        }
    },

    {
        name = "MarineLeft", --"Reflects" player's cosmetic choice, but not gender
        defaultPos = { origin = Vector(1.38, -0.75, 3.12), angles = Vector(0, -75, 0) },
        poseParams = 
        {
            { name = "body_pitch", value = -18 },
            { name = "body_yaw", value = -10 },
        },
        inputParams = 
        {
            { name = "activity", value = "none" },
            { name = "move", value = "idle" },
            { name = "alive", value = true },
        },
        modelFile = PrecacheAsset("models/marine/male/male.model"),
        graphFile = "models/marine/male/male.animation_graph",
        team = kTeam1Index,
        customizable = true,
    },
    {
        name = "MarineCenter", --Never changes variant, static scene object
        defaultPos = { origin = Vector(0.19, -0.75, 5.22), angles = Vector(0, -175, 0) },
        poseParams = 
        {
            { name = "body_pitch", value = -32 },
            { name = "body_yaw", value = 6 },
        },
        inputParams = 
        {
            { name = "activity", value = "none" },
            { name = "move", value = "idle" },
            { name = "alive", value = true },
        },
        modelFile = PrecacheAsset("models/marine/female/female_special.model"),
        graphFile = "models/marine/male/male.animation_graph",
        team = kTeam1Index,
        customizable = true,
        staticVariant = kMarineVariant.special
    },
    {
        name = "MarineRight",  --Target for Player customizations / viewing
        defaultPos = { origin = Vector(-1.84, -0.74, 3), angles = Vector(0, 180, 0) },
        poseParams = 
        {
            { name = "body_pitch", value = 0 }, -- -14
            { name = "body_yaw", value = 0 }, -- 9
        },
        inputParams = 
        {
            { name = "activity", value = "none" },
            { name = "move", value = "idle" },
            { name = "alive", value = true },
        },
        modelFile = PrecacheAsset("models/marine/male/male.model"),
        graphFile = "models/marine/male/male.animation_graph",
        team = kTeam1Index,
        customizable = true,
        cosmeticId = gCustomizeSceneData.kSceneObjectReferences.Marine,
        zoomedInputParams = 
        { 
            { name = "activity", value = "none" },
            { name = "move", value = "idle" },
            { name = "alive", value = true },
        },
        zoomedPoseParams = --Denotes what params to set when zoom _begins_
        {
            { name = "body_pitch", value = 0 },
            { name = "body_yaw", value = 0 },
        },
        zoomedRotationLocks = 
        { 
            pitch = {min = -28, max = 28},
            yaw = { min = nil, max = nil },
            roll = false
        }
    },

    {
        name = "ExoMiniguns", --Target for Player customizations
        defaultPos = { origin = Vector(-8.09, 0.38, 4.92), angles = Vector(0, 90, 0) },
        defaultAnim = "idle",
        poseParams = 
        {
            { name = "body_pitch", value = -50 },
            { name = "body_yaw", value = 8.5 },
        },
        inputParams = 
        {
            { name = "move", value = "idle" },
            { name = "alive", value = true },
        },
        defaultTexIndex = 0,
        modelFile = PrecacheAsset("models/marine/exosuit/exosuit_mm.model"),
        graphFile = "cinematics/menu/customize_exosuit_mm.animation_graph",
        team = kTeam1Index,
        customizable = true,
        cosmeticId = gCustomizeSceneData.kSceneObjectReferences.Exo,
        zoomedInputParams = 
        { 
            { name = "move", value = "idle" },
            { name = "alive", value = true },
        },
        zoomedPoseParams = 
        {
            { name = "body_pitch", value = 0 },   --TODO Update to be "straight"
            { name = "body_yaw", value = 0 },
        },
        zoomedRotationLocks = 
        { 
            pitch = {min = -20, max = 20},
            yaw = { min = nil, max = nil },
            roll = false
        }
    },
    {
        name = "ExoRailguns", --"Reflects" player's cusmetic choice
        defaultPos = { origin = Vector( -8.09, 0.38, 1.74 ), angles = Vector( 0, 90, 0 ) },
        defaultAnim = "equip",
        isStatic = true,
        defaultTexIndex = 0,
        modelFile = PrecacheAsset("models/marine/exosuit/exosuit_rr.model"),
        --graphFile = "models/marine/exosuit/exosuit_rr.animation_graph",
        team = kTeam1Index,
        customizable = true,
        cosmeticId = gCustomizeSceneData.kSceneObjectReferences.Exo,
        zoomedRotationLocks = 
        { 
            pitch = {min = -18, max = 18},
            yaw = { min = nil, max = nil },
            roll = false
        }
    },

    {
        name = "Rifle",
        defaultPos = { origin = Vector(7.09, 2.1, 4.12), angles = Vector( -90, 90, 0 ) },
        isStatic = true,
        defaultTexIndex = 0,
        modelFile = PrecacheAsset("models/marine/rifle/rifle.model"),
        team = kTeam1Index,
        customizable = true,
        cosmeticId = gCustomizeSceneData.kSceneObjectReferences.Rifle,
        zoomedRotationLocks = 
        { 
            pitch = {min = -32, max = 32},
            yaw = { min = nil, max = nil },
            roll = false
        }
    },
    {
        name = "Pistol",
        defaultPos = { origin = Vector( 7.09, 2.21, 4.97 ), angles = Vector( -90, 90, 0 ) },
        isStatic = true,
        defaultTexIndex = 0,
        modelFile = PrecacheAsset("models/marine/pistol/pistol.model"),
        team = kTeam1Index,
        customizable = true,
        cosmeticId = gCustomizeSceneData.kSceneObjectReferences.Pistol,
        zoomedRotationLocks = 
        { 
            pitch = {min = -32, max = 32},
            yaw = { min = nil, max = nil },
            roll = false
        }
    },
    {
        name = "Welder",
        defaultPos = { origin = Vector( 7.1, 1.83, 4.6 ), angles = Vector( 0, 0, 90 ) },
        isStatic = true,
        defaultTexIndex = 0,
        modelFile = PrecacheAsset("models/marine/welder/welder.model"),
        team = kTeam1Index,
        customizable = true,
        cosmeticId = gCustomizeSceneData.kSceneObjectReferences.Welder,
        zoomedRotationLocks = 
        { 
            pitch = {min = -32, max = 32},
            yaw = { min = nil, max = nil },
            roll = false
        }
    },
    {
        name = "Axe",
        defaultPos = { origin = Vector( 7.1, 1.85, 5.32 ), angles = Vector( -75, 0, 90 ) },
        isStatic = true,
        defaultTexIndex = 0,
        modelFile = PrecacheAsset("models/marine/axe/axe.model"),
        team = kTeam1Index,
        customizable = true,
        cosmeticId = gCustomizeSceneData.kSceneObjectReferences.Axe,
        zoomedRotationLocks = 
        { 
            pitch = {min = -32, max = 32},
            yaw = { min = nil, max = nil },
            roll = false
        }
    },
    {
        name = "Shotgun",
        defaultPos = { origin = Vector( 7.08, 2.11, 5.95 ), angles = Vector( 90, 90, 0 ) },
        isStatic = true,
        defaultTexIndex = 0,
        modelFile = PrecacheAsset("models/marine/shotgun/shotgun.model"),
        team = kTeam1Index,
        customizable = true,
        cosmeticId = gCustomizeSceneData.kSceneObjectReferences.Shotgun,
        zoomedRotationLocks = 
        { 
            pitch = {min = -32, max = 32},
            yaw = { min = nil, max = nil },
            roll = false
        }
    },
    {
        name = "GrenadeLauncher",
        defaultPos = { origin = Vector( 7.07, 1.56, 4.38 ), angles = Vector( 90, 90, 0 ) },
        isStatic = true,
        defaultTexIndex = 0,
        modelFile = PrecacheAsset("models/marine/grenadelauncher/grenadelauncher.model"),
        team = kTeam1Index,
        customizable = true,
        cosmeticId = gCustomizeSceneData.kSceneObjectReferences.GrenadeLauncher,
        zoomedRotationLocks = 
        { 
            pitch = {min = -32, max = 32},
            yaw = { min = nil, max = nil },
            roll = false
        }
    },
    {
        name = "Flamethrower",
        defaultPos = { origin = Vector( 7.07, 1.66, 6 ), angles = Vector( -77.5, -90, -180 ) },
        isStatic = true,
        defaultTexIndex = 0,
        modelFile = PrecacheAsset("models/marine/flamethrower/flamethrower.model"),
        team = kTeam1Index,
        customizable = true,
        cosmeticId = gCustomizeSceneData.kSceneObjectReferences.Flamethrower,
        zoomedRotationLocks = 
        { 
            pitch = {min = -32, max = 32},
            yaw = { min = nil, max = nil },
            roll = false
        }
    },
    {
        name = "HeavyMachineGun",
        defaultPos = { origin = Vector( 6.64, 1.03, 4.92 ), angles = Vector( -17.03, 90, 0 ) },
        isStatic = true,
        defaultTexIndex = 0,
        modelFile = PrecacheAsset("models/marine/hmg/hmg.model"),
        team = kTeam1Index,
        customizable = true,
        cosmeticId = gCustomizeSceneData.kSceneObjectReferences.HeavyMachineGun,
        zoomedRotationLocks = 
        { 
            pitch = {min = -32, max = 32},
            yaw = { min = nil, max = nil },
            roll = false
        }
    },

---------------------------------------
--Transition Zone Objects
    {
        name = "VentSkulk", --XXX Could have this be updated on Skin changes too
        defaultPos = { origin = Vector(1.38, -2.38, -0.47), angles = Vector(0, -165, 0) },
        poseParams = 
        {
            { name = "body_pitch", value = -7.65 },
            { name = "body_yaw", value = 90 },
        },
        inputParams = 
        {
            { name = "move", value = "idle" },
            { name = "alive", value = true },
        },
        defaultTexIndex = 0,
        modelFile = PrecacheAsset("models/alien/skulk/skulk.model"),
        graphFile = "models/alien/skulk/skulk.animation_graph",
        team = kTeam2Index,
        customizable = false,  --Could change to true for a little extra fluff
    },
    {
        name = "VentSkulkBabblerBuddy", 
        defaultPos = { origin = Vector(-2.325, -2.34, -0.4), angles = Vector(0, 80, 0) },
        inputParams = 
        {
            { name = "move", value = "wag" },
        },
        defaultTexIndex = 0,
        modelFile = PrecacheAsset("models/alien/babbler/babbler.model"),
        graphFile = "models/alien/babbler/babbler.animation_graph",
        team = kTeam2Index,
    },

---------------------------------------
--Alien Zone Objects

    --Filler Objects
    {
        name = "FillerCyst", 
        defaultPos = { origin = Vector(-7.75, -8.22, 4.22 ), angles = Vector(-3.21, -14.65, -14.16) },
        inputParams = 
        {
            { name = "alive", value = true },
        },
        defaultTexIndex = 0,
        modelFile = PrecacheAsset("models/alien/cyst/cyst.model"),
        graphFile = "models/alien/cyst/cyst.animation_graph",
        team = kTeam2Index,
    },

    --Strutures
    {
        name = "AlienTechPoint", 
        defaultPos = { origin = Vector(3.05, -10.33, 11.31 ), angles = Vector(0, 0, 0) },
        inputParams = 
        {
            { name = "hive_deploy", value = true },
        },
        defaultTexIndex = 0,
        modelFile = PrecacheAsset("models/misc/tech_point/tech_point.model"),
        graphFile = "models/misc/tech_point/tech_point.animation_graph",
        team = kTeam2Index
    },
    {
        name = "Hive", 
        defaultPos = { origin = Vector(3.13, -8.175, 10.92 ), angles = Vector(0, 0, 0) },
        inputParams = 
        {
            { name = "built", value = true },
            { name = "alive", value = true },
            { name = "occupied", value = true },
        },
        defaultTexIndex = 0,
        modelFile = PrecacheAsset("models/alien/hive/hive.model"),
        graphFile = "models/alien/hive/hive.animation_graph",
        team = kTeam2Index,
        customizable = true,
        cosmeticId = gCustomizeSceneData.kSceneObjectReferences.Hive,
        zoomedInputParams = 
        {
            { name = "built", value = true },
            { name = "alive", value = true },
            { name = "occupied", value = true },
        },
        zoomedRotationLocks = 
        { 
            pitch = {min = -15, max = 15},
            yaw = { min = nil, max = nil },
            roll = false
        }
    },
    {
        name = "Harvester", 
        defaultPos = { origin = Vector(-1.88, -10.35, 11.88 ), angles = Vector(0, 155, 0) },
        inputParams = 
        {
            { name = "built", value = true },
            { name = "alive", value = true },
        },
        defaultTexIndex = 0,
        modelFile = PrecacheAsset("models/alien/harvester/harvester.model"),
        graphFile = "models/alien/harvester/harvester.animation_graph",
        team = kTeam2Index,
        customizable = true,
        cosmeticId = gCustomizeSceneData.kSceneObjectReferences.Harvester,
        zoomedInputParams = 
        {
            { name = "built", value = true },
            { name = "alive", value = true },
        },
        zoomedRotationLocks = 
        { 
            pitch = {min = -18, max = 18},
            yaw = { min = nil, max = nil },
            roll = false
        }
    },
    {
        name = "Egg", 
        defaultPos = { origin = Vector(-0.61, -10.38, 9.51 ), angles = Vector(0, -55, 0) },
        inputParams = 
        {
            { name = "built", value = true },
            { name = "alive", value = true },
            { name = "spawned", value = true },
        },
        defaultTexIndex = 0,
        modelFile = PrecacheAsset("models/alien/egg/egg.model"),
        graphFile = "models/alien/egg/egg.animation_graph",
        team = kTeam2Index,
        customizable = true,
        cosmeticId = gCustomizeSceneData.kSceneObjectReferences.Egg,
        zoomedInputParams = 
        {
            { name = "built", value = true },
            { name = "alive", value = true },
            { name = "spawned", value = true },
        },
        zoomedRotationLocks = 
        { 
            pitch = {min = -22, max = 22},
            yaw = { min = nil, max = nil },
            roll = false
        }
    },

    --Lifeforms
    {
        name = "Skulk", 
        defaultPos = { origin = Vector( -7.59, -9.35, 6.87 ), angles = Vector(16.74, 157.3, 63.07) },
        poseParams = 
        {
            { name = "body_pitch", value = 38 },
            { name = "body_yaw", value = 12 },
        },
        inputParams = 
        {
            { name = "alive", value = true },
            { name = "move", value = "idle" }, --taunt
        },
        defaultTexIndex = 0,
        modelFile = PrecacheAsset("models/alien/skulk/skulk.model"),
        graphFile = "models/alien/skulk/skulk.animation_graph",
        team = kTeam2Index,
        customizable = true,
        cosmeticId = gCustomizeSceneData.kSceneObjectReferences.Skulk,
        zoomedPoseParams = 
        {
            { name = "body_pitch", value = 0 },
            { name = "body_yaw", value = 0 },
        },
        zoomedInputParams = 
        {
            { name = "alive", value = true },
            { name = "move", value = "idle" }, --taunt
        },
        zoomedRotationLocks = 
        { 
            pitch = {min = -35, max = 35},
            yaw = { min = nil, max = nil },
            roll = false
        }
    },
    {
        name = "Lerk", 
        defaultPos = { origin = Vector( -9.35, -7.75, 6.7 ), angles = Vector(5, 84, 0) },
        poseParams = 
        {
            { name = "body_pitch", value = -15 },
            { name = "body_yaw", value = -75 },
        },
        inputParams = 
        {
            { name = "alive", value = true },
            { name = "move", value = "idle" },
            --{ name = "activity", value = "taunt" },
        },
        defaultTexIndex = 0,
        modelFile = PrecacheAsset("models/alien/lerk/lerk.model"),
        graphFile = "models/alien/lerk/lerk.animation_graph",
        team = kTeam2Index,
        customizable = true,
        cosmeticId = gCustomizeSceneData.kSceneObjectReferences.Lerk,
        zoomedPoseParams = 
        {
            { name = "body_pitch", value = 0 },
            { name = "body_yaw", value = 0 },
        },
        zoomedInputParams = 
        {
            { name = "alive", value = true },
            { name = "move", value = "idle" }, --taunt
        },
        zoomedRotationLocks = 
        { 
            pitch = {min = -36, max = 36},
            yaw = { min = nil, max = nil },
            roll = false
        }
    },
    {
        name = "Fade", 
        defaultPos = { origin = Vector( -4.175, -10.38, 11.95 ), angles = Vector(0, 218.5, 0) },
        poseParams = 
        {
            { name = "body_pitch", value = 12 },
            { name = "body_yaw", value = 90 },
            { name = "crouch", value = 0 }, --0.285
        },
        inputParams = 
        {
            { name = "alive", value = true },
            { name = "move", value = "idle" },
            --{ name = "activity", value = "taunt" },
        },
        defaultTexIndex = 0,
        modelFile = PrecacheAsset("models/alien/fade/fade.model"),
        graphFile = "models/alien/fade/fade.animation_graph",
        team = kTeam2Index,
        customizable = true,
        cosmeticId = gCustomizeSceneData.kSceneObjectReferences.Fade,
        zoomedPoseParams = 
        {
            { name = "body_pitch", value = 0 },
            { name = "body_yaw", value = 0 },
        },
        zoomedInputParams = 
        {
            { name = "alive", value = true },
            { name = "move", value = "idle" }, --taunt
        },
        zoomedRotationLocks = 
        { 
            pitch = {min = -30, max = 30},
            yaw = { min = nil, max = nil },
            roll = false
        }
    },
    {
        name = "Onos", 
        defaultPos = { origin = Vector( -7.25, -10.38, 11.85 ), angles = Vector(0, 140, 0) },
        poseParams = 
        {
            { name = "body_pitch", value = 11.45 },
            { name = "body_yaw", value = 0 },
            { name = "stoop", value = 0.5 },
        },
        inputParams = 
        {
            { name = "alive", value = true },
            { name = "move", value = "idle" },  --taunt
        },
        defaultTexIndex = 0,
        modelFile = PrecacheAsset("models/alien/onos/onos.model"),
        graphFile = "models/alien/onos/onos.animation_graph",
        team = kTeam2Index,
        customizable = true,
        cosmeticId = gCustomizeSceneData.kSceneObjectReferences.Onos,
        zoomedPoseParams = 
        {
            { name = "body_pitch", value = 0 },
            { name = "body_yaw", value = 0 },
        },
        zoomedInputParams = 
        {
            { name = "alive", value = true },
            { name = "move", value = "idle" }, --taunt
        },
        zoomedRotationLocks = 
        { 
            pitch = {min = -28, max = 28},
            yaw = { min = nil, max = nil },
            roll = false
        }
    },

    --Gorge-n-Toys
    {
        name = "Gorge", 
        defaultPos = { origin = Vector( -6.425, -10.325, 8.65 ), angles = Vector( 0, 115, 0 ) },
        poseParams = 
        {
            { name = "body_pitch", value = 20 },
            { name = "body_yaw", value = -45.75 },
        },
        inputParams = 
        {
            { name = "alive", value = true },
            { name = "move", value = "idle" },
            --{ name = "activity", value = "taunt" },
        },
        defaultTexIndex = 0,
        modelFile = PrecacheAsset("models/alien/gorge/gorge.model"),
        graphFile = "models/alien/gorge/gorge.animation_graph",
        team = kTeam2Index,
        customizable = true,
        cosmeticId = gCustomizeSceneData.kSceneObjectReferences.Gorge,
        zoomedPoseParams = 
        {
            { name = "body_pitch", value = 0 },
            { name = "body_yaw", value = 0 },
        },
        zoomedInputParams = 
        {
            { name = "alive", value = true },
            { name = "move", value = "idle" }, --taunt
        },
        zoomedRotationLocks = 
        { 
            pitch = {min = -28, max = 28},
            yaw = { min = nil, max = nil },
            roll = false
        }
    },
    {
        name = "Hydra", 
        defaultPos = { origin = Vector( -8.3, -8.725, 9.76 ), angles = Vector( -41.7, 11.59, -60.63 ) },
        inputParams = 
        {
            { name = "alive", value = true },
            { name = "built", value = true },
            --{ name = "alerting", value = true },  --TODO Change to idle-timed routine to trigger for X seconds
        },
        defaultTexIndex = 0,
        modelFile = PrecacheAsset("models/alien/hydra/hydra.model"),
        graphFile = "models/alien/hydra/hydra.animation_graph",
        team = kTeam2Index,
        customizable = true,
    },
    {
        name = "Clog",
        defaultPos = { origin = Vector(-5.45, -10.7, 7.4), angles = Vector(0, -30, 35) },
        isStatic = true,
        defaultTexIndex = 0,
        modelFile = PrecacheAsset("models/alien/gorge/clog.model"),
        team = kTeam2Index,
        customizable = true,
    },
    {
        name = "BabblerEgg", 
        defaultPos = { origin = Vector(-5.35, -10.38, 9.25), angles = Vector(0, 165, 0) },
        poseParams = 
        {
            { name = "grow", value = 0.5 },
        },
        inputParams = 
        {
            { name = "alive", value = true },
        },
        defaultTexIndex = 0,
        modelFile = PrecacheAsset("models/alien/babbler/babbler_egg.model"),
        graphFile = "models/alien/babbler/babbler_egg.animation_graph",
        team = kTeam2Index,
        customizable = true,
    },
    {
        name = "Babbler",
        defaultPos = { origin = Vector(-5.38, -10.09, 7.32), angles = Vector( -7.5, 56, -2) },
        inputParams = 
        {
            { name = "move", value = "idle" },
        },
        defaultTexIndex = 0,
        modelFile = PrecacheAsset("models/alien/babbler/babbler.model"),
        graphFile = "models/alien/babbler/babbler.animation_graph",
        team = kTeam2Index,
        customizable = true,
    },

    --Tunnels
    {
        name = "Tunnel", 
        defaultPos = { origin = Vector(-2.85, -10.64, 6.53 ), angles = Vector(0, 0, 0) },
        inputParams = 
        {
            { name = "built", value = true },
            { name = "open", value = true },
            { name = "skip_open", value = true },
        },
        defaultTexIndex = 0,
        modelFile = PrecacheAsset("models/alien/tunnel/mouth.model"),
        graphFile = "models/alien/tunnel/mouth.animation_graph",
        team = kTeam2Index,
        customizable = true,
        cosmeticId = gCustomizeSceneData.kSceneObjectReferences.Tunnel,
        zoomedInputParams = 
        {
            { name = "built", value = true },
            { name = "open", value = true },
            { name = "skip_open", value = true },
        },
        zoomedRotationLocks = 
        { 
            pitch = {min = -18, max = 18},
            yaw = { min = nil, max = nil },
            roll = false
        }
    },
}

local function PreacheGraphs()
    for i = 1, #gCustomizeSceneData.kSceneObjects do
        if gCustomizeSceneData.kSceneObjects[i].graphFile then
            Client.PrecacheLoadAnimationGraph(gCustomizeSceneData.kSceneObjects[i].graphFile)
        end
    end
end
--This must be done via this event because the needed function isn't active until then
Event.Hook("LoadComplete", PreacheGraphs)


local function GetSceneCinematicCoords( origin, yaw, pitch, roll )
    assert(origin)
    local angle = Angles()
    angle.yaw = yaw and yaw or 0
    angle.pitch = pitch and pitch or 0
    angle.roll = roll and roll or 0
    return angle:GetCoords( origin )
end

gCustomizeSceneData.kSceneCinematics =
{
    {
        fileName = gCustomizeSceneData.kHiveTechpointFX,
        playbackType = Cinematic.Repeat_Endless,
        coords = GetSceneCinematicCoords( Vector( 3.05, -10.33, 11.31 ) ),
    },
    {
        fileName = gCustomizeSceneData.kHiveTechpointLightFX,
        playbackType = Cinematic.Repeat_Loop,
        coords = GetSceneCinematicCoords( Vector( 3.05, -10.33, 11.31 ) ),
    },
    {
        fileName = gCustomizeSceneData.kHiveWisps,
        playbackType = Cinematic.Repeat_Endless,
        coords = GetSceneCinematicCoords( Vector( 3.13, -9.5, 10.92 ) ),
    },
    {
        fileName = gCustomizeSceneData.kHiveWisps_Toxin,
        playbackType = Cinematic.Repeat_Endless,
        coords = GetSceneCinematicCoords( Vector( 3.13, -9.5, 10.92 ) ),
        initVisible = false
    },
    {
        fileName = gCustomizeSceneData.kHiveMist,
        playbackType = Cinematic.Repeat_Endless,
        coords = GetSceneCinematicCoords( Vector( 2.925, -7.88, 10.9 ) ),
    },
    {
        fileName = gCustomizeSceneData.kLavaBubbleFX,
        playbackType = Cinematic.Repeat_Loop,
        coords = GetSceneCinematicCoords( Vector( 2.31, -14, 5.2 ) ),
    },
    {
        fileName = gCustomizeSceneData.kLavaBubbleFX,
        playbackType = Cinematic.Repeat_Loop,
        coords = GetSceneCinematicCoords( Vector( 2.63, -13.75, 6.13 ), -90 ),
    },
    {
        fileName = gCustomizeSceneData.kLavaBubbleFX,
        playbackType = Cinematic.Repeat_Loop,
        coords = GetSceneCinematicCoords( Vector( -6.75, -14, 5 ), 45 ),
    },
    {
        fileName = gCustomizeSceneData.kLavaFallFX,
        playbackType = Cinematic.Repeat_Endless,
        coords = GetSceneCinematicCoords( Vector( 7, -7.925, 6 ), -90 ),
    },
    {
        fileName = gCustomizeSceneData.kLavaFallFX,
        playbackType = Cinematic.Repeat_Endless,
        coords = GetSceneCinematicCoords( Vector( 5.65, -12.36, 5.88 ), -90 ),
    },
    {
        fileName = gCustomizeSceneData.kMoseyingDrifter,
        playbackType = Cinematic.Repeat_Loop,
        coords = GetSceneCinematicCoords( Vector( 2.2425, -4.865, 6.975 ), -89 ),
    },
}

--local fovDegrees = Math.Degrees(GetScreenAdjustedFov(Client.GetEffectiveFov(self), 4/3))
--NEED a means to get FOV value via simple function

--?? Define transitions as separate data? Should this just be a special case (e.g. team-view change)
--[[
gCustomizeSceneData.kCameraPaths = 
{
    [gCustomizeSceneData.kViewLabels.TeamTransition] = 
    {
        --???
    }
}
--]]

gCustomizeSceneData.kCameraViewPositions = 
{

    ---------------------------------------
    --Marine Camera View Positions
    [gCustomizeSceneData.kViewLabels.DefaultMarineView] = 
    { 
        origin = Vector( 1.425, 1.75, -1.45 ),
        target = Vector( 0.115, 0.115, 8.9 ),
        fov = math.rad(108),
        animTime = 2,
        activationDist = 2.75,
        team = kTeam1Index
    },
    [gCustomizeSceneData.kViewLabels.Marines] = 
    {
        origin = Vector( -1.985, 0.65, 1 ),
        target = Vector( -1.68, -0.125, 5.98 ),
        fov = math.rad(90),
        animTime = 1.75,
        activationDist = 1.2,
        team = kTeam1Index,
        --TODO Add "LookUp" callback (needs reset when moving away...so "OnBlur" and "OnFocus")
    },
    [gCustomizeSceneData.kViewLabels.ShoulderPatches] = 
    {
        origin = Vector( -2.6, 1, 2.5 ),      --origin = Vector( -1.465, 1.03, 2.35 ),
        target = Vector( -1.05, 0.5, 3.39 ),      --target = Vector( -2.97, -0.75, 6.34 ),
        fov = math.rad(70),
        animTime = 0.5,
        activationDist = 1.2,
        team = kTeam1Index
    },
    [gCustomizeSceneData.kViewLabels.ExoBay] = 
    {
        origin = Vector(-2.55, 3.4925, 3.15),
        target = Vector( -11.5, 1.05, 3.865 ),
        fov = math.rad(60),
        animTime = 4.5,
        activationDist = 0.8,
        team = kTeam1Index
    },
    [gCustomizeSceneData.kViewLabels.Armory] = 
    {
        origin = Vector(4, 1.85, 4.9328),
        target = Vector( 7.11, 1.75, 4.8995 ),
        fov = math.rad(68),
        animTime = 6,
        activationDist = 0.85,
        startMoveDelay = 0.085,
        team = kTeam1Index
    },
    [gCustomizeSceneData.kViewLabels.MarineStructures] = 
    {
        origin = Vector( 1.65, 4.1, 4.25 ),
        target = Vector( 2.36, 0.15, 12.5 ),
        fov = math.rad(88),
        animTime = 1,
        activationDist = 1.75,
        startMoveDelay = 0.01,
        team = kTeam1Index
    },

    --Marine Sub-Views---------------------
    [gCustomizeSceneData.kViewLabels.Rifle] = 
    {
        origin = Vector( 4, 1.8, 4.9315 ),
        target = Vector( 7.09, 2.0865, 4.0325 ),
        fov = math.rad(18.5),
        animTime = 8,
        activationDist = 0.1,
        team = kTeam1Index
    },
    [gCustomizeSceneData.kViewLabels.Pistol] = 
    {
        origin = Vector( 4, 1.8, 4.9315 ),
        target = Vector( 7.09, 2.21, 4.925 ),
        fov = math.rad(16),
        animTime = 8,
        activationDist = 0.1,
        team = kTeam1Index
    },
    [gCustomizeSceneData.kViewLabels.Axe] = 
    {
        origin = Vector( 4, 1.8, 4.9315 ),
        target = Vector( 7.1, 1.885, 5.135 ),
        fov = math.rad(16),
        animTime = 8,
        activationDist = 0.1,
        team = kTeam1Index
    },
    [gCustomizeSceneData.kViewLabels.Welder] = 
    {
        origin = Vector( 4, 1.8, 4.9315 ),
        target = Vector( 7.1, 1.885, 4.681 ),
        fov = math.rad(13),
        animTime = 8,
        activationDist = 0.1,
        team = kTeam1Index
    },
    [gCustomizeSceneData.kViewLabels.Shotgun] = 
    {
        origin = Vector( 4, 1.8, 4.9315 ),
        target = Vector( 7.08, 2.11, 5.74 ),
        fov = math.rad(17),
        animTime = 8,
        activationDist = 0.1,
        team = kTeam1Index
    },
    [gCustomizeSceneData.kViewLabels.GrenadeLauncher] = 
    {
        origin = Vector( 4, 1.8, 4.9315 ),
        target = Vector( 7.07, 1.65, 4.185 ),
        fov = math.rad(17.5),
        animTime = 8,
        activationDist = 0.1,
        team = kTeam1Index
    },
    [gCustomizeSceneData.kViewLabels.Flamethrower] = 
    {
        origin = Vector( 4, 1.8, 4.9315 ),
        target = Vector( 7.07, 1.65, 5.57625 ),
        fov = math.rad(23.68),
        animTime = 8,
        activationDist = 0.1,
        team = kTeam1Index
    },
    [gCustomizeSceneData.kViewLabels.HeavyMachinegun] = 
    {
        origin = Vector( 4, 1.8, 4.9315 ),
        target = Vector( 6.64, 1.1425, 4.8965 ),
        fov = math.rad(26.125),
        animTime = 8,
        activationDist = 0.1,
        team = kTeam1Index
    },

    

    ---------------------------------------
    --Transition Vent / Team-View change mid-point
    [gCustomizeSceneData.kViewLabels.TeamTransition] = 
    {
        origin = Vector( 0.65, -1.5, -4.5 ),
        target = Vector( 0, -1.38, 1.38 ),
        fov = math.rad(88),
        animTime = 1.5,
        activationDist = 0.2,
        --These "relay" into their intended views, based on the team-value of a target view
        targetTeam1View = gCustomizeSceneData.kViewLabels.DefaultMarineView,
        targetTeam2View = gCustomizeSceneData.kViewLabels.DefaultAlienView
    },

    ---------------------------------------
    --Alien Camera View Positions
    [gCustomizeSceneData.kViewLabels.DefaultAlienView] = 
    {
        origin = Vector( -0.07, -5.725, -2.6 ),
        target = Vector( -3.5, -11, 16.5 ),
        fov = math.rad(89),
        animTime = 2,
        activationDist = 2,
    },
    [gCustomizeSceneData.kViewLabels.AlienStructures] = 
    {
        origin = Vector( -1.75, -7.25, 5.25 ),
        target = Vector( 3.7185, -10.465, 13.705 ),
        fov = math.rad(84),
        animTime = 2,
        activationDist = 2,
    },
    [gCustomizeSceneData.kViewLabels.AlienLifeforms] = 
    {
        origin = Vector( -1.88, -8.25, 6 ),
        target = Vector( -10, -10.25, 11.55 ),
        fov = math.rad(86),
        animTime = 4,
        activationDist = 2,
    },
    [gCustomizeSceneData.kViewLabels.AlienTunnels] = 
    {
        origin = Vector( -1.25, -8, 1.88 ),
        target = Vector( -3.7, -12.15, 8.45 ),
        fov = math.rad(65),
        animTime = 3.75,
        activationDist = 2,
    },

    --FIXME All Lifeform points are going to need target changed (it should be "center mass" of model)
    [gCustomizeSceneData.kViewLabels.Skulk] = 
    {
        origin = Vector( -1.88, -8.25, 6 ),
        target = Vector( -7.59, -9.35, 6.87 ),
        fov = math.rad(30),
        animTime = 6.5,
        activationDist = 0,
    },
    [gCustomizeSceneData.kViewLabels.Gorge] = 
    {
        origin = Vector( -1.88, -8.25, 6 ),
        target = Vector( -6.425, -10, 8.685 ),
        fov = math.rad(43),
        animTime = 6.5,
        activationDist = 0,
    },
    [gCustomizeSceneData.kViewLabels.Lerk] = 
    {
        origin = Vector( -1.88, -8.25, 6 ),
        target = Vector( -9.35, -7.325, 6.7 ),
        fov = math.rad(25.5),
        animTime = 6.5,
        activationDist = 0,
    },
    [gCustomizeSceneData.kViewLabels.Fade] = 
    {
        origin = Vector( -1.88, -8.25, 6 ),
        target = Vector( -4.175, -9.595, 11.65 ),
        fov = math.rad(30),
        animTime = 6.5,
        activationDist = 0,
    },
    [gCustomizeSceneData.kViewLabels.Onos] = 
    {
        origin = Vector( -1.88, -8.25, 6 ),
        target = Vector( -7.245, -9.1, 11.9 ),
        fov = math.rad(43.925),
        animTime = 6.5,
        activationDist = 0.01,
    },
}

gCustomizeSceneData.kDefaultViewLabel = gCustomizeSceneData.kViewLabels.DefaultMarineView
gCustomizeSceneData.kDefaultView = gCustomizeSceneData.kCameraViewPositions[gCustomizeSceneData.kDefaultViewLabel]


-------------------------------------------------------------------------------
---Helper Functions

function GetCustomizeScenePosition( posLabel )
    assert(posLabel)  --isenum?
    return gCustomizeSceneData.kCameraViewPositions[posLabel]
end

function GetIsViewForTeam( viewLabel, teamIndex )
    assert(viewLabel and teamIndex)
    if gCustomizeSceneData.kTeamViews[teamIndex] then
        return table.icontains( gCustomizeSceneData.kTeamViews[teamIndex], viewLabel )
    end
    Log("Error: Invalid team index[%s] in view list data", teamIndex)
    return false
end

function GetViewTeamIndex( viewLabel )
    return ( table.icontains( gCustomizeSceneData.kTeamViews[kTeam1Index], viewLabel ) and kTeam1Index or kTeam2Index )
end

function GetIsDefaultView( viewLabel )
    return table.icontains( gCustomizeSceneData.kDefaultviews, viewLabel )
end

function GetObjectSelectableMaterial( teamIndex )
    return (teamIndex == kTeam1Index and gCustomizeSceneData.kMarineTeamSelectableMaterial
    or gCustomizeSceneData.kAlienTeamSelectableMaterial)
end

function GetObjectHighlightMaterial( teamIndex )
    return (teamIndex == kTeam1Index and gCustomizeSceneData.kMarineTeamHighlightMaterial
    or gCustomizeSceneData.kAlienTeamHighlightMaterial)
end

function GetSceneObjectInitData( objectName )
    assert(objectName)
    for i = 1, #gCustomizeSceneData.kSceneObjects do
        if gCustomizeSceneData.kSceneObjects[i].name == objectName then
            return gCustomizeSceneData.kSceneObjects[i]
        end
    end
    return nil
end

--Build list of all items client currently owns
function FetchAllOwnedItems()

    local ownedItems = {}

    ownedItems["marineVariant"] = {}
    for i = 1, #kMarineVariant do
        local key = kMarineVariant[i]
        local itemId = kMarineVariantData[kMarineVariant[key]].itemId
        if itemId == nil or GetHasVariant( kMarineVariantData, i, nil ) then
            table.insert(ownedItems["marineVariant"], key)
        end
    end
    
    ownedItems["exoVariant"] = {}
    for i = 1, #kExoVariant do
        local key = kExoVariant[i]
        local itemId = kExoVariantData[kExoVariant[key]].itemId
        if itemId == nil or GetHasVariant( kExoVariantData, i, nil ) then
            table.insert(ownedItems["exoVariant"], key)
        end
    end

    ownedItems["marineStructuresVariant"] = {}
    for i = 1, #kMarineStructureVariants do
        local key = kMarineStructureVariants[i]
        local itemId = kMarineStructureVariantsData[kMarineStructureVariants[key]].itemId
        if itemId == nil or GetHasVariant( kMarineStructureVariantsData, i, nil ) then
            table.insert(ownedItems["marineStructuresVariant"], key)
        end
    end

    ownedItems["rifleVariant"] = {}
    for i = 1, #kRifleVariant do
        local key = kRifleVariant[i]
        local itemId = kRifleVariantData[kRifleVariant[key]].itemId
        if itemId == nil or GetHasVariant( kRifleVariantData, i, nil ) then
            table.insert(ownedItems["rifleVariant"], key)
        end
    end

    ownedItems["pistolVariant"] = {}
    for i = 1, #kPistolVariant do
        local key = kPistolVariant[i]
        local itemId = kPistolVariantData[kPistolVariant[key]].itemId
        if itemId == nil or GetHasVariant( kPistolVariantData, i, nil ) then
            table.insert(ownedItems["pistolVariant"], key)
        end
    end

    ownedItems["axeVariant"] = {}
    for i = 1, #kAxeVariant do
        local key = kAxeVariant[i]
        local itemId = kAxeVariantData[kAxeVariant[key]].itemId
        if itemId == nil or GetHasVariant( kAxeVariantData, i, nil ) then
            table.insert(ownedItems["axeVariant"], key)
        end
    end

    ownedItems["welderVariant"] = {}
    for i = 1, #kWelderVariant do
        local key = kWelderVariant[i]
        local itemId = kWelderVariantData[kWelderVariant[key]].itemId
        if itemId == nil or GetHasVariant( kWelderVariantData, i, nil ) then
            table.insert(ownedItems["welderVariant"], key)
        end
    end

    ownedItems["shotgunVariant"] = {}
    for i = 1, #kShotgunVariant do
        local key = kShotgunVariant[i]
        local itemId = kShotgunVariantData[kShotgunVariant[key]].itemId
        if itemId == nil or GetHasVariant( kShotgunVariantData, i, nil ) then
            table.insert(ownedItems["shotgunVariant"], key)
        end
    end

    ownedItems["grenadeLauncherVariant"] = {}
    for i = 1, #kGrenadeLauncherVariant do
        local key = kGrenadeLauncherVariant[i]
        local itemId = kGrenadeLauncherVariantData[kGrenadeLauncherVariant[key]].itemId
        if itemId == nil or GetHasVariant( kGrenadeLauncherVariantData, i, nil ) then
            table.insert(ownedItems["grenadeLauncherVariant"], key)
        end
    end

    ownedItems["flamethrowerVariant"] = {}
    for i = 1, #kFlamethrowerVariant do
        local key = kFlamethrowerVariant[i]
        local itemId = kFlamethrowerVariantData[kFlamethrowerVariant[key]].itemId
        if itemId == nil or GetHasVariant( kFlamethrowerVariantData, i, nil ) then
            table.insert(ownedItems["flamethrowerVariant"], key)
        end
    end

    ownedItems["hmgVariant"] = {}
    for i = 1, #kHMGVariant do
        local key = kHMGVariant[i]
        local itemId = kHMGVariantData[kHMGVariant[key]].itemId
        if itemId == nil or GetHasVariant( kHMGVariantData, i, nil ) then
            table.insert(ownedItems["hmgVariant"], key)
        end
    end

    ownedItems["skulkVariant"] = {}
    for i = 1, #kSkulkVariant do
        local key = kSkulkVariant[i]
        local itemId = kSkulkVariantData[kSkulkVariant[key]].itemId
        if itemId == nil or GetHasVariant( kSkulkVariantData, i, nil ) then
            table.insert(ownedItems["skulkVariant"], key)
        end
    end

    ownedItems["gorgeVariant"] = {}
    for i = 1, #kGorgeVariant do
        local key = kGorgeVariant[i]
        local itemId = kGorgeVariantData[kGorgeVariant[key]].itemId
        if itemId == nil or GetHasVariant( kGorgeVariantData, i, nil ) then
            table.insert(ownedItems["gorgeVariant"], key)
        end
    end

    ownedItems["lerkVariant"] = {}
    for i = 1, #kLerkVariant do
        local key = kLerkVariant[i]
        local itemId = kLerkVariantData[kLerkVariant[key]].itemId
        if itemId == nil or GetHasVariant( kLerkVariantData, i, nil ) then
            table.insert(ownedItems["lerkVariant"], key)
        end
    end

    ownedItems["fadeVariant"] = {}
    for i = 1, #kFadeVariant do
        local key = kFadeVariant[i]
        local itemId = kFadeVariantData[kFadeVariant[key]].itemId
        if itemId == nil or GetHasVariant( kFadeVariantData, i, nil ) then
            table.insert(ownedItems["fadeVariant"], key)
        end
    end

    ownedItems["onosVariant"] = {}
    for i = 1, #kOnosVariant do
        local key = kOnosVariant[i]
        local itemId = kOnosVariantData[kOnosVariant[key]].itemId
        if (itemId == nil and not kOnosVariantData[kOnosVariant[key]].itemIds) or GetHasVariant( kOnosVariantData, i, nil ) then
            table.insert(ownedItems["onosVariant"], key)
        elseif kOnosVariantData[kOnosVariant[key]].itemIds then --one-off for Shadow Onos
            local id1 = kOnosVariantData[kOnosVariant[key]].itemIds[1]
            local id2 = kOnosVariantData[kOnosVariant[key]].itemIds[2]
            if GetHasVariant( kOnosVariantData, id1, nil ) or GetHasVariant( kOnosVariantData, id2, nil ) then
                table.insert(ownedItems["onosVariant"], key)
            end
        end
    end

    ownedItems["alienStructuresVariant"] = {}
    for i = 1, #kAlienStructureVariants do
        local key = kAlienStructureVariants[i]
        local itemId = kAlienStructureVariantsData[kAlienStructureVariants[key]].itemId
        if itemId == nil or GetHasVariant( kAlienStructureVariantsData, i, nil ) then
            table.insert(ownedItems["alienStructuresVariant"], key)
        end
    end

    ownedItems["alienTunnelsVariant"] = {}
    for i = 1, #kAlienTunnelVariants do
        local key = kAlienTunnelVariants[i]
        local itemId = kAlienTunnelVariantsData[kAlienTunnelVariants[key]].itemId
        if itemId == nil or GetHasVariant( kAlienTunnelVariantsData, i, nil ) then
            table.insert(ownedItems["alienTunnelsVariant"], key)
        end
    end
    
    ownedItems["shoudlerPatches"] = {}
    for i = 1, #kShoulderPadNames do
        if GetHasShoulderPad(i) then
            table.insert(ownedItems["shoudlerPatches"], i)
        end
    end

    return ownedItems
end


function GetVariantData( costmeticTypeId )
    assert(costmeticTypeId and gCustomizeSceneData.kSceneObjectVariantsDataMap[costmeticTypeId])
    return gCustomizeSceneData.kSceneObjectVariantsDataMap[costmeticTypeId]
end

function GetNextOwnedVariant( variants, ownedVariants, curIdx )
    assert(variants and type(variants) == "table")
    assert(ownedVariants and type(ownedVariants) == "table")
    assert(curIdx and type(curIdx) == "number" and curIdx > 0)
    
    local nextIdx = curIdx + 1
    if nextIdx > #ownedVariants then
        nextIdx = 1
    end

    return variants[ownedVariants[nextIdx]], nextIdx
end

function GetOwnedVariantIndexByVariantId( ownedVariants, variantId, variants )
    assert(ownedVariants and type(ownedVariants) == "table")
    assert(variants and type(variants) == "table")
    assert(variantId and type(variantId) == "number" and variantId > 0)

    for i = 1, #ownedVariants do
        local tVarId = variants[ownedVariants[i]]
        if tVarId == variantId then
            return tVarId
        end
    end

    return false --not found
end

function GetBabblerVariantModel( variant )
    assert(variant)
    if variant == kGorgeVariant.shadow then
        return "models/alien/babbler/babbler_shadow.model"
    elseif variant == kGorgeVariant.abyss then
        return "models/alien/babbler/babbler_abyss.model"
    end
    return "models/alien/babbler/babbler.model"
end

function GetBabblerEggVariantModel(variant)
    assert(variant)
    if variant == kGorgeVariant.shadow then
        return "models/alien/babbler/babbler_egg_shadow.model"
    elseif variant == kGorgeVariant.abyss then
        return "models/alien/babbler/babbler_egg_abyss.model"
    end
    return "models/alien/babbler/babbler_egg.model"
end

function GetClogVariantModel( variant )
    assert(variant)
    if variant == kGorgeVariant.shadow then
        return "models/alien/gorge/clog_shadow.model"
    elseif variant == kGorgeVariant.toxin then
        return "models/alien/gorge/clog_toxin.model"
    elseif variant == kGorgeVariant.abyss then
        return "models/alien/gorge/clog_abyss.model"
    end
    return "models/alien/gorge/clog.model"
end

function GetHydraVariantModel( variant )
    assert(variant)
    if variant == kGorgeVariant.shadow then
        return "models/alien/hydra/hydra_shadow.model"
    elseif variant == kGorgeVariant.abyss then
        return "models/alien/hydra/hydra_abyss.model"
    end
    return "models/alien/hydra/hydra.model"
end

function GetGorgeToysTextureIndex( gorgeVariant )
    assert(gorgeVariant)
    return gorgeVariant == kGorgeVariant.toxin and 1 or 0
end

function GetCustomizableModelPath( label, sex, options )
    assert(label and type(label) == "string" and label ~= "")
    assert(options)

    local modelType = string.lower(label)
    local modelPath = nil

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

    elseif modelType == "marine" then
        modelPath = "models/marine/" .. sex .. "/" .. sex .. GetVariantModel(kMarineVariantData, options.marineVariant)

    elseif modelType == "exo_mm" then
        modelPath =  "models/marine/exosuit/exosuit_mm.model"

    elseif modelType == "exo_rr" then
        modelPath =  "models/marine/exosuit/exosuit_rr.model"

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

    elseif modelType == "grenadelauncher" then
        modelPath = "models/marine/grenadelauncher/grenadelauncher" .. GetVariantModel(kGrenadeLauncherVariantData, options.grenadeLauncherVariant)

    elseif modelType == "welder" then
        modelPath = "models/marine/welder/welder" .. GetVariantModel(kWelderVariantData, options.welderVariant)

    elseif modelType == "hmg" then
        modelPath = "models/marine/hmg/hmg" .. GetVariantModel(kHMGVariantData, options.hmgVariant)

    elseif modelType == "command_station" then
        modelPath = "models/marine/command_station/command_station.model"

    elseif modelType == "extractor" then
        modelPath = "models/marine/extractor/extractor.model"

    elseif modelType == "hive" then
        modelPath = "models/alien/hive/hive.model"

    elseif modelType == "egg" then
        modelPath = "models/alien/egg/egg.model"

    elseif modelType == "harvester" then
        modelPath = "models/alien/harvester/harvester.model"

    elseif modelType == "hydra" then
        modelPath = GetHydraVariantModel(options.gorgeVariant)

    elseif modelType == "babbler" then
        modelPath = GetBabblerVariantModel(options.gorgeVariant)

    elseif modelType == "babbler_egg" then
        modelPath = GetBabblerEggVariantModel(options.gorgeVariant)

    elseif modelType == "clog" then
        modelPath = GetClogVariantModel(options.gorgeVariant)

    elseif modelType == "tunnel" then
        modelPath = "models/alien/tunnel/mouth" .. GetVariantModel(kAlienTunnelVariantsData, options.alienTunnelsVariant)
    end

    return modelPath
end


local function PrecacheCustomizeAssets()

    local cachedList = {} --simple dumb list to only call precache once per model

    for i = 1, #kMarineVariant do
        local model = GetCustomizableModelPath( "marine", "male", { marineVariant = i } )
        if model and not table.icontains(cachedList, model) then
            PrecacheAsset( model )
            table.insert(cachedList, model)
        end
    end

    for i = 1, #kMarineVariant do
        local model = GetCustomizableModelPath( "marine", "female", { marineVariant = i } )
        if model and not table.icontains(cachedList, model) then
            PrecacheAsset( model )
            table.insert(cachedList, model)
        end
    end

    for i = 1, #kOnosVariant do
        local model = GetCustomizableModelPath( "onos", "male", { onosVariant = i } )
        if model and not table.icontains(cachedList, model) then
            PrecacheAsset( model )
            table.insert(cachedList, model)
        end
    end

    for i = 1, #kFadeVariant do
        local model = GetCustomizableModelPath( "fade", "male", { fadeVariant = i } )
        if model and not table.icontains(cachedList, model) then
            PrecacheAsset( model )
            table.insert(cachedList, model)
        end
    end

    for i = 1, #kLerkVariant do
        local model = GetCustomizableModelPath( "lerk", "male", { lerkVariant = i } )
        if model and not table.icontains(cachedList, model) then
            PrecacheAsset( model )
            table.insert(cachedList, model)
        end
    end

    for i = 1, #kSkulkVariant do
        local model = GetCustomizableModelPath( "skulk", "male", { skulkVariant = i } )
        if model and not table.icontains(cachedList, model) then
            PrecacheAsset( model )
            table.insert(cachedList, model)
        end
    end

    for i = 1, #kRifleVariant do
        local model = GetCustomizableModelPath( "rifle", "male", { rifleVariant = i } )
        if model and not table.icontains(cachedList, model) then
            PrecacheAsset( model )
            table.insert(cachedList, model)
        end
    end

    for i = 1, #kShotgunVariant do
        local model = GetCustomizableModelPath( "shotgun", "male", { shotgunVariant = i } )
        if model and not table.icontains(cachedList, model) then
            PrecacheAsset( model )
            table.insert(cachedList, model)
        end
    end

    for i = 1, #kPistolVariant do
        local model = GetCustomizableModelPath( "pistol", "male", { pistolVariant = i } )
        if model and not table.icontains(cachedList, model) then
            PrecacheAsset( model )
            table.insert(cachedList, model)
        end
    end

    for i = 1, #kAxeVariant do
        local model = GetCustomizableModelPath( "axe", "male", { axeVariant = i } )
        if model and not table.icontains(cachedList, model) then
            PrecacheAsset( model )
            table.insert(cachedList, model)
        end
    end

    for i = 1, #kFlamethrowerVariant do
        local model = GetCustomizableModelPath( "flamethrower", "male", { flamethrowerVariant = i } )
        if model and not table.icontains(cachedList, model) then
            PrecacheAsset( model )
            table.insert(cachedList, model)
        end
    end

    for i = 1, #kGrenadeLauncherVariant do
        local model = GetCustomizableModelPath( "grenadelauncher", "male", { grenadeLauncherVariant = i } )
        if model and not table.icontains(cachedList, model) then
            PrecacheAsset( model )
            table.insert(cachedList, model)
        end
    end

    for i = 1, #kWelderVariant do
        local model = GetCustomizableModelPath( "welder", "male", { welderVariant = i } )
        if model and not table.icontains(cachedList, model) then
            PrecacheAsset( model )
            table.insert(cachedList, model)
        end
    end

    for i = 1, #kExoVariant do
        local model = GetCustomizableModelPath( "exo", "male", { exoVariant = i } )
        if model and not table.icontains(cachedList, model) then
            PrecacheAsset( model )
            table.insert(cachedList, model)
        end
    end

    for i = 1, #kMarineStructureVariants do
        local csModel = GetCustomizableModelPath( "command_station", "male", { } )
        local eModel = GetCustomizableModelPath( "extractor", "male", { } )

        if csModel and not table.icontains(cachedList, csModel) then
            PrecacheAsset( csModel )
            table.insert(cachedList, csModel)
        end

        if eModel and not table.icontains(cachedList, eModel) then
            PrecacheAsset( eModel )
            table.insert(cachedList, eModel)
        end
    end

    for i = 1, #kAlienStructureVariants do
        local hiveModel = GetCustomizableModelPath( "hive", "male", { } )
        local harvyModel = GetCustomizableModelPath( "harvester", "male", { } )
        local eggModel = GetCustomizableModelPath( "egg", "male", { } )

        if hiveModel and not table.icontains(cachedList, hiveModel) then
            PrecacheAsset( hiveModel )
            table.insert(cachedList, hiveModel)
        end

        if harvyModel and not table.icontains(cachedList, harvyModel) then
            PrecacheAsset( harvyModel )
            table.insert(cachedList, harvyModel)
        end

        if eggModel and not table.icontains(cachedList, eggModel) then
            PrecacheAsset( eggModel )
            table.insert(cachedList, eggModel)
        end
    end

    for i = 1, #kAlienTunnelVariants do
        local model = GetCustomizableModelPath( "tunnel", "male", { alienTunnelsVariant = i } )
        if model and not table.icontains(cachedList, model) then
            PrecacheAsset( model )
            table.insert(cachedList, model)
        end
    end

    for i = 1, #kGorgeVariant do
        local model = GetCustomizableModelPath( "gorge", "male", { gorgeVariant = i } )
        local clogModel = GetCustomizableModelPath( "clog", "male", { gorgeVariant = i } )
        local babblerModel = GetCustomizableModelPath( "babbler", "male", { gorgeVariant = i } )
        local babblerEggModel = GetCustomizableModelPath( "babbler_egg", "male", { gorgeVariant = i } )
        local hydraModel = GetCustomizableModelPath( "hydra", "male", { gorgeVariant = i } )

        if model and not table.icontains(cachedList, model) then
            PrecacheAsset( model )
            table.insert(cachedList, model)
        end

        if clogModel and not table.icontains(cachedList, clogModel) then
            PrecacheAsset( clogModel )
            table.insert(cachedList, clogModel)
        end

        if babblerModel and not table.icontains(cachedList, babblerModel) then
            PrecacheAsset( babblerModel )
            table.insert(cachedList, babblerModel)
        end

        if hydraModel and not table.icontains(cachedList, hydraModel) then
            PrecacheAsset( hydraModel )
            table.insert(cachedList, hydraModel)
        end

        if babblerEggModel and not table.icontains(cachedList, babblerEggModel) then
            PrecacheAsset( babblerEggModel )
            table.insert(cachedList, babblerEggModel)
        end
    end

end
PrecacheCustomizeAssets()
