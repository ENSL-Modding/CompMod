-- ======= Copyright (c) 2017, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\menu\FancyText.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Concrete text type of FancyElement that allows for more advanced shaders to be applied to it.
--    Uses a GUIView to render text with a particular font to a texture.  Allows for more complex
--    shader effects than a simple text-GUIItem. For more simple text objects (ie without the
--    GUIView rendering to intermediate texture) that do not require advanced shader effects, use
--    a FancyPlainText instead.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/menu/FancyPlainText.lua")
Script.Load("lua/menu/FancyGUIViewManager.lua")

class 'FancyText' (FancyPlainText)

local function CalculateViewSizes(self)
    
    if self.calculatedTextSize then
        local textSize = self.calculatedTextSize * self.internalScale
        
        -- round to nearest actual pixel, to prevent 1-pixel size differences between
        -- fancytext and fancyplaintext.
        local _, scale = Fancy_Transform(Vector(0,0,0), 1)
        textSize.x = (math.floor(textSize.x * scale) / scale)
        textSize.y = (math.floor(textSize.y * scale) / scale)
        
        if self.padding then
            self.guiViewSize = (textSize + self.padding * 2) * scale
        end
        
        -- internalScale was set with the call to FancyPlainText.UpdateSourceScale.
        -- reset it so we don't scale the guiitem that the rendered image is presented
        -- in.  But first, modify the calculated text size to match the result of
        -- multiplying the two together.
        self.calculatedTextSize = textSize
        self.guiViewTextScale = self.internalScale -- make a copy so we can pass to the GVM
        self.internalScale = 1.0
    end
    
end

local function DestroyImage(self)
    
    if self.image then
        GUI.DestroyItem(self.image)
        self.image = nil
    end
    
end

local function ValidateImage(self)
    
    if not self.image then
        self.image = GUI.CreateItem()
    end
    
    self.image:SetTexture(self.guiViewTarget)
    self.image:SetColor(Color(1,1,1,1))
    self.image:SetSize(self.guiViewSize)
    self.image:SetLayer(self.layer)
    self.image:SetIsVisible(false) -- not until we're ready to display it.
    
end

local function GetIsValidStateForGVM(self)
    
    -- Equate empty string with nil, to keep things simple.
    if self.text == "" then
        self.text = nil
    end
    
    if not self.textActual then
        return false
    end
    
    if not self.guiViewSize then
        return false
    end
    
    if not self.guiViewTextScale then
        return false
    end
    
    local fontInvalid = not self.fontActual
    if not self.fontActual then
        return false
    end
    
    return true
    
end

local function GetIsValidStateForImage(self)
    
    if not GetIsValidStateForGVM(self) then
        return false
    end
    
    if not self.guiViewTarget then
        return false
    end
    
    return true
    
end

local function SetupGUIViewManager(self, setupTable)
    
    local gvm = FancyGUIViewManager()
    
    gvm:Initialize(self.guiViewSize) -- so it rounds properly
    gvm:Setup(setupTable)
    
    -- pass additional shader parameters to GVM
    assert(self.textActual)
    assert(self.fontActual)
    assert(self.guiViewTextScale)
    
    gvm:SetTextInputValue("text", self.textActual)
    gvm:SetTextInputValue("fontName", self.fontActual)
    gvm:SetTextInputValue("textScaleFactor", self.guiViewTextScale)
    
    self.guiViewManager = gvm
    self.guiViewTarget = gvm:GetOutputTextureName()
    
end

local function DestroyGUIViewManager(self)
    
    if self.guiViewManager then
        self.guiViewManager:Destroy()
    end
    
end

-------------------------
-- From FancyPlainText --
-------------------------

-- FancyText does not create its own text item -- it creates a
-- GUIView that renders to a texture.  FancyText owns the gui item
-- that displays the texture... not the text itself.
function FancyText:GetOwnsTextItem()
    
    return false
    
end

function FancyText:UpdateSourceScale()
    
    FancyPlainText.UpdateSourceScale(self)
    
    -- calculate the size of the gui view object.
    CalculateViewSizes(self)
    
end

-- this is also called when text is changed, so we don't need to worry about overriding this
-- specifically for text changes.
function FancyText:UpdateActualFont()
    
    FancyPlainText.UpdateActualFont(self)
    
    -- will likely change the size of the texture it needs to render to, so reset the GVM
    self:ResetGVM()
    
end

function FancyText:GetAnchorPointVector()
    
    -- image is always aligned from its upper left corner.
    return self.anchorPointSizeFactor + Vector(0.5, 0.5, 0.0)
    
end

-----------------------
-- From FancyElement --
-----------------------

function FancyText:UpdateItem()
    
    FancyPlainText.UpdateItem(self)
    
    if GetIsValidStateForImage(self) then
        -- text should be visible.
        ValidateImage(self)
    else
        -- no text is visible
        DestroyImage(self)
    end
    
end

function FancyText:Initialize()
    
    FancyPlainText.Initialize(self)
    
    self.image = nil
    
    self.guiViewManager = nil
    
    self.isVisible = true
    
    -- in 1080p pixels... will need to be converted for most uses... but we want to remain consistent.
    self.guiViewSize = nil
    self.guiViewTarget = nil -- texture name to be displayed.
    self.guiViewTextScale = 1.0
    
    self:UpdateItem()
    
    getmetatable(self).__tostring = FancyText.ToString
    
end

function FancyText:ToString()
    
    local str = FancyPlainText.ToString(self)
    str = str .. string.format("    image = %s\n    guiViewManager = %s\n    isVisible = %s\n    guiViewSize = %s\n    guiViewTextScale = %s\n    guiViewTarget = %s\n", self.image, self.guiViewManager, self.isVisible, self.guiViewSize, self.guiViewTextScale, self.guiViewTarget)
    return str
    
end

function FancyText:Destroy()
    
    FancyPlainText.Destroy(self)
    
    DestroyImage(self)
    DestroyGUIViewManager(self)
    
end

function FancyText:SetIsVisible(state)
    
    FancyElement.SetIsVisible(self, state)
    
    self.isVisible = state
    if self.image then
        self.image:SetIsVisible(state)
    end
    
end

function FancyText:GetDisplayedItem()
    
    return self.image
    
end

-----------------------
-- FancyText methods --
-----------------------

function FancyText:GetImage()
    
    return self.image
    
end

function FancyText:ResetGVM()
    
    if not GetIsValidStateForGVM(self) then
        return
    end
    
    DestroyGUIViewManager(self)
    SetupGUIViewManager(self, self.setupTable)
    self:RenderElement()
    
end

function FancyText:SetupShaders(setupTable)
    
    self.setupTable = setupTable
    self:ResetGVM()
    
    self:UpdateItem()
    
end

function FancyText:OnResolutionChanged()
    
    FancyElement.OnResolutionChanged(self)
    
    self:UpdateItem()
    self:ResetGVM()
    self:UpdateItem() -- to update the image size with the new gui view size and render target.
    
end

function FancyText:RenderElement()
    
    FancyElement.RenderElement(self)
    
    if self.guiViewManager then
        self.guiViewManager:RenderAll()
    else
        Log("WARNING: FancyText:RenderElement() called before guiViewManager initialized")
    end
    
end

function FancyText:Update(deltaTime)
    
    FancyElement.Update(self)
    
    local visible = false
    if self.guiViewManager then
        self.guiViewManager:Update(deltaTime)
        
        if self.guiViewManager:GetIsReadyToDisplay() then
            visible = true
        end
    end
    
    -- hide image unless it's ready to be displayed... otherwise we see a bunch of noisy garbage.
    if self.image then
        self.image:SetIsVisible(visible and self.isVisible)
    end
    
end


