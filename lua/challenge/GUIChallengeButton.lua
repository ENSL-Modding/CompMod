-- ======= Copyright (c) 2017, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\challenge\GUIChallengeButton.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Base class for a button for use in the challenge modes popups.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUIAssets.lua")
Script.Load("lua/UnsortedSet.lua")

class 'GUIChallengeButton' (GUIScript)

GUIChallengeButton.kFontName = Fonts.kAgencyFB_Medium
GUIChallengeButton.kFontSize = 20 -- desired font size, at 1-1 scaling.
GUIChallengeButton.kFontActualSize = 22 -- size font texture actually is
GUIChallengeButton.kTextColor = Color(0,0,0,1)
GUIChallengeButton.kButtonSize = Vector(221, 71, 0)
GUIChallengeButton.kButtonSpacing = 40

GUIChallengeButton.kDefaultLayer = 40

GUIChallengeButton.kTextLayerOffset = 0

-- Over size = regular size scaled up proportionally so that it is kButtonSpacing-wider than normal.
GUIChallengeButton.kButtonOverSize = Vector(GUIChallengeButton.kButtonSize.x + GUIChallengeButton.kButtonSpacing, ((GUIChallengeButton.kButtonSize.x + GUIChallengeButton.kButtonSpacing) / GUIChallengeButton.kButtonSize.x) * GUIChallengeButton.kButtonSize.y, 0)

GUIChallengeButton.kHoverSound = PrecacheAsset("sound/NS2.fev/common/hovar")
GUIChallengeButton.kClickSound = PrecacheAsset("sound/NS2.fev/common/button_click")

function GUIChallengeButton:UpdateTransform()
    
    local size = self.kButtonSize * self.scale
    self.minCorner = self.position - (size * 0.5)
    self.maxCorner = self.minCorner + size
    self.realSize = size -- useful for child classes to not have to redo these calculations
    
    self.text:SetPosition(self.position)
    self.text:SetScale(self.fontScale)
    
end

function GUIChallengeButton:CreateGUIItem()
    
    local item = GUI.CreateItem()
    US_Add(self.items, item)
    
    return item
    
end

function GUIChallengeButton:InitGUI()
    
    self.text = self:CreateGUIItem()
    self.text:SetOptionFlag(GUIItem.ManageRender)
    self.text:SetTextAlignmentX(GUIItem.Align_Center)
    self.text:SetTextAlignmentY(GUIItem.Align_Center)
    self.text:SetFontName(self.kFontName)
    
end

function GUIChallengeButton:UpdateFontScale()
    
    local fontScale = (self.kFontSize / self.kFontActualSize) * self.scale.y
    self.fontScale = Vector(fontScale, fontScale, 0)
    
end

function GUIChallengeButton:UpdateLayers()
    
    self.text:SetLayer(self.layer + self.kTextLayerOffset)
    
end

function GUIChallengeButton:UpdateColor()
    
    local textColor = Color(self.kTextColor)
    textColor.a = textColor.a * self.opacity
    self.text:SetColor(textColor)
    
end

-- Sets the parent script of this button.  The parent script is used to determine if the buttons
-- should be active or not.
function GUIChallengeButton:SetParentScript(script)
    
    self.parentScript = script
    
end

function GUIChallengeButton:Initialize()
    
    self.items = US_Create()
    
    self.layer = self.kDefaultLayer
    self.opacity = 0.0 -- start faded out.
    
    self.position = Vector(0,0,0)
    self.scale = Vector(1,1,0)
    
    self.minCorner = Vector(0,0,0)
    self.maxCorner = Vector(0,0,0)
    
    self.over = false
    self.mouseDown = false
    
    self:InitGUI()
    self:UpdateFontScale()
    self:UpdateColor()
    self:UpdateLayers()
    self:UpdateTransform()
    self:Update(0)
    
    MouseTracker_SetIsVisible(true, nil, true)
    
    self.updateInterval = 0
    
end

function GUIChallengeButton:Uninitialize()
    
    for i=1, #self.items.a do
        GUI.DestroyItem(self.items.a[i])
    end
    
    MouseTracker_SetIsVisible(false)
    
end

function GUIChallengeButton:SetText(text)
    
    self.text:SetText(text)
    
end

function GUIChallengeButton:SetCallback(callback)
    
    self.callback = callback
    
end

function GUIChallengeButton:CheckForMouseOver()
    
    if not self.parentScript or not self.parentScript:GetIsWindowActive(self) then
        return false
    end
    
    local mousePos = Vector(0,0,0)
    mousePos.x, mousePos.y = Client.GetCursorPosScreen()
    
    if  mousePos.x >= self.minCorner.x and
        mousePos.x < self.maxCorner.x and
        mousePos.y >= self.minCorner.y and
        mousePos.y < self.maxCorner.y then
        return true
    end
    
    return false
    
end

function GUIChallengeButton:Update(deltaTime)
    
    local newOver = self:CheckForMouseOver()
    if not self.over and newOver then
        -- Play sound effect
        StartSoundEffect(self.kHoverSound)
    end
    
    if self.over ~= newOver then
        self.over = newOver
        self:UpdateTransform()
    end
    
end

-- We only receive SendKeyEvent from the parent GUIScript because we want the option of consuming all events
-- (eg prevent main menu from being opened while this screen is visible).
function GUIChallengeButton:SendKeyEventFromParent(input, down)
    
    -- We only care about the left mouse button.
    if input ~= InputKey.MouseButton0 then
        return false
    end
    
    -- ensure mouse button was not being held down.
    if self.mouseDown and down then
        return false
    end
    
    -- keep track of mouse's previous "down" state
    self.mouseDown = down
    
    -- nothing else to do if the button isn't down.
    if not down then
        return false
    end
    
    -- determine if the mouse cursor is over the button.  It will also return false if the button is disabled,
    -- even if the mouse is over the button.
    local over = self:CheckForMouseOver()
    if not over then
        return false
    end
    
    -- if we made it this far, must be a valid click.
    StartSoundEffect(self.kClickSound)
    if self.callback then
        self.callback(self)
    end
    
    return true
    
end

function GUIChallengeButton:SetPosition(position)
    
    self.position = position
    self:UpdateTransform()
    
end

function GUIChallengeButton:SetScale(scale)
    
    self.scale = scale
    self:UpdateFontScale()
    self:UpdateTransform()
    
end

function GUIChallengeButton:SetOpacity(opacity)
    
    self.opacity = opacity
    self:UpdateColor()
    
end

function GUIChallengeButton:SetLayer(layer)
    
    self.layer = layer
    self:UpdateLayers()
    
end



