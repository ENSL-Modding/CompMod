-- ======= Copyright (c) 2017, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\challenge\GUIChallengeLeaderboard.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    An abstract GUIScript class for displaying the leaderboards for challenge modes.  This is
--    extended by the GUIChallengeLeaderboardAlien class, for alien-themed leaderboards. (At the
--    time of writing, there are no marine-related challenges... but it's nice to plan ahead.)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

local kSteamProfileURL = "http://steamcommunity.com/profiles/"

Script.Load("lua/GUIAssets.lua")
Script.Load("lua/UnorderedSet.lua")

class 'GUIChallengeLeaderboard' (GUIScript)

local kDefaultLayer = 40

-- All of the below member-constants are encouraged to be overwritten by extended classes, where desired.
GUIChallengeLeaderboard.kNumRows = 10

GUIChallengeLeaderboard.kColor = Color(1,1,1,1)
GUIChallengeLeaderboard.kShadowColor = Color(0,0,0,0.5)
GUIChallengeLeaderboard.kHighlightedColor = Color(1,1,1,1)

GUIChallengeLeaderboard.kPanelWidth = 512

GUIChallengeLeaderboard.kTitleFontName = Fonts.kAgencyFB_Huge
local kAgencyHugeActualSize = 66
GUIChallengeLeaderboard.kTitleFontSize = 42

GUIChallengeLeaderboard.kFontName = Fonts.kAgencyFB_Large
local kAgencyLargeActualSize = 28
GUIChallengeLeaderboard.kFontSize = 24

GUIChallengeLeaderboard.kTooltipTextLayerOffset = 8
GUIChallengeLeaderboard.kTooltipTextShadowLayerOffset = 7
GUIChallengeLeaderboard.kTooltipBackgroundLayerOffset = 6
GUIChallengeLeaderboard.kTooltipBackgroundShadowLayerOffset = 5
GUIChallengeLeaderboard.kButtonHighlightLayerOffset = 4
GUIChallengeLeaderboard.kContentLayerOffset = 3
GUIChallengeLeaderboard.kContentShadowLayerOffset = 2
GUIChallengeLeaderboard.kHighlightLayerOffset = 1
GUIChallengeLeaderboard.kAnimationStencilLayerOffset = 1
GUIChallengeLeaderboard.kBackgroundLayerOffset = 0

GUIChallengeLeaderboard.kShadowOffset = Vector(2, 2, 0)

GUIChallengeLeaderboard.kHeaderYOffset = 74
GUIChallengeLeaderboard.kPlayerHeaderXOffset = 102
GUIChallengeLeaderboard.kDividerYOffset = 103
GUIChallengeLeaderboard.kDividerThickness = 8
GUIChallengeLeaderboard.kRowYOffset = 144
GUIChallengeLeaderboard.kRankXOffset = 47
GUIChallengeLeaderboard.kIconSize = 32
GUIChallengeLeaderboard.kCommonMargin = 8
GUIChallengeLeaderboard.kRowSpacing = 40
GUIChallengeLeaderboard.kArrowSize = Vector(48, 96, 0)
GUIChallengeLeaderboard.kArrowXOffset = 380 -- should be overidden
GUIChallengeLeaderboard.kHighlightWidth = 430 -- should be overidden
GUIChallengeLeaderboard.kPlayerButtonWidth = 160 -- will likely be overidden

GUIChallengeLeaderboard.kFriendsIcon = PrecacheAsset("ui/challenge/friends_icon.dds")
GUIChallengeLeaderboard.kGlobalIcon = PrecacheAsset("ui/challenge/globe_icon.dds")
GUIChallengeLeaderboard.kArrowIcon = PrecacheAsset("models/dev/dev_sphere.dds") -- should be overridden
GUIChallengeLeaderboard.kHighlightGraphic = PrecacheAsset("ui/challenge/leaderboard_personal_highlight.dds")
GUIChallengeLeaderboard.kHighlightColor = Color(1,1,1,1) -- should be overridden.
GUIChallengeLeaderboard.kHighlightSize = Vector(588, 67, 0)
GUIChallengeLeaderboard.kHighlightPosition = Vector(-31, 139, 0)
GUIChallengeLeaderboard.kAvatarHighlightStrength = 0.75
GUIChallengeLeaderboard.kButtonDisabledColor = Color(0.25, 0.25, 0.25, 1.0)
GUIChallengeLeaderboard.kMissingAvatarTexture = PrecacheAsset("ui/missing_avatar.dds")

GUIChallengeLeaderboard.kTooltipFontSize = 15
GUIChallengeLeaderboard.kTooltipFontName = Fonts.kAgencyFB_Small
local kAgencySmallActualSize = 18
local kAgencySmallLineSpan = 27
GUIChallengeLeaderboard.kTooltipDelayTime = 0.5
GUIChallengeLeaderboard.kTooltipFadeInTime = 0.5
GUIChallengeLeaderboard.kTooltipPersistTime = 1.0
GUIChallengeLeaderboard.kTooltipBackColor = Color(0.5, 0.5, 0.5, 0.9) -- should be overridden
GUIChallengeLeaderboard.kTooltipMargin = 4.0
GUIChallengeLeaderboard.kTooltipMarginBottom = 12.0
GUIChallengeLeaderboard.kTooltipMaxWidth = 140
GUIChallengeLeaderboard.kTooltipOffset = Vector(0,32,0) -- so mouse cursor doesn't overlap it as much

GUIChallengeLeaderboard.kLeaderboardPosition = Vector(0, 0, 0)

GUIChallengeLeaderboard.kInvalidHandle = "18446744073709551615" -- (2^64)-1

GUIChallengeLeaderboard.kWipeTime = 0.1 -- each row's wipe takes 0.1 seconds from start to finish
GUIChallengeLeaderboard.kWipeDelay = 0.016667 -- each row's wipe is delayed by this amount from the previous row.

GUIChallengeLeaderboard.kFadeTime = 1.0

GUIChallengeLeaderboard.kButtonHoverSound = PrecacheAsset("sound/NS2.fev/common/hovar")
GUIChallengeLeaderboard.kButtonClickSound = PrecacheAsset("sound/NS2.fev/common/button_click")

local avatarRequests = {} -- set of steamId64 that have active requests.

local function ActivateAvatarRequest(steamId)
    
    if not steamId then
        return
    end
    
    local steamId64 = Client.ConvertSteamId32To64(steamId)
    
    if avatarRequests[steamId64] then
        return -- already active
    end
    
    avatarRequests[steamId64] = true
    
    Client.ActivateAvatarRequest(steamId64)

end

local function DeactivateAvatarRequest(steamId)
    
    if not steamId then
        return
    end
    
    local steamId64 = Client.ConvertSteamId32To64(steamId)
    
    if not avatarRequests[steamId64] then
        return -- already inactive.
    end
    
    avatarRequests[steamId64] = nil
    
    Client.DeactivateAvatarRequest(steamId64)
    
end

local function DeactivateAllAvatarRequests()
    
    for steamId64, __ in pairs(avatarRequests) do
        Client.DeactivateAvatarRequest(steamId64)
    end
    
    avatarRequests = {}

end

function GUIChallengeLeaderboard:UpdateRowTransform(rowIndex)
    
    local shadowOffset = self.kShadowOffset * self.scale
    local rowOffset = Vector(0, self.kRowSpacing * (rowIndex-1) * self.scale.y, 0)
    
    local row = self.rows[rowIndex]
    
    -- Rank
    local rankPosition = Vector(self.kRankXOffset, self.kRowYOffset, 0)
    rankPosition = (rankPosition * self.scale) + self.position + rowOffset
    row.rankItem:SetPosition(rankPosition)
    row.rankShadowItem:SetPosition(rankPosition + shadowOffset)
    row.rankItem:SetScale(self.fontScale)
    row.rankShadowItem:SetScale(self.fontScale)
    
    -- Player Info (avatar button, name text button)
    local iconPosition = Vector(rankPosition.x + (self.kCommonMargin * self.scale.x), rankPosition.y - (self.kIconSize * 0.5 * self.scale.y), 0)
    row.playerItemTable.iconButton.realPos = Vector(iconPosition)
    local iconSize = Vector(self.scale.x * self.kIconSize, self.scale.y * self.kIconSize, 0)
    row.playerItemTable.iconButton.realSize = Vector(iconSize)
    row.playerItemTable.iconButton:SetPosition(iconPosition, shadowOffset)
    row.playerItemTable.iconButton:SetSize(iconSize)
    
    local namePosition = Vector(rankPosition.x + ((self.kIconSize + self.kCommonMargin * 3.0) * self.scale.x), rankPosition.y, 0)
    local nameButtonPosition = namePosition - Vector(0, self.kFontSize * 0.5 * self.scale.y, 0)
    local nameSize = Vector(self.scale.x * self.kPlayerButtonWidth, self.scale.y * self.kIconSize, 0)
    row.playerItemTable.nameButton.realPos = Vector(nameButtonPosition)
    row.playerItemTable.nameButton.realSize = Vector(nameSize)
    row.playerItemTable.nameButton:SetPosition(namePosition, shadowOffset)
    row.playerItemTable.nameButton:SetSize(nameSize)
    
    -- Animation wiper (mostly just to get the y-coordinates set correctly, x is handled by animation whenever
    -- animation is running)
    row.wipePos = Vector(self.position.x, rankPosition.y - (self.kRowSpacing * 0.5 * self.scale.y) , 0.0)
    row.wipeSize = Vector(self:GetRowWidth(), self.kRowSpacing, 0.0) * self.scale
    row.wiper:SetPosition(row.wipePos)
    row.wiper:SetSize(row.wipeSize)
    
end

function GUIChallengeLeaderboard:UpdateRowStencilFunc(rowIndex, sFunc)
    
    local row = self.rows[rowIndex]
    
    row.rankItem:SetStencilFunc(sFunc)
    row.rankShadowItem:SetStencilFunc(sFunc)
    row.playerItemTable:SetStencilFunc(sFunc)
    
end

-- Called to update the positioning and scaling of all items in the leaderboard.
function GUIChallengeLeaderboard:UpdateTransform()
    
    local shadowOffset = self.kShadowOffset * self.scale
    
    -- Header
    -- Title
    local titlePosition = Vector(self.kPanelWidth * 0.5, self.kTitleFontSize * 0.5, 0)
    titlePosition = (titlePosition * self.scale) + self.position
    self.titleItem:SetPosition(titlePosition)
    self.titleShadowItem:SetPosition(titlePosition + shadowOffset)
    self.titleItem:SetScale(self.titleFontScale)
    self.titleShadowItem:SetScale(self.titleFontScale)
    
    -- Rank
    local rankPosition = Vector(0, self.kHeaderYOffset, 0)
    rankPosition = (rankPosition * self.scale) + self.position
    self.rankHeaderItem:SetPosition(rankPosition)
    self.rankHeaderShadowItem:SetPosition(rankPosition + shadowOffset)
    self.rankHeaderItem:SetScale(self.fontScale)
    self.rankHeaderShadowItem:SetScale(self.fontScale)
    
    -- Player
    local playerPosition = Vector(self.kPlayerHeaderXOffset, self.kHeaderYOffset, 0)
    playerPosition = (playerPosition * self.scale) + self.position
    self.playerHeaderItem:SetPosition(playerPosition)
    self.playerHeaderShadowItem:SetPosition(playerPosition + shadowOffset)
    self.playerHeaderItem:SetScale(self.fontScale)
    self.playerHeaderShadowItem:SetScale(self.fontScale)
    
    -- Divider
    local dividerPosition = Vector(0, self.kDividerYOffset, 0)
    dividerPosition = (dividerPosition * self.scale) + self.position
    self.dividerItem:SetPosition(dividerPosition)
    self.dividerShadowItem:SetPosition(dividerPosition + shadowOffset)
    local dividerSize = Vector(self.kPanelWidth * self.scale.x, self.kDividerThickness * self.scale.y, 0)
    self.dividerItem:SetSize(dividerSize)
    self.dividerShadowItem:SetSize(dividerSize)
    
    -- Row Items
    for i=1, #self.rows do
        self:UpdateRowTransform(i)
    end
    
    -- Buttons
    local regularButtonSize = Vector(self.kIconSize, self.kIconSize, 0) * self.scale
    
    local friendPos = Vector(self.kIconSize, self.kCommonMargin, 0)
    friendPos = (friendPos * self.scale) + self.position
    self.friendsButton.realPos = Vector(friendPos)
    self.friendsButton.realSize = Vector(regularButtonSize)
    self.friendsButton:SetPosition(friendPos, shadowOffset)
    self.friendsButton:SetSize(regularButtonSize)
    
    local globalPos = Vector(self.kIconSize * 2.0 + self.kCommonMargin, self.kCommonMargin, 0)
    globalPos = (globalPos * self.scale) + self.position
    self.globalButton.realPos = Vector(globalPos)
    self.globalButton.realSize = Vector(regularButtonSize)
    self.globalButton:SetPosition(globalPos, shadowOffset)
    self.globalButton:SetSize(regularButtonSize)
    
    local upArrowPos = Vector(self.kArrowXOffset, self.kRowYOffset - self.kIconSize * 0.5, 0)
    local downArrowPos = upArrowPos + Vector(0, (self.kRowSpacing * (self.kNumRows - 1)) + self.kIconSize - self.kArrowSize.y, 0)
    upArrowPos = (upArrowPos * self.scale) + self.position
    downArrowPos = (downArrowPos * self.scale) + self.position
    local arrowSize = self.kArrowSize * self.scale
    self.upArrowButton.realSize = arrowSize
    self.downArrowButton.realSize = arrowSize
    self.upArrowButton.realPos = upArrowPos
    self.downArrowButton.realPos = downArrowPos
    self.upArrowButton:SetPosition(upArrowPos, shadowOffset)
    self.downArrowButton:SetPosition(downArrowPos, shadowOffset)
    self.upArrowButton:SetSize(arrowSize)
    self.downArrowButton:SetSize(arrowSize)
    
end

-- Returns the entry data for the given row index, or nil if not found.
function GUIChallengeLeaderboard:GetEntryDisplayedAtIndex(rowIndex)
    
    if not self.displayedTopIndex then
        return nil
    end
    
    local entryTable = self:GetActiveData()
    
    return entryTable[self.displayedTopIndex + rowIndex - 1]
    
end

function GUIChallengeLeaderboard:OnProfileButtonClicked(rowIndex)
    
    local entry = self:GetEntryDisplayedAtIndex(rowIndex)
    if not entry then
        return
    end
    
    local steamId = entry.steamId
    Client.ShowWebpage(string.format("%s[U:1:%s]", kSteamProfileURL, steamId))
    
end

function GUIChallengeLeaderboard:CreateButtonCommon(onClick, tooltip, disabledTooltip)
    
    local newButton = {}
    newButton.active = false
    newButton.over = false
    newButton.board = self
    newButton.enabled = true
    newButton.visible = true
    
    -- function called when button is (successfully) clicked on.  Will not fire if
    -- user clicks on button that was already "active", or if item is not visible.
    newButton.onClick = onClick
    
    if tooltip then
        newButton.tooltip = Locale.ResolveString(tooltip)
    end
    
    if disabledTooltip then
        newButton.disabledTooltip = Locale.ResolveString(disabledTooltip)
    end
    
    newButton.SetIsEnabled = function(button, state)
        button.enabled = state
    end
    
    self.buttons:Add(newButton)
    
    return newButton
    
end

function GUIChallengeLeaderboard:CreateSimpleButton(graphic, onClick, tooltip, disabledTooltip)
    
    local newButton = self:CreateButtonCommon(onClick, tooltip, disabledTooltip)
    
    local item = self:CreateGUIItem()
    item:SetColor(self.kColor)
    local shadowItem = self:CreateGUIItem()
    shadowItem:SetColor(self.kShadowColor)
    
    newButton.color = Color(self.kColor)
    newButton.shadowColor = Color(self.kShadowColor)
    newButton.item = item
    newButton.shadowItem = shadowItem
    newButton.type = "icon"
    
    if graphic then
        newButton.item:SetTexture(graphic)
        newButton.shadowItem:SetTexture(graphic)
    end
    
    newButton.board = self
    
    newButton.UpdateLayers = function(button)
        button.item:SetLayer(self.layer + self.kContentLayerOffset)
        button.shadowItem:SetLayer(self.layer + self.kContentShadowLayerOffset)
    end
    
    newButton.SetOpacity = function(button, opacity)
        local color = Color(button.color)
        color.a = color.a * opacity
        button.item:SetColor(color)
        
        local shadowColor = Color(button.shadowColor)
        shadowColor.a = shadowColor.a * opacity
        button.shadowItem:SetColor(shadowColor)
    end
    
    newButton.SetStencilFunc = function(button, sFunc)
        button.item:SetStencilFunc(sFunc)
        button.shadowItem:SetStencilFunc(sFunc)
    end
    
    newButton.SetIsVisible = function(button, state)
        button.visible = state
        button:UpdateVisibility()
    end
    
    newButton.UpdateVisibility = function(button)
        local vis = button.visible and self.visible
        button.item:SetIsVisible(vis)
        button.shadowItem:SetIsVisible(vis)
    end
    
    newButton.GetIsVisible = function(button, state)
        return button.item:GetIsVisible()
    end
    
    local old_Button_SetIsEnabled = newButton.SetIsEnabled
    newButton.SetIsEnabled = function(button, state)
        old_Button_SetIsEnabled(button, state)
        
        if state then
            button.item:SetColor(self.kColor)
            button.color = Color(self.kColor)
        else
            button.item:SetColor(self.kButtonDisabledColor)
            button.color = Color(self.kButtonDisabledColor)
        end
    end
    
    newButton.Highlight = function(button)
        button.item:SetColor(self.kHighlightedColor)
        button.color = Color(self.kHighlightedColor)
    end
    
    newButton.UnHighlight = function(button)
        button.item:SetColor(self.kColor)
        button.color = Color(self.kColor)
    end
    
    newButton.SetPosition = function(button, pos, shadowOffset)
        button.item:SetPosition(pos)
        button.shadowItem:SetPosition(pos + shadowOffset)
    end
    
    newButton.SetSize = function(button, size)
        button.item:SetSize(size)
        button.shadowItem:SetSize(size)
    end
    
    return newButton
    
end

function GUIChallengeLeaderboard:CreateIconButton(rowIndex)
    
    local newButton = self:CreateSimpleButton(self.kMissingAvatarTexture,
        function(button)
            button.board:OnProfileButtonClicked(button.rowIndex)
        end, "LEADERBOARD_TOOLTIP_PROFILE")
    newButton.item:SetColor(Color(1,1,1,1))
    newButton.color = Color(1,1,1,1)
    newButton.type = "player_icon"
    newButton.overlayItem = self:CreateGUIItem()
    newButton.overlayItem:SetIsVisible(false)
    newButton.overlayItem:SetBlendTechnique(GUIItem.Add)
    newButton.overlayItem:SetColor(Color(1,1,1,self.kAvatarHighlightStrength))
    newButton.highlightColor = Color(1,1,1, self.kAvatarHighlightStrength)
    newButton.overlayItem:SetTexture(self.kMissingAvatarTexture)
    
    local oldUpdateLayers = newButton.UpdateLayers
    newButton.UpdateLayers = function(button)
        oldUpdateLayers(button)
        button.overlayItem:SetLayer(self.layer + self.kButtonHighlightLayerOffset)
    end
    
    local oldSetOpacity = newButton.SetOpacity
    newButton.SetOpacity = function(button, opacity)
        oldSetOpacity(button, opacity)
        
        local color = Color(button.highlightColor)
        color.a = color.a * opacity
        button.overlayItem:SetColor(color)
    end
    
    local oldSetStencilFunc = newButton.SetStencilFunc
    newButton.SetStencilFunc = function(button, sFunc)
        oldSetStencilFunc(button, sFunc)
        button.overlayItem:SetStencilFunc(sFunc)
    end
    
    newButton.SetTexture = function(button, texture)
        button.overlayItem:SetTexture(texture)
        button.item:SetTexture(texture)
    end
    
    newButton.Highlight = function(button)
        button.overlayItem:SetIsVisible(true)
    end
    
    newButton.UnHighlight = function(button)
        button.overlayItem:SetIsVisible(false)
    end
    
    local oldSetPosition = newButton.SetPosition
    newButton.SetPosition = function(button, pos, shadowOffset)
        oldSetPosition(button, pos, shadowOffset)
        button.overlayItem:SetPosition(pos)
    end
    
    local oldSetSize = newButton.SetSize
    newButton.SetSize = function(button, size)
        oldSetSize(button, size)
        button.overlayItem:SetSize(size)
    end
    
    return newButton
    
end

function GUIChallengeLeaderboard:CreateTextButton(text, onClick, tooltip, disabledTooltip)
    
    local newButton = self:CreateButtonCommon(onClick, tooltip)
    
    local item, shadowItem = self:CreateTextItem(true)
    newButton.item = item
    newButton.color = Color(newButton.item:GetColor())
    newButton.shadowItem = shadowItem
    newButton.shadowColor = Color(newButton.shadowItem:GetColor())
    newButton.type = "text"
    
    newButton.UpdateLayers = function(button)
        button.item:SetLayer(self.layer + self.kContentLayerOffset)
        button.shadowItem:SetLayer(self.layer + self.kContentShadowLayerOffset)
    end
    
    newButton.SetOpacity = function(button, opacity)
        local color = Color(button.color)
        color.a = color.a * opacity
        button.item:SetColor(color)
        
        local shadowColor = Color(button.shadowColor)
        shadowColor.a = shadowColor.a * opacity
        button.shadowItem:SetColor(shadowColor)
    end
    
    newButton.SetStencilFunc = function(button, sFunc)
        button.item:SetStencilFunc(sFunc)
        button.shadowItem:SetStencilFunc(sFunc)
    end
    
    newButton.Highlight = function(button)
        button.item:SetColor(self.kHighlightedColor)
        button.color = Color(self.kHighlightedColor)
    end
    
    newButton.UnHighlight = function(button)
        button.item:SetColor(self.kColor)
        button.color = Color(self.kColor)
    end
    
    newButton.SetPosition = function(button, pos, shadowOffset)
        button.item:SetPosition(pos)
        button.shadowItem:SetPosition(pos + shadowOffset)
    end
    
    newButton.SetSize = function(button, size)
        button.item:SetScale(self.fontScale)
        button.shadowItem:SetScale(self.fontScale)
    end
    
    newButton.SetText = function(button, text)
        button.item:SetText(text)
        button.shadowItem:SetText(text)
    end
    
    newButton.SetIsVisible = function(button, state)
        button.visible = state
        button:UpdateVisibility()
    end
    
    newButton.UpdateVisibility = function(button)
        local vis = button.visible and self.visible
        button.item:SetIsVisible(vis)
        button.shadowItem:SetIsVisible(vis)
    end
    
    newButton.GetIsVisible = function(button)
        return button.item:GetIsVisible()
    end
    
    return newButton
    
end

function GUIChallengeLeaderboard:CreateGUIItem()
    
    local item = GUI.CreateItem()
    self.items:Add(item)
    
    return item
    
end

function GUIChallengeLeaderboard:CreateTextItem(createShadow)
    
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

function GUIChallengeLeaderboard:CreatePlayerItem(rowIndex)
    
    local playerNameButton = self:CreateTextButton("",
        function(button)
            button.board:OnProfileButtonClicked(button.rowIndex)
        end, "LEADERBOARD_TOOLTIP_PROFILE")
    playerNameButton.rowIndex = rowIndex
    playerNameButton.item:SetTextAlignmentX(GUIItem.Align_Min)
    playerNameButton.shadowItem:SetTextAlignmentX(GUIItem.Align_Min)
    
    local playerIconButton = self:CreateIconButton(rowIndex)
    playerIconButton.rowIndex = rowIndex
    
    local newPlayerEntry = {}
    newPlayerEntry.nameButton = playerNameButton
    newPlayerEntry.iconButton = playerIconButton
    
    newPlayerEntry.UpdateLayers = function(entry)
        entry.nameButton:UpdateLayers()
        entry.iconButton:UpdateLayers()
    end
    
    newPlayerEntry.SetOpacity = function(entry, opacity)
        entry.nameButton:SetOpacity(opacity)
        entry.iconButton:SetOpacity(opacity)
    end
    
    newPlayerEntry.SetStencilFunc = function(entry, sFunc)
        entry.nameButton:SetStencilFunc(sFunc)
        entry.iconButton:SetStencilFunc(sFunc)
    end
    
    return newPlayerEntry
    
end

function GUIChallengeLeaderboard:DestroyGUIItem(item)
    
    GUI.DestroyItem(item)
    self.items:RemoveElement(item)
    self.buttons:RemoveElement(item) -- just in case.
    
end

function GUIChallengeLeaderboard:InitializeRow(rowIndex)
    
    local row = self.rows[rowIndex]
    row.visible = true
    
    row.rankItem, row.rankShadowItem = self:CreateTextItem(true)
    row.rankItem:SetTextAlignmentX(GUIItem.Align_Max)
    row.rankShadowItem:SetTextAlignmentX(GUIItem.Align_Max)
    row.rankItem:SetIsVisible(false)
    row.rankShadowItem:SetIsVisible(false)
    
    row.playerItemTable = self:CreatePlayerItem(rowIndex)
    row.playerItemTable.nameButton:SetIsVisible(false)
    row.playerItemTable.iconButton:SetIsVisible(false)
    
    -- initialize the animation wipe
    row.wiper = self:CreateGUIItem()
    row.wiper:SetIsStencil(true)
    row.wiper:SetClearsStencilBuffer(false)
    
end

function GUIChallengeLeaderboard:UpdateFontScales()
    
    -- we assume scale.y is the more pertinant scaling factor here.  They should be the same anyways, but just in case...
    local titleScale = (self.kTitleFontSize / kAgencyHugeActualSize) * self.scale.y
    self.titleFontScale = Vector(titleScale, titleScale, 0)
    
    local regularScale = (self.kFontSize / kAgencyLargeActualSize) * self.scale.y
    self.fontScale = Vector(regularScale, regularScale, 0)
    
    local tooltipScale = (self.kTooltipFontSize / kAgencySmallActualSize) * self.scale.y
    self.tooltipFontScale = Vector(tooltipScale, tooltipScale, 0)
    
end

function GUIChallengeLeaderboard:InitGUI()
    
    -- Initialize title graphic
    self.titleItem, self.titleShadowItem = self:CreateTextItem(true)
    self.titleItem:SetTextAlignmentX(GUIItem.Align_Center)
    self.titleShadowItem:SetTextAlignmentX(GUIItem.Align_Center)
    self.titleItem:SetFontName(self.kTitleFontName)
    self.titleShadowItem:SetFontName(self.kTitleFontName)
    self.titleItem:SetText(Locale.ResolveString("LEADERBOARD"))
    self.titleShadowItem:SetText(Locale.ResolveString("LEADERBOARD"))
    
    -- Every leaderboard table consists of at least two columns (rank, player info) followed by
    -- whatever score data is used.
    
    -- Initialize "rank" column heading text.
    self.rankHeaderItem, self.rankHeaderShadowItem = self:CreateTextItem(true)
    self.rankHeaderItem:SetText(Locale.ResolveString("RANK"))
    self.rankHeaderShadowItem:SetText(Locale.ResolveString("RANK"))
    
    -- Initialize "player" column heading text.
    self.playerHeaderItem, self.playerHeaderShadowItem = self:CreateTextItem(true)
    self.playerHeaderItem:SetTextAlignmentX(GUIItem.Align_Min) -- left-aligned text
    self.playerHeaderShadowItem:SetTextAlignmentX(GUIItem.Align_Min)
    self.playerHeaderItem:SetText(Locale.ResolveString("LEADERBOARD_PLAYER"))
    self.playerHeaderShadowItem:SetText(Locale.ResolveString("LEADERBOARD_PLAYER"))
    
    -- Initialize per-row items
    for i=1, #self.rows do
        self:InitializeRow(i)
    end
    
    -- Initialize divider between header and contents
    self.dividerItem = self:CreateGUIItem()
    self.dividerShadowItem = self:CreateGUIItem()
    self.dividerItem:SetColor(self.kColor)
    self.dividerShadowItem:SetColor(self.kShadowColor)
    
    -- Initialize buttons.
    self.friendsButton = self:CreateSimpleButton(self.kFriendsIcon,
        function(button)
            button.board:SetBoardFilter("friends")
        end, "LEADERBOARD_TOOLTIP_FRIENDS")
    self.friendsButton.active = true
    self.friendsButton:Highlight()
    self.globalButton = self:CreateSimpleButton(self.kGlobalIcon,
        function(button)
            button.board:SetBoardFilter("global")
        end, "LEADERBOARD_TOOLTIP_GLOBAL")
    self.upArrowButton = self:CreateSimpleButton(self.kArrowIcon,
        function(button)
            button.board:OnArrowClicked("up")
        end, "LEADERBOARD_TOOLTIP_ARROW")
    self.upArrowButton:SetIsVisible(false)
    self.downArrowButton = self:CreateSimpleButton(self.kArrowIcon,
        function(button)
            button.board:OnArrowClicked("down")
        end, "LEADERBOARD_TOOLTIP_ARROW")
    self.downArrowButton.item:SetTextureCoordinates(1.0, 1.0, 0.0, 0.0) -- rotate 180 degrees.
    self.downArrowButton.shadowItem:SetTextureCoordinates(1.0, 1.0, 0.0, 0.0) -- rotate 180 degrees.
    self.downArrowButton:SetIsVisible(false)
    
    -- Initialize personal row highlight
    self.highlightItem = self:CreateGUIItem()
    self.highlightItem:SetTexture(self.kHighlightGraphic)
    self.highlightItem:SetBlendTechnique(GUIItem.Add)
    self.highlightItem:SetIsVisible(false) -- hide until we know player is actually on board.
    self.highlightItem:SetColor(self.kHighlightColor)
    
end

function GUIChallengeLeaderboard:UpdateRowLayers(index, row)
    
    local contentLayer = self.layer + self.kContentLayerOffset
    local shadowLayer = self.layer + self.kContentShadowLayerOffset
    
    row.rankItem:SetLayer(contentLayer)
    row.rankShadowItem:SetLayer(shadowLayer)
    
    row.playerItemTable:UpdateLayers()
    
    row.wiper:SetLayer(self.layer + self.kAnimationStencilLayerOffset)
    
end

function GUIChallengeLeaderboard:UpdateRowsLayers()
    
    for i=1, #self.rows do
        self:UpdateRowLayers(i, self.rows[i])
    end
    
end

function GUIChallengeLeaderboard:UpdateLayers()
    
    local contentLayer = self.layer + self.kContentLayerOffset
    local shadowLayer = self.layer + self.kContentShadowLayerOffset
    
    self.titleItem:SetLayer(contentLayer)
    self.titleShadowItem:SetLayer(shadowLayer)
    
    self.rankHeaderItem:SetLayer(contentLayer)
    self.rankHeaderShadowItem:SetLayer(shadowLayer)
    
    self.playerHeaderItem:SetLayer(contentLayer)
    self.playerHeaderShadowItem:SetLayer(shadowLayer)
    
    self.dividerItem:SetLayer(contentLayer)
    self.dividerShadowItem:SetLayer(shadowLayer)
    
    self:UpdateRowsLayers()
    
    self.friendsButton:UpdateLayers()
    self.globalButton:UpdateLayers()
    self.upArrowButton:UpdateLayers()
    self.downArrowButton:UpdateLayers()
    
    self.highlightItem:SetLayer(self.layer + self.kHighlightLayerOffset)
    
    if self.tooltip then
        
        self.tooltip.back:SetLayer(self.layer + self.kTooltipBackgroundLayerOffset)
        self.tooltip.backShadowBottom:SetLayer(self.layer + self.kTooltipBackgroundShadowLayerOffset)
        self.tooltip.backShadowRight:SetLayer(self.layer + self.kTooltipBackgroundShadowLayerOffset)
        
        self.tooltip.textItem:SetLayer(self.layer + self.kTooltipTextLayerOffset)
        self.tooltip.textShadowItem:SetLayer(self.layer + self.kTooltipTextShadowLayerOffset)
        
    end
    
end

function GUIChallengeLeaderboard:SetLayer(layer)
    
    self.layer = layer
    self:UpdateLayers()
    
end

function GUIChallengeLeaderboard:AddSiblingScript(script)
    
    if self.siblingScripts:Add(script) then
        -- we just added them to our list of siblings, make sure we're added to theirs.
        if script.AddSiblingScript then
            script:AddSiblingScript(self)
        end
    end
    
end

function GUIChallengeLeaderboard:RemoveSiblingScript(script)
    
    if self.siblingScripts:RemoveElement(script) then
        -- we just removed them from our set, make sure they remove us.
        if script.RemoveSiblingScript then
            script:RemoveSiblingScript(self)
        end
    end
    
    self:SetWindowActive(script, true) -- just in case this script was preventing this window from being active.
    
end

function GUIChallengeLeaderboard:SetIsVisible(state)
    
    self.visible = state
    self:UpdateVisibility()
    
end

function GUIChallengeLeaderboard:UpdateRowVisibility(rowIndex)
    
    local row = self.rows[rowIndex]
    local vis = self.visible and row.visible
    
    row.rankItem:SetIsVisible(vis)
    row.rankShadowItem:SetIsVisible(vis)
    row.playerItemTable.nameButton:SetIsVisible(row.visible)
    row.playerItemTable.iconButton:SetIsVisible(row.visible)
    
end

function GUIChallengeLeaderboard:UpdateVisibility()
    
    self.titleItem:SetIsVisible(self.visible)
    self.titleShadowItem:SetIsVisible(self.visible)
    
    self.rankHeaderItem:SetIsVisible(self.visible)
    self.rankHeaderShadowItem:SetIsVisible(self.visible)
    
    self.playerHeaderItem:SetIsVisible(self.visible)
    self.playerHeaderShadowItem:SetIsVisible(self.visible)
    
    self.dividerItem:SetIsVisible(self.visible)
    self.dividerShadowItem:SetIsVisible(self.visible)
    
    for i=1, #self.rows do
        self:UpdateRowVisibility(i)
    end
    
    self.highlightItem:SetIsVisible(self.visible and self.highlightVis)
    
    -- update button visibilities (their update function takes into account the leaderboard's visibility)
    for i=1, #self.buttons do
        self.buttons[i]:UpdateVisibility()
    end
    
end

function GUIChallengeLeaderboard:Initialize()
    
    self.filterType = "friends" -- only display friend's scores.
    
    -- stores entries in an array where indices are equal to rank... therefore table array will have
    -- holes in the data.  These holes will be filled as requested.
    self.globalData = {} -- stores entries in a table associated by rank.
    self.globalDataMaxEntry = -1
    
    -- stores entries in a sorted order, but indices are unrelated to rank, as the friends score
    -- entries will likely have holes in it (eg player is friends with rank #1, 2, 3, 5, but not 4.)
    -- we initialize to nil instead of an empty table because the way steam works for fetching
    -- friends-only data is all or nothing.  There is no way to specify only a range of friends.
    -- Therefore if friendsData is not nil, it is filled.
    self.friendsData = nil
    
    -- the index of the entry that is displayed at the top of the list.  If the filter is global,
    -- this means the global rank that is displayed in row 1 of the leaderboard.  If the filter is
    -- friends, this means the index in the friends entry table that is displayed in row 1.  If nil,
    -- we revert to some default behavior.
    self.displayedTopIndex = nil
    self.displayedBottomIndex = nil -- will never be nil unless displayedTopIndex is also nil.
    
    -- the ROW INDEX of the entry that is displayed that is highlighted.  NOT the entry index.
    self.highlightedIndex = nil
    self.highlightVis = true
    
    -- the global player rank of the player's entry.  "nil" indicates it has not been retrieved,
    -- 0 indicates the player does not have a score entry.
    self.playerRank = nil
    
    -- table of items that make up the tooltip.
    self.tooltip = nil
    
    -- a better name for this might be "state".
    self.animation = "hidden" -- completely invisible, waiting for the go-ahead to fade-in.
    self.animationTime = nil
    
    -- true when the next set of row data is ready to be animated on. (Sometimes it can be faster than the animation, so
    -- we need to wait.)
    self.nextDataReady = false
    
    -- tooltip hover is for the whole board, not per-button, to allow the user to hover over one button, then quickly
    -- inspect the other buttons without having to wait again, which would be frustrating.
    self.tooltipHoverTime = 0.0
    
    -- To make cleanup easier, we keep track of which items belong to this script.
    self.items = UnorderedSet()
    self.buttons = UnorderedSet()
    self.siblingScripts = UnorderedSet()
    
    -- Initialize important values
    self.position = Vector(0,0,0)
    self.scale = Vector(1,1,1)
    self.layer = kDefaultLayer
    
    self.windowDisabled = {}
    self.windowDisabledCount = 0
    
    -- Initialize empty tables, one for each row.
    self.rows = {}
    for i=1, self.kNumRows do
        self.rows[i] = {}
    end
    
    self:InitGUI()
    -- setup stencils for row items
    for i=1, #self.rows do
        self:UpdateRowStencilFunc(i, GUIItem.Equal)
    end
    
    self:SetIsVisible(true)
    self:UpdateLeaderboardTransform()
    self:UpdateFontScales()
    self:UpdateTransform()
    self:UpdateButtonsRollovers()
    self:UpdateActiveData()
    self:UpdateLayers()
    
    MouseTracker_SetIsVisible(true, nil, true)
    
    self.updateInterval = 0
    
end

function GUIChallengeLeaderboard:DoWipeOutAnimation(callback)
    
    self.animationCallback = callback
    self.animation = "out"
    self.animationTime = 0.0
    
    -- setup all elements of the row to only render inside the wiper, so they will be hidden
    -- as the wiper slides right
    for i=1, #self.rows do
        self:UpdateRowStencilFunc(i, GUIItem.NotEqual)
    end
    
end

function GUIChallengeLeaderboard:DoWipeInAnimation(callback)
    
    self.animationCallback = callback
    self.animation = "in"
    self.animationTime = 0.0
    
    -- setup all elements of the row to be wiped out by the wiper, so they will be revealed
    -- as the wiper slides right.
    for i=1, #self.rows do
        self:UpdateRowStencilFunc(i, GUIItem.Equal)
    end
    
end

function GUIChallengeLeaderboard:OnArrowClicked(direction)
    
    self:DoWipeOutAnimation(
    function(self)
        self.animation = "waitingForDownload"
    end)
    
    if direction == "up" then
        self.displayedTopIndex = self.displayedTopIndex - self.kNumRows
    elseif direction == "down" then
        self.displayedTopIndex = self.displayedTopIndex + self.kNumRows
    end
    
    self.displayedBottomIndex = self.displayedTopIndex + self.kNumRows - 1
    
    self:UpdateActiveData()
    
    self.upArrowButton.item:SetIsVisible(false)
    self.upArrowButton.shadowItem:SetIsVisible(false)
    self.downArrowButton.item:SetIsVisible(false)
    self.downArrowButton.shadowItem:SetIsVisible(false)
    
    self:Update(0)
    
end

function GUIChallengeLeaderboard:Uninitialize()
    
    DeactivateAllAvatarRequests()
    
    -- Cleanup is easy because every item created by the system is in one
    -- convenient set.
    for i=1, #self.items do
        GUI.DestroyItem(self.items[i])
    end
    
    MouseTracker_SetIsVisible(false)
    
    -- Sever our connection with any sibling scripts.
    while #self.siblingScripts > 0 do
        self:RemoveSiblingScript(self.siblingScripts[1])
    end
    
end

function GUIChallengeLeaderboard:OnResolutionChanged()
    
    -- side effect: recalculates transforms for everything -- invalidating wiper positions.
    self:UpdateLeaderboardTransform()
    
    if self.animation == "done" then
        -- ensure rows are not hidden by wipers
        for i=1, #self.rows do
            self:UpdateRowStencilFunc(i, GUIItem.NotEqual)
        end
        
    elseif self.animation == "waitingForDownload" then
        -- ensure rows are hidden by wipers
        for i=1, #self.rows do
            self:UpdateRowStencilFunc(i, GUIItem.Equal)
        end
        
    end
    
end

-- Sets the absolute screen position of the upper-left corner of this panel, in pixels.
-- (Not scaled 1080p pixels or any of that funkery... I've learned my lesson...)
-- Since it is the upper-left corner of the panel, this is not affected by scaling in any
-- way.
function GUIChallengeLeaderboard:SetPosition(position)
    
    self.position = position
    self:UpdateTransform()
    
end

-- Sets the scaling value of this panel.  Measurements provided are taken from a mockup
-- done at 1920x1080, so scale values should be calculated with this in mind.
function GUIChallengeLeaderboard:SetScale(scale)
    
    self.scale = scale
    self:UpdateFontScales()
    self:UpdateTransform()
    
end

-- Hides any graphical elements that belong to the row.
function GUIChallengeLeaderboard:HideRow(rowIndex)
    
    local row = self.rows[rowIndex]
    row.visible = false
    self:UpdateRowVisibility(rowIndex)
    
end

-- Returns the steam name associated with this steamId, or nil if it's not yet known.
function GUIChallengeLeaderboard:GetPlayerNameForSteamId(steamId)
    
    local result
    result = GetSteamLeaderboardManager():GetSteamName(steamId)
    
    if result then
        return result
    end
    
    -- try again, as sometimes the name will be made available immediately 
    result = GetSteamLeaderboardManager():GetSteamName(steamId)
    
    return result -- name or nil
    
end

-- Clears the row at the given index and fills it with the supplied data.
function GUIChallengeLeaderboard:SetRowData(rowIndex, data)
    
    local row = self.rows[rowIndex]
    
    local prevSteamId = row.playerSteamId
    
    row.playerSteamId = data.steamId
    if row.playerSteamId then
        row.playerName = self:GetPlayerNameForSteamId(row.playerSteamId)
    end
    
    row.rankItem:SetText(tostring(data.globalRank))
    row.rankShadowItem:SetText(tostring(data.globalRank))
    
    if row.playerName then -- we might still be waiting on Steam for the player name.
        row.playerItemTable.nameButton:SetText(row.playerName)
        row.showName = true
    else
        row.showName = false
    end
    
    row.visible = true
    self:UpdateRowVisibility(rowIndex)
    
    row.playerItemTable.iconButton:SetTexture(self.kMissingAvatarTexture)
    
    -- Deactivate previous avatar request.
    DeactivateAvatarRequest(prevSteamId) -- performs a nil check, so this is okay.
    
    -- Activate new avatar request.
    ActivateAvatarRequest(row.playerSteamId)
    
end

-- Clear all stored data for the leaderboard.  UpdateActiveData() should be called
-- afterwards, otherwise GUI will be outdated.
function GUIChallengeLeaderboard:ClearData()
    
    self.globalData = {}
    self.friendsData = nil
    
end

function GUIChallengeLeaderboard:SetBoardFilter(type)
    
    if type == "friends" then
        self.friendsButton.active = true
        self.friendsButton:Highlight()
        self.globalButton.active = false
        self.globalButton:UnHighlight()
    elseif type == "global" then
        self.globalButton.active = true
        self.globalButton:Highlight()
        self.friendsButton.active = false
        self.friendsButton:UnHighlight()
    end
    
    self:DoWipeOutAnimation(function(self)
        self.animation = "waitingForDownload"
    end)
    
    self.filterType = type
    
    self.upArrowButton.item:SetIsVisible(false)
    self.upArrowButton.shadowItem:SetIsVisible(false)
    self.downArrowButton.item:SetIsVisible(false)
    self.downArrowButton.shadowItem:SetIsVisible(false)
    
    -- Changing filter type (or clicking the same button that's active) causes the view range to reset to default range.
    self.displayedTopIndex = nil
    
    -- also pull double-duty and have switching types act as a flush/refresh.
    self:ClearData()
    self:UpdateActiveData()
    
    self:Update(0)
    
end

function GUIChallengeLeaderboard:CheckForButtonClicks()
    
    self:UpdateButtonsRollovers()
    local button
    for i=1, #self.buttons do
        if self.buttons[i].over and self.buttons[i].enabled and self.buttons[i]:GetIsVisible() then
            button = self.buttons[i]
            break
        end
    end
    
    if not button then
        return false
    end
    
    StartSoundEffect(self.kButtonClickSound)
    button.onClick(button)
    return true
    
end

function GUIChallengeLeaderboard:SendKeyEvent(input, down)
    
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

-- Is anything external preventing this window from working?
function GUIChallengeLeaderboard:GetIsWindowActive()
    return self.windowDisabledCount == 0 and self.visible
end

-- keep track of things that prevent this window from being active.
function GUIChallengeLeaderboard:SetWindowActive(label, state)
    
    assert(label) -- label doesn't have to be a string, it can be anything unique (eg a pointer)
    
    if state == true and self.windowDisabled[label] then
        self.windowDisabled[label] = nil
        self.windowDisabledCount = self.windowDisabledCount - 1
    elseif state == false and not self.windowDisabled[label] then
        self.windowDisabled[label] = true
        self.windowDisabledCount = self.windowDisabledCount + 1
    end
    
end

function GUIChallengeLeaderboard:UpdateButtonRollover(button, mousePos)
    
    local over = false
    if button.realPos
      and self:GetIsWindowActive()
      and self.animation == "done"
      and button.item:GetIsVisible()
      and mousePos.x >= button.realPos.x
      and mousePos.y >= button.realPos.y
      and mousePos.x <= button.realPos.x + button.realSize.x
      and mousePos.y <= button.realPos.y + button.realSize.y then
        over = true
    end
    
    if button.enabled and not button.active then -- do not do any rollover effects if button is disabled.
        if button.over and not over then
            -- on -> off
            button:UnHighlight()
        elseif not button.over and over then
            -- off -> on
            button:Highlight()
            StartSoundEffect(self.kButtonHoverSound)
        end
    end
    
    button.over = over
    
end

function GUIChallengeLeaderboard:CreateTooltip()
    
    local tooltip = {}
    tooltip.back = self:CreateGUIItem()
    tooltip.backShadowBottom = self:CreateGUIItem()
    tooltip.backShadowRight = self:CreateGUIItem()
    tooltip.textItem = self:CreateTextItem()
    tooltip.textShadowItem = self:CreateTextItem()
    
    -- initialize everything invisible, we will deal with this later during the fade-in.
    tooltip.back:SetColor(Color(0,0,0,0))
    tooltip.backShadowBottom:SetColor(Color(0,0,0,0))
    tooltip.backShadowRight:SetColor(Color(0,0,0,0))
    
    tooltip.textItem:SetFontName(self.kTooltipFontName)
    tooltip.textShadowItem:SetFontName(self.kTooltipFontName)
    
    tooltip.textItem:SetTextAlignmentY(GUIItem.Align_Min)
    tooltip.textShadowItem:SetTextAlignmentY(GUIItem.Align_Min)
    
    tooltip.opacity = 0.0
    tooltip.visible = self.visible
    
    self.tooltip = tooltip
    
    self:UpdateLayers()
    
end

function GUIChallengeLeaderboard:SetTooltipText(tooltip, text)
    
    tooltip.rawText = text
    
    local maxWidth = self.kTooltipMaxWidth * self.scale.x
    
    tooltip.textItem:SetScale(self.tooltipFontScale)
    tooltip.textShadowItem:SetScale(self.tooltipFontScale)
    
    local wrappedText
    local numLines
    wrappedText, ___, numLines = WordWrap(tooltip.textItem, text, 0, maxWidth)
    tooltip.textItem:SetText(wrappedText)
    tooltip.textShadowItem:SetText(wrappedText)
    
    -- adjust background size to fit the text.
    local backSize = Vector(0,0,0)
    backSize.x = (tooltip.textItem:GetTextWidth(wrappedText) * self.tooltipFontScale.x) + (self.kTooltipMargin * 2.0 * self.scale.x)
    backSize.y = (self.kTooltipFontSize + (math.max(numLines - 1, 0)) * kAgencySmallLineSpan + self.kTooltipMargin + self.kTooltipMarginBottom) * self.scale.y
    
    local shadowOffset = self.kShadowOffset * self.scale
    local bottomShadowSize = Vector(backSize.x, shadowOffset.y, 0)
    local rightShadowSize = Vector(shadowOffset.x, backSize.y - shadowOffset.y, 0)
    
    tooltip.back:SetSize(backSize)
    tooltip.backShadowBottom:SetSize(bottomShadowSize)
    tooltip.backShadowRight:SetSize(rightShadowSize)
    
end

function GUIChallengeLeaderboard:SetTooltipPosition(tooltip, pos)
    
    -- ensure we don't move off the screen.
    local screenSize = Vector(Client.GetScreenWidth(), Client.GetScreenHeight(), 0)
    
    local shadowOffset = self.kShadowOffset * self.scale
    local backSize = tooltip.back:GetSize()
    
    local anchor = Vector(0,0,0)
    
    local bottomRightCorner = pos + backSize
    if bottomRightCorner.x >= screenSize.x then
        anchor.x = 1
    end
    
    if bottomRightCorner.y >= screenSize.y then
        anchor.y = 1
    end
    
    local offset = -(backSize * anchor) - (((anchor * 2.0) - 1.0) * self.kTooltipOffset)
    
    local backPos = pos + offset
    tooltip.back:SetPosition(backPos)
    tooltip.backShadowBottom:SetPosition(backPos + Vector(shadowOffset.x, backSize.y, 0))
    tooltip.backShadowRight:SetPosition(backPos + Vector(backSize.x, shadowOffset.y, 0))
    
    local textOffset = Vector(self.kTooltipMargin, self.kTooltipMargin, 0) * self.scale
    tooltip.textItem:SetPosition(backPos + textOffset)
    tooltip.textShadowItem:SetPosition(backPos + textOffset + shadowOffset)
    
end

function GUIChallengeLeaderboard:UpdateTooltipColor(tooltip, opacity)
    
    local backColor = Color(self.kTooltipBackColor.r, self.kTooltipBackColor.g, self.kTooltipBackColor.b, self.kTooltipBackColor.a * opacity)
    tooltip.back:SetColor(backColor)
    
    local shadowColor = Color(self.kShadowColor.r, self.kShadowColor.g, self.kShadowColor.b, self.kShadowColor.a * opacity)
    tooltip.backShadowBottom:SetColor(shadowColor)
    tooltip.backShadowRight:SetColor(shadowColor)
    tooltip.textShadowItem:SetColor(shadowColor)
    
    local textColor = Color(self.kColor.r, self.kColor.g, self.kColor.b, self.kColor.a * opacity)
    tooltip.textItem:SetColor(textColor)
    
end

function GUIChallengeLeaderboard:DestroyTooltip()
    
    local tooltip = self.tooltip
    
    if not tooltip then
        return
    end
    
    if tooltip.back then
        self:DestroyGUIItem(tooltip.back)
        tooltip.back = nil
    end
    
    if tooltip.backShadowBottom then
        self:DestroyGUIItem(tooltip.backShadowBottom)
        tooltip.backShadowBottom = nil
    end
    
    if tooltip.backShadowRight then
        self:DestroyGUIItem(tooltip.backShadowRight)
        tooltip.backShadowRight = nil
    end
    
    if tooltip.textItem then
        self:DestroyGUIItem(tooltip.textItem)
        tooltip.textItem = nil
    end
    
    if tooltip.textShadowItem then
        self:DestroyGUIItem(tooltip.textShadowItem)
        tooltip.textShadowItem = nil
    end
    
    self.tooltip = nil
    
end

function GUIChallengeLeaderboard:UpdateTooltip(button, deltaTime, mousePos)
    
    -- If user is hovering over a button, start accumulating the time they've hovered, or subtract if they're
    -- not hovering over a button.
    if button then
        local totalPersistTime = self.kTooltipDelayTime + self.kTooltipFadeInTime + self.kTooltipPersistTime
        self.tooltipHoverTime = math.min(self.tooltipHoverTime + deltaTime, totalPersistTime)
    else
        self.tooltipHoverTime = math.max(self.tooltipHoverTime - deltaTime, 0.0)
    end
    
    if not self.tooltip then
        self:CreateTooltip()
    end
    
    local tooltip = self.tooltip
    
    local tooltipText
    if button then
        tooltipText = button.tooltip
        if button.disabledTooltip and not button.enabled then
            tooltipText = button.disabledTooltip
        end
    end
    
    if tooltipText and tooltip.rawText ~= tooltipText then
        self:SetTooltipText(tooltip, tooltipText)
    end
    
    self:SetTooltipPosition(tooltip, mousePos)
    
    local opacity = Clamp((self.tooltipHoverTime - self.kTooltipDelayTime) / self.kTooltipFadeInTime, 0.0, 1.0)
    self:UpdateTooltipColor(tooltip, opacity)
    
    if self.visible ~= tooltip.visible then
        tooltip.visible = self.visible
        tooltip.back:SetIsVisible(self.visible)
        tooltip.backShadowBottom:SetIsVisible(self.visible)
        tooltip.backShadowRight:SetIsVisible(self.visible)
        tooltip.textItem:SetIsVisible(self.visible)
        tooltip.textShadowItem:SetIsVisible(self.visible)
    end
    
end

function GUIChallengeLeaderboard:UpdateButtonsRollovers(mousePos)
    
    if not mousePos then
        mousePos = Vector(0,0,0)
        mousePos.x, mousePos.y = Client.GetCursorPosScreen()
    end
    
    for i=1, #self.buttons do
        self:UpdateButtonRollover(self.buttons[i], mousePos)
    end
    
end

function GUIChallengeLeaderboard:UpdatePlayerItems()
    
    for i=1, self.kNumRows do
        
        -- Check that all the player names that are needed, are loaded.
        local row = self.rows[i]
        local playerItems = row.playerItemTable
        if not row.playerName and row.playerSteamId and playerItems.nameButton:GetIsVisible() then
            row.playerName = self:GetPlayerNameForSteamId(row.playerSteamId)
            if row.playerName then
                playerItems.nameButton:SetText(row.playerName)
            end
        end
        
        local steamId64
        if row.playerSteamId then
            steamId64 = Client.ConvertSteamId32To64(row.playerSteamId)
        end
        
        -- Ensure garbage data isn't being displayed as the player avatar.
        if steamId64 and Client.GetIsAvatarReady(steamId64) then
            local textureName = Client.GetTextureNameForAvatar(steamId64)
            playerItems.iconButton:SetTexture(textureName)
        else
            playerItems.iconButton:SetTexture(self.kMissingAvatarTexture)
        end
        
    end
    
end

-- Update the transform of the "wiper" object to move from left to right, from totally covering row, to not at all.
-- The difference between wipe-in and wipe-out is simply the stencil mode of the row (eg is it being knocked out by
-- the wiper, or being exclusively included by the wiper?)
function GUIChallengeLeaderboard:UpdateWipeAnimationForRow(rowIndex, wipeFraction)
    
    local row = self.rows[rowIndex]
    local wiper = row.wiper
    
    local newPosX = (row.wipeSize.x * wipeFraction) + row.wipePos.x
    local newSizeX = row.wipeSize.x * (1.0 - wipeFraction)
    
    wiper:SetPosition(Vector(newPosX, row.wipePos.y, 0))
    wiper:SetSize(Vector(newSizeX, row.wipeSize.y, 0))
    
end

function GUIChallengeLeaderboard:UpdateRowOpacity(rowIndex, opacity)
    
    local row = self.rows[rowIndex]
    
    local modifiedColor = Color(self.kColor)
    modifiedColor.a = modifiedColor.a * opacity
    
    local modifiedShadowColor = Color(self.kShadowColor)
    modifiedShadowColor.a = modifiedShadowColor.a * opacity
    
    row.rankItem:SetColor(modifiedColor)
    row.rankShadowItem:SetColor(modifiedShadowColor)
    
    row.playerItemTable:SetOpacity(opacity)
    
end

function GUIChallengeLeaderboard:UpdateOpacity(opacity)
    
    local modifiedColor = Color(self.kColor)
    modifiedColor.a = modifiedColor.a * opacity
    
    local modifiedShadowColor = Color(self.kShadowColor)
    modifiedShadowColor.a = modifiedShadowColor.a * opacity
    
    self.titleItem:SetColor(modifiedColor)
    self.titleShadowItem:SetColor(modifiedShadowColor)
    
    self.rankHeaderItem:SetColor(modifiedColor)
    self.rankHeaderShadowItem:SetColor(modifiedShadowColor)
    
    self.playerHeaderItem:SetColor(modifiedColor)
    self.playerHeaderShadowItem:SetColor(modifiedShadowColor)
    
    self.dividerItem:SetColor(modifiedColor)
    self.dividerShadowItem:SetColor(modifiedShadowColor)
    
    self.friendsButton:SetOpacity(opacity)
    self.globalButton:SetOpacity(opacity)
    
    for i=1, #self.rows do
        self:UpdateRowOpacity(i, opacity)
    end
    
    local highlightColor = Color(self.kHighlightColor)
    highlightColor.a = highlightColor.a * opacity
    self.highlightItem:SetColor(highlightColor)
    
    self.upArrowButton:SetOpacity(opacity)
    self.downArrowButton:SetOpacity(opacity)
    
end

function GUIChallengeLeaderboard:UpdateAnimation(deltaTime)
    
    assert(self.animation ~= nil)
    
    if self.animation == "done" or self.animation == "hidden" then
        -- nothing to do
        return
        
    elseif self.animation == "waitingForDownload" then
        
        if not self.nextDataReady then
            -- still waiting for downloaded data...
            return
        end
        
        self:RevealNextGUI()
        
    elseif self.animation == "in" or self.animation == "out" then
        
        assert(self.animationTime ~= nil)
        
        self.animationTime = self.animationTime + deltaTime
        
        -- total amount of time it will take for the entire animation to complete
        local totalAnimationDuration = self.kWipeTime + (self.kWipeDelay * #self.rows)
        
        -- Update the rows for the animation
        for i=1, #self.rows do
            local index = i-1
            local wipeFraction = Clamp((self.animationTime - (self.kWipeDelay * index)) / self.kWipeTime, 0, 1)
            
            self:UpdateWipeAnimationForRow(i, wipeFraction)
        end
        
        -- Update the highlight fade in/out for the animation
        local highlightFraction = Clamp(self.animationTime / totalAnimationDuration, 0, 1)
        local opacity = 1.0
        if self.animation == "in" then
            opacity = highlightFraction
        elseif self.animation == "out" then
            opacity = 1.0 - highlightFraction
        end
        
        local color = Color(self.kHighlightColor)
        color.a = color.a * opacity
        self.highlightItem:SetColor(color)
        
        -- Check if the animation has finished
        if self.animationTime >= totalAnimationDuration then
            -- the animation has completed for all rows
            self.animation = "done" -- might be set to something else in the callback function.
            if self.animationCallback then
                self.animationCallback(self)
            end
        end
        
    elseif self.animation == "fadeIn" or self.animation == "fadeOut" then
        
        assert(self.animationTime ~= nil)
        
        self.animationTime = self.animationTime + deltaTime
        
        local animFraction = Clamp(self.animationTime / self.kFadeTime, 0.0, 1.0)
        
        local opacity
        if self.animation == "fadeIn" then
            opacity = animFraction
        else
            opacity = 1.0 - animFraction
        end
        
        self:UpdateOpacity(opacity)
        
        -- Check if the animation has finished
        if animFraction >= 1.0 then
            self.animation = "done" -- might be set to something else in the callback function.
            if self.animationCallback then
                self.animationCallback(self)
                return
            end
            
        end
        
    end
    
end

function GUIChallengeLeaderboard:Update(deltaTime)
    
    -- Hide if main menu is open
    local vis = not MainMenu_GetIsOpened()
    if vis ~= self.visible then
        self:SetIsVisible(vis)
    end
    
    -- Player names and avatars
    self:UpdatePlayerItems()
    
    local mousePos = Vector(0,0,0)
    mousePos.x, mousePos.y = Client.GetCursorPosScreen()
    
    -- Update button rollovers
    self:UpdateButtonsRollovers(mousePos)
    
    -- Update tooltip
    local button
    for i=1, #self.buttons do
        if self.buttons[i].over then
            button = self.buttons[i]
            break
        end
    end
    
    self:UpdateTooltip(button, deltaTime, mousePos)
    
    -- Update animations, if any.
    self:UpdateAnimation(deltaTime)
    
end

-- Returns the first index of the entry with the given steamId.  The maximum table size can be
-- provided to account for tables with holes in the data.
function GUIChallengeLeaderboard:FindSteamIdInEntryTable(steamId, entryTable, tableSize)
    
    -- Optionally provide maximum index of table (the # operator is fooled by holes in the array).
    local range = tableSize
    if not range then
        range = #entryTable
    end
    
    for i=1, range do
        local entry = entryTable[i]
        if entry and entry.steamId == steamId then
           return i
        end
    end
    
    return -1
    
end

-- Attempts to fit a window of values (values between and including startIndex and endIndex) within 1..range.
-- The window will be shifted in-bounds. (eg if startIndex is -1 and endIndex is 3, both values have 2 added to
-- them, making the range 1 and 5.  If the window is too large for the range, it will be cropped to the range.
function GUIChallengeLeaderboard:ValidateWindowRange(startIndex, endIndex, range)
    
    if (endIndex - startIndex) + 1 > range then
        return 1, range
    end
    
    if startIndex < 1 then
        endIndex = endIndex - (startIndex - 1)
        startIndex = 1
    end
    
    if endIndex > range then
        startIndex = startIndex - (endIndex - range)
        endIndex = range
    end
    
    return startIndex, endIndex
    
end

-- Calculates the displayedTopIndex based on the player's index and how many surrounding entries there
-- are.  Ideally, we have half above player, and half below player (with possible leftover entry
-- sent below player), but we might not have enough entries for that.
function GUIChallengeLeaderboard:CalculateDisplayedRangeWindow(playerIndex, entryTable, tableSize)
    
    -- Optionally provide maximum index of table (the # operator is fooled by holes in the array).
    local range = tableSize
    if not range then
        range = #entryTable
    end
    
    local idealAbove = math.floor((self.kNumRows - 1) * 0.5)
    local idealBelow = math.ceil((self.kNumRows - 1) * 0.5)
    
    local idealTop = playerIndex - idealAbove
    local idealBot = playerIndex + idealBelow
    
    self.displayedTopIndex, self.displayedBottomIndex = self:ValidateWindowRange(idealTop, idealBot, range)
    
end

function GUIChallengeLeaderboard:GetActiveData()
    
    if self.filterType == "friends" then
        return self.friendsData
    elseif self.filterType == "global" then
        return self.globalData
    end
    
    return {}
    
end

function GUIChallengeLeaderboard:GetEntryCount()
    
    if self.filterType == "friends" then
        return self.friendsData and #self.friendsData or 0
    elseif self.filterType == "global" then
        if self.boardName and self.boardName ~= "" then
            return GetSteamLeaderboardManager():GetEntryCount(self.boardName)
        else
            return 0
        end
    end
    
    return 0
    
end

function GUIChallengeLeaderboard:UpdateHighlight()
    
    local playerRow -- player's row index
    local localSteamId = Client.GetSteamId()
    
    for i=1, #self.rows do
        if self.rows[i].playerSteamId == localSteamId then
            playerRow = i
            break
        end
    end
    
    -- Update highlight
    if playerRow then
        self.highlightItem:SetIsVisible(self.visible)
        self.highlightVis = true
        local pos = ((self.kHighlightPosition + (Vector(0, self.kRowSpacing, 0) * playerRow)) - Vector(0, self.kHighlightSize.y, 0)) * self.scale + self.position
        local size = self.kHighlightSize * self.scale
        self.highlightItem:SetPosition(pos)
        self.highlightItem:SetSize(size)
    else
        self.highlightItem:SetIsVisible(false)
        self.highlightVis = false
    end
    
end

-- Called when the wipe out animation is finished, and the next data is ready.
function GUIChallengeLeaderboard:RevealNextGUI()
    
    self.nextDataReady = false
    
    -- Update rows
    local activeData = self:GetActiveData()
    local numDisplayedRows = math.min((self.displayedBottomIndex - self.displayedTopIndex) + 1,10)
    for i=1, numDisplayedRows do
        local entryIndex = self.displayedTopIndex + i - 1
        self:SetRowData(i, activeData[entryIndex])
    end
    
    self:UpdateHighlight()
    
    -- Clear rows that do not contain data
    for i=numDisplayedRows + 1, self.kNumRows do
        self:HideRow(i)
    end
    
    self:DoWipeInAnimation(
    function(self)
        -- Update scroll arrows
        self.upArrowButton:SetIsVisible(self.displayedTopIndex > 1)
        self.downArrowButton:SetIsVisible(self.displayedBottomIndex < self:GetEntryCount())
    end)
    
    self:Update(0)
    
end

-- Called when the displayed data has been updated, and the GUI needs to be updated to reflect this.
function GUIChallengeLeaderboard:UpdateGUI()
    
    self.nextDataReady = true
    
end

function GUIChallengeLeaderboard:UpdateActiveData_Friends()
    
    if not self.boardName then
        -- Can't do anything until we know which leaderboard we're querying.
        return
    end
    
    if self.friendsData == nil then
        -- Request friends data from Steam.
        GetSteamLeaderboardManager():RequestFriendScores(self.boardName,
            function(success, entryTable)
                if success then
                    self.friendsData = entryTable
                    self:UpdateActiveData()
                else
                    Log("ERROR:  Unable to retrieve friends' scores.")
                end
            end)
        
        -- Don't do anything now, we're waiting to get back something from Steam.
        return
    end
    
    if self.displayedTopIndex == nil then
        -- search for current player in list of entries.
        local steamId = Client.GetSteamId()
        local index = self:FindSteamIdInEntryTable(steamId, self.friendsData)
        if index > 0 then
            -- player's index found
            self:CalculateDisplayedRangeWindow(index, self.friendsData)
            self.highlightedIndex = (index - self.displayedTopIndex) + 1
        else
            -- player's index not found
            -- display the top scoring friends
            self.displayedTopIndex = 1
            self.displayedBottomIndex = math.min(#self.friendsData, self.kNumRows)
            self.highlightedIndex = nil
        end
    end
    
    -- ensure arrows haven't pushed us off the bottom of the list.
    self.displayedTopIndex, self.displayedBottomIndex = self:ValidateWindowRange(self.displayedTopIndex, self.displayedBottomIndex, #self.friendsData)
    
    self:UpdateGUI()
    
end

function GUIChallengeLeaderboard:EntriesAreEqual(a, b)
    
    if a.steamId ~= b.steamId then
        return false
    end
    
    if a.globalRank ~= b.globalRank then
        return false
    end
    
    if a.score ~= b.score then
        return false
    end
    
    if a.ugcHandle ~= b.ugcHandle then
        return false
    end
    
    return true
    
end

function GUIChallengeLeaderboard:AddEntryListToGlobalList(entryList)
    
    local minIndex
    local maxIndex
    local clearAllOthers = false
    for i=1, #entryList do
        local newEntry = entryList[i]
        local newEntryIndex = newEntry.globalRank
        
        minIndex = (minIndex and math.min(minIndex, newEntryIndex)) or newEntryIndex
        maxIndex = (maxIndex and math.max(maxIndex, newEntryIndex)) or newEntryIndex
        
        local oldEntry = self.globalData
        if not clearAllOthers and oldEntry ~= nil and not self:EntriesAreEqual(newEntry, oldEntry) then
            clearAllOthers = true -- we found a conflict when updating some of the entries... indicating the
            -- leaderboard data has changed independent of us.  We'll finish copying over the data we JUST
            -- received, but afterwards we'll clear everything else out so it's forced to refresh.
        end
        
        self.globalData[newEntryIndex] = newEntry
    end
    
    if clearAllOthers then
        for i=1, minIndex - 1 do
            self.globalData[i] = nil
        end
        
        for i=maxIndex+1, self.globalDataMaxEntry do
            self.globalData[i] = nil
        end
        
        self.globalDataMaxEntry = maxIndex
        
        -- Clear the cached replays too, just in case a new replay was created and uploaded.
        GetReplayManager():ClearCachedReplaysFromLeaderboard()
        
    else
        self.globalDataMaxEntry = math.max(self.globalDataMaxEntry, maxIndex)
    end
    
end

function GUIChallengeLeaderboard:DoGetPlayerRank()
    
    GetSteamLeaderboardManager():RequestPlayerScore(self.boardName,
    function(success, entryTable)
        if success then
            if #entryTable == 0 then
                -- player entry was not found
                self.playerRank = 0 -- not found (ranks start at 1)
                self:UpdateActiveData()
            else
                -- player was found
                self.playerRank = entryTable[1].globalRank
                self:UpdateActiveData()
            end
        else
            Log("ERROR:  Unable to retrieve user's score!  (Does NOT indicate the score does not exist, but rather there was a problem with the request.)")
        end
    end)
    
end

function GUIChallengeLeaderboard:DoGetTopScores()
    
    GetSteamLeaderboardManager():RequestRangeOfScores(self.boardName, 1, self.kNumRows,
    function(success, entryTable)
        if success then
            self:AddEntryListToGlobalList(entryTable)
            
            -- Don't act on the data we just received -- it may be out of date.  Instead,
            -- just call the update function again.  It'll get everything sorted out.
            self:UpdateActiveData()
            return
        else
            Log("ERROR:  Unable to retrieve top scores!")
            return
        end
    end)
    
end

function GUIChallengeLeaderboard:ShowTopScores()
    
    -- See if we need to download the top scores, or if we already have them.
    local entryCount = GetSteamLeaderboardManager():GetEntryCount(self.boardName)
    
    if not self:GetIsRangeContiguous(self.globalData, 1, math.min(self.kNumRows, entryCount)) then
        -- we need to download the top scores
        self:DoGetTopScores()
        return
    end
    
    -- we've already downloaded the top entries, let's display those.
    self.displayedTopIndex = math.min(1, entryCount)
    self.displayedBottomIndex = math.min(entryCount, self.kNumRows)
    self:UpdateGUI()
    
end

function GUIChallengeLeaderboard:DoGetDisplayRangeOfScores()
    
    GetSteamLeaderboardManager():RequestRangeOfScores(self.boardName, self.displayedTopIndex, self.displayedBottomIndex, 
    function(success, entryTable)
        if success then
            self:AddEntryListToGlobalList(entryTable)
            
            -- Don't act on the data we just received -- it may be out of date.  Instead,
            -- just call the update function again.  It'll get everything sorted out.
            self:UpdateActiveData()
        else
            Log("ERROR:  Unable to retrieve scores around player!")
        end
    end)
    
end

function GUIChallengeLeaderboard:ShowScoresAroundPlayer()
    
    local entryCount = GetSteamLeaderboardManager():GetEntryCount(self.boardName)
    self:CalculateDisplayedRangeWindow(self.playerRank, self.globalData, entryCount)
    if not self:GetIsRangeContiguous(self.globalData, self.displayedTopIndex,
        self.displayedBottomIndex) then
        -- There were holes in the data, we need to request the data from steam.
        self:DoGetDisplayRangeOfScores()
        return
    end
    
    -- We've got all the entries we needed to display.
    self:UpdateGUI()
    
end

function GUIChallengeLeaderboard:UpdateActiveData_GlobalInitial()
    
    -- we aren't displaying anything currently!  Let's see if the player is on the scoreboard,
    -- and if so, we'll display some entries around them.
    if self.playerRank == nil then
        -- we need to query Steam for the player's rank.
        self:DoGetPlayerRank()
        return
    end
    
    -- Ensure the board actually has some entries to show on it
    local entryCount = GetSteamLeaderboardManager():GetEntryCount(self.boardName)
    if entryCount == 0 then
        -- board is empty.
        self.displayedTopIndex = 0
        self.displayedBottomIndex = 0
        self:UpdateGUI()
        return
    end
    
    -- We have the player's rank (or at least know that they are not present on the board)
    if self.playerRank == 0 then
        -- Player does not have an entry on the board, let's just show them the top scores
        -- in that case.
        self:ShowTopScores()
        return
    end
    
    self:ShowScoresAroundPlayer()
    
end

function GUIChallengeLeaderboard:UpdateActiveData_Global()
    
    if not self.boardName then
        -- Can't do anything until we know which leaderboard we're querying.
        return
    end
    
    if self.displayedTopIndex == nil then
        -- Setup our initial viewing position on the leaderboard.
        -- (splitting this out into many functions, otherwise it becomes a huge, nightmarish "if" pyramid.)
        self:UpdateActiveData_GlobalInitial()
        return
    end
    
    -- Validate the range of the viewing window, shifting it into valid space if it is out of bounds.
    local entryCount = GetSteamLeaderboardManager():GetEntryCount(self.boardName)
    self.displayedTopIndex, self.displayedBottomIndex = self:ValidateWindowRange(self.displayedTopIndex, self.displayedBottomIndex, entryCount)
    
    -- Check if we need to download any of these entries.
    if not self:GetIsRangeContiguous(self.globalData, self.displayedTopIndex, self.displayedBottomIndex) then
        self:DoGetDisplayRangeOfScores()
        return
    end
    
    -- We've got all the entries we needed to display.
    self:UpdateGUI()
    
end

function GUIChallengeLeaderboard:GetIsRangeContiguous(entryTable, startIndex, endIndex)
    
    for i=startIndex, endIndex do
        if entryTable[i] == nil then
            return false
        end
    end
    
    return true
    
end

-- Ensure we have the data needed to display in the GUI.  If so, pass it along to the GUI,
-- otherwise take whatever actions necessary to get the data.
function GUIChallengeLeaderboard:UpdateActiveData()
    
    if self.filterType == "friends" then
        self:UpdateActiveData_Friends()
    elseif self.filterType == "global" then
        self:UpdateActiveData_Global()
    else
        Log("ERROR: invalid filter type!")
    end
    
end

function GUIChallengeLeaderboard:SetSteamLeaderboardName(name)
    
    self.boardName = name
    self:UpdateActiveData()
    
end

function GUIChallengeLeaderboard:UpdateLeaderboardTransform()
    
    local pos, scale = Fancy_Transform(Vector(0,0,0), 1.0)
    self:SetScale(Vector(scale, scale, 1.0))
    self:SetPosition(self.kLeaderboardPosition * scale + pos)
    self:UpdateHighlight()
    
    -- ensure we re-scale the tooltip text if applicable
    if self.tooltip and self.tooltip.rawText then
        self:SetTooltipText(self.tooltip, self.tooltip.rawText)
    end
    
end

-- the width of the row, before scaling.
-- should be overridden
function GUIChallengeLeaderboard:GetRowWidth()
    
    return 0
    
end

function GUIChallengeLeaderboard:DoFadeInAnimation(callback)
    
    self.animationCallback = callback
    self.animation = "fadeIn"
    self.animationTime = 0.0
    self:Update(0)
    
end

function GUIChallengeLeaderboard:DoFadeOutAnimation(callback)
    
    self.animationCallback = callback
    self.animation = "fadeOut"
    self.animationTime = 0.0
    self:Update(0)
    
end

function GUIChallengeLeaderboard:GetParentEntity()
    return self.parentEnt
end

-- The entity that controls the flow of the game (eg the "SkulkChallenge" entity).
-- Necessary in order to deliver callbacks to the entity so it can coordinate between the many different
-- gui scripts.
function GUIChallengeLeaderboard:SetParentEntity(ent)
    self.parentEnt = ent
end
