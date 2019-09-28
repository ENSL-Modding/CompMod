-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/MenuData.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    All menu-related content should be defined in this file.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

MenuData = {}
Script.Load("lua/menu2/MenuDataUtils.lua")


            --------------------------------
            -- MENU BACKGROUND CINEMATICS --
            --------------------------------

Script.Load("lua/menu2/MenuBackgrounds.lua")

            ---------------------------
            -- MENU BACKGROUND MUSIC --
            ---------------------------

MenuData.AddMenuMusic(
{
    name = "eclipseRemix",
    localeString = "MENU_MUSIC_ECLIPSE_REMIX",
    musicPath = "sound/NS2.fev/Eclipse Remix Menu",
})

MenuData.AddMenuMusic(
{
    name = "exo",
    localeString = "MENU_MUSIC_EXO",
    musicPath = "sound/NS2.fev/Exo (Original Music) Menu",
})

MenuData.AddMenuMusic(
{
    name = "beta",
    localeString = "MENU_MUSIC_BETA",
    musicPath = "sound/NS2.fev/Beta Menu",
})

MenuData.AddMenuMusic(
{
    name = "ns1",
    localeString = "MENU_MUSIC_NS1",
    musicPath = "sound/NS2.fev/NS1 Menu",
})

MenuData.AddMenuMusic(
{
    name = "frontiersmen",
    localeString = "MENU_MUSIC_FRONTIERSMEN",
    musicPath = "sound/NS2.fev/Frontiersmen Menu",
})


            ------------------------
            -- MENU CONFIGURATION --
            ------------------------

MenuData.Config = {}


            ------------------
            -- OPTIONS MENU --
            ------------------

MenuData.Config.OptionsMenu = {}


            --------------------------------
            -- OPTIONS MENU - GENERAL TAB --
            --------------------------------

MenuData.Config.OptionsMenu.General = MenuData.CreateDefaultOptionsLayout
{
    checksChildren =
    {
        -- SHOW HINTS
        {
            name = "showHints",
            class = OP_TT_Checkbox,
            params =
            {
                optionPath = "showHints",
                optionType = "bool",
                default = true,
                tooltip = Locale.ResolveString("OPTION_SHOW_HINTS"),
            },
            
            properties =
            {
                {"Label", Locale.ResolveString("SHOW_HINTS")},
            },
        },
        
        -- SHOW DAMAGE NUMBERS
        {
            name = "showDamageNumbers",
            class = OP_TT_Checkbox,
            params =
            {
                optionPath = "drawDamage",
                optionType = "bool",
                default = false,
                tooltip = Locale.ResolveString("OPTION_DRAW_DAMAGE"),
            },
            
            properties =
            {
                {"Label", Locale.ResolveString("DAMAGE_NUMBERS")},
            },
        },
        
        -- SHOW HEALTH BARS
        {
            name = "showHealthBars",
            class = OP_TT_Checkbox,
            params =
            {
                optionPath = "enemyHealth",
                optionType = "bool",
                default = true,
                tooltip = Locale.ResolveString("OPTION_ENEMY_HEALTH"),
            },
            
            properties =
            {
                {"Label", Locale.ResolveString("ENEMY_HEALTH_BARS")},
            },
        },
        
        -- PHYSICS MULTITHREADING
        {
            name = "physicsMultiThreading",
            class = OP_TT_Checkbox,
            params =
            {
                optionPath = "physicsMultithreading",
                optionType = "bool",
                default = false,
                tooltip = Locale.ResolveString("OPTION_PHYSICS_MULTITHREADING_TOOLTIP"),
            },
            
            properties =
            {
                {"Label", Locale.ResolveString("OPTION_PHYSICS_MULTITHREADING")},
            },
        },
    },
    
    regularChildren =
    {
        -- LANGUAGE
        {
            name = "language",
            class = OP_Choice,
            params =
            {
                optionPath = "locale",
                optionType = "string",
                default = "enUS",
                autoRestart = true, -- need to restart client to load selected language.
            },
            
            properties =
            {
                {"Label", Locale.ResolveString("LANGUAGE")..": "},
                {"Choices",
                    {
                        { value = "enUS", displayString = Locale.ResolveString("ENGLISH") },
                        { value = "bgBG", displayString = Locale.ResolveString("BULGARIAN") },
                        { value = "hrHR", displayString = Locale.ResolveString("CROATIAN") },
                        { value = "zhCN", displayString = Locale.ResolveString("CHINESE_SIMPLIFIED") },
                        { value = "zhTW", displayString = Locale.ResolveString("CHINESE_TRADITIONAL") },
                        { value = "csCS", displayString = Locale.ResolveString("CZECH") },
                        { value = "daDK", displayString = Locale.ResolveString("DANISH") },
                        { value = "nlNL", displayString = Locale.ResolveString("DUTCH") },
                        { value = "fiFI", displayString = Locale.ResolveString("FINNISH") },
                        { value = "frFR", displayString = Locale.ResolveString("FRENCH") },
                        { value = "deDE", displayString = Locale.ResolveString("GERMAN") },
                        { value = "itIT", displayString = Locale.ResolveString("ITALIAN") },
                        { value = "jaJA", displayString = Locale.ResolveString("JAPANESE") },
                        { value = "koKR", displayString = Locale.ResolveString("KOREAN") },
                        { value = "noNO", displayString = Locale.ResolveString("NORWEGIAN") },
                        { value = "plPL", displayString = Locale.ResolveString("POLISH") },
                        { value = "ptBR", displayString = Locale.ResolveString("PORTUGUESE") },
                        { value = "roRO", displayString = Locale.ResolveString("ROMANIAN") },
                        { value = "ruRU", displayString = Locale.ResolveString("RUSSIAN") },
                        { value = "rsRS", displayString = Locale.ResolveString("SERBIAN") },
                        { value = "esES", displayString = Locale.ResolveString("SPANISH") },
                        { value = "swSW", displayString = Locale.ResolveString("SWEDISH") },
                    },
                },
            },
        },
        
        -- NICKNAME (group of options)
        {
            name = "nicknameOptionGroup",
            class = GUIListLayout,
            params =
            {
                orientation = "vertical",
            },
            properties =
            {
                {"FrontPadding", 0},
                {"BackPadding", 0},
                {"Spacing", 32},
            },
            
            children =
            {
                -- USE STEAM PERSONA
                {
                    name = "useAlternateNickname",
                    class = OP_TT_Checkbox,
                    params =
                    {
                        optionPath = kNicknameOverrideKey,
                        optionType = "bool",
                        default = false,
                        tooltip = Locale.ResolveString("MENU_TOOLTIP_ALTERNATE_NICKNAME"),
                        alternateSetter =
                            function(value)
                                Client.SetOptionBoolean(kNicknameOverrideKey, value)
                                UpdatePlayerNicknameFromOptions()
                            end,
                        immediateUpdate =
                            function(self, value)
                                Client.SetOptionBoolean(kNicknameOverrideKey, value)
                                UpdatePlayerNicknameFromOptions()
                            end,
                    },
                    
                    properties =
                    {
                        {"Label", Locale.ResolveString("NS2NICKNAME")..": "},
                    },
                },
                
                -- NICKNAME
                {
                    name = "nickname",
                    class = OP_TT_Expandable_Text,
                    params =
                    {
                        optionPath = kNicknameOptionsKey,
                        optionType = "string",
                        default = "New Player",
                        
                        expansionMargin = 4, -- prevent outer stroke effect from being cropped away.
                        
                        tooltip = Locale.ResolveString("MENU_TOOLTIP_ALTERNATE_NICKNAME"),
                    },
                    
                    properties =
                    {
                        {"Label", Locale.ResolveString("NICKNAME")..": "},
                        {"MaxCharacterCount", 20},
                    },
                    
                    postInit =
                    {
                        -- Handle expansion.
                        function(self)
                            self:HookEvent(GetOptionsMenu():GetOptionWidget("useAlternateNickname"), "OnValueChanged",
                            function(self, value)
                                self:SetExpanded(value)
                            end)
                            self:SetExpanded(GetOptionsMenu():GetOptionWidget("useAlternateNickname"):GetValue())
                        end,
                        
                        -- Inform the GUILocalPlayerProfileData whenever there is a change to the player name.
                        function(self)
                            GetLocalPlayerProfileData():HookEvent(self, "OnValueChanged", GetLocalPlayerProfileData().SetPlayerName)
                        end,
                        
                        -- Update nickname when editing changes.
                        function(self)
                            self:HookEvent(self, "OnEditEnd", function(self2)
                                SetNickName(self2:GetValue())
                            end)
                        end
                    },
                },
            },
        },
        
        -- FOV ADJUST
        {
            name = "fovAdjust",
            class = OP_TT_Number,
            params =
            {
                optionPath = "fov-adjustment",
                optionType = "float",
                
                -- Migrate previous option, if found.  This option should be stored as part of the user's
                -- preferences, not the system configuration -- FOV is a question of taste -- nothing to do
                -- with system capabilities.
                default = Client.GetOptionFloat("graphics/display/fov-adjustment", 0) * 20,
                
                immediateUpdate = function(self)
                    local value = self:GetValue()
                    if Client and Client.SetFOVAdjustment then
                        Client.SetFOVAdjustment(value)
                    end
                end,
                
                minValue = 0,
                maxValue = 20,
                decimalPlaces = 1,
                
                tooltip = Locale.ResolveString("FOV_ADJUSTMENT_TOOLTIP"),
            },
            
            properties =
            {
                {"Label", Locale.ResolveString("FOV_ADJUSTMENT")..": "},
            },
        },
        
        -- MINIMAP ZOOM
        {
            name = "minimapZoom",
            class = OP_TT_Number,
            params =
            {
                optionPath = "minimap-zoom",
                optionType = "float",
                default = 0.75,
                
                immediateUpdate = function(self)
                    local oldValue = Client.GetOptionFloat("minimap-zoom", 0.75)
                    local value = self:GetValue()
                    Client.SetOptionFloat("minimap-zoom", value)
                    if SafeRefreshMinimapZoom then SafeRefreshMinimapZoom() end
                    Client.SetOptionFloat("minimap-zoom", oldValue)
                end,
                
                minValue = 0,
                maxValue = 1,
                decimalPlaces = 2,
                
                tooltip = Locale.ResolveString("MINIMAP_ZOOM_TOOLTIP"),
            },
            
            properties =
            {
                {"Label", Locale.ResolveString("MINIMAP_ZOOM")..": "},
            },
        },
        
        -- HUD DETAIL
        {
            name = "hudDetail",
            class = OP_TT_Choice,
            params =
            {
                optionPath = "hudmode",
                optionType = "int",
                default = 1,
                
                immediateUpdate = function(self)
                    if Client and Client.SetHudDetail then
                        Client.SetHudDetail(self:GetValue())
                    end
                end,
                
                tooltip = Locale.ResolveString("HUD_DETAIL_TOOLTIP"),
            },
            
            properties =
            {
                {"Label", Locale.ResolveString("HUD_DETAIL")..": "},
                {"Choices",
                    {
                        { value = 1, displayString = Locale.ResolveString("HIGH") },
                        { value = 2, displayString = Locale.ResolveString("LOW") },
                    }
                },
            },
        },
        
        -- MENU BACKGROUND
        {
            name = "menuBackground",
            class = OP_Choice,
            params = 
            {
                -- Not going to bother migrating this option.  Menu background options are now string values.
                optionPath = "menu/menuBackgroundName",
                optionType = "string",
                default = "default",
                autoRestart = true,
            },
            
            properties = 
            {
                {"Label", Locale.ResolveString("MENU_BACKGROUND")..": "},
                {"Choices", MenuBackgrounds.GetMenuBackgroundChoices()},
            },
        },
        
        -- MENU MUSIC
        {
            name = "menuMusic",
            class = OP_Choice,
            params =
            {
                -- Not going to bother migrating this option.  Menu music options are now string values.
                optionPath = "menu/menuMusicName",
                optionType = "string",
                default = "random",
                autoRestart = true,
            },
            
            properties =
            {
                {"Label", Locale.ResolveString("MENU_MUSIC")..": "},
                {"Choices", MenuData.GetMenuMusicChoices()},
            },
        },
        
        -- RESOURCE LOADING
        {
            name = "resourceLoading",
            class = OP_TT_Choice,
            params =
            {
                optionPath = "system/resourceLoading",
                optionType = "int",
                default = 1,
                
                tooltip = Locale.ResolveString("OPTION_RESOURCE_LOADING_TOOLTIP"),
            },
            
            properties =
            {
                {"Label", Locale.ResolveString("OPTION_RESOURCE_LOADING")..": "},
                {"Choices",
                    {
                        { value = 1, displayString = Locale.ResolveString("LOW") },
                        { value = 2, displayString = Locale.ResolveString("MEDIUM") },
                        { value = 3, displayString = Locale.ResolveString("HIGH") },
                    },
                },
            },
        },
    },
}


            ---------------------------------
            -- OPTIONS MENU - CONTROLS TAB --
            ---------------------------------

MenuData.Config.OptionsMenu.Controls = MenuData.CreateControlsLayout
{
    -- Controls menu is split into two halves: regular controls, and commander controls.
    
    -- REGULAR CONTROLS
    leftChildren =
    {
        { -- FIELD PLAYER BINDINGS Header
            name = "bindingsDivider",
            class = GUIMenuDividerWidget,
            params =
            {
                font = MenuStyle.kOptionGroupHeadingFont,
            },
            properties =
            {
                {"Label", Locale.ResolveString("FIELD_PLAYER_BINDINGS")},
            },
            postInit = function(self) self:AlignTop() end,
        },
        
        { -- INVERT MOUSE
            name = "invertMouse",
            class = OP_TT_Checkbox,
            params =
            {
                optionPath = "input/mouse/invert",
                optionType = "bool",
                default = false,
                
                tooltip = Locale.ResolveString("INVERT_MOUSE_TOOLTIP"),
            },
            
            properties =
            {
                {"Label", Locale.ResolveString("INVERT_MOUSE")},
            },
        },
        
        { -- MOUSE SENSITIVITY
            name = "mouseSensitivity",
            class = OP_Number,
            params =
            {
                alternateSetter = MenuData.SetMouseSensitivity,
                alternateGetter = MenuData.GetMouseSensitivity,
                
                minValue = 0.01,
                maxValue = 20.0,
                decimalPlaces = 2,
            },
            
            properties =
            {
                {"Label", Locale.ResolveString("MOUSE_SENSITIVITY")},
            },
        },
        
        { -- MOUSE ACCELERATION ENABLED/DISABLED
            name = "mouseAcceleration",
            class = OP_TT_Checkbox,
            params =
            {
                optionPath = "input/mouse/acceleration",
                optionType = "bool",
                default = false,
                
                immediateUpdate = function(self)
                    local oldValue = Client.GetOptionBoolean("input/mouse/acceleration", false)
                    local value = self:GetValue()
                    Client.SetOptionBoolean("input/mouse/acceleration", value)
                    Input_SyncInputOptions()
                    Client.SetOptionBoolean("input/mouse/acceleration", oldValue)
                end,
                
                tooltip = Locale.ResolveString("MOUSE_ACCELERATION_TOOLTIP"),
            },
            
            properties =
            {
                {"Label", Locale.ResolveString("MOUSE_ACCELERATION")},
            },
        },
        
        { -- MOUSE ACCELERATION AMOUNT
            name = "accelerationAmount",
            class = OP_TT_Expandable_Number,
            params =
            {
                optionPath = "input/mouse/acceleration-amount",
                optionType = "float",
                default = 1.0,
                
                immediateUpdate = function(self)
                    local oldValue = Client.GetOptionFloat("input/mouse/acceleration-amount", 1.0)
                    local value = self:GetValue()
                    Client.SetOptionFloat("input/mouse/acceleration-amount", value)
                    Input_SyncInputOptions()
                    Client.SetOptionFloat("input/mouse/acceleration-amount", oldValue)
                end,
                
                minValue = 1,
                maxValue = 1.4,
                decimalPlaces = 2,
                
                expansionMargin = 4, -- prevent outer stroke effect from being cropped away.
                
                tooltip = Locale.ResolveString("ACCELERATION_AMOUNT_TOOLTIP"),
            },
            
            properties =
            {
                {"Label", Locale.ResolveString("ACCELERATION_AMOUNT")},
            },
            
            postInit =
            {
                function(self)
                    self:HookEvent(GetOptionsMenu():GetOptionWidget("mouseAcceleration"), "OnValueChanged",
                    function(self, value)
                        self:SetExpanded(value)
                    end)
                    self:SetExpanded(GetOptionsMenu():GetOptionWidget("mouseAcceleration"):GetValue())
                end,
            },
        },
        
        { -- BINDINGS DIVIDER
            name = "bindingsDivider",
            class = GUIMenuDividerWidget,
            properties =
            {
                {"Label", Locale.ResolveString("BINDINGS")},
            },
        },
        
        -- MOVEMENT GROUP
        MenuData.CreateExpandableKeybindGroup
        {
            name = "movementGroup",
            label = "MOVEMENT",
            params =
            {
                open = true, -- default this group to open so it looks less empty on this side.
            },
            children =
            {
                { -- MOVE FORWARD
                    name = "moveForward",
                    class = OP_Keybind,
                    params =
                    {
                        optionPath = "input/MoveForward",
                        optionType = "string",
                        default = "W",
                        
                        bindGroup = "general",
                    },
                    properties =
                    {
                        {"Label", Locale.ResolveString("BINDINGS_MOVE_FORWARD")},
                    },
                },
                
                { -- STRAFE LEFT
                    name = "moveLeft",
                    class = OP_Keybind,
                    params =
                    {
                        optionPath = "input/MoveLeft",
                        optionType = "string",
                        default = "A",
                        
                        bindGroup = "general",
                    },
                    properties =
                    {
                        {"Label", Locale.ResolveString("BINDINGS_MOVE_LEFT")},
                    },
                },
                
                { -- MOVE BACKWARD
                    name = "moveBackward",
                    class = OP_Keybind,
                    params =
                    {
                        optionPath = "input/MoveBackward",
                        optionType = "string",
                        default = "S",
                        
                        bindGroup = "general",
                    },
                    properties =
                    {
                        {"Label", Locale.ResolveString("BINDINGS_MOVE_BACKWARD")},
                    },
                },
                
                { -- STRAFE RIGHT
                    name = "moveRight",
                    class = OP_Keybind,
                    params =
                    {
                        optionPath = "input/MoveRight",
                        optionType = "string",
                        default = "D",
                        
                        bindGroup = "general",
                    },
                    properties =
                    {
                        {"Label", Locale.ResolveString("BINDINGS_MOVE_RIGHT")},
                    },
                },
                
                { -- JUMP
                    name = "jump",
                    class = OP_Keybind,
                    params =
                    {
                        optionPath = "input/Jump",
                        optionType = "string",
                        default = "Space",
                        
                        bindGroup = "general",
                    },
                    properties =
                    {
                        {"Label", Locale.ResolveString("BINDINGS_JUMP")},
                    },
                },
                
                { -- MOVE SPECIAL
                    name = "moveSpecial",
                    class = OP_TT_Keybind,
                    params =
                    {
                        optionPath = "input/MovementModifier",
                        optionType = "string",
                        default = "LeftShift",
                        
                        bindGroup = "general",
                        
                        tooltip = Locale.ResolveString("BINDINGS_MOVEMENT_SPECIAL_TOOLTIP"),
                    },
                    properties =
                    {
                        {"Label", Locale.ResolveString("BINDINGS_MOVEMENT_SPECIAL")},
                    },
                },
                
                { -- CROUCH
                    name = "crouch",
                    class = OP_Keybind,
                    params =
                    {
                        optionPath = "input/Crouch",
                        optionType = "string",
                        default = "LeftControl",
                        
                        bindGroup = "general",
                    },
                    properties =
                    {
                        {"Label", Locale.ResolveString("BINDINGS_CROUCH")},
                    },
                },
            },
        },
        
        -- COMBAT & INTERACTION GROUP
        MenuData.CreateExpandableKeybindGroup
        {
            name = "combatAndInteractionGroup",
            label = "COMBAT_AND_INTERACTION",
            children =
            {
                { -- PRIMARY ATTACK
                    name = "primaryAttack",
                    class = OP_Keybind,
                    params =
                    {
                        optionPath = "input/PrimaryAttack",
                        optionType = "string",
                        default = "MouseButton0",
                        
                        bindGroup = "general",
                    },
                    properties =
                    {
                        {"Label", Locale.ResolveString("BINDINGS_PRIMARY_ATTACK")},
                    },
                },
                
                { -- SECONDARY ATTACK
                    name = "secondaryAttack",
                    class = OP_Keybind,
                    params =
                    {
                        optionPath = "input/SecondaryAttack",
                        optionType = "string",
                        default = "MouseButton1",
                        
                        bindGroup = "general",
                    },
                    properties =
                    {
                        {"Label", Locale.ResolveString("BINDINGS_SECONDARY_ATTACK")},
                    },
                },
                
                { -- TERTIARY ATTACK
                    name = "tertiaryAttack",
                    class = OP_TT_Keybind,
                    params =
                    {
                        optionPath = "input/TertiaryAttack",
                        optionType = "string",
                        default = "B",
                        
                        bindGroup = "general",
                    },
                    properties =
                    {
                        {"Label", Locale.ResolveString("BINDINGS_TERTIARY_ATTACK")},
                        {"Tooltip", Locale.ResolveString("BINDINGS_TERTIARY_ATTACK_TT")},
                    },
                },
                
                { -- RELOAD
                    name = "reload",
                    class = OP_Keybind,
                    params =
                    {
                        optionPath = "input/Reload",
                        optionType = "string",
                        default = "R",
                        
                        bindGroup = "general",
                    },
                    properties =
                    {
                        {"Label", Locale.ResolveString("BINDINGS_RELOAD")},
                    },
                },
                
                { -- USE
                    name = "use",
                    class = OP_Keybind,
                    params =
                    {
                        optionPath = "input/Use",
                        optionType = "string",
                        default = "E",
                        
                        bindGroup = "general",
                    },
                    properties =
                    {
                        {"Label", Locale.ResolveString("BINDINGS_USE")},
                    },
                },
                
                { -- FLASHLIGHT
                    name = "flashlight",
                    class = OP_Keybind,
                    params =
                    {
                        optionPath = "input/ToggleFlashlight",
                        optionType = "string",
                        default = "F",
                        
                        bindGroup = "general",
                    },
                    properties =
                    {
                        {"Label", Locale.ResolveString("BINDINGS_FLASHLIGHT")},
                    },
                },
                
                { -- DROP WEAPON
                    name = "dropWeapon",
                    class = OP_Keybind,
                    params =
                    {
                        optionPath = "input/Drop",
                        optionType = "string",
                        default = "G",
                        
                        bindGroup = "general",
                    },
                    properties =
                    {
                        {"Label", Locale.ResolveString("BINDINGS_DROP_WEAPON_/_EJECT")},
                    },
                },
                
                { -- NEXT WEAPON
                    name = "nextWeapon",
                    class = OP_Keybind,
                    params =
                    {
                        optionPath = "input/SelectNextWeapon",
                        optionType = "string",
                        default = "MouseWheelUp",
                        
                        bindGroup = "general",
                    },
                    properties =
                    {
                        {"Label", Locale.ResolveString("BINDINGS_NEXT_WEAPON")},
                    },
                },
                
                { -- PREVIOUS WEAPON
                    name = "prevWeapon",
                    class = OP_Keybind,
                    params =
                    {
                        optionPath = "input/SelectPreviousWeapon",
                        optionType = "string",
                        default = "MouseWheelDown",
                        
                        bindGroup = "general",
                    },
                    properties =
                    {
                        {"Label", Locale.ResolveString("BINDINGS_PREVIOUS_WEAPON")},
                    },
                },
                
                { -- WEAPON SLOT 1
                    name = "weaponSlot1",
                    class = OP_Keybind,
                    params =
                    {
                        optionPath = "input/Weapon1",
                        optionType = "string",
                        default = "1",
                        
                        bindGroup = "general",
                    },
                    properties =
                    {
                        {"Label", Locale.ResolveString("BINDINGS_WEAPON_#1")},
                    },
                },
                
                { -- WEAPON SLOT 2
                    name = "weaponSlot2",
                    class = OP_Keybind,
                    params =
                    {
                        optionPath = "input/Weapon2",
                        optionType = "string",
                        default = "2",
                        
                        bindGroup = "general",
                    },
                    properties =
                    {
                        {"Label", Locale.ResolveString("BINDINGS_WEAPON_#2")},
                    },
                },
                
                { -- WEAPON SLOT 3
                    name = "weaponSlot3",
                    class = OP_Keybind,
                    params =
                    {
                        optionPath = "input/Weapon3",
                        optionType = "string",
                        default = "3",
                        
                        bindGroup = "general",
                    },
                    properties =
                    {
                        {"Label", Locale.ResolveString("BINDINGS_WEAPON_#3")},
                    },
                },
                
                { -- WEAPON SLOT 4
                    name = "weaponSlot4",
                    class = OP_Keybind,
                    params =
                    {
                        optionPath = "input/Weapon4",
                        optionType = "string",
                        default = "4",
                        
                        bindGroup = "general",
                    },
                    properties =
                    {
                        {"Label", Locale.ResolveString("BINDINGS_WEAPON_#4")},
                    },
                },
                
                { -- WEAPON SLOT 5
                    name = "weaponSlot5",
                    class = OP_Keybind,
                    params =
                    {
                        optionPath = "input/Weapon5",
                        optionType = "string",
                        default = "5",
                        
                        bindGroup = "general",
                    },
                    properties =
                    {
                        {"Label", Locale.ResolveString("BINDINGS_WEAPON_#5")},
                    },
                },
                
                { -- QUICK SWITCH
                    name = "quickSwitch",
                    class = OP_Keybind,
                    params =
                    {
                        optionPath = "input/QuickSwitch",
                        optionType = "string",
                        default = "V",
                        
                        bindGroup = "general",
                    },
                    properties =
                    {
                        {"Label", Locale.ResolveString("BINDINGS_QUICK_SWITCH")},
                    },
                },
                
                { -- EVOLVE MENU
                    name = "evolveMenu",
                    class = OP_Keybind,
                    params =
                    {
                        optionPath = "input/Buy",
                        optionType = "string",
                        default = "B",
                        
                        bindGroup = "general",
                    },
                    properties =
                    {
                        {"Label", Locale.ResolveString("BINDINGS_BUY/EVOLVE_MENU")},
                    },
                },
                
                { -- EVOLVE LAST UPGRADES
                    name = "evolveLast",
                    class = OP_Keybind,
                    params =
                    {
                        optionPath = "input/LastUpgrades",
                        optionType = "string",
                        default = "None",
                        
                        bindGroup = "general",
                    },
                    properties =
                    {
                        {"Label", Locale.ResolveString("BINDINGS_EVOLVE_LAST_UPGRADES")},
                    },
                },
            },
        },
        
        -- COMMUNICATION & INFORMATION GROUP
        MenuData.CreateExpandableKeybindGroup
        {
            name = "communicationAndInformationGroup",
            label = "COMMUNICATION_AND_INFORMATION",
            children =
            {
                { -- REQUEST HEALTH
                    name = "requestHealth",
                    class = OP_Keybind,
                    params =
                    {
                        optionPath = "input/RequestHealth",
                        optionType = "string",
                        default = "Q",
                        
                        bindGroup = "general",
                    },
                    properties =
                    {
                        {"Label", Locale.ResolveString("BINDINGS_REQUEST_HEALING_/_MEDPACK")},
                    },
                },
                
                { -- REQUEST AMMO
                    name = "requestAmmo",
                    class = OP_Keybind,
                    params =
                    {
                        optionPath = "input/RequestAmmo",
                        optionType = "string",
                        default = "Z",
                        
                        bindGroup = "general",
                    },
                    properties =
                    {
                        {"Label", Locale.ResolveString("BINDINGS_REQUEST_AMMO_/_ENZYME")},
                    },
                },
                
                { -- REQUEST ORDER
                    name = "requestOrder",
                    class = OP_Keybind,
                    params =
                    {
                        optionPath = "input/RequestOrder",
                        optionType = "string",
                        default = "H",
                        
                        bindGroup = "general",
                    },
                    properties =
                    {
                        {"Label", Locale.ResolveString("BINDINGS_REQUEST_ORDER")},
                    },
                },
                
                { -- SHOW MAP
                    name = "showMap",
                    class = OP_Keybind,
                    params =
                    {
                        optionPath = "input/ShowMap",
                        optionType = "string",
                        default = "C",
                        
                        bindGroup = "general",
                    },
                    properties =
                    {
                        {"Label", Locale.ResolveString("BINDINGS_SHOW_MAP")},
                    },
                },
                
                { -- PING LOCATION
                    name = "pingLocation",
                    class = OP_Keybind,
                    params =
                    {
                        optionPath = "input/PingLocation",
                        optionType = "string",
                        default = "MouseButton2",
                        
                        bindGroup = "general",
                    },
                    properties =
                    {
                        {"Label", Locale.ResolveString("BINDINGS_PING_LOCATION")},
                    },
                },
                
                { -- SHOW SCOREBOARD
                    name = "scoreboard",
                    class = OP_Keybind,
                    params =
                    {
                        optionPath = "input/Scoreboard",
                        optionType = "string",
                        default = "Tab",
                        
                        bindGroup = "general",
                    },
                    properties =
                    {
                        {"Label", Locale.ResolveString("BINDINGS_SCOREBOARD")},
                    },
                },
                
                { -- PUSH TO TALK
                    name = "pushToTalk",
                    class = OP_Keybind,
                    params =
                    {
                        optionPath = "input/VoiceChat",
                        optionType = "string",
                        default = "LeftAlt",
                        
                        bindGroup = "general",
                    },
                    properties =
                    {
                        {"Label", Locale.ResolveString("BINDINGS_PUSH_TO_TALK")},
                    },
                },
                
                { -- EVERYBODY TEXT CHAT
                    name = "everybodyTextChat",
                    class = OP_Keybind,
                    params =
                    {
                        optionPath = "input/TextChat",
                        optionType = "string",
                        default = "Return",
                        
                        bindGroup = "general",
                    },
                    properties =
                    {
                        {"Label", Locale.ResolveString("BINDINGS_EVERYBODY_TEXT_CHAT")},
                    },
                },
                
                { -- TEAM-ONLY TEXT CHAT
                    name = "teamOnlyTextChat",
                    class = OP_Keybind,
                    params =
                    {
                        optionPath = "input/TeamChat",
                        optionType = "string",
                        default = "Y",
                        
                        bindGroup = "general",
                    },
                    properties =
                    {
                        {"Label", Locale.ResolveString("BINDINGS_TEAM_CHAT")},
                    },
                },
                
                { -- TECH TREE
                    name = "showTechTree",
                    class = OP_Keybind,
                    params =
                    {
                        optionPath = "input/ShowTechMap",
                        optionType = "string",
                        default = "J",
                        
                        bindGroup = "general",
                    },
                    properties =
                    {
                        {"Label", Locale.ResolveString("BINDINGS_SHOW_TECH_TREE")},
                    },
                },
                
                { -- TAUNT
                    name = "taunt",
                    class = OP_Keybind,
                    params =
                    {
                        optionPath = "input/Taunt",
                        optionType = "string",
                        default = "T",
                        
                        bindGroup = "general",
                    },
                    properties =
                    {
                        {"Label", Locale.ResolveString("BINDINGS_TAUNT")},
                    },
                },
                
                { -- TOGGLE MINIMAP NAME VISIBILITY
                    name = "toggleMinimapNameVisibility",
                    class = OP_Keybind,
                    params =
                    {
                        optionPath = "input/ToggleMinimapNames",
                        optionType = "string",
                        default = "None",
                        
                        bindGroup = "general",
                    },
                    properties =
                    {
                        {"Label", Locale.ResolveString("BINDINGS_TOGGLE_MINIMAP_NAMES")},
                    },
                },
                
                { -- VOICEOVER MENU
                    name = "voiceoverMenu",
                    class = OP_Keybind,
                    params =
                    {
                        optionPath = "input/RequestMenu",
                        optionType = "string",
                        default = "X",
                        
                        bindGroup = "general",
                    },
                    properties =
                    {
                        {"Label", Locale.ResolveString("BINDINGS_VOICEOVER_MENU")},
                    },
                },
                
                { -- REQUEST WELD
                    name = "requestWeld",
                    class = OP_Keybind,
                    params =
                    {
                        optionPath = "input/RequestWeld",
                        optionType = "string",
                        default = "None",
                        
                        bindGroup = "general",
                    },
                    properties =
                    {
                        {"Label", Locale.ResolveString("BINDINGS_REQUEST_WELD")},
                    },
                },
                
                { -- MARINE - COVERING YOU
                    name = "marineCoveringYou",
                    class = OP_Keybind,
                    params =
                    {
                        optionPath = "input/VoiceOverCovering",
                        optionType = "string",
                        default = "None",
                        
                        bindGroup = "general",
                    },
                    properties =
                    {
                        {"Label", Locale.ResolveString("BINDINGS_VOICE_COVERING")},
                    },
                },
                
                { -- MARINE - FOLLOW ME
                    name = "marineFollowMe",
                    class = OP_Keybind,
                    params =
                    {
                        optionPath = "input/VoiceOverFollowMe",
                        optionType = "string",
                        default = "None",
                        
                        bindGroup = "general",
                    },
                    properties =
                    {
                        {"Label", Locale.ResolveString("BINDINGS_VOICE_FOLLOW")},
                    },
                },
                
                { -- MARINE - HOSTILES
                    name = "marineHostiles",
                    class = OP_Keybind,
                    params =
                    {
                        optionPath = "input/VoiceOverHostiles",
                        optionType = "string",
                        default = "None",
                        
                        bindGroup = "general",
                    },
                    properties =
                    {
                        {"Label", Locale.ResolveString("BINDINGS_VOICE_HOSTILES")},
                    },
                },
                
                { -- ACKNOWLEDGED CHUCKLE
                    name = "acknowledgedChuckle",
                    class = OP_Keybind,
                    params =
                    {
                        optionPath = "input/VoiceOverAcknowledged",
                        optionType = "string",
                        default = "None",
                        
                        bindGroup = "general",
                    },
                    properties =
                    {
                        {"Label", Locale.ResolveString("BINDINGS_VOICE_ACKOWLEDGED")},
                    },
                },
            },
        },
        
        -- MISCELLANEOUS GROUP
        MenuData.CreateExpandableKeybindGroup
        {
            name = "miscGroup",
            label = "MISCELLANEOUS",
            children =
            {
                { -- TOGGLE CONSOLE
                    name = "toggleConsole",
                    class = OP_Keybind,
                    params =
                    {
                        optionPath = "input/ToggleConsole",
                        optionType = "string",
                        default = "Grave",
                        
                        bindGroup = "general",

                        -- Don't allow users to use LMB for console.  This prevents them from ever
                        -- clicking again.
                        disabledKeys = {InputKey.MouseButton0},
                    },
                    properties =
                    {
                        {"Label", Locale.ResolveString("BINDINGS_TOGGLE_CONSOLE")},
                    },
                },
                
                { -- READY ROOM
                    name = "goToReadyRoom",
                    class = OP_Keybind,
                    params =
                    {
                        optionPath = "input/ReadyRoom",
                        optionType = "string",
                        default = "F4",
                        
                        bindGroup = "general",
                    },
                    properties =
                    {
                        {"Label", Locale.ResolveString("BINDINGS_GO_TO_READY_ROOM")},
                    },
                },
                
                { -- VOTE YES
                    name = "voteYes",
                    class = OP_Keybind,
                    params =
                    {
                        optionPath = "input/VoteYes",
                        optionType = "string",
                        default = "F1",
                        
                        bindGroup = "general",
                    },
                    properties =
                    {
                        {"Label", Locale.ResolveString("BINDINGS_VOTE_YES")},
                    },
                },
                
                { -- VOTE NO
                    name = "voteNo",
                    class = OP_Keybind,
                    params =
                    {
                        optionPath = "input/VoteNo",
                        optionType = "string",
                        default = "F2",
                        
                        bindGroup = "general",
                    },
                    properties =
                    {
                        {"Label", Locale.ResolveString("BINDINGS_VOTE_NO")},
                    },
                },
                
                { -- HELP SCREEN
                    name = "helpScreen",
                    class = OP_Keybind,
                    params =
                    {
                        optionPath = "input/HelpScreen",
                        optionType = "string",
                        default = "F3",
                        
                        bindGroup = "general",
                    },
                    properties =
                    {
                        {"Label", Locale.ResolveString("HELP_SCREEN")},
                    },
                },
            },
        },
    },
    
    -- COMMANDER CONTROLS
    rightChildren =
    {
        { -- COMMANDER BINDINGS Header
            name = "bindingsDivider",
            class = GUIMenuDividerWidget,
            params =
            {
                font = MenuStyle.kOptionGroupHeadingFont,
            },
            properties =
            {
                {"Label", Locale.ResolveString("COMMANDER_BINDINGS")},
            },
            postInit = function(self) self:AlignTop() end,
        },
        
        MenuData.CreateExpandableKeybindGroup
        {
            name = "commanderGrid",
            label = "COMMANDER_GRID",
            
            children =
            {
                { -- COMMANDER BINDINGS GRID
                    name = "commanderKeybindGrid",
                    class = GUIMenuCommanderKeybindGrid,
                    
                    properties =
                    {
                        {"ResetButtonLabel", Locale.ResolveString("COMMANDER_BINDINGS_GRID_RESET")},
                    },
                },
            },
        },
        
        { -- NON-GRID COMMANDER BINDINGS.
            name = "layout",
            class = GUIListLayout,
            params =
            {
                orientation = "vertical",
            },
            properties =
            {
                {"FrontPadding", 32},
                {"BackPadding", 32},
                {"Spacing", 0},
            },
            postInit = 
            {
                SyncParentContentsSizeToLayout,
            },
            children =
            {
                { -- GO TO PREVIOUS LOCATION
                    name = "commGoToPrevLocation",
                    class = OP_Keybind,
                    params =
                    {
                        optionPath = "input/PreviousLocationCom",
                        optionType = "string",
                        default = "None",
                        
                        bindGroup = "commander",
                    },
                    properties =
                    {
                        {"Label", Locale.ResolveString("COMBINDINGS_GO_TO_PREVIOUS_LOCATION")},
                    },
                },
                
                { -- ZOOM IN
                    name = "commZoomIn",
                    class = OP_Keybind,
                    params =
                    {
                        optionPath = "input/OverHeadZoomIncrease",
                        optionType = "string",
                        default = "MouseWheelUp",
                        
                        bindGroup = "commander",
                    },
                    properties =
                    {
                        {"Label", Locale.ResolveString("COMBINDINGS_OVERHEAD_ZOOM_INCREASE")},
                    },
                },
                
                { -- ZOOM OUT
                    name = "commZoomOut",
                    class = OP_Keybind,
                    params =
                    {
                        optionPath = "input/OverHeadZoomDecrease",
                        optionType = "string",
                        default = "MouseWheelDown",
                        
                        bindGroup = "commander",
                    },
                    properties =
                    {
                        {"Label", Locale.ResolveString("COMBINDINGS_OVERHEAD_ZOOM_DECREASE")},
                    },
                },
                
                { -- RESET ZOOM
                    name = "commResetZoom",
                    class = OP_Keybind,
                    params =
                    {
                        optionPath = "input/OverHeadZoomReset",
                        optionType = "string",
                        default = "None",
                        
                        bindGroup = "commander",
                    },
                    properties =
                    {
                        {"Label", Locale.ResolveString("COMBINDINGS_OVERHEAD_ZOOM_RESET")},
                    },
                },
                
                { -- MOVEMENT OVERRIDE
                    name = "commMovementOverride",
                    class = OP_Keybind,
                    params =
                    {
                        optionPath = "input/MovementModifierCom",
                        optionType = "string",
                        default = "LeftShift",
                        
                        bindGroup = "commander",
                    },
                    properties =
                    {
                        {"Label", Locale.ResolveString("COMBINDINGS_MOVEMENT_SPECIAL")},
                    },
                },
                
                -- TODO Hook this up in-game.  Currently, this is hard-coded to space.
                --[=[
                { -- GO TO LAST ALERT
                    name = "commGoToAlert",
                    class = OP_Keybind,
                    params =
                    {
                        optionPath = "input/LastAlertCom",
                        optionType = "string",
                        default = "Space",
                        
                        bindGroup = "commander",
                    },
                    properties =
                    {
                        {"Label", Locale.ResolveString("COMBINDINGS_GO_TO_ALERT")},
                    },
                },
                --]=]
                
                { -- COMMANDER SHOW MAP
                    name = "commShowMap",
                    class = OP_Keybind,
                    params =
                    {
                        optionPath = "input/ShowMapCom",
                        optionType = "string",
                        default = "C",
                        
                        inheritFrom = "showMap",
                        bindGroup = "commander",
                    },
                    properties =
                    {
                        {"Label", Locale.ResolveString("COMBINDINGS_SHOW_MAP")},
                    },
                },
                
                { -- COMMANDER PUSH TO TALK
                    name = "commPushToTalk",
                    class = OP_Keybind,
                    params =
                    {
                        optionPath = "input/VoiceChatCom",
                        optionType = "string",
                        default = "LeftAlt",
                        
                        inheritFrom = "pushToTalk",
                        bindGroup = "commander",
                    },
                    properties =
                    {
                        {"Label", Locale.ResolveString("BINDINGS_PUSH_TO_TALK")},
                    },
                },
                
                { -- COMMANDER EVERYBODY TEXT CHAT
                    name = "commEverybodyTextChat",
                    class = OP_Keybind,
                    params =
                    {
                        optionPath = "input/TextChatCom",
                        optionType = "string",
                        default = "Return",
                        
                        inheritFrom = "everybodyTextChat",
                        bindGroup = "commander",
                    },
                    properties =
                    {
                        {"Label", Locale.ResolveString("BINDINGS_EVERYBODY_TEXT_CHAT")},
                    },
                },
                
                { -- COMMANDER TEAM-ONLY TEXT CHAT
                    name = "commTeamOnlyTextChat",
                    class = OP_Keybind,
                    params =
                    {
                        optionPath = "input/TeamChatCom",
                        optionType = "string",
                        default = "Y",
                        
                        inheritFrom = "teamOnlyTextChat",
                        bindGroup = "commander",
                    },
                    properties =
                    {
                        {"Label", Locale.ResolveString("BINDINGS_TEAM_CHAT")},
                    },
                },
            },
        },
    },
}


            -----------------------------
            -- OPTIONS MENU - MODS TAB --
            -----------------------------

MenuData.Config.OptionsMenu.Mods =
{
    name = "modsCategoryDisplayBox",
    class = GUIMenuCategoryDisplayBox,
    postInit =
    {
        -- Add field to options menu, for easy access.
        function(self) GetOptionsMenu().modsCategoryDisplayBox = self end,
        
        -- Sync to parent size.
        function(self) self:HookEvent(self:GetParent(), "OnSizeChanged", self.SetSize) end,
    }
}


            ---------------------------------
            -- OPTIONS MENU - GRAPHICS TAB --
            ---------------------------------

MenuData.Config.OptionsMenu.Graphics = MenuData.CreateDefaultOptionsLayout
{
    checksChildren =
    {
        -- SHADOWS
        {
            name = "shadows",
            class = OP_Checkbox,
            params =
            {
                optionPath = "graphics/display/shadows",
                optionType = "bool",
                default = true,
                immediateUpdate = function(self)
                    local value = self:GetValue()
                    Client.SetRenderSetting("shadows", tostring(value))
                end,
            },
            
            properties =
            {
                {"Label", Locale.ResolveString("SHADOWS")},
            },
        },
        
        -- BLOOM
        {
            name = "bloom",
            class = OP_TT_Checkbox,
            params =
            {
                optionPath = "graphics/display/bloom_new",
                optionType = "bool",
                default = true,
                immediateUpdate = function(self)
                    local value = self:GetValue()
                    Client.SetRenderSetting("bloom", tostring(value))
                end,
                
                tooltip = Locale.ResolveString("BLOOM_TOOLTIP"),
            },
            
            properties =
            {
                {"Label", Locale.ResolveString("BLOOM")},
            },
        },
        
        -- ANISOTROPIC FILTERING
        {
            name = "anisotropicFiltering",
            class = OP_Checkbox,
            params =
            {
                optionPath = "graphics/display/anisotropic-filtering",
                optionType = "bool",
                default = true,
                immediateUpdate = function(self)
                    local value = self:GetValue()
                    Shared.ConsoleCommand("r_anisotropic "..tostring(value))
                end,
            },
            
            properties =
            {
                {"Label", Locale.ResolveString("AF")},
            },
        },
        
        -- REFLECTIONS
        {
            name = "reflections",
            class = OP_Checkbox,
            params =
            {
                optionPath = "graphics/reflections",
                optionType = "bool",
                default = true,
                immediateUpdate = function(self)
                    local value = self:GetValue()
                    Client.SetRenderSetting("reflections", tostring(value))
                end,
            },
            
            properties =
            {
                {"Label", Locale.ResolveString("REFLECTIONS")},
            },
        },
    },
    
    regularChildren =
    {
        
        -- DISPLAY / MONITOR
        {
            name = "display",
            class = OP_Choice,
            params =
            {
                optionPath = "graphics/display/display",
                optionType = "int",
                default = 0,
                reloadGraphicsOptions = true,
                revertGraphicsOptions = true, -- reload on revert.
            },
            
            properties =
            {
                {"Label", Locale.ResolveString("DISPLAY")..": "},
                {"Choices", MenuData.GetDisplayChoices()},
            },
            
            postInit =
            {
                function(self)
                    self:HookEvent(GetGlobalEventDispatcher(), "OnDisplayChanged",
                        function(self, newDisplay, oldDisplay)
                            self:SetValue(newDisplay)
                        end)
                end
            },
        },
        
        -- RESOLUTION
        {
            name = "resolution",
            class = OP_Choice,
            params =
            {
                alternateSetter = MenuData.SetResolution,
                alternateGetter = MenuData.GetResolution,
                reloadGraphicsOptions = true,
            },
            
            properties =
            {
                {"Label", Locale.ResolveString("RESOLUTION")..": "},
                {"Choices", MenuData.GetResolutionChoices()},
            },
        },
        
        -- WINDOW MODE
        {
            name = "windowMode",
            class = OP_Choice,
            params =
            {
                optionPath = "graphics/display/window-mode",
                optionType = "string",
                default = "fullscreen-windowed",
                reloadGraphicsOptions = true,
                revertGraphicsOptions = true,
            },
            
            properties =
            {
                {"Label", Locale.ResolveString("WINDOW_MODE")..": "},
                {"Choices", MenuData.GetWindowModeChoices() }
            },
            
            postInit =
            {
                function(self)
                    -- Update widget's value if the user changes fullscreen mode (eg alt+enter).
                    self:HookEvent(GetGlobalEventDispatcher(), "OnOptionsChanged",
                        function(self)
                            SetWidgetValueFromOption(self)
                        end)
                end
            },
        },
        
        -- VSYNC
        {
            name = "vsync",
            class = OP_Choice,
            params =
            {
                optionPath = "graphics/display/display-buffering",
                optionType = "int",
                default = 0,
                reloadGraphicsOptions = true,
            },
            
            properties =
            {
                {"Label", Locale.ResolveString("VSYNC")..": "},
                {"Choices",
                    {
                        { value = 0, displayString = Locale.ResolveString("DISABLED") },
                        { value = 1, displayString = Locale.ResolveString("DOUBLE_BUFFERED") },
                        { value = 2, displayString = Locale.ResolveString("TRIPLE_BUFFERED") },
                    },
                },
            },
        },
        
        -- TEXTURE QUALITY
        {
            name = "textureQuality",
            class = OP_TT_Choice,
            params =
            {
                optionPath = "graphics/display/quality",
                optionType = "int",
                default = 1,
                immediateUpdate = function(self)
                    local oldValue = Client.GetOptionInteger("graphics/display/quality", 1)
                    local value = self:GetValue()
                    Client.SetOptionInteger("graphics/display/quality", value)
                    Client.ReloadGraphicsOptions()
                    
                    -- Texture settings are loaded on the next frame, so we have to delay the
                    -- reset by 1 frame.  Do this by creating a timed callback for 0 seconds.
                    self:AddTimedCallback(
                    function(self)
                        Client.SetOptionInteger("graphics/display/quality", oldValue)
                    end, 0.1)
                end,
                
                tooltip = Locale.ResolveString("OPTION_TEXTUREQUALITY"),
            },
            
            properties =
            {
                {"Label", Locale.ResolveString("TEXTURE_QUALITY")..": "},
                {"Choices",
                    {
                        { value = 0, displayString = Locale.ResolveString("LOW") },
                        { value = 1, displayString = Locale.ResolveString("MEDIUM") },
                        { value = 2, displayString = Locale.ResolveString("HIGH") },
                    },
                },
            },
        },
    
        -- GPU MEMORY
        {
            name = "gpuMemory",
            class = OP_TT_Choice,
            params =
            {
                optionPath = "graphics/textureManagement",
                optionType = "int",
                default = 1,
        
                tooltip = Locale.ResolveString("OPTION_TEXTURE_MANAGEMENT_TOOLTIP"),
            },
    
            properties =
            {
                {"Label", Locale.ResolveString("GPU_MEMORY")..": "},
                {"Choices",
                 {
                     { value = 1, displayString = Locale.ResolveString("UNLIMITED") },
                     { value = 2, displayString = "0.5GB" },
                     { value = 3, displayString = "1.0GB" },
                     { value = 4, displayString = "1.5GB" },
                     { value = 5, displayString = "2GB+" },
                 },
                },
            },
        },
    
        -- ANTIALIASING
        {
            name = "antialiasing",
            class = OP_TT_Choice,
            params =
            {
                optionPath = kAntiAliasingOptionsKey,
                optionType = "string",
                default = "fxaa",
                immediateUpdate = function(self)
                    local value = self:GetValue()
                    Client.SetRenderSetting("anti_aliasing", value)
                end,
                
                tooltip = Locale.ResolveString("OPTION_ANTI_ALIASING"),
            },
    
            properties =
            {
                {"Label", Locale.ResolveString("ANTI_ALIASING")},
                {"Choices",
                    {
                        { value = "taa",  displayString = Locale.ResolveString("TAA"),  },
                        { value = "fxaa", displayString = Locale.ResolveString("FXAA"), },
                        { value = "off",  displayString = Locale.ResolveString("OFF"),  },
                    },
                },
            },
            
            postInit = function(self)
                
                -- Switch choice from "taa" to "off" if the user is not running DX11.  Also, remove
                -- the "taa" choice if they are not running dx11.
                if Client.GetRenderDeviceName() ~= "D3D11" then
                    
                    -- Switch off antialiasing if the user had taa selected and is running in DX9.
                    if self:GetValue() == "taa" then
                        self:SetValue("off")
                        GetOptionsMenu():RemoveOptionWidgetFromChangedSet(self)
                        Client.SetOptionString(self.optionPath, self:GetValue())
                    end
                    
                    local choices = self:GetChoices()
                    local changed = false
                    for i=#choices, 1, -1 do
                        if choices[i].value == "taa" then
                            table.remove(choices, i)
                            changed = true
                        end
                    end
                    if changed then
                        self:SetChoices(choices)
                    end
                    
                end
    
                -- Ensure the value is set correctly (can be mismatched if user has just switched to
                -- DX11 from DX9, would say "TAA" even though FXAA was being used).
                Client.SetRenderSetting("anti_aliasing", self:GetValue())
                
                -- Fix bad/old values of antialiasing (eg from previous build where it was either
                -- true or false.
                if self:GetValue() ~= "taa" and self:GetValue() ~= "fxaa" and self:GetValue() ~= "off" then
                    self:SetValue("taa")
                    GetOptionsMenu():RemoveOptionWidgetFromChangedSet(self)
                    Client.SetOptionString(self.optionPath, self:GetValue())
                end
                
            end,
        },
        
        -- PARTICLE QUALITY
        {
            name = "particleQuality",
            class = OP_TT_Choice,
            params =
            {
                optionPath = "graphics/display/particles",
                optionType = "string",
                default = "high",
                immediateUpdate = function(self)
                    local value = self:GetValue()
                    Client.SetRenderSetting("particles", value)
                end,
                
                tooltip = Locale.ResolveString("OPTION_PARTICLE_QUALITY_TOOLTIP"),
            },
            
            properties =
            {
                {"Label", Locale.ResolveString("PARTICLE_QUALITY")..": "},
                {"Choices",
                    {
                        { value = "high", displayString = Locale.ResolveString("HIGH") },
                        { value = "low",  displayString = Locale.ResolveString("LOW") },
                    },
                },
            },
        },
        
        -- LIGHT QUALITY
        {
            name = "lightQuality",
            class = OP_TT_Choice,
            params =
            {
                optionPath = "graphics/lightQuality",
                optionType = "int",
                default = 1,
                immediateUpdate = function(self)
                    -- Hack... Set option to the new value temporarily so player gets a preview, then
                    -- call updates that use that new option, then reset the option without updating.
                    local value = self:GetValue()
                    
                    if Lights_UpdateLightMode then
                        local before = Client.GetOptionInteger("graphics/lightQuality", 1)
                        Client.SetOptionInteger("graphics/lightQuality", value)
                        
                        Lights_UpdateLightMode()
                        
                        if Client.GetIsConnected() then
                            for _, onos in ientitylist(Shared.GetEntitiesWithClassname("Onos")) do
                                onos:RecalculateShakeLightList()
                            end
                        end
                        
                        Client.SetOptionInteger("graphics/lightQuality", before)
                    end
                end,
                
                tooltip = Locale.ResolveString("OPTION_LIGHT_QUALITY"),
            },
            
            properties =
            {
                {"Label", Locale.ResolveString("LIGHT_QUALITY")..": "},
                {"Choices",
                    {
                        { value = 1, displayString = Locale.ResolveString("LOW") },
                        { value = 2, displayString = Locale.ResolveString("HIGH") },
                    },
                },
            },
        },
    
        -- REFRACTION QUALITY
        {
            name = "refractionQuality",
            class = OP_TT_Choice,
            params =
            {
                optionPath = "graphics/refractionQuality",
                optionType = "string",
                default = "low",
                immediateUpdate = function(self)
                    local value = self:GetValue()
                    Client.SetRenderSetting("refraction_quality", tostring(value))
                end,

                tooltip = Locale.ResolveString("OPTION_REFRACTION_QUALITY_TOOLTIP"),
            },
    
            properties =
            {
                {"Label", Locale.ResolveString("REFRACTION_QUALITY")},
                {"Choices",
                    {
                        { value = "high",  displayString = Locale.ResolveString("HIGH"),  },
                        { value = "low", displayString = Locale.ResolveString("LOW"), },
                    },
                },
            },
        },
        
        -- ATMOSPHERICS (group of options)
        {
            name = "atmosphericsOptionGroup",
            class = GUIListLayout,
            
            params =
            {
                orientation = "vertical",
            },
            
            properties =
            {
                {"FrontPadding", 0},
                {"BackPadding", 0},
                {"Spacing", 32},
            },
            
            children =
            {
                -- ATMOSPHERICS ENABLED
                {
                    name = "atmospherics",
                    class = OP_TT_Checkbox,
                    params =
                    {
                        optionPath = "graphics/display/atmospherics",
                        optionType = "bool",
                        default = true,
                        immediateUpdate = function(self)
                            local value = tostring(self:GetValue())
                            Client.SetRenderSetting("atmospherics", value)
                        end,
                        
                        tooltip = Locale.ResolveString("ATMOSPHERICS_TOOLTIP"),
                    },
                    
                    properties =
                    {
                        {"Label", Locale.ResolveString("ATMOSPHERICS")..": "},
                    },
                },
                
                -- ATMOSPHERICS DENSITY
                {
                    name = "atmoDensity",
                    class = OP_TT_Expandable_Number,
                    params =
                    {
                        optionPath = "graphics/atmospheric-density",
                        optionType = "float",
                        default = 0.5,
                        immediateUpdate = function(self)
                            -- Hack... Set option to the new value temporarily so player gets a
                            -- preview, then call updates that use that new option, then reset the
                            -- option without updating.
                            local oldValue = Client.GetOptionFloat("graphics/atmospheric-density", 0.5)
                            local value = self:GetValue()
                            Client.SetOptionFloat("graphics/atmospheric-density", value)
                            ApplyAtmosphericDensity()
                            Client.SetOptionFloat("graphics/atmospheric-density", oldValue)
                        end,
                        
                        minValue = 0,
                        maxValue = 1,
                        decimalPlaces = 2,
                        
                        expansionMargin = 4, -- prevent outer stroke effect from being cropped away.
                        
                        tooltip = Locale.ResolveString("ATMO_DENSITY_TOOLTIP"),
                    },
                    
                    properties =
                    {
                        {"Label", Locale.ResolveString("ATMO_DENSITY")..": "},
                    },
                    
                    postInit =
                    {
                        function(self)
                            self:HookEvent(GetOptionsMenu():GetOptionWidget("atmospherics"), "OnValueChanged",
                            function(self, value)
                                self:SetExpanded(value)
                            end)
                            self:SetExpanded(GetOptionsMenu():GetOptionWidget("atmospherics"):GetValue())
                        end,
                    },
                },
                
                -- ATMOSPHERICS QUALITY
                {
                    name = "atmoQuality",
                    class = OP_TT_Expandable_Choice,
                    params =
                    {
                        optionPath = "graphics/atmospheric-quality",
                        optionType = "string",
                        default = "low", -- match old value.
                        immediateUpdate = function(self)
                            local value = self:GetValue()
                            Client.SetRenderSetting("atmosphericsQuality", value)
                        end,

                        expansionMargin = 4, -- prevent outer stroke effect from being cropped away.
                    },
                    properties =
                    {
                        {"Label", Locale.ResolveString("ATMO_QUALITY")..":"},
                        {"Choices",
                            {
                                { value = "low", displayString = Locale.ResolveString("LOW"),},
                                { value = "med", displayString = Locale.ResolveString("HIGH"),},
                                { value = "high", displayString = Locale.ResolveString("EXTREME"),},
                            },
                        },
                        {"Tooltip", Locale.ResolveString("ATMO_QUALITY_TT")},
                    },
                    postInit =
                    {
                        function(self)
                            self:HookEvent(GetOptionsMenu():GetOptionWidget("atmospherics"), "OnValueChanged",
                            function(self, value)
                                self:SetExpanded(value)
                            end)
                            self:SetExpanded(GetOptionsMenu():GetOptionWidget("atmospherics"):GetValue())
                        end,
                    },
                },
            },
        },
        
        -- AMBIENT OCCLUSION
        {
            name = "ambientOcclusion",
            class = OP_TT_Choice,
            params =
            {
                optionPath = "graphics/display/ambient-occlusion",
                optionType = "string",
                default = "high",
                immediateUpdate = function(self)
                    local value = self:GetValue()
                    Client.SetRenderSetting("ambient_occlusion", value)
                end,
                
                tooltip = Locale.ResolveString("AMBIENT_OCCLUSION_TOOLTIP"),
            },
            
            properties =
            {
                {"Label", Locale.ResolveString("AMBIENT_OCCLUSION")..": "},
                {"Choices",
                    {
                        { value = "off", displayString = Locale.ResolveString("OFF")},
                        { value = "medium", displayString = Locale.ResolveString("MEDIUM")},
                        { value = "high", displayString = Locale.ResolveString("HIGH") },
                    },
                },
            },
        },
        
        -- DECAL LIFETIME
        {
            name = "decalLifeTime",
            class = OP_TT_Number,
            params =
            {
                optionPath = "graphics/decallifetime",
                optionType = "float",
                default = 0.2,
                
                immediateUpdate = function(self)
                    if Client and Client.SetDefaultDecalLifetime then
                        Client.SetDefaultDecalLifetime(self:GetValue() * kDecalMaxLifetime)
                    end
                end,
                
                minValue = 0,
                maxValue = 1,
                decimalPlaces = 2,
                
                tooltip = Locale.ResolveString("DECAL_LIFETIME_TOOLTIP"),
            },
            
            properties =
            {
                {"Label", Locale.ResolveString("DECAL")..": "},
            },
        },
        
        -- INFESTATION
        {
            name = "infestation",
            class = OP_TT_Choice,
            params =
            {
                optionPath = "graphics/infestation",
                optionType = "string",
                default = "rich",
                immediateUpdate = function(self)
                    -- Hack... Infestation is simply told when to update, but not at what quality.  In
                    -- order to provide the sort of "preview before applying" functionality of the new
                    -- menu we're after, we have to set the option, update infestation, then set it back
                    -- without updating infestation. :/
                    if Infestation_SyncOptions then
                        local value = self:GetValue()
                        local before = Client.GetOptionString("graphics/infestation", "rich")
                        Client.SetOptionString("graphics/infestation", value)
                        Infestation_SyncOptions()
                        Client.SetOptionString("graphics/infestation", before)
                    end
                end,
                
                tooltip = Locale.ResolveString("MENU_INFESTATION_TOOLTIP"),
            },
            
            properties =
            {
                {"Label", Locale.ResolveString("MENU_INFESTATION")..": "},
                {"Choices",
                    {
                        { value = "minimal", displayString = Locale.ResolveString("MINIMAL") },
                        { value = "rich", displayString = Locale.ResolveString("RICH") },
                    },
                },
            },
        },
        
        -- GAMMA
        {
            name = "gamma",
            class = OP_Number,
            params =
            {
                optionPath = "graphics/display/gamma",
                optionType = "float",
                default = 2.2,
                immediateUpdate = function(self)
                    local value = self:GetValue()
                    Client.SetRenderGammaAdjustment(value)
                end,
                
                minValue = 1.7,
                maxValue = 2.5,
                decimalPlaces = 2,
            },
            
            properties =
            {
                {"Label", Locale.ResolveString("OPTION_GAMMA")..": "},
            },
        },
    },
}


            ------------------------------
            -- OPTIONS MENU - SOUND TAB --
            ------------------------------

MenuData.Config.OptionsMenu.Sound = MenuData.CreateDefaultOptionsLayout
{
    checksChildren =
    {
        -- Perhaps we should re-think this unless we can come up with more checkboxes to fill out this
        -- section? (only 1 checkbox ATM...)
        
        -- MUTE ON MINIMIZE
        {
            name = "muteOnMinimize",
            class = OP_TT_Checkbox,
            params =
            {
                optionPath = "sound/minimized-mute",
                optionType = "bool",
                default = true,
                
                tooltip = Locale.ResolveString("SOUND_MUTE_MINIZED_TTIP"),
            },
            
            properties =
            {
                {"Label", Locale.ResolveString("SOUND_MUTE_MINIZED")},
            },
        },
    },
    
    regularChildren =
    {
        -- INPUT DEVICE
        {
            name = "inputDevice",
            class = OP_Choice,
            params =
            {
                optionPath = "sound/input-device",
                optionType = "string",
                default = "Default",
                immediateUpdate = function(self)
                    local value = self:GetValue()
                    MenuData.SetInputSoundDevice(value)
                end,
            },
            
            properties =
            {
                {"Label", Locale.ResolveString("INPUT_DEVICE")..": "},
            },
            
            postInit =
            {
                -- Certain required Client functions and values are not set yet.  Need to defer
                -- setting dropdown choices until the next frame.
                function(self)
                    self:AddTimedCallback(function(self)
                        self:SetChoices(MenuData.GetInputSoundDeviceChoices())
                    end, 0)
                end,
                
                -- Update sound device list if it changes.
                function(self)
                    self:HookEvent(GetGlobalEventDispatcher(), "OnSoundDeviceListChanged",
                        function(self)
                            self:SetChoices(MenuData.GetInputSoundDeviceChoices())
                        end)
                end,
            },
        },
        
        -- OUTPUT DEVICE
        {
            name = "outputDevice",
            class = OP_Choice,
            params =
            {
                optionPath = "sound/output-device",
                optionType = "string",
                default = "Default",
                immediateUpdate = function(self)
                    local value = self:GetValue()
                    MenuData.SetOutputSoundDevice(value)
                end,
            },
            
            properties =
            {
                {"Label", Locale.ResolveString("OUTPUT_DEVICE")..": "},
            },
            
            postInit =
            {
                -- Certain required Client functions and values are not set yet.  Need to defer
                -- setting dropdown choices until the next frame.
                function(self)
                    self:AddTimedCallback(function(self)
                        self:SetChoices(MenuData.GetOutputSoundDeviceChoices())
                    end, 0)
                end,
                
                -- Update sound device list if it changes.
                function(self)
                    self:HookEvent(GetGlobalEventDispatcher(), "OnSoundDeviceListChanged",
                        function(self)
                            self:SetChoices(MenuData.GetOutputSoundDeviceChoices())
                        end)
                end,
            },
        },
        
        -- VOICE VOLUME
        {
            name = "voiceVolume",
            class = OP_TT_Number,
            params =
            {
                optionPath = "voiceVolume",
                optionType = "int",
                default = 90,
                immediateUpdate = function(self)
                    local value = self:GetValue()
                    Client.SetVoiceVolume(value / 100)
                end,
                
                minValue = 0,
                maxValue = 100,
                decimalPlaces = 0,
                
                tooltip = Locale.ResolveString("VOICE_VOLUME_TOOLTIP"),
            },
            
            properties =
            {
                {"Label", Locale.ResolveString("VOICE_VOLUME")..": "},
            },
        },
        
        -- SOUND VOLUME
        {
            name = "soundVolume",
            class = OP_Number,
            params =
            {
                optionPath = "soundVolume",
                optionType = "int",
                default = 90,
                immediateUpdate = function(self)
                    local value = self:GetValue()
                    Client.SetSoundVolume(value / 100)
                end,
                
                minValue = 0,
                maxValue = 100,
                decimalPlaces = 0,
            },
            
            properties =
            {
                {"Label", Locale.ResolveString("SOUND_VOLUME")..": "},
            },
        },
        
        -- MICROPHONE RELEASE DELAY
        {
            name = "micReleaseDelay",
            class = OP_TT_Number,
            params =
            {
                optionPath = "recordingReleaseDelay",
                optionType = "float",
                default = 0.15,
                
                minValue = 0,
                maxValue = 1,
                decimalPlaces = 2,
                
                tooltip = Locale.ResolveString("MICROPHONE_RELEASE_DELAY_TTIP"),
            },
            
            properties =
            {
                {"Label", Locale.ResolveString("MICROPHONE_RELEASE_DELAY")..": "},
            },
        },
        
        -- MUSIC VOLUME
        {
            name = "musicVolume",
            class = OP_Number,
            params =
            {
                optionPath = "musicVolume",
                optionType = "int",
                default = 90,
                immediateUpdate = function(self)
                    local value = self:GetValue()
                    Client.SetMusicVolume(value / 100)
                end,
                
                minValue = 0,
                maxValue = 100,
                decimalPlaces = 0,
            },
            
            properties =
            {
                {"Label", Locale.ResolveString("MUSIC_VOLUME")..": "},
            },
        },
        
        -- MICROPHONE GAIN
        {
            name = "micGain",
            class = OP_Number,
            params =
            {
                optionPath = "recordingGain",
                optionType = "float",
                default = 0.5,
                immediateUpdate = function(self)
                    local value = self:GetValue()
                    Client.SetRecordingGain(value)
                end,
                
                minValue = 0,
                maxValue = 1,
                decimalPlaces = 2,
            },
            
            properties =
            {
                {"Label", Locale.ResolveString("MICROPHONE_GAIN")..": "},
            },
        },
        
        -- HIT-SOUND VOLUME
        {
            name = "hitSoundVolume",
            class = OP_Number,
            params =
            {
                optionPath = "hitsound-vol",
                optionType = "float",
                default = 0,
                
                minValue = 0,
                maxValue = 1,
                decimalPlaces = 2,
            },
            
            properties =
            {
                {"Label", Locale.ResolveString("HIT_SOUND_VOLUME")..": "},
            },
            
            postInit =
            {
                function(self)
                    self:HookEvent(self, "OnDragEnd", MenuData.PreviewHitSound)
                    self:HookEvent(self, "OnJump", MenuData.PreviewHitSound)
                end,
            },
        },
        
        -- MICROPHONE VOLUME VISUALIZATION
        {
            name = "micLevelViz",
            class = GUIMenuMicVolumeVisualizationWidget,
            
            properties =
            {
                {"Label", Locale.ResolveString("MICROPHONE_LEVEL")},
            },
        },
    },
}


            -----------------------
            -- START SERVER MENU --
            -----------------------

kStartServer_ServerNameKey = "start-server/server-name"
kStartServer_PasswordKey = "start-server/password"
kStartServer_PortKey = "start-server/port"
kStartServer_MapKey = "start-server/map"
kStartServer_PlayerLimitKey = "start-server/max-players"
kStartServer_AddBotsKey = "start-server/add-bots"

kStartServer_DefaultServerName = "Listen Server"
kStartServer_DefaultPassword = ""
kStartServer_DefaultPort = 27015
kStartServer_DefaultMap = "ns2_summit"
kStartServer_DefaultPlayerLimit = 16
kStartServer_DefaultAddBots = true

MenuData.StartServerMenu =
{
    name = "listLayout",
    class = GUIListLayout,
    params = 
    {
        orientation = "vertical",
        spacing = 64,
        frontPadding = 24,
        backPadding = 48,
    },
    
    children =
    {
        { -- Server Name
            name = "serverName",
            class = GetAutoOptionWrappedClass(GUIMenuTextEntryWidget),
            params =
            {
                label = Locale.ResolveString("SERVERBROWSER_SERVERNAME"),
                value = "NS2 Listen Server",
                optionPath = kStartServer_ServerNameKey,
                optionType = "string",
                default = kStartServer_DefaultServerName,
                maxCharacterCount = 60, -- TODO find out if there's a proper global for max server name length.
            },
        },
        
        { -- Server Password
            name = "password",
            class = GetAutoOptionWrappedClass(GUIMenuPasswordEntryWidget),
            params =
            {
                label = Locale.ResolveString("SERVERBROWSER_CREATE_PASSWORD"),
                maxCharacterCount = kStartServer_MaxServerPasswordLength,
                optionPath = kStartServer_PasswordKey,
                optionType = "string",
                default = kStartServer_DefaultPassword,
            },
        },
        
        { -- Port
            name = "port",
            class = GetAutoOptionWrappedClass(GUIMenuNumberEntryWidget),
            params =
            {
                label = Locale.ResolveString("SERVERBROWSER_CREATE_PORT"),
                minValue = 0,
                maxValue = 65535,
                maxCharacterCount = 5,
                decimalPlaces = 0,
                optionPath = kStartServer_PortKey,
                optionType = "int",
                default = kStartServer_DefaultPort,
            },
        },
        
        { -- Map
            name = "map",
            class = GetAutoOptionWrappedClass(GUIMenuDropdownWidget),
            params =
            {
                label = Locale.ResolveString("SERVERBROWSER_MAP"),
                optionPath = kStartServer_MapKey,
                optionType = "string",
                default = kStartServer_DefaultMap,
            },
            postInit = 
            {
                function(self)
                    self:SetChoices(MenuData.GetMapChoices()) -- gotta do this post-load. :(
                end
            },
        },
        
        { -- Player Limit
            name = "playerLimit",
            class = GetAutoOptionWrappedClass(GUIMenuSliderEntryWidget),
            params =
            {
                label = Locale.ResolveString("SERVERBROWSER_CREATE_PLAYER_LIMIT"),
                minValue = 1,
                maxValue = 24,
                decimalPlaces = 0,
                optionPath = kStartServer_PlayerLimitKey,
                optionType = "int",
                default = kStartServer_DefaultPlayerLimit,
            },
        },
        
        { -- Add Bots
            name = "addBots",
            class = GetAutoOptionWrappedClass(GUIMenuCheckboxWidgetLabeled),
            params =
            {
                label = Locale.ResolveString("SERVERBROWSER_CREATE_ADD_BOTS"),
                optionPath = kStartServer_AddBotsKey,
                optionType = "bool",
                default = kStartServer_DefaultAddBots,
            }
        },
    },
}


            -------------------
            -- TRAINING MENU --
            -------------------

MenuData.TrainingMenu =
{
    name = "trainingCategories",
    class = GUIMenuCategoryDisplayBox,
    params =
    {
        categories =
        {
            -- WATCH INTRO
            MenuData.CreateTrainingMenuCategory
            {
                categoryName = "watchIntroEntry",
                entryLabel = Locale.ResolveString("REPLAY_INTRO_VIDEO"),
                texture = "ui/menu/training/intro_banner.dds",
                description = Locale.ResolveString("REPLAY_INTRO_VIDEO_DESCRIPTION"),
                actionButtonText = Locale.ResolveString("REPLAY_INTRO_VIDEO_ACTION"),
                actionButtonCallback = PlayIntro,
            },
    
            -- MARINE TUTORIAL
            MenuData.CreateTutorialMenuCategory
            {
                categoryName = "marineTutorial",
                entryLabel = Locale.ResolveString("PLAY_TUT1"),
                texture = "ui/menu/training/marine_banner.dds",
                description = Locale.ResolveString("PLAY_TUT1_DESCRIPTION"),
                actionButtonText = Locale.ResolveString("PLAY"),
                achievement = "First_0_6",
                actionButtonCallback = StartMarineTutorial,
            },
    
            -- ALIEN TUTORIAL
            MenuData.CreateTutorialMenuCategory
            {
                categoryName = "alienTutorial",
                entryLabel = Locale.ResolveString("PLAY_TUT2"),
                texture = "ui/menu/training/alien_banner.dds",
                description = Locale.ResolveString("PLAY_TUT2_DESCRIPTION"),
                actionButtonText = Locale.ResolveString("PLAY"),
                achievement = "First_0_7",
                actionButtonCallback = StartAlienTutorial,
            },
    
            -- MARINE COMMANDER TUTORIAL
            MenuData.CreateTutorialMenuCategory
            {
                categoryName = "marineCommanderTutorial",
                entryLabel = Locale.ResolveString("PLAY_TUT3"),
                texture = "ui/menu/training/commander_banner.dds",
                description = Locale.ResolveString("PLAY_TUT3_DESCRIPTION"),
                actionButtonText = Locale.ResolveString("PLAY"),
                achievement = "First_0_8",
                actionButtonCallback = StartMarineCommanderTutorial,
            },
    
            -- ALIEN COMMANDER TUTORIAL
            MenuData.CreateTutorialMenuCategory
            {
                categoryName = "alienCommanderTutorial",
                entryLabel = Locale.ResolveString("PLAY_TUT4"),
                texture = "ui/menu/training/alien_commander_banner.dds",
                description = Locale.ResolveString("PLAY_TUT4_DESCRIPTION"),
                actionButtonText = Locale.ResolveString("PLAY"),
                achievement = "First_0_9",
                actionButtonCallback = StartAlienCommanderTutorial,
            },

            -- BOOTCAMP
            MenuData.CreateTrainingMenuCategory
            {
                categoryName = "bootcamp",
                entryLabel = Locale.ResolveString("PLAY_BOOTCAMP"),
                texture = "ui/menu/training/bootcamp_banner.dds",
                description = Locale.ResolveString("PLAY_SANDBOX_DESCRIPTION"),
                actionButtonText = Locale.ResolveString("PLAY"),
                actionButtonCallback = function()
                    Log("BOOTCAMP clicked! (Will be replaced with QuickPlay when that is implemented.")
                end
            },
        },
    },
}


            ---------------------
            -- CHALLENGES MENU --
            ---------------------

MenuData.ChallengesMenu =
{
    name = "trainingCategories",
    class = GUIMenuCategoryDisplayBox,
    params =
    {
        categories =
        {
            -- SKULK CHALLENGE
            MenuData.CreateChallengesMenuCategory
            {
                categoryName = "skulkChallenge",
                entryLabel = Locale.ResolveString("PLAY_SKULK_CHALLENGE"),
                texture = "ui/menu/training/skulk_challenge_banner.dds",
                description = Locale.ResolveString("TUT_SKULK_CHALLENGE_TOOLTIP"),
                actionButtonText = Locale.ResolveString("PLAY"),
                actionButtonCallback = StartSkulkChallenge,
            },
            
            -- HIVE CHALLENGE
            MenuData.CreateChallengesMenuCategory
            {
                categoryName = "hiveChallenge",
                entryLabel = Locale.ResolveString("PLAY_HIVE_CHALLENGE"),
                texture = "ui/menu/training/hive_challenge_banner.dds",
                description = Locale.ResolveString("TUT_HIVE_CHALLENGE_TOOLTIP"),
                actionButtonText = Locale.ResolveString("PLAY"),
                actionButtonCallback = StartHiveChallenge,
            },
        },
    },
}