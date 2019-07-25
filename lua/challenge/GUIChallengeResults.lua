-- ======= Copyright (c) 2017, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\challenge\GUIChallengeResults.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    An abstract GUIScript class for displaying the end-game results of a challenge mode.  This is
--    extended by the GUIChallengeResultsAlien class, for alien-themed results screens. (At the time
--    of writing, there are no marine-related challenges... but it's nice to plan ahead.)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUIAssets.lua")
Script.Load("lua/UnsortedSet.lua")
Script.Load("lua/challenge/GUIChallengeMedal.lua")

class 'GUIChallengeResults' (GUIScript)

local kDefaultLayer = 40

-- All of the below member-constants are encouraged to be overwritten by extended classes, where desired.
GUIChallengeResults.kColor = Color(1,1,1,1)
GUIChallengeResults.kShadowColor = Color(0,0,0,0.5)
GUIChallengeResults.kHighlightedColor = Color(1,1,1,1)

GUIChallengeResults.kTitleFontName = Fonts.kAgencyFB_Huge
local kAgencyHugeActualSize = 66
GUIChallengeResults.kTitleFontSize = 42

GUIChallengeResults.kFontName = Fonts.kAgencyFB_Large
local kAgencyLargeActualSize = 28
GUIChallengeResults.kFontSize = 24

GUIChallengeResults.kButtonTextLayerOffset = 3
GUIChallengeResults.kContentLayerOffset = 2
GUIChallengeResults.kContentShadowLayerOffset = 1
GUIChallengeResults.kWiperLayerOffset = 0
GUIChallengeResults.kBackgroundLayerOffset = 0

GUIChallengeResults.kShadowOffset = Vector(2, 2, 0)

GUIChallengeResults.kCommonMargin = 8
GUIChallengeResults.kRowSpacing = 40
GUIChallengeResults.kTitleSpacing = 20
GUIChallengeResults.kDividerThickness = 8

GUIChallengeResults.kPanelSize = Vector(815, 490, 0)
GUIChallengeResults.kMedalBorderSize = 366
GUIChallengeResults.kMedalSize = 330

GUIChallengeResults.kButtonSize = Vector(221, 71, 0)
GUIChallengeResults.kButtonFontSize = 20
GUIChallengeResults.kButtonFontName = Fonts.kAgencyFB_Medium
local kAgencyMediumActualSize = 22
GUIChallengeResults.kButtonTextColor = Color(0,0,0,1)
GUIChallengeResults.kButtonSpacing = 40
GUIChallengeResults.kFirstButtonPosition = Vector(738, 557, 0)

-- Over size = regular size scaled up proportionally so that it is kButtonSpacing-wider than normal.
GUIChallengeResults.kButtonOverSize = Vector(GUIChallengeResults.kButtonSize.x + GUIChallengeResults.kButtonSpacing, ((GUIChallengeResults.kButtonSize.x + GUIChallengeResults.kButtonSpacing) / GUIChallengeResults.kButtonSize.x) * GUIChallengeResults.kButtonSize.y, 0)

GUIChallengeResults.kMedalGraphic = PrecacheAsset("ui/challenge/medal_outline.dds")
GUIChallengeResults.kMedalNameToClassName = {} -- empty here, filled in extending classes

GUIChallengeResults.kWipeTime = 0.1 -- each row's wipe takes 0.1 seconds from start to finish
GUIChallengeResults.kWipeDelay = 0.016667 -- each row's wipe is delayed by this amount from the previous row.

GUIChallengeResults.kFadeTime = 1.0

GUIChallengeResults.kResultsScreenPosition = Vector(186, 271, 0)

GUIChallengeResults.kButtonHoverSound = PrecacheAsset("sound/NS2.fev/common/hovar")
GUIChallengeResults.kButtonClickSound = PrecacheAsset("sound/NS2.fev/common/button_click")

GUIChallengeResults.kMedalNameLocale = 
{
    bronze = "CHALLENGE_MEDAL_BRONZE",
    silver = "CHALLENGE_MEDAL_SILVER",
    gold = "CHALLENGE_MEDAL_GOLD",
    shadow = "CHALLENGE_MEDAL_SHADOW",
}

function GUIChallengeResults:CreateGUIItem()
    
    local item = GUI.CreateItem()
    US_Add(self.items, item)
    
    return item
    
end

function GUIChallengeResults:DestroyGUIItem(item)
    
    GUI.DestroyItem(item)
    US_Remove(self.items, item)
    
end

function GUIChallengeResults:CreateTextItem(createShadow)
    
    local item = self:CreateGUIItem()
    item:SetOptionFlag(GUIItem.ManageRender)
    item:SetTextAlignmentY(GUIItem.Align_Center)
    item:SetFontName(self.kFontName)
    item:SetColor(self.kColor)
    
    if createShadow then
        
        local shadowItem = self:CreateGUIItem()
        shadowItem:SetOptionFlag(GUIItem.ManageRender)
        shadowItem:SetTextAlignmentY(GUIItem.Align_Center)
        shadowItem:SetFontName(self.kFontName)
        shadowItem:SetColor(self.kShadowColor)
        
        return item, shadowItem
        
    end
    
    return item
    
end

-- Clears all the contents of the results rows.
function GUIChallengeResults:ClearRows()
    
    for i=1, #self.rows do
        if self.rows[i].transformType == "content" then
            self:DestroyGUIItem(self.rows[i].name.text)
            self:DestroyGUIItem(self.rows[i].name.textShadow)
            self:DestroyGUIItem(self.rows[i].content.text)
            self:DestroyGUIItem(self.rows[i].content.textShadow)
        elseif self.rows[i].transformType == "divider" then
            self:DestroyGUIItem(self.rows[i].item)
        end
    end
    
    self.rows = {}
    
end

function GUIChallengeResults:SetRowStencilFunc(row, func)
    
    if row.name then
        row.name.text:SetStencilFunc(func)
        row.name.textShadow:SetStencilFunc(func)
    end
    
    if row.content then
        row.content.text:SetStencilFunc(func)
        row.content.textShadow:SetStencilFunc(func)
    end
    
    if row.item then
        row.item:SetStencilFunc(func)
    end
    
end

-- Adds a row to the results screen that displays a name on the left, and then some content
-- (a string) on the right.
function GUIChallengeResults:AddRow(name, content)
    
    local newRow = {}
    newRow.name = {}
    newRow.name.text, newRow.name.textShadow = self:CreateTextItem(true)
    newRow.content = {}
    newRow.content.text, newRow.content.textShadow = self:CreateTextItem(true)
    newRow.content.text:SetTextAlignmentX(GUIItem.Align_Max)
    newRow.content.textShadow:SetTextAlignmentX(GUIItem.Align_Max)
    
    local nameResolved = Locale.ResolveString(name)
    newRow.name.text:SetText(nameResolved)
    newRow.name.textShadow:SetText(nameResolved)
    newRow.content.text:SetText(content)
    newRow.content.textShadow:SetText(content)
    
    local wiper = self:CreateGUIItem()
    wiper:SetIsStencil(true)
    wiper:SetClearsStencilBuffer(false)
    newRow.wiper = wiper
    newRow.wiperVis = true
    
    newRow.transformType = "content"
    
    table.insert(self.rows, newRow)
    
    self:UpdateVisibility()
    
end

function GUIChallengeResults:AddButton_InitGUI(localeString, newButton)
    
    newButton.text = self:CreateTextItem()
    newButton.text:SetFontName(self.kButtonFontName)
    newButton.text:SetTextAlignmentX(GUIItem.Align_Center)
    newButton.text:SetTextAlignmentY(GUIItem.Align_Center)
    newButton.text:SetColor(self.kButtonTextColor)
    newButton.text:SetText(Locale.ResolveString(localeString))
    
end

function GUIChallengeResults:SetButtonText(luaName, localeString)
    
    self.namedButtons[luaName].text:SetText(Locale.ResolveString(localeString))
    
end

function GUIChallengeResults:GetButtonByName(name)
    
    return self.namedButtons[name]
    
end

-- Adds a button to the bottom of the results screen.  Should not be overridden by extending classes.
-- To add/modify buttons' appearance, override AddButton_InitGUI instead.
function GUIChallengeResults:AddButton(localeString, callback, luaName)
    
    local newButton = {}
    newButton.over = false
    newButton.enabled = true
    
    self:AddButton_InitGUI(localeString, newButton)
    
    newButton.callback = callback
    newButton.luaName = luaName
    
    table.insert(self.buttons, newButton)
    if luaName then
        self.namedButtons[luaName] = newButton
    end
    
    self:UpdateButtonTransform(#self.buttons, newButton)
    
    return newButton
    
end

function GUIChallengeResults:UpdateFontScales()
    
    local titleScale = (self.kTitleFontSize / kAgencyHugeActualSize) * self.scale.y
    self.titleFontScale = Vector(titleScale, titleScale, 0)
    
    local regularFontScale = (self.kFontSize / kAgencyLargeActualSize) * self.scale.y
    self.fontScale = Vector(regularFontScale, regularFontScale, 0)
    
    local buttonFontScale = (self.kButtonFontSize / kAgencyMediumActualSize) * self.scale.y
    self.buttonFontScale = Vector(buttonFontScale, buttonFontScale, 0)
    
end

function GUIChallengeResults:UpdateButtonTransforms()
    
    for i=1, #self.buttons do
        self:UpdateButtonTransform(i, self.buttons[i])
    end
    
end

function GUIChallengeResults:UpdateButtonTransform(index, button)
    
    -- Button Text
    local pos = self.kFirstButtonPosition - Vector(((index - 1) * (self.kButtonSpacing + self.kButtonSize.x)), 0, 0)
    pos.x = pos.x * self.scale.x
    pos.y = pos.y * self.scale.y
    pos = pos + self.position
    button.text:SetPosition(pos)
    button.text:SetScale(self.buttonFontScale)
    
    -- store this for easier over detection
    button.position = pos
    button.halfExtents = Vector(0,0,0)
    button.halfExtents.x = self.kButtonSize.x * 0.5 * self.scale.x
    button.halfExtents.y = self.kButtonSize.y * 0.5 * self.scale.y
    
    -- Button graphics are handled via extending classes
    
end

function GUIChallengeResults:UpdateMedalTransform()
    
    if not self.medalScript then
        return
    end
    
    local size = Vector(self.scale.x * self.kMedalSize, self.scale.y * self.kMedalSize, 0)
    self.medalScript:SetSize(size)
    
    local pos = Vector(0,0,0)
    pos.x = self.kMedalBorderSize * 0.5
    pos.y = self.kMedalBorderSize * 0.5 + self.kTitleSpacing + self.kTitleFontSize
    pos.x = pos.x * self.scale.x
    pos.y = pos.y * self.scale.y
    pos = pos + self.position - (size * 0.5)
    self.medalScript:SetPosition(pos)
    
end

function GUIChallengeResults:UpdateButtonVisibility(button)
    
    button.text:SetIsVisible(self.visible)
    
end

function GUIChallengeResults:UpdateVisibility()
    
    self.titleItem:SetIsVisible(self.visible)
    self.titleShadowItem:SetIsVisible(self.visible)
    
    self.medalNameItem:SetIsVisible(self.visible)
    self.medalNameShadowItem:SetIsVisible(self.visible)
    self.medalNameWiper:SetIsVisible(self.visible)
    
    self.medalBorderItem:SetIsVisible(self.visible)
    
    if self.medalScript then
        self.medalScript:SetIsVisible(self.visible)
    end
    
    for i=1, #self.rows do
        
        local row = self.rows[i]
        
        if row.name then
            row.name.text:SetIsVisible(self.visible)
            row.name.textShadow:SetIsVisible(self.visible)
        end
        
        if row.content then
            row.content.text:SetIsVisible(self.visible)
            row.content.textShadow:SetIsVisible(self.visible)
        end
        
        if row.item then
            row.item:SetIsVisible(self.visible)
        end
        
        row.wiper:SetIsVisible(self.visible and row.wiperVis)
        
    end
    
    for i=1, #self.buttons do
        self:UpdateButtonVisibility(self.buttons[i])
    end
    
end

function GUIChallengeResults:UpdateTransform()
    
    local shadowOffset = self.kShadowOffset * self.scale
    
    -- Title
    local titlePosition = Vector(self.kPanelSize.x * 0.5, 0, 0) * self.scale + self.position
    self.titleItem:SetPosition(titlePosition)
    self.titleShadowItem:SetPosition(titlePosition + shadowOffset)
    self.titleItem:SetScale(self.titleFontScale)
    self.titleShadowItem:SetScale(self.titleFontScale)
    
    -- Medal Name
    local mNamePos = Vector(self.kMedalBorderSize * 0.5, self.kPanelSize.y, 0) * self.scale + self.position
    self.medalNameItem:SetPosition(mNamePos)
    self.medalNameShadowItem:SetPosition(mNamePos + shadowOffset)
    self.medalNameItem:SetScale(self.titleFontScale)
    self.medalNameShadowItem:SetScale(self.titleFontScale)
    
    -- Medal Name Wiper
    local mnWiperPos = Vector(0.0, self.kPanelSize.y - self.kTitleFontSize - self.kTitleSpacing, 0.0) * self.scale + self.position
    local mnWiperSize = Vector(self.kMedalBorderSize, self.kTitleFontSize + self.kTitleSpacing * 2.0, 0) * self.scale
    self.medalNameWiper:SetPosition(mnWiperPos)
    self.medalNameWiper:SetSize(mnWiperSize)
    
    -- Medal Border
    local mBorderPos = Vector(0.0, self.kTitleFontSize + self.kTitleSpacing, 0.0) * self.scale + self.position
    self.medalBorderItem:SetPosition(mBorderPos)
    self.medalBorderItem:SetSize(Vector(self.kMedalBorderSize * self.scale.x, self.kMedalBorderSize * self.scale.y, 0))
    
    -- Medal Graphic
    self:UpdateMedalTransform()
    
    -- Content Rows
    local rowLeftX = self.kMedalBorderSize + self.kCommonMargin * 4.0
    local rowRightX = self.kPanelSize.x
    local rowMiddleY = self.kTitleFontSize + self.kTitleSpacing + self.kRowSpacing + self.kCommonMargin * 2.0
    for i=1, #self.rows do
        
        local row = self.rows[i]
        
        if self.rows[i].transformType == "content" then
            
            local namePos = Vector(rowLeftX, rowMiddleY, 0) * self.scale + self.position
            row.name.text:SetPosition(namePos)
            row.name.textShadow:SetPosition(namePos + shadowOffset)
            
            local contentPos = Vector(rowRightX, rowMiddleY, 0) * self.scale + self.position
            row.content.text:SetPosition(contentPos)
            row.content.textShadow:SetPosition(contentPos + shadowOffset)
            
            row.name.text:SetScale(self.fontScale)
            row.name.textShadow:SetScale(self.fontScale)
            row.content.text:SetScale(self.fontScale)
            row.content.textShadow:SetScale(self.fontScale)
            
        elseif self.rows[i].transformType == "divider" then
            
            local left = Vector(rowLeftX, rowMiddleY - self.kDividerThickness * 0.5, 0) * self.scale + self.position
            local right = Vector(rowRightX, rowMiddleY + self.kDividerThickness * 0.5, 0) * self.scale + self.position
            row.item:SetPosition(left)
            row.item:SetSize(right - left)
            
        end
        
        -- update the wiper
        local wiperLeftX = rowLeftX - self.kCommonMargin
        local wiperRightX = rowRightX + self.kCommonMargin
        local wiperPos = Vector(wiperLeftX, rowMiddleY - self.kRowSpacing * 0.5, 0) * self.scale + self.position
        local wiperSize = Vector(wiperRightX - wiperLeftX, self.kRowSpacing, 0) * self.scale
        row.wiper:SetPosition(wiperPos)
        row.wiper:SetSize(wiperSize)
        
        rowMiddleY = rowMiddleY + self.kRowSpacing
        
    end
    
    -- Buttons
    self:UpdateButtonTransforms()
    
    -- Full screen fader
    self.fullscreenFade:SetPosition(Vector(0,0,0))
    self.fullscreenFade:SetSize(Vector(Client.GetScreenWidth(), Client.GetScreenHeight(), 0))
    
end

function GUIChallengeResults:ClearMedalScript()
    
    if self.medalScript then
        GetGUIManager():DestroyGUIScript(self.medalScript)
        self.medalScript = nil
    end
    
end

function GUIChallengeResults:SetMedalScript(scriptName)
    
    if self.medalScript then
        self:ClearMedalScript()
    end
    
    self.medalScript = GetGUIManager():CreateGUIScript(scriptName)
    self.medalScript:SetIsVisible(self.visible)
    self:UpdateMedalTransform()
    self.medalScript:SetLayer(self.layer + self.kContentLayerOffset)
    
    return self.medalScript
    
end

function GUIChallengeResults:SetTitle(text)
    
    self.titleItem:SetText(text)
    self.titleShadowItem:SetText(text)
    
end

function GUIChallengeResults:UpdateButtonLayers(index, button)
    
    button.text:SetLayer(self.layer + self.kButtonTextLayerOffset)
    
end

function GUIChallengeResults:UpdateButtonsLayers()
    
    for i=1, #self.buttons do
        self:UpdateButtonLayers(i, self.buttons[i])
    end
    
end

function GUIChallengeResults:UpdateLayers()
    
    -- start by setting everything to default content layer.
    local contentLayer = self.layer + self.kContentLayerOffset
    local shadowLayer = self.layer + self.kContentShadowLayerOffset
    self.titleItem:SetLayer(contentLayer)
    self.titleShadowItem:SetLayer(shadowLayer)
    
    self.medalBorderItem:SetLayer(contentLayer)
    
    self.medalNameItem:SetLayer(contentLayer)
    self.medalNameShadowItem:SetLayer(shadowLayer)
    
    self.medalNameWiper:SetLayer(self.layer + self.kWiperLayerOffset)
    
    self:UpdateButtonsLayers()
    
    -- content rows
    for i=1, #self.rows do
        local row = self.rows[i]
        
        if row.transformType == "content" then
            row.name.text:SetLayer(contentLayer)
            row.name.textShadow:SetLayer(shadowLayer)
            row.content.text:SetLayer(contentLayer)
            row.content.textShadow:SetLayer(shadowLayer)
        elseif row.transformType == "divider" then
            row.item:SetLayer(contentLayer)
        end
        
        row.wiper:SetLayer(self.layer + self.kWiperLayerOffset)
    end
    
    if self.medalScript then
        self.medalScript:SetLayer(contentLayer)
    end
    
end

function GUIChallengeResults:SetLayer(layer)
    
    self.layer = layer
    self:UpdateLayers()
    
end

function GUIChallengeResults:InitGUI()
    
    -- Initialize title graphic
    self.titleItem, self.titleShadowItem = self:CreateTextItem(true)
    self.titleItem:SetTextAlignmentX(GUIItem.Align_Center)
    self.titleItem:SetTextAlignmentY(GUIItem.Align_Min)
    self.titleShadowItem:SetTextAlignmentX(GUIItem.Align_Center)
    self.titleShadowItem:SetTextAlignmentY(GUIItem.Align_Min)
    self.titleItem:SetFontName(self.kTitleFontName)
    self.titleShadowItem:SetFontName(self.kTitleFontName)
    self.titleItem:SetText("")
    self.titleShadowItem:SetText("")
    
    -- Initialize medal border graphic
    self.medalBorderItem = self:CreateGUIItem()
    self.medalBorderItem:SetTexture(self.kMedalGraphic)
    self.medalBorderItem:SetColor(self.kColor)
    
    -- Initialize medal name text
    self.medalNameItem, self.medalNameShadowItem = self:CreateTextItem(true)
    self.medalNameItem:SetTextAlignmentX(GUIItem.Align_Center)
    self.medalNameItem:SetTextAlignmentY(GUIItem.Align_Max)
    self.medalNameShadowItem:SetTextAlignmentX(GUIItem.Align_Center)
    self.medalNameShadowItem:SetTextAlignmentY(GUIItem.Align_Max)
    self.medalNameItem:SetFontName(self.kTitleFontName)
    self.medalNameShadowItem:SetFontName(self.kTitleFontName)
    self.medalNameItem:SetText("")
    self.medalNameShadowItem:SetText("")
    
    -- Add wiper for medal name text
    local wiper = self:CreateGUIItem()
    wiper:SetIsStencil(true)
    wiper:SetClearsStencilBuffer(false)
    self.medalNameWiper = wiper
    
    -- Add "quit" button
    local quitButton = self:AddButton("QUIT",
    function()
        self:GetParentEntity():OnQuitClicked()
    end)
    
    -- Create a black, fullscreen object for fading in/out.
    -- Don't use our self-cleaning GUI method, we want this to persist for that brief frame or two between the gui being
    -- destroyed, and the game changing to the loading screen.  Otherwise, we'll see a brief flash from black, to game, to
    -- loading screen.
    self.fullscreenFade = GUI.CreateItem()
    self.fullscreenFade:SetColor(Color(0,0,0,1))
    self.fullscreenFade:SetIsVisible(false)
    
end

function GUIChallengeResults:GetParentEntity()
    return self.parentEnt
end

-- The entity that controls the flow of the game (eg the "SkulkChallenge" entity).
-- Necessary in order to deliver callbacks to the entity so it can coordinate between the many different
-- gui scripts.
function GUIChallengeResults:SetParentEntity(ent)
    self.parentEnt = ent
end

function GUIChallengeResults:SetIsVisible(state)
    
    self.visible = state
    self:UpdateVisibility()
    
end

function GUIChallengeResults:Initialize()
    
    -- To make cleanup easier, we keep track of which items belong to this script.
    self.items = US_Create()
    self.rows = {}
    self.buttons = {}
    self.namedButtons = {} -- easier access to buttons.
    self.siblingScripts = US_Create()
    
    -- Initialize important values
    self.position = Vector(0,0,0)
    self.scale = Vector(1,1,1)
    self.state = "hidden" -- waiting for fade in.
    self.animationTime = 0.0
    self.animationCallback = nil
    
    self.windowDisabled = {}
    self.windowDisabledCount = 0
    
    self.layer = kDefaultLayer
    
    self:UpdateFontScales()
    self:InitGUI()
    self:UpdateResultsScreenTransform()
    self:UpdateTransform()
    self:SetIsVisible(true)
    self:Update(0)
    
    MouseTracker_SetIsVisible(true, nil, true)
    
    self.updateInterval = 0
    
end

function GUIChallengeResults:Uninitialize()
    
    for i=1, #self.items.a do
        GUI.DestroyItem(self.items.a[i])
    end
    
    self:ClearMedalScript()
    
    MouseTracker_SetIsVisible(false)
    
    -- Sever our connection with any sibling scripts.
    while US_GetSize(self.siblingScripts) > 0 do
        self:RemoveSiblingScript(US_GetElement(self.siblingScripts, 1))
    end
    
end

function GUIChallengeResults:OnResolutionChanged()
    
    self:UpdateResultsScreenTransform()
    
end

function GUIChallengeResults:SetPosition(position)
    
    self.position = position
    self:UpdateTransform()
    
end

function GUIChallengeResults:SetScale(scale)
    
    self.scale = scale
    self:UpdateFontScales()
    self:UpdateTransform()
    
end

function GUIChallengeResults:AddRow_Divider()
    
    local newDivider = {}
    newDivider.item = self:CreateGUIItem()
    newDivider.item:SetColor(self.kColor)
    
    local wiper = self:CreateGUIItem()
    wiper:SetIsStencil(true)
    wiper:SetClearsStencilBuffer(false)
    newDivider.wiper = wiper
    
    newDivider.transformType = "divider"
    
    newDivider.wiperVis = true
    
    table.insert(self.rows, newDivider)
    
end

function GUIChallengeResults:AddRow_Time(row)
    
    if row.value then
        self:AddRow(row.name, ConvertSecondsToString(row.value))
    else
        self:AddRow(row.name, "--:--.--")
    end
    
end

function GUIChallengeResults:AddRow_Speed(row)
    
    if row.value then
        self:AddRow(row.name, string.format("%.2f m/s", row.value))
    else
        self:AddRow(row.name, "-------")
    end
    
end

function GUIChallengeResults:AddRow_Integer(row)
    
    if row.value then
        self:AddRow(row.name, tostring(row.value))
    else
        self:AddRow(row.name, "???")
    end
    
end

-- Adds the requested rows to the gui.
function GUIChallengeResults:SetupResults(resultsTable)
    
    local rows = resultsTable.rows
    -- Call the appropriate "AddRow_" function depending on the "type" of the row, as specified in the table.
    for i=1, #rows do
        local funcName = "AddRow_" .. rows[i].type
        self[funcName](self, rows[i])
    end
    
    -- Ensure all newly created rows of GUI elements are hidden by the wipers
    for i=1, #self.rows do
        self:SetRowStencilFunc(self.rows[i], GUIItem.Equal)
    end
    
    -- Set medal item text, and create a wiper for this too.
    local medalNameResolved
    if resultsTable.medalAwarded then
        medalNameResolved = self.kMedalNameLocale[resultsTable.medalAwarded]
        if medalNameResolved then
            medalNameResolved = Locale.ResolveString(medalNameResolved)
        end
    end
    
    medalNameResolved = medalNameResolved or Locale.ResolveString("NO_MEDAL")
    
    self.medalNameItem:SetText(medalNameResolved)
    self.medalNameShadowItem:SetText(medalNameResolved)
    
    self:SetTitle(Locale.ResolveString(resultsTable.title))
    
    self:UpdateTransform()
    self:UpdateLayers()
    
end

-- Shows the results screen (presumed to be hidden before now), and displays the results stored in the table.
function GUIChallengeResults:ShowWithResults(resultsTable, finishCallback)
    
    assert(resultsTable)
    
    self:SetupResults(resultsTable)
    
    self:DoFadeIn(
    function(self)
        self:DoWipeIn(
        function(self)
            if resultsTable.medalAwarded then
                self:DisplayMedal(resultsTable.medalAwarded,
                function()
                    self:DoWipeInMedalName(finishCallback)
                end, nil)
            else
                self:DoWipeInMedalName(finishCallback)
            end
        end)
    end)
    
end

function GUIChallengeResults:SetButtonEnabled(button, state)
    
    button.enabled = (state ~= false) -- default nil to true
    
end

function GUIChallengeResults:UpdateButtonRollover(button, mousePos)
    
    local oldState = button.over or false
    
    local diff = (button.position - mousePos)
    if math.abs(diff.x) <= button.halfExtents.x
    and math.abs(diff.y) <= button.halfExtents.y
    and self.state == "done"
    and self:GetIsWindowActive()
    and button.enabled == true then
        button.over = true
    else
        button.over = false
    end
    
    if oldState == false and button.over == true then
        StartSoundEffect(self.kButtonHoverSound)
    end
    
end

function GUIChallengeResults:UpdateButtonRollovers()
    
    local mousePos = Vector(0,0,0)
    mousePos.x, mousePos.y = Client.GetCursorPosScreen()
    
    for i=1, #self.buttons do
        self:UpdateButtonRollover(self.buttons[i], mousePos)
    end
    
end

function GUIChallengeResults:UpdateButtonOpacity(button, opacity)
    
    local fadeColor = Color(self.kButtonTextColor)
    fadeColor.a = fadeColor.a * opacity
    
    button.text:SetColor(fadeColor)
    
end

function GUIChallengeResults:UpdateRowOpacity(row, opacity)
    
    local fadeColor = Color(self.kColor)
    fadeColor.a = fadeColor.a * opacity
    
    local shadowColor = Color(self.kShadowColor)
    shadowColor.a = shadowColor.a * opacity
    
    if row.transformType == "content" then
        
        row.name.text:SetColor(fadeColor)
        row.name.textShadow:SetColor(shadowColor)
        
        row.content.text:SetColor(fadeColor)
        row.content.textShadow:SetColor(shadowColor)
        
    elseif row.transformType == "divider" then
        
        row.item:SetColor(fadeColor)
        
    end
    
end

function GUIChallengeResults:UpdateOpacity(opacity)
    
    local fadeColor = Color(self.kColor)
    fadeColor.a = fadeColor.a * opacity
    
    local shadowColor = Color(self.kShadowColor)
    shadowColor.a = shadowColor.a * opacity
    
    self.titleItem:SetColor(fadeColor)
    self.titleShadowItem:SetColor(shadowColor)
    
    self.medalNameItem:SetColor(fadeColor)
    self.medalNameShadowItem:SetColor(shadowColor)
    
    self.medalBorderItem:SetColor(fadeColor)
    
    if self.medalScript then
        self.medalScript:SetOpacity(opacity)
    end
    
    -- update rows
    for i=1, #self.rows do
        self:UpdateRowOpacity(self.rows[i], opacity)
    end
    
    -- update buttons
    for i=1, #self.buttons do
        self:UpdateButtonOpacity(self.buttons[i], opacity)
    end
    
end

function GUIChallengeResults:UpdateWiperPosition(rowIndex, fraction)
    
    local rowLeftX = self.kMedalBorderSize + self.kCommonMargin * 3.0
    local rowRightX = self.kPanelSize.x + self.kCommonMargin
    local rowMiddleY = self.kTitleFontSize + self.kTitleSpacing + self.kRowSpacing + self.kCommonMargin * 2.0
    rowMiddleY = rowMiddleY + (self.kRowSpacing * (rowIndex - 1))
    
    local row = self.rows[rowIndex]
    local wiper = row.wiper
    
    local wiperPos = Vector(0, rowMiddleY - self.kRowSpacing * 0.5, 0)
    wiperPos.x = rowLeftX * (1.0 - fraction) + rowRightX * fraction
    wiperPos = wiperPos * self.scale + self.position
    local wiperSize = Vector(0, self.kRowSpacing, 0)
    wiperSize.x = (rowRightX - rowLeftX) * (1.0 - fraction)
    wiperSize = wiperSize * self.scale
    wiper:SetPosition(wiperPos)
    wiper:SetSize(wiperSize)
    
end

function GUIChallengeResults:UpdateAnimation(deltaTime)
    
    if self.state == "hidden" or self.state == "done" then
        
        return -- nothing to do
        
    elseif self.state == "fadeIn" or self.state == "fadeOut" then
        
        -- do fade animations
        self.animationTime = self.animationTime + deltaTime
        
        if self.state == "fadeIn" then
            self:UpdateOpacity(Clamp(self.animationTime / self.kFadeTime, 0, 1))
        else
            self:UpdateOpacity(1.0 - Clamp(self.animationTime / self.kFadeTime, 0, 1))
        end
        
        -- check if animation is done
        if self.animationTime >= self.kFadeTime then
            self.state = "done" -- might be changed by animationCallback
            if self.animationCallback then
                self.animationCallback(self)
            end
        end
        
    elseif self.state == "wipeIn" then
        
        -- do wipe animation
        self.animationTime = self.animationTime + deltaTime
        
        for i=1, #self.rows do
            
            local index = i-1
            local fraction = Clamp((self.animationTime - self.kWipeDelay * index) / self.kWipeTime, 0.0, 1.0)
            self:UpdateWiperPosition(i, fraction)
            
        end
        
        -- check if animation is done
        local totalAnimationTime = self.kWipeTime + (#self.rows * self.kWipeDelay)
        if self.animationTime >= totalAnimationTime then
            
            -- hide the wipers
            for i=1, #self.rows do
                self.rows[i].wiper:SetIsVisible(false)
                self.rows[i].wiperVis = false
            end
            
            self.state = "done" -- might be changed by animationCallback
            if self.animationCallback then
                self.animationCallback(self)
            end
        end
        
    elseif self.state == "wipeInMedalName" then
        
        self.animationTime = self.animationTime + deltaTime
        
        local fraction = Clamp(self.animationTime / self.kWipeTime, 0.0, 1.0)
        
        local mnWiperPos = Vector(self.kMedalBorderSize * fraction, self.kPanelSize.y - self.kTitleFontSize - self.kTitleSpacing, 0.0) * self.scale + self.position
        local mnWiperSize = Vector(self.kMedalBorderSize * (1.0 - fraction), self.kTitleFontSize + self.kTitleSpacing * 2.0, 0) * self.scale
        self.medalNameWiper:SetPosition(mnWiperPos)
        self.medalNameWiper:SetSize(mnWiperSize)
        
        -- check if animation is done
        if self.animationTime >= self.kWipeTime then
            self.state = "done"
            
            self.medalNameWiper:SetIsVisible(false)
            
            if self.animationCallback then
                self.animationCallback(self)
            end
        end
        
    end
    
end

function GUIChallengeResults:Update(deltaTime)
    
    -- ensure this screen is hidden if menu is open
    local vis = not MainMenu_GetIsOpened()
    if vis ~= self.visible then
        self:SetIsVisible(vis)
    end
    
    self:UpdateButtonRollovers()
    self:UpdateButtonTransforms()
    self:UpdateAnimation(deltaTime)
    
end

function GUIChallengeResults:DisplayMedal(medalName, playbackStartCallback, playbackEndCallback)
    
    local medalGUIClassName = self.kMedalNameToClassName[medalName]
    if medalGUIClassName == nil then
        Log("no medal class name found for medal named \"%s\"", medalName)
        return
    end
    
    local script = self:SetMedalScript(medalGUIClassName)
    script:SetStartCallback(playbackStartCallback)
    script:SetEndCallback(playbackEndCallback)
    script:LoadAndPlay()
    
end

-- Fades in the entire results screen (at this point, the rows would not exist yet, so just the background and medal
-- stuff).
function GUIChallengeResults:DoFadeIn(callback)
    
    self.state = "fadeIn"
    self.animationCallback = callback
    self.animationTime = 0.0
    self:Update(0)
    
end

-- Fades out everything in the results screen.
function GUIChallengeResults:DoFadeOut(callback)
    
    self.state = "fadeOut"
    self.animationCallback = callback
    self.animationTime = 0.0
    self:Update(0)
    
end

-- Does a per-row wipe-in animation from left to right.
function GUIChallengeResults:DoWipeIn(callback)
    
    self.state = "wipeIn"
    self.animationCallback = callback
    self.animationTime = 0.0
    
end

-- Wipes in the name of the medal (presumably) just awarded.
function GUIChallengeResults:DoWipeInMedalName(callback)
    
    self.state = "wipeInMedalName"
    self.animationCallback = callback
    self.animationTime = 0.0
    
end

function GUIChallengeResults:UpdateResultsScreenTransform()
    
    local pos, scale = Fancy_Transform(Vector(0,0,0), 1.0)
    self:SetScale(Vector(scale, scale, 0))
    self:SetPosition(self.kResultsScreenPosition * scale + pos)
    
end

function GUIChallengeResults:RemoveSiblingScript(script)
    
    if US_Remove(self.siblingScripts, script) then
        -- we just removed them from our set, make sure they remove us.
        if script.RemoveSiblingScript then
            script:RemoveSiblingScript(self)
        end
    end
    
    self:SetWindowActive(script, true) -- just in case this script was preventing this window from being active.
    
end

function GUIChallengeResults:AddSiblingScript(script)
    
    if US_Add(self.siblingScripts, script) then
        -- we just added them to our list of siblings, make sure we're added to theirs.
        if script.AddSiblingScript then
            script:AddSiblingScript(self)
        end
    end
    
end

-- Disable the window with a label.  Multiple things can disable the window at once, and the window will only
-- ever be active again once all those things have set the window to active again.
function GUIChallengeResults:SetWindowActive(label, state)
    
    assert(label) -- label doesn't have to be a string, it can be anything unique (eg a pointer)
    
    if state == true and self.windowDisabled[label] then
        self.windowDisabled[label] = nil
        self.windowDisabledCount = self.windowDisabledCount - 1
    elseif state == false and not self.windowDisabled[label] then
        self.windowDisabled[label] = true
        self.windowDisabledCount = self.windowDisabledCount + 1
    end
    
end

-- Is anything preventing this window from working?
function GUIChallengeResults:GetIsWindowActive()
    return self.windowDisabledCount == 0 and self.visible == true
end

function GUIChallengeResults:CheckForButtonClicks()
    
    self:UpdateButtonRollovers()
    local hoverButton
    for i=1, #self.buttons do
        if self.buttons[i].over then
            hoverButton = self.buttons[i]
        end
    end
    
    if not hoverButton then
        return false
    end
    
    StartSoundEffect(self.kButtonClickSound)
    hoverButton.callback(hoverButton)
    
    return true
    
end

function GUIChallengeResults:SendKeyEvent(input, down)
    
    if not self:GetIsWindowActive() then
        return false
    end
    
    -- take control of mouse movement, so they player isn't also moving their view around with the mouse visible.
    -- This *should* be handled by InputHandler.lua... but... it doesn't always catch things... :(
    if input == InputKey.MouseX or input == InputKey.MouseY then
        return true
    end
    
    if input == InputKey.MouseButton0 and down then
        if self:CheckForButtonClicks() then
            return true
        end
    end
    
    return false
    
end
