-- ======= Copyright (c) 2017, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\challenge\GUIChallengePrompt.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Nag screen to try to get players to enable their Steam Cloud settings, or report if it cannot be changed
--    due to their settings.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/UnorderedSet.lua")
Script.Load("lua/challenge/GUIChallengeButton.lua")
Script.Load("lua/menu/FancyUtilities.lua")

class 'GUIChallengePrompt' (GUIScript)

GUIChallengePrompt.kButtonClass = "GUIChallengeButton"

GUIChallengePrompt.kIcons = {} -- no icons defined in base class.

GUIChallengePrompt.kPanelSize = Vector(800, 375, 0)

GUIChallengePrompt.kIconSpaceSize = Vector(240, 227, 0)
GUIChallengePrompt.kIconMargin = 40 -- amount of space inset into the "IconSpace" that the icon must be within.

-- The size of the icon space inset with the margins.
GUIChallengePrompt.kIconBounds = GUIChallengePrompt.kIconSpaceSize - (Vector(GUIChallengePrompt.kIconMargin, GUIChallengePrompt.kIconMargin, 0) * 2.0)

GUIChallengePrompt.kFontName = Fonts.kAgencyFB_Large
GUIChallengePrompt.kFontSize = 24
GUIChallengePrompt.kFontActualSize = 28
GUIChallengePrompt.kFontColor = Color(1,1,1,1)
GUIChallengePrompt.kFontLineSpan = 41

GUIChallengePrompt.kShadowColor = Color(0,0,0,0.5)
GUIChallengePrompt.kShadowOffset = Vector(2,2,0)

GUIChallengePrompt.kDescriptionTextSpaceSize = Vector(560, 188, 0)
GUIChallengePrompt.kDescriptionTextSpacePosition = Vector(240, 0, 0)
GUIChallengePrompt.kDescriptionTextMargin = 26

GUIChallengePrompt.kPromptTextYOffset = 24 -- text is centered in panel with this much y-offset from center.

-- buttons are positioned with their centers at this y-offset from the center of the panel
GUIChallengePrompt.kButtonAnchorYOffset = 130

GUIChallengePrompt.kTextLayerOffset = 2
GUIChallengePrompt.kTextShadowLayerOffset = 1
GUIChallengePrompt.kButtonLayerOffset = 1
GUIChallengePrompt.kIconLayerOffset = 1
GUIChallengePrompt.kDimmerLayerOffset = 0
GUIChallengePrompt.kDefaultLayer = 40

GUIChallengePrompt.kFadeTime = 0.5

GUIChallengePrompt.kDimmerOpacity = 0.5

function GUIChallengePrompt:CreateGUIItem()
    
    local item = GUI.CreateItem()
    self.items:Add(item)
    
    return item
    
end

function GUIChallengePrompt:UpdateFontScale()
    
    self.fontScale = (self.kFontSize / self.kFontActualSize) * self.scale.y
    self.fontSize = self.kFontSize * self.fontScale
    self.fontLineSpan = self.fontScale * self.kFontLineSpan
    
end

function GUIChallengePrompt:UpdateLayers()
    
    self.descText:SetLayer(self.layer + self.kTextLayerOffset)
    self.descTextShadow:SetLayer(self.layer + self.kTextShadowLayerOffset)
    self.promptText:SetLayer(self.layer + self.kTextLayerOffset)
    self.promptTextShadow:SetLayer(self.layer + self.kTextShadowLayerOffset)
    
    if self.icon then
        self.icon:SetLayer(self.layer + self.kIconLayerOffset)
    end
    
    for i=1, #self.buttons do
        self.buttons[i]:SetLayer(self.layer + self.kButtonLayerOffset)
    end
    
    self.dimmer:SetLayer(self.layer + self.kDimmerLayerOffset)
    
end

function GUIChallengePrompt:UpdateIconTransform()
    
    if not self.icon then
        return
    end
    
    -- fit the texture inside the "icon bounds"
    local iconBounds = self.kIconBounds * self.scale
    local size = Vector(self.icon:GetTextureWidth(), self.icon:GetTextureHeight(), 0)
    
    -- scale down until it fits horizontally
    if iconBounds.x < size.x then
        size = size * (iconBounds.x / size.x)
    end
    
    -- scale down until it fits vertically
    if iconBounds.y < size.y then
        size = size * (iconBounds.y / size.y)
    end
    
    self.icon:SetSize(size)
    
    -- center icon in the space provided.
    local centerPos = self.kIconSpaceSize * 0.5 * self.scale + self.position
    self.icon:SetPosition(Vector(centerPos.x - (size.x * 0.5), centerPos.y - (size.y * 0.5), 0))
    
end

function GUIChallengePrompt:UpdateButtonTransforms()
    
    local buttonsOrigin = (self.kPanelSize * 0.5 + Vector(0, self.kButtonAnchorYOffset, 0)) * self.scale + self.position
    local buttonSpacing = Vector(_G[self.kButtonClass].kButtonOverSize.x * self.scale.x, 0, 0)
    
    local buttonFirstPos = buttonsOrigin - (buttonSpacing * 0.5 * (#self.buttons - 1))
    for i=1, #self.buttons do
        self.buttons[i]:SetPosition(buttonFirstPos + (buttonSpacing * (i-1)))
        self.buttons[i]:SetScale(self.scale)
    end
    
end

function GUIChallengePrompt:UpdateTransform()
    
    local shadowOffset = self.kShadowOffset * self.scale
    
    self.numLines = self.numLines or 1
    local blockHeight = math.max(self.numLines - 1, 0) * self.fontLineSpan + self.fontSize
    local emptySpace = self.kDescriptionTextSpaceSize.y * self.scale.y - blockHeight
    local descPos = self.kDescriptionTextSpacePosition * self.scale + Vector(self.kDescriptionTextMargin * self.scale.x, emptySpace * 0.5, 0) + self.position
    self.descText:SetPosition(descPos)
    self.descTextShadow:SetPosition(descPos + shadowOffset)
    self.descText:SetScale(Vector(self.fontScale, self.fontScale, 0))
    self.descTextShadow:SetScale(Vector(self.fontScale, self.fontScale, 0))
    
    local promptPos = ((self.kPanelSize * 0.5) + Vector(0, self.kPromptTextYOffset, 0)) * self.scale + self.position
    self.promptText:SetPosition(promptPos)
    self.promptTextShadow:SetPosition(promptPos + shadowOffset)
    self.promptText:SetScale(Vector(self.fontScale, self.fontScale, 0))
    self.promptTextShadow:SetScale(Vector(self.fontScale, self.fontScale, 0))
    
    self.dimmer:SetSize(Vector(Client.GetScreenWidth(), Client.GetScreenHeight(), 0))
    self.dimmer:SetPosition(Vector(0,0,0))
    
    self:UpdateIconTransform()
    self:UpdateButtonTransforms()
    
end

function GUIChallengePrompt:SetLayer(layer)
    
    self.layer = layer
    self:UpdateLayers()
    
end

function GUIChallengePrompt:InitGUI()
    
    -- Create description text
    self.descText = self:CreateGUIItem()
    self.descTextShadow = self:CreateGUIItem()
    
    self.descText:SetText("")
    self.descTextShadow:SetText("")
    
    self.descText:SetOptionFlag(GUIItem.ManageRender)
    self.descTextShadow:SetOptionFlag(GUIItem.ManageRender)
    
    self.descText:SetFontName(self.kFontName)
    self.descTextShadow:SetFontName(self.kFontName)
    
    -- Create prompt text
    self.promptText = self:CreateGUIItem()
    self.promptTextShadow = self:CreateGUIItem()
    
    self.promptText:SetOptionFlag(GUIItem.ManageRender)
    self.promptTextShadow:SetOptionFlag(GUIItem.ManageRender)
    
    self.promptText:SetText("")
    self.promptTextShadow:SetText("")
    
    self.promptText:SetFontName(self.kFontName)
    self.promptTextShadow:SetFontName(self.kFontName)
    
    self.promptText:SetTextAlignmentX(GUIItem.Align_Center)
    self.promptTextShadow:SetTextAlignmentX(GUIItem.Align_Center)
    self.promptText:SetTextAlignmentY(GUIItem.Align_Center)
    self.promptTextShadow:SetTextAlignmentY(GUIItem.Align_Center)
    
    self.dimmer = self:CreateGUIItem()
    
end

function GUIChallengePrompt:UpdateColor()
    
    local textColor = Color(self.kFontColor)
    textColor.a = textColor.a * self.opacity
    
    self.descText:SetColor(textColor)
    self.promptText:SetColor(textColor)
    
    local shadowColor = Color(self.kShadowColor)
    shadowColor.a = shadowColor.a * self.opacity
    
    self.descTextShadow:SetColor(shadowColor)
    self.promptTextShadow:SetColor(shadowColor)
    
    for i=1, #self.buttons do
        self.buttons[i]:SetOpacity(self.opacity)
    end
    
    if self.icon then
        self.icon:SetColor(Color(1,1,1,self.opacity))
    end
    
    self.dimmer:SetColor(Color(0, 0, 0, self.opacity * self.kDimmerOpacity))
    
end

function GUIChallengePrompt:Initialize()
    
    self.items = UnorderedSet()
    self.buttons = {} -- table of button scripts
    
    -- start faded-out
    self.opacity = 0.0
    self.visState = "invisible"
    self.layer = self.kDefaultLayer
    self.windowDisabled = {}
    self.windowDisabledCount = 0
    
    self:InitGUI()
    
    self:ResizeForScreen() -- also calls UpdateTransform()
    self:UpdateColor()
    
end

function GUIChallengePrompt:Uninitialize()
    
    -- Destroy button scripts
    for i=1, #self.buttons do
        GetGUIManager():DestroyGUIScript(self.buttons[i])
    end
    
    -- Destroy gui items
    for i=1, #self.items do
        GUI.DestroyItem(self.items[i])
    end
    
end

function GUIChallengePrompt:OnResolutionChanged()
    
    self:ResizeForScreen()
    
end

function GUIChallengePrompt:ClearButtons()
    
    for i=1, #self.buttons do
        GetGUIManager():DestroyGUIScript(self.buttons[i])
    end
    self.buttons = {}
    
    self:UpdateButtonTransforms()
    
end

function GUIChallengePrompt:AddButton(localeString, callback)
    
    local newButton = GetGUIManager():CreateGUIScript(self.kButtonClass)
    newButton:SetText(Locale.ResolveString(localeString))
    newButton:SetCallback(callback)
    newButton:SetParentScript(self)
    table.insert(self.buttons, newButton)
    
    self:UpdateButtonTransforms()
    self:UpdateLayers()
    
end

-- Disable the window with a label.  Multiple things can disable the window at once, and the window will only
-- ever be active again once all those things have set the window to active again.
function GUIChallengePrompt:SetWindowActive(label, state)
    
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
function GUIChallengePrompt:GetIsWindowActive()
    return self.windowDisabledCount == 0 and self.visState == "visible"
end

function GUIChallengePrompt:ResizeForScreen()
    
    _, self.scale = Fancy_Transform(Vector(0,0,0), Vector(1,1,1))
    
    local screenSize = Vector(Client.GetScreenWidth(), Client.GetScreenHeight(), 0)
    local panelSize = self.kPanelSize * self.scale
    
    self.position = ((screenSize - panelSize) * 0.5)
    
    self:UpdateFontScale()
    self:UpdateTransform()
    
end

function GUIChallengePrompt:DoCallback()
    
    if not self.callback then
        return
    end
    
    local tempCallback = self.callback
    self.callback = nil
    tempCallback(self)
    
end

function GUIChallengePrompt:UpdateVisibility(deltaTime)
    
    if self.visState == "fadingIn" then
        
        self.opacity = math.min(self.opacity + (deltaTime / self.kFadeTime), 1.0)
        self:UpdateColor()
        
        if self.opacity == 1.0 then
            self.visState = "visible"
            self:DoCallback()
        end
        
    elseif self.visState == "fadingOut" then
        
        self.opacity = math.max(self.opacity - (deltaTime / self.kFadeTime), 0.0)
        self:UpdateColor()
        
        if self.opacity == 0.0 then
            self.visState = "invisible"
            self:DoCallback()
        end
        
    end
    
end

function GUIChallengePrompt:Update(deltaTime)
    
    self:UpdateVisibility(deltaTime)
    
end

function GUIChallengePrompt:Hide(callback)
    
    self.callback = callback
    
    if self.visState ~= "visible" then
        self:DoCallback()
        return
    end
    
    self.visState = "fadingOut"
    
end

function GUIChallengePrompt:Show(callback)
    
    self.callback = callback
    
    if self.visState ~= "invisible" then
        self:DoCallback()
        return
    end
    
    self.visState = "fadingIn"
    
end

function GUIChallengePrompt:SetPromptTextLiteral(stringLiteral)
    
    self.promptText:SetText(stringLiteral)
    self.promptTextShadow:SetText(stringLiteral)
    
end

function GUIChallengePrompt:SetPromptText(localeString)
    
    local promptResolved = Locale.ResolveString(localeString)
    self.promptText:SetText(promptResolved)
    self.promptTextShadow:SetText(promptResolved)
    
end

function GUIChallengePrompt:SetDescriptionText(localeString)
    
    local descriptionResolved = Locale.ResolveString(localeString)
    local maxWidth = self.kDescriptionTextSpaceSize.x - (self.kDescriptionTextMargin * 2.0)
    
    local descriptionWrapped
    local numLines
    descriptionWrapped, _, numLines = WordWrap(self.descText, descriptionResolved, 0, maxWidth * self.scale.x)
    self.descText:SetText(descriptionWrapped)
    self.descTextShadow:SetText(descriptionWrapped)
    self.numLines = numLines
    
    self:UpdateTransform()
    
end

function GUIChallengePrompt:SetIcon(name)
    
    if self.kIcons[name] == nil then
        Log("Icon '%s' not found for prompt screen!")
        return
    end
    
    if not self.icon then
        self.icon = self:CreateGUIItem()
    end
    
    self.icon:SetTexture(self.kIcons[name])
    self:UpdateIconTransform()
    self:UpdateLayers()
    self:UpdateColor()
    
end

function GUIChallengePrompt:SendKeyEvent(input, down)
    
    -- take control of mouse movement, so they player isn't also moving their view around with the mouse visible.
    -- This *should* be handled by InputHandler.lua... but... it doesn't always catch things... :(
    if input == InputKey.MouseX or input == InputKey.MouseY then
        return true
    end
    
    for i=1, #self.buttons do
        
        if self.buttons[i]:SendKeyEventFromParent(input, down) then
            return true
        end
        
    end
    
    -- consume all events (don't allow main menu to open while this screen is open).
    return true
    
end




