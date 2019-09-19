-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/NavBar/Screens/Options/GUIMenuOptions.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Options menu.  Options themselves are defined in MenuData.lua.  This just pulls it all
--    together and sticks it inside a GUIObject.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/menu2/NavBar/Screens/GUIMenuNavBarScreen.lua")
Script.Load("lua/menu2/GUIMenuBasicBox.lua")
Script.Load("lua/menu2/GUIMenuTabbedBox.lua")
Script.Load("lua/menu2/widgets/GUIMenuTabButtonsWidget.lua")
Script.Load("lua/menu2/NavBar/Screens/Options/GUIMenuOptionsBarButton.lua")
Script.Load("lua/menu2/MenuData.lua")
Script.Load("lua/IterableDict.lua")
Script.Load("lua/menu2/popup/GUIMenuPopupSimpleMessage.lua")
Script.Load("lua/menu2/GUIMenuCategoryDisplayBoxEntry.lua")
Script.Load("lua/menu2/NavBar/Screens/Options/Mods/GUIMenuModEntry.lua")
Script.Load("lua/menu2/GUIModDataManager.lua")
Script.Load("lua/GUI/GUIGlobalEventDispatcher.lua")

-- Load mods menu data now.  Mods should post-hook this to add their own options menus.
Script.Load("lua/menu2/NavBar/Screens/Options/Mods/ModsMenuData.lua")


local kInitScreenOptionKey = "system/options-menu-init-screen"

---@class GUIMenuOptions : GUIMenuNavBarScreen
class "GUIMenuOptions" (GUIMenuNavBarScreen)

GUIMenuOptions:AddCompositeClassProperty("_ChildWindowsAnchor", "childWindows", "Anchor")

-- Singleton accessor.  Does not create options menu if it doesn't already exist, so keep in mind
-- that it can return nil.
local optionsMenu
function GetOptionsMenu()
    return optionsMenu
end

-- how many pixels to leave between the bottom of the screen and the bottom of this screen.
local kScreenBottomDistance = 250
local kScreenWidth = 2577

local kTabHeight = 94
local kTabMinWidth = 900
local kRestartRequiredTextOffsetY = 4

local kInnerBackgroundSideSpacing = 32 -- horizontal spacing between edge of outer background and inner background.
local kInnerBackgroundTopSpacing = 212 -- spacing between top edge of outer background and inner background.
-- spacing between bottom edge of outer background and inner background (not including tab height!).
local kInnerBackgroundBottomSpacing = 16

local kHeaderBarTexture = PrecacheAsset("ui/newMenu/optionsNavBarBack.dds")

local kButtonBarSize = Vector(2509, 118, 0)

-- Extra y to add to the position of the child contents (and subtract from y-size) to prevent
-- header bar from overlapping options menu contents.
local kButtonBarOverlapOffset = 22

-- Returns true if there are unsaved changes to the values of the options in the options menu.
function GUIMenuOptions:GetHasPendingChanges()
    return self.previousValues ~= nil or self.previousSubValues ~= nil
end

local function OnRestartClicked(self)
    
    -- Restart button shouldn't have been clickable if the client was in a game.
    if Client.GetIsConnected() then
        Log("WARNING: Client was able to click restart button when connected to a server.  The button should not have been enabled.")
        return
    end
    
    -- Do popup if there are pending changes yet-to-be-applied before restarting the client.
    if self:GetHasPendingChanges() then
        self:DoPendingChangesPopup(OnRestartClicked)
        return
    end
    
    self:RestartClient()
    
end

local function OnBackClicked(self)
    
    -- Do popup if there are pending changes yet-to-be-applied before navigating away from the options menu.
    if self:GetHasPendingChanges() then
        self:DoPendingChangesPopup(OnBackClicked)
        return
    end
    
    -- Go back to the previous screen.
    self:OnBack()
    
end

local function OnRightButtonClicked(self)
    self.rightButtonCallback(self)
end

local function OnApplyClicked(self)
    self:ApplyChanges()
end

local kButtonData =
{
    __tostring = function() return "{...}" end,
    
    { -- 1 - General
        name = "general",
        subScreenName = "General",
        localeString = "GENERAL",
        textOffset = Vector(59, 0, 0),
        polygon = -- relative to "buttonBar" locator item.
        {
            Vector(  0,   0, 0),
            Vector(118, 118, 0),
            Vector(552, 118, 0),
            Vector(552,   0, 0),
        },
        glowOffset = Vector(59, 0, 0),
        xAnchor = 0,
    },
    
    { -- 2 - Controls
        name = "controls",
        subScreenName = "Controls",
        localeString = "CONTROLS",
        polygon = -- relative to "buttonBar" locator item.
        {
            Vector(552,   0, 0),
            Vector(552, 118, 0),
            Vector(977, 118, 0),
            Vector(977,   0, 0),
        },
        xAnchor = 1.05,
    },
    
    { -- 3 - Mods
        name = "mods",
        subScreenName = "Mods",
        localeString = "MENU_MODS",
        polygon = -- relative to "buttonBar" locator item.
        {
            Vector( 977,   0, 0),
            Vector( 977, 118, 0),
            Vector(1545, 118, 0),
            Vector(1545,   0, 0),
        },
        xAnchor = 2.1,
    },
    
    { -- 4 - Graphics
        name = "graphics",
        subScreenName = "Graphics",
        localeString = "GRAPHICS",
        polygon = -- relative to "buttonBar" locator item.
        {
            Vector(1545,   0, 0),
            Vector(1545, 118, 0),
            Vector(2016, 118, 0),
            Vector(2016,   0, 0),
        },
        xAnchor = 3.15,
    },
    
    { -- 5 - Sound
        name = "sound",
        subScreenName = "Sound",
        localeString = "SOUND",
        textOffset = Vector(-59, 0, 0),
        polygon =
        {
            Vector(2016,   0, 0),
            Vector(2016, 118, 0),
            Vector(2391, 118, 0),
            Vector(2509,   0, 0),
        },
        glowOffset = Vector(-59, 0, 0),
        xAnchor = 4.2,
    },
}

function GUIMenuOptions:GetButtonData()
    return kButtonData
end

local function UpdateInnerBackgroundSize(self, coolBackSize)
    self.innerBack:SetSize(coolBackSize - Vector(kInnerBackgroundSideSpacing * 2, kInnerBackgroundBottomSpacing + kInnerBackgroundTopSpacing + kTabHeight, 0))
end

local function OnOptionsMenuSizeChanged(self)
    -- Make the outer background the same size as this object.
    self.coolBack:SetSize(self:GetSize() + Vector(0, GUIMenuNavBar.kUnderlapYSize, 0))
    self.innerBack:SetSize(self:GetSize() + Vector(-kInnerBackgroundSideSpacing * 2, GUIMenuNavBar.kUnderlapYSize - kInnerBackgroundTopSpacing - kInnerBackgroundBottomSpacing - kTabHeight, 0))
    self.childWindowsCropper:SetSize(self.innerBack:GetSize().x, self.innerBack:GetSize().y - kButtonBarOverlapOffset)
    self.childWindows:SetSize(self.childWindowsCropper:GetSize())
    for i=1, #self.subMenuHolders do
        self.subMenuHolders[i]:SetSize(self.childWindows:GetSize())
    end
end

local function FindButtonDataContainingValueForKey(self, key, value)
    
    assert(value ~= nil)
    
    local buttonData = self:GetButtonData()
    for i=1, #buttonData do
        if buttonData[i][key] == value then
            return buttonData[i]
        end
    end
    
end

local function UpdateBottomButtons(self)
    
    -- Figure out what the text of the bottom-right button should be, and whether or not it should
    -- be enabled.
    if self.activeSubScreenName == "Mods" and self.modsCategoryDisplayBox:GetActiveCategoryName() == "manageMods" and not kInGame then
        self.bottomButtons:SetRightLabel(Locale.ResolveString("RESTART"))
        self.rightButtonCallback = OnRestartClicked
        self.bottomButtons:SetRightEnabled(true)
    else
        self.bottomButtons:SetRightLabel(Locale.ResolveString("MENU_APPLY"))
        self.rightButtonCallback = OnApplyClicked
        self.bottomButtons:SetRightEnabled(self:GetHasPendingChanges())
    end
    
end

local function SetGlowingButtonByName(self, name)
    for i=1, #self.buttons do
        local thisButtonName = self.buttons[i]
        local button = self.buttons[thisButtonName]
        button:SetGlowing(thisButtonName == name)
    end
end

local function ActivateSubScreen(self, buttonData, instant)
    
    local target = Vector(-buttonData.xAnchor, 0, 0)
    if instant then
        self:ClearPropertyAnimations("_ChildWindowsAnchor")
        self:Set_ChildWindowsAnchor(target)
    else
        self:AnimateProperty("_ChildWindowsAnchor", target, MenuAnimations.FlyIn)
    end
    
    SetGlowingButtonByName(self, buttonData.name)
    
    self.activeSubScreenName = buttonData.subScreenName
    
    UpdateBottomButtons(self)
    
    -- If the mods menu hasn't been refreshed yet, do it now.
    if buttonData.subScreenName == "Mods" and not self.modsMenuFirstRefresh then
        GetModDataManager():Refresh()
    end
    
end

local function CreateHeaderButton(self, buttonData)
    
    local newButton = CreateGUIObject(buttonData.name, GUIMenuOptionsBarButton, self.buttonBar)
    newButton:SetLabel(Locale.ResolveString(buttonData.localeString))
    newButton:SetPoints(buttonData.polygon)
    if buttonData.textOffset then
        newButton:SetLabelOffset(buttonData.textOffset)
    end
    if buttonData.glowOffset then
        newButton:SetGlowOffset(buttonData.glowOffset)
    end
    
    self:HookEvent(newButton, "OnPressed", function()
        ActivateSubScreen(self, buttonData)
    end)
    
    return newButton
    
end

local function RecomputeOptionsMenuHeight(self)
    
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
    RecomputeOptionsMenuHeight(self)
    
end

local function CreateSubMenu(self, name, config)
    
    local holder = CreateGUIObject(name, GUIObject, self.childWindows)
    table.insert(self.subMenuHolders, holder)
    
    CreateGUIObjectFromConfig(config, holder)
    
    return holder
    
end

-- Associates an OptionWrapped widget-type (see MenuDataUtils.lua) with its name so that it can be
-- accessed via GetOptionWidget().
function GUIMenuOptions:RegisterOptionWidget(widget)
    
    AssertIsaGUIObject(widget)
    
    local name = widget:GetName()
    assert(name)
    
    if self.optionWidgets[name] then
        error(string.format("An option widget named '%s' has already been registered.", name), 2)
    end
    
    self.optionWidgets[name] = widget
    
end

-- Returns an option widget associated with this name by RegisterOptionWidget.  Very useful in
-- conjunction with the GetOptionsMenu() global accessor.
function GUIMenuOptions:GetOptionWidget(name)
    
    return self.optionWidgets[name]
    
end

function GUIMenuOptions:SetSubScreenActive(name, instant)
    
    local screenButtonData = FindButtonDataContainingValueForKey(self, "subScreenName", name)
    assert(screenButtonData)
    ActivateSubScreen(self, screenButtonData, instant)
    
end

local function GetNeedsManualRestart(self)
    
    -- Currently only one option requires a manual restart to be applied.
    local actualRenderDevice = Client.GetRenderDeviceName()
    local desiredRenderDevice = self:GetOptionWidget("renderDevice"):GetValue()
    return actualRenderDevice ~= desiredRenderDevice
    
end

local function UpdateNeedsRestartText(self)
    
    local needsRestart = GetNeedsManualRestart(self)
    
    -- Any "autoRestart" options become manual restart options when in-game -- we don't want to
    -- force the player out of their game!
    needsRestart = needsRestart or (self.restartRequiredValues ~= nil)
    
    local prevNeedsRestart = self.prevNeedsRestart == true
    self.prevNeedsRestart = needsRestart
    
    -- Flash if we just now need to restart, fade away if we no longer need to restart.
    if needsRestart ~= prevNeedsRestart then
        if needsRestart then
            self.restartRequiredText:ClearPropertyAnimations("Color")
            DoColorFlashEffect(self.restartRequiredText, "Color", MenuStyle.kWarningColor)
        else
            self.restartRequiredText:ClearPropertyAnimations("Color")
            self.restartRequiredText:AnimateProperty("Color", MenuStyle.kWarningColor * Color(1, 1, 1, 0), MenuAnimations.Fade)
        end
    end
    
end

local function InitModsMenu(self)
    
    assert(self.modsCategoryDisplayBox)
    assert(self.modsCategoryDisplayBox:isa("GUIMenuCategoryDisplayBox"))
    
    self:HookEvent(self.modsCategoryDisplayBox, "OnActiveCategoryNameChanged", UpdateBottomButtons)
    
    assert(type(gModsCategories) == "table")
    assert(gModsCategories[1].categoryName == "manageMods") -- manageMods must be first!
    
    for i=1, #gModsCategories do

        local category = gModsCategories[i]
        self.modsCategoryDisplayBox:AddCategory(category.categoryName, category.entryConfig, category.contentsConfig)
        
    end
    
end

function GUIMenuOptions:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    optionsMenu = self
    
    PushParamChange(params, "screenName", "Options")
    GUIMenuNavBarScreen.Initialize(self, params, errorDepth)
    PopParamChange(params, "screenName")
    
    self:GetRootItem():SetDebugName("optionsMenu")
    self:ListenForCursorInteractions() -- prevent click-through
    
    -- Mapping of optionName --> widget.
    self.optionWidgets = {}
    
    self.inGame = Client.GetIsConnected()
    
    -- Background (two layers, the "cool" layer, and a basic layer on top of that).
    self.coolBack = CreateGUIObject("coolBack", GUIMenuTabbedBox, self)
    self.coolBack:SetLayer(-2)
    self.coolBack:SetPosition(0, -GUIMenuNavBar.kUnderlapYSize)
    
    self.innerBack = CreateGUIObject("innerBack", GUIMenuBasicBox, self)
    self.innerBack:SetLayer(-1)
    self.innerBack:SetPosition(kInnerBackgroundSideSpacing, kInnerBackgroundTopSpacing - GUIMenuNavBar.kUnderlapYSize)
    self:HookEvent(self.coolBack, "OnSizeChanged", UpdateInnerBackgroundSize)
    
    -- Header bar graphic (background for buttons)
    self.headerGraphic = self:CreateGUIItem()
    self.headerGraphic:SetTexture(kHeaderBarTexture)
    self.headerGraphic:SetSizeFromTexture()
    self.headerGraphic:AlignTop()
    self.headerGraphic:SetPosition(0, -GUIMenuNavBar.kUnderlapYSize)
    self.headerGraphic:SetLayer(2)
    
    -- Holds buttons themselves.
    self.buttonBar = self:CreateLocatorGUIItem()
    self.buttonBar:SetSize(kButtonBarSize)
    self.buttonBar:AlignTop()
    self.buttonBar:SetLayer(3)
    
    self.subScreens = {}
    self.headerButtonsByName = {}
    
    local buttonData = self:GetButtonData()
    self.buttons = {}
    for i=1, #buttonData do
        self.buttons[i] = buttonData[i].name
        self.buttons[buttonData[i].name] = CreateHeaderButton(self, buttonData[i])
    end
    
    -- Refresh the mods list whenever the user clicks on the "Mods" button.
    assert(self.buttons.mods)
    GetModDataManager():HookEvent(self.buttons.mods, "OnPressed", GetModDataManager().Refresh)
    
    -- Create bottom tab buttons.  These change based on which options menu is selected.
    self.bottomButtons = CreateGUIObject("bottomButtons", GUIMenuTabButtonsWidget, self)
    self.bottomButtons:SetLayer(2)
    self.bottomButtons:AlignBottom()
    self.bottomButtons:SetLeftLabel("LEFT")
    self.bottomButtons:SetRightLabel("RIGHT")
    self.bottomButtons:SetTabMinWidth(kTabMinWidth)
    self.bottomButtons:SetTabHeight(kTabHeight)
    self.bottomButtons:SetFont(MenuStyle.kButtonFont)
    self.bottomButtons:SetLeftLabel(Locale.ResolveString("BACK"))
    self:HookEvent(self.bottomButtons, "OnLeftPressed", OnBackClicked)
    self.bottomButtons:SetRightLabel(Locale.ResolveString("MENU_APPLY"))
    self:HookEvent(self.bottomButtons, "OnRightPressed", OnRightButtonClicked)
    self.coolBack:HookEvent(self.bottomButtons, "OnTabSizeChanged", self.coolBack.SetTabSize)
    self.coolBack:SetTabSize(self.bottomButtons:GetTabSize())
    
    -- Create text to display when a manual restart is required.
    self.restartRequiredText = CreateGUIObject("restartRequiredText", GUIText, self)
    self.restartRequiredText:SetColor(MenuStyle.kWarningColor * Color(1, 1, 1, 0))
    self.restartRequiredText:SetFont(MenuStyle.kOptionHeadingFont)
    self.restartRequiredText:SetDropShadowEnabled(true)
    self.restartRequiredText:SetAnchor(0.5, 1)
    self.restartRequiredText:SetHotSpot(0, 0.5)
    
    local function UpdateRestartRequiredText(rrText, tabSize)
        rrText:SetPosition(tabSize.x * 0.5 + tabSize.y + MenuStyle.kLabelSpacing,
                           -tabSize.y * 0.5 + kRestartRequiredTextOffsetY)
    end
    self.restartRequiredText:HookEvent(self.bottomButtons, "OnTabSizeChanged", UpdateRestartRequiredText)
    UpdateRestartRequiredText(self.restartRequiredText, self.bottomButtons:GetTabSize())
    
    self.restartRequiredText:SetText(Locale.ResolveString("GAME_RESTART_REQUIRED"))
    
    EnableOnAbsoluteScaleChangedEvent(self)
    self:HookEvent(self, "OnAbsoluteScaleChanged", OnAbsoluteScaleChanged)
    self:HookEvent(GetGlobalEventDispatcher(), "OnResolutionChanged", RecomputeOptionsMenuHeight)
    
    self.childWindowsCropper = self:CreateLocatorGUIItem()
    self.childWindowsCropper:SetDebugName("childWindowsCropper")
    self.childWindowsCropper:CropToBounds()
    self.childWindowsCropper:SetPosition(self.innerBack:GetPosition() + Vector(0, kButtonBarOverlapOffset, 0))
    self.childWindowsCropper:SetLayer(1)
    
    -- All 5 sub-menus are contained as children of "childWindows", and are arranged left-to-right.
    self.childWindows = self:CreateLocatorGUIItem(self.childWindowsCropper)
    self.childWindows:SetDebugName("childWindows")
    self.subMenuHolders = {}
    
    -- Helper function that ensures debug info is included in the config tables and sub-tables, so
    -- error stack traces have meaningful info to display.
    MenuData.AddDebugInfo(MenuData.Config.OptionsMenu.General,  "MenuData.Config.OptionsMenu.General")
    MenuData.AddDebugInfo(MenuData.Config.OptionsMenu.Controls, "MenuData.Config.OptionsMenu.Controls")
    MenuData.AddDebugInfo(MenuData.Config.OptionsMenu.Mods,     "MenuData.Config.OptionsMenu.Mods")
    MenuData.AddDebugInfo(MenuData.Config.OptionsMenu.Graphics, "MenuData.Config.OptionsMenu.Graphics")
    MenuData.AddDebugInfo(MenuData.Config.OptionsMenu.Sound,    "MenuData.Config.OptionsMenu.Sound")
    
    self.generalMenuHolder  = CreateSubMenu(self, "generalMenu",  MenuData.Config.OptionsMenu.General)
    self.controlsMenuHolder = CreateSubMenu(self, "controlsMenu", MenuData.Config.OptionsMenu.Controls)
    self.modsMenuHolder     = CreateSubMenu(self, "modsMenu",     MenuData.Config.OptionsMenu.Mods)
    self.graphicsMenuHolder = CreateSubMenu(self, "graphicsMenu", MenuData.Config.OptionsMenu.Graphics)
    self.soundMenuHolder    = CreateSubMenu(self, "soundMenu",    MenuData.Config.OptionsMenu.Sound)
    
    for i=1, #self.subMenuHolders do
        local ha = buttonData[i].xAnchor
        self.subMenuHolders[i]:SetAnchor(ha, 0)
    end
    
    self:HookEvent(self, "OnSizeChanged", OnOptionsMenuSizeChanged)
    
    -- If the client was just restarted from the options menu, then we'll have a saved screen name.
    local optionsMenuInitScreen = Client.GetOptionString(kInitScreenOptionKey, "")
    if optionsMenuInitScreen == "" then
        self:SetSubScreenActive("General", true)
    else
        Client.SetOptionString(kInitScreenOptionKey, "")
        GetScreenManager():DisplayScreen("Options", true)
        self:SetSubScreenActive(optionsMenuInitScreen, true)
    end
    
    -- If we're not in-game, load the mods menu immediately.
    if not Client.GetIsConnected() then
        GetModDataManager():Refresh()
        self.modsMenuFirstRefresh = true
    end
    
    UpdateNeedsRestartText(self)
    
    InitModsMenu(self)

    self.optionsMenuInitialized = true
end

function GUIMenuOptions:RestartClient()
    
    -- Never allow client to get reset by options menu in the middle of a game.
    assert(not Client.GetIsConnected())
    
    -- Save the screen we were looking at.
    Client.SetOptionString(kInitScreenOptionKey, self.activeSubScreenName)
    Client.RestartMain()
    
end

local function UpdateOptions(self)
    
    UpdateBottomButtons(self)
    UpdateNeedsRestartText(self)
    
end

function GUIMenuOptions:RemoveOptionWidgetFromChangedSet(widget)
    
    if not self.previousValues then
        return
    end
    
    if self.previousValues[widget] == nil then
        return
    end
    
    self.previousValues[widget] = nil
    
    -- Cleanup the previousValues field if it's empty.
    if #self.previousValues == 0 then
        self.previousValues = nil
    end
    
    UpdateOptions(self)

end

-- Provides a mechanism for option widgets to save sub-state.  Eg. Some keybind widgets can be set to "inherited".
-- Much fewer capabilities than regular options (eg can't trigger automatic client resets, etc).
function GUIMenuOptions:OnSubOptionChanged(widget, subValueName, value, prevValue)
    
    AssertIsaGUIObject(widget)
    
    if not widget.ApplySubOption then
        Log("GUIMenuOptions:OnSubOptionChanged() called for widget '%s', but widget does not have required method 'ApplySubOption'", widget:GetName())
        return
    end
    if not widget.RevertSubOption then
        Log("GUIMenuOptions:OnSubOptionChanged() called for widget '%s', but widget does not have required method 'RevertSubOption'", widget:GetName())
        return
    end
    if not widget.GetSubValueChangeDescription then
        Log("GUIMenuOptions:OnSubOptionChanged() called for widget '%s', but widget does not have required method 'GetSubValueChangeDescription'", widget:GetName())
        return
    end
    
    if not self.optionsMenuInitialized then
        return -- options menu is still being initialized, ignore initial option setup.
    end
    
    -- Break off now if options are being changed internally by the menu system.
    if self.applyingChanges then
        return
    end
    
    if not self.previousSubValues then
        self.previousSubValues = IterableDict()
    end
    
    local previouslyRecordedSubValues = self.previousSubValues[widget]
    if not previouslyRecordedSubValues then
        previouslyRecordedSubValues = {}
        self.previousSubValues[widget] = previouslyRecordedSubValues
    end
    
    local previouslyRecordedSubValue
    local foundIndex
    for i=1, #previouslyRecordedSubValues do
        if previouslyRecordedSubValues[i].name == subValueName then
            previouslyRecordedSubValue = previouslyRecordedSubValues[i]
            foundIndex = i
        end
    end
    
    if not previouslyRecordedSubValue then
        
        -- First time this sub value has been changed.
        table.insert(previouslyRecordedSubValues, {name = subValueName, value = prevValue})
        
    elseif previouslyRecordedSubValue.value == value then
        
        -- If the value was previously recorded, and the user is changing it back to that
        -- previously recorded value, remove the entry from the list -- the user manually reverted
        -- the change.
        assert(foundIndex)
        table.remove(previouslyRecordedSubValues, foundIndex)
        
        -- Clean up table if empty.
        if #previouslyRecordedSubValues == 0 then
            self.previousSubValues[widget] = nil
        end
        
        -- Clean up dictionary if empty.
        if #self.previousSubValues == 0 then
            self.previousSubValues = nil
        end
        
    end
    
    UpdateOptions(self)
    
end

function GUIMenuOptions:OnOptionChanged(widget, value, prevValue)
    
    AssertIsaGUIObject(widget)
    
    if not self.optionsMenuInitialized then
        return -- options menu is still being initialized, ignore initial option setup.
    end
    
    -- Keep track of options' previous values that cannot be changed without a map/menu change/reload.
    if widget.autoRestart and Client.GetIsConnected() then
        if not self.restartRequiredValues then
            self.restartRequiredValues = IterableDict()
        end
        
        local previousValue = self.restartRequiredValues[widget]
        if previousValue == nil then
            
            -- Only record the previous value if the option is being changed for the first time.
            self.restartRequiredValues[widget] = prevValue
            
        elseif previousValue == value then
            
            -- If the value was previously recorded and the user is changing it back to that
            -- previously recorded value, remove the entry from the list -- the user manually
            -- reverted the change.
            self.restartRequiredValues[widget] = nil
            
        end
        
        if #self.restartRequiredValues == 0 then
            self.restartRequiredValues = nil
        end
        
    end
    
    -- Break off now if options are being changed internally by the menu system.
    if self.applyingChanges then
        return
    end
    
    if dbgStoreEventStackTraces then
        if value == nil or prevValue == nil then
            Log("ERROR!  Received nil for value or prevValue in GUIMenuOptions:OnOptionChanged!  stack trace:\n%s", Debug_GetStackTraceForEvent())
        end
    else
        assert(value ~= nil)
        assert(prevValue ~= nil)
    end
    
    -- Keep track of the previous values of options so we can revert to them if the user chooses to
    -- revert changes made.
    
    if not self.previousValues then
        self.previousValues = IterableDict()
    end
    
    local previouslyRecordedValue = self.previousValues[widget]
    if previouslyRecordedValue == nil then
        
        -- Only record the previous value if the option is being changed for the first time.
        self.previousValues[widget] = prevValue
        
    elseif previouslyRecordedValue == value then
        
        -- If the value was previously recorded, and the user is changing it back to that
        -- previously recorded value, remove the entry from the list -- the user manually reverted
        -- the change.
        self.previousValues[widget] = nil
        
    end
    
    -- Cleanup the previousValues field if it's empty.
    if #self.previousValues == 0 then
        self.previousValues = nil
    end
    
    -- Automatically apply the option value, so if the user quits without pressing "apply", their
    -- changes won't be lost.  In the original design, they would be lost, but this wasn't very well
    -- thought through.  Now, the "Apply" button really just serves to apply any changes that
    -- shouldn't be done automatically (eg resolution changes), and clears the previous values list
    -- used for reverting.
    SetOptionFromWidgetValue(widget)
    
    UpdateOptions(self)
    
end

function GUIMenuOptions:GetActiveSubScreenName()
    return self.activeSubScreenName or "General"
end

-- Saves changes to the options menu.
function GUIMenuOptions:ApplyChanges()
    
    if not self.previousValues and not self.previousSubValues then
        return
    end
    
    local needsAutoRestart = false
    local reloadGraphicsOptions = false
    
    self.applyingChanges = true -- prevent the widget value changes from showing up again.
    if self.previousValues then
        for widget, prevValue in pairs(self.previousValues) do -- JIT-SAFE pairs.
            SetOptionFromWidgetValue(widget)
            
            if widget.autoRestart then
                needsAutoRestart = true
            end
            
            if widget.reloadGraphicsOptions then
                reloadGraphicsOptions = true
            end
            
        end
    end
    if self.previousSubValues then
        for widget, subOptions in pairs(self.previousSubValues) do -- JIT-SAFE pairs.
            for i=1, #subOptions do
                local subOption = subOptions[i]
                widget:ApplySubOption(subOption.name)
            end
        end
    end
    
    if reloadGraphicsOptions then
        Client.ReloadGraphicsOptions()
    end
    
    self.applyingChanges = false -- allow widget value changes to be recorded again.
    
    self.previousValues = nil
    self.previousSubValues = nil
    UpdateOptions(self)
    
    -- Re-roll background, in case they changed this option... yea, it's a bit inelegant...
    MenuBackgrounds.PickNextMenuBackgroundPath()
    
    -- Updates certain key options used directly by the engine (like the console key, and the mouse
    -- raw input option).
    Client.ReloadKeyOptions()
    
    -- Automatically restart the client if necessary.
    if needsAutoRestart then
        if not Client.GetIsConnected() then
            self:RestartClient()
        end
    end
    
end

-- Reverts changes to the options menu.
function GUIMenuOptions:RevertChanges()
    
    local reloadGraphicsOptions = false
    
    self.applyingChanges = true -- prevent the widget value changes from showing up again.
    if self.previousValues then
        for widget, prevValue in pairs(self.previousValues) do -- JIT-SAFE pairs.
            widget:SetValue(prevValue)
            
            if widget.revertGraphicsOptions then
                reloadGraphicsOptions = true
                SetOptionFromWidgetValue(widget)
            end
            
        end
    end
    if self.previousSubValues then
        for widget, subOptions in pairs(self.previousSubValues) do -- JIT-SAFE pairs.
            for i=1, #subOptions do
                local subOption = subOptions[i]
                widget:RevertSubOption(subOption.name, subOption.value)
            end
        end
    end
    
    if reloadGraphicsOptions then
        Client.ReloadGraphicsOptions()
    end
    
    -- Updates certain key options used directly by the engine (like the console key, and the mouse
    -- raw input option).
    Client.ReloadKeyOptions()
    
    self.applyingChanges = false -- allow widget value changes to be recorded again.
    
    self.previousValues = nil
    self.previousSubValues = nil
    UpdateOptions(self)
    
end

local function PendingChangesPopupCallback_Save(popup)
    
    GetOptionsMenu():ApplyChanges()
    
    local acceptCallback = popup.acceptCallback
    popup:Close()
    acceptCallback(GetOptionsMenu())
    
end

local function PendingChangesPopupCallback_Revert(popup)
    
    GetOptionsMenu():RevertChanges()
    
    local acceptCallback = popup.acceptCallback
    popup:Close()
    acceptCallback(GetOptionsMenu())
    
end

local function GetOmittedPendingChangesLine(omissionCount)
    
    return "\n("..StringReformat(Locale.ResolveString("SERVERBROWSER_FILTER_GAMEMODE_OTHERS"),
        {
            amount = omissionCount,
        })..")"
    
end

local function GetPendingChangesPopupMessage(self)
    
    local message = Locale.ResolveString("OPTIONS_UNSAVED_CHANGES_MESSAGE")
    
    -- Make sure we have space to add an "omitted x widgets" line.
    local omissionLengthEstimate = #GetOmittedPendingChangesLine(999)
    
    local exceededCharacterLimit = false
    local exceededWidgetCount = 0
    if self.previousValues then
        for widget, prevValue in pairs(self.previousValues) do -- JIT-SAFE pairs.
            
            if exceededCharacterLimit then
                
                exceededWidgetCount = exceededWidgetCount + 1
                
            else
                
                -- Add a colon to widget label if needed, or remove the extra space at the end if it has it.
                local widgetLabel = widget:GetLabel()
                if string.sub(widgetLabel, #widgetLabel, #widgetLabel) == " " then
                    widgetLabel = string.sub(widgetLabel, 1, #widgetLabel - 1)
                elseif string.sub(widgetLabel, #widgetLabel, #widgetLabel) ~= ":" then
                    widgetLabel = widgetLabel..":"
                end
                
                local newMsgPart = string.format("\n    - %s %s --> %s", widgetLabel, widget:GetValueString(prevValue), widget:GetValueString(widget:GetValue()))
                
                if #message + #newMsgPart > gGUIItemMaxCharacters - omissionLengthEstimate then
                    exceededCharacterLimit = true
                    exceededWidgetCount = 1
                else
                    message = message .. newMsgPart
                end
                
            end
        end
    end
    
    if self.previousSubValues then
        for widget, subValues in pairs(self.previousSubValues) do -- JIT-SAFE pairs.
            
            if exceededCharacterLimit then
                exceededWidgetCount = exceededWidgetCount + 1
            else
                for i=1, #subValues do
                    local subValue = subValues[i]
                    
                    -- Add a colon to widget label if needed, or remove the extra space at the end if it has it.
                    local widgetLabel = widget:GetLabel()
                    if string.sub(widgetLabel, #widgetLabel, #widgetLabel) == " " then
                        widgetLabel = string.sub(widgetLabel, 1, #widgetLabel - 1)
                    elseif string.sub(widgetLabel, #widgetLabel, #widgetLabel) ~= ":" then
                        widgetLabel = widgetLabel..":"
                    end
                    
                    local newMsgPart = string.format("\n    - %s %s", widgetLabel, widget:GetSubValueChangeDescription(subValue.name, subValue.value))
                    
                    if #message + #newMsgPart > gGUIItemMaxCharacters - omissionLengthEstimate then
                        exceededCharacterLimit = true
                        exceededWidgetCount = 1
                    else
                        message = message .. newMsgPart
                    end
                end
            end
            
        end
    end
    
    if exceededCharacterLimit then
        message = message..GetOmittedPendingChangesLine(exceededWidgetCount)
    end
    
    return message
    
end

-- Opens a popup telling the user that there are unsaved changes to the options menu, giving them
-- the choice of either A) Saving the changes and proceeding, or B) Reverting the changes and
-- proceeding, or C) Cancel whatever they were trying to do without saving or reverting the
-- options.  If the user chooses A or B, the provided "acceptCallback" will be called.
-- Returns the popup if it was created.  Will return nil if a popup is already active.
function GUIMenuOptions:DoPendingChangesPopup(acceptCallback)
    
    if self.displayingPendingChangesPopup then
        return nil
    end
    
    assert(self.previousValues ~= nil or self.previousSubValues ~= nil)
    
    local popup = CreateGUIObject("popup", GUIMenuPopupSimpleMessage, nil,
    {
        title = Locale.ResolveString("OPTIONS_UNSAVED_CHANGES"),
        message = GetPendingChangesPopupMessage(self),
        buttonConfig =
        {
            -- Save changes button
            {
                name = "save",
                params =
                {
                    label = Locale.ResolveString("OPTIONS_SAVE"),
                },
                callback = PendingChangesPopupCallback_Save,
            },
        
            -- Revert changes button
            {
                name = "revert",
                params =
                {
                    label = Locale.ResolveString("OPTIONS_REVERT"),
                },
                callback = PendingChangesPopupCallback_Revert,
            },
        
            -- Cancel button
            GUIPopupDialog.CancelButton,
        
        },
    })
    popup.acceptCallback = acceptCallback
    
    self:HookEvent(popup, "OnClosed", function() self.displayingPendingChangesPopup = false end)
    
    self.displayingPendingChangesPopup = true
    
    return popup
    
end

function GUIMenuOptions:RequestHide(delayedCallback)
    
    -- If there are no pending changes, carry on.
    if not self:GetHasPendingChanges() then
        return true
    end
    
    -- Ask the user if they want to save changes.
    self:DoPendingChangesPopup(delayedCallback)
    
end
