-- ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/Hud/HelpScreen/HelpTile.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Displays information about one ability/weapon of a lifeform/marine.  Abstract of MarineHelpTile and AlienHelpTile.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUIAssets.lua")

class "HelpTile" (GUIScript)

-- GUIBasic shader, but with a "saturation" parameter added.
HelpTile.saturationShader = "shaders/GUIBasicSaturation.surface_shader"

HelpTile.descriptionBackgroundRegionSize = Vector(323, 91, 0)
HelpTile.descriptionBackgroundPosition = Vector(-26, 251, 0) -- relative to upper-left corner of block background.
HelpTile.descriptionBackgroundLayer = 5
HelpTile.descriptionBackgroundDefaultScaleFactor = 0.5

HelpTile.blockTextOffsetY = 177
HelpTile.blockTextHeight = 17
HelpTile.blockTextFontName = Fonts.kMicrogrammaDBolExt_Huge
local kMacroFontActualHeight = 49.0
HelpTile.blockTextLayer = 7
HelpTile.blockBackgroundLayer = 6
HelpTile.blockBackgroundRegionSize = Vector(267, 235, 0) -- the usable area of the box -- not just the graphic's size
HelpTile.blockBackgroundDefaultScaleFactor = 0.5

HelpTile.descriptionTextHeight = 20 -- desired height
HelpTile.descriptionTextLineSpacing = 29 -- space from top of one line to top of other line
HelpTile.descriptionTextFontName = Fonts.kAgencyFB_Medium
HelpTile.descriptionTextFontActualHeight = 22.0 -- actual height of kAgencyMedium
HelpTile.descriptionTextLayer = 7
HelpTile.descriptionTextMinStartY = -30
HelpTile.descriptionShadowColor = Color(0,0,0,0.5)
HelpTile.descriptionTextShadowLayer = 6
HelpTile.descriptionTextShadowOffset = Vector(2, 2, 0)

HelpTile.bindingIconCenterPosition = Vector(134, -56, 0)
HelpTile.bindingIconHeight = 71
HelpTile.bindingSeparatorFontName = Fonts.kMicrogrammaDBolExt_Huge
HelpTile.bindingSeparatorScaleFactor = 0.75
HelpTile.bindingSpacing = 5
HelpTile.bindingScaleFactor = 0.75

HelpTile.bigIconCenterPosition = Vector(134, 104, 0)
HelpTile.bigIconDefaultScaleFactor = 0.5 -- icon graphics are by default 2x the size they should be for a 1920x1080 screen.
HelpTile.bigIconLayer = 7

HelpTile.titleTextColor = Color(1,1,1,1)
HelpTile.missingRequirementTextColor = Color( 1, 58/255, 58/255, 1)

HelpTile.requirementTextPosition = Vector(134, 333, 0)
HelpTile.requirementTextShadowOffset = Vector(2, 2, 0)
HelpTile.requirementTextShadowColor = Color(0,0,0,0.5)
HelpTile.requirementTextHeight = 15
HelpTile.requirementTextLayer = 7
HelpTile.requirementTextShadowLayer = 6

local function DestroyItem(item)
    
    if item == nil then
        return
    end
    
    if type(item) == "table" then
        if item.type ~= nil then
            if item.type == "guiitem" then
                GUI.DestroyItem(item.item)
            elseif item.type == "guiscript" then
                GetGUIManager():DestroyGUIScript(item.item)
            else
                Log("ERROR:  Attempt to automatically destroy unknown item type!  (was '%s')", item.type)
            end
        else
            for i=1, #item do
                DestroyItem(item[i])
            end
        end
    else
        GUI.DestroyItem(item)
    end
    
end

-- all constant measurements provided assume a 1920x1080 screen size.  If this isn't true, we
-- want to uniformly scale this rectangle into the current screen size, so we'll either letter-box
-- or pillar-box the result.  This function calculates the scaling factor and the offset to add to
-- the scaled positions of gui items, and assigns them to the HelpTile passed to it.
function HelpTile:CalculateOffsetAndScale()
    
    local basisWidth = 1920
    local basisHeight = 1080
    local basisRatio = basisWidth / basisHeight
    
    local width = Client.GetScreenWidth()
    local height = Client.GetScreenHeight()
    local ratio = width / height
    
    if width == basisWidth and height == basisHeight then
        self.scaledOffset = Vector(0,0,0)
        self.scaling = 1.0
        return
    end
    
    local scaleFactor = 1.0
    if ratio > basisRatio then
        scaleFactor = height / basisHeight
    else
        scaleFactor = width / basisWidth
    end
    
    local newBasisWidth = basisWidth * scaleFactor
    local newBasisHeight = basisHeight * scaleFactor
    
    local xOffset = (width - newBasisWidth) * 0.5
    local yOffset = (height - newBasisHeight) * 0.5
    
    self.scaledOffset = Vector(xOffset, yOffset, 0)
    self.scaling = scaleFactor
    
end

local function AddBindingItem(item, type, bindingTable)
    
    local newEntry = {}
    newEntry.type = type
    newEntry.item = item
    bindingTable[#bindingTable+1] = newEntry
    
end

local function CreateSeparator(self, text, bindingTable)
    
    local sep = GUI.CreateItem()
    sep:SetOptionFlag(GUIItem.ManageRender)
    sep:SetShader(self.saturationShader)
    sep:SetFontName(self.bindingSeparatorFontName)
    sep:SetText(text)
    sep:SetColor(self.descriptionTextColor)
    local s = self.bindingSeparatorScaleFactor * self.scaling
    sep:SetScale(Vector(s,s,0))
    sep:SetTextAlignmentX(GUIItem.Align_Center)
    sep:SetTextAlignmentY(GUIItem.Align_Center)
    
    AddBindingItem(sep, "guiitem", bindingTable)
    
end

local function CreateBinding(self, action, bindingTable)
    
    local bind = GetGUIManager():CreateGUIScript("Hud/HelpScreen/HelpScreenBinding")
    bind:SetColor(self.descriptionTextColor)
    bind:SetScalingFactor(self.scaling * self.bindingScaleFactor)
    bind:SetAction(action)
    
    AddBindingItem(bind, "guiscript", bindingTable)
    
end

local function GetItemWidth(item)
    
    if item.type == "guiitem" then
        return item.item:GetTextWidth(item.item:GetText()) * item.item:GetScale().x
    elseif item.type == "guiscript" then
        return item.item:GetScaledSize().x
    end
    
end

function HelpTile:UpdateBindingPosition()
    
    if not self.binding then
        return
    end
    
    local rightEdges = {[0] = 0.0}
    for i=1, #self.binding do
        if i > 1 then
            rightEdges[#rightEdges+1] = rightEdges[#rightEdges] + self.bindingSpacing
        end
        rightEdges[#rightEdges+1] = rightEdges[#rightEdges] + GetItemWidth(self.binding[i])
    end
    
    local startOffset = Vector(rightEdges[#rightEdges] * -0.5, 0, 0)
    local start = (((self.position + self.bindingIconCenterPosition) * self.scaling) + self.scaledOffset) + startOffset
    
    for i=1, #self.binding do
        local index = (i * 2) - 1
        local left = rightEdges[index-1]
        local right = rightEdges[index]
        local middle = (left + right) * 0.5
        self.binding[i].item:SetPosition(start + Vector(middle, 0, 0))
    end
    
end

function HelpTile:UpdateBinding()
    
    if not self.actions then
        return
    end
    
    DestroyItem(self.binding)
    self.binding = {}
    
    -- this keybind display grouping is really only written to support 2 different bindings at a
    -- time, either in sequence or as alternatives to each other.  More than this would clutter the
    -- ui too much and... frankly... wouldn't be a good sign for our game design. ;)
    for i=1, #self.actions do
        if i > 1 then
            -- add a + separator between to signify a sequence.
            CreateSeparator(self, "+", self.binding)
        end
        
        for j=1, #self.actions[i] do
            if j > 1 then
                -- add a / separator between to signify an alternative.
                CreateSeparator(self, "/", self.binding)
            end
            
            -- add the binding
            CreateBinding(self, self.actions[i][j], self.binding)
        end
    end
    
end

function HelpTile:Initialize()
    
    self.position = Vector(0,0,0)
    self.visible = true -- CAN it be visible?
    
    self:CalculateOffsetAndScale()
    
    self.blockBackground = GUI.CreateItem()
    self.blockBackground:SetShader(self.saturationShader)
    self.blockBackground:SetTexture(self.blockBackgroundTexture)
    self.blockBackground:SetSize(Vector(self.blockBackground:GetTextureWidth(), self.blockBackground:GetTextureHeight(), 0) * self.scaling * self.blockBackgroundDefaultScaleFactor)
    self.blockBackground:SetLayer(self.blockBackgroundLayer)
    
    self.blockText = GUI.CreateItem()
    self.blockText:SetShader(self.saturationShader)
    self.blockText:SetOptionFlag(GUIItem.ManageRender)
    self.blockText:SetFontName(self.blockTextFontName)
    self.blockText:SetTextAlignmentX(GUIItem.Align_Center)
    self.blockText:SetTextAlignmentY(GUIItem.Align_Center)
    local titleScale = self.scaling * (self.blockTextHeight / kMacroFontActualHeight)
    self.blockText:SetScale(Vector(titleScale, titleScale, 0))
    self.blockText:SetLayer(self.blockTextLayer)
    
    self.descriptionBackground = GUI.CreateItem()
    self.descriptionBackground:SetShader(self.saturationShader)
    self.descriptionBackground:SetTexture(self.descriptionBackgroundTexture)
    self.descriptionBackground:SetLayer(self.descriptionBackgroundLayer)
    
    self.descriptionTextItems = {}
    self.descriptionTextShadowItems = {}
    
    self.requirementText = GUI.CreateItem()
    self.requirementText:SetOptionFlag(GUIItem.ManageRender)
    self.requirementText:SetFontName(self.descriptionTextFontName)
    self.requirementText:SetTextAlignmentX(GUIItem.Align_Center)
    self.requirementText:SetTextAlignmentY(GUIItem.Align_Center)
    local reqScale = self.scaling * (self.requirementTextHeight / self.descriptionTextFontActualHeight)
    self.requirementText:SetScale(Vector(reqScale, reqScale, 0))
    self.requirementText:SetLayer(self.requirementTextLayer)
    
    self.requirementTextShadow = GUI.CreateItem()
    self.requirementTextShadow:SetOptionFlag(GUIItem.ManageRender)
    self.requirementTextShadow:SetFontName(self.descriptionTextFontName)
    self.requirementTextShadow:SetTextAlignmentX(GUIItem.Align_Center)
    self.requirementTextShadow:SetTextAlignmentY(GUIItem.Align_Center)
    local reqScale = self.scaling * (self.requirementTextHeight / self.descriptionTextFontActualHeight)
    self.requirementTextShadow:SetScale(Vector(reqScale, reqScale, 0))
    self.requirementTextShadow:SetLayer(self.requirementTextShadowLayer)
    self.requirementTextShadow:SetColor(self.requirementTextShadowColor)
    
    self:UpdatePositions()
    
    self.updateInterval = 0.25 -- 4fps
    
end

function HelpTile:UpdatePositions()
    
    self.blockBackground:SetPosition(self.scaledOffset + ((self.position - self.blockBackgroundAnchorPoint) * self.scaling))
    
    self.descriptionBackground:SetPosition(self.scaledOffset + ((self.position + self.descriptionBackgroundPosition - self.descriptionBackgroundAnchorPoint) * self.scaling))
    
    local topCenter = self.position + Vector(self.blockBackgroundRegionSize.x * 0.5, 0, 0)
    self.blockText:SetPosition(((topCenter + Vector(0, self.blockTextOffsetY, 0)) * self.scaling) + self.scaledOffset)
    
    local startingOffset = (#self.descriptionTextItems - 1) * -0.5 * self.descriptionTextLineSpacing
    startingOffset = math.max(startingOffset, self.descriptionTextMinStartY)
    
    local centerPoint = self.position + self.descriptionBackgroundPosition + (self.descriptionBackgroundRegionSize * 0.5)
    local startingPoint = centerPoint + Vector(0, startingOffset, 0)
    local offsetPer = Vector(0, self.descriptionTextLineSpacing, 0)
    local endingPoint = startingPoint
    for i=1, #self.descriptionTextItems do
        
        local p = ((startingPoint + offsetPer * (i-1)) * self.scaling) + self.scaledOffset
        self.descriptionTextItems[i]:SetPosition(p)
        self.descriptionTextShadowItems[i]:SetPosition(p + (self.descriptionTextShadowOffset * self.scaling))
        endingPoint = p
        
    end
    
    -- If we have more than 3 lines in the description, stretch out the description box vertically to accommodate the extra
    -- size.
    local extraDescriptionHeight = #self.descriptionTextItems
    if self.unlocked == false then
        -- extra line spacing for requirement text, which won't be visible if it doesn't exist, or if the item is unlocked.
        extraDescriptionHeight = extraDescriptionHeight + 1
    end
    extraDescriptionHeight = math.max(extraDescriptionHeight - 3, 0)
    extraDescriptionHeight = extraDescriptionHeight * self.descriptionTextLineSpacing * self.scaling
    
    self.descriptionBackground:SetSize(((Vector(self.descriptionBackground:GetTextureWidth(), self.descriptionBackground:GetTextureHeight(), 0) * self.descriptionBackgroundDefaultScaleFactor) + Vector(0, extraDescriptionHeight, 0)) * self.scaling)
    
    endingPoint = endingPoint + offsetPer * self.scaling
    self.requirementText:SetPosition( endingPoint )
    self.requirementTextShadow:SetPosition( self.requirementText:GetPosition() + self.requirementTextShadowOffset * self.scaling )
    
    if self.icon then -- update icon position/scaling
        local s = self.bigIconDefaultScaleFactor * self.scaling
        self.icon:SetScale(Vector(s, s, 0))
        
        local p = self.scaledOffset + ((self.position + self.bigIconCenterPosition) * self.scaling)
        local d = self.icon:GetSize() * 0.5
        p = p - d
        self.icon:SetPosition(p)
        self.icon:SetIsVisible(self.visible)
    end
    
    self:UpdateBindingPosition()
    
end

function HelpTile:Uninitialize()
    
    DestroyItem(self.blockBackground)
    self.blockBackground = nil
    
    DestroyItem(self.blockText)
    self.blockText = nil
    
    DestroyItem(self.descriptionBackground)
    self.descriptionBackground = nil
    
    DestroyItem(self.descriptionTextItems)
    self.descriptionTextItems = nil
    DestroyItem(self.descriptionTextShadowItems)
    self.descriptionTextShadowItems = nil
    
    DestroyItem(self.requirementText)
    self.requirementText = nil
    DestroyItem(self.requirementTextShadow)
    self.requirementTextShadow = nil
    
    DestroyItem(self.icon)
    self.icon = nil
    
    DestroyItem(self.binding)
    self.binding = nil
    
end

function HelpTile:OnResolutionChanged()
    
    self:CalculateOffsetAndScale()
    self:UpdatePositions()
    self:SetIsVisible(self.visible)
    
end

function HelpTile:SetIcon(path)
    
    assert(path)
    DestroyItem(self.icon)
    self.icon = GUI.CreateItem()
    self.icon:SetShader(self.saturationShader)
    self.icon:SetTexture(path)
    self.icon:SetSize(Vector(self.icon:GetTextureWidth(), self.icon:GetTextureHeight(),0))
    self.icon:SetLayer(self.bigIconLayer)
    
end

function HelpTile:SetDescriptionText(text)
    
    -- clear existing.
    DestroyItem(self.descriptionTextItems)
    self.descriptionTextItems = {}
    DestroyItem(self.descriptionTextShadowItems)
    self.descriptionTextShadowItems = {}
    
    local fontScale = (self.descriptionTextHeight / self.descriptionTextFontActualHeight) * self.scaling
    
    local tempTextObject = GUI.CreateItem()
    tempTextObject:SetOptionFlag(GUIItem.ManageRender)
    tempTextObject:SetFontName(self.descriptionTextFontName)
    tempTextObject:SetIsVisible(false)
    local wrappedText = WordWrap( tempTextObject, text, 0, self.descriptionBackgroundRegionSize.x)
    local lines = string.Explode(wrappedText, "\n")
    GUI.DestroyItem(tempTextObject)
    
    for i=1, #lines do
        
        local newTextItem = GUI.CreateItem()
        newTextItem:SetShader(self.saturationShader)
        newTextItem:SetOptionFlag(GUIItem.ManageRender)
        newTextItem:SetFontName(self.descriptionTextFontName)
        newTextItem:SetScale(Vector(fontScale, fontScale, 0))
        newTextItem:SetText(lines[i])
        newTextItem:SetColor(self.descriptionTextColor)
        newTextItem:SetLayer(self.descriptionTextLayer)
        newTextItem:SetTextAlignmentX(GUIItem.Align_Center)
        newTextItem:SetTextAlignmentY(GUIItem.Align_Center)
        self.descriptionTextItems[#self.descriptionTextItems+1] = newTextItem
        
        -- shadow
        local newTextItem2 = GUI.CreateItem()
        newTextItem2:SetOptionFlag(GUIItem.ManageRender)
        newTextItem2:SetFontName(self.descriptionTextFontName)
        newTextItem2:SetScale(Vector(fontScale, fontScale, 0))
        newTextItem2:SetText(lines[i])
        newTextItem2:SetColor(self.descriptionShadowColor)
        newTextItem2:SetLayer(self.descriptionTextShadowLayer)
        newTextItem2:SetTextAlignmentX(GUIItem.Align_Center)
        newTextItem2:SetTextAlignmentY(GUIItem.Align_Center)
        self.descriptionTextShadowItems[#self.descriptionTextShadowItems+1] = newTextItem2
        
    end
    
end

function HelpTile:UnlockStateChanged()
    
    local saturation
    if self.unlocked == false then
        saturation = 0.0
    else
        saturation = 1.0
    end
    
    self.blockBackground:SetFloatParameter("saturation", saturation)
    self.blockText:SetFloatParameter("saturation", saturation)
    self.descriptionBackground:SetFloatParameter("saturation", saturation)
    self.icon:SetFloatParameter("saturation", saturation)
    
    for i=1, #self.descriptionTextItems do
        self.descriptionTextItems[i]:SetFloatParameter("saturation", saturation)
    end
    
    if self.binding then
        for i=1, #self.binding do
            local binding = self.binding[i]
            if binding.type == "guiitem" then
                self.binding[i].item:SetFloatParameter("saturation", saturation)
            else
                self.binding[i].item:SetSaturation(saturation)
            end
        end
    end
    
end

function HelpTile:UpdateRequirements()
    
    -- since you don't LOSE abilities -- only gain them, we don't need to check
    -- for lost abilities.
    if self.unlocked then
        return
    end
    
    if not self.requirementFunction then
        self.requirementText:SetIsVisible(false)
        self.requirementTextShadow:SetIsVisible(false)
        return
    end
    
    self.requirementText:SetIsVisible(self.visible)
    self.requirementTextShadow:SetIsVisible(self.visible)
    
    local result, text, args = self.requirementFunction()
    if self.unlocked == nil or self.unlocked ~= result then
        self.unlocked = (result == true)
        if self.locale then
            self.requirementText:SetText(StringReformat(Locale.ResolveString(text), args or {}))
            self.requirementTextShadow:SetText(self.requirementText:GetText())
        else
            self.requirementText:SetText(StringReformat(text, args or {}))
            self.requirementTextShadow:SetText(self.requirementText:GetText())
        end
        
        if self.unlocked then
            self.requirementText:SetColor(self.descriptionTextColor)
        else
            self.requirementText:SetColor(self.missingRequirementTextColor)
        end
        
        self:UnlockStateChanged()
    end
    
end

function HelpTile:SetContent(content)
    
    self.name = content.name
    if content.locale == true then
        self.title = Locale.ResolveString(content.title)
        self.description = StringReformat(Locale.ResolveString(content.description), content.descriptionFormatValues or {})
    else
        self.title = content.title
        self.description = StringReformat(content.description, content.descriptionFormatValues or {})
    end
    
    self.locale = (content.locale == true)
    self.requirementFunction = content.requirementFunction
    self.imagePath = content.imagePath
    self.actions = content.actions
    self.hideIfLocked = content.hideIfLocked
    self.skipCards = content.skipCards
    
    self.blockText:SetText(self.title)
    self:SetDescriptionText(self.description)
    
    if self.imagePath then
        self:SetIcon(self.imagePath)
    end
    
    self:UpdateBinding()
    self:UpdateRequirements()
    self:UpdatePositions()
    
end

function HelpTile:SetPosition(position)
    
    self.position = position
    self:UpdatePositions()
    
end

function HelpTile:Update(deltaTime)
    
    self:UpdateRequirements()
    
end

function HelpTile:SetIsVisible(state)
    
    self.visible = state
    
    self.blockBackground:SetIsVisible(state)
    self.blockText:SetIsVisible(state)
    self.descriptionBackground:SetIsVisible(state)
    self.requirementText:SetIsVisible(state)
    self.requirementTextShadow:SetIsVisible(state)
    
    for i=1, #self.descriptionTextItems do
        self.descriptionTextItems[i]:SetIsVisible(state)
        self.descriptionTextShadowItems[i]:SetIsVisible(state)
    end
    
    if self.icon then
        self.icon:SetIsVisible(state)
    end
    
    if self.binding then
        for i=1, #self.binding do
            self.binding[i].item:SetIsVisible(state)
        end
    end
    
end



