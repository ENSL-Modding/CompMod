-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/PlayerScreen/Customize/CustomizeScene.lua
--
--    Created by:   Brock Gillespie (brock@naturalselection2.com)
--
--    Primary object to manage, update, and adjust sub-objects contained withiin the Customize render scene.
--    This class is primarily utilized for maintaining the "state" of both the Customize Screen render scene
--    and the objects contained in it. It's also acts as an accessor from the GUI in order to either query
--    or update the (sub)states of the objects and the scene views.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

--[[
TODO

- Need ref table for all customizable objects
- Need init routine to create said objects

NICE-TO-HAVES
- Need Customizable Model -> Camera point linking
-- Using above, grants means to have OnFocus / OnBlur like behavior/actions (e.g. Marine turns to face camera when viewing it)

--]]

--[[
Idle Animations
    EXO
    - Will need to be able to "offset" model Yaw with changes to body_yaw (e.g. Exo)
    -- If above can be done, then being able to do "counter-offset"  (i.e. opposite direction) could allow for pseudo Marine head movement

    MARINE
    - Should use body_pitch to make them look up from time to time, as idle state. When camera is on Armor view, should
      change body_pitch to "neutral" (looking forward, laterally).

    LERK
    - When focusing the Lerk, it should hop up ad hover-flap. When camera moves away from it, after a tiny delay, it lands.

    ALL Lifeforms
    - Should randomly (at min + rand) play, at intervals, their "Fidget" animation (if those are still available).

--]]

Script.Load("lua/Utility.lua")
Script.Load("lua/AnimatedModel.lua") --This is included for simple non-graph based models (e.g. Rifle)
Script.Load("lua/GraphDrivenModel.lua")
Script.Load("lua/tweener/Tweener.lua")

Script.Load("lua/menu2/PlayerScreen/Customize/CustomizeSceneCameras.lua")

--Local Constants
local kUpVec = Vector(0,1,0)


---@class CustomizeScene
class "CustomizeScene"

--After init, camera is set to this Coord
CustomizeScene.kDefaultView = gCustomizeSceneData.kViewLabels.DefaultMarineView

CustomizeScene.kBackgroundCinematic = PrecacheAsset("cinematics/menu/customize_scene.cinematic")
CustomizeScene.kRenderTarget = "*customize_screen_cinematic"

CustomizeScene.kCinematicRenderSetup = "renderer/customize.render_setup"

CustomizeScene.kSceneRenderMask = kCustomizeSceneRenderMask
--CustomizeScene.kSceneInverseRenderMask = bit.bnot( kCustomizeSceneRenderMask )

CustomizeScene.kCameraNearPlane = 0.01
CustomizeScene.kCameraFarPlane = 1500

--CustomizeScene.kAspectRatio = 4 / 3
CustomizeScene.kAspectRatio = 16/9

CustomizeScene.kSelectableMaterialStartTime = math.random(0.1, math.random(math.random(0.2,1), math.random(1, 2)))
CustomizeScene.kHighlightMaterialStartTime = math.random(0.1, math.random(math.random(0.5,1), math.random(1.5, 3)))

local gCustomizeScene
function GetCustomizeScene()
    if not gCustomizeScene then
        gCustomizeScene = CustomizeScene()
    end
    return gCustomizeScene
end


function CustomizeScene:Initialize( viewSize )  --TODO Add "downsample" factor
    assert(viewSize and viewSize:GetLength() > 0)
    assert( gCustomizeSceneData and type(gCustomizeSceneData) == "table")

    --RenderCamera for this scene
    self.renderCamera = nil

    --Cinematic Background (as result Level file too)
    self.cinematic = nil

    --The Current Active scene View label (not the destination if a transition is active)
    self.activeViewLabel = gCustomizeSceneData.kDefaultViewLabel  --TODO make this a stored/read option?
    self.previousViewLabel = self.activeViewLabel

    --Simple object to hold the active CameraTransition, not have thing means the Camera is idle
    self.transition = nil

    --"global" to control if the Scene updates or not
    self.isActive = false

    --Intended size of the Render Target (note this can be influenced by GUI scaling, etc)
    self.viewSize = Vector()
    VectorCopy(viewSize, self.viewSize)

    --RenderCamera scalar modifier on its X,Y viewport
    self.viewScaleFactor = 1 --0.5

    --Tracker for the last time CustomizeScene was in Active state and updated
    self.lastUpdateTime = 0

    --Container for expiring sub-routines for this overall update loop
    --Have OnStart(), OnUpdate(), and OnComplete() events with interval rates for Update and timeout value used with startTime
    self.sceneEvents = {}

    self:InitBackground()
    self:InitRenderCamera()

    --Lookup table to hold Key/Value pairs of "special" models. Used to quickly access
    --a particular scene object via its index. Keys for this table are defined in 'specialIndex'
    --value in the gCustomizeSceneData.kSceneObjects table.
    self.specialModelHandles = {}

    --Alias to denote which "chunk" of the scene (Marines or Aliens) scene is setup for right now
    --this is used to skip updating models if they're not in the active view.
    self.activeContentSection = kTeam1Index

    --Simple flag to denote something in the Scene has changed, and update(s) should be run
    self.sceneDirty = false

    --Callback holder for triggering actions to GUI when camera is in "activation range" of the target view-label
    self.viewNearDistanceActiveCallback = nil

    --Flag to denote if Customize scene's debug drawing is enabled
    self.debugVisEnabled = false

    --Lookup table to link Scene Object name to Cosmetic Variant-type of all active variant values (after init and on user-change)
    self.objectsActiveVariantsList = {}

    --Table numerically indexed with all AnimatedModel or GraphDrivenModel objects in the entire customize scene
    self.sceneObjects = {}

    --reference table, numerically indexed, of objects that cosmetic selection applied to
    self.customizableModels = {}

    self:InitSceneObjects()

    --numerically indexed table storing instances of all Cinematics in the customize scene (one-shot cinematics are not included in this)
    self.sceneCinematics = {}

    self:InitSceneCinematics()

    self:RefreshOwnedItems()

    self:InitCustomizableModels()

    --List of special callback "event" functions, which are contextually limited (i.e. don't require update every tick)
    self.eventHandlers = {}

    --Scratch / temporary RenderModel that is only created when a Scene Object is zoomed. Only renders in ViewZone
    self.zoomedModel = nil
    self.zoomedModelCoords = nil

end

function CustomizeScene:InitBackground()
    assert(self.kBackgroundCinematic)

    self.cinematic = Client.CreateCinematic(RenderScene.Zone_Default, true)
    self.cinematic:SetRepeatStyle( Cinematic.Repeat_Endless )
    self.cinematic:SetCinematic( self.kBackgroundCinematic, self.kSceneRenderMask )
    --Required to keep visible as active/visible until RenderCamera is initialized, for fetching its camera

    self.skyBox = Client.CreateCinematic( RenderScene.Zone_SkyBox )
    self.skyBox:SetCinematic( gCustomizeSceneData.kSkyBoxCinematic, self.kSceneRenderMask )
    self.skyBox:SetRepeatStyle( Cinematic.Repeat_Endless )
    local skyboxCoords = Coords.GetLookAt( Vector(0,0,0), Vector(0,0,1), kUpVec )
    self.skyBox:SetCoords( skyboxCoords )

end

function CustomizeScene:InitRenderCamera()
    assert(self.cinematic)

    self.renderCamera = Client.CreateRenderCamera()
    self.renderCamera:SetRenderSetup( self.kCinematicRenderSetup )
    self.renderCamera:SetType( RenderCamera.Type_Perspective )
    self.renderCamera:SetCullingMode( RenderCamera.CullingMode_Frustum )
    self.renderCamera:SetRenderMask( self.kSceneRenderMask )

    self.renderCamera:SetNearPlane( self.kCameraNearPlane )
    self.renderCamera:SetFarPlane( self.kCameraFarPlane )
    
    self.renderCamera:SetTargetTexture( self.kRenderTarget, false, math.floor(self.viewSize.x * self.viewScaleFactor), math.floor(self.viewSize.y * self.viewScaleFactor) )
    self.renderCamera:SetUsesTAA( false )

    local defaultView = gCustomizeSceneData.kDefaultView
    local coords = Coords.GetLookAt( defaultView.origin, defaultView.target, kUpVec )
    local fov = self:GetSizeAdjustedFov( defaultView.fov )

    self.renderCamera:SetFov( fov )
    self.renderCamera:SetCoords( coords )

    --Setting camera visiblity will control if the entire scene is rendered or not
    self.renderCamera:SetIsVisible( self.isActive )

    Client.SetMainCameraExclusionRectEnabled( self.isActive )

end

function CustomizeScene:InitSceneObjects()
    assert(gCustomizeSceneData.kSceneObjects and #gCustomizeSceneData.kSceneObjects > 0)
    
    for i = 1, #gCustomizeSceneData.kSceneObjects do
        local data = gCustomizeSceneData.kSceneObjects[i]
        local newObject = {}

        newObject.name = data.name
        newObject.contentGroup = data.team
        newObject.static = data.isStatic
        newObject.customizable = data.customizable and data.customizable or false

        newObject.lastUpdateTime = 0  --used if we need to stagger or halt updates to a given model (i.e. static objects or animation rates)

        if newObject.customizable then
        --Cache scene object index for easy reference later when changing skins
            table.insert( self.customizableModels, i )
            
            if not self.objectsActiveVariantsList[newObject.name] then
                self.objectsActiveVariantsList[newObject.name] = {}
            end

            self.objectsActiveVariantsList[newObject.name].activeVariantId = nil --set later
            self.objectsActiveVariantsList[newObject.name].ownedActiveVariantId = nil
            self.objectsActiveVariantsList[newObject.name].cosmeticId = (data.cosmeticId ~= nil and data.cosmeticId or nil)
        end

        newObject.highlight = false

        if data.isStatic then
            newObject.model = self:InitAnimatedModel( data )
        else
            newObject.model = self:InitGraphModel( data )
        end

        --Additive material that's indicative of something is selectable/usable
        if newObject.customizable then
            local initStartTime = math.random(math.random(), math.random(1.5, 3))

            if data.team == kTeam1Index then
                newObject.model:AddMaterial( gCustomizeSceneData.kMarineTeamSelectableMaterial )
                newObject.model:SetNamedMaterialParameter("startTime", initStartTime, gCustomizeSceneData.kMarineTeamSelectableMaterial)
            elseif data.team == kTeam2Index then
                newObject.model:AddMaterial( gCustomizeSceneData.kAlienTeamSelectableMaterial )
                newObject.model:SetNamedMaterialParameter("startTime", initStartTime, gCustomizeSceneData.kAlienTeamSelectableMaterial)
            end
        end

        self.sceneObjects[i] = newObject

    end

end

function CustomizeScene:InitAnimatedModel( data, renderZoneOverride, zoomed )
    assert(data and data.modelFile)
    
    local model = AnimatedModel()
    model:OnInitialized( data.modelFile, (renderZoneOverride ~= nil and renderZoneOverride or RenderScene.Zone_Default) )

    local modelAngles = Angles()
    if not zoomed then
        modelAngles.pitch = math.rad(data.defaultPos.angles.x)
        modelAngles.yaw = math.rad(data.defaultPos.angles.y)
        modelAngles.roll = math.rad(data.defaultPos.angles.z)
    elseif zoomed then --TODO set in config-data, or global const
        modelAngles.pitch = 0
        modelAngles.yaw = 0
        modelAngles.roll = 0
    end

    local coords = modelAngles:GetCoords( data.defaultPos.origin )
    if zoomed then
        coords.origin = self.renderCamera:GetCoords():GetInverse():TransformPoint( coords.origin )
    end
    
    model:SetCoords( coords )
    model:InstanceMaterials()
    model:SetRenderMask( self.kSceneRenderMask )
    model:SetIsVisible( true )
    model:SetCastsShadows( true )

    if data.defaultAnim then
        assert(data.defaultAnim ~= "")

        model:SetAnimation( data.defaultAnim )
        model:SetQueuedAnimation( data.defaultAnim )
        model:SetStaticAnimation( ( data.isStatic and data.defaultAnim ) and data.isStatic or false )

        if data.poseParams and not zoomed then
            for p = 1, #data.poseParams do
                local param = data.poseParams[p]
                assert(param.name and param.value)
                model:SetPoseParam(param.name, param.value)
            end
        end

        if zoomed then
            if data.zoomedPoseParams then
                for p = 1, #data.zoomedPoseParams do
                    local param = data.zoomedPoseParams[p]
                    assert(param.name and param.value)
                    model:SetPoseParam(param.name, param.value)
                end
            end
        end
    end

    return model
end

function CustomizeScene:InitGraphModel( data, renderZoneOverride, zoomed )
    assert(data and data.graphFile)

    local model = GraphDrivenModel()

    model:Initialize( data.modelFile, data.graphFile, (renderZoneOverride ~= nil and renderZoneOverride or RenderScene.Zone_Default) )

    local modelAngles = Angles()
    if not zoomed then
        modelAngles.pitch = math.rad(data.defaultPos.angles.x)
        modelAngles.yaw = math.rad(data.defaultPos.angles.y)
        modelAngles.roll = math.rad(data.defaultPos.angles.z)
    elseif zoomed then --TODO set in config-data, or global const
        modelAngles.pitch = 0
        modelAngles.yaw = 0
        modelAngles.roll = 0
    end

    local origin = data.defaultPos.origin
    if zoomed then
        origin = self.renderCamera:GetCoords():GetInverse():TransformPoint(origin)
    end

    local coords = modelAngles:GetCoords( origin )

    model:SetCoords( coords )

    model:SetRenderMask( self.kSceneRenderMask )
    model:InstanceMaterials()
    model:SetIsVisible( true )
    model:SetCastsShadows( true )

    if data.poseParams and not zoomed then
        for p = 1, #data.poseParams do
            model:SetPoseParam(data.poseParams[p].name, data.poseParams[p].value)
        end
    end

    if data.inputParams and not zoomed then
        for p = 1, #data.inputParams do
            model:SetAnimationInput(data.inputParams[p].name, data.inputParams[p].value)
        end
    end

    if zoomed then
        if data.zoomedInputParams then
            for p = 1, #data.zoomedInputParams do
                model:SetAnimationInput(data.zoomedInputParams[p].name, data.zoomedInputParams[p].value)
            end
        end

        if data.zoomedPoseParams then
            for p = 1, #data.zoomedPoseParams do
                model:SetPoseParam(data.zoomedPoseParams[p].name, data.zoomedPoseParams[p].value)
            end
        end
    end

    return model
end

function CustomizeScene:InitSceneCinematics()
    assert(gCustomizeSceneData.kSceneCinematics and #gCustomizeSceneData.kSceneCinematics > 0)

    for c = 1, #gCustomizeSceneData.kSceneCinematics do

        local data = gCustomizeSceneData.kSceneCinematics[c]

        self.sceneCinematics[c] = {}

        self.sceneCinematics[c].cinematic = Client.CreateCinematic( RenderScene.Zone_Default )
        self.sceneCinematics[c].cinematic:SetCinematic( data.fileName, self.kSceneRenderMask )
        self.sceneCinematics[c].cinematic:SetRepeatStyle( data.playbackType )
        self.sceneCinematics[c].cinematic:SetCoords( data.coords )

        if data.initVisible ~= nil then
        --Optionally hide cinematic per definition, but default to visible
            self.sceneCinematics[c].cinematic:SetIsVisible(data.initVisible ~= nil and data.initVisible or true)
        end

        --Special cases
        if data.fileName == gCustomizeSceneData.kHiveWisps_Toxin then
            self.toxinHiveWispsIndex = c
        elseif data.fileName == gCustomizeSceneData.kHiveWisps then
            self.normalHiveWispsIndex = c
        end
    end

    --Extra One-Shot cinematics (i.e. playback controled via code, not cinematic loop itself)
    self.macFlyby = nil
    self.minMacPlayTime = gCustomizeSceneData.kMacFlybyMinInterval
    self.lastMacPlayTime = 0
    self.macPlayTimeInterval = gCustomizeSceneData.kMacFlybyMinInterval
end


function CustomizeScene:GetSizeAdjustedFov( horzFov )
    local actualAspect = self.viewSize.x / self.viewSize.y
    local verticalFov = 2.0 * math.atan( math.tan( horzFov * 0.5) / self.kAspectRatio )
    horzFov = 2.0 * math.atan( math.tan( verticalFov * 0.5) * actualAspect )
    return math.abs(horzFov)
end

function CustomizeScene:SetCameraPerspective( coords, fov )
    if not self.debugVisEnabled then
        self.renderCamera:SetCoords(coords)
        self.renderCamera:SetFov(fov)
    end
end

function CustomizeScene:TransitionToView( targetView, isTeamChange )

    --function CameraTransition:Init( targetView, fromView, curOrg, curTarget, curFov, isTeamViewChange )
    if self.transition then
    --existing transition running, use it's data to feed new one

        local iCoords = self.transition:GetCoords()
        local iFov = self.transition:GetFov()
        local iT = self.transition:GetTargetData()

        self.transition = nil
        self.transition = CameraTransition()
        self.transition:Init( targetView, nil, iCoords.origin, iT.target, iFov, isTeamChange )

    else
    --New transition from camera at rest
        self.transition = CameraTransition()
        self.transition:Init( targetView, self.activeViewLabel, nil, nil, isTeamChange )
    end

    self.transition:SetDistanceActivationCallback( self.DistanceActivationResult )

    self.previousViewLabel = self.activeViewLabel

    --FIXME Not always toggling (inconsistent)
    for i = 1, #self.customizableModels do

        local scenObjIdx = self.customizableModels[i]
        local sceneObject = self.sceneObjects[scenObjIdx]

        if GetIsDefaultView( targetView ) and not GetIsDefaultView(self.previousViewLabel) then
        --Always toggle on the selectable material, when returning to a default view
            
            local selectableMaterial = GetObjectSelectableMaterial( sceneObject.contentGroup )
            local selectableStartTime = math.random(0.1, math.random(math.random(0.5,1), math.random(1.5, 3)))

            sceneObject.model:AddMaterial( GetObjectSelectableMaterial( sceneObject.contentGroup ) )
            sceneObject.model:SetNamedMaterialParameter("startTime", selectableStartTime, selectableMaterial)

        elseif not GetIsDefaultView( targetView ) then
        --Always toggle off the selectable material, as it can appear in the background of some views
            sceneObject.model:RemoveMaterial( GetObjectSelectableMaterial( sceneObject.contentGroup ) )
        end
    end

    --TODO Add MarineRotateFromCam (back to scene data value)
    --[[
    local RotateMarineFromCam = function()

    end
    local event = self:BuildEventHandler(
        "MarineRotateFromCam", 0.01, 0, nil, RotateMarineFromCam, nil
    )
    --]]

end

local objectsPerViewList = 
{
    [gCustomizeSceneData.kViewLabels.Armory] = { "Rifle", "Axe", "Pistol", "Welder", "Shotgun", "GrenadeLauncher", "Flamethrower", "HeavyMachineGun" },
    [gCustomizeSceneData.kViewLabels.Marines] = { "MarineLeft", "MarineCenter", "MarineRight" },
    [gCustomizeSceneData.kViewLabels.ExoBay] = { "ExoMiniguns", "ExoRailguns" },
    [gCustomizeSceneData.kViewLabels.MarineStructures] = { "CommandStation", "Extractor" },

    [gCustomizeSceneData.kViewLabels.AlienLifeforms] = { "Skulk", "Gorge", "Lerk", "Fade", "Onos", "Babbler", "Hydra", "Clog", "BabblerEgg" },
    [gCustomizeSceneData.kViewLabels.AlienStructures] = { "Hive", "Harvester", "Egg" },
    [gCustomizeSceneData.kViewLabels.AlienTunnels] = { "Tunnel" },
}

--Helper function to manage toggling highlight material on/off for all customizable models of a given camera view
function CustomizeScene:ToggleViewHighlight( viewLabel )
    assert(viewLabel and objectsPerViewList[viewLabel])

    local objectsNames = objectsPerViewList[viewLabel]

    for i = 1, #self.customizableModels do
        local scenObjIdx = self.customizableModels[i]

        if table.icontains( objectsNames, self.sceneObjects[scenObjIdx].name ) then

            local sceneobjectData = GetSceneObjectInitData( self.sceneObjects[scenObjIdx].name )
            
            if self.sceneObjects[scenObjIdx].highlight then
                self.sceneObjects[scenObjIdx].model:RemoveMaterial( GetObjectHighlightMaterial( self.sceneObjects[scenObjIdx].contentGroup ) )
                self.sceneObjects[scenObjIdx].highlight = false
            else
                self.sceneObjects[scenObjIdx].model:AddMaterial( GetObjectHighlightMaterial( self.sceneObjects[scenObjIdx].contentGroup ) )
                self.sceneObjects[scenObjIdx].highlight = true
            end
        end
    end
end

function CustomizeScene:DistanceActivationResult( viewLabelActivation )

    --[[
    --TODO
     - Need a View -> Callback(s) table, kick-off handler. BUT, needs to have self, and the scene in scope when run
     - This is for triggering things like models rotating towards camera, updating pose-params via timer, etc, etc
    --]]

    --[[
    if viewLabelActivation == gCustomizeSceneData.kViewLabels.Marines then
        --TODO Rotate (lerp) "main" Marine model towards camera and zero out pose/inputs

        local RotateMarineToCam = function(time, deltaTime)
            local cScne = GetCustomizeScene()
            local obj, idx = cScne:GetSceneObject( "MarineRight" )
            assert(obj, idx)
            local marine = cScne.sceneObjects[idx]


        end

        local event = self:BuildEventHandler( 
            "MarineRotateToCam",
            0.01, 0, nil, RotateMarineToCam, nil, 0, 
            { 
                targetAngle = Vector( 0, -90, 0 ), 
                targetPoseParams = 
                { 
                    { name = "body_pitch", value = 0 },
                    { name = "body_yaw", value = 0 }, 
                } 
            }
        )

        self:AddSceneEvent( event )
    end
    --]]

    GetCustomizeScreen():OnViewLabelActivation( viewLabelActivation )
end

--TODO Add tweening and other timed animation elements (model rotating to camera, etc)


local sceneObjectNamesList = 
{
    ["CommandStation"] = "command_station",
    ["Extractor"] = "extractor",
    ["MarineLeft"] = "marine",
    ["MarineCenter"] = "marine",
    ["MarineRight"] = "marine",
    ["ExoMiniguns"] = "exo_mm",
    ["ExoRailguns"] = "exo_rr",
    ["Rifle"] = "rifle",
    ["Axe"] = "axe",
    ["Welder"] = "welder",
    ["Pistol"] = "pistol",
    ["Shotgun"] = "shotgun",
    ["GrenadeLauncher"] = "grenadelauncher",
    ["Flamethrower"] = "flamethrower",
    ["HeavyMachineGun"] = "hmg",

    ["Skulk"] = "skulk",
    ["Gorge"] = "gorge",
    ["Lerk"] = "lerk",
    ["Fade"] = "fade",
    ["Onos"] = "onos",
    ["Hive"] = "hive",
    ["Harvester"] = "harvester",
    ["Egg"] = "egg",
    ["Hydra"] = "hydra",
    ["Clog"] = "clog",
    ["Babbler"] = "babbler",
    ["BabblerEgg"] = "babbler_egg",
    ["Tunnel"] = "tunnel",
}
local function GetCosmeticType( sceneObjName, sex )
    assert(sceneObjName)
    return sceneObjectNamesList[sceneObjName] and sceneObjectNamesList[sceneObjName] or false
end

local sceneObjectVariantOptionsKeys =
{
    ["CommandStation"] = "marineStructuresVariant",
    ["Extractor"] = "marineStructuresVariant",
    ["MarineLeft"] = "marineVariant",
    ["MarineCenter"] = "marineVariant",
    ["MarineRight"] = "marineVariant",
    ["ExoMiniguns"] = "exoVariant",
    ["ExoRailguns"] = "exoVariant",
    ["Rifle"] = "rifleVariant",
    ["Axe"] = "axeVariant",
    ["Welder"] = "welderVariant",
    ["Pistol"] = "pistolVariant",
    ["Shotgun"] = "shotgunVariant",
    ["GrenadeLauncher"] = "grenadeLauncherVariant",
    ["Flamethrower"] = "flamethrowerVariant",
    ["HeavyMachineGun"] = "hmgVariant",

    ["Skulk"] = "skulkVariant",
    ["Gorge"] = "gorgeVariant",
    ["Lerk"] = "lerkVariant",
    ["Fade"] = "fadeVariant",
    ["Onos"] = "onosVariant",
    ["Hive"] = "alienStructuresVariant",
    ["Harvester"] = "alienStructuresVariant",
    ["Egg"] = "alienStructuresVariant",
    ["Hydra"] = "gorgeVariant",
    ["Clog"] = "gorgeVariant",
    ["Babbler"] = "gorgeVariant",
    ["BabblerEgg"] = "gorgeVariant",
    ["Tunnel"] = "alienTunnelsVariant",
}
local function GetVariantKey( sceneName )
    assert(sceneName)
    return sceneObjectVariantOptionsKeys[sceneName] and sceneObjectVariantOptionsKeys[sceneName] or false
end

local textureIndexBasedObjects = 
{
    "CommandStation", "Extractor", "ExoMiniguns", "ExoRailguns",
    "Rifle", "Axe", "Hive", "Tunnel", "Egg", "Harvester", "GrenadeLauncher",
    "Babbler", "BabblerEgg", "Hydra", "Clog"
}


local gorgeToysNames = { "Clog", "Hydra", "Babbler", "BabblerEgg" }

function CustomizeScene:GetSceneObject( objectName, index )
    assert(objectName or index)

    if objectName then
        for i = 1, #self.sceneObjects do
            local so = self.sceneObjects[i]
            if objectName == so.name then
                object = so
                sceneIndex = i
                return so, i
            end
        end
    else
        if self.sceneObjects[index] then
            return self.sceneObjects[index], index
        end
    end

    return nil, false
end

function CustomizeScene:GetActiveShoulderPatchIndex()
    return self.ownedPadActiveIndex
end

--dumb list of scene objects to apply updated variant data to
local variantSelectObjectsChangelist =  --?? Move to scene data file?
{
    [gCustomizeSceneData.kSceneObjectReferences.Marine] = { "MarineRight", "MarineLeft" },
    [gCustomizeSceneData.kSceneObjectReferences.CommandStation] = { "CommandStation", "Extractor" },
    [gCustomizeSceneData.kSceneObjectReferences.Extractor] = { "CommandStation", "Extractor" },
    [gCustomizeSceneData.kSceneObjectReferences.Exo] = { "ExoMiniguns", "ExoRailguns" },
    [gCustomizeSceneData.kSceneObjectReferences.Rifle] = { "Rifle" },
    [gCustomizeSceneData.kSceneObjectReferences.Axe] = { "Axe" },
    [gCustomizeSceneData.kSceneObjectReferences.Pistol] = { "Pistol" },
    [gCustomizeSceneData.kSceneObjectReferences.Welder] = { "Welder" },
    [gCustomizeSceneData.kSceneObjectReferences.Shotgun] = { "Shotgun" },
    [gCustomizeSceneData.kSceneObjectReferences.Flamethrower] = { "Flamethrower" },
    [gCustomizeSceneData.kSceneObjectReferences.GrenadeLauncher] = { "GrenadeLauncher" },
    [gCustomizeSceneData.kSceneObjectReferences.HeavyMachineGun] = { "HeavyMachineGun" },

    [gCustomizeSceneData.kSceneObjectReferences.Hive] = { "Hive", "Harvester", "Egg" },
    [gCustomizeSceneData.kSceneObjectReferences.Harvester] = { "Hive", "Harvester", "Egg" },
    [gCustomizeSceneData.kSceneObjectReferences.Egg] = { "Hive", "Harvester", "Egg" },

    [gCustomizeSceneData.kSceneObjectReferences.Tunnel] = { "Tunnel" },
    
    [gCustomizeSceneData.kSceneObjectReferences.Skulk] = { "Skulk" },
    [gCustomizeSceneData.kSceneObjectReferences.Gorge] = { "Gorge", "Hydra", "BabblerEgg", "Babbler", "Clog" },
    [gCustomizeSceneData.kSceneObjectReferences.Lerk] = { "Lerk" },
    [gCustomizeSceneData.kSceneObjectReferences.Fade] = { "Fade" },
    [gCustomizeSceneData.kSceneObjectReferences.Onos] = { "Onos" },
}

function CustomizeScene:GetOwnedShoulderPadIndexByPatchId( patchId )
    assert(patchId)

    if patchId == 0 then
        return 1
    end

    --TODO update, below not jittable
    for k,v in pairs(self.ownedCosmeticItems["shoudlerPatches"]) do
        if patchId == v then
            return k
        end
    end

    return false
end

local marinesList = { "MarineLeft", "MarineCenter", "MarineRight" }

function CustomizeScene:InitCustomizableModels()
    
    local options = GetAndSetVariantOptions()
    local marineRightIndex = -1

    for i = 1, #self.customizableModels do 

        local scenObjIdx = self.customizableModels[i]
        local sceneObject = self.sceneObjects[scenObjIdx]
        local sceneObjectData = GetSceneObjectInitData(sceneObject.name)

        if sceneObject.model then
            
            local sexType = string.lower(options.sexType)
            if sceneObject.name == "MarineCenter" then
                sexType = sexType == "male" and "female" or "male" --opposite of player selection
            end

            if sceneObject.name == "MarineRight" then
                marineRightIndex = scenObjIdx
            end

            local cosmeticType = GetCosmeticType( sceneObject.name, sexType )
            local variantKey = GetVariantKey( sceneObject.name )
            local newModelFile
            
            if sceneObjectData.staticVariant then
                local tempOptions = {}
                table.copy(options, tempOptions)
                tempOptions[variantKey] = sceneObjectData.staticVariant
                newModelFile = GetCustomizableModelPath( cosmeticType, sexType, tempOptions )
            else
                newModelFile = GetCustomizableModelPath( cosmeticType, sexType, options )
            end

            if newModelFile and sceneObjectData then
                if newModelFile ~= sceneObjectData.modelFile and newModelFile ~= nil then
                    
                    self.sceneObjects[scenObjIdx].model:Destroy()  --This is not ideal...
                    self.sceneObjects[scenObjIdx].model = nil

                    local tData = sceneObjectData
                    tData.modelFile = newModelFile
                    if sceneObjectData.isStatic then
                        self.sceneObjects[scenObjIdx].model = self:InitAnimatedModel( tData )
                    else
                        self.sceneObjects[scenObjIdx].model = self:InitGraphModel( tData )
                    end

                    --Additive material that's indicative of something is selectable/usable
                    if sceneObjectData.customizable then
                        local initStartTime = math.random(math.random(), math.random(2, 4))

                        if sceneObjectData.team == kTeam1Index then
                            self.sceneObjects[scenObjIdx].model:AddMaterial( gCustomizeSceneData.kMarineTeamSelectableMaterial )
                            self.sceneObjects[scenObjIdx].model:SetNamedMaterialParameter("startTime", initStartTime, gCustomizeSceneData.kMarineTeamSelectableMaterial )
                        elseif sceneObjectData.team == kTeam2Index then
                            self.sceneObjects[scenObjIdx].model:AddMaterial( gCustomizeSceneData.kAlienTeamSelectableMaterial )
                            self.sceneObjects[scenObjIdx].model:SetNamedMaterialParameter("startTime", initStartTime, gCustomizeSceneData.kAlienTeamSelectableMaterial )
                        end
                    end

                end
            end

            self.objectsActiveVariantsList[sceneObject.name].activeVariantId = options[variantKey]

            if sceneObjectData.cosmeticId then
            --Only objects with a cosmeticId trigger changes, so safe to skip others (like Babbler)
                local variants = gCustomizeSceneData.kSceneObjectVariantsMap[sceneObjectData.cosmeticId]
                self.objectsActiveVariantsList[sceneObject.name].ownedActiveVariantId = GetOwnedVariantIndexByVariantId( self.ownedCosmeticItems[variantKey], options[variantKey], variants )
            end

            if variantKey and table.icontains(textureIndexBasedObjects, sceneObject.name) then
            --All stored values are offset by 1 from shader parameters
                local variantIndex = 0
                if sceneObject.name == "Tunnel" then
                    variantIndex = options[variantKey] > 2 and options[variantKey] - 2 or options[variantKey] - 1
                elseif table.icontains(gorgeToysNames, sceneObject.name) then
                    variantIndex = GetGorgeToysTextureIndex( options.gorgeVariant )
                else
                    variantIndex = options[variantKey] - 1
                end

                self.sceneObjects[scenObjIdx].model:SetMaterialParameter("textureIndex", variantIndex)
            end

            --Shoulder Patch
            if table.icontains(marinesList, sceneObject.name) then
                if sceneObject.name == "MarineLeft" then
                    self.marineLeftObjectIndex = scenObjIdx
                elseif sceneObject.name == "MarineCenter" then
                    self.marineCenterObjectIndex = scenObjIdx
                elseif sceneObject.name == "MarineRight" then
                    self.marineRightObjectIndex = scenObjIdx
                end

                self.sceneObjects[scenObjIdx].model:SetMaterialParameter("patchIndex", options.shoulderPadIndex - 2)
            end
        end
    end

    if marineRightIndex > -1 then
        self.ownedPadActiveIndex = self:GetOwnedShoulderPadIndexByPatchId( options.shoulderPadIndex )
    end

end

--TODO Add means to set variant value for all items that "share" a common id...in other words, Sets/Collections (e.g. Default, Forge, Nocturne, etc, etc)

function CustomizeScene:CyclePatches()
    assert(self.marineRightObjectIndex)
    assert(self.ownedPadActiveIndex)
    assert(self.ownedCosmeticItems["shoudlerPatches"])
    
    local tIdx = ( self.ownedPadActiveIndex + 1 > #self.ownedCosmeticItems["shoudlerPatches"] and 1 or self.ownedPadActiveIndex + 1 )
    local nextPadIdx = self.ownedCosmeticItems["shoudlerPatches"][tIdx]
    
    self.ownedPadActiveIndex = tIdx

    self.sceneObjects[self.marineLeftObjectIndex].model:SetMaterialParameter("patchIndex", nextPadIdx - 2)
    self.sceneObjects[self.marineCenterObjectIndex].model:SetMaterialParameter("patchIndex", nextPadIdx - 2)
    self.sceneObjects[self.marineRightObjectIndex].model:SetMaterialParameter("patchIndex", nextPadIdx - 2)
    
    Client.SetOptionInteger( "shoulderPad", nextPadIdx )
    SendPlayerVariantUpdate()
    
    local padName = kShoulderPadNames[nextPadIdx]
    return padName
end


function CustomizeScene:CycleCosmetic( cosmeticId )
    assert(cosmeticId)

    if not gCustomizeSceneData.kSceneObjectVariantsMap[cosmeticId] then
        Log("Error: invalid variant identifier")
        return false
    end

    local variants = gCustomizeSceneData.kSceneObjectVariantsMap[cosmeticId]
    local nextVariantName
    local nextVariantId
    local ownedVariantIndex
    local variantKey

    if variantSelectObjectsChangelist[cosmeticId] then
        for i = 1, #variantSelectObjectsChangelist[cosmeticId] do

            local sceneObjName = variantSelectObjectsChangelist[cosmeticId][i]

            if not variantKey then
                variantKey = GetVariantKey( sceneObjName )
            end

            if not nextVariantId then
                nextVariantId, ownedVariantIndex = GetNextOwnedVariant( variants, self.ownedCosmeticItems[variantKey], self.objectsActiveVariantsList[sceneObjName].ownedActiveVariantId )
                --TODO Trigger behaviors of "You don't own this, here's the buy button" (via callback to GUI)
            end

            if ownedVariantIndex then
                self.objectsActiveVariantsList[sceneObjName].ownedActiveVariantId = ownedVariantIndex
            end
            
            if not nextVariantName then
                nextVariantName = GetVariantName( GetVariantData( cosmeticId ), nextVariantId )
            end

            local gender = cosmeticId == gCustomizeSceneData.kSceneObjectReferences.Marine and Client.GetOptionString("sexType", "Male") or nil
            local cosmeticType = GetCosmeticType( sceneObjName, gender )

            local variantsTbl = {}
            variantsTbl[variantKey] = nextVariantId

            local newModelFile = GetCustomizableModelPath( cosmeticType, gender, variantsTbl )
            local sceneObject, objIdx = self:GetSceneObject( sceneObjName, nil )

            if self.sceneObjects[objIdx].model:GetModelFilename() ~= newModelFile and newModelFile ~= nil then
                local sceneObjectData = GetSceneObjectInitData(sceneObjName)

                self.sceneObjects[objIdx].model:Destroy()   --This is not ideal...
                self.sceneObjects[objIdx].model = nil

                local tData = sceneObjectData
                tData.modelFile = newModelFile
                if sceneObjectData.isStatic then
                    self.sceneObjects[objIdx].model = self:InitAnimatedModel( tData )
                else
                    self.sceneObjects[objIdx].model = self:InitGraphModel( tData )
                end
            end

            if variantKey and table.icontains(textureIndexBasedObjects, sceneObjName) then
                local variantIndex = 0
                if sceneObject.name == "Tunnel" then
                    variantIndex = variantsTbl[variantKey] > 2 and variantsTbl[variantKey] - 2 or variantsTbl[variantKey] - 1
                elseif table.icontains(gorgeToysNames, sceneObjName) then
                    variantIndex = GetGorgeToysTextureIndex( variantsTbl.gorgeVariant )
                else
                    variantIndex = variantsTbl[variantKey] - 1
                end

                self.sceneObjects[objIdx].model:SetMaterialParameter("textureIndex", variantIndex)
            end

            self.objectsActiveVariantsList[sceneObjName].activeVariantId = nextVariantId

            if cosmeticId == gCustomizeSceneData.kSceneObjectReferences.Marine then
                local patchIndex = self.ownedCosmeticItems["shoudlerPatches"][self.ownedPadActiveIndex]
                self.sceneObjects[objIdx].model:SetMaterialParameter("patchIndex", patchIndex - 2)
            end
        end

        if variantKey then
            Client.SetOptionInteger(variantKey, nextVariantId)
            SendPlayerVariantUpdate() --FIXME This is a really wasteful network message
        end
    end

    return nextVariantName
end

function CustomizeScene:CycleMarineGenderType()

    local curSex = Client.GetOptionString("sexType", "Male") == "Male" and "Female" or "Male" --toggle
    local cosmeticId = gCustomizeSceneData.kSceneObjectReferences.Marine
    local variants = gCustomizeSceneData.kSceneObjectVariantsMap[cosmeticId]
    local sexTypeLabel

    local modelsList = { "MarineRight", "MarineCenter", "MarineLeft" }
    for i = 1, #modelsList do

        local sceneObjName = modelsList[i]
        local cosmeticType = GetCosmeticType( sceneObjName, curSex )
        local variantKey = GetVariantKey( sceneObjName )
        local variantsTbl = {}
        variantsTbl[variantKey] = (sceneObjName == "MarineRight" or sceneObjName == "MarineLeft") and self.objectsActiveVariantsList[sceneObjName].activeVariantId or kMarineVariant.special
        local newModelFile

        if sceneObjName == "MarineCenter" then --Always the opposite of client selection
            local oppositeCurSex = curSex == "Male" and "Female" or "Male"
            newModelFile = GetCustomizableModelPath( cosmeticType, oppositeCurSex, variantsTbl )
        else
            newModelFile = GetCustomizableModelPath( cosmeticType, curSex, variantsTbl )
        end

        local sceneObject, objIdx = self:GetSceneObject( sceneObjName, nil )
        if self.sceneObjects[objIdx].model:GetModelFilename() ~= newModelFile and newModelFile ~= nil then
            local sceneObjectData = GetSceneObjectInitData(sceneObjName)
            self.sceneObjects[objIdx].model:Destroy()   --This is not ideal...
            self.sceneObjects[objIdx].model = nil

            local tData = sceneObjectData
            tData.modelFile = newModelFile
            self.sceneObjects[objIdx].model = self:InitGraphModel( tData )

            if sceneObjectData.team == kTeam1Index then
                self.sceneObjects[objIdx].model:AddMaterial( gCustomizeSceneData.kMarineTeamSelectableMaterial )
                self.sceneObjects[objIdx].model:SetMaterialParameter("startTime", math.random(math.random(), math.random(2, 5)), true)
            end
        end

        local variantIndex = 0
        if variantKey and table.icontains(textureIndexBasedObjects, sceneObjName) then
            variantIndex = variantsTbl[variantKey] - 1
            self.sceneObjects[objIdx].model:SetMaterialParameter("textureIndex", variantIndex)
        end
        
        local patchIndex = self.ownedCosmeticItems["shoudlerPatches"][self.ownedPadActiveIndex]
        self.sceneObjects[self.marineLeftObjectIndex].model:SetMaterialParameter("patchIndex", patchIndex - 2)
        self.sceneObjects[self.marineCenterObjectIndex].model:SetMaterialParameter("patchIndex", patchIndex - 2)
        self.sceneObjects[self.marineRightObjectIndex].model:SetMaterialParameter("patchIndex", patchIndex - 2)
    end

    Client.SetOptionString("sexType", firstToUpper(curSex))
    sexTypeLabel = firstToUpper(curSex)
    SendPlayerVariantUpdate() --FIXME This is a really wasteful network message

    return sexTypeLabel
end

function CustomizeScene:RefreshOwnedItems()
    self.ownedCosmeticItems = nil
    self.ownedCosmeticItems = {}
    self.ownedCosmeticItems = FetchAllOwnedItems()
end

function CustomizeScene:GetCustomizableObjectVariantName( objectName )
    assert(objectName)
    assert(self.objectsActiveVariantsList[objectName])
    return GetVariantName( GetVariantData( self.objectsActiveVariantsList[objectName].cosmeticId ), self.objectsActiveVariantsList[objectName].activeVariantId )
end

function CustomizeScene:SetZoomedSceneObject( objectName )  --XX Might want to considering hiding ALL models that in view, for the active view
    --Log("CustomizeScene:SetZoomedSceneObject( %s )", objectName)
    assert(objectName)
    assert(self.zoomedModel == nil)

    local obj, idx = self:GetSceneObject(objectName)
    assert(obj, idx)
    local modelFile = self.sceneObjects[idx].model:GetModelFilename()
    local coords = self.sceneObjects[idx].model:GetCoords()
    local data = gCustomizeSceneData.kSceneObjects[idx]

    self.sceneObjects[idx].model:SetIsVisible(false)
    
    local variantKey = GetVariantKey( objectName )
    --TODO Make sure all existing cosmetics are applied (should patch index, etc, etc)

    if data.isStatic then
        self.zoomedModel = self:InitAnimatedModel( data, RenderScene.Zone_ViewModel, true )
    else
        self.zoomedModel = self:InitGraphModel( data, RenderScene.Zone_ViewModel, true )
    end

    --FIXME This causes model origin to shift...as if it wasn't even worse already...
    -- Note: This is REALLY needed (most likely), as the VS model is ratehr smaller otherwise

    local vmCoords = self.zoomedModel:GetCoords()
    --[[
    vmCoords.xAxis = vmCoords.xAxis * 1.75
    vmCoords.yAxis = vmCoords.yAxis * 1.75
    vmCoords.zAxis = vmCoords.zAxis * 1.75
    self.zoomedModel:SetCoords(vmCoords)
    --]]

    --cached for later modification/tracking (duplicate of data.defaultPos override on purpose.)
    self.zoomedModelCoords = vmCoords

end

--?? Transitions / position tweening? Smooth pposition changes? If not, models will just "snap" to default positions (little janky)

function CustomizeScene:RemoveZoomdSceneObject( objectName )
    --Log("CustomizeScene:RemoveZoomdSceneObject( %s )", objectName)
    assert(objectName)
    assert(self.zoomedModel)

    self.zoomedModel:Destroy()
    self.zoomedModel = nil
    self.zoomedModelCoords = nil

    local obj, idx = self:GetSceneObject(objectName)
    assert(obj, idx)

    self.sceneObjects[idx].model:SetIsVisible(true)
end

function CustomizeScene:TriggerMacFlyBy()
    self.macFlyby = Client.CreateCinematic( RenderScene.Zone_Default )
    self.macFlyby:SetCinematic( gCustomizeSceneData.kMacFlyby, self.kSceneRenderMask )
    self.macFlyby:SetRepeatStyle( Cinematic.Repeat_None )
    local macFlyCoords = Coords.GetLookAt( Vector(0,0,0), Vector(0,0,1), kUpVec )
    self.macFlyby:SetCoords( macFlyCoords )
end

function CustomizeScene:UpdateSceneExtras( time, deltaTime )

    local isMarineView = GetViewTeamIndex(self.activeViewLabel) == kTeam1Index
    if isMarineView then
        
        local triggerMacFlyby = 
            ( time >= self.minMacPlayTime and self.lastMacPlayTime == 0 ) --first time
            or
            ( self.lastMacPlayTime + self.macPlayTimeInterval < time )

        if triggerMacFlyby then
            self:TriggerMacFlyBy()
            local nextRandTime = (math.random() * gCustomizeSceneData.kMacFlybyMinInterval) + gCustomizeSceneData.kMacFlybyMinInterval * 0.5 + self.minMacPlayTime
            self.macPlayTimeInterval = gCustomizeSceneData.kMacFlybyMinInterval + math.floor(nextRandTime) + self.minMacPlayTime
            self.lastMacPlayTime = time
        end
    end

    if self.objectsActiveVariantsList["Hive"].activeVariantId == kAlienStructureVariants.Toxin and not self.sceneCinematics[self.toxinHiveWispsIndex].cinematic:GetIsVisible() then
        self.sceneCinematics[self.toxinHiveWispsIndex].cinematic:SetIsVisible(true)
        self.sceneCinematics[self.normalHiveWispsIndex].cinematic:SetIsVisible(false)
    elseif not self.sceneCinematics[self.normalHiveWispsIndex].cinematic:GetIsVisible() then
    --reverse above
        self.sceneCinematics[self.toxinHiveWispsIndex].cinematic:SetIsVisible(false)
        self.sceneCinematics[self.normalHiveWispsIndex].cinematic:SetIsVisible(true)
    end

end

--Simple utility/ease function to generate the correct table structure and fields for self.eventHandlers processing
function CustomizeScene:BuildEventHandler( name, interval, timeLimit, onStartFunc, onUpdateFunc, onFinalFunc, updateDelay, data )
    assert(name)
    assert(timeLimit)

    if not interval and onUpdateFunc then
        Log("Error: cannot create CustomizeScene Event handler without interval value")
        return false
    end

    local event = --?? change to class instead? benefits?
    {
        lastUpdate = 0,
        startedTime = 0,
        --polling flag? Indicates it never expires unless of explicit removal? ...eh (BUT...that would be ideal for idle "animations")
        interval = interval ~= nil and interval or false,
        timeLimit = timeLimit ~= nil and timeLimit or false,
        startDelay = updateDelay ~= nil and updateDelay or false,
        OnStart = onUpdateFunc and onUpdateFunc or nil,
        OnUpdate = onStartFunc and onStartFunc or nil,
        OnFinalize = onFinalFunc and onFinalFunc or nil,
        data = data ~= nil and data or false
    }

    return event
end

local function HasEvent(handlers, event)
    for i = 1, #handlers do
        if handlers[i].name == event.name then
            return true
        end
    end
    return false
end

function CustomizeScene:AddSceneEvent( eventDef )
    assert( eventDef and type(eventDef) == "table" )
    assert( eventDef.OnStart or eventDef.OnUpdate or eventDef.OnFinalize ) --must have at least one

    if not HasEvent(self.eventHandlers, eventDef) then
        table.insert(self.eventHandlers, eventDef)

        if eventDef.OnStart and eventDef.startDelay == nil then
            eventDef:OnStart()
            self.eventHandlers[#self.eventHandlers].startedTime = Shared.GetTime()
        end
    else
        Log("Error: Cannot add duplicate CustomizeScene Events[%s]!", eventDef.name)
    end
end

function CustomizeScene:UpdateEventHandlers( time, deltaTime )

    if #self.eventHandlers > 0 then
        for e = 1, #self.eventHandlers do
            
            if self.eventHandlers[e].startedTime + self.eventHandlers[e].timeLimit >= time then
                if self.eventHandlers[e].OnFinalize then
                    self.eventHandlers[e]:OnFinalize()
                end
                table.remove(self.eventHandlers, e) --safe to do IN loop?
            end

            --TODO deal with startedTime and startDelay
            --if self.eventHandlers[e].startedTime == 0 

            if self.eventHandlers[e].OnUpdate then
                if self.eventHandlers[e].lastUpdate + self.eventHandlers[e].interval >= time then
                    self.eventHandlers[e].OnUpdate( time, deltaTime )
                end
            end

            self.eventHandlers[e].lastUpdate = time
        end
    end

end

function CustomizeScene:OnUpdate(time, deltaTime)

    if not self.isActive then
        return
    end

    if self.debugVisEnabled then
        self:UpdateDebugCamera(time, deltaTime)
    end

    self.lastUpdateTime = time

    self:UpdateSceneExtras( time, deltaTime )

    for m = 1, #self.sceneObjects do
        self.sceneObjects[m].model:Update(deltaTime)
    end

    self:UpdateEventHandlers(time, deltaTime)

    if self.transition then
        if self.transition:Update(deltaTime, self) then
            self.previousViewLabel = self.activeViewLabel
            self.activeViewLabel = self.transition:GetTargetView()
            self.transition = nil  --finished
        end
    end

end

function CustomizeScene:Resize( newSize ) --OnResChange?
    assert(newSize and newSize:GetLength() > 0) --len likely not valid
    Log("CustomizeScene:Resize( [%s, %s] )", newSize.x, newSize.y)
end

function CustomizeScene:SetViewLabelGUICallback( callback )
    self.viewNearDistanceActiveCallback = callback
end

function CustomizeScene:SetActive( active )
    self.isActive = active

    self.renderCamera:SetIsVisible( self.isActive )

    Client.SetMainCameraExclusionRectEnabled( self.isActive )

    for m = 1, #self.sceneObjects do
        if self.sceneObjects[m].contentGroup == self.activeContentSection then
        --Skip updating all models not in the current active view (minor perf saving)
            self.sceneObjects[m].model:SetIsVisible( self.isActive ) --actually helps?
        end
    end
end

function CustomizeScene:GetActive()
    return self.isActive
end

function CustomizeScene:SetSceneView( viewLabel )
    assert(viewLabel)

    local viewData = gCustomizeSceneData.kCameraViewPositions[viewLabel]

    if viewData and type(viewData) == "table" then
        local coords = Coords.GetLookAt( viewData.origin, viewData.target, kUpVec )
        local fov = self:GetSizeAdjustedFov( viewData.fov )
        self.renderCamera:SetFov( fov )
        self.renderCamera:SetCoords( coords )
    else
        Log("Error: unrecognized view label[%d]", viewLabel)
    end

end

function CustomizeScene:ClearTransitions( targetViewLabel )
    self.transition = nil
    self:SetSceneView(targetViewLabel)
end

local gDebugCamModel = nil
function CustomizeScene:UpdateDebugCamera(time, deltaTime)

    if gDebugCamModel == nil then
        gDebugCamModel = AnimatedModel()
        gDebugCamModel:OnInitialized( camModel, RenderScene.Zone_Default )
        gDebugCamModel:SetRenderMask( self.kSceneRenderMask )
        gDebugCamModel:InstanceMaterials()
        gDebugCamModel:SetIsVisible( true )
        gDebugCamModel:SetCastsShadows(false)
        gDebugCamModel:SetStaticAnimation(true)
    end

    local camCoords

    if self.transition then
        camCoords = self.transition:GetCoords() 
        --TODO spawn orig/target objects for current transition (cinematics?)  ..can't use DebugDrawXYZ, due to no render mask support
    else
        local activeCamData = gCustomizeSceneData.kCameraViewPositions[self.activeViewLabel]
        camCoords = Coords.GetLookAt( activeCamData.origin, activeCamData.target, kUpVec )
    end

    gDebugCamModel:SetCoords( camCoords )

    local isMarineView = GetViewTeamIndex(self.activeViewLabel) == kTeam1Index
    self.renderCamera:SetCoords( isMarineView and debugCamCoords_Team1 or debugCamCoords_Team2 )
    self.renderCamera:SetFov( isMarineView and debugCameraFov_Team1 or debugCameraFov_Team2 )

end

function CustomizeScene:ToggleDebugView()
    self.debugVisEnabled = not self.debugVisEnabled
    Log("CustomizeScene Debug %s", self.debugVisEnabled and "Enabled" or "Disabled")

    if self.debugVisEnabled then
    --Save
        self._cacheCamCoords = self.renderCamera:GetCoords()
        self._cacheCamFov = self.renderCamera:GetFov()
        self._cacheActiveView = self.activeViewLabel

    elseif self._cacheCamCoords ~= nil and self._cacheCamFov ~= nil then 
    --Restore
        self.renderCamera:SetCoords( self._cacheCamCoords )
        self.renderCamera:SetFov( self._cacheCamFov )
        self.activeViewLabel = self._cacheActiveView
        
        gDebugCamModel:SetIsVisible( false )

        self._cacheCamCoords = nil
        self._cacheCamFov = nil
        self._cacheActiveView = nil
    end
end
Event.Hook("Console_cs_debug", function() GetCustomizeScene():ToggleDebugView() end)


function CustomizeScene:Destroy()
    
    self.transition = nil

    Client.DestroyRenderCamera( self.renderCamera )

    Client.DestroyCinematic( self.cinematic )
    Client.DestroyCinematic( self.skyBox )
    
    if self.macFlyby ~= nil then
        Client.DestroyCinematic(self.macFlyby)
    end

    for m = 1, #self.sceneObjects do
        --TODO Free any swapped materials
        self.sceneObjects[m].model:Destroy()
        self.sceneObjects[m] = nil
    end
    self.sceneObjects = nil

    for c = 1, #self.sceneCinematics do
        Client.DestroyCinematic( self.sceneCinematics[c].cinematic )
        self.sceneCinematics[c] = nil
    end
    self.sceneCinematics = nil
end


--Debug stuff  -- disable before go-live

local function SetSceneView( str )
    local cs = GetCustomizeScene()

    cs.transition = nil --clear active camera control

    if str == "marines" then
        cs:SetSceneView( gCustomizeSceneData.kViewLabels.Marines )
    elseif str == "exobay" then
        cs:SetSceneView( gCustomizeSceneData.kViewLabels.ExoBay )
    elseif str == "armory" then
        cs:SetSceneView( gCustomizeSceneData.kViewLabels.Armory )
    elseif str == "patches" then
        cs:SetSceneView( gCustomizeSceneData.kViewLabels.ShoulderPatches )
    elseif str == "marine_struct" then
        cs:SetSceneView( gCustomizeSceneData.kViewLabels.MarineStructures )

    elseif str == "vent" then
        cs:SetSceneView( gCustomizeSceneData.kViewLabels.TeamTransition )

    elseif str == "aliens" then
        cs:SetSceneView( gCustomizeSceneData.kViewLabels.DefaultAlienView )
    elseif str == "alien_struct" then
        cs:SetSceneView( gCustomizeSceneData.kViewLabels.AlienStructures )
    elseif str == "alien_lifes" then
        cs:SetSceneView( gCustomizeSceneData.kViewLabels.AlienLifeforms )
    elseif str == "alien_tunnel" then
        cs:SetSceneView( gCustomizeSceneData.kViewLabels.AlienTunnels )

    else
        cs:SetSceneView( gCustomizeSceneData.kViewLabels.DefaultMarineView )
    end

end
Event.Hook("Console_cs_setview", SetSceneView)

local function DumpOwnedItemsList()
    local cs = GetCustomizeScene()
    Log(TableToString(cs.ownedCosmeticItems))
end
Event.Hook("Console_cs_dumpitems", DumpOwnedItemsList)
