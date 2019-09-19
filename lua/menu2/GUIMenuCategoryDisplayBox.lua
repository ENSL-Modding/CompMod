-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/menu2/GUIMenuCategoryDisplayBox.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    A box that contains a space on the left to select from different categories to display on the
--    right.
--
--  Parameters (* = required)
--      categories      Array of categories to initialize this object with.  Each "category" in the
--                      array is a table containing the following key-value pairs:
--                          categoryName    Name of the category.  Must be unique.
--                          entryConfig     Config of the entry to place in the list on the left.
--                          contentsConfig  Config of the contents to display on the right when
--                                          category is active.
--
--  Properties
--      ActiveCategoryName      The name of the currently selected category.
--
--  Events
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/GUI/GUIObject.lua")
Script.Load("lua/GUI/layouts/GUIFillLayout.lua")

---@class GUIMenuCategoryDisplayBox : GUIObject
class "GUIMenuCategoryDisplayBox" (GUIObject)

GUIMenuCategoryDisplayBox:AddClassProperty("ActiveCategoryName", "")

local kLeftSideWeight = 0.3
local kRightSideWeight = 1 - kLeftSideWeight

local function OnActiveCategoryNameChanged(self, categoryName, prevCategoryName)
    
    if prevCategoryName ~= "" then
        local prevActiveEntry = self.entries[prevCategoryName]
        if prevActiveEntry then
            prevActiveEntry:SetSelected(false)
        end
        
        local prevActiveRoot = self.roots[prevCategoryName]
        if prevActiveRoot then
            prevActiveRoot:SetVisible(false)
        end
    end
    
    if categoryName ~= "" then
        local activeEntry = self.entries[categoryName]
        if activeEntry then
            activeEntry:SetSelected(true)
        end
        
        local activeRoot = self.roots[categoryName]
        if activeRoot then
            activeRoot:SetVisible(true)
        end
    end
    
end

function GUIMenuCategoryDisplayBox:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    RequireType({"table", "nil"}, params.categories, "params.categories", errorDepth)
    if params.categories then
        for i=1, #params.categories do
            RequireType("table", params.categories[i], string.format("params.categories[%d]", i), errorDepth)
            RequireType("string", params.categories[i].categoryName, string.format("params.categories[%d].categoryName", i), errorDepth)
            RequireType("table", params.categories[i].entryConfig, string.format("params.categories[%d].entryConfig", i), errorDepth)
            RequireType("table", params.categories[i].contentsConfig, string.format("params.categories[%d].contentsConfig", i), errorDepth)
        end
    end
    
    GUIObject.Initialize(self, params, errorDepth)
    
    -- Main layout to hold the left and right sections.
    self.layout = CreateGUIObject("layout", GUIFillLayout, self,
    {
        orientation = "horizontal",
        fixedMinorSize = true,
    })
    self.layout:HookEvent(self, "OnSizeChanged", self.layout.SetSize) -- Sync to parent size.
    
    -- Left side scroll pane.
    self.leftScrollPane = CreateGUIObject("leftScrollPane", GUIMenuScrollPane, self.layout,
    {
        weight = kLeftSideWeight,
        horizontalScrollBarEnabled = false,
    })
    self.leftScrollPane:HookEvent(self.layout, "OnSizeChanged", self.leftScrollPane.SetHeight)
    
    -- Left side layout
    self.leftLayout = CreateGUIObject("leftLayout", GUIListLayout, self.leftScrollPane,
    {
        orientation = "vertical",
        fixedMinorSize = true,
    })
    self.leftLayout:HookEvent(self.leftScrollPane, "OnContentsSizeChanged", self.leftLayout.SetWidth)
    self.leftScrollPane:HookEvent(self.leftLayout, "OnSizeChanged", self.leftScrollPane.SetPaneHeight)
    
    -- Right side contents holder (for all contents -- they'll stack up, but only one will be
    -- visible at a time).
    self.rightGroup = CreateGUIObject("rightGroup", GUIObject, self.layout,
    {
        weight = kRightSideWeight,
    })
    self.rightGroup:HookEvent(self.layout, "OnSizeChanged", self.rightGroup.SetHeight)
    
    -- Mapping of categoryName string --> categoryEntry object
    self.entries = {}
    
    -- Mapping of categoryName string --> categoryRoot object.
    self.roots = {}
    
    self.even = false
    
    if params.categories then
        for i=1, #params.categories do
            local category = params.categories[i]
            self:AddCategory(category.categoryName, category.entryConfig, category.contentsConfig)
        end
    end
    
    self:HookEvent(self, "OnActiveCategoryNameChanged", OnActiveCategoryNameChanged)
    
end

local function OnEntryPressed(entry)
    
    local self = entry.owningCategoryDisplayBox
    assert(self)
    
    PlayMenuSound("ButtonClick")
    
    self:SetActiveCategoryName(entry.categoryName)
    
end

function GUIMenuCategoryDisplayBox:AddCategory(categoryName, entryConfig, contentsConfig)
    
    RequireType("string", categoryName, "categoryName", 2)
    RequireType("table", entryConfig, "entryConfig", 2)
    RequireType("table", contentsConfig, "contentsConfig", 2)
    
    if self.entries[categoryName] then
        error(string.format("A category named '%s' already exists!", categoryName), 2)
    end
    assert(self.roots[categoryName] == nil) -- shouldn't exist if it didn't exist in entries.
    
    local newEntry = CreateGUIObjectFromConfig(entryConfig, self.leftLayout)
    newEntry:HookEvent(self.leftLayout, "OnSizeChanged", newEntry.SetWidth)
    newEntry:SetWidth(self.leftLayout:GetSize())
    newEntry.owningCategoryDisplayBox = self
    newEntry.categoryName = categoryName
    newEntry:SetIndexEven(self.even)
    self.even = not self.even
    
    newEntry:HookEvent(newEntry, "OnPressed", OnEntryPressed)
    
    -- Entries must have a "SetSelected" method (or Selected property).
    RequireMethod(newEntry, "SetSelected", 2)
    
    local newRoot = CreateGUIObjectFromConfig(contentsConfig, self.rightGroup)
    newRoot:SetVisible(false)
    
    self.entries[categoryName] = newEntry
    self.roots[categoryName] = newRoot
    
    -- Make the first-added category the currently active one.
    if self:GetActiveCategoryName() == "" then
        self:SetActiveCategoryName(categoryName)
        newEntry:SetSelected(true)
        newRoot:SetVisible(true)
    end
    
end
