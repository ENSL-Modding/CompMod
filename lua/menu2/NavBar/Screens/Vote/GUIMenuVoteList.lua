-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/menu2/NavBar/Screens/Vote/GUIMenuVoteList.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    List of the sub-options available for a vote.
--
--  Parameters (* = required)
--     *owningMenu                  The menu that owns this list and all its sub-lists (eg the vote
--                                  menu).  Provide it here rather than using the GetVoteMenu()
--                                  global so we can re-use these classes with minimal changes.
--     *listLabel                   The label the vote menu will take on when this list is
--                                  displayed.
--      parentList                  The parent list of this list, if any.
--      suppressRevealAnimation     If true, don't show the opening animation.
--
--  Properties
--      SelectedOption      Currently selected vote option, or GUIObject.NoObject for none.
--
--  Events
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/GUI/GUIObject.lua")
Script.Load("lua/GUI/layouts/GUIListLayout.lua")

Script.Load("lua/menu2/widgets/GUIMenuScrollPane.lua")

Script.Load("lua/menu2/NavBar/Screens/Vote/GUIMenuVoteOption.lua")

class "GUIMenuVoteList" (GUIObject)

GUIMenuVoteList:AddClassProperty("SelectedOption", GUIObject.NoObject, true)

function GUIMenuVoteList:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    RequireIsa("GUIObject", params.owningMenu, "params.owningMenu", errorDepth)
    RequireType("string", params.listLabel, "params.listLabel", errorDepth)
    if params.parentList ~= nil then
        RequireIsa("GUIObject", params.parentList, "params.parentList", errorDepth)
    end
    RequireType({"boolean", "nil"}, params.suppressRevealAnimation, "params.suppressRevealAnimation", errorDepth)
    
    GUIObject.Initialize(self, params, errorDepth)
    
    self.listLabelText = params.listLabel
    
    self:SetSyncToParentSize(true)
    
    self.scrollPane = CreateGUIObject("scrollPane", GUIMenuScrollPane, self,
    {
        horizontalScrollBarEnabled = false,
    })
    self.scrollPane:SetSyncToParentSize(true)
    
    self.layout = CreateGUIObject("layout", GUIListLayout, self.scrollPane,
    {
        orientation = "vertical",
        fixedMinorSize = true,
    })
    self.layout:HookEvent(self.scrollPane, "OnContentsSizeChanged", self.layout.SetWidth)
    self.scrollPane:HookEvent(self.layout, "OnSizeChanged", self.scrollPane.SetPaneHeight)
    
    self.owningMenu = params.owningMenu
    self.parentList = params.parentList
    
    -- Animate the new list in from the side.
    if not params.suppressRevealAnimation then
        self:SetAnchor(1, 0)
        self:AnimateProperty("Anchor", Vector(0, 0, 0), MenuAnimations.FlyIn)
    end
    
    self.owningMenu:SetList(self)
    
end

function GUIMenuVoteList:GetLabelText()
    return self.listLabelText
end

function GUIMenuVoteList:GetParentList()
    return self.parentList
end

local function UpdateSelectionFromListSelection(option, selectedObject)
    option:SetSelected(option == selectedObject)
end

local function SanitizeLabelForGUIObjectName(name)
    name = string.gsub(name, "%.", "")
    name = string.gsub(name, "%:", "")
    name = string.gsub(name, "/", "")
    name = string.gsub(name, " ", "_")
    return name
end

function GUIMenuVoteList:AddOption(label, generateMenuFunc, startVoteFunc, data)
    
    RequireType("string", label, "label", 2)
    RequireType({"function", "nil"}, generateMenuFunc, "generateMenuFunc", 2)
    RequireType({"function", "nil"}, startVoteFunc, "startVoteFunc", 2)
    RequireType({"table", "nil"}, data, "data", 2)
    
    if generateMenuFunc ~= nil and data ~= nil then
        error("Attempt to call GUIMenuVoteList:AddOption with both gnerateMenuFunc and data provided -- must be one or the other!", 2)
    end
    
    local name = SanitizeLabelForGUIObjectName("option_"..label)
    local newOption = CreateGUIObject(name, GUIMenuVoteOption, self.layout,
    {
        owningList = self,
        label = label,
        data = data,
        startFunc = startVoteFunc,
        genFunc = generateMenuFunc,
    })
    
    -- Sync width of option to the width of the layout.
    newOption:HookEvent(self.layout, "OnSizeChanged", newOption.SetWidth)
    
    -- Link this option's "Selected" property with the list's "SelectedOption" property.
    newOption:HookEvent(self, "OnSelectedOptionChanged", UpdateSelectionFromListSelection)
    
end

function GUIMenuVoteList:CreateSubMenu(label, generatorFunction, startVoteFunc)
    
    local name = SanitizeLabelForGUIObjectName("list_"..label)
    local newSubMenu = CreateGUIObject(name, GUIMenuVoteList, self:GetParent(),
    {
        owningMenu = self.owningMenu,
        listLabel = label,
        parentList = self,
    })
    
    local genFuncResults = generatorFunction()
    for i=1, #genFuncResults do
        local result = genFuncResults[i]
        newSubMenu:AddOption(result.text, result.generateMenuFunc, startVoteFunc, result.extraData)
    end
    
    self:Hide()
    
end

-- Reveals the previously-hidden vote list.
function GUIMenuVoteList:Reveal(immediate)
    
    -- Will appear to slide in from the left, (where it was just hidden).
    self:SetVisible(true)
    if immediate then
        self.scrollPane:SetAnchor(0, 0)
    else
        self.scrollPane:AnimateProperty("Anchor", Vector(0, 0, 0), MenuAnimations.FlyIn)
    end
    
end

local function OnHideAnimationFinished(self, animationName)
    if animationName == "hideAnimation" then
        self:SetVisible(false)
    end
end

-- Animates the list off-screen to the left, to display sub options.
function GUIMenuVoteList:Hide()

    -- Will appear to slide all the way to the left, and once out of sight, makes it invisible.
    self.scrollPane:AnimateProperty("Anchor", Vector(-1, 0, 0), MenuAnimations.FlyIn, "hideAnimation")
    self:HookEvent(self.scrollPane, "OnAnimationFinished", OnHideAnimationFinished)

end

local function OnDestroyAnimationFinished(self, animationName)
    if animationName == "destroyAnimation" then
        self:Destroy()
    end
end

-- Animates the list off-screen to the right, and once out of sight, destroys it.  This is used when
-- a vote menu is backed-out of.
function GUIMenuVoteList:HideAndDestroy()

    -- Will appear to slide all the way to the right and then be destroyed.
    self.scrollPane:AnimateProperty("Anchor", Vector(1, 0, 0), MenuAnimations.FlyIn, "destroyAnimation")
    self:HookEvent(self.scrollPane, "OnAnimationFinished", OnDestroyAnimationFinished)

end
