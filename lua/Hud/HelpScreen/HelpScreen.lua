-- ======= Copyright (c) 2017, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/Hud/HelpScreen/HelpScreen.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Chooses which help cards to display from the set defined in HelpScreenContent.lua, and arranges
--    them on the screen.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUIUtility.lua")
Script.Load("lua/Hud/HelpScreen/HelpScreenBinding.lua")
Script.Load("lua/Hud/HelpScreen/MarineHelpTile.lua")
Script.Load("lua/Hud/HelpScreen/AlienHelpTile.lua")
Script.Load("lua/Hud/HelpScreen/HelpScreenContent.lua")
Script.Load("lua/UnorderedSet.lua")

local helpScreenInstance
local helpScreenObservers = UnorderedSet()
local kFont = Fonts.kAgencyFB_Large_Bordered

local kReadTime = 0.5 -- time screen must be displayed before tiles present are marked as read.

class "HelpScreen" (GUIScript)

HelpScreen.hotkeyIconPosition = { [kMarineTeamType] = Vector(1450, 1010, 0), [kAlienTeamType] = Vector(1480, 965, 0) }
HelpScreen.hotkeyDescriptionOffset = 40
HelpScreen.hotkeyScaleFactor = 0.75
HelpScreen.hotkeyColorDefault = kBrightColor
HelpScreen.hotkeyColorAlien = kAlienBrightColor

-- size of each tile, including some padding to keep them a comfortable distance apart.
HelpScreen.tileSize = Vector(355, 376, 0)

-- distance between upper-left corner of our generously sized tile, and the upper-left corner of the tile's content
-- origin.  All content within a tile is measured from the upper-left corner of the marine block background.
HelpScreen.tileOffset = Vector(-44, -21, 0)
HelpScreen.bottomRowOffset = Vector(0, 50, 0)

HelpScreen.tileSpacing = 64 -- px @1080p.
HelpScreen.kMaxTiles = 8 -- max tiles that can fit on the screen at once.

local tileReadStatus = {} -- cache for whether or not client has seen a tile (by name and also indexed).

-- whenever the help screen is displayed, these GUIScripts should be hidden.
local initOnce = false
HelpScreen.uiScriptsHidden = {
    "GUIAlienHUD",
    "GUIAlienSpectatorHUD",
    "GUIAuraDisplay",
    "GUIChat",
    "GUICommunicationStatusIcons",
    "GUIDamageIndicators",
    "GUIDeathMessages",
    "GUIExoEject",
    "GUIExoThruster",
    "GUIHiveStatus",
    "GUIIssuesDisplay",
    "GUIJetpackFuel",
    "GUILifeformPopup",
    "GUIMinimapFrame",
    "GUINotifications",
    "GUIObjectiveDisplay",
    "GUIPickups",
    "GUIPing",
    "GUIPoisonedFeedback",
    "GUIProgressBar",
    "GUIScoreboard",
    "GUISensorBlips",
    "GUITechMap",
    "GUITipVideo",
    "GUIUnitStatus",
    "GUIUpgradeChamberDisplay",
    "GUIVoiceChat",
    "GUIVoteMenu",
    "GUIWaitingForAutoTeamBalance",
    "GUIWaypoints",
    "GUIWorldText",
    "Hud/Marine/GUIExoHUD",
    "Hud/Marine/GUIMarineHUD",
}
-- MODDERS:  Hook into this function to register other GUIScript names to be hidden by help screen.
-- Only use for GUIScripts that are controlled via ClientUI (automatically created/destroyed based
-- on player class).  These scripts MUST implement the methods SetIsVisible(state) and 
-- GetIsVisible(). For other types of scripts that are not controlled by ClientUI (eg 
-- crosshairs, action icon, request menu, etc.), use the HelpScreen_AddObserver and 
-- HelpScreen_RemoveObserver commands to be notified of changes. This function is only
-- called once -- so don't worry about duplicate checking.
function HelpScreen_InitHiddenScripts()
    
    -- Hook in and add your own GUIScripts to the table!  Also, be considerate of other mods!
    -- Don't overwrite the function, hook into it.  (Example below)
    
end

--[[ Example usage:
local old_HelpScreen_InitHiddenScripts = HelpScreen_InitHiddenScripts
function HelpScreen_InitHiddenScripts()
    
    old_HelpScreen_InitHiddenScripts()
    
    HelpScreen_AddHiddenScript("GUIMyAwesomeScript")
    HelpScreen_AddHiddenScript("cool_mod/cool_gui_script")
    
end
--]]

-- Add a script to the above table that will be hidden when the help menu is visible.  The script
-- path given should be relative to the "lua" directory, eg "Hud/Marine/GUIMarineHUD", and omit the
-- ".lua" extension.
function HelpScreen_AddHiddenScript(scriptPath)
    
    HelpScreen.uiScriptsHidden[#HelpScreen.uiScriptsHidden + 1] = scriptPath
    
end

-- Adds the given script to a set of scripts that will be notified when the visibility of the
-- help screen changes.  More efficient than simply having each script poll for visibility.
-- Scripts are notified via a call to a method called OnHelpScreenVisChange(), where the first
-- parameter passed is the help-screen's visibility.  Also, scripts are notified immediately
-- after the observer is added, to bring them up to speed.
function HelpScreen_AddObserver(script)
    
    helpScreenObservers:Add(script)
    script:OnHelpScreenVisChange(HelpScreen_GetHelpScreen():GetIsBeingDisplayed())
    
end

-- Removes the given script from the observer set.
function HelpScreen_RemoveObserver(script)
    
    helpScreenObservers:RemoveElement(script)
    
end

-- To arrange tiles, we will stack them in one or two rows.  One row for <= 4, two rows for >4.  There should not be
-- > 8 cards, ever.  Cards with index >8 will be discarded.  Cards are distributed evenly between the rows, with
-- remainders going to the bottom.  Cards are spaced the same amount between each other, and the entire row is centered
-- in the frame.  All rows of cards are centered vertically in the frame, with the spacing between the two rows of
-- cards as between each card in the row.
function HelpScreen:ArrangeTiles()
    
    local rowCount = (#self.tiles <= 4) and 1 or 2 -- only 1 or 2 rows can fit!
    
    if rowCount == 1 then
        
        local tileCount = #self.tiles
        local start = Vector(0, 0, 0)
        start.x = (960 - ((tileCount - 1) * ((self.tileSize.x + self.tileSpacing) * 0.5))) - (self.tileSize.x * 0.5) - self.tileOffset.x
        start.y = 540 - (self.tileSize.y * 0.5) - self.tileOffset.y
        
        local perTile = Vector(self.tileSpacing + self.tileSize.x, 0, 0)
        
        for i=1, #self.tiles do
            self.tiles[i]:SetPosition(start + perTile * (i-1))
        end
        
    elseif rowCount == 2 then
        
        local topCount = math.floor(#self.tiles / 2)
        local botCount = math.ceil(#self.tiles / 2)
        
        local topStart = Vector(0,0,0)
        local botStart = Vector(0,0,0)
        
        topStart.x = (960 - ((topCount - 1) * ((self.tileSize.x + self.tileSpacing) * 0.5))) - (self.tileSize.x * 0.5) - self.tileOffset.x
        topStart.y = (540 - ((self.tileSize.y + self.tileSpacing) * 0.5)) - (self.tileSize.y * 0.5) - self.tileOffset.y
        
        botStart.x = (960 - ((botCount - 1) * ((self.tileSize.x + self.tileSpacing) * 0.5))) - (self.tileSize.x * 0.5) - self.tileOffset.x
        botStart.y = (540 + ((self.tileSize.y + self.tileSpacing) * 0.5)) - (self.tileSize.y * 0.5) - self.tileOffset.y + self.bottomRowOffset.y
        
        local perTile = Vector(self.tileSpacing + self.tileSize.x, 0, 0)
        
        if topCount == botCount then
            -- cards on top and cards on bottom are equal, we'll need to stagger them so they overlap less.
            topStart.x = topStart.x - (perTile.x * 0.25)
            botStart.x = botStart.x + (perTile.x * 0.25)
        end
        
        for i=1, topCount do
            self.tiles[i]:SetPosition(topStart + perTile * (i - 1))
        end
        
        for i=topCount+1, botCount+topCount do
            self.tiles[i]:SetPosition(botStart + perTile * ((i - topCount) - 1))
        end
        
    else
        assert(false)
    end
    
end

local function GetHasTileBeenRead(name)
    
    if tileReadStatus[name] == nil then
        local fromOptions = Client.GetOptionBoolean(string.format("helpScreen/%s", name), false)
        tileReadStatus[name] = fromOptions
        tileReadStatus[#tileReadStatus+1] = name
    end
    
    return tileReadStatus[name]
    
end

local function SetTileRead(name)
    
    if tileReadStatus[name] == true then
        return
    end
    
    tileReadStatus[name] = true
    Client.SetOptionBoolean(string.format("helpScreen/%s", name), true)
    
end

function HelpScreen:MarkAllAsRead()
    
    for i=1, #self.tiles do
        
        SetTileRead(self.tiles[i].name)
        
    end
    
    self.containsUnreadTiles = false
    
end

function HelpScreen:CreateTiles(contentTable)
    
    for i=1, math.min(#contentTable, self.kMaxTiles) do
        
        local newScript
        if contentTable[i].theme == "marine" then
            newScript = GetGUIManager():CreateGUIScript("Hud/HelpScreen/MarineHelpTile")
        elseif contentTable[i].theme == "alien" then
            newScript = GetGUIManager():CreateGUIScript("Hud/HelpScreen/AlienHelpTile")
        end
        
        assert(newScript)
        
        newScript:SetContent(contentTable[i])
        newScript:SetIsVisible(self.displayed)
        
        self.tiles[i] = newScript
        self.tiles[newScript.name] = i
        
        if GetHasTileBeenRead(newScript.name) == false then
            self.containsUnreadTiles = true
        end
        
    end
    
end

local function GetIsaWithChildren(ent, className)
    
    if ent:isa(className) then
        return true
    end
    
    for i=0, ent:GetNumChildren() - 1 do
        local child = ent:GetChildAtIndex(i)
        local result = GetIsaWithChildren(child, className)
        if result then
            return true
        end
    end
    
    return false
    
end

-- Ugh... apparently there's no way to convert from a mapName to a className... :( 
local kRecognizedEmbryoClasses = { "Skulk", "Gorge", "Lerk", "Fade", "Onos", }
local kMapNameToClass = {}
for i=1, #kRecognizedEmbryoClasses do
    local mapName = gModClassMap[kRecognizedEmbryoClasses[i]].mapName
    kMapNameToClass[mapName] = kRecognizedEmbryoClasses[i]
end

local function GetIsEvolvingToClass(player, contentClassName)
    
    local techId = player.gestationTypeTechId
    if not techId then
        return false
    end
    
    local mapName = LookupTechData(techId, kTechDataGestateName)
    if not mapName then
        return false
    end
    
    local className = kMapNameToClass[mapName]
    if not className then
        return false
    end
    
    if not classisa(className, contentClassName) then
        return false
    end
    
    return true
    
end

local function GetIsContentApplicable(applicableContent, content)
    
    -- don't attempt to evaluate content if there isn't a valid local player for the client.
    -- weird, but can sometimes happen.
    local player = Client.GetLocalPlayer()
    if not player then
        return false
    end
    
    -- check that the player's class "isa" one of the classes provided, or if they are evolving to one.
    local foundValidClass = true -- default to true if no classNames exist
    if content.classNames then
        foundValidClass = false
        for i=1, #content.classNames do
            if GetIsaWithChildren(player, content.classNames[i])
              or GetIsEvolvingToClass(player, content.classNames[i]) then
                foundValidClass = true
                break
            end
        end
    end
    
    if not foundValidClass then
        return false
    end
    
    -- hide this card if requirements are not met and if it is set to hide in such case.
    if content.hideIfLocked then
        if content.requirementFunction and content.requirementFunction() == false then
            return false
        end
    end
    
    -- check if this tile has been overwritten by a better tile (eg adv metab > metab)
    if content.skipCards ~= nil and #content.skipCards > 0 then
        
        for i=1, #content.skipCards do
            local betterTileName = content.skipCards[i]
            if applicableContent[betterTileName] then -- does better tile exist?
                return false
            end
        end
        
    end
    
    return true
    
end

local function GetAllApplicableTiles()
    
    PROFILE("HelpScreen:GetAllApplicableTiles")
    
    local contentTable = HelpScreen_GetContentTable()
    
    local applicableContent = {}
    for i=1, #contentTable do
        if GetIsContentApplicable(applicableContent, contentTable[i]) then
            applicableContent[#applicableContent+1] = contentTable[i]
            applicableContent[contentTable[i].name] = #applicableContent
        end
        
    end
    
    return applicableContent
    
end

function HelpScreen:DiscardTiles()
    
    if self.tiles then
        for i=1, #self.tiles do
            GetGUIManager():DestroyGUIScript(self.tiles[i])
        end
    end
    
    self.tiles = {}
    
end

function HelpScreen:PositionHotkey()
    
    local widthFactor = Client.GetScreenWidth() / 1920.0
    local heightFactor = Client.GetScreenHeight() / 1080.0
    self.hotkeyIcon:SetScalingFactor(heightFactor * self.hotkeyScaleFactor)

    local player = Client.GetLocalPlayer()
    local teamNumber = player and player:GetTeamType() or kTeam1Type
    local hotkeyIconPosition = self.hotkeyIconPosition[teamNumber] or self.hotkeyIconPosition[kTeam1Type]
    local x = widthFactor * hotkeyIconPosition.x
    local y = heightFactor * hotkeyIconPosition.y
    
    self.hotkeyIcon:SetPosition(Vector(x, y, 0))
    
    self.hotkeyDescription:SetPosition(Vector(x + self.hotkeyDescriptionOffset * heightFactor, y, 0))
    self.hotkeyDescription:SetScale(Vector(heightFactor, heightFactor, 0))
    
end

local function InitModScripts()
    
    if initOnce then
        return
    end
    
    initOnce = true
    
    HelpScreen_InitHiddenScripts()
    
end

function HelpScreen:Initialize()
    
    InitModScripts()

    self:DiscardTiles() -- clears previous, init to empty table
    
    self.updateInterval = 1/5 -- 5 fps should be fine.
    self.displayed = false
    self.containsUnreadTiles = false
    
    -- create a hotkey prompt for the top of the screen.
    self.hotkeyIcon = GetGUIManager():CreateGUIScript("Hud/HelpScreen/HelpScreenBinding")
    
    self.hotkeyDescription = GUI.CreateItem()
    self.hotkeyDescription:SetOptionFlag(GUIItem.ManageRender)
    self.hotkeyDescription:SetText(Locale.ResolveString("NEW_INFORMATION"))
    self.hotkeyDescription:SetFontName(kFont)
    self.hotkeyDescription:SetColor(kBrightColor)
    self.hotkeyDescription:SetTextAlignmentY(GUIItem.Align_Center)
    self.hotkeyIcon:SetColor(kBrightColor)

    self:PositionHotkey()
    self.hotkeyIcon:SetAction("HelpScreen")
    
    helpScreenInstance = self
    
    self.displayOpenTime = 0
    
    self.visible = ClientUI.GetScriptVisibility("HelpScreen")
    
    self:Update(0)
    
end

function HelpScreen:Uninitialize()

    self:DiscardTiles()
    self.displayed = false
    
    GetGUIManager():DestroyGUIScript(self.hotkeyIcon)
    GUI.DestroyItem(self.hotkeyDescription)
    self.hotkeyDescription = nil
    self.hotkeyIcon = nil
    
    helpScreenInstance = nil
    
end

function HelpScreen:GetContainsUnreadTiles()
    
    return self.containsUnreadTiles
    
end

function HelpScreen:Update(deltaTime)
    
    PROFILE("HelpScreen:Update")
    
    if self.displayed and not self:GetShouldDisplay() then
        self:Hide()
    end
    
    -- Update requirements when help screen is open.  The tiles do this on their own, but we also need to check
    -- to ensure we're displaying the correct tile if the tile is set to be hidden if not unlocked.
    -- Also mark tiles as "read" if the player has looked at them long enough.
    if self.displayed then
        for i=1, #self.tiles do
            if self.tiles[i].hideIfLocked and self.tiles[i].unlocked == false then
                self:RefreshTiles(self)
                break
            end
        end
        
        self.displayOpenTime = self.displayOpenTime + deltaTime
        
        if self.displayOpenTime >= kReadTime then
            self:MarkAllAsRead()
        end
        
    end
    
    if not self.displayed then
        self.displayOpenTime = 0
    end
    
    -- update hotkey binding visibility
    local hotkeyVis = (self:GetShouldDisplay() and self:GetContainsUnreadTiles()) and not self.displayed and self.visible
    self.hotkeyIcon:SetIsVisible(hotkeyVis)
    self.hotkeyDescription:SetIsVisible(hotkeyVis)
    
end

function HelpScreen:Hide()
    
    PROFILE("HelpScreen:Hide")
    
    if not self.displayed then return end
    
    local player = Client.GetLocalPlayer()
    assert(player)
    player.viewingHelpScreen = false -- to hide blur effect
    self.displayed = false
    
    for i=1, #self.tiles do
        self.tiles[i]:SetIsVisible(false)
    end
    
    -- unhide the ui elements that we hid when the help menu was displayed.
    for i=1, #self.uiScriptsHidden do
        ClientUI.SetScriptVisibility(self.uiScriptsHidden[i], "HelpScreen", true)
    end
    
    for i=1, #helpScreenObservers do
        helpScreenObservers[i]:OnHelpScreenVisChange(false)
    end
    
end

function HelpScreen:Display()
    
    PROFILE("HelpScreen:Display")
    
    if self.displayed then return end
    
    local player = Client.GetLocalPlayer()
    assert(player)
    player.viewingHelpScreen = true -- to display blur effect
    self.displayed = true
    
    self:RefreshTiles(self)
    for i=1, #self.tiles do
        self.tiles[i]:SetIsVisible(true)
    end
    
    -- handle misc stuff here
    if player.CloseMenu then
        player:CloseMenu()
    end
    
    -- hide certain ui elements.
    for i=1, #self.uiScriptsHidden do
        ClientUI.SetScriptVisibility(self.uiScriptsHidden[i], "HelpScreen", false)
    end
    
    for i=1, #helpScreenObservers do
        helpScreenObservers[i]:OnHelpScreenVisChange(true)
    end
    
end

function HelpScreen:GetShouldDisplay()
    
    PROFILE("HelpScreen:GetShouldDisplay")

    if not self.visible then
        return false
    end
    
    if not self.tiles or #self.tiles == 0 then
        return false
    end
    
    local key = BindingsUI_GetInputValue("HelpScreen")
    if key == "None" or key == "" then
        return false
    end
    
    if MainMenu_GetIsOpened() then
        return false
    end
    
    if ChatUI_EnteringChatMessage() then
        return false
    end
    
    local player = Client.GetLocalPlayer()
    if not player or player:isa("Commander") then
        return false
    end
    
    if player:GetTeamType() == kNeutralTeamType then
        return false
    end
    
    if player.GetIsAlive and not player:GetIsAlive() then
        return false
    end
    
    if GetGameInfoEntity():GetGameEnded() then
        return false
    end
    
    if GetGameInfoEntity():GetState() == kGameState.Countdown then
        return false
    end
    
    -- global variable set to true while playing tutorials, or anywhere else the help
    -- screen is not desired.
    if gDisableHelpScreen then
        return false
    end
    
    return true
    
end

function HelpScreen:OnResolutionChanged()

    self:PositionHotkey()
    
end

function HelpScreen:SendKeyEvent(key, down)
    
    PROFILE("HelpScreen:SendKeyEvent")
    
    -- checks to ensure the function actually has a keybinding.
    if not self:GetShouldDisplay() then
        if self.displayed then
            self:Hide()
        end
        return
    end
    
    if GetIsBinding(key, "HelpScreen") then
        if down and not self.displayed then
            self:Display()
        elseif not down then
            self:Hide()
        end
        
        return true
    end
    
    -- key not handled
    return false
    
end

function HelpScreen:RefreshTiles()
    
    PROFILE("HelpScreen:RefreshTiles")
    
    -- Start from a clean slate.
    self:DiscardTiles()
    
    local tilesToCreate = GetAllApplicableTiles()

    self:CreateTiles(tilesToCreate)

    self:ArrangeTiles()
    
end

function HelpScreen:UpdateHotkeyColor()
    
    local color = self.hotkeyColorDefault
    local player = Client.GetLocalPlayer()
    if player and player:isa("Alien") then
        color = self.hotkeyColorAlien
    end
    
    self.hotkeyIcon:SetColor(color)
    self.hotkeyDescription:SetColor(color)
    
end

function HelpScreen:OnLocalPlayerChanged()
    
    PROFILE("HelpScreen:OnLocalPlayerChanged")
    
    local prevDisplayed = self:GetIsBeingDisplayed()
    
    self:Uninitialize()
    self:Initialize()
    self:RefreshTiles(self)
    
    self:UpdateHotkeyColor()
    
    if prevDisplayed then
        self:Display()
    end
    
end

function HelpScreen:GetIsBeingDisplayed()
    
    return self.displayed
    
end

function HelpScreen:SetIsVisible(state)
    
    self.visible = state
    
    if not self.visible then
        self:Hide()
    end
    
end

function HelpScreen:PrintStats()
    
    if not self.tiles then
        Log("self.tiles = nil")
        return
    end
    
    Log("#self.tiles = %s", #self.tiles)
    
end

function HelpScreen_GetHelpScreen()
    
    if not helpScreenInstance then
        helpScreenInstance = GetGUIManager():CreateGUIScript("Hud/HelpScreen/HelpScreen")
    end
    
    return helpScreenInstance
    
end

-- Convenience function to force an update.  Useful for when a weapon is dropped/picked up.
function HelpScreen_ForceUpdate()
    
    HelpScreen_GetHelpScreen():OnLocalPlayerChanged()
    
end

-----------
-- DEBUG --
-----------

-- When help screen tiles are "seen", they are marked as seen, and if all applicable tiles have been seen, the hotkey
-- no longer appears.  For testing purposes, this command allows us to reset the "read" status of all tiles at once
-- to "unread".
local function OnResetHelpScreen()
    
    local contentTable = HelpScreen_GetContentTable()
    if not contentTable or #contentTable == 0 then
        Log("ERROR: No help tile content loaded, couldn't reset help screen. :/")
        return
    end
    
    for i=1, #contentTable do
        local name = contentTable[i].name
        Client.SetOptionBoolean(string.format("helpScreen/%s", name), false)
    end
    
    tileReadStatus = {}
    
    Log("All help screen content reset to unread.")
    
end
Event.Hook("Console_reset_help_screen", OnResetHelpScreen)

local function OnPrintHelpScreenStats()
    
    local hs = HelpScreen_GetHelpScreen()
    hs:PrintStats()
    
end
Event.Hook("Console_hsprintstats", OnPrintHelpScreenStats)



