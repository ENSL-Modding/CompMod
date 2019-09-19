-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/GUI/GUIParagraph.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Same as GUIText, except text will be automatically word-wrapped to fit into the specified
--    region.
--  
--  Parameters (* = required)
--      font
--      fontFamily (only if font not defined)
--      fontSize (only if font not defined)
--      paragraphSize
--      text
--      justification
--  
--  Properties:
--      FontFamily      Whether or not this object is currently being dragged by the user.
--      FontSize        Whether or not this object can be dragged by the user.
--      ParagraphSize   The size of the region to word-wrap text into.  The height, if non-negative
--                      limits text rendering to this area.  If height is negative, the size of the
--                      text returned is calculated after the word wrap.
--      Justification   The justification of the font.  It can be one of 3 values:
--                          left justified      = GUIItem.Align_Min
--                          center justified    = GUIItem.Align_Center
--                          right justified     = GUIItem.Align_Max
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/GUIText.lua")

---@class GUIParagraph : GUIText
class "GUIParagraph" (GUIText)

GUIParagraph:AddClassProperty("ParagraphSize", Vector(9999, -1, 0))
GUIParagraph:AddClassProperty("Justification", GUIItem.Align_Min)

local kLegalJustifications =
{
    [GUIItem.Align_Min] = true,
    [GUIItem.Align_Center] = true,
    [GUIItem.Align_Max] = true,
}

local function UpdateTextClipping(self)
    
    local paragraphSize = self:GetParagraphSize()
    local textScale = self.text:GetScale()
    
    local flexibleHeight = paragraphSize.y < 0
    local clippedWidth
    local clippedHeight
    if textScale.x == 0 or textScale.y == 0 then
        -- Just a weird number so I can tell what's going on if I ever encouter a bug related to
        -- this.  Doesn't really matter visually since one of the scales is zero.
        clippedWidth = 333
        clippedHeight = 333
    else
        clippedWidth = paragraphSize.x / textScale.x
        clippedHeight = paragraphSize.y / textScale.y
    end
    
    self.text:SetTextClipped(true, clippedWidth, flexibleHeight and -1 or clippedHeight)
    
    self:ForceUpdateTextSize()
    
end

local kJustificationToHotSpotXMapping =
{
    [GUIItem.Align_Min] = 0,
    [GUIItem.Align_Center] = -0.5,
    [GUIItem.Align_Max] = -1,
}

local function UpdateJustification(self)
    
    local align = self:GetJustification()
    self.text:SetTextAlignmentX(align)
    
    assert(kJustificationToHotSpotXMapping[align])
    self.text:SetHotSpot(kJustificationToHotSpotXMapping[align], self.text:GetHotSpot().y)
    
end

local function OnJustificationChanged(self, justify)
    
    if kLegalJustifications[justify] == nil then
        error(string.format("Illegal value for justification.  Expected GUIItem.Align_Min (%s), GUIItem.Align_Center (%s), or GUIItem.Align_Max (%s) -- Got %s instead.", GUIItem.Align_Min, GUIItem.Align_Center, GUIItem.Align_Max, justify), errorDepth)
    end
    
    UpdateJustification(self)
    
end

function GUIParagraph:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    -- Allow clip size to be specified.
    RequireType({"Vector", "nil"}, params.paragraphSize, "params.paragraphSize", errorDepth)
    
    -- Allow justification to be specified.
    RequireType({"number", "nil"}, params.justification, "params.justification", errorDepth)
    if params.justification ~= nil and kLegalJustifications[params.justification] == nil then
        error(string.format("Illegal value for params.justification.  Expected GUIItem.Align_Min (%s), GUIItem.Align_Center (%s), or GUIItem.Align_Max (%s) -- Got %s instead.", GUIItem.Align_Min, GUIItem.Align_Center, GUIItem.Align_Max, params.justification), errorDepth)
    end
    
    GUIText.Initialize(self, params, errorDepth)
    
    -- Reset alignment of text object (centered from GUIText, but this messes up justification).
    self.text:AlignTopLeft()
    
    self:HookEvent(self, "OnParagraphSizeChanged", UpdateTextClipping)
    
    -- All of the following events can potentially cause text scale to change.
    self:HookEvent(self, "OnAbsoluteScaleChanged", UpdateTextClipping)
    self:HookEvent(self, "OnTextChanged", UpdateTextClipping)
    self:HookEvent(self, "OnFontSizeChanged", UpdateTextClipping)
    self:HookEvent(self, "OnFontFamilyChanged", UpdateTextClipping)
    
    self:HookEvent(self, "OnJustificationChanged", OnJustificationChanged)
    
    UpdateTextClipping(self)
    
    if params.paragraphSize then
        self:SetParagraphSize(params.paragraphSize)
    end
    
    if params.justification then
        self:SetJustification(params.justification)
    end
    
    self:ForceUpdateTextSize()
    
end
