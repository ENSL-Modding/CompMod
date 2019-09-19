-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/menu2/NavBar/Screens/Options/Mods/ModsMenuData.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Creates the list of mods and options to go with those mods.
--    Modders: post-hook this file and add to the list to add options for your mods.
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/menu2/GUIMenuCategoryDisplayBoxEntry.lua")
Script.Load("lua/menu2/NavBar/Screens/Options/Mods/GUIMenuModScreen.lua")
Script.Load("lua/menu2/NavBar/Screens/Options/Mods/GUIMenuManageModsDisplayBoxEntry.lua")

ModsMenuUtils = {}

-- Combines the key-value pairs of two tables.  If there are collisions, a's table takes precedence.
function ModsMenuUtils.CombineParams(a, b)
    assert(type(a) == "table")
    assert(type(b) == "table")
    local result = {}
    for key, value in pairs(b) do
        result[key] = value
    end
    for key, value in pairs(a) do
        result[key] = value
    end
    return result
end

-- Combines the array-parts of two tables.
function ModsMenuUtils.CombineLists(a, b)
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

function ModsMenuUtils.SyncToParentSize(self)
    local parentObject = self:GetParent()
    assert(parentObject)
    self:HookEvent(parentObject, "OnSizeChanged", self.SetSize)
end

function ModsMenuUtils.SyncParentPaneHeightToSize(self)
    local parentObject = self:GetParent()
    assert(parentObject)
    parentObject:HookEvent(self, "OnSizeChanged", parentObject.SetPaneHeight)
end

local function SyncWidth(self, size)
    self:SetSize(size.x, self:GetSize().y)
end

function ModsMenuUtils.SyncWidthToParentWidth(self)
    local parentObject = self:GetParent()
    assert(parentObject)
    self:HookEvent(parentObject, "OnSizeChanged", SyncWidth)
end

local function SyncWidthWithPadding(self, size)
    self:SetWidth(size.x - 128)
end

local function SyncWidthToParentContentsWidthWithPadding(self)
    local parentObj = self:GetParent()
    assert(parentObj)
    self:HookEvent(parentObj, "OnContentsSizeChanged", SyncWidthWithPadding)
end

local function SyncPaneWidthToSize(self)
    local parentObj = self:GetParent()
    assert(parentObj)
    self:HookEvent(self, "OnSizeChanged", self.SetPaneWidth)
end

function ModsMenuUtils.CreateBasicModsMenuContents(paramTable)
    
    RequireType("string", paramTable.layoutName, "paramTable.layoutName")
    RequireType("table", paramTable.contents, "paramTable.contents")
    RequireType({"table", "nil"}, paramTable.layoutParams, "paramTable.layoutParams")
    
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
            ModsMenuUtils.SyncToParentSize,
            SyncPaneWidthToSize,
        },
        
        children =
        {
            {
                name = paramTable.layoutName,
                class = GUIListLayout,
                params = ModsMenuUtils.CombineParams(paramTable.layoutParams or {},
                {
                    orientation = "vertical",
                    fixedMinorSize = true,
                    frontPadding = 32,
                    backPadding = 32,
                    spacing = 32,
                }),
                postInit = ModsMenuUtils.CombineLists(
                        type(paramTable.postInit) == "nil" and {} or
                        type(paramTable.postInit) == "function" and {paramTable.postInit} or
                        paramTable.postInit,
                {
                    ModsMenuUtils.SyncParentPaneHeightToSize,
                    SyncWidthToParentContentsWidthWithPadding,
                    function(self) self:AlignTop() end,
                }),
                
                children = paramTable.contents,
            },
        },
    }
    
end

gModsCategories = {}

if kInGame then
    -- Don't allow mods to be managed when in-game.  Instead, create the button for it, but disable
    -- it with a tooltip.
    table.insert(gModsCategories,
    {
        categoryName = "manageMods",
        entryConfig =
        {
            name = "manageModsEntry",
            class = GUIMenuCategoryDisplayBoxEntry,
            params =
            {
                label = Locale.ResolveString("MENU_MANAGE_MODS"),
            }
        },
        contentsConfig =
        {
            name = "disabledTooltipHolder",
            class = GUIObject,
            postInit = ModsMenuUtils.SyncToParentSize,
            children =
            {
                { -- Text explaining why the screen is blank.
                    name = "disabledTooltip",
                    class = GUIText,
                    params =
                    {
                        text = Locale.ResolveString("MENU_MODS_MANAGEMENT_DISABLED_TOOLTIP"),
                        fontFamily = "Agency",
                        fontSize = 48,
                        color = MenuStyle.kOptionHeadingColor,
                        align = "center",
                    }
                }
            }
        },
    })
else
    -- Create mod manage screen if not in-game.
    table.insert(gModsCategories,
    {
        categoryName = "manageMods",
        entryConfig =
        {
            name = "manageModsEntry",
            class = GUIMenuManageModsDisplayBoxEntry,
            params =
            {
                label = Locale.ResolveString("MENU_MANAGE_MODS"),
            },
        },
        contentsConfig =
        {
            name = "modsScreen",
            class = GUIMenuModScreen,
            postInit = ModsMenuUtils.SyncToParentSize,
        },
    })
end

