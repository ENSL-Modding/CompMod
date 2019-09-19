-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/PlayerScreen/Customize/GUIMenuCustomizeScreen.lua
--
--    Created by:   Brock Gillespie (brock@naturalselection2.com)
--
--    Main player cosmetics window for viewing and selecting specific cosmetics. This also 
--    sets up and manages a separate RenderCamera and bound-texture render target. In addition,
--    this is also the initiator and orchestrator for a pseudo RenderScene managed by the
--    CustomizeScene object.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================


Script.Load("lua/GUI/GUIUtils.lua")

Script.Load("lua/GUI/GUIText.lua")
Script.Load("lua/GUI/layouts/GUIListLayout.lua")

Script.Load("lua/menu2/MenuStyles.lua")

Script.Load("lua/menu2/GUIMenuScreen.lua")
Script.Load("lua/menu2/GUIMenuBasicBox.lua")

Script.Load("lua/menu2/widgets/GUIMenuSimpleTextButton.lua")

Script.Load("lua/menu2/widgets/GUIMenuCustomizeTabButton.lua")
Script.Load("lua/menu2/widgets/GUIMenuTabbedListButtonsWidget.lua")

Script.Load("lua/menu2/PlayerScreen/Customize/GUIMenuCustomizeWorldButton.lua")

--Render Scene management and data
Script.Load("lua/NS2Utility.lua") --required for variant stuff
Script.Load("lua/menu2/PlayerScreen/Customize/CustomizeSceneData.lua")
Script.Load("lua/menu2/PlayerScreen/Customize/CustomizeScene.lua")



local kScreenWidth = 1280
local kScreenHeight = 720
local kScreenBottomDistance = 0   --FIXME Must be scaled/etc

local kDisplayPositionX = 0
local kDisplayPositionY = 240   --FIXME Must be scaled/etc

local kInnerBgSideSpacing = 6
local kInnerBgTopSpacing = 6
local kInnerBgBottomSpacing = 6
local kInnerBgBorderWidth = 1

local kMarinesViewColor = HexToColor("4DB1FF")
local kAliensViewColor = HexToColor("FFCA3A")

local kCinematicShader = PrecacheAsset("shaders/GUI/menu/opaque.surface_shader")

local kMarineSubMenuHeight = 85
local kMarineSubMenuButtonLabelFont = ReadOnly{family = "Microgramma", size = 22}
local kMarineSubMenuButtonLabelLrgFont = ReadOnly{family = "Microgramma", size = 27}
local kMarineSubMenuButtonFont = ReadOnly{family = "MicrogrammaBold", size = 22}
local kMarineSubMenuButtonLrgFont = ReadOnly{family = "MicrogrammaBold", size = 27}

local kAlienSubMenuHeight = 85
local kAlienSubMenuButtonLabelFont = ReadOnly{family = "Agency", size = 38}
local kAlienSubMenuButtonFont = ReadOnly{family = "AgencyBold", size = 38}

local kMarineSubMenuWeaponLabelFont = ReadOnly{family = "Microgramma", size = 24}

local kViewInstructionsFont = ReadOnly{family = "Agency", size = 46}

local kMainWorldButtonsLayer = 4
local kItemViewButtonsLayer = 5
local kGlobalBackButtonLayer = 20

local function UpdateInnerBackgroundSize(self, parentSize)
    local mod = Vector(kInnerBgSideSpacing * 2, (kInnerBgBottomSpacing + kInnerBgTopSpacing), 0)
    
    self.background:SetSize(parentSize - mod)

    if self.renderTexture then
        local viewSize = Vector( parentSize.x - (kInnerBgSideSpacing * 2), parentSize.y - (kInnerBgTopSpacing * 2), 0)
        self.renderTexture:SetSize(viewSize)
    end
end


local gCustomizeScreen
function GetCustomizeScreen()
    if gCustomizeScreen then
        return gCustomizeScreen
    end
    error("gCustomizeScreen not set!")
end

---@class GUIMenuCustomizeScreen : GUIMenuScreen
class "GUIMenuCustomizeScreen" (GUIMenuScreen)


function GUIMenuCustomizeScreen:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1

    PushParamChange(params, "screenName", "Customize")
    GUIMenuScreen.Initialize(self, params, errorDepth)
    PopParamChange(params, "screenName")

    gCustomizeScreen = self

    self:GetRootItem():SetDebugName("customizeScreen")

    self:ListenForCursorInteractions() -- prevent click-through

    self.background = CreateGUIObject("background", GUIMenuBasicBox, self)
    self.background:SetLayer(-2)
    self.background:SetPosition( kInnerBgSideSpacing * 0.5, kInnerBgTopSpacing )
    self.background:SetStrokeWidth( kInnerBgBorderWidth )
    self.background:SetStrokeColor( MenuStyle.kTooltipText )
    self:HookEvent(self, "OnSizeChanged", UpdateInnerBackgroundSize)

    self:SetSize( Vector(kScreenWidth, kScreenHeight, 0) )

    self:SetCropMin(0,0)
    self:SetCropMax(1,1)

    self.customizeActive = false

    --FIXME Need to ensure this jives with clients aspect ratio (to fix squashing effect)
    local viewSize = Vector( kScreenWidth - (kInnerBgSideSpacing * 2) - kInnerBgBorderWidth - 1, kScreenHeight - (kInnerBgTopSpacing * 2) - kInnerBgBorderWidth, 0)

    local scene = GetCustomizeScene()
    scene:Initialize( viewSize )
    --Supplied callback is triggered whenever the camera has moved within activation-distance of a given View position
    scene:SetViewLabelGUICallback( self.OnViewLabelActivation )

    self.renderTexture = CreateGUIObject("renderTexture", GUIObject, self)
    self.renderTexture:SetLayer(-1)
    self.renderTexture:SetPosition( kInnerBgSideSpacing * 0.5 + kInnerBgBorderWidth, kInnerBgTopSpacing + kInnerBgBorderWidth )
    self.renderTexture:SetSize( viewSize )
    self.renderTexture:SetColor( Color(1, 1, 1, 1) )
    self.renderTexture:SetShader( kCinematicShader )
    self.renderTexture:SetTexture( CustomizeScene.kRenderTarget )

    self.activeTargetView = gCustomizeSceneData.kDefaultViewLabel  --TODO Read from client options
    self.previousTargetView = self.activeTargetView
    
    --Note: ALL child GUIObjects MUST be initialized AFTER CustomizeScene is created _and_ initialized!
    self:InitializeNavElements()
    
    self.viewsWorldButtons = {}
    self:InitWorldNavigationElements()

    self.timeTargetViewChange = 0

    --Hook Main Menu event to toggle this screen in order to control exclusion stencil
    self:HookEvent( GetMainMenu(), "OnClosed", function() GetCustomizeScene():SetActive(false) end )
    self:HookEvent( GetMainMenu(), "OnOpened", 
        function()
            local customizeScreenActive = GetCustomizeScreen().customizeActive
            if customizeScreenActive then
                GetCustomizeScreen():UpdateExclusionStencilSize()
            end
            GetCustomizeScene():SetActive(customizeScreenActive)
        end
    )

    --Required in order to update render scene, this can never be false
    self:SetUpdates( true )

end

function GUIMenuCustomizeScreen:InitializeNavElements()

    self.mainMarineTopBar = {}
    self.mainAlienBottomBar = {}

    local marineBarStyle = 
    {
        font = MenuStyle.kCustomizeViewBarMarineButtonFont,
        fontGlow = MenuStyle.kCustomizeViewBarMarineButtonFont,
        fontColor = MenuStyle.kOptionHeadingColor,
        fontGlowStyle = MenuStyle.kMainBarButtonGlow
    }

    --TODO Add localization to Buttons
    --TODO: These lists of buttons need "end-caps" images (optional)
    self.mainMarineTopBar = CreateGUIObject("marineMainTopBar", GUIMenuTabbedListButtonsWidget, self, 
    {
        position = Vector( 0, kInnerBgSideSpacing, 0 ),
        align = "top"
    })
    self.mainMarineTopBar:AddButton( "weaponsButton", "Weapons", function() self.SetDesiredActiveView(self, gCustomizeSceneData.kViewLabels.Armory) end, marineBarStyle )
    self.mainMarineTopBar:AddButton( "armorsButton", "Armors", function() self.SetDesiredActiveView(self, gCustomizeSceneData.kViewLabels.Marines) end, marineBarStyle )
    self.mainMarineTopBar:AddButton( "patchesButton", "Shoulder Patches", function() self.SetDesiredActiveView(self, gCustomizeSceneData.kViewLabels.ShoulderPatches) end, marineBarStyle )
    self.mainMarineTopBar:AddButton( "exosButton", "Exosuits", function() self.SetDesiredActiveView(self, gCustomizeSceneData.kViewLabels.ExoBay) end, marineBarStyle )
    self.mainMarineTopBar:AddButton( "structuresButton", "Structures", function() self.SetDesiredActiveView(self, gCustomizeSceneData.kViewLabels.MarineStructures) end, marineBarStyle )
    self.mainMarineTopBar:AlignTop()
    self.mainMarineTopBar:SetVisible(true)

    local alienBarStyle = 
    {
        font = MenuStyle.kCustomizeViewBarAlienButtonFont,
        fontGlow = MenuStyle.kCustomizeViewBarAlienButtonFont,
        fontColor = MenuStyle.kOptionHeadingColor,
        fontGlowStyle = MenuStyle.kCustomizeBarButtonAlienGlow
    }

    --TODO: These lists of buttons need "end-caps" images (optional)
    --TODO Add localization to Buttons
    self.mainAlienBottomBar = CreateGUIObject("mainAlienBottomBar", GUIMenuTabbedListButtonsWidget, self, { align = "bottom" })
    self.mainAlienBottomBar:AddButton( "lifeforms", "Lifeforms", function() self.SetDesiredActiveView(self, gCustomizeSceneData.kViewLabels.AlienLifeforms) end, alienBarStyle )
    self.mainAlienBottomBar:AddButton( "alienStructsButton", "Structures", function() self.SetDesiredActiveView(self, gCustomizeSceneData.kViewLabels.AlienStructures) end, alienBarStyle )
    self.mainAlienBottomBar:AddButton( "alienTunnelsButton", "Tunnels", function() self.SetDesiredActiveView(self, gCustomizeSceneData.kViewLabels.AlienTunnels) end, alienBarStyle )
    self.mainAlienBottomBar:SetY( -2 )
    self.mainAlienBottomBar:AlignBottom()
    self.mainAlienBottomBar:SetVisible(false)

    self.aliensViewButton = CreateGUIObject("goAliensViewButtn", GUIMenuCustomizeTabButton, self,
    {
        label = "KHARAA", --TODO localize? (requires new string)
        font = MenuStyle.kCustomizeViewAliensButtonFont,
        fontColor = MenuStyle.kOptionHeadingColor,
        fontGlow = MenuStyle.kCustomizeViewAliensButtonFont,
        fontGlowStyle = MenuStyle.kCustomizeBarButtonAlienGlow,
        --position = Vector( 0, -kInnerBgSideSpacing, 0 ),
    })
    self.aliensViewButton:HookEvent(self.aliensViewButton, "OnPressed", function() self.SetDesiredActiveView(self, gCustomizeSceneData.kViewLabels.DefaultAlienView) end)
    self.aliensViewButton:SetVisible(true)
    self.aliensViewButton:AlignBottom()

    self.marinesViewButton = CreateGUIObject("goMarinesViewButtn", GUIMenuCustomizeTabButton, self,
        {
            label = "FRONTIERSMEN", --TODO localize? (requires new string)
            font = MenuStyle.kCustomizeViewMarinesButtonFont,
            fontColor = MenuStyle.kOptionHeadingColor,
            fontGlow = MenuStyle.kCustomizeViewMarinesButtonFont,
            fontGlowStyle = MenuStyle.kMainBarButtonGlow,
            position = Vector( 0, kInnerBgSideSpacing, 0 ),
        })
    self.marinesViewButton:HookEvent(self.marinesViewButton, "OnPressed", function() self.SetDesiredActiveView(self, gCustomizeSceneData.kViewLabels.DefaultMarineView) end)
    self.marinesViewButton:SetVisible(false) --only visible in Alien-centric views 
    self.marinesViewButton:AlignTop()

    --Generalized Back button that's only active on "sub-view" (i.e. Non-Default view)
    self.globalBackButton = CreateGUIObject("globalBackButton", GUIMenuCustomizeTabButton, self,
        {
            label = Locale.ResolveString("BACK"),
            font = MenuStyle.kCustomizeViewMarinesButtonFont,
            fontColor = MenuStyle.kWhite,
            fontGlow = MenuStyle.kCustomizeViewMarinesButtonFont,
            fontGlowStyle = MenuStyle.kCustomizeButtonGlow,
            position = Vector( -8, -8, 0 ),
        })
    self.globalBackButton:SetVisible(false)
    self.globalBackButton:AlignBottomRight()
    self.globalBackButton:SetLayer( kGlobalBackButtonLayer )
    self.globalBackButton:HookEvent(self.globalBackButton, "OnPressed", 
        function()
            --[[
            local cScrn = GetCustomizeScreen()
            if cScrn.worldGlobalObjectZoomButton:GetVisible() then
                cScrn:HideModelZoomElements( cScrn.worldGlobalObjectZoomButton:GetSceneObjectLabel() )
            end
            --]]

            local curTeamIdx = GetViewTeamIndex(self.activeTargetView)
            local teamDefaultView = 
                curTeamIdx == kTeam1Index and gCustomizeSceneData.kViewLabels.DefaultMarineView
                or gCustomizeSceneData.kViewLabels.DefaultAlienView
            self.SetDesiredActiveView(self, teamDefaultView)
        end
    )

end

function GUIMenuCustomizeScreen:InitWorldNavigationElements()

    --Marines Default view World buttons
    self.worldWeaponsButton = CreateGUIObject( "worldWeaponsButton", GUIMenuCustomizeWorldButton, self )
    self.worldWeaponsButton:AlignLeft()
    self.worldWeaponsButton:SetSize( Vector( 500, 350, 0 ) )
    self.worldWeaponsButton:SetY( -120 )
    self.worldWeaponsButton:SetLayer( kMainWorldButtonsLayer )
    --self.worldWeaponsButton:SetColor( Color(1, 0.2, 1, 0.2) )
    local viewArmory = function()
        GetCustomizeScreen():SetDesiredActiveView( gCustomizeSceneData.kViewLabels.Armory )
    end
    self.worldWeaponsButton:SetPressedCallback( viewArmory )
    local toggleHighlightArmory = function()
        GetCustomizeScene():ToggleViewHighlight( gCustomizeSceneData.kViewLabels.Armory )
    end
    self.worldWeaponsButton:SetMouseEnterCallback( toggleHighlightArmory )
    self.worldWeaponsButton:SetMouseExitCallback( toggleHighlightArmory )
    --FIXME Add scaling hook(s)

    self.worldArmorsButton = CreateGUIObject( "worldArmorsButton", GUIMenuCustomizeWorldButton, self )
    self.worldArmorsButton:AlignCenter()
    self.worldArmorsButton:SetSize( Vector( 745, 430, 0 ) )
    self.worldArmorsButton:SetY( 155 )
    self.worldArmorsButton:SetX( 200 )
    self.worldArmorsButton:SetLayer( kMainWorldButtonsLayer )
    --self.worldArmorsButton:SetColor( Color(1, 1, 1, 0.3) )
    local viewMarines = function()
        GetCustomizeScreen():SetDesiredActiveView( gCustomizeSceneData.kViewLabels.Marines )
    end
    self.worldArmorsButton:SetPressedCallback( viewMarines )
    local toggleHighlightMarines = function()
        GetCustomizeScene():ToggleViewHighlight( gCustomizeSceneData.kViewLabels.Marines )
    end
    self.worldArmorsButton:SetMouseEnterCallback( toggleHighlightMarines )
    self.worldArmorsButton:SetMouseExitCallback( toggleHighlightMarines )
    --FIXME Add scaling hook(s)

    self.worldExosuitsButton = CreateGUIObject( "worldExosuitsButton", GUIMenuCustomizeWorldButton, self )
    self.worldExosuitsButton:AlignRight()
    self.worldExosuitsButton:SetSize( Vector( 450, 415, 0 ) )
    self.worldExosuitsButton:SetY( -150 )
    self.worldExosuitsButton:SetX( -10 )
    self.worldExosuitsButton:SetLayer( kMainWorldButtonsLayer )
    --self.worldExosuitsButton:SetColor( Color(0, 1, 1, 0.2) )
    local viewExos = function()
        GetCustomizeScreen():SetDesiredActiveView( gCustomizeSceneData.kViewLabels.ExoBay )
    end
    self.worldExosuitsButton:SetPressedCallback( viewExos )
    local toggleHighlightExos = function()
        GetCustomizeScene():ToggleViewHighlight( gCustomizeSceneData.kViewLabels.ExoBay )
    end
    self.worldExosuitsButton:SetMouseEnterCallback( toggleHighlightExos )
    self.worldExosuitsButton:SetMouseExitCallback( toggleHighlightExos )
    --FIXME Add scaling hook(s)

    self.worldMarineStructsButton1 = CreateGUIObject( "worldMarineStructsButton1", GUIMenuCustomizeWorldButton, self )
    self.worldMarineStructsButton1:AlignCenter()
    self.worldMarineStructsButton1:SetSize( Vector( 520, 280, 0 ) )
    self.worldMarineStructsButton1:SetY( -190 )
    self.worldMarineStructsButton1:SetLayer( kMainWorldButtonsLayer )
    --self.worldMarineStructsButton1:SetColor( Color(0, 1, 0, 0.15) )
    local viewMarineStructs = function()
        GetCustomizeScreen():SetDesiredActiveView( gCustomizeSceneData.kViewLabels.MarineStructures )
    end
    self.worldMarineStructsButton1:SetPressedCallback( viewMarineStructs )
    local toggleHighlightMarineStructs = function()
        GetCustomizeScene():ToggleViewHighlight( gCustomizeSceneData.kViewLabels.MarineStructures )
    end
    self.worldMarineStructsButton1:SetMouseEnterCallback( toggleHighlightMarineStructs )
    self.worldMarineStructsButton1:SetMouseExitCallback( toggleHighlightMarineStructs )
    --FIXME Add scaling hook(s)

    self.worldMarineStructsButton2 = CreateGUIObject( "worldMarineStructsButton2", GUIMenuCustomizeWorldButton, self )
    self.worldMarineStructsButton2:AlignCenter()
    self.worldMarineStructsButton2:SetSize( Vector( 320, 250, 0 ) )
    self.worldMarineStructsButton2:SetY( -50 )
    self.worldMarineStructsButton2:SetX( -410 )
    self.worldMarineStructsButton2:SetLayer( kMainWorldButtonsLayer )
    --self.worldMarineStructsButton2:SetColor( Color(0, 1, 0.2, 0.325) )
    self.worldMarineStructsButton2:SetPressedCallback( viewMarineStructs )
    self.worldMarineStructsButton2:SetMouseEnterCallback( toggleHighlightMarineStructs )
    self.worldMarineStructsButton2:SetMouseExitCallback( toggleHighlightMarineStructs )
    --FIXME Add scaling hook(s)

    self.viewsWorldButtons[gCustomizeSceneData.kViewLabels.DefaultMarineView] = 
    {
        self.worldWeaponsButton, self.worldArmorsButton, self.worldExosuitsButton, 
        self.worldMarineStructsButton1, self.worldMarineStructsButton2
    }
    

    --Alien Default View World buttons
    local viewAlienStructs = function()
        GetCustomizeScreen():SetDesiredActiveView( gCustomizeSceneData.kViewLabels.AlienStructures )
    end

    local toggleHighlightAlienStructs = function()
        GetCustomizeScene():ToggleViewHighlight( gCustomizeSceneData.kViewLabels.AlienStructures )
    end

    self.worldAlienStructsButton1 = CreateGUIObject( "worldAlienStructsButton1", GUIMenuCustomizeWorldButton, self )
    self.worldAlienStructsButton1:AlignLeft()
    self.worldAlienStructsButton1:SetSize( Vector( 510, 540, 0 ) )
    self.worldAlienStructsButton1:SetY( -90 )
    self.worldAlienStructsButton1:SetX( 480 )
    self.worldAlienStructsButton1:SetLayer( kMainWorldButtonsLayer )
    self.worldAlienStructsButton1:SetVisible(false)
    --self.worldAlienStructsButton1:SetColor( Color(1, 0, 0.5, 0.2) )
    self.worldAlienStructsButton1:SetPressedCallback( viewAlienStructs )
    self.worldAlienStructsButton1:SetMouseEnterCallback( toggleHighlightAlienStructs )
    self.worldAlienStructsButton1:SetMouseExitCallback( toggleHighlightAlienStructs )
    --FIXME Add scaling hook(s)

    self.worldAlienStructsButton2 = CreateGUIObject( "worldAlienStructsButton2", GUIMenuCustomizeWorldButton, self )
    self.worldAlienStructsButton2:AlignCenter()
    self.worldAlienStructsButton2:SetSize( Vector( 365, 350, 0 ) )
    self.worldAlienStructsButton2:SetY( -10 )
    self.worldAlienStructsButton2:SetX( -160 )
    self.worldAlienStructsButton2:SetLayer( kMainWorldButtonsLayer )
    self.worldAlienStructsButton2:SetVisible(false)
    --self.worldAlienStructsButton2:SetColor( Color(1, 0.2, 0.8, 0.2) )
    self.worldAlienStructsButton2:SetPressedCallback( viewAlienStructs )
    self.worldAlienStructsButton2:SetMouseEnterCallback( toggleHighlightAlienStructs )
    self.worldAlienStructsButton2:SetMouseExitCallback( toggleHighlightAlienStructs )
    --FIXME Add scaling hook(s)


    local viewAlienLifeforms = function()
        GetCustomizeScreen():SetDesiredActiveView( gCustomizeSceneData.kViewLabels.AlienLifeforms )
    end
    local toggleHighlightLifeforms = function()
        GetCustomizeScene():ToggleViewHighlight( gCustomizeSceneData.kViewLabels.AlienLifeforms )
    end

    self.worldLifeformsButton1 = CreateGUIObject( "worldLifeformsButton1", GUIMenuCustomizeWorldButton, self )
    self.worldLifeformsButton1:AlignCenter()
    self.worldLifeformsButton1:SetSize( Vector( 500, 400, 0 ) )
    self.worldLifeformsButton1:SetY( -40 )
    self.worldLifeformsButton1:SetX( 300 )
    self.worldLifeformsButton1:SetLayer( kMainWorldButtonsLayer )
    self.worldLifeformsButton1:SetVisible(false)
    --self.worldLifeformsButton1:SetColor( Color(0.3, 1, 0.2, 0.2) )
    self.worldLifeformsButton1:SetPressedCallback( viewAlienLifeforms )
    self.worldLifeformsButton1:SetMouseEnterCallback( toggleHighlightLifeforms )
    self.worldLifeformsButton1:SetMouseExitCallback( toggleHighlightLifeforms )
    --FIXME Add scaling hook(s)

    self.worldLifeformsButton2 = CreateGUIObject( "worldLifeformsButton2", GUIMenuCustomizeWorldButton, self )
    self.worldLifeformsButton2:AlignCenter()
    self.worldLifeformsButton2:SetSize( Vector( 215, 200, 0 ) )
    self.worldLifeformsButton2:SetY( 60 )
    self.worldLifeformsButton2:SetX( 650 )
    self.worldLifeformsButton2:SetLayer( kMainWorldButtonsLayer )
    self.worldLifeformsButton2:SetVisible(false)
    --self.worldLifeformsButton2:SetColor( Color(0.5, 1, 0.1, 0.15) )
    self.worldLifeformsButton2:SetPressedCallback( viewAlienLifeforms )
    self.worldLifeformsButton2:SetMouseEnterCallback( toggleHighlightLifeforms )
    self.worldLifeformsButton2:SetMouseExitCallback( toggleHighlightLifeforms )
    --FIXME Add scaling hook(s)

    self.worldLifeformsButton3 = CreateGUIObject( "worldLifeformsButton3", GUIMenuCustomizeWorldButton, self )
    self.worldLifeformsButton3:AlignRight()
    self.worldLifeformsButton3:SetSize( Vector( 280, 220, 0 ) )
    self.worldLifeformsButton3:SetY( -165 )
    self.worldLifeformsButton3:SetX( -285 )
    self.worldLifeformsButton3:SetLayer( kMainWorldButtonsLayer )
    self.worldLifeformsButton3:SetVisible(false)
    --self.worldLifeformsButton3:SetColor( Color(0.85, 0.2, 0, 0.3) )
    self.worldLifeformsButton3:SetPressedCallback( viewAlienLifeforms )
    self.worldLifeformsButton3:SetMouseEnterCallback( toggleHighlightLifeforms )
    self.worldLifeformsButton3:SetMouseExitCallback( toggleHighlightLifeforms )
    --FIXME Add scaling hook(s)


    local viewAlienTunnels = function()
        GetCustomizeScreen():SetDesiredActiveView( gCustomizeSceneData.kViewLabels.AlienTunnels )
    end
    local toggleHighlightTunnels = function()
        GetCustomizeScene():ToggleViewHighlight( gCustomizeSceneData.kViewLabels.AlienTunnels )
    end

    self.worldAlienTunnelButton = CreateGUIObject( "worldAlienTunnelButton", GUIMenuCustomizeWorldButton, self )
    self.worldAlienTunnelButton:AlignCenter()
    self.worldAlienTunnelButton:SetSize( Vector( 380, 240, 0 ) )
    self.worldAlienTunnelButton:SetY( 280 )
    self.worldAlienTunnelButton:SetX( 150 )
    self.worldAlienTunnelButton:SetLayer( kMainWorldButtonsLayer )
    self.worldAlienTunnelButton:SetVisible(false)
    --self.worldAlienTunnelButton:SetColor( Color(1, 0, 0, 0.4) )
    self.worldAlienTunnelButton:SetPressedCallback( viewAlienTunnels )
    self.worldAlienTunnelButton:SetMouseEnterCallback( toggleHighlightTunnels )
    self.worldAlienTunnelButton:SetMouseExitCallback( toggleHighlightTunnels )
    --FIXME Add scaling hook(s)

    self.viewsWorldButtons[gCustomizeSceneData.kViewLabels.DefaultAlienView] = 
    {
        self.worldAlienStructsButton1,
        self.worldAlienStructsButton2,
        self.worldLifeformsButton1,
        self.worldLifeformsButton2,
        self.worldLifeformsButton3,
        self.worldAlienTunnelButton
    }


    self:InitMarineWeaponElements()
    self:InitMarineArmorElements()
    self:InitMarinePatchElements()
    self:InitMarineExoElements()
    self:InitMarineStructureElements()

    self:InitAlienLifeformElements()
    self:InitAlienStructuresElements()
    self:InitAlienTunnelElements()

    --[[
    --This is the common (GUI aligned, not world/view releative) button that handles mouse-dragging, etc for Zooming on Scene Objects (i.e. rendering in ViewZone, not Default)
    self.worldGlobalObjectZoomButton = CreateGUIObject("worldGlobalObjectZoomButton", GUIMenuCustomizeWorldButton, self)
    self.worldGlobalObjectZoomButton:AlignCenter()
    self.worldGlobalObjectZoomButton:SetSize( Vector( 2600, 1350, 0 ) ) --match primary parent size, minus some padding?
    self.worldGlobalObjectZoomButton:SetY( -50 )
    self.worldGlobalObjectZoomButton:SetLayer( kItemViewButtonsLayer ) --higher order?
    self.worldGlobalObjectZoomButton:SetVisible(false)
    --self.worldGlobalObjectZoomButton:SetColor( Color(1, 0, 0.1, 0.425) )
    
    self.worldGlobalZoomInstructions = CreateGUIObject("worldGlobalZoomInstructions", GUIText, self, { font = kViewInstructionsFont, })
    self.worldGlobalZoomInstructions:AlignBottom()
    self.worldGlobalZoomInstructions:SetY( -50 )
    self.worldGlobalZoomInstructions:SetText("Left-click and drag to rotate, Right-click to zoom-out") --TODO Localize
    self.worldGlobalZoomInstructions:SetDropShadowEnabled(true)
    self.worldGlobalZoomInstructions:SetVisible(false)

    local CloseZoom = function(self)
        GetCustomizeScreen():HideModelZoomElements( self:GetSceneObjectLabel() )
    end
    self.worldGlobalObjectZoomButton:SetMouseRightClickCallback(CloseZoom)
    --TODO Setup mouse-drag cb
        Should just feed a vector direction and length to CustomizeScene, but only when moved far enough (min-dist)
    --]]

end

--[[
function GUIMenuCustomizeScreen:ShowModelZoomElements( objectSceneName )
    assert(objectSceneName)
    self:HideViewWorldElements()
    self.worldGlobalObjectZoomButton:SetSceneObjectLabel( objectSceneName )
    self.worldGlobalObjectZoomButton:SetVisible(true)
    self.worldGlobalZoomInstructions:SetVisible(true)
    
    if GetViewTeamIndex( self.activeTargetView ) == kTeam1Index then
        self.mainMarineTopBar:SetVisible(false)
    else
        self.mainAlienBottomBar:SetVisible(false)
    end

    GetCustomizeScene():SetZoomedSceneObject(objectSceneName)
end

function GUIMenuCustomizeScreen:HideModelZoomElements( objectSceneName )
    assert(objectSceneName)

    GetCustomizeScene():RemoveZoomdSceneObject(objectSceneName)
    
    self:ToggleViewElements()
    self.worldGlobalZoomInstructions:SetVisible(false)
    self.worldGlobalObjectZoomButton:SetVisible(false)
    self.worldGlobalObjectZoomButton:ClearSceneObjectLabel()

    if GetViewTeamIndex( self.activeTargetView ) == kTeam1Index then
        self.mainMarineTopBar:SetVisible(true)
    else
        self.mainAlienBottomBar:SetVisible(true)
    end
end
--]]

function GUIMenuCustomizeScreen:InitAlienStructuresElements()

    local hiveStr = Locale.ResolveString("HIVE")
    local harvyStr = Locale.ResolveString("HARVESTER")
    local eggStr = Locale.ResolveString("EGG")

    local initHiveLbl = GetCustomizeScene():GetCustomizableObjectVariantName( "Hive" ) .. " " .. hiveStr
    local initHarvyLbl = GetCustomizeScene():GetCustomizableObjectVariantName( "Harvester" ) .. " " .. harvyStr
    local initEggLbl = GetCustomizeScene():GetCustomizableObjectVariantName( "Egg" ) .. " " .. eggStr

    self.worldHiveButton = CreateGUIObject( "worldHiveButton", GUIMenuCustomizeWorldButton, self )
    self.worldHiveButton:AlignCenter()
    self.worldHiveButton:SetSize( Vector( 900, 840, 0 ) )
    self.worldHiveButton:SetY( -190 )
    self.worldHiveButton:SetX( -250 )
    self.worldHiveButton:SetLayer( kMainWorldButtonsLayer )
    self.worldHiveButton:SetVisible(false)
    self.worldHiveButton:SetTooltip(initHiveLbl)
    --self.worldHiveButton:SetColor( Color(1, 0, 0.5, 0.2) )
    --FIXME Add scaling hook(s)

    self.worldHarvesterButton = CreateGUIObject( "worldHarvesterButton", GUIMenuCustomizeWorldButton, self )
    self.worldHarvesterButton:AlignRight()
    self.worldHarvesterButton:SetSize( Vector( 550, 800, 0 ) )
    self.worldHarvesterButton:SetY( 40 )
    self.worldHarvesterButton:SetX( -75 )
    self.worldHarvesterButton:SetLayer( kMainWorldButtonsLayer )
    self.worldHarvesterButton:SetVisible(false)
    self.worldHarvesterButton:SetTooltip(initHarvyLbl)
    --self.worldHarvesterButton:SetColor( Color(1, 0, 0, 0.3) )
    --FIXME Add scaling hook(s)

    self.worldEggButton = CreateGUIObject( "worldEggButton", GUIMenuCustomizeWorldButton, self )
    self.worldEggButton:AlignBottom()
    self.worldEggButton:SetSize( Vector( 510, 340, 0 ) )
    self.worldEggButton:SetY( -115 )
    self.worldEggButton:SetX( 410 )
    self.worldEggButton:SetLayer( kMainWorldButtonsLayer )
    self.worldEggButton:SetVisible(false)
    self.worldEggButton:SetTooltip(initEggLbl)
    --self.worldEggButton:SetColor( Color(0.2, 1, 0.2, 0.2) )
    --FIXME Add scaling hook(s)

    self.alienStructsIntructions = CreateGUIObject("alienStructsIntructions", GUIText, self, { font = kViewInstructionsFont, })
    self.alienStructsIntructions:AlignBottom()
    self.alienStructsIntructions:SetY( -110 )
    self.alienStructsIntructions:SetText("Left-click structures to change skin") --TODO Localize
    self.alienStructsIntructions:SetDropShadowEnabled(true)
    self.alienStructsIntructions:SetVisible(false)

    self.viewsWorldButtons[gCustomizeSceneData.kViewLabels.AlienStructures] = 
    {
        self.worldHiveButton,
        self.worldHarvesterButton,
        self.worldEggButton,

        self.alienStructsIntructions
    }

    local hiveBtn = self.worldHiveButton
    local harvyBtn = self.worldHarvesterButton
    local eggBtn = self.worldEggButton

    local CycleCosmetic = function(self)
        local nextLabel = GetCustomizeScene():CycleCosmetic( gCustomizeSceneData.kSceneObjectReferences.Hive )
        if self.name == "worldHiveButton" then
            self:SetTooltip( nextLabel .. " " .. hiveStr )
            harvyBtn:SetTooltip( nextLabel .. " " .. harvyStr )
            eggBtn:SetTooltip( nextLabel .. " " .. eggStr )
        elseif self.name == "worldHarvesterButton" then
            hiveBtn:SetTooltip( nextLabel .. " " .. hiveStr )
            self:SetTooltip( nextLabel .. " " .. harvyStr )
            eggBtn:SetTooltip( nextLabel .. " " .. eggStr )
        elseif self.name == "worldEggButton" then
            hiveBtn:SetTooltip( nextLabel .. " " .. hiveStr )
            harvyBtn:SetTooltip( nextLabel .. " " .. harvyStr )
            self:SetTooltip( nextLabel .. " " .. eggStr )
        end
    end

    self.worldHiveButton:SetPressedCallback( CycleCosmetic )
    self.worldHarvesterButton:SetPressedCallback( CycleCosmetic )
    self.worldEggButton:SetPressedCallback( CycleCosmetic )

end

function GUIMenuCustomizeScreen:InitAlienTunnelElements()

    local tunnelStr = Locale.ResolveString("TUNNEL_ENTRANCE") --FIXME Bleh...no string-key for just "Tunnels"
    local initTunnelLbl = GetCustomizeScene():GetCustomizableObjectVariantName( "Tunnel" ) .. " " .. tunnelStr

    self.worldTunnelButton = CreateGUIObject( "worldTunnelButton", GUIMenuCustomizeWorldButton, self )
    self.worldTunnelButton:AlignCenter()
    self.worldTunnelButton:SetSize( Vector( 1050, 750, 0 ) )
    self.worldTunnelButton:SetY( -95 )
    self.worldTunnelButton:SetX( -60 )
    self.worldTunnelButton:SetLayer( kMainWorldButtonsLayer )
    self.worldTunnelButton:SetVisible(false)
    self.worldTunnelButton:SetTooltip(initTunnelLbl)
    --self.worldTunnelButton:SetColor( Color(1, 0, 0.5, 0.2) )
    --FIXME Add scaling hook(s)

    self.tunnelsIntructions = CreateGUIObject("tunnelsIntructions", GUIText, self, { font = kViewInstructionsFont, })
    self.tunnelsIntructions:AlignBottom()
    self.tunnelsIntructions:SetY( -110 )
    self.tunnelsIntructions:SetText("Left-click Tunnel to change skin") --TODO Localize
    self.tunnelsIntructions:SetDropShadowEnabled(true)
    self.tunnelsIntructions:SetVisible(false)

    self.viewsWorldButtons[gCustomizeSceneData.kViewLabels.AlienTunnels] = 
    {
        self.worldTunnelButton, self.tunnelsIntructions
    }

    local CycleCosmetic = function(self)
        local nextLabel = GetCustomizeScene():CycleCosmetic( gCustomizeSceneData.kSceneObjectReferences.Tunnel )
        self:SetTooltip( nextLabel .. " " .. tunnelStr )
    end

    self.worldTunnelButton:SetPressedCallback( CycleCosmetic )

    --[[
    local ZoomTunnel = function(self)
        local cScrn = GetCustomizeScreen()
        if not cScrn.worldGlobalObjectZoomButton:GetVisible() then
            cScrn:ShowModelZoomElements( "Tunnel" )
        end
    end
    self.worldTunnelButton:SetMouseRightClickCallback( ZoomTunnel )
    --]]
end


function GUIMenuCustomizeScreen:InitAlienLifeformElements()

    local skulkStr = Locale.ResolveString("SKULK")
    local gorgeStr = Locale.ResolveString("GORGE")
    local lerkStr = Locale.ResolveString("LERK")
    local fadeStr = Locale.ResolveString("FADE")
    local onosStr = Locale.ResolveString("ONOS")

    local initSkulkLbl = GetCustomizeScene():GetCustomizableObjectVariantName( "Skulk" ) .. " " .. skulkStr
    local initGorgeLbl = GetCustomizeScene():GetCustomizableObjectVariantName( "Gorge" ) .. " " .. gorgeStr
    local initLerkLbl = GetCustomizeScene():GetCustomizableObjectVariantName( "Lerk" ) .. " " .. lerkStr
    local initFadeLbl = GetCustomizeScene():GetCustomizableObjectVariantName( "Fade" ) .. " " .. fadeStr
    local initOnosLbl = GetCustomizeScene():GetCustomizableObjectVariantName( "Onos" ) .. " " .. onosStr

    self.worldSkulkButton = CreateGUIObject( "worldSkulkButton", GUIMenuCustomizeWorldButton, self )
    self.worldSkulkButton:AlignRight()
    self.worldSkulkButton:SetSize( Vector( 625, 320, 0 ) )
    self.worldSkulkButton:SetY( -15 )
    self.worldSkulkButton:SetX( -310 )
    self.worldSkulkButton:SetLayer( kMainWorldButtonsLayer )
    --self.worldSkulkButton:SetColor( Color(0.2, 0, 0.8, 0.2) )
    self.worldSkulkButton:SetVisible(false)
    self.worldSkulkButton:SetTooltip(initSkulkLbl)
    --FIXME Add scaling hook(s)

    self.worldGorgeButton = CreateGUIObject( "worldGorgeButton", GUIMenuCustomizeWorldButton, self )
    self.worldGorgeButton:AlignCenter()
    self.worldGorgeButton:SetSize( Vector( 360, 360, 0 ) )
    self.worldGorgeButton:SetY( 145 )
    self.worldGorgeButton:SetX( 95 )
    self.worldGorgeButton:SetLayer( kMainWorldButtonsLayer )
    self.worldGorgeButton:SetVisible(false)
    self.worldGorgeButton:SetTooltip(initGorgeLbl)
    --self.worldGorgeButton:SetColor( Color(0.2, 1, 0, 0.2) )
    --FIXME Add scaling hook(s)

    self.worldLerkButton = CreateGUIObject( "worldLerkButton", GUIMenuCustomizeWorldButton, self )
    self.worldLerkButton:AlignTopRight()
    self.worldLerkButton:SetSize( Vector( 425, 300, 0 ) )
    self.worldLerkButton:SetY( 90 )
    self.worldLerkButton:SetX( -310 )
    self.worldLerkButton:SetLayer( kMainWorldButtonsLayer )
    self.worldLerkButton:SetVisible(false)
    self.worldLerkButton:SetTooltip(initLerkLbl)
    --self.worldLerkButton:SetColor( Color(1, 0, 0.2, 0.25) )
    --FIXME Add scaling hook(s)

    self.worldFadeButton = CreateGUIObject( "worldFadeButton", GUIMenuCustomizeWorldButton, self )
    self.worldFadeButton:AlignLeft()
    self.worldFadeButton:SetSize( Vector( 540, 450, 0 ) )
    self.worldFadeButton:SetY( 90 )
    self.worldFadeButton:SetX( 90 )
    self.worldFadeButton:SetLayer( kMainWorldButtonsLayer )
    self.worldFadeButton:SetVisible(false)
    self.worldFadeButton:SetTooltip(initFadeLbl)
    --self.worldFadeButton:SetColor( Color(1, 0, 0.5, 0.2) )
    --FIXME Add scaling hook(s)

    self.worldOnosButton = CreateGUIObject( "worldOnosButton", GUIMenuCustomizeWorldButton, self )
    self.worldOnosButton:AlignCenter()
    self.worldOnosButton:SetSize( Vector( 560, 750, 0 ) )
    self.worldOnosButton:SetY( -180 )
    self.worldOnosButton:SetX( -390 )
    self.worldOnosButton:SetLayer( kMainWorldButtonsLayer )
    self.worldOnosButton:SetVisible(false)
    self.worldOnosButton:SetTooltip(initOnosLbl)
    --self.worldOnosButton:SetColor( Color(0.5, 0, 1, 0.2) )
    --FIXME Add scaling hook(s)

    self.lifeformsIntructions = CreateGUIObject("lifeformsIntructions", GUIText, self, { font = kViewInstructionsFont, })
    self.lifeformsIntructions:AlignBottom()
    self.lifeformsIntructions:SetY( -110 )
    self.lifeformsIntructions:SetText("Left-click Lifeform to change skin") --TODO Localize
    self.lifeformsIntructions:SetDropShadowEnabled(true)
    self.lifeformsIntructions:SetVisible(false)

    self.viewsWorldButtons[gCustomizeSceneData.kViewLabels.AlienLifeforms] = 
    {
        self.worldSkulkButton,
        self.worldGorgeButton,
        self.worldLerkButton,
        self.worldFadeButton,
        self.worldOnosButton,

        self.lifeformsIntructions
    }

    local CycleCosmeticSkulk = function(self)
        local nextLabel = GetCustomizeScene():CycleCosmetic( gCustomizeSceneData.kSceneObjectReferences.Skulk )
        self:SetTooltip(nextLabel .. " " .. skulkStr)
    end

    local CycleCosmeticGorge = function(self)
        local nextLabel = GetCustomizeScene():CycleCosmetic( gCustomizeSceneData.kSceneObjectReferences.Gorge )
        self:SetTooltip(nextLabel .. " " .. gorgeStr)
    end

    local CycleCosmeticLerk = function(self)
        local nextLabel = GetCustomizeScene():CycleCosmetic( gCustomizeSceneData.kSceneObjectReferences.Lerk )
        self:SetTooltip(nextLabel .. " " .. lerkStr)
    end

    local CycleCosmeticFade = function(self)
        local nextLabel = GetCustomizeScene():CycleCosmetic( gCustomizeSceneData.kSceneObjectReferences.Fade )
        self:SetTooltip(nextLabel .. " " .. fadeStr)
    end

    local CycleCosmeticOnos = function(self)
        local nextLabel = GetCustomizeScene():CycleCosmetic( gCustomizeSceneData.kSceneObjectReferences.Onos )
        self:SetTooltip(nextLabel .. " " .. onosStr)
    end

    self.worldSkulkButton:SetPressedCallback( CycleCosmeticSkulk )
    self.worldGorgeButton:SetPressedCallback( CycleCosmeticGorge )
    self.worldLerkButton:SetPressedCallback( CycleCosmeticLerk )
    self.worldFadeButton:SetPressedCallback( CycleCosmeticFade )
    self.worldOnosButton:SetPressedCallback( CycleCosmeticOnos )

end



function GUIMenuCustomizeScreen:InitMarineExoElements()

    local exoSuitStr = Locale.ResolveString("EXOSUIT")
    local initExoSkinLabel = GetCustomizeScene():GetCustomizableObjectVariantName( "ExoMiniguns" ) .. " " .. exoSuitStr --rail shares same label
    --TODO Need non=string identifider for above call param

    self.worldExoMinigunsButton = CreateGUIObject( "worldExoMinigunsButton", GUIMenuCustomizeWorldButton, self, { tooltip = "" } )
    self.worldExoMinigunsButton:AlignLeft()
    self.worldExoMinigunsButton:SetSize( Vector( 980, 1150, 0 ) )
    self.worldExoMinigunsButton:SetY( 65 )
    self.worldExoMinigunsButton:SetX( 260 )
    --self.worldExoMinigunsButton:SetColor( Color(0.2, 1, 1, 0.2) )
    self.worldExoMinigunsButton:SetVisible(false)
    self.worldExoMinigunsButton:SetTooltip(initExoSkinLabel)
    --FIXME Add scaling hook(s)

    self.worldExoRailgunsButton = CreateGUIObject( "worldExoRailgunsButton", GUIMenuCustomizeWorldButton, self, { tooltip = "" } )
    self.worldExoRailgunsButton:AlignRight()
    self.worldExoRailgunsButton:SetSize( Vector( 975, 1280, 0 ) )
    self.worldExoRailgunsButton:SetY( 80 )
    self.worldExoRailgunsButton:SetX( -10 )
    --self.worldExoRailgunsButton:SetColor( Color(0.5, 0.2, 1, 0.2) )
    self.worldExoRailgunsButton:SetVisible(false)
    self.worldExoRailgunsButton:SetTooltip(initExoSkinLabel)
    --FIXME Add scaling hook(s)

    self.exoIntructions = CreateGUIObject("exoIntructions", GUIText, self, { font = kViewInstructionsFont, })
    self.exoIntructions:AlignBottom()
    self.exoIntructions:SetY( -50 )
    self.exoIntructions:SetText("Left-click " .. exoSuitStr .. " to change skin") --TODO Localize
    self.exoIntructions:SetDropShadowEnabled(true)
    self.exoIntructions:SetVisible(false)

    self.viewsWorldButtons[gCustomizeSceneData.kViewLabels.ExoBay] = 
    {
        self.worldExoMinigunsButton, self.worldExoRailgunsButton, self.exoIntructions
    }

    local CycleCosmetic = function( self )
        local nextLabel = GetCustomizeScene():CycleCosmetic( gCustomizeSceneData.kSceneObjectReferences.Exo )
        self:SetTooltip(nextLabel .. " " .. exoSuitStr)
    end

    self.worldExoMinigunsButton:SetPressedCallback( CycleCosmetic )
    self.worldExoRailgunsButton:SetPressedCallback( CycleCosmetic )

    --[[
    local ZoomExoMiniguns = function(self)
        local cScrn = GetCustomizeScreen()
        if not cScrn.worldGlobalObjectZoomButton:GetVisible() then
        --"zoom" out is handled via global zoom/view world-button
            cScrn:ShowModelZoomElements( "ExoMiniguns" )
        end
    end

    local ZoomExoRailguns = function(self)
        local cScrn = GetCustomizeScreen()
        if not cScrn.worldGlobalObjectZoomButton:GetVisible() then
            cScrn:ShowModelZoomElements( "ExoRailguns" )
        end
    end

    self.worldExoMinigunsButton:SetMouseRightClickCallback( ZoomExoMiniguns )
    self.worldExoRailgunsButton:SetMouseRightClickCallback( ZoomExoRailguns )
    --]]
end


function GUIMenuCustomizeScreen:InitMarineStructureElements()

    local cmdStationStr = Locale.ResolveString("COMMAND_STATION")
    local extractorStr = Locale.ResolveString("EXTRACTOR")
    local initExtractorSkinLabel = GetCustomizeScene():GetCustomizableObjectVariantName( "Extractor" ) .. " " .. extractorStr
    local initCmdStationSkinLabel = GetCustomizeScene():GetCustomizableObjectVariantName( "CommandStation" ) .. " " .. cmdStationStr

    self.worldCommandStationButton = CreateGUIObject( "worldCommandStationButton", GUIMenuCustomizeWorldButton, self )
    self.worldCommandStationButton:AlignCenter()
    self.worldCommandStationButton:SetSize( Vector( 1100, 1200, 0 ) )
    self.worldCommandStationButton:SetX( 480 )
    --self.worldCommandStationButton:SetColor( Color(1, 0.2, 1, 0.2) )
    self.worldCommandStationButton:SetVisible(false) --Default to not interactable
    self.worldCommandStationButton:SetTooltip(initCmdStationSkinLabel)
    --FIXME Add scaling hook(s)

    self.worldExtractorButton = CreateGUIObject( "worldExtractorButton", GUIMenuCustomizeWorldButton, self )
    self.worldExtractorButton:AlignCenter()
    self.worldExtractorButton:SetSize( Vector( 600, 600, 0 ) )
    self.worldExtractorButton:SetY( 150 )
    self.worldExtractorButton:SetX( -600 )
    --self.worldExtractorButton:SetColor( Color(1, 0.2, 0.4, 0.2) )
    self.worldExtractorButton:SetTooltip(initExtractorSkinLabel)
    self.worldExtractorButton:SetVisible(false)
    --FIXME Add scaling hook(s)

    self.marineStructsIntructions = CreateGUIObject("marineStructsIntructions", GUIText, self, { font = kViewInstructionsFont, })
    self.marineStructsIntructions:AlignBottom()
    self.marineStructsIntructions:SetY( -50 )
    self.marineStructsIntructions:SetText("Left-click structure to change skin") --TODO Localize
    self.marineStructsIntructions:SetDropShadowEnabled(true)
    self.marineStructsIntructions:SetVisible(false)

    self.viewsWorldButtons[gCustomizeSceneData.kViewLabels.MarineStructures] = 
    {
        self.worldCommandStationButton, self.worldExtractorButton, self.marineStructsIntructions
    }

    local csBtn = self.worldCommandStationButton
    local exBtn = self.worldExtractorButton

    local CycleCosmetic = function(self)
        local nextLabel = GetCustomizeScene():CycleCosmetic( gCustomizeSceneData.kSceneObjectReferences.CommandStation )
        if self.name == "worldExtractorButton" then
            self:SetTooltip( nextLabel .. " " .. extractorStr )
            csBtn:SetTooltip( nextLabel .. " " .. cmdStationStr )
        else
            self:SetTooltip( nextLabel .. " " .. cmdStationStr )
            exBtn:SetTooltip( nextLabel .. " " .. extractorStr )
        end
    end

    self.worldExtractorButton:SetPressedCallback( CycleCosmetic )
    self.worldCommandStationButton:SetPressedCallback( CycleCosmetic )

end


function GUIMenuCustomizeScreen:InitMarinePatchElements()

    local patchStr = "Shoulder Patch"  --FIXME Bleh...no string-key for just "Shoulder Patch"
    local initPatchIdx = GetCustomizeScene():GetActiveShoulderPatchIndex()
    local initPadLbl = kShoulderPadNames[initPatchIdx] .. " " .. (kShoulderPadNames[initPatchIdx] == "None" and "" or patchStr)
    
    self.worldPatchButton = CreateGUIObject( "worldPatchButton", GUIMenuCustomizeWorldButton, self )
    self.worldPatchButton:AlignCenter()
    self.worldPatchButton:SetSize( Vector( 360, 365, 0 ) )
    self.worldPatchButton:SetLayer( kMainWorldButtonsLayer )
    self.worldPatchButton:SetVisible(false)
    self.worldPatchButton:SetTooltip(initPadLbl)
    --self.worldPatchButton:SetColor( Color(0.735, 0.285, 0, 0.35) )

    self.patchesIntructions = CreateGUIObject("patchesIntructions", GUIText, self, { font = kViewInstructionsFont, })
    self.patchesIntructions:AlignBottom()
    self.patchesIntructions:SetY( -50 )
    self.patchesIntructions:SetText("Left-click " .. patchStr .. " to change it") --TODO Localize
    self.patchesIntructions:SetDropShadowEnabled(true)
    self.patchesIntructions:SetVisible(false)

    self.viewsWorldButtons[gCustomizeSceneData.kViewLabels.ShoulderPatches] = 
    {
        self.worldPatchButton, self.patchesIntructions
    }

    local CyclePatch = function(self)
        local nextLabel = GetCustomizeScene():CyclePatches()
        local patchName = nextLabel ~= kShoulderPadNames[1] and ( nextLabel .. " " .. patchStr ) or nextLabel
        self:SetTooltip( patchName )
    end

    self.worldPatchButton:SetPressedCallback( CyclePatch )

end


local worldWepBtnToItem = 
{
    ["worldRifleButton"] = gCustomizeSceneData.kSceneObjectReferences.Rifle,
    ["worldPistolButton"] = gCustomizeSceneData.kSceneObjectReferences.Pistol,
    ["worldShotgunButton"] = gCustomizeSceneData.kSceneObjectReferences.Shotgun,
    ["worldWelderButton"] = gCustomizeSceneData.kSceneObjectReferences.Welder,
    ["worldAxeButton"] = gCustomizeSceneData.kSceneObjectReferences.Axe,
    ["worldGrenadeLauncherButton"] = gCustomizeSceneData.kSceneObjectReferences.GrenadeLauncher,
    ["worldFlamethrowerButton"] = gCustomizeSceneData.kSceneObjectReferences.Flamethrower,
    ["worldHmgButton"] = gCustomizeSceneData.kSceneObjectReferences.HeavyMachineGun,
}

function GUIMenuCustomizeScreen:InitMarineWeaponElements()

    local rifleLabel = Locale.ResolveString("RIFLE")
    local pistolLabel = Locale.ResolveString("PISTOL")
    local welderLabel = Locale.ResolveString("WELDER")
    local axeLabel = Locale.ResolveString("AXE")
    local sgLabel = Locale.ResolveString("SHOTGUN")
    local nadeLabel = Locale.ResolveString("GRENADE_LAUNCHER")
    local ftLabel = Locale.ResolveString("FLAMETHROWER")
    local hmgLabel = "Heavy Machine Gun"  --Locale.ResolveString("HMG") --TODO Add string-key

    local initRifleLbl = GetCustomizeScene():GetCustomizableObjectVariantName( "Rifle" ) .. " " .. rifleLabel
    local initPistolLbl = GetCustomizeScene():GetCustomizableObjectVariantName( "Pistol" ) .. " " .. pistolLabel
    local initWelderLbl = GetCustomizeScene():GetCustomizableObjectVariantName( "Welder" ) .. " " .. welderLabel
    local initAxeLbl = GetCustomizeScene():GetCustomizableObjectVariantName( "Axe" ) .. " " .. axeLabel
    local initShotgunLbl = GetCustomizeScene():GetCustomizableObjectVariantName( "Shotgun" ) .. " " .. sgLabel
    local initNadeLbl = GetCustomizeScene():GetCustomizableObjectVariantName( "GrenadeLauncher" ) .. " " .. nadeLabel
    local initFtLbl = GetCustomizeScene():GetCustomizableObjectVariantName( "Flamethrower" ) .. " " .. ftLabel
    local initHmgLbl = GetCustomizeScene():GetCustomizableObjectVariantName( "HeavyMachineGun" ) .. " " .. hmgLabel

    self.worldRifleButton = CreateGUIObject( "worldRifleButton", GUIMenuCustomizeWorldButton, self )
    self.worldRifleButton:AlignCenter()
    self.worldRifleButton:SetSize( Vector( 585, 210, 0 ) )
    self.worldRifleButton:SetY( -175 )
    self.worldRifleButton:SetX( -545 )
    --self.worldRifleButton:SetColor( Color(1, 1, 1, 0.285) )
    self.worldRifleButton:SetVisible(false) --Default to not interactable
    self.worldRifleButton:SetTooltip(initRifleLbl)
    --FIXME Add scaling hook(s)
    
    self.worldPistolButton = CreateGUIObject( "worldPistolButton", GUIMenuCustomizeWorldButton, self )
    self.worldPistolButton:AlignCenter()
    self.worldPistolButton:SetSize( Vector( 200, 120, 0 ) )
    self.worldPistolButton:SetY( -260 )
    self.worldPistolButton:SetX( 10 )
    --self.worldPistolButton:SetColor( Color(1, 1, 0, 0.285) )
    self.worldPistolButton:SetVisible(false)
    self.worldPistolButton:SetTooltip(initPistolLbl)
    --FIXME Add scaling hook(s)

    self.worldWelderButton = CreateGUIObject( "worldWelderButton", GUIMenuCustomizeWorldButton, self )
    self.worldWelderButton:AlignCenter()
    self.worldWelderButton:SetSize( Vector( 130, 140, 0 ) )
    self.worldWelderButton:SetY( -80 )
    self.worldWelderButton:SetX( -150 )
    --self.worldWelderButton:SetColor( Color(0, 1, 1, 0.3) )
    self.worldWelderButton:SetVisible(false)
    self.worldWelderButton:SetTooltip(initWelderLbl)
    --FIXME Add scaling hook(s)

    self.worldAxeButton = CreateGUIObject( "worldAxeButton", GUIMenuCustomizeWorldButton, self )
    self.worldAxeButton:AlignCenter()
    self.worldAxeButton:SetSize( Vector( 265, 120, 0 ) )
    self.worldAxeButton:SetY( -80 )
    self.worldAxeButton:SetX( 140 )
    --self.worldAxeButton:SetColor( Color(0, 1, 1, 0.3) )
    self.worldAxeButton:SetVisible(false)
    self.worldAxeButton:SetTooltip(initAxeLbl)
    --FIXME Add scaling hook(s)

    self.worldShotgunButton = CreateGUIObject( "worldShotgunButton", GUIMenuCustomizeWorldButton, self )
    self.worldShotgunButton:AlignRight()
    self.worldShotgunButton:SetSize( Vector( 570, 150, 0 ) )
    self.worldShotgunButton:SetY( -200 )
    self.worldShotgunButton:SetX( -485 )
    --self.worldShotgunButton:SetColor( Color(1, 0, 1, 0.285) )
    self.worldShotgunButton:SetVisible(false)
    self.worldShotgunButton:SetTooltip(initShotgunLbl)
    --FIXME Add scaling hook(s)

    self.worldGrenadeLauncherButton = CreateGUIObject( "worldGrenadeLauncherButton", GUIMenuCustomizeWorldButton, self )
    self.worldGrenadeLauncherButton:AlignCenter()
    self.worldGrenadeLauncherButton:SetSize( Vector( 540, 200, 0 ) )
    self.worldGrenadeLauncherButton:SetY( 95 )
    self.worldGrenadeLauncherButton:SetX( -455 )
    --self.worldGrenadeLauncherButton:SetColor( Color(1, 0, 0.5, 0.3) )
    self.worldGrenadeLauncherButton:SetVisible(false)
    self.worldGrenadeLauncherButton:SetTooltip(initNadeLbl)
    --FIXME Add scaling hook(s)

    self.worldFlamethrowerButton = CreateGUIObject( "worldFlamethrowerButton", GUIMenuCustomizeWorldButton, self )
    self.worldFlamethrowerButton:AlignRight()
    self.worldFlamethrowerButton:SetSize( Vector( 830, 260, 0 ) )
    self.worldFlamethrowerButton:SetY( 115 )
    self.worldFlamethrowerButton:SetX( -450 )
    --self.worldFlamethrowerButton:SetColor( Color(0, 0.65, 1, 0.3) )
    self.worldFlamethrowerButton:SetVisible(false)
    self.worldFlamethrowerButton:SetTooltip(initFtLbl)
    --FIXME Add scaling hook(s)

    self.worldHmgButton = CreateGUIObject( "worldHmgButton", GUIMenuCustomizeWorldButton, self )
    self.worldHmgButton:AlignCenter()
    self.worldHmgButton:SetSize( Vector( 880, 280, 0 ) )
    self.worldHmgButton:SetY( 490 )
    --self.worldHmgButton:SetColor( Color(0.4, 0, 1, 0.3) )
    self.worldHmgButton:SetVisible(false)
    self.worldHmgButton:SetTooltip(initHmgLbl)
    --FIXME Add scaling hook(s)

    self.weaponsIntructions = CreateGUIObject("weaponsIntructions", GUIText, self, { font = kViewInstructionsFont, })
    self.weaponsIntructions:AlignBottom()
    self.weaponsIntructions:SetY( -50 )
    self.weaponsIntructions:SetText("Left-click Weapon to change skin") --TODO Localize
    self.weaponsIntructions:SetDropShadowEnabled(true)
    self.weaponsIntructions:SetVisible(false)

    self.viewsWorldButtons[gCustomizeSceneData.kViewLabels.Armory] = 
    {
        self.worldRifleButton, self.worldPistolButton, self.worldShotgunButton,
        self.worldWelderButton, self.worldAxeButton, self.worldGrenadeLauncherButton,
        self.worldFlamethrowerButton, self.worldHmgButton,
        self.weaponsIntructions
    }

    --[[ (Note: these will be needed for "Collections / Sets" feature)
    local rifleBtn = self.worldRifleButton
    local pistolBtn = self.worldPistolButton
    local welderBtn = self.worldWelderButton
    local axeBtn = self.worldAxeButton
    local sgBtn = self.worldShotgunButton
    local nadeBtn = self.worldGrenadeLauncherButton
    local ftBtn = self.worldFlamethrowerButton
    local hmgBtn = self.worldHmgButton
    --]]

    local CycleWeaponCosmetic = function(self)
        local nextLabel = GetCustomizeScene():CycleCosmetic( worldWepBtnToItem[self.name] ) --linear loop step
        
        if self.name == "worldRifleButton" then
            self:SetTooltip( nextLabel .. " " .. rifleLabel )
        elseif self.name == "worldPistolButton" then
            self:SetTooltip( nextLabel .. " " .. pistolLabel )
        elseif self.name == "worldWelderButton" then
            self:SetTooltip( nextLabel .. " " .. welderLabel )
        elseif self.name == "worldAxeButton" then
            self:SetTooltip( nextLabel .. " " .. axeLabel )
        elseif self.name == "worldShotgunButton" then
            self:SetTooltip( nextLabel .. " " .. sgLabel )
        elseif self.name == "worldGrenadeLauncherButton" then
            self:SetTooltip( nextLabel .. " " .. nadeLabel )
        elseif self.name == "worldFlamethrowerButton" then
            self:SetTooltip( nextLabel .. " " .. ftLabel )
        elseif self.name == "worldHmgButton" then
            self:SetTooltip( nextLabel .. " " .. hmgLabel )
        end
    end

    self.worldRifleButton:SetPressedCallback( CycleWeaponCosmetic )
    self.worldPistolButton:SetPressedCallback( CycleWeaponCosmetic )
    self.worldShotgunButton:SetPressedCallback( CycleWeaponCosmetic )
    self.worldWelderButton:SetPressedCallback( CycleWeaponCosmetic )
    self.worldAxeButton:SetPressedCallback( CycleWeaponCosmetic )
    self.worldGrenadeLauncherButton:SetPressedCallback( CycleWeaponCosmetic )
    self.worldFlamethrowerButton:SetPressedCallback( CycleWeaponCosmetic )
    self.worldHmgButton:SetPressedCallback( CycleWeaponCosmetic )

    --TODO Add Object View-Zone "zooming" feature (needs to be modal, to toggle mouse-tracking [rotator] UI element(s) )

end

function GUIMenuCustomizeScreen:InitMarineArmorElements()

    local armorStr = Locale.ResolveString("ARMOR")
    local initArmorLabel = GetCustomizeScene():GetCustomizableObjectVariantName( "MarineRight" ) .. " " .. armorStr

    self.worldMarineArmorButton = CreateGUIObject( "worldMarineArmorButton", GUIMenuCustomizeWorldButton, self )
    self.worldMarineArmorButton:AlignCenter()
    self.worldMarineArmorButton:SetSize( Vector( 450, 1320, 0 ) )
    self.worldMarineArmorButton:SetY( 75 )
    self.worldMarineArmorButton:SetX( -30 )
    --self.worldMarineArmorButton:SetColor( Color(0.2, 1, 1, 0.2) )
    self.worldMarineArmorButton:SetVisible(false)
    self.worldMarineArmorButton:SetTooltip(initArmorLabel)
    --FIXME Add scaling hook(s)

    self.worldMarineGenderButton = CreateGUIObject( "worldMarineGenderButton", GUIMenuCustomizeWorldButton, self )
    self.worldMarineGenderButton:AlignLeft()
    self.worldMarineGenderButton:SetSize( Vector( 285, 640, 0 ) )
    self.worldMarineGenderButton:SetY( -70 )
    self.worldMarineGenderButton:SetX( 570 )
    --self.worldMarineGenderButton:SetColor( Color(0.8, 0.4, 0, 0.2) )
    self.worldMarineGenderButton:SetVisible(false)
    --FIXME Add scaling hook(s)

    self.armorIntructions = CreateGUIObject("armorInstructions", GUIText, self, { font = kViewInstructionsFont, })
    self.armorIntructions:AlignBottom()
    self.armorIntructions:SetY( -50 )
    self.armorIntructions:SetText("Left-click Marine change skin") --TODO Localize
    self.armorIntructions:SetDropShadowEnabled(true)
    self.armorIntructions:SetVisible(false)

    self.genderChangeLabel = CreateGUIObject("genderChangeLabel", GUIText, self,
    {
        font = kViewInstructionsFont,
    })
    self.genderChangeLabel:AlignLeft()
    self.genderChangeLabel:SetY( -70 )
    self.genderChangeLabel:SetX( 570 )
    self.genderChangeLabel:SetDropShadowEnabled(true)
    self.genderChangeLabel:SetVisible(false)
    local curGend = Client.GetOptionString("sexType", "Male")
    self.genderChangeLabel:SetText( "Change to " .. (curGend == "Male" and "Female" or "Male") ) --TODO Localize
    local genderChangeLabel = self.genderChangeLabel

    self.viewsWorldButtons[gCustomizeSceneData.kViewLabels.Marines] = 
    {
        self.worldMarineArmorButton, self.worldMarineGenderButton,
        self.armorIntructions, self.genderChangeLabel
    }

    local CycleArmor = function(self)
        local nextLabel = GetCustomizeScene():CycleCosmetic( gCustomizeSceneData.kSceneObjectReferences.Marine ) --linear loop step
        self:SetTooltip( nextLabel .. " " .. armorStr )
    end

    local CycleGender = function()  --FIXME This is setting the wrong variant-value for MarineRight
        local newType = GetCustomizeScene():CycleMarineGenderType()
        genderChangeLabel:SetText( "Change to " .. (newType == "Male" and "Female" or "Male") ) --TODO Localize
    end

    --TODO Add Right-click -> zoom handler (to trigger render in view-zone [needs toggle-state])
    self.worldMarineArmorButton:SetPressedCallback( CycleArmor )
    self.worldMarineGenderButton:SetPressedCallback( CycleGender )

end


function GUIMenuCustomizeScreen:ToggleViewElements()
    assert(self.viewsWorldButtons[self.activeTargetView])

    --Special case handlers
    if self.activeTargetView == gCustomizeSceneData.kViewLabels.ShoulderPatches then
        local curSex = Client.GetOptionString("sexType", "Male")
        --Always update position just in case
        if curSex == "Female" then
            self.worldPatchButton:SetY( -50 )
            self.worldPatchButton:SetX( 260 )
        else
            self.worldPatchButton:SetY( 25 )
            self.worldPatchButton:SetX( 100 )
        end
    end

    local worldButtons = self.viewsWorldButtons[self.activeTargetView]
    for i = 1, #worldButtons do
        worldButtons[i]:SetVisible(true)
    end
end


function GUIMenuCustomizeScreen:OnViewLabelActivation( activeViewLabel )
    
    if GetIsViewForTeam(activeViewLabel, kTeam1Index) then
        self.mainMarineTopBar:SetVisible(true)
        self.marinesViewButton:SetVisible(false)

        self.aliensViewButton:SetVisible(true)
        self.mainAlienBottomBar:SetVisible(false)
    elseif GetIsViewForTeam(activeViewLabel, kTeam2Index) then
        self.mainMarineTopBar:SetVisible(false)
        self.marinesViewButton:SetVisible(true)

        self.aliensViewButton:SetVisible(false)
        self.mainAlienBottomBar:SetVisible(true)
    end

    self:ToggleViewElements()

    --Ensure buttons are always present for default views (hackaround)
    if GetIsDefaultView( activeViewLabel ) then
        self.aliensViewButton:SetVisible( GetViewTeamIndex(activeViewLabel) == kTeam1Index )
        self.marinesViewButton:SetVisible( GetViewTeamIndex(activeViewLabel) == kTeam2Index )
        self.globalBackButton:SetVisible(false)
    else
        self.globalBackButton:SetVisible(true)
        self.aliensViewButton:SetVisible(false)
        self.marinesViewButton:SetVisible(false)
    end

end

function GUIMenuCustomizeScreen:HideViewWorldElements() --FIXME Change to IterDict?
    for k, v in pairs(self.viewsWorldButtons) do
        for i = 1, #v do
            self.viewsWorldButtons[k][i]:SetVisible(false)
        end
    end
end

local changeViewInterv = 0.2 --FIXME This is a bit janky
function GUIMenuCustomizeScreen:SetDesiredActiveView( viewLabel )
    assert(viewLabel)

    local time = Shared.GetTime()
    local isTeamChanging = GetViewTeamIndex(self.activeTargetView) ~= GetViewTeamIndex(viewLabel) --FIXME This is not setting true/false 100% of the time
    --Log("\t isTeamChanging: %s", isTeamChanging)

    if self.activeTargetView == viewLabel and self.timeTargetViewChange + changeViewInterv < time then

        if GetIsViewForTeam(viewLabel, kTeam1Index) then
            viewLabel = gCustomizeSceneData.kViewLabels.DefaultMarineView
        else
            viewLabel = gCustomizeSceneData.kViewLabels.DefaultAlienView
        end

    end

    self.previousTargetView = self.activeTargetView
    self.activeTargetView = viewLabel
    self.timeTargetViewChange = Shared.GetTime()

    self:HideViewWorldElements()

    GetCustomizeScene():TransitionToView(viewLabel, isTeamChanging)

end

function GUIMenuCustomizeScreen:RefreshOwnedItems()
    GetCustomizeScene():RefreshOwnedItems()
end

function GUIMenuCustomizeScreen:Uninitialize()
    self.renderTexture = nil
    GetCustomizeScene():Destroy()
    GUIMenuScreen.Uninitialize(self)
end

function GUIMenuCustomizeScreen:UpdateExclusionStencilSize()
    local size = self.background:GetSize()
    local pos = GetStaticScreenPosition(self.background)
    local abss = self.background:GetAbsoluteScale()
    local dim = pos + size * abss
    Client.SetMainCameraExclusionRect( pos.x, pos.y, dim.x, dim.y )
end

function GUIMenuCustomizeScreen:Display(immediate)

    if not GUIMenuScreen.Display(self, immediate) then
        return -- already being displayed!
    end

    self.customizeActive = true
    GetCustomizeScene():ClearTransitions( self.activeTargetView )
    GetCustomizeScene():SetActive( self.customizeActive )

    self:UpdateExclusionStencilSize()
    Client.SetMainCameraExclusionRectEnabled(true)

end

function GUIMenuCustomizeScreen:Hide()
    
    if not GUIMenuScreen.Hide(self) then
        return
    end

    self.customizeActive = false
    GetCustomizeScene():SetActive(self.customizeActive)

    Client.SetMainCameraExclusionRectEnabled(false)
end

function GUIMenuCustomizeScreen:OnUpdate(deltaTime, time)

    GetCustomizeScene():OnUpdate(time, deltaTime)

end

