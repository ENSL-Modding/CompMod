-- ======= Copyright (c) 2017, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\challenge\GUIReplayDownloader.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    An abstract GUIScript class that downloads a replay for a challenge mode, and displays the download 
--    progress.  Extended by GUIReplayDownloaderAlien, replay downloader with alien theme.  Most
--    of the functionality is defined in here, though..
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/challenge/SteamLeaderboardManager.lua")
Script.Load("lua/UnorderedSet.lua")
Script.Load("lua/GUIAssets.lua")

local kDefaultLayer = 40

class 'GUIReplayDownloader' (GUIScript)

GUIReplayDownloader.kColor = Color(1,1,1,1)
GUIReplayDownloader.kShadowColor = Color(0,0,0,0.5)
GUIReplayDownloader.kDarkenColor = Color(0,0,0,0.5)

GUIReplayDownloader.kShadowOffset = Vector(2, 2, 0)

GUIReplayDownloader.kTitleFontName = Fonts.kAgencyFB_Huge
GUIReplayDownloader.kTitleFontActualSize = 66
GUIReplayDownloader.kTitleFontSize = 42

GUIReplayDownloader.kButtonFontName = Fonts.kAgencyFB_Medium
GUIReplayDownloader.kButtonFontActualSize = 22
GUIReplayDownloader.kButtonFontSize = 20
GUIReplayDownloader.kButtonFontColor = Color(1,1,1,1)

GUIReplayDownloader.kButtonTextLayerOffset = 0
GUIReplayDownloader.kButtonLayerOffset = 3

GUIReplayDownloader.kProgressBarLayerOffset = 2

GUIReplayDownloader.kStatusTextLayerOffset = 3
GUIReplayDownloader.kStatusTextShadowLayerOffset = 2

GUIReplayDownloader.kBackgroundLayerOffset = 1
GUIReplayDownloader.kDarkOverlayLayerOffset = 0

GUIReplayDownloader.kPanelSize = Vector(626, 288, 0)
GUIReplayDownloader.kTitleYOffset = 62
GUIReplayDownloader.kButtonCenterYOffset = 220

GUIReplayDownloader.kButtonSize = Vector(233, 86, 0)
GUIReplayDownloader.kButtonSpacing = 40

-- Over size = regular size scaled up proportionally so that it is kButtonSpacing-wider than normal.
GUIReplayDownloader.kButtonOverSize = Vector(GUIReplayDownloader.kButtonSize.x + GUIReplayDownloader.kButtonSpacing, ((GUIReplayDownloader.kButtonSize.x + GUIReplayDownloader.kButtonSpacing) / GUIReplayDownloader.kButtonSize.x) * GUIReplayDownloader.kButtonSize.y, 0)

GUIReplayDownloader.kFadeTime = 0.5

GUIReplayDownloader.kButtonHoverSound = PrecacheAsset("sound/NS2.fev/common/hovar")
GUIReplayDownloader.kButtonClickSound = PrecacheAsset("sound/NS2.fev/common/button_click")

function GUIReplayDownloader:UpdateFontScales()
    
    self.titleFontScale = self.scale * (self.kTitleFontSize / self.kTitleFontActualSize)
    self.buttonFontScale = self.scale * (self.kButtonFontSize / self.kButtonFontActualSize)
    
end

function GUIReplayDownloader:UpdateButtonTransform(button)
    
    button.textItem:SetPosition(button.position)
    button.textItem:SetScale(self.buttonFontScale)
    
    -- store this for easier rollover detection
    button.halfExtents = self.kButtonSize * 0.5 * self.scale
    
end

function GUIReplayDownloader:UpdateProgressFraction()
    
    if not self.ugcHandle then
        self.progressFraction = 0.0
        return
    end
    
    if self.downloadedFileSize then
        -- an indication that download has completed
        self.progressFraction = 1.0
    end
    
    local fraction = Client.GetUGCDownloadProgress(self.ugcHandle)
    
    if fraction >= 0.0 then
        self.progressFraction = fraction
    end
    
end

function GUIReplayDownloader:UpdateProgressBarFill()
    -- Will be extended for themeing...
end

function GUIReplayDownloader:UpdateProgressBarTransform()
    -- Will be extended for themeing...
end

function GUIReplayDownloader:UpdateLayers()
    
    self.statusTextItem:SetLayer(self.layer + self.kStatusTextLayerOffset)
    self.statusTextShadowItem:SetLayer(self.layer + self.kStatusTextShadowLayerOffset)
    
    self.progressBar:SetLayer(self.layer + self.kProgressBarLayerOffset)
    
    self.darkenItem:SetLayer(self.layer + self.kDarkOverlayLayerOffset)
    
    for i=1, #self.buttons do
        self.buttons[i]:SetLayer(self.layer + self.kButtonLayerOffset)
    end
    
end

function GUIReplayDownloader:UpdateTransform()
    
    local shadowOffset = self.kShadowOffset * self.scale
    
    -- Update buttons
    local buttonCenterPos = Vector(self.kPanelSize.x * 0.5, self.kButtonCenterYOffset, 0)
    local offsetFraction = -0.5 * (#self.buttons - 1) -- buttons are positioned by their centers.
    local xOffset = offsetFraction * self.kButtonOverSize.x
    
    for i=1, #self.buttons do
        local index = i-1
        local pos = ((buttonCenterPos + Vector(xOffset + (self.kButtonOverSize.x * index), 0, 0)) * self.scale) + self.position
        self.buttons[i].position = pos
        self:UpdateButtonTransform(self.buttons[i])
    end
    
    -- Update status text
    local titlePos = (Vector(self.kPanelSize.x * 0.5, self.kTitleYOffset, 0) * self.scale) + self.position
    self.statusTextItem:SetPosition(titlePos)
    self.statusTextShadowItem:SetPosition(titlePos + shadowOffset)
    self.statusTextItem:SetScale(self.titleFontScale)
    self.statusTextShadowItem:SetScale(self.titleFontScale)
    
    self.darkenItem:SetSize(Vector(Client.GetScreenWidth(), Client.GetScreenHeight(), 0))
    self.darkenItem:SetPosition(Vector(0, 0, 0))
    
    self:UpdateProgressBarTransform()
    
end

function GUIReplayDownloader:GetOpacity()
    
    if self.fadeIn ~= nil then
        return Clamp(self.fadeIn / self.kFadeTime, 0, 1)
    elseif self.fadeOut ~= nil then
        return Clamp(self.fadeOut / self.kFadeTime, 0, 1)
    elseif self.status == "active" then
        return 1
    end
    
    return 0
    
end

function GUIReplayDownloader:UpdateColor()
    
    local opacity = self:GetOpacity()
    
    local shadowColor = Color(self.kShadowColor.r, self.kShadowColor.g, self.kShadowColor.b, self.kShadowColor.a * opacity)
    local color = Color(self.kColor.r, self.kColor.g, self.kColor.b, self.kColor.a * opacity)
    local darkenColor = Color(self.kDarkenColor.r, self.kDarkenColor.g, self.kDarkenColor.b, self.kDarkenColor.a * opacity)
    
    self.statusTextItem:SetColor(color)
    self.statusTextShadowItem:SetColor(shadowColor)
    self.darkenItem:SetColor(darkenColor)
    
    local buttonTextColor = Color(self.kButtonFontColor.r, self.kButtonFontColor.g, self.kButtonFontColor.b, self.kButtonFontColor.a * opacity)
    
    for i=1, #self.buttons do
        self.buttons[i].textItem:SetColor(buttonTextColor)
    end
    
end

function GUIReplayDownloader:InitProgressBarGUI()
    -- Will be extended for themeing...
end

function GUIReplayDownloader:CreateProgressBar()
    
    self.progressBar = {}
    
    self:InitProgressBarGUI()
    
end

function GUIReplayDownloader:InitButton(newButton, buttonText)
    
    local text = self:CreateTextItem()
    text:SetColor(self.kButtonFontColor)
    text:SetFontName(self.kButtonFontName)
    text:SetText(Locale.ResolveString(buttonText))
    newButton.textItem = text
    
    newButton.SetLayer = function(button, layer)
        button.textItem:SetLayer(layer + self.kButtonTextLayerOffset)
    end
    
end

function GUIReplayDownloader:CreateButton(buttonText, onClick)
    
    local newButton = {}
    newButton.over = false
    newButton.onClick = onClick
    
    self:InitButton(newButton, buttonText)
    
    table.insert(self.buttons, 1, newButton) -- add new buttons on the left.
    
    self:UpdateTransform()
    self:UpdateLayers()
    self:UpdateColor()
    
    return newButton
    
end

function GUIReplayDownloader:SetupCallback(name, callback)
    
    self.callbacks[name] = callback
    
end

function GUIReplayDownloader:DoFadeIn()
    
    self.status = "fadingIn"
    self.fadeIn = 0.0
    
end

function GUIReplayDownloader:DoFadeOut()
    
    self.status = "fadingOut"
    self.fadeOut = self.kFadeTime
    
end

function GUIReplayDownloader:OnCancelClicked()
    
    self:DoFadeOut()
    self.result = "cancel"
    
end

function GUIReplayDownloader:OnOkClicked()
    
    self.result = "ok"
    if self.callbacks.ok then
        self.callbacks.ok()
    end
    
end

function GUIReplayDownloader:InitializeGUI()
    
    self.statusTextItem, self.statusTextShadowItem = self:CreateTextItem(true)
    local status = Locale.ResolveString("DOWNLOADING_REPLAY")
    self.statusTextItem:SetText(status)
    self.statusTextShadowItem:SetText(status)
    
    self:CreateProgressBar()
    
    self.darkenItem = self:CreateGUIItem()
    self.darkenItem:SetColor(self.kDarkenColor)
    
    self.cancelButton = self:CreateButton("CANCEL", function() self:OnCancelClicked() end)
    
end

function GUIReplayDownloader:Initialize()
    
    self.items = UnorderedSet()
    self.buttons = {}
    
    self.callbacks = {}
    
    self.status = "inactive"
    self.result = "cancel"
    self.okButtonText = "OK" -- can be changed, eg to "View Replay"
    
    self.position = Vector(0,0,0)
    self.scale = Vector(1,1,1)
    self.layer = kDefaultLayer
    
    self:UpdateFontScales()
    
    self:InitializeGUI()
    
    self:UpdateTransform()
    self:UpdateLayers()
    self:UpdateColor()
    self:UpdateProgressFraction()
    
    self.updateInterval = 0
    
end

function GUIReplayDownloader:DestroyButton(button)
    
    local index
    for i=1, #self.buttons do
        if self.buttons[i] == button then
            index = i
            break
        end
    end
    
    if index then
        table.remove(self.buttons, index)
    end
    
    self:DestroyGUIItem(button.textItem)
    
end

function GUIReplayDownloader:OnRetryClicked()
    
    self:DestroyButton(self.retryButton)
    self:BeginDownloadingUGC(self.ugcHandle)
    
end

function GUIReplayDownloader:SetOkButtonText(text)
    
    self.okButtonText = text
    
end

function GUIReplayDownloader:OnDownloadComplete(success, handleOrError, fileSize)
    
    if success then
        
        self.downloadedFileSize = fileSize
        
        local status = Locale.ResolveString("DOWNLOAD_COMPLETE")
        self.statusTextItem:SetText(status)
        self.statusTextShadowItem:SetText(status)
        
        if self.callbacks.ok then
            self:CreateButton(self.okButtonText, function() self:OnOkClicked() end)
        end
        
    else
        Log("UGC download failed!  (Error code = %s)", handleOrError)
        local status = Locale.ResolveString("DOWNLOAD_FAILED")
        self.statusTextItem:SetText(status)
        self.statusTextShadowItem:SetText(status)
        
        if not self.retryButton then
            self:CreateButton("RETRY", function() self:OnRetry() end)
        end
        
    end
    
end

function GUIReplayDownloader:BeginDownloadingUGC(handle)
    
    self.ugcHandle = handle
    GetSteamLeaderboardManager():DownloadUGC(handle, function(success, handleOrError, fileSize) self:OnDownloadComplete(success, handleOrError, fileSize) end)
    self:DoFadeIn()
    
end

function GUIReplayDownloader:Terminate()
    
    self.status = "terminated"
    
    if self.callbacks.terminated then
        self.callbacks.terminated()
    end
    
    GetGUIManager():DestroyGUIScript(self)
    
end

function GUIReplayDownloader:Uninitialize()
    
    -- Cleanup is easy because every item created by the system is in one
    -- convenient set.
    for i=1, #self.items do
        GUI.DestroyItem(self.items[i])
    end
    
    self.buttons = {}
    
end

function GUIReplayDownloader:SendKeyEvent(key, down)
    
    -- take control of mouse movement, so they player isn't also moving their view around with the mouse visible.
    -- This *should* be handled by InputHandler.lua... but... it doesn't always catch things... :(
    if input == InputKey.MouseX or input == InputKey.MouseY then
        return true
    end
    
    self:UpdateButtonRollovers()
    if key == InputKey.MouseButton0 and down then
        for i=1, #self.buttons do
            if self.buttons[i].over then
                StartSoundEffect(self.kButtonClickSound)
                self.buttons[i].onClick()
                self:UpdateButtonRollovers() -- to disable buttons if status changed.
                return true
            end
        end
    end
    
    return true -- consume everything
    
end

function GUIReplayDownloader:UpdateButtonRollover(button, mousePos)
    
    if self.status ~= "active" then
        button.over = false
        return
    end
    
    local oldOver = button.over
    
    local diff = (button.position - mousePos)
    if math.abs(diff.x) <= button.halfExtents.x and math.abs(diff.y) <= button.halfExtents.y then
        button.over = true
        if not oldOver then
            StartSoundEffect(self.kButtonHoverSound)
        end
    else
        button.over = false
    end
    
    if oldOver ~= button.over then
        self:UpdateButtonTransform(button)
    end
    
end

function GUIReplayDownloader:UpdateButtonRollovers()
    
    local mousePos = Vector(0,0,0)
    mousePos.x, mousePos.y = Client.GetCursorPosScreen()
    
    for i=1, #self.buttons do
        self:UpdateButtonRollover(self.buttons[i], mousePos)
    end
    
end

function GUIReplayDownloader:Update(deltaTime)
    
    self:UpdateButtonRollovers()
    self:UpdateProgressFraction()
    self:UpdateProgressBarFill()
    
    if self.status == "fadingOut" then
        
        self.fadeOut = self.fadeOut - deltaTime
        
        self:UpdateColor()
        
        if self.fadeOut <= 0.0 then
            self:Terminate()
        end
        
    elseif self.status == "fadingIn" then
        
        self.fadeIn = self.fadeIn + deltaTime
        
        self:UpdateColor()
        
        if self.fadeIn >= self.kFadeTime then
            self.status = "active"
            self.fadeIn = nil
        end
        
    end
    
end

function GUIReplayDownloader:CreateGUIItem()
    
    local item = GUI.CreateItem()
    self.items:Add(item)
    
    return item
    
end

function GUIReplayDownloader:CreateTextItem(createShadow)
    
    local item = self:CreateGUIItem()
    item:SetOptionFlag(GUIItem.ManageRender)
    item:SetTextAlignmentX(GUIItem.Align_Center)
    item:SetTextAlignmentY(GUIItem.Align_Center)
    item:SetFontName(self.kTitleFontName)
    item:SetColor(self.kColor)
    
    if createShadow then
        
        local shadowItem = self:CreateGUIItem()
        shadowItem:SetOptionFlag(GUIItem.ManageRender)
        shadowItem:SetTextAlignmentX(GUIItem.Align_Center)
        shadowItem:SetTextAlignmentY(GUIItem.Align_Center)
        shadowItem:SetFontName(self.kTitleFontName)
        shadowItem:SetColor(self.kShadowColor)
        
        return item, shadowItem
        
    end
    
    return item
    
end

function GUIReplayDownloader:DestroyGUIItem(item)
    
    GUI.DestroyItem(item)
    self.items:RemoveElement(item)
    
end

function GUIReplayDownloader:CenterOnScreen()
    
    local size = self.kPanelSize * self.scale
    local screenSize = Vector(Client.GetScreenWidth(), Client.GetScreenHeight(), 0)
    
    local pos = (screenSize - size) * 0.5
    
    self:SetPosition(pos)
    
end

-- Sets the absolute screen position of the upper-left corner of this panel, in pixels.
function GUIReplayDownloader:SetPosition(position)
    
    self.position = position
    self:UpdateTransform()
    
end

-- Sets the scaling value of this panel.  Measurements provided are taken from a mockup
-- done at 1920x1080, so scale values should be calculated with this in mind.
function GUIReplayDownloader:SetScale(scale)
    
    self.scale = scale
    self:UpdateFontScales()
    self:CenterOnScreen()
    
end

function GUIReplayDownloader:SetLayer(layer)
    
    self.layer = layer
    self:UpdateLayers()
    
end

