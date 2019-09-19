-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/MenuDataUtils.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Define utilities related to MenuData here, rather than cluttering up the MenuData.lua file.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/layouts/GUIFlexLayout.lua")
Script.Load("lua/GUI/layouts/GUIListLayout.lua")
Script.Load("lua/GUI/layouts/GUIColumnLayout.lua")
Script.Load("lua/GUI/layouts/GUIFillLayout.lua")

Script.Load("lua/GUI/GUIGlobalEventDispatcher.lua")

Script.Load("lua/menu2/widgets/GUIMenuCheckboxWidgetLabeled.lua")
Script.Load("lua/menu2/widgets/GUIMenuCommanderKeybindGrid.lua")
Script.Load("lua/menu2/widgets/GUIMenuDividerWidget.lua")
Script.Load("lua/menu2/widgets/GUIMenuDropdownWidget.lua")
Script.Load("lua/menu2/widgets/GUIMenuExpandableKeybindGroup.lua")
Script.Load("lua/menu2/widgets/GUIMenuKeybindEntryWidget.lua")
Script.Load("lua/menu2/widgets/GUIMenuKeybindEntryWidgetSimple.lua")
Script.Load("lua/menu2/widgets/GUIMenuMicVolumeVisualizationWidget.lua")
Script.Load("lua/menu2/widgets/GUIMenuPasswordEntryWidget.lua")
Script.Load("lua/menu2/widgets/GUIMenuSliderEntryWidget.lua")
Script.Load("lua/menu2/widgets/GUIMenuTextEntryWidget.lua")

Script.Load("lua/menu2/GUIMenuCategoryDisplayBox.lua")
Script.Load("lua/menu2/GUIMenuCategoryDisplayBoxEntry.lua")

Script.Load("lua/menu2/popup/GUIMenuPopupDialog.lua")

Script.Load("lua/menu2/NavBar/Screens/Training/GUIMenuTrainingGraphic.lua")
Script.Load("lua/menu2/NavBar/Screens/Training/GUIMenuTrainingTutorialEntry.lua")
Script.Load("lua/menu/GUIVideoTutorialIntro.lua") -- for intro.

Script.Load("lua/menu2/wrappers/Option.lua")
Script.Load("lua/menu2/wrappers/Expandable.lua")
Script.Load("lua/menu2/wrappers/Tooltip.lua")
Script.Load("lua/menu2/wrappers/AutoOption.lua")

Script.Load("lua/HitSounds.lua")

-- Define special classes for the options menu.
OP_Checkbox = GetOptionWrappedClass(GUIMenuCheckboxWidgetLabeled)
OP_Text = GetOptionWrappedClass(GUIMenuTextEntryWidget)
OP_Choice = GetOptionWrappedClass(GUIMenuDropdownWidget)
OP_Number = GetOptionWrappedClass(GUIMenuSliderEntryWidget)
OP_Keybind = GetOptionWrappedClass(GUIMenuKeybindEntryWidget)

OP_Expandable_Checkbox     = GetMultiWrappedClass(GUIMenuCheckboxWidgetLabeled, {"Option", "Expandable"})
OP_Expandable_Text         = GetMultiWrappedClass(GUIMenuTextEntryWidget,       {"Option", "Expandable"})
OP_Expandable_Choice       = GetMultiWrappedClass(GUIMenuDropdownWidget,        {"Option", "Expandable"})
OP_Expandable_Number       = GetMultiWrappedClass(GUIMenuSliderEntryWidget,     {"Option", "Expandable"})
OP_Expandable_Keybind      = GetMultiWrappedClass(GUIMenuKeybindEntryWidget,    {"Option", "Expandable"})

OP_TT_Checkbox             = GetMultiWrappedClass(GUIMenuCheckboxWidgetLabeled, {"Option", "Tooltip"})
OP_TT_Text                 = GetMultiWrappedClass(GUIMenuTextEntryWidget,       {"Option", "Tooltip"})
OP_TT_Choice               = GetMultiWrappedClass(GUIMenuDropdownWidget,        {"Option", "Tooltip"})
OP_TT_Number               = GetMultiWrappedClass(GUIMenuSliderEntryWidget,     {"Option", "Tooltip"})
OP_TT_Keybind              = GetMultiWrappedClass(GUIMenuKeybindEntryWidget,    {"Option", "Tooltip"})

OP_TT_Expandable_Checkbox  = GetMultiWrappedClass(GUIMenuCheckboxWidgetLabeled, {"Option", "Tooltip", "Expandable"})
OP_TT_Expandable_Text      = GetMultiWrappedClass(GUIMenuTextEntryWidget,       {"Option", "Tooltip", "Expandable"})
OP_TT_Expandable_Choice    = GetMultiWrappedClass(GUIMenuDropdownWidget,        {"Option", "Tooltip", "Expandable"})
OP_TT_Expandable_Number    = GetMultiWrappedClass(GUIMenuSliderEntryWidget,     {"Option", "Tooltip", "Expandable"})
OP_TT_Expandable_Keybind   = GetMultiWrappedClass(GUIMenuKeybindEntryWidget,    {"Option", "Tooltip", "Expandable"})

-- The engine function isn't loaded at first, so we have to have this pass through function.
function MenuData.SetMouseSensitivity(sens) Client.SetMouseSensitivity(sens) end
function MenuData.GetMouseSensitivity()
    local result = Client.GetMouseSensitivity()
    return result
end

local function SyncWidth(self, size)
    self:SetSize(size.x, self:GetSize().y)
end

local function HookupWidthSync(self)
    self:HookEvent(self:GetParent(), "OnSizeChanged", SyncWidth)
end

local function SyncToParentSize(self)
    local parentObject = self:GetParent()
    assert(parentObject)
    self:HookEvent(parentObject, "OnSizeChanged", self.SetSize)
end

local function UpdateHeight(self, size)
    self:SetSize(self:GetSize().x, size.y)
end

local function SyncToParentHeight(self)
    local parentObj = self:GetParent()
    assert(parentObj)
    self:HookEvent(parentObj, "OnSizeChanged", UpdateHeight)
end

local function SetPaneHeightToLayoutHeight(self, size)
    local parent = self:GetParent()
    parent:SetPaneSize(parent:GetPaneSize().x, size.y)
end

local function SyncPaneHeightToLayoutHeight(self)
    local parent = self:GetParent()
    if parent:isa("GUIScrollPane") then
        self:HookEvent(self, "OnSizeChanged", SetPaneHeightToLayoutHeight)
    end
end

-- Creates a vertical list layout, with paramsTable.children as the children arranged within the layout.
function MenuData.CreateVerticalListLayout(paramsTable)
    
    local fixedSize = paramsTable.fixedSize
    if fixedSize == nil then
        fixedSize = true
    end
    
    return
    {
        name = "layout",
        class = GUIListLayout,
        params =
        {
            orientation = "vertical",
            position = paramsTable.position,
        },
        properties =
        {
            {"FrontPadding", paramsTable.frontPadding or 64},
            {"BackPadding", 48},
            {"Spacing", 32},
            {"FixedMinorSize", fixedSize },
            {"HotSpot", Vector(paramsTable.alignX or 0, 0, 0)},
            {"Anchor", Vector(paramsTable.alignX or 0, 0, 0)},
        },
        
        postInit =
        {
            function(self) if self:GetFixedMinorSize() then HookupWidthSync(self) end end,
            SyncPaneHeightToLayoutHeight,
        },
        
        children = paramsTable.children,
    }
end

-- Creates an options layout that separates checkboxes from other options.
-- paramsTable should contain two keys: checksChildren, and regularChildren, each is a table array
-- containing children to place into these sections.
function MenuData.CreateDefaultOptionsLayout(paramsTable)
    return
    {
        name = "scrollPane",
        class = GUIMenuScrollPane,
        params =
        {
            horizontalScrollBarEnabled = false,
        },
        postInit =
        {
            SyncToParentSize,
        },
        
        children =
        {
            MenuData.CreateVerticalListLayout
            {
                children =
                {
                    { -- Checkbox Section
                        name = "checkboxSection",
                        class = GUIColumnLayout,
                        properties =
                        {
                            {"NumColumns", 3},
                            {"FrontPadding", 32},
                            {"BackPadding", 32},
                            {"Spacing", 32},
                        },
                        postInit =
                        {
                            function(self) HookupWidthSync(self) end,
                        },
                        children = paramsTable.checksChildren,
                    },
                    
                    { -- Regular Section
                        name = "regularSection",
                        class = GUIColumnLayout,
                        properties =
                        {
                            {"NumColumns", 2},
                            {"FrontPadding", 32},
                            {"BackPadding", 32},
                            {"Spacing", 32},
                        },
                        postInit =
                        {
                            function(self) HookupWidthSync(self) end,
                        },
                        children = paramsTable.regularChildren,
                    },
                },
            },
        },
    }
end

local function SetPaneSizeToHalfParentWidth(self)
    local parentObject = self:GetParent()
    assert(parentObject)
    local size = parentObject:GetSize()
    self:SetSize(size.x * 0.5, size.y)
    self:SetPaneSize(size.x * 0.5, self:GetPaneSize().y)
end

local function SyncPaneToHalfParentWidth(self)
    local parentObject = self:GetParent()
    assert(parentObject)
    self:HookEvent(parentObject, "OnSizeChanged", SetPaneSizeToHalfParentWidth)
end

-- Creates an options layout split into two equally wide columns.
-- Expects two tables as fields: leftChildren and rightChildren.
function MenuData.CreateControlsLayout(paramsTable)
    return
    {
        name = "halvesHolder",
        class = GUIObject,
        postInit =
        {
            SyncToParentSize,
        },
        children =
        {
            {
                name = "leftSide",
                class = GUIMenuScrollPane,
                params =
                {
                    horizontalScrollBarEnabled = false,
                },
                postInit =
                {
                    GUIObject.AlignLeft,
                    SyncPaneToHalfParentWidth,
                },
                children =
                {
                    MenuData.CreateVerticalListLayout
                    {
                        children = paramsTable.leftChildren,
                        fixedSize = false,
                        alignX = 0.5,
                        frontPadding = 64,
                    },
                },
            },
            
            {
                name = "rightSide",
                class = GUIMenuScrollPane,
                params =
                {
                    horizontalScrollBarEnabled = false,
                },
                postInit =
                {
                    GUIObject.AlignRight,
                    SyncPaneToHalfParentWidth,
                },
                children =
                {
                    MenuData.CreateVerticalListLayout
                    {
                        children = paramsTable.rightChildren,
                        fixedSize = false,
                        alignX = 0.5,
                        frontPadding = 64,
                    },
                },
            },
        },
    }
end

local function SyncContentsSize(self, size)
    
    self:SetContentsSize(size)
    
end

local function SyncParentContentsSizeToLayout(self)
    local parent = self:GetParent():GetParent():GetParent()
    assert(parent)
    
    parent:HookEvent(self, "OnSizeChanged", SyncContentsSize)
end

local function SyncPaneWidthToWidth(self)
    self:HookEvent(self, "OnSizeChanged", self.SetPaneWidth)
end

-- Combines the array-parts of two tables.
local function CombineLists(a, b)
    assert(type(a) == "table")
    assert(type(b) == "table")
    local result = {}
    for i=1, #a do
        table.insert(result, a[i])
    end
    for i=1, #b do
        table.insert(result, b[i])
    end
    return result
end

-- Creates an expandable group to hold keybind widgets.  Expects three fields: name, label, and
-- children.
function MenuData.CreateExpandableKeybindGroup(paramsTable)
    
    RequireType({"table", "nil"}, paramsTable.params, "paramsTable.params", errorDepth)
    
    return
    {
        name = paramsTable.name,
        class = GUIMenuExpandableKeybindGroup,
        params = CombineParams(paramsTable.params or {},
        {
            expansionMargin = 4, -- prevent outer stroke effect from being cropped away.
        }),
        properties =
        {
            {"Label", Locale.ResolveString(paramsTable.label)},
        },
        children =
        {
            {
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
                children = paramsTable.children
            },
        },
    }
end

function MenuData.CreateTrainingMenuCategory(paramsTable)
    
    RequireType("string", paramsTable.categoryName, "paramsTable.categoryName", 2)
    RequireType("string", paramsTable.entryLabel, "paramsTable.entryLabel", 2)
    RequireType("string", paramsTable.texture, "paramsTable.texture", 2)
    RequireType("string", paramsTable.description, "paramsTable.description", 2)
    RequireType("string", paramsTable.actionButtonText, "paramsTable.actionButtonText", 2)
    RequireType("function", paramsTable.actionButtonCallback, "paramsTable.actionButtonCallback", 2)
    
    return
    {
        categoryName = paramsTable.categoryName,
        entryConfig =
        {
            name = paramsTable.categoryName.."entry",
            class = GUIMenuCategoryDisplayBoxEntry,
            params =
            {
                label = paramsTable.entryLabel,
            },
            postInit = function(self)
                self:HookEvent(self, "OnPressed",
                    function()
                        GetTrainingMenu():SetActionButtonLabel(Locale.ResolveString(paramsTable.actionButtonText))
                        GetTrainingMenu():SetActionButtonCallback(paramsTable.actionButtonCallback)
                    end)
            end
        },
        contentsConfig =
        {
            name = paramsTable.categoryName.."ContentsLayout",
            class = GUIFillLayout,
            params =
            {
                orientation = "vertical",
                fixedMinorSize = true,
            },
            postInit = function(self)
                self:HookEvent(self:GetParent(), "OnSizeChanged", self.SetSize)
                self:SetSize(self:GetParent():GetSize())
            end,
            children =
            {
                {
                    name = paramsTable.categoryName.."GraphicHolder",
                    class = GUIObject,
                    params =
                    {
                        weight = 0.3,
                    },
                    postInit =
                    {
                        function(self)
                            self:HookEvent(self:GetParent(), "OnSizeChanged", self.SetWidth)
                        end,
                    },
                    children =
                    {
                        {
                            name = paramsTable.categoryName.."Graphic",
                            class = GUIMenuTrainingGraphic,
                            params =
                            {
                                weight = 0.5,
                                texture = PrecacheAsset(paramsTable.texture),
                                align = "center",
                            },
                            postInit =
                            {
                                function(self)
                                    local function SetSizeWithIndent(self2, size)
                                        self2:SetSize(size - Vector(100, 100, 0))
                                    end
                                    self:HookEvent(self:GetParent(), "OnSizeChanged", SetSizeWithIndent)
                                    SetSizeWithIndent(self, self:GetParent():GetSize())
                                end,
                            },
                        },
                    },
                },
            
                {
                    name = paramsTable.categoryName.."Description",
                    class = GUIObject,
                    params =
                    {
                        weight = 0.5,
                        align = "center",
                    },
                    postInit =
                    {
                        function(self)
                            self:HookEvent(self:GetParent(), "OnSizeChanged",
                                    function(self2, size)
                                        self2:SetSize(size - Vector(100, 0, 0))
                                    end)
                        end,
                    },
                    children =
                    {
                        {
                            name = paramsTable.categoryName.."DescriptionText",
                            class = GUIParagraph,
                            params =
                            {
                                font = MenuStyle.kOptionHeadingFont,
                                color = MenuStyle.kOptionHeadingColor,
                                text = paramsTable.description,
                                align = "top",
                                position = Vector(0, 50, 0),
                            },
                            postInit =
                            {
                                function(self)
                                    local function SetDescriptionParagraphSize(self2, size)
                                        self2:SetParagraphSize(size.x, -1)
                                    end
                                    self:HookEvent(self:GetParent(), "OnSizeChanged", SetDescriptionParagraphSize)
                                    SetDescriptionParagraphSize(self, self:GetParent():GetSize())
                                end
                            },
                        },
                    },
                },
            },
        },
    }
    
end

function MenuData.CreateTutorialMenuCategory(paramsTable)
    
    RequireType("string", paramsTable.categoryName, "paramsTable.categoryName", 2)
    RequireType("string", paramsTable.entryLabel, "paramsTable.entryLabel", 2)
    RequireType("string", paramsTable.texture, "paramsTable.texture", 2)
    RequireType("string", paramsTable.description, "paramsTable.description", 2)
    RequireType("string", paramsTable.actionButtonText, "paramsTable.actionButtonText", 2)
    RequireType("function", paramsTable.actionButtonCallback, "paramsTable.actionButtonCallback", 2)
    RequireType("string", paramsTable.achievement, "paramsTable.achievement", 2)
    
    return
    {
        categoryName = paramsTable.categoryName,
        entryConfig =
        {
            name = paramsTable.categoryName.."entry",
            class = GUIMenuTrainingTutorialEntry,
            params =
            {
                label = paramsTable.entryLabel,
                tutorialAchievementCode = paramsTable.achievement,
            },
            postInit = function(self)
                self:HookEvent(self, "OnPressed",
                        function()
                            GetTrainingMenu():SetActionButtonLabel(Locale.ResolveString(paramsTable.actionButtonText))
                            GetTrainingMenu():SetActionButtonCallback(paramsTable.actionButtonCallback)
                        end)
            end
        },
        contentsConfig =
        {
            name = paramsTable.categoryName.."ContentsLayout",
            class = GUIFillLayout,
            params =
            {
                orientation = "vertical",
                fixedMinorSize = true,
            },
            postInit = function(self)
                self:HookEvent(self:GetParent(), "OnSizeChanged", self.SetSize)
                self:SetSize(self:GetParent():GetSize())
            end,
            children =
            {
                {
                    name = paramsTable.categoryName.."GraphicHolder",
                    class = GUIObject,
                    params =
                    {
                        weight = 0.3,
                    },
                    postInit =
                    {
                        function(self)
                            self:HookEvent(self:GetParent(), "OnSizeChanged", self.SetWidth)
                        end,
                    },
                    children =
                    {
                        {
                            name = paramsTable.categoryName.."Graphic",
                            class = GUIMenuTrainingGraphic,
                            params =
                            {
                                weight = 0.5,
                                texture = PrecacheAsset(paramsTable.texture),
                                align = "center",
                            },
                            postInit =
                            {
                                function(self)
                                    local function SetSizeWithIndent(self2, size)
                                        self2:SetSize(size - Vector(100, 100, 0))
                                    end
                                    self:HookEvent(self:GetParent(), "OnSizeChanged", SetSizeWithIndent)
                                    SetSizeWithIndent(self, self:GetParent():GetSize())
                                end,
                            },
                        },
                    },
                },
                
                {
                    name = paramsTable.categoryName.."Description",
                    class = GUIObject,
                    params =
                    {
                        weight = 0.5,
                        align = "center",
                    },
                    postInit =
                    {
                        function(self)
                            self:HookEvent(self:GetParent(), "OnSizeChanged",
                                    function(self2, size)
                                        self2:SetSize(size - Vector(100, 0, 0))
                                    end)
                        end,
                    },
                    children =
                    {
                        {
                            name = paramsTable.categoryName.."DescriptionText",
                            class = GUIParagraph,
                            params =
                            {
                                font = MenuStyle.kOptionHeadingFont,
                                color = MenuStyle.kOptionHeadingColor,
                                text = paramsTable.description,
                                align = "top",
                                position = Vector(0, 50, 0),
                            },
                            postInit =
                            {
                                function(self)
                                    local function SetDescriptionParagraphSize(self2, size)
                                        self2:SetParagraphSize(size.x, -1)
                                    end
                                    self:HookEvent(self:GetParent(), "OnSizeChanged", SetDescriptionParagraphSize)
                                    SetDescriptionParagraphSize(self, self:GetParent():GetSize())
                                end
                            },
                        },
                    },
                },
            },
        },
    }

end

function MenuData.CreateChallengesMenuCategory(paramsTable)
    
    RequireType("string", paramsTable.categoryName, "paramsTable.categoryName", 2)
    RequireType("string", paramsTable.entryLabel, "paramsTable.entryLabel", 2)
    RequireType("string", paramsTable.texture, "paramsTable.texture", 2)
    RequireType("string", paramsTable.description, "paramsTable.description", 2)
    RequireType("string", paramsTable.actionButtonText, "paramsTable.actionButtonText", 2)
    RequireType("function", paramsTable.actionButtonCallback, "paramsTable.actionButtonCallback", 2)
    
    return
    {
        categoryName = paramsTable.categoryName,
        entryConfig =
        {
            name = paramsTable.categoryName.."entry",
            class = GUIMenuCategoryDisplayBoxEntry,
            params =
            {
                label = paramsTable.entryLabel,
            },
            postInit = function(self)
                self:HookEvent(self, "OnPressed",
                        function()
                            GetChallengesMenu():SetActionButtonLabel(Locale.ResolveString(paramsTable.actionButtonText))
                            GetChallengesMenu():SetActionButtonCallback(paramsTable.actionButtonCallback)
                        end)
            end
        },
        contentsConfig =
        {
            name = paramsTable.categoryName.."ContentsLayout",
            class = GUIFillLayout,
            params =
            {
                orientation = "vertical",
                fixedMinorSize = true,
            },
            postInit = function(self)
                self:HookEvent(self:GetParent(), "OnSizeChanged", self.SetSize)
                self:SetSize(self:GetParent():GetSize())
            end,
            children =
            {
                {
                    name = paramsTable.categoryName.."GraphicHolder",
                    class = GUIObject,
                    params =
                    {
                        weight = 0.3,
                    },
                    postInit =
                    {
                        function(self)
                            self:HookEvent(self:GetParent(), "OnSizeChanged", self.SetWidth)
                        end,
                    },
                    children =
                    {
                        {
                            name = paramsTable.categoryName.."Graphic",
                            class = GUIMenuTrainingGraphic,
                            params =
                            {
                                weight = 0.5,
                                texture = PrecacheAsset(paramsTable.texture),
                                align = "center",
                            },
                            postInit =
                            {
                                function(self)
                                    local function SetSizeWithIndent(self2, size)
                                        self2:SetSize(size - Vector(100, 100, 0))
                                    end
                                    self:HookEvent(self:GetParent(), "OnSizeChanged", SetSizeWithIndent)
                                    SetSizeWithIndent(self, self:GetParent():GetSize())
                                end,
                            },
                        },
                    },
                },
                
                {
                    name = paramsTable.categoryName.."Description",
                    class = GUIObject,
                    params =
                    {
                        weight = 0.5,
                        align = "center",
                    },
                    postInit =
                    {
                        function(self)
                            self:HookEvent(self:GetParent(), "OnSizeChanged",
                                    function(self2, size)
                                        self2:SetSize(size - Vector(100, 0, 0))
                                    end)
                        end,
                    },
                    children =
                    {
                        {
                            name = paramsTable.categoryName.."DescriptionText",
                            class = GUIParagraph,
                            params =
                            {
                                font = MenuStyle.kOptionHeadingFont,
                                color = MenuStyle.kOptionHeadingColor,
                                text = paramsTable.description,
                                align = "top",
                                position = Vector(0, 50, 0),
                            },
                            postInit =
                            {
                                function(self)
                                    local function SetDescriptionParagraphSize(self2, size)
                                        self2:SetParagraphSize(size.x, -1)
                                    end
                                    self:HookEvent(self:GetParent(), "OnSizeChanged", SetDescriptionParagraphSize)
                                    SetDescriptionParagraphSize(self, self:GetParent():GetSize())
                                end
                            },
                        },
                    },
                },
            },
        },
    }

end

local kMenuMusicData = {}
function MenuData.AddMenuMusic(data)
    
    if type(data.name) ~= "string" then
        error(string.format("Expected string for menu music name, got '%s' instead!", data.name), 2)
    end
    
    if data.name == "random" then
        error("Defining menu music with the name \"random\" is not allowed.", 2)
    end
    
    if data.name == "" then
        error("Menu music name cannot be empty!", 2)
    end
    
    if type(data.localeString) ~= "string" then
        error(string.format("Expected a string for menu music locale string, got '%s' instead!", data.localeString), 2)
    end
    
    if data.localeString == "" then
        error("Menu music locale string cannot be empty!", 2)
    end
    
    if type(data.musicPath) ~= "string" then
        error(string.format("Expected a string for menu music path, got '%s' instead!", data.musicPath), 2)
    end
    
    if data.musicPath == "" then
        error("Menu music path cannot be empty!", 2)
    end
    
    kMenuMusicData[data.name] =
    {
        name = data.name,
        localeString = data.localeString,
        musicPath = data.musicPath,
    }
end

function MenuData.GetMenuMusicChoices()
    
    local choices = {}
    
    choices[1] = { value = "random", displayString = Locale.ResolveString("MENU_MUSIC_RANDOM") }
    
    -- Yea yea... we're using pairs, but this function is called VERY infrequently, so it should be fine.
    for __, music in pairs(kMenuMusicData) do
        choices[#choices+1] = { value = music.name, displayString = Locale.ResolveString(music.localeString) }
    end
    
    return choices
    
end

function MenuData.GetMenuMusicSoundName(name)
    if name == "random" then
        local choices = MenuData.GetMenuMusicChoices()
        local choice = choices[math.random(2, #choices)]
        return kMenuMusicData[choice.value].musicPath
    else
        return kMenuMusicData[name].musicPath
    end
end

function MenuData.GetCurrentMenuMusicSoundName()
    local name = Client.GetOptionString("menu/menuMusicName", "random")
    local result = MenuData.GetMenuMusicSoundName(name)
    return result
end

local kDeviceLocales =
{
    D3D9 = Locale.ResolveString("DIRECTX9"),
    D3D11 = Locale.ResolveString("DIRECTX11"),
    OpenGL = Locale.ResolveString("OPENGL"),
}
function MenuData.GetRenderDeviceChoices()
    
    local renderDevices = Client.GetRenderDeviceNames()
    local choices = {}
    for i=1, #renderDevices do
        choices[#choices+1] = { value = renderDevices[i], displayString = kDeviceLocales[renderDevices[i]] }
    end
    
    return choices
    
end

local resolutions
local function GetResolutionsTable()
    if not resolutions then
        resolutions = {}
        local resCount = Client.GetNumResolutions()
        for i=1, resCount do
            resolutions[i] = Client.GetResolution(i)
        end
    end
    return resolutions
end

function MenuData.SetResolution(index)
    local resolutions = GetResolutionsTable()
    local res = resolutions[index]
    Client.SetOptionInteger("graphics/display/x-resolution", res.xResolution)
    Client.SetOptionInteger("graphics/display/y-resolution", res.yResolution)
end

function MenuData.GetResolution()
    local xRes = Client.GetOptionInteger("graphics/display/x-resolution", 1280)
    local yRes = Client.GetOptionInteger("graphics/display/y-resolution", 800)
    local resolutions = GetResolutionsTable()
    for i=1, #resolutions do
        if resolutions[i].xResolution == xRes and resolutions[i].yResolution == yRes then
            return i
        end
    end
    return 1
end

function MenuData.GetResolutionChoices()
    
    local startupRes = Client.GetStartupResolution()
    local nativeAspect = startupRes.xResolution / startupRes.yResolution
    local resolutions = GetResolutionsTable()
    local choices = {}
    
    for i=#resolutions, 1, -1 do -- reverse order so biggest are at top of list
        local res = resolutions[i]
        local aspect = res.xResolution / res.yResolution
        local displayString = string.format("%dx%d%s", res.xResolution, res.yResolution, aspect == nativeAspect and "*" or "")
        choices[#choices+1] = { value = i, displayString = displayString }
    end
    
    return choices
    
end

function MenuData.GetDisplayChoices()
    
    local choices = {}
    choices[1] = {value = 0, displayString = Locale.ResolveString("DEFAULT")}
    
    local numDisplays = Client.GetNumDisplays()
    for i=1, numDisplays do
        choices[#choices+1] = {value = i, displayString = Locale.ResolveString("DISPLAY").." "..tostring(i)}
    end
    
    return choices
    
end

function MenuData.GetWindowModeChoices()
    
    local windowModeNames = {"windowed", "fullscreen", "fullscreen-windowed"}
    local windowModeLocales = {"WINDOW_MODE_WINDOWED", "WINDOW_MODE_FULLSCREEN", "WINDOW_MODE_FULLSCREEN_WINDOWED"}
    local windowModeCount = Client.GetNumWindowModes()
    local choices = {}
    for i=1, windowModeCount do
        local windowModeIndex = Client.GetWindowMode(i) + 1
        choices[#choices+1] = { value = windowModeNames[windowModeIndex], displayString = Locale.ResolveString(windowModeLocales[windowModeIndex]) }
    end
    
    return choices
    
end

local function GetSoundDeviceList(deviceType)
    local devices = {}
    local numDevices = Client.GetSoundDeviceCount(deviceType)
    for i=1, numDevices do
        local deviceName = Client.GetSoundDeviceName(deviceType, i-1)
        local deviceGUID = Client.GetSoundDeviceGuid(deviceType, i-1)
        table.insert(devices, {name = deviceName, guid = deviceGUID})
    end
    return devices
end

local function SetSoundDevice(deviceType, guid)
    if guid == "Default" then
        if Client.GetSoundDeviceCount(deviceType) > 0 then
            Client.SetSoundDevice(deviceType, 0)
        end
    else
        local deviceId = Client.FindSoundDeviceByGuid(deviceType, guid)
        if deviceId == -1 then
            deviceId = 0
        end
        
        Client.SetSoundDevice(deviceType, deviceId)
    end
end

function MenuData.SetOutputSoundDevice(guid)
    SetSoundDevice(Client.SoundDeviceType_Output, guid)
end

function MenuData.SetInputSoundDevice(guid)
    SetSoundDevice(Client.SoundDeviceType_Input, guid)
end

local function GetSoundDeviceChoices(deviceType)
    
    local devices = GetSoundDeviceList(deviceType)
    local choices = {}
    choices[1] = {value = "Default", displayString = Locale.ResolveString("DEFAULT")}
    for i=1, #devices do
        choices[#choices+1] = {value = devices[i].guid, displayString = devices[i].name}
    end
    
    return choices
    
end

function MenuData.GetInputSoundDeviceChoices()
    local result = GetSoundDeviceChoices(Client.SoundDeviceType_Input)
    return result
end

function MenuData.GetOutputSoundDeviceChoices()
    local result = GetSoundDeviceChoices(Client.SoundDeviceType_Output)
    return result
end

function MenuData.PreviewHitSound()
    local volume = GetOptionsMenu():GetOptionWidget("hitSoundVolume"):GetValue()
    local before = Client.GetOptionFloat("hitsound-vol", 0)
    Client.SetOptionFloat("hitsound-vol", volume)
    HitSounds_SyncOptions()
    HitSounds_PlayHitsound(1)
    Client.SetOptionFloat("hitsound-vol", before)
end

function MenuData.GetMapChoices()
    
    Client.RefreshModList()
    
    local mapFileNames
    _, mapFileNames = GetInstalledMapList()
    
    local choices = {}
    for i=1, #mapFileNames do
        
        local newChoice = {}
        newChoice.displayString = mapFileNames[i].name
        newChoice.value = mapFileNames[i].fileName
        table.insert(choices, newChoice)
        
    end
    
    return choices
    
end

-- Adds __tostring member functions to config table members so it can be more succinctly
-- represented in error stack traces.  Takes 'config', ideally the root level of the config table.
-- Should be called before _using_ the table, not after declaring it, as mods might make changes,
-- which would also need debugging info.
-- Safe to call multiple times on the same config table "just in case".
-- Can provide an optional "rootName" which is just a prefix for all the paths shown by the
-- generated __tostring functions.
function MenuData.AddDebugInfo(config, optionalRootName)
    
    RequireType("table", config, "config")
    RequireType({"nil", "string"}, optionalRootName, "optionalRootName")
    
    local currentPath = optionalRootName or ""
    
    -- Attempt to add a __tostring method if one does not exist.
    if rawget(config, "__tostring") == nil then
        local path = #currentPath > 0 and currentPath or "<root>"
        
        -- We don't really care if it works or not, just wrap it in a pcall so if it fails, it fails
        -- silently.
        pcall(function()
            config.__tostring =
                function(config2)
                    return "config table " .. path
                end
        end)
        
    end
    
    -- Recurse to all child tables.
    for key, value in pairs(config) do
        if type(value) == "table" then
            
            local keyString = tostring(key)
            
            -- Try to find a better name for the object.
            if type(key) == "number" then
                local nameField = value.name
                if type(nameField) == "string" then
                    keyString = nameField
                end
            end
            
            -- If the key is just "children", then ignore it.
            local path = currentPath
            if keyString ~= "children" then
                path = #currentPath > 0 and (currentPath.."."..keyString) or keyString
            end
            
            -- Don't recurse any further if this "table" is really a class.
            if value.classname == nil then
                MenuData.AddDebugInfo(value, path)
            end
            
        end
    end
    
end

local function StartSinglePlayerMode(localModPath, mapName)
    local modIndex = Client.GetLocalModId(localModPath)
    assert(modIndex)
    local password      = "dummypassword"..ToString(math.random())
    local port          = 27015
    local maxPlayers    = 1
    local serverName    = "private tutorial server"
    Client.SetOptionString("lastServerMapName", mapName)
    if Client.StartServer(modIndex, mapName, serverName, password, port, maxPlayers, true, true) then
        LeaveMenu()
    end
end

function PlayIntro()
    GUIVideoTutorialIntro_Play(nil, nil)
end

local kTutorials =
{
    "marine",
    "alien",
    "marineComm",
    "alienComm",
}
for i=1, #kTutorials do
    kTutorials[kTutorials[i]] = i
end

local kTutorialConfigs =
{
    marine     = {  mod = "bootcamp/marine_1",    map = "ns2_tut_marine_1", code = "First_0_6", label = Locale.ResolveString("PLAY_TUT1"),  labelLower = Locale.ResolveString("PLAY_TUT1_LOWER") },
    alien      = {  mod = "bootcamp/alien_1",     map = "ns2_tut_alien_1",  code = "First_0_7", label = Locale.ResolveString("PLAY_TUT2"),  labelLower = Locale.ResolveString("PLAY_TUT2_LOWER") },
    marineComm = {  mod = "bootcamp/command_1",   map = "ns2_tut_cmd_1",    code = "First_0_8", label = Locale.ResolveString("PLAY_TUT3"),  labelLower = Locale.ResolveString("PLAY_TUT3_LOWER") },
    alienComm  = {  mod = "bootcamp/command_2",   map = "ns2_tut_cmd_2",    code = "First_0_9", label = Locale.ResolveString("PLAY_TUT4"),  labelLower = Locale.ResolveString("PLAY_TUT4_LOWER") },
}

local spoofNotPlayedTutIdx = 999
Event.Hook("Console_spoof_not_played_tut", function(tutName)
    
    if tutName == nil then
        spoofNotPlayedTutIdx = 999
        Log("cleared the spoofed not-played-tutorial value.")
        return
    end
    
    local idx = kTutorials[tutName]
    if not idx then
        Log("usage: spoof_not_played_tut (marine|alien|marineComm|alienComm)")
        return
    end
    
    spoofNotPlayedTutIdx = idx
    Log("Set spoofed not-played-tutorial value to %s", tutName)
    
end)

function StartTutorial(tutorialName)
    
    assert(kTutorials[tutorialName])
    
    -- Check if previous tutorials have been completed.
    local tutorialIdx = kTutorials[tutorialName]
    local tutorialConfig = kTutorialConfigs[tutorialName]
    assert(tutorialConfig)
    local incompleteTutName
    for i=1, tutorialIdx-1 do
        local prevTutorialName = kTutorials[i]
        local prevTutorialConfig = kTutorialConfigs[prevTutorialName]
        if not Client.GetAchievement(prevTutorialConfig.code) or spoofNotPlayedTutIdx == i then
            incompleteTutName = prevTutorialName
            break
        end
    end
    
    local function StartTutorialFunc()
        StartSinglePlayerMode(tutorialConfig.mod, tutorialConfig.map)
    end
    
    if incompleteTutName then
        
        local incompleteTutConfig = kTutorialConfigs[incompleteTutName]
        
        -- Popup, urging the user to complete earlier tutorials first.
        local popup = CreateGUIObject("popup", GUIMenuPopupSimpleMessage, nil,
        {
            title = Locale.ResolveString("PLAY_TUT"),
            message = string.format(Locale.ResolveString("PLAY_TUT_OUT_OF_ORDER_MESSAGE"), incompleteTutConfig.labelLower),
            buttonConfig =
            {
                -- Play Anyways button.
                {
                    name = "playAnyways",
                    params =
                    {
                        label = Locale.ResolveString("PLAY_TUT_ANYWAYS"),
                    },
                    callback = StartTutorialFunc,
                },
                
                -- Play older tutorial button.
                {
                    name = "playEarlier",
                    params =
                    {
                        label = Locale.ResolveString("PLAY_TUT_PLAY_FIRST"),
                    },
                    callback =
                        function()
                            StartSinglePlayerMode(incompleteTutConfig.mod, incompleteTutConfig.map)
                        end,
                },
                
                -- Cancel Button.
                GUIPopupDialog.CancelButton,
                
            },
        })
        
    else
        StartTutorialFunc()
    end
    
end


function StartMarineTutorial()
    StartTutorial("marine")
end

function StartAlienTutorial()
    StartTutorial("alien")
end

function StartMarineCommanderTutorial()
    StartTutorial("marineComm")
end

function StartAlienCommanderTutorial()
    StartTutorial("alienComm")
end

function StartHiveChallenge()
    StartSinglePlayerMode("challenges/hive_challenge", "ns2_ch_hive_platform")
end

function StartSkulkChallenge()
    StartSinglePlayerMode("challenges/skulk_challenge", "ns2_skulk_challenge_1")
end
