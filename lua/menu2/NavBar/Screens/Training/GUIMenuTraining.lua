-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/menu2/NavBar/Screens/Training/GUIMenuTraining.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Training menu for intro, tutorials, and bootcamp option.
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/menu2/NavBar/Screens/GUIMenuNavBarScreen.lua")
Script.Load("lua/menu2/GUIMenuBasicBox.lua")
Script.Load("lua/menu2/GUIMenuTabbedBox.lua")
Script.Load("lua/menu2/widgets/GUIMenuTabButtonsWidget.lua")
Script.Load("lua/menu2/MenuData.lua")
Script.Load("lua/GUI/GUIGlobalEventDispatcher.lua")

---@class GUIMenuTraining : GUIMenuNavBarScreen
class "GUIMenuTraining" (GUIMenuNavBarScreen)

local trainingMenu
function GetTrainingMenu()
    return trainingMenu
end

-- how many pixels to leave between the bottom of the screen and the bottom of this screen.
local kScreenBottomDistance = 250
local kScreenWidth = 2577

local kTabHeight = 94
local kTabMinWidth = 900

local kInnerBackgroundSideSpacing = 32 -- horizontal spacing between edge of outer background and inner background.
local kInnerBackgroundTopSpacing = 162 -- spacing between top edge of outer background and inner background.
-- spacing between bottom edge of outer background and inner background (not including tab height!).
local kInnerBackgroundBottomSpacing = 16

local function UpdateInnerBackgroundSize(self, coolBackSize)
    self.innerBack:SetSize(coolBackSize - Vector(kInnerBackgroundSideSpacing * 2, kInnerBackgroundBottomSpacing + kInnerBackgroundTopSpacing + kTabHeight, 0))
end

local function OnOptionsMenuSizeChanged(self)
    -- Make the outer background the same size as this object.
    self.coolBack:SetSize(self:GetSize() + Vector(0, GUIMenuNavBar.kUnderlapYSize, 0))
    self.innerBack:SetSize(self:GetSize() + Vector(-kInnerBackgroundSideSpacing * 2, GUIMenuNavBar.kUnderlapYSize - kInnerBackgroundTopSpacing - kInnerBackgroundBottomSpacing - kTabHeight, 0))
end

local function RecomputeScreenHeight(self)
    
    -- Resize this object to leave a consistent spacing to the bottom of the screen.
    local aScale = self.absoluteScale
    local ssSpacing = kScreenBottomDistance * aScale.y
    local ssBottomY = Client.GetScreenHeight() - ssSpacing
    local ssTopY = self:GetParent():GetScreenPosition().y
    local ssSizeY = ssBottomY - ssTopY
    local localSizeY = ssSizeY / aScale.y
    self:SetSize(kScreenWidth, localSizeY)
    
end

local function OnAbsoluteScaleChanged(self, aScale)
    
    self.absoluteScale = aScale
    RecomputeScreenHeight(self)
    
end

function GUIMenuTraining:SetActionButtonLabel(text)
    self.bottomButtons:SetRightLabel(text)
end

function GUIMenuTraining:SetActionButtonCallback(callback)
    self.actionButtonCallback = callback
end

function GUIMenuTraining:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    trainingMenu = self
    
    PushParamChange(params, "screenName", "Training")
    GUIMenuNavBarScreen.Initialize(self, params, errorDepth)
    PopParamChange(params, "screenName")
    
    self.actionButtonCallback = PlayIntro
    
    self:GetRootItem():SetDebugName("trainingMenu")
    self:ListenForCursorInteractions() -- prevent click-through
    
    -- Background (two layers, the "cool" layer, and a basic layer on top of that).
    self.coolBack = CreateGUIObject("coolBack", GUIMenuTabbedBox, self)
    self.coolBack:SetLayer(-2)
    self.coolBack:SetPosition(0, -GUIMenuNavBar.kUnderlapYSize)
    
    self.innerBack = CreateGUIObject("innerBack", GUIMenuBasicBox, self)
    self.innerBack:SetLayer(1)
    self.innerBack:SetPosition(kInnerBackgroundSideSpacing, kInnerBackgroundTopSpacing - GUIMenuNavBar.kUnderlapYSize)
    self:HookEvent(self.coolBack, "OnSizeChanged", UpdateInnerBackgroundSize)
    
    -- Create bottom tab buttons.  These change based on which options menu is selected.
    self.bottomButtons = CreateGUIObject("bottomButtons", GUIMenuTabButtonsWidget, self)
    self.bottomButtons:SetLayer(2)
    self.bottomButtons:AlignBottom()
    self.bottomButtons:SetLeftLabel(Locale.ResolveString("BACK"))
    self.bottomButtons:SetRightLabel(Locale.ResolveString("REPLAY_INTRO_VIDEO_ACTION")) -- default selection is intro.
    self.bottomButtons:SetTabMinWidth(kTabMinWidth)
    self.bottomButtons:SetTabHeight(kTabHeight)
    self.bottomButtons:SetFont(MenuStyle.kButtonFont)
    self.coolBack:HookEvent(self.bottomButtons, "OnTabSizeChanged", self.coolBack.SetTabSize)
    self.coolBack:SetTabSize(self.bottomButtons:GetTabSize())
    self:HookEvent(self.bottomButtons, "OnLeftPressed", self.OnBack)
    self:HookEvent(self.bottomButtons, "OnRightPressed", function(self2) self2.actionButtonCallback() end)
    
    EnableOnAbsoluteScaleChangedEvent(self)
    self:HookEvent(self, "OnAbsoluteScaleChanged", OnAbsoluteScaleChanged)
    self:HookEvent(GetGlobalEventDispatcher(), "OnResolutionChanged", RecomputeScreenHeight)
    
    self:HookEvent(self, "OnSizeChanged", OnOptionsMenuSizeChanged)
    
    self.contents = CreateGUIObjectFromConfig(MenuData.TrainingMenu, self.innerBack)
    self.contents:HookEvent(self.innerBack, "OnSizeChanged", self.contents.SetSize)
    self.contents:SetSize(self.innerBack:GetSize())
    
end
