-- ======= Copyright (c) 2017, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\menu\FancyPlainText.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Concrete text type of FancyElement.  For text that requires advanced shader effects (eg
--    blurring, distorting, or other spatial or convolution effects), consider using FancyText
--    instead.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/menu/FancyElement.lua")
Script.Load("lua/menu/FancyUtilities.lua")

class 'FancyPlainText' (FancyElement)

-----------------------
-- From FancyElement --
-----------------------

function FancyPlainText:UpdateItem()
    
    FancyElement.UpdateItem(self)
    
    self:UpdateTransform()
    
    if self.item then
        if self.color then
            self.item:SetColor(self.color)
        end
        
        if self.textActual then
            self.item:SetText(self.textActual)
        end
        
        if self.fontActual then
            self.item:SetFontName(self.fontActual)
        end
    end
    
end

function FancyPlainText:Initialize()
    
    FancyElement.Initialize(self)
    
    if self:GetOwnsTextItem() then
        self.item = GUI.CreateItem()
        self.item:SetOptionFlag(GUIItem.ManageRender)
        self.item:SetIsVisible(true)
        self.item:SetTextAlignmentX(GUIItem.Align_Center)
        self.item:SetTextAlignmentY(GUIItem.Align_Center)
    end
    
    self.desiredWidth = nil
    self.desiredHeight = nil
    
    self.anchorPointSizeFactor = Vector(0,0,0)
    
    -- extra width/height added to the item's calculated size.  (per side, so actual additional
    -- width/height is 2 * value.
    self.padding = Vector(0,0,0)
    
    self.calculatedTextSize = nil
    
    -- the translation string, not the actual text itself.
    self.text = nil
    self.textActual = nil -- actual string being dispalyed, ie run through Locale()
    
    self.fontName = nil -- preferred font
    self.fallbackFontName = nil -- font to use in case preferred font cannot render all characters.
    self.fontActual = nil -- font that is actually rendered.
    
    self.color = Color(1,1,1,1)
    
    -- There is the FancyElement scaling (ie, inherited from parents, passed to children), and
    -- then there's this "internalScale" value.  This is where we set the "font size", which should
    -- not impact any children it might have.  THIS is the value that is directly influenced by
    -- the desired width & height of the text box.
    self.internalScale = 1.0
    
    self:UpdateItem()
    
    getmetatable(self).__tostring = FancyPlainText.ToString
    
end

function FancyPlainText:ToString()
    
    local str = FancyElement.ToString(self)
    str = str .. string.format("    item = %s\n    desiredWidth = %s\n    desiredHeight = %s\n    anchorPointSizeFactor = %s\n    padding = %s\n    calculatedTextSize = %s\n    text = %s\n    textActual = %s\n    fontName = %s\n    fallbackFontName = %s\n    fontActual = %s\n    color = %s\n    internalScale = %s\n", self.item, self.desiredWidth, self.desiredHeight, self.anchorPointSizeFactor, self.padding, self.calculatedTextSize, self.text, self.textActual, self.fontName, self.fallbackFontName, self.fontActual, self.color, self.internalScale)
    return str
    
end

function FancyPlainText:Destroy()
    
    FancyElement.Destroy(self)
    
    if self.item then
        GUI.DestroyItem(self.item)
        self.item = nil
    end
    
end

function FancyPlainText:SetIsVisible(state)
    
    FancyElement.SetIsVisible(self, state)
    
    if self.item then
        self.item:SetIsVisible(state)
    end
    
end

function FancyPlainText:GetDisplayedItem()
    
    return self.item
    
end

----------------------------
-- FancyPlainText methods --
----------------------------

-- call to cause it to re-check that all characters of the text can be displayed by the font.
-- sets the "fontActual" parameter, which will be either fontName, or, if that font cannot render
-- all characters, fallbackFontName. Should be called any time text or fonts are changed.
function FancyPlainText:UpdateActualFont()
    
    self.fontActual = Fancy_GetBestFont(self.fontName, self.fallbackFontName, self.textActual)
    
    self:UpdateItem()
    
end

-- Updates the "internalScale" value to reflect the desired text area size, as well as
-- the "calculatedTextSize" to the pixel size of the text before scaling is applied.
function FancyPlainText:UpdateSourceScale()
    
    if self.desiredWidth then assert(self.desiredWidth > 0) end
    if self.desiredHeight then assert(self.desiredHeight > 0) end
    
    -- reset to 1
    if not self.desiredWidth and not self.desiredHeight then
        self.internalScale = 1.0
        return
    end
    
    if self.textActual and self.fontActual then
        -- size is in real pixels, not the assumed 1080p that all other measurements are based on.  Correct for this.
        local _, scale = Fancy_Transform(Vector(0,0,0), 1)
        self.calculatedTextSize = Fancy_CalculateTextSize(self.textActual, self.fontActual) / scale
    end
    
    if self.calculatedTextSize then
        
        local uniformScale = 1.0
        local scaleX
        local scaleY

        if self.desiredWidth then
            scaleX = self.desiredWidth / self.calculatedTextSize.x
        end
        
        if self.desiredHeight then
            scaleY = self.desiredHeight / self.calculatedTextSize.y
        end
        
        if scaleX then
            if scaleY then
                uniformScale = min(scaleX, scaleY)
            else
                uniformScale = scaleX
            end
        else
            uniformScale = scaleY
        end
        
        self.internalScale = uniformScale
        
    end
    
end

function FancyPlainText:UpdateTransform()
    
    self:UpdateSourceScale()
    
    -- gets the text object, or if this is a fancyText, then gets the image the rendered text is
    -- displayed on.
    local item = self:GetDisplayedItem()
    if item then
        item:SetScale(self:GetAbsoluteScale() * self.internalScale)
    end
    
    if item and self.calculatedTextSize then
        local pixelSize = self.calculatedTextSize * self.internalScale
        local offset = Vector(0,0,0)
        local anchorPointFactor = self:GetAnchorPointVector()
        offset.x = pixelSize.x * anchorPointFactor.x + self.padding.x
        offset.y = pixelSize.y * anchorPointFactor.y + self.padding.y
        local position = Vector(0,0,0)
        position.x = self:GetAbsolutePosition().x - offset.x * self:GetAbsoluteScale().x
        position.y = self:GetAbsolutePosition().y - offset.y * self:GetAbsoluteScale().y
        position = Fancy_Transform(position, 1, self:GetResizeMethod())
        item:SetPosition(position)
    end
    
    if item then
        item:SetLayer(self.layer)
    end
    
end

-- Is the text gui item a member of the element itself?
function FancyPlainText:GetOwnsTextItem()
    
    return true
    
end

function FancyPlainText:SetText(text)
    
    if not text or self.text == text then
        return
    end
    
    self.text = text
    
    self:UpdateActualText()
    
end

-- Updates the "textActual" value, which is the string to be displayed. ("text" is the translation
-- string.)  This triggers an update to the actual font, which also triggers an item update.
function FancyPlainText:UpdateActualText()
    
    if not self.text then
        return
    end
    
    self.textActual = Locale.ResolveString(self.text)
    
    self:UpdateActualFont()
    
end

function FancyPlainText:SetColor(color)
    
    if self.color == color then
        return
    end
    
    self.color = color
    
    self:UpdateItem()
    
end

-- Either parameter is optional.  Only the parameters specified will be changed.
-- (eg passing nil as fallbackFontName doesn't set it to nil)
function FancyPlainText:SetFont(fontName, fallbackFontName)
    
    if self.fontName == fontName and self.fallbackFontName == fallbackFontName then
        return
    end
    
    self.fontName = fontName or self.fontName
    self.fallbackFontName = fallbackFontName or self.fallbackFontName
    
    self:UpdateActualFont()
    
end

-- Sets the desired size of the text, in 1080p pixels, and assuming absolute (inherited X
-- relative) scale is 1.  Passing nil for either the width or height sets the constraint to
-- be width/height only.  Passing nil for both resets scale to 1.0.  In other words, this
-- method is used to adjust the "font size" of the text, before any other scaling is performed.
function FancyPlainText:SetDesiredBox(width, height)
    
    if self.desiredWidth == width and self.desiredHeight == height then
        return
    end
    
    self.desiredWidth = width
    self.desiredHeight = height
    
    self:UpdateItem()
    
end

-- to allow for stuff that's bigger than the text itself, ie glows, blurs, etc.
function FancyPlainText:SetPadding(padding)
    
    if not padding or self.padding == padding then
        return
    end
    
    self.padding = padding
    
    self:UpdateItem()
    
end

function FancyPlainText:SetAnchorPointByName(name)
    
    if not name then
        return
    end
    
    local newAnchorPointSizeFactor = Fancy_GetAnchorPointFactorByName(name)
    if self.anchorPointSizeFactor == newAnchorPointSizeFactor then
        return
    end
    
    self.anchorPointSizeFactor = newAnchorPointSizeFactor
    
    self:UpdateItem()
    
end

function FancyPlainText:GetAnchorPointVector()
    
    return self.anchorPointSizeFactor
    
end

-----------------------------------------
-- Global Utilities for FancyPlainText --
-----------------------------------------

kFancyTextAnchorPoints =
{
    ["top-left"]        = Vector(-0.5, -0.5, 0.0),
    ["top"]             = Vector( 0.0, -0.5, 0.0),
    ["top-right"]       = Vector( 0.5, -0.5, 0.0),
    ["left"]            = Vector(-0.5,  0.0, 0.0),
    ["center"]          = Vector( 0.0,  0.0, 0.0),
    ["right"]           = Vector( 0.5,  0.0, 0.0),
    ["bottom-left"]     = Vector(-0.5,  0.5, 0.0),
    ["bottom"]          = Vector( 0.0,  0.5, 0.0),
    ["bottom-right"]    = Vector( 0.5,  0.5, 0.0),
}
function Fancy_GetAnchorPointFactorByName(name)
    
    local relativeAnchor = kFancyTextAnchorPoints[name]
    if relativeAnchor then
        return relativeAnchor
    end
    
    Log("ERROR!  Unknown anchor point name '%s'.", name)
    return Vector(0, 0, 0)
    
end 
