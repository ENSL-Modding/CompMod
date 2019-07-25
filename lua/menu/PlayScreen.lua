-- ======= Copyright (c) 2017, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\menu\PlayScreen.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    The screen that appears when you click "play" in the main menu.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUIScript.lua")

Script.Load("lua/menu/FancyButton.lua")
Script.Load("lua/menu/FancyPlainText.lua")
Script.Load("lua/menu/FancyText.lua")
Script.Load("lua/menu/FancyImage.lua")
Script.Load("lua/menu/FancyClickableBox.lua")
Script.Load("lua/menu/FancyClickablePolygon.lua")

class 'PlayScreen' (GUIScript)

-- Anchored to top, stretched across width of screen
local kUILines1Texture = PrecacheAsset("ui/menu/play_menu/ui_lines_1.dds")
local kUILines1Pos = Vector(0, 31, 0)
local kUILines1Size = Vector(1920, 71, 0)

-- Anchored to bottom left corner of screen, stretch factor from horizontal.
local kUILines2Texture = PrecacheAsset("ui/menu/play_menu/ui_lines_2.dds")
local kUILines2Pos = Vector(0, 965, 0)
local kUILines2Size = Vector(620, 60, 0)

-- Anchored to bottom right corner of screen, stretch factor from horizontal.
local kUILines3Texture = PrecacheAsset("ui/menu/play_menu/ui_lines_3.dds")
local kUILines3Pos = Vector(1280, 1006, 0)
local kUILines3Size = Vector(640, 18, 0)

-- Anchored to bottom center, stretch factor from vertical.
local kTextBoxTexture  = PrecacheAsset("ui/menu/play_menu/text_box.dds")
local kTextBoxTextColor = Color(140/255, 198/255, 225/255, 1.0)
local kTextBoxTextFont = Fonts.kAgencyFB_Large
local kTextBoxPos = Vector(626, 938, 0)
local kTextBoxSize = Vector(664, 121, 0)

-- kAgencyFB_Large has 5px padding on each side, so we have to add 10 to every measurement from PS.
local kTextBoxTextSize = 38 -- px measured @ 1080p.  = 28px + 5px padding on each side.

local kScanlinesShader = "shaders/GUIPlayMenuScanLines.surface_shader"
local kScanlinesShaderMult = "shaders/GUIPlayMenuScanLinesMult.surface_shader"
local kRolloverShader = "shaders/GUIPlayMenuRollover.surface_shader"
local kScanlinesOverColor = Color(130/255, 230/255, 1, 0.0625)
local kScanlinesGreyColor = Color(130/255, 230/255, 1, 1.0)

local kPlainTextOverColor = Color(56/255, 239/255, 1.0, 1.0)
local kPlainTextColor = Color(140/255, 198/255, 225/255, 1)
local kPlainTextAlternateColor = Color(79/255, 127/255, 149/255, 1.0) -- for additional lines

local kTextureQuickPlayOver = PrecacheAsset("ui/menu/play_menu/quick_play_over.dds")
local kTextureQuickPlayGrey = PrecacheAsset("ui/menu/play_menu/quick_play_grey.dds")
local kTextureTrainingOver = PrecacheAsset("ui/menu/play_menu/training_over.dds")
local kTextureTrainingGrey = PrecacheAsset("ui/menu/play_menu/training_grey.dds")
local kTextureArcadeOver = PrecacheAsset("ui/menu/play_menu/arcade_over.dds")
local kTextureArcadeGrey = PrecacheAsset("ui/menu/play_menu/arcade_grey.dds")
local kTextureServerBrowserOver = PrecacheAsset("ui/menu/play_menu/server_browser_over.dds")
local kTextureServerBrowserGrey = PrecacheAsset("ui/menu/play_menu/server_browser_grey.dds")
local kTextureBackArrows = PrecacheAsset("ui/menu/play_menu/back_arrows.dds")

local kTextureBackButtonShading = PrecacheAsset("ui/menu/play_menu/back_shadow.dds")
local kBackBackgroundSourceSize = Vector(128, 128, 0)
local kBackBackgroundSize = Vector(460, 289, 0)

PlayScreen.kRecognizedButtonStates = {"grey", "over"}

PlayScreen.kButtonData = 
{
    {
        name            = "quickplay",
        position        = Vector(434, 159, 0),
        resize          = "best-fit-center",
        clickZone       =
        {
            zoneType        = "polygon",
            zonePts         =
            {
                -- pixel coordinates
                Vector(0,0,0),
                Vector(0, 391, 0),
                Vector(1049, 391, 0),
                Vector(1049, 30, 0),
                Vector(596, 30, 0),
                Vector(546, 0, 0),
            }
        },
        
        states  =
        {
            over                =
            {
                -- rollover flash
                { image = {
                        texture         = kTextureQuickPlayOver,
                        dimensions      = Vector(1169, 511, 0),
                        anchorPoint     = Vector(60, 60, 0), -- the upper-left corner of where true 0,0 should be.
                        position        = Vector(0, 0, 0), -- coordinates of the anchor point, relative to parent.
                        
                        shader          = kRolloverShader,
                        blendMode       = "add",
                        layer           = 9,
                        eventShaderInputs =
                        {
                            { event = "mouseOver", shaderInput = "overTime" },
                        },
                    },
                },
                
                -- scanlines
                { image = {
                        texture         = kTextureQuickPlayOver,
                        dimensions      = Vector(1169, 511, 0),
                        anchorPoint     = Vector(60, 60, 0), -- the upper-left corner of where true 0,0 should be.
                        position        = Vector(0, 0, 0), -- coordinates of the anchor point, relative to parent.
                        
                        shader          = kScanlinesShader,
                        blendMode       = "add",
                        color           = kScanlinesOverColor,
                        layer           = 8,
                    },
                },
                
                -- text that has a shader applied to it
                { fancyText = {
                        preferredFont       = Fonts.kMicrogrammaDBolExt_Huge,
                        fallbackFont        = Fonts.kArial_Medium,
                        -- constrain height, and just have a maximum width.
                        desiredHeight       = 60,
                        translateStr        = "PLAY_MENU_QUICK_PLAY",
                        anchorPoint         = "top",
                        padding             = Vector(20, 20, 0),
                        layer               = 7,
                        position            = Vector(526, 292, 0), -- position relative to parent, in this case, the button.
                        shaderSetup         =
                        { -- list of "nodes".  Connections are dependent upon the names matching up.
                            
                            {   -- text-layer
                                source = "text", -- "text" is like a reserved word, not an actual texture name.
                                output = "*quickPlayText", -- output texture name
                            },
                            
                            {
                                source = "*quickPlayText",
                                shader = "shaders/GUIPlayMenuBlur.surface_shader",
                                output = "*quickPlayTextBlurH",
                                extraInputs = 
                                {
                                    { "blurRadius", 13 },
                                    { "xFactor", 1},
                                    { "yFactor", 0},
                                }
                            },
                            
                            {
                                source = "*quickPlayTextBlurH",
                                shader = "shaders/GUIPlayMenuBlur.surface_shader",
                                output = "*quickPlayTextBlurV",
                                extraInputs = 
                                {
                                    { "blurRadius", 13 },
                                    { "xFactor", 0},
                                    { "yFactor", 1},
                                }
                            },
                            
                            {   -- effects layer
                                source = "*quickPlayText", -- input texture name (assigned to baseTexture)
                                shader = "shaders/GUIPlayMenuTextGlow.surface_shader", 
                                output = "*quickPlayTextFinalOutput",
                                
                                extraInputs = -- can specify either a float value, or a texture path.
                                {
                                    { "glowMap", "*quickPlayTextBlurV" },
                                }
                                
                            },
                            
                        },
                    },
                },
                
                { image = {
                        texture         = kTextureQuickPlayOver,
                        dimensions      = Vector(1169, 511, 0),
                        anchorPoint     = Vector(60, 60, 0), -- the upper-left corner of where true 0,0 should be.
                        position        = Vector(0, 0, 0), -- coordinates of the anchor point, relative to parent.
                        layer           = 6,
                    },
                },
            },
            
            grey                =
            {
                -- scanlines
                { image = {
                        texture         = kTextureQuickPlayGrey,
                        dimensions      = Vector(1065, 416, 0),
                        anchorPoint     = Vector(8, 0, 0), -- the upper-left corner of where true 0,0 should be.
                        position        = Vector(0, 0, 0), -- coordinates of the anchor point, relative to parent.
                        
                        shader          = kScanlinesShaderMult,
                        blendMode       = "multiply",
                        color           = kScanlinesGreyColor,
                        layer           = 8,
                    },
                },
                
                -- simple text with just a solid color.
                { text = {
                        preferredFont       = Fonts.kMicrogrammaDBolExt_Huge,
                        fallbackFont        = Fonts.kArial_Medium,
                        desiredHeight       = 60,
                        translateStr        = "PLAY_MENU_QUICK_PLAY",
                        anchorPoint         = "top", -- origin of this text is in the center of its top edge.
                        position            = Vector(526, 292, 0), -- position relative to parent.
                        color               = kPlainTextColor,
                        layer               = 7,
                    },
                },
                
                { image = {
                        texture         = kTextureQuickPlayGrey,
                        dimensions      = Vector(1065, 416, 0),
                        anchorPoint     = Vector(8, 0, 0),
                        position        = Vector(0, 0, 0),
                        layer           = 6,
                    },
                },
            },
        },
    },
    
    {
        name            = "serverbrowser",
        position        = Vector(105, 608, 0),
        resize          = "best-fit-center",
        clickZone       =
        {
            zoneType        = "polygon",
            zonePts         =
            {
                -- pixel coordinates
                Vector(0, 0, 0),
                Vector(0, 275, 0),
                Vector(306, 275, 0),
                Vector(340, 307, 0),
                Vector(529, 307, 0),
                Vector(529, 0, 0),
            },
        },
        
        states  =
        {
            over                =
            {
                -- rollover flash
                { image = {
                        texture         = kTextureTrainingOver,
                        dimensions      = Vector(650, 428, 0),
                        anchorPoint     = Vector(60, 60, 0), -- the upper-left corner of where true 0,0 should be.
                        position        = Vector(0, 0, 0), -- coordinates of the anchor point, relative to parent.
                        
                        shader          = kRolloverShader,
                        blendMode       = "add",
                        layer           = 9,
                        eventShaderInputs =
                        {
                            { event = "mouseOver", shaderInput = "overTime" },
                        },
                    },
                },
                
                -- scanlines
                { image = {
                        texture         = kTextureTrainingOver,
                        dimensions      = Vector(650, 428, 0),
                        anchorPoint     = Vector(60, 60, 0), -- the upper-left corner of where true 0,0 should be.
                        position        = Vector(0, 0, 0), -- coordinates of the anchor point, relative to parent.
                        
                        shader          = kScanlinesShader,
                        blendMode       = "add",
                        color           = kScanlinesOverColor,
                        layer           = 8,
                    },
                },
                
                { text = {
                        preferredFont       = Fonts.kMicrogrammaDBolExt_Huge,
                        fallbackFont        = Fonts.kArial_Medium,
                        -- constrain height, and just have a maximum width.
                        desiredHeight       = 40,
                        translateStr        = "PLAY_MENU_SERVER_BROWSER_LINE_1",
                        anchorPoint         = "top-left", -- origin of this text is at its left edge, at the top.
                        position            = Vector(16, 149, 0), -- position relative to parent, in this case, the button.
                        color               = kPlainTextOverColor,
                        layer               = 7,
                    },
                },
                
                { text = {
                        preferredFont       = Fonts.kMicrogrammaDBolExt_Huge,
                        fallbackFont        = Fonts.kArial_Medium,
                        -- constrain height, and just have a maximum width.
                        desiredHeight       = 40,
                        translateStr        = "PLAY_MENU_SERVER_BROWSER_LINE_2",
                        anchorPoint         = "top-left", -- origin of this text is at its left edge, at the top.
                        position            = Vector(16, 209, 0), -- position relative to parent, in this case, the button.
                        color               = kPlainTextOverColor,
                        layer               = 7,
                    },
                },
                
                { image = {
                        texture         = kTextureTrainingOver,
                        dimensions      = Vector(650, 428, 0),
                        anchorPoint     = Vector(60, 60, 0), -- the upper-left corner of where true 0,0 should be.
                        position        = Vector(0, 0, 0), -- coordinates of the anchor point, relative to parent.
                        layer           = 6,
                    },
                },
            },
            
            grey                =
            {
                -- scanlines
                { image = {
                        texture         = kTextureTrainingGrey,
                        dimensions      = Vector(548, 330, 0),
                        anchorPoint     = Vector(18, 0, 0),
                        position        = Vector(0, 0, 0),
                        
                        shader          = kScanlinesShaderMult,
                        blendMode       = "multiply",
                        color           = kScanlinesGreyColor,
                        layer           = 8,
                    },
                },
                
                -- simple text with just a solid color.
                { text = {
                        preferredFont       = Fonts.kMicrogrammaDBolExt_Huge,
                        fallbackFont        = Fonts.kArial_Medium,
                        desiredHeight       = 40,
                        translateStr        = "PLAY_MENU_SERVER_BROWSER_LINE_1",
                        anchorPoint         = "top-left",
                        position            = Vector(16, 149, 0), -- position relative to parent.
                        color               = kPlainTextAlternateColor,
                        layer               = 7,
                    },
                },
                
                { text = {
                        preferredFont       = Fonts.kMicrogrammaDBolExt_Huge,
                        fallbackFont        = Fonts.kArial_Medium,
                        desiredHeight       = 40,
                        translateStr        = "PLAY_MENU_SERVER_BROWSER_LINE_2",
                        anchorPoint         = "top-left",
                        position            = Vector(16, 209, 0), -- position relative to parent.
                        color               = kPlainTextColor,
                        layer               = 7,
                    },
                },
                
                { image = {
                        texture         = kTextureTrainingGrey,
                        dimensions      = Vector(548, 330, 0),
                        anchorPoint     = Vector(18, 0, 0),
                        position        = Vector(0, 0, 0),
                        layer           = 6,
                    },
                },
            },
        },
    },
    
    {
        name            = "arcade",
        position        = Vector(695, 608, 0),
        resize          = "best-fit-center",
        clickZone       =
        {
            zoneType        = "box",
            -- for now, we'll just assume the box's upper-left corner is the same as the parent button.
            zoneSize        = Vector(530, 308, 0)
        },
        
        states  =
        {
            over                =
            {
                -- rollover flash
                { image = {
                        texture         = kTextureArcadeOver,
                        dimensions      = Vector(650, 428, 0),
                        anchorPoint     = Vector(60, 60, 0), -- the upper-left corner of where true 0,0 should be.
                        position        = Vector(0, 0, 0), -- coordinates of the anchor point, relative to parent.
                        
                        shader          = kRolloverShader,
                        blendMode       = "add",
                        layer           = 9,
                        eventShaderInputs =
                        {
                            { event = "mouseOver", shaderInput = "overTime" },
                        },
                    },
                },
                
                -- scanlines
                { image = {
                        texture         = kTextureArcadeOver,
                        dimensions      = Vector(650, 428, 0),
                        anchorPoint     = Vector(60, 60, 0), -- the upper-left corner of where true 0,0 should be.
                        position        = Vector(0, 0, 0), -- coordinates of the anchor point, relative to parent.
                        
                        shader          = kScanlinesShader,
                        blendMode       = "add",
                        color           = kScanlinesOverColor,
                        layer           = 8,
                    },
                },
                
                { text = {
                        preferredFont       = Fonts.kMicrogrammaDBolExt_Huge,
                        fallbackFont        = Fonts.kArial_Medium,
                        -- constrain height, and just have a maximum width.
                        desiredHeight       = 48,
                        translateStr        = "PLAY_MENU_ARCADE",
                        anchorPoint         = "top",
                        position            = Vector(265, 225, 0),
                        color               = kPlainTextOverColor,
                        layer               = 7,
                    },
                },
                
                { image = {
                        texture         = kTextureArcadeOver,
                        dimensions      = Vector(650, 428, 0),
                        anchorPoint     = Vector(60, 60, 0), -- the upper-left corner of where true 0,0 should be.
                        position        = Vector(0, 0, 0), -- coordinates of the anchor point, relative to parent.
                        layer           = 6,
                    },
                },
            },
            
            grey                =
            {
                -- scanlines
                { image = {
                        texture         = kTextureArcadeGrey,
                        dimensions      = Vector(546, 333, 0),
                        anchorPoint     = Vector(8, 0, 0),
                        position        = Vector(0, 0, 0),
                        
                        shader          = kScanlinesShaderMult,
                        blendMode       = "multiply",
                        color           = kScanlinesGreyColor,
                        layer           = 8,
                    },
                },
                
                -- simple text with just a solid color.
                { text = {
                        preferredFont       = Fonts.kMicrogrammaDBolExt_Huge,
                        fallbackFont        = Fonts.kArial_Medium,
                        desiredHeight       = 48,
                        translateStr        = "PLAY_MENU_ARCADE",
                        anchorPoint         = "top",
                        position            = Vector(265, 225, 0),
                        color               = kPlainTextColor,
                        layer               = 7,
                    },
                },
                
                { image = {
                        texture         = kTextureArcadeGrey,
                        dimensions      = Vector(546, 333, 0),
                        anchorPoint     = Vector(8, 0, 0),
                        position        = Vector(0, 0, 0),
                        layer           = 6,
                    },
                },
            },
        },
    },
    
    {
        name            = "training",
        position        = Vector(1285, 608, 0),
        resize          = "best-fit-center",
        clickZone       =
        {
            zoneType        = "polygon",
            zonePts         =
            {
                -- pixel coordinates
                Vector(0, 0, 0),
                Vector(0, 307, 0),
                Vector(190, 307, 0),
                Vector(225, 275, 0),
                Vector(529, 275, 0),
                Vector(529, 0, 0),
            },
        },
        
        states  =
        {
            over                =
            {
                -- rollover flash
                { image = {
                        texture         = kTextureServerBrowserOver,
                        dimensions      = Vector(650, 428, 0),
                        anchorPoint     = Vector(60, 60, 0), -- the upper-left corner of where true 0,0 should be.
                        position        = Vector(0, 0, 0), -- coordinates of the anchor point, relative to parent.
                        
                        shader          = kRolloverShader,
                        blendMode       = "add",
                        layer           = 9,
                        eventShaderInputs =
                        {
                            { event = "mouseOver", shaderInput = "overTime" },
                        },
                    },
                },
                
                -- scanlines
                { image = {
                        texture         = kTextureServerBrowserOver,
                        dimensions      = Vector(650, 428, 0),
                        anchorPoint     = Vector(60, 60, 0), -- the upper-left corner of where true 0,0 should be.
                        position        = Vector(0, 0, 0), -- coordinates of the anchor point, relative to parent.
                        
                        shader          = kScanlinesShader,
                        blendMode       = "add",
                        color           = kScanlinesOverColor,
                        layer           = 8,
                    },
                },
                
                -- Bottom line text
                { text = {
                        preferredFont       = Fonts.kMicrogrammaDBolExt_Huge,
                        fallbackFont        = Fonts.kArial_Medium,
                        -- constrain height, and just have a maximum width.
                        desiredHeight       = 40,
                        translateStr        = "PLAY_MENU_TRAINING",
                        anchorPoint         = "top-right",
                        position            = Vector(505, 209, 0), -- position relative to parent, in this case, the button.
                        color               = kPlainTextOverColor,
                        layer               = 7,
                    },
                },
                
                { image = {
                        texture         = kTextureServerBrowserOver,
                        dimensions      = Vector(650, 428, 0),
                        anchorPoint     = Vector(60, 60, 0), -- the upper-left corner of where true 0,0 should be.
                        position        = Vector(0, 0, 0), -- coordinates of the anchor point, relative to parent.
                        layer           = 6,
                    },
                },
            },
            
            grey                =
            {
                -- scanlines
                { image = {
                        texture         = kTextureServerBrowserGrey,
                        dimensions      = Vector(548, 330, 0),
                        anchorPoint     = Vector(17, 0, 0),
                        position        = Vector(0, 0, 0),
                        
                        shader          = kScanlinesShaderMult,
                        blendMode       = "multiply",
                        color           = kScanlinesGreyColor,
                        layer           = 8,
                    },
                },
                
                -- Bottom line text
                { text = {
                        preferredFont       = Fonts.kMicrogrammaDBolExt_Huge,
                        fallbackFont        = Fonts.kArial_Medium,
                        desiredHeight       = 40,
                        translateStr        = "PLAY_MENU_TRAINING",
                        anchorPoint         = "top-right",
                        position            = Vector(505, 209, 0), -- position relative to parent.
                        color               = kPlainTextColor,
                        layer               = 7,
                    },
                },
                
                { image = {
                        texture         = kTextureServerBrowserGrey,
                        dimensions      = Vector(548, 330, 0),
                        anchorPoint     = Vector(17, 0, 0),
                        position        = Vector(0, 0, 0),
                        layer           = 6,
                    },
                },
            },
        },
    },
    
    {
        name = "backbutton",
        position = Vector(46,28,0),
        resize          = "best-fit-top-left",
        clickZone = 
        {
            zoneType        = "box",
            -- for now, we'll just assume the box's upper-left corner is the same as the parent button.
            zoneSize        = Vector(308, 60, 0),
        },
        
        states  =
        {
            over =
            {
                { text = {
                        preferredFont       = Fonts.kAgencyFB_Huge,
                        desiredHeight       = 46,
                        translateStr        = "BACK",
                        anchorPoint         = "top-left",
                        position            = Vector(116, 6, 0),
                        color               = Color(1, 1, 1, 1.0),
                        layer               = 7,
                    },
                },
                
                { text = { -- shadow
                        preferredFont       = Fonts.kAgencyFB_Huge,
                        desiredHeight       = 46,
                        translateStr        = "BACK",
                        anchorPoint         = "top-left",
                        position            = Vector(118, 8, 0),
                        color               = Color(0, 0, 0, 0.5),
                        layer               = 6,
                    },
                },
                
                { image = {
                        texture             = kTextureBackArrows,
                        dimensions          = Vector(89, 40, 0),
                        anchorPoint         = Vector(0, 0, 0),
                        position            = Vector(10, 10, 0),
                        color               = Color(1, 1, 1, 1.0),
                        layer               = 5,
                    },
                },
                
                -- background darkness
                { image = {
                        texture             = kTextureBackButtonShading,
                        dimensions          = kBackBackgroundSize,
                        anchorPoint         = kBackBackgroundSize * 0.5,
                        position            = Vector(122, 35, 0),
                        color               = Color(1, 1, 1, 1),
                        layer               = 4,
                        
                        shader              = "shaders/GUIBasic.surface_shader",
                        blendMode           = "multiply"
                    },
                },
            },
            
            grey =
            {
                { text = {
                        preferredFont       = Fonts.kAgencyFB_Huge,
                        desiredHeight       = 46,
                        translateStr        = "BACK",
                        anchorPoint         = "top-left",
                        position            = Vector(116, 6, 0),
                        color               = Color(153/255, 200/255, 219/255, 1.0),
                        layer               = 7,
                    },
                },
                
                { text = { -- shadow
                        preferredFont       = Fonts.kAgencyFB_Huge,
                        desiredHeight       = 46,
                        translateStr        = "BACK",
                        anchorPoint         = "top-left",
                        position            = Vector(118, 8, 0),
                        color               = Color(0, 0, 0, 0.5),
                        layer               = 6,
                    },
                },
                
                { image = {
                        texture         = kTextureBackArrows,
                        dimensions      = Vector(89, 40, 0),
                        anchorPoint     = Vector(0, 0, 0),
                        position        = Vector(10, 10, 0),
                        color           = Color(153/255, 200/255, 219/255, 1.0),
                    },
                },
                
                -- background darkness
                { image = {
                        texture             = kTextureBackButtonShading,
                        dimensions          = kBackBackgroundSize,
                        anchorPoint         = kBackBackgroundSize * 0.5,
                        position            = Vector(122, 35, 0),
                        color               = Color(1, 1, 1, 1),
                        layer               = 4,
                        
                        shader              = "shaders/GUIBasic.surface_shader",
                        blendMode           = "multiply"
                    },
                },
            },
        },
    },
}

PlayScreen.kButtonNameToLocalString = 
{
    quickplay = "PLAY_MENU_QUICK_PLAY_DESCRIPTION",
    training = "PLAY_MENU_TRAINING_DESCRIPTION",
    arcade = "PLAY_MENU_ARCADE_DESCRIPTION",
    serverbrowser = "PLAY_MENU_SERVER_BROWSER_DESCRIPTION",
    backbutton = "PLAY_MENU_BACK_DESCRIPTION",
}

-- The speed that characters are "typed out" into the text box at the bottom of the screen.
PlayScreen.kCharactersPerSecond = 80

function PlayScreen:ReadClickable(buttonData)
    
    local zoneType = buttonData.clickZone.zoneType
    if not zoneType then
        Log("ERROR!  Clickable zone type not specified for button %s", buttonData.name)
        return
    elseif zoneType == "box" then
        local zoneSize = buttonData.clickZone.zoneSize
        if not zoneSize then
            Log("ERROR!  Clickable box zone type missing parameter 'zoneSize' for button %s", buttonData.name)
            return
        end
        --local clickable = FancyClickableBox()
        local clickable = GetGUIManager():CreateGUIScript("FancyClickableBox")
        clickable:Initialize()
        clickable:SetupBoxUpperLeft(Vector(0,0,0), buttonData.clickZone.zoneSize)
        return clickable
    elseif zoneType == "polygon" then
        local zonePts = buttonData.clickZone.zonePts
        if not zonePts or type(zonePts) ~= "table" or #zonePts < 3 then
            Log("ERROR!  Clickable polygon zone type parameter 'zonePts' missing or invalid for button %s.  Must provide at least 3 points in the form of a table of Vector objects.", buttonData.name)
            return
        end
        --local clickable = FancyClickablePolygon()
        local clickable = GetGUIManager():CreateGUIScript("FancyClickablePolygon")
        clickable:Initialize()
        clickable:SetupPolygon(zonePts)
        return clickable
    else
        Log("ERROR!  Clickable zone type specified for button %s is invalid (%s)", buttonData.name, zoneType)
        return
    end
    
    -- should never make it to here.
    assert(false)
    return
    
end

function PlayScreen:ReadElementCommon(element, button, buttonData, input, stateRoot)
    
    element:SetRelativePosition(input.position or Vector(0,0,0))
    element:SetLayer(input.layer or 6)
    
    stateRoot:AddChild(element)
    
end

function PlayScreen:ReadTextElementCommon(element, button, buttonData, input, stateRoot)
    
    element:SetText(input.translateStr)
    element:SetFont(input.preferredFont, input.fallbackFont)
    element:SetDesiredBox(input.desiredWidth, input.desiredHeight)
    element:SetPadding(input.padding) -- not always applicable, passing nil is okay.
    element:SetAnchorPointByName(input.anchorPoint)
    
end

function PlayScreen:ReadStateElementFancyText(button, buttonData, input, stateRoot)
    
    local newElement = FancyText()
    newElement:Initialize()
    
    self:ReadElementCommon(newElement, button, buttonData, input, stateRoot)
    self:ReadTextElementCommon(newElement, button, buttonData, input, stateRoot)
    
    newElement:SetupShaders(input.shaderSetup)
    
end

function PlayScreen:ReadStateElementImage(button, buttonData, input, stateRoot)
    
    local newElement = FancyImage()
    newElement:Initialize()
    
    self:ReadElementCommon(newElement, button, buttonData, input, stateRoot)
    newElement:SetImage(input.texture, input.dimensions, input.anchorPoint)
    
    -- passing nil is fine, it has a default shader.
    newElement:SetShader(input.shader)
    newElement:SetBlendMode(input.blendMode)
    
    if input.extraParams then
        for i=1, #input.extraParams do
            newElement:SetShaderParameter(input.extraParams[i])
        end
    end
    
    if input.eventShaderInputs then
        for i=1, #input.eventShaderInputs do
            local param = input.eventShaderInputs[i]
            button:SetupEventInput(param.event, param.shaderInput, newElement)
        end
    end
    
    newElement:SetColor(input.color or Color(1,1,1,1))
    
end

function PlayScreen:ReadStateElementText(button, buttonData, input, stateRoot)
    
    local newElement = FancyPlainText()
    newElement:Initialize()
    
    self:ReadElementCommon(newElement, button, buttonData, input, stateRoot)
    self:ReadTextElementCommon(newElement, button, buttonData, input, stateRoot)
    
    newElement:SetColor(input.color or Color(1,1,1,1))
    
end

function PlayScreen:ReadStateElement(button, buttonData, readElement, stateRoot, stateName)
    
    if readElement.fancyText then
        self:ReadStateElementFancyText(button, buttonData, readElement.fancyText, stateRoot)
    elseif readElement.image then
        self:ReadStateElementImage(button, buttonData, readElement.image, stateRoot)
    elseif readElement.text then
        self:ReadStateElementText(button, buttonData, readElement.text, stateRoot)
    else
        Log("ERROR!  Invalid type specified for button '%s' state '%s' (%s)", buttonData.name, stateName, readElement)
    end
    
end

function PlayScreen:ReadButtonStates(button, buttonData)
    
    local states = buttonData.states
    if not states then
        -- could be used to create invisible buttons?  idk...
        return
    end
    
    for i=1, #PlayScreen.kRecognizedButtonStates do
        local stateName = PlayScreen.kRecognizedButtonStates[i]
        local readState = states[stateName]
        if readState then
            local stateRoot = button:GetElementForState(stateName)
            for j=1, #readState do
                self:ReadStateElement(button, buttonData, readState[j], stateRoot, stateName)
            end
        end
    end
    
end

function PlayScreen:ReadButtonData(buttonData)
    
    local newButton = FancyButton()
    newButton:Initialize()
    
    local clickable = self:ReadClickable(buttonData)
    clickable:SetCallbackFunction(
        function(buttonAction)
            self:OnButtonAction(buttonData.name, buttonAction)
        end)
    newButton:SetClickable(clickable)
    
    self:ReadButtonStates(newButton, buttonData)
    
    newButton:SetRelativePosition(buttonData.position)
    newButton:SetResizeMethod(buttonData.resize)
    
    -- allow access by either name or index
    self.buttons[buttonData.name] = newButton
    self.buttons[#self.buttons + 1] = newButton
    
end

function PlayScreen:Initialize()
    
    self.buttons = {}
    local buttonData = PlayScreen.kButtonData
    for i=1, #buttonData do
        self:ReadButtonData(buttonData[i])
    end
    
    -- Create non-button graphical items
    self.uiLines1 = GUI.CreateItem()
    self.uiLines1:SetTexture(kUILines1Texture)
    
    self.uiLines2 = GUI.CreateItem()
    self.uiLines2:SetTexture(kUILines2Texture)
    
    self.uiLines3 = GUI.CreateItem()
    self.uiLines3:SetTexture(kUILines3Texture)
    
    self.textBoxBackground = GUI.CreateItem()
    self.textBoxBackground:SetTexture(kTextBoxTexture)
    self.textBoxBackground:SetLayer(6)
    
    self.textBoxText = GUI.CreateItem()
    self.textBoxText:SetOptionFlag(GUIItem.ManageRender)
    self.textBoxText:SetText("")
    self.textBoxText:SetFontName(kTextBoxTextFont)
    self.textBoxText:SetTextAlignmentX(GUIItem.Align_Center)
    self.textBoxText:SetTextAlignmentY(GUIItem.Align_Center)
    self.textBoxText:SetColor(kPlainTextColor)
    self.textBoxText:SetLayer(7)
    
    self.textBoxScanlines = GUI.CreateItem()
    self.textBoxScanlines:SetBlendTechnique(GUIItem.Add)
    self.textBoxScanlines:SetShader(kScanlinesShader)
    self.textBoxScanlines:SetTexture(kTextBoxTexture)
    self.textBoxScanlines:SetColor(kScanlinesOverColor)
    self.textBoxScanlines:SetLayer(8)
    
    self.currentText = ""
    self.textTypeDuration = 0
    
    self:SharedUpdate(0)

    self:Hide()

    self.isEnabled = true
    
    -- DEBUG
    -- self:CreateDebugTextures()
end

function PlayScreen:CreateDebugTextures()
    self.test1 = GUI.CreateItem()
    self.test1:SetTexture("*quickPlayText")
    self.test1:SetSize(Vector(256,256,0))
    self.test1:SetPosition(Vector(0,0,0))
    self.test1:SetIsVisible(gDebugFancyText or false)
    self.test1:SetLayer(40)

    self.test2 = GUI.CreateItem()
    self.test2:SetTexture("*quickPlayTextBlurH")
    self.test2:SetSize(Vector(256,256,0))
    self.test2:SetPosition(Vector(256,0,0))
    self.test2:SetIsVisible(gDebugFancyText or false)
    self.test2:SetLayer(40)

    self.test3 = GUI.CreateItem()
    self.test3:SetTexture("*quickPlayTextBlurV")
    self.test3:SetSize(Vector(256,256,0))
    self.test3:SetPosition(Vector(0,256,0))
    self.test3:SetIsVisible(gDebugFancyText or false)
    self.test3:SetLayer(40)

    self.test4 = GUI.CreateItem()
    self.test4:SetTexture("*quickPlayTextFinalOutput")
    self.test4:SetSize(Vector(256,256,0))
    self.test4:SetPosition(Vector(256,256,0))
    self.test4:SetIsVisible(gDebugFancyText or false)
    self.test4:SetLayer(40)

    gFancyTextDebugTextures = gFancyTextDebugTextures or {}
    gFancyTextDebugTextures.test1 = self.test1
    gFancyTextDebugTextures.test2 = self.test2
    gFancyTextDebugTextures.test3 = self.test3
    gFancyTextDebugTextures.test4 = self.test4
end

function PlayScreen:Uninitialize()
    
    for i=1, #self.buttons do
        self.buttons[i]:Destroy()
    end
    
    if self.uiLines1 then
        GUI.DestroyItem(self.uiLines1)
        self.uiLines1 = nil
    end
    
    if self.uiLines2 then
        GUI.DestroyItem(self.uiLines2)
        self.uiLines2 = nil
    end
    
    if self.uiLines3 then
        GUI.DestroyItem(self.uiLines3)
        self.uiLines3 = nil
    end
    
    if self.textBoxBackground then
        GUI.DestroyItem(self.textBoxBackground)
        self.textBoxBackground = nil
    end
    
    if self.textBoxText then
        GUI.DestroyItem(self.textBoxText)
        self.textBoxText = nil
    end
    
    if self.textBoxScanlines then
        GUI.DestroyItem(self.textBoxScanlines)
        self.textBoxScanlines = nil
    end
    
    for i=1, 4 do
        local name = "test"..i
        if self[name] then
            GUI.DestroyItem(self[name])
            self[name] = nil
        end
    end
    gFancyTextDebugTextures.test1 = nil
    gFancyTextDebugTextures.test2 = nil
    gFancyTextDebugTextures.test3 = nil
    gFancyTextDebugTextures.test4 = nil
    
end

function PlayScreen:GetTextForActiveButton()
    
    if not self.activeButton then
        return nil
    end
    
    return PlayScreen.kButtonNameToLocalString[self.activeButton] or ""
    
end

-- Have the text animate onto the screen, like it's being typed out.
function PlayScreen:UpdateTextBoxText(deltaTime)
    
    local rawText = self:GetTextForActiveButton()
    local newText
    if rawText then
        newText = Locale.ResolveString(rawText)
    else
        newText = ""
    end
    
    if newText ~= self.currentText then
        self.currentText = newText
        self.textTypeDuration = 0
    else
        self.textTypeDuration = self.textTypeDuration + deltaTime
    end
    
    local typeIndex = math.floor((self.textTypeDuration * PlayScreen.kCharactersPerSecond) + 0.5) + 1
    if typeIndex > #newText then
        self.textBoxText:SetText(newText)
    else
        self.textBoxText:SetText(string.sub(newText, 1, typeIndex))
    end
    
    -- size the font to fit.
    local height = Client.GetScreenHeight()
    local boxScale = height / 1080.0
    local desiredTextHeight = kTextBoxTextSize * boxScale
    local actualTextHeight = self.textBoxText:GetTextHeight("C") -- nice, tall character to measure.
    local fontScale = desiredTextHeight / actualTextHeight
    self.textBoxText:SetScale(Vector(fontScale,fontScale,0))
    
end

function PlayScreen:SharedUpdate(deltaTime)
    
    for i=1, #self.buttons do
        self.buttons[i]:Update(deltaTime)
    end
    
    -- scale graphical items to fit
    local width = Client.GetScreenWidth()
    local height = Client.GetScreenHeight()
    
    -- text box position and scale
    local boxScale = height / 1080.0
    local boxWidth = kTextBoxSize.x * boxScale
    local boxHeight = kTextBoxSize.y * boxScale
    self.textBoxBackground:SetSize(Vector(boxWidth, boxHeight, 1))
    self.textBoxBackground:SetPosition(Vector((width-boxWidth) * 0.5, kTextBoxPos.y * boxScale, 1))
    self.textBoxScanlines:SetSize(self.textBoxBackground:GetSize())
    self.textBoxScanlines:SetPosition(self.textBoxBackground:GetPosition())
    self.textBoxScanlines:SetFloatParameter("rcpFrameY", 1.0 / self.textBoxScanlines:GetSize().y)
    
    self:UpdateTextBoxText(deltaTime)
    self.textBoxText:SetPosition(Vector(width * 0.5, (kTextBoxPos.y * boxScale) + (boxHeight * 0.5)  , 1))
    
    -- ui line 1... scope it to keep it clean
    do
        local scaleFactor = width / 1920.0
        self.uiLines1:SetSize(Vector(width, kUILines1Size.y * scaleFactor, 1))
        self.uiLines1:SetPosition(Vector(0, kUILines1Pos.y * scaleFactor, 0))
    end
    
    do
        -- since ui lines 2 and 3 are drawn around the box, we need to take the box's size
        -- into account.
        local boxLeftEdge1080 = 960 - (kTextBoxSize.x * 0.5)
        local boxLeftEdgeActual = (width - boxWidth) * 0.5
        local scaleFactor = boxLeftEdgeActual / boxLeftEdge1080
        self.uiLines2:SetSize(Vector(kUILines2Size.x * scaleFactor, kUILines2Size.y * scaleFactor, 0))
        self.uiLines2:SetPosition(Vector(0, kUILines2Pos.y * (height / 1080), 0))
        
        local boxRightEdge1080 = 960 + (kTextBoxSize.x * 0.5)
        local boxRightEdgeActual = (width + boxWidth) * 0.5
        scaleFactor = boxRightEdgeActual / boxRightEdge1080
        self.uiLines3:SetSize(Vector(kUILines3Size.x * scaleFactor, kUILines3Size.y * scaleFactor, 0))
        self.uiLines3:SetPosition(Vector(width - (kUILines3Size.x * scaleFactor), kUILines3Pos.y * (height / 1080), 0))
    end
    
end

function PlayScreen:OnResolutionChanged()
    
    for i=1, #self.buttons do
        self.buttons[i]:OnResolutionChanged()
    end
    self:SharedUpdate(0)
    
end

function PlayScreen:Update(deltaTime)
    if not self.isVisibility then return end

    self:SharedUpdate(deltaTime)
    
end

function PlayScreen:SetIsEnabled(state)
    if self.isEnabled == state then return end

    self.isEnabled = state

    for i = 1, #self.buttons do
        if self.buttons[i]:GetClickable() then
            self.buttons[i]:GetClickable():SetIsEnabled(state)
        end
    end
end

function PlayScreen:GetIsVisible()
    return self.isVisibility
end

function PlayScreen:SetVisibility(state)

    self.isVisibility = state
    
    for i = 1, #self.buttons do
        self.buttons[i]:SetIsVisible(state)
    end
    
    self.uiLines1:SetIsVisible(state)
    self.uiLines2:SetIsVisible(state)
    self.uiLines3:SetIsVisible(state)
    self.textBoxBackground:SetIsVisible(state)
    self.textBoxScanlines:SetIsVisible(state)
    self.textBoxText:SetIsVisible(state)
    
end

function PlayScreen:Show()

    MainMenu_OnWindowOpen()
    
    self:SetVisibility(true)

    local mainMenu = GetGUIMainMenu()
    if mainMenu and not mainMenu:PlayNowUnlocked() then
        local function enable()
            self:SetIsEnabled(true)
        end

        if mainMenu:CreateTutorialNagWindow(enable) then
            self:SetIsEnabled(false)
        end
    end
    
end

function PlayScreen:Hide()

    MainMenu_OnWindowOpen()
    
    self:SetVisibility(false)
    
end

function PlayScreen:DoQuickPlayButton()

    local mainMenu = GetGUIMainMenu()
    mainMenu:DoQuickJoin()
    
end

function PlayScreen:DoTrainingButton()

    local mainMenu = GetGUIMainMenu()
    if not mainMenu.trainingWindow then
        mainMenu:CreateTrainingWindow()
    end

    mainMenu.trainingWindow:SetIsVisible(true)
    mainMenu.trainingWindow.playScreen = self

    self:Hide()
    mainMenu.windowToOpen = nil

end

function PlayScreen:DoArcadeButton()

    local mainMenu = GetGUIMainMenu()
    mainMenu.serverBrowserWindow:SetIsVisible(true)
    Matchmaking_JoinGlobalLobby()

    local browserTabs = mainMenu.serverTabs
    local selectedTab = browserTabs.lastGameTab
    browserTabs:SelectTabByName("MODDED")

    -- set the selected tab back to the previous selected one
    browserTabs.lastGameTab = selectedTab
    Client.SetOptionString("currentGameModeFilter", selectedTab.tabName)

    self:Hide()
    mainMenu.windowToOpen = nil
    
end

function PlayScreen:DoServerBrowserButton()

    local mainMenu = GetGUIMainMenu()
    mainMenu.serverBrowserWindow:SetIsVisible(true)
    Matchmaking_JoinGlobalLobby()

    -- activate the last selected server browser tab unless it's the arcade one then reset to the All tab
    local browserTabs = mainMenu.serverTabs
    local targetName = "All"
    if browserTabs.lastGameTab.tabName and browserTabs.lastGameTab.tabName ~= "MODDED" then
        targetName = browserTabs.lastGameTab.tabName
    end
    browserTabs:SelectTabByName( targetName)
    
    self:Hide()
    mainMenu.windowToOpen = nil
    
end

function PlayScreen:DoBackButton()

    local mainMenu = GetGUIMainMenu()

    --Stop and hide the quick play queue if it's running
    if mainMenu.playNowWindow and mainMenu.playNowWindow:GetIsVisible() then
        mainMenu.playNowWindow:SetIsVisible(false)
        return
    end

    self:Hide()
    mainMenu:ShowMenu()
end

function PlayScreen:ButtonClicked(buttonName)

    local mainMenu = GetGUIMainMenu()
    if mainMenu.playNowWindow and mainMenu.playNowWindow:GetIsVisible() then
        return
    end
    
    if buttonName == "quickplay" then
        self:DoQuickPlayButton()
    elseif buttonName == "training" then
        self:DoTrainingButton()
    elseif buttonName == "arcade" then
        self:DoArcadeButton()
    elseif buttonName == "serverbrowser" then
        self:DoServerBrowserButton()
    elseif buttonName == "backbutton" then
        self:DoBackButton()
    else
        -- Unknown button.
        Log("Unknown button clicked... yell at Beige, I guess...")
    end
    
    MainMenu_OnPlayButtonClicked()
    
end

function PlayScreen:OnButtonAction(buttonName, buttonAction)

    -- update button highlighting
    if buttonAction == "mouseOut" then
        if self.activeButton == buttonName then
            self.activeButton = nil
        end
    else
        self.activeButton = buttonName
    end
    
    -- handle button clicks
    if buttonAction == "mouse0Down" then
        self:ButtonClicked(buttonName)
    end
    
end

function PlayScreen:SendKeyEvent(key, down)

    if key == InputKey.Escape and down then
        if self.isVisibility and self.isEnabled then
            self:DoBackButton()
            return true
        else
            local mainMenu = GetGUIMainMenu()
            if not mainMenu then return end

            if mainMenu.playNowWindow and mainMenu.playNowWindow:GetIsVisible() then
                mainMenu.playNowWindow:SetIsVisible(false)
                return true
            elseif mainMenu.trainingWindow and mainMenu.trainingWindow.playScreen and mainMenu.trainingWindow:GetIsVisible() then
                mainMenu.trainingWindow:SetIsVisible(false)
                mainMenu.videoPlayer:Hide()

                mainMenu.showWindowAnimation:SetIsVisible(false)

                mainMenu:HideMenu()
                self:Show()

                mainMenu.trainingWindow.playScreen = nil

                return true
            elseif mainMenu.serverBrowserWindow and mainMenu.serverBrowserWindow:GetIsVisible() then
                mainMenu.playNowWindow:SetIsVisible(false)
                mainMenu.serverBrowserWindow:SetIsVisible(false)

                mainMenu.showWindowAnimation:SetIsVisible(false)

                Matchmaking_LeaveGlobalLobby()

                mainMenu:HideMenu()
                self:Show()

                return true
            end
        end
    end
end

-- precache all assets used in PlayScreen.kButtonData
local function TryToPrecacheTexture(textureName)
    if not textureName or string.sub(textureName, 1, 1) == "*" then
        return -- can't precache textures that are rendered by gui views.
    end
    
    PrecacheAsset(textureName)
end
for i=1, #PlayScreen.kButtonData do
    local states = PlayScreen.kButtonData[i]
    for j=1, #PlayScreen.kRecognizedButtonStates do
        local stateElements = states[PlayScreen.kRecognizedButtonStates[j]]
        if stateElements then
            local element = stateElements.fancyText or stateElements.image or stateElements.text
            if element then
                if element.preferredFont then
                    PrecacheAsset(element.preferredFont)
                end
                if element.fallbackFont then
                    PrecacheAsset(element.fallbackFont)
                end
                TryToPrecacheTexture(element.texture)
                local shaderSetup = element.shaderSetup
                if shaderSetup then
                    for k=1, #shaderSetup do
                        local node = shaderSetup[k]
                        if node.source ~= "text" then
                            TryToPrecacheTexture(node.source)
                        end
                        if node.shader then
                            PrecacheAsset(node.shader)
                        end
                        TryToPrecacheTexture(node.output)
                    end
                end
            end
        end
    end
end

-- DEBUG -- 
local function GetCanIndex(indexable, key)
    
    if pcall(function()
        local temp = indexable[key]
    end) then
        return true
    end
    
    return false
    
end

local function IsNumber(test)
    
    if pcall(function()
        local temp = tonumber(test)
    end)
        then
        return true
    end
    
    return false
    
end

local function GetIndex(entry)
    
    local openBracket = string.find(entry, "%[")
    if not openBracket then
        return nil
    end
    
    local closeBracket = string.find(entry, "%]")
    if not closeBracket or closeBracket <= openBracket + 1 then
        return nil
    end
    
    local plainEntry = string.sub(entry, 1, openBracket-1)
    local result = string.sub(entry, openBracket + 1, closeBracket - 1)
    -- convert to number if possible
    result = IsNumber(result) and tonumber(result) or result
    return result, plainEntry
    
end

local function GetFunctionCall(entry)
    
    if string.sub(entry, #entry-1, #entry) == "()" then
        local call = string.sub(entry, 1, #entry-2)
        if #call > 0 then
            return true, call
        end
    end
    
    return false, nil
    
end

local function OnCommandDebugPlayScreen(path)
    
    if MainMenu_IsInGame() then
        return
    end
    
    local pathEntries = Fancy_SplitStringIntoTable(path or "", "%.")
    local tbl = GetGUIMainMenu().playScreen
    local pathSoFar = "playScreen"
    for i=1, #pathEntries do
        local entry = pathEntries[i]
        
        if not GetCanIndex(tbl, entry) then
            Log("current location %s does not refer to a table!", pathSoFar)
            Log("    value is %s\n", tbl)
        else
            local index, plainEntry = GetIndex(entry)
            if index then
                tbl = tbl[plainEntry][index]
            else
                local isFunc, func = GetFunctionCall(entry)
                if isFunc then
                    entry = func
                end
                if tbl[entry] == nil then
                    Log("no table entry named \"%s\" found inside table %s", entry, pathSoFar)
                    return
                else
                    if isFunc then
                        tbl = tbl[entry](tbl) -- assume we pass self to it.
                    else
                        tbl = tbl[entry]
                    end
                end
            end
        end
        
        pathSoFar = pathSoFar .. "." .. entry .. (isFunc and "()" or "")
        
        if i==#pathEntries then
            Log("%s\n    %s", pathSoFar, tbl)
        end
    end
end
Event.Hook("Console_dps", OnCommandDebugPlayScreen)

local function OnCommandDebugFancyText()
    
    if not gFancyTextDebugTextures then
        return
    end
    
    gDebugFancyText = gDebugFancyText or false
    gDebugFancyText = not gDebugFancyText
    
    for _, item in pairs(gFancyTextDebugTextures) do
        item:SetIsVisible(gDebugFancyText)
    end
    
end
Event.Hook("Console_debugfancytext", OnCommandDebugFancyText)
-- END DEBUG --


