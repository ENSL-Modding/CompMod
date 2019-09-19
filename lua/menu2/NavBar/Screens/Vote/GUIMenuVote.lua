-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/menu2/NavBar/Screens/Vote/GUIMenuVote.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Menu to call votes in-game.
--
--  Properties
--      Label       Label to use for the current menu (eg "VOTE" when at main menu, "KICK PLAYER"
--                  when on that menu, etc.).
--      List        The currently displayed list of options.
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/menu2/NavBar/Screens/GUIMenuNavBarScreen.lua")
Script.Load("lua/menu2/GUIMenuBasicBox.lua")
Script.Load("lua/menu2/GUIMenuTabbedBox.lua")
Script.Load("lua/menu2/widgets/GUIMenuTabButtonsWidget.lua")
Script.Load("lua/menu2/MenuData.lua")
Script.Load("lua/GUI/GUIGlobalEventDispatcher.lua")
Script.Load("lua/GUI/layouts/GUIListLayout.lua")
Script.Load("lua/menu2/MenuStyles.lua")
Script.Load("lua/GUI/style/GUIStyledText.lua")

Script.Load("lua/menu2/NavBar/Screens/Vote/GUIMenuVoteList.lua")

---@class GUIMenuVote : GUIMenuNavBarScreen
class "GUIMenuVote" (GUIMenuNavBarScreen)

local voteMenu
function GetVoteMenu()
    return voteMenu
end

-- how many pixels to leave between the bottom of the screen and the bottom of this screen.
local kScreenBottomDistance = 500 --250
local kScreenWidth = 1200 --1500 --2577

local kTabHeight = 94
local kTabMinWidth = 900

local kInnerBackgroundSideSpacing = 32 -- horizontal spacing between edge of outer background and inner background.
local kInnerBackgroundTopSpacing = 212 -- spacing between top edge of outer background and inner background.
-- spacing between bottom edge of outer background and inner background (not including tab height!).
local kInnerBackgroundBottomSpacing = 16

local kTitleYOffset = 104

GUIMenuVote:AddCompositeClassProperty("Label", "label", "Text")
GUIMenuVote:AddClassProperty("List", GUIObject.NoObject, true)

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

local function GoToParentList(self, immediate)
    
    local currentList = self:GetList()
    if currentList == self.mainList or currentList == GUIObject.NoObject then
        return
    end
    
    local parentList = currentList:GetParentList()
    assert(parentList)
    if immediate then
        currentList:Destroy()
    else
        currentList:HideAndDestroy()
    end
    self:SetList(parentList)
    parentList:Reveal(immediate)
    
end

local function GoToMainList(self, immediate)
    
    local currentList = self:GetList()
    while currentList ~= self.mainList do
        GoToParentList(self, immediate)
        currentList = self:GetList()
    end
    
end

local function OnBackPressed(self)
    
    local currentList = self:GetList()
    if currentList == GUIObject.NoObject or currentList == self.mainList then
        self:OnBack()
    else
        GoToParentList(self)
    end
    
end

local function GetSelectedOption(self)
    local selectedOption = GUIObject.NoObject
    local currentList = self:GetList()
    if currentList ~= GUIObject.NoObject then
        selectedOption = currentList:GetSelectedOption()
    end
    return selectedOption
end

local function UpdateButtonEnabledState(self)
    
    local selectedOption = GetSelectedOption(self)
    self.bottomButtons:SetRightEnabled(selectedOption ~= GUIObject.NoObject)
    
end

local function UpdateLabel(self)
    
    local currentList = self:GetList()
    if currentList == GUIObject.NoObject then
        self:SetLabel(Locale.ResolveString("VOTE"))
    else
        self:SetLabel(currentList:GetLabelText())
    end
    
end

local function OnListChanged(self, newList, prevList)
    
    if prevList ~= GUIObject.NoObject then
        self:UnHookEvent(prevList, "OnSelectedOptionChanged", UpdateButtonEnabledState)
    end
    
    if newList ~= GUIObject.NoObject then
        self:HookEvent(newList, "OnSelectedOptionChanged", UpdateButtonEnabledState)
    end
    
    UpdateButtonEnabledState(self)
    UpdateLabel(self)
    
end

local function OnBeginVotePressed(self)
    
    local selectedOption = GetSelectedOption(self)
    assert(selectedOption ~= GUIObject.NoObject) -- button should not have been enabled if false!
    
    assert(selectedOption.startFunc)
    
    selectedOption.startFunc(selectedOption.data)
    
    GoToMainList(self, true) -- Go back to the main list immediately.  This cleans up submenus.
    self.OnBack() -- go back to the nav bar (for when the player opens the menu next time).
    GetMainMenu():Close()
    
end

local function OnScreenDisplay(self)
    
    -- Ensure that whenever this menu is displayed, it starts at the main list.
    GoToMainList(self, true) -- Go back to the main list immediately.  This cleans up submenus.
    
end

function GUIMenuVote:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    voteMenu = self
    
    PushParamChange(params, "screenName", "Vote")
    GUIMenuNavBarScreen.Initialize(self, params, errorDepth)
    PopParamChange(params, "screenName")
    
    self:GetRootItem():SetDebugName("voteMenu")
    self:ListenForCursorInteractions() -- prevent click-through
    
    -- Background (two layers, the "cool" layer, and a basic layer on top of that).
    self.coolBack = CreateGUIObject("coolBack", GUIMenuTabbedBox, self)
    self.coolBack:SetLayer(-2)
    self.coolBack:SetPosition(0, -GUIMenuNavBar.kUnderlapYSize)
    
    self.label = CreateGUIObject("label", GUIStyledText, self.coolBack,
    {
        style = MenuStyle.kMainBarButtonText,
        font = MenuStyle.kNavBarFont,
        align = "top",
        position = Vector(0, kTitleYOffset, 0),
    })
    
    self.innerBack = CreateGUIObject("innerBack", GUIMenuBasicBox, self)
    self.innerBack:SetLayer(1)
    self.innerBack:SetPosition(kInnerBackgroundSideSpacing, kInnerBackgroundTopSpacing - GUIMenuNavBar.kUnderlapYSize)
    self:HookEvent(self.coolBack, "OnSizeChanged", UpdateInnerBackgroundSize)
    
    -- Create bottom tab buttons.  These change based on which options menu is selected.
    self.bottomButtons = CreateGUIObject("bottomButtons", GUIMenuTabButtonsWidget, self)
    self.bottomButtons:SetLayer(2)
    self.bottomButtons:AlignBottom()
    self.bottomButtons:SetLeftLabel(Locale.ResolveString("BACK"))
    self.bottomButtons:SetRightLabel(Locale.ResolveString("VOTE_CALL_VOTE"))
    self.bottomButtons:SetRightEnabled(false)
    self.bottomButtons:SetTabMinWidth(kTabMinWidth)
    self.bottomButtons:SetTabHeight(kTabHeight)
    self.bottomButtons:SetFont(MenuStyle.kButtonFont)
    self.coolBack:HookEvent(self.bottomButtons, "OnTabSizeChanged", self.coolBack.SetTabSize)
    self.coolBack:SetTabSize(self.bottomButtons:GetTabSize())
    self:HookEvent(self.bottomButtons, "OnLeftPressed", OnBackPressed)
    self:HookEvent(self.bottomButtons, "OnRightPressed", OnBeginVotePressed)
    
    EnableOnAbsoluteScaleChangedEvent(self)
    self:HookEvent(self, "OnAbsoluteScaleChanged", OnAbsoluteScaleChanged)
    self:HookEvent(GetGlobalEventDispatcher(), "OnResolutionChanged", RecomputeScreenHeight)
    
    self:HookEvent(self, "OnSizeChanged", OnOptionsMenuSizeChanged)
    
    -- Keep track of which list is being displayed so we can known which lists' selection to take
    -- into account.  This allows us to enable/disable the begin vote button accordingly.
    self:HookEvent(self, "OnListChanged", OnListChanged)
    
    self.mainListHolder = CreateGUIObject("mainListHolder", GUIObject, self.innerBack)
    self.mainListHolder:SetSyncToParentSize(true)
    self.mainListHolder:SetCropMax(1, 1)
    
    self.mainList = CreateGUIObject("mainList", GUIMenuVoteList, self.mainListHolder,
    {
        owningMenu = self,
        listLabel = Locale.ResolveString("VOTE"),
        suppressRevealAnimation = true,
    })
    
    -- Inform the voting class that we're ready to add vote types.
    OnGUIStartVoteMenuCreated("GUIStartVoteMenu", self) -- spoof name of legacy system.
    
    self:HookEvent(self, "OnScreenDisplay", OnScreenDisplay)
    
end

function GUIMenuVote:AddMainMenuOption(label, generateMenuFunc, startVoteFunc)
    self.mainList:AddOption(label, generateMenuFunc, startVoteFunc, nil)
end
