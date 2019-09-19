-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/GUIMenuTruncatedText.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    A specialization of GUIMenuTruncatedDisplayWidget that contains a GUIText object, and exposes
--    the GUIText interface at the root level (eg no need to do tt:GetObject():GetText(), can just
--    do tt:GetText())
--
--  Parameters (* = required)
--      cls             Class to instantiate inside this widget.
--  
--  Properties:
--      AutoScroll          -- Whether or not the item automatically scrolls.
--      Scroll              -- The current value of the item's scroll (some value between 0 and X,
--                             where X is the width of the contents that doesn't fit inside the
--                             container).
--      FontFamily          -- Whether or not this object is currently being dragged by the user.
--      FontSize            -- Whether or not this object can be dragged by the user.
--      TextSize            -- Size of the text inside the truncated display.
--
--  Events:
--      OnInternalFontChanged       Fires when the font file used internally (the REAL font file)
--                                  changes.  Typically not necessary except where knowing the
--                                  exact size of a text when rendered is crucial.
--      OnInternalFontScaleChanged  Fires when the scale applied to the internal text object
--                                  changes.  Typically not necessary except where knowing the
--                                  exact size of a text when rendered is crucial.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/GUIText.lua")
Script.Load("lua/menu2/widgets/GUIMenuTruncatedDisplayWidget.lua")
Script.Load("lua/menu2/MenuStyles.lua")

local GetChangedEventNameForProperty = GUIObject._GetChangedEventNameForProperty
local migrateProperties =
{
    "BlendTechnique",
    "ClearsStencilBuffer",
    "Color",
    "Opacity",
    "DropShadowColor",
    "DropShadowEnabled",
    "DropShadowOffset",
    "FontSize",
    "FontFamily",
    "InheritsParentStencilSettings",
    "IsStencil",
    "Shader",
    "SnapsToPixels",
    "StencilFunc",
    "Text",
}
for i=1, #migrateProperties do migrateProperties[migrateProperties[i] ] = i end -- make it a dictionary as well.

---@class GUIMenuTruncatedText : GUIMenuTruncatedDisplayWidget
class "GUIMenuTruncatedText" (GUIMenuTruncatedDisplayWidget)

GUIMenuTruncatedText:AddCompositeClassProperty("TextSize", "obj", "Size")

local function UpdateAutoScrollSpeed(self)
    
    local fontSize = self:GetObject():GetFontSize()
    self:SetAutoScrollSpeed(fontSize * MenuStyle.kTextAutoScrollSpeedMult)
    
end

function GUIMenuTruncatedText:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    -- This class overrides the class parameter
    PushParamChange(params, "opacity", nil)
    PushParamChange(params, "color", nil)
    PushParamChange(params, "cls", params.cls or GUIText)
    GUIMenuTruncatedDisplayWidget.Initialize(self, params, errorDepth)
    PopParamChange(params, "cls")
    PopParamChange(params, "color")
    PopParamChange(params, "opacity")
    
    -- Auto scroll enabled by default.
    self:SetAutoScroll(true)
    
    -- Adjust scroll speed based on FontSize
    self:HookEvent(self, "OnFontSizeChanged", UpdateAutoScrollSpeed)
    UpdateAutoScrollSpeed(self)
    
    -- Forward property change events.
    for i=1, #migrateProperties do
        local propertyName = migrateProperties[i]
        self:ForwardEvent(self:GetObject(), GetChangedEventNameForProperty(propertyName))
    end
    
    self:ForwardEvent(self:GetObject(), GetChangedEventNameForProperty("AutoScroll"))
    self:ForwardEvent(self:GetObject(), GetChangedEventNameForProperty("Scroll"))
    self:ForwardEvent(self:GetObject(), GetChangedEventNameForProperty("FontFamily"))
    self:ForwardEvent(self:GetObject(), GetChangedEventNameForProperty("FontSize"))
    
    self:ForwardEvent(self:GetObject(), "OnInternalFontChanged")
    self:ForwardEvent(self:GetObject(), "OnInternalFontScaleChanged")
    self:ForwardEvent(self:GetObject(), "OnInternalFontScaleChanged")
    
    if params.color then
        self:SetColor(params.color)
    end
    
    if params.opacity then
        self:SetOpacity(params.opacity)
    end
    
end

function GUIMenuTruncatedText:GetVisibleObject()
    return self:GetObject().text
end

-- Returns the size of this object as if the text were changed to the displayed text.  Note that
-- this is not a 100% foolproof method, as setting the text of the object can trigger a font change
-- due to characters not being renderable in the current font.  This font change is _not_ taken
-- into account here for performance reasons.
function GUIMenuTruncatedText:CalculateTextSize(text)
    local result = self:GetObject():CalculateTextSize(text)
    return result
end

function GUIMenuTruncatedText:SetFont(fontFamilyName, localSize)
    local result = self:GetObject():SetFont(fontFamilyName, localSize)
    return result
end

function GUIMenuTruncatedText:ForceUpdateTextSize()
    self:GetObject():ForceUpdateTextSize()
end

-- Re-define many of the properties of this object to map to the properties of the
-- internal text item.
do
    
    local GetGetterNameForProperty = GUIObject._GetGetterNameForProperty
    local GetSetterNameForProperty = GUIObject._GetSetterNameForProperty
    local GetRawSetterNameForProperty = GUIObject._GetRawSetterNameForProperty
    
    for i=1, #migrateProperties do
        local propertyName = migrateProperties[i]
        
        -- Getter
        local getterName = GetGetterNameForProperty(propertyName)
        GUIMenuTruncatedText[getterName] = function(self, static)
            local result = self:GetObject():Get(propertyName, static)
            return result
        end
        
        -- Setter
        local setterName = GetSetterNameForProperty(propertyName)
        GUIMenuTruncatedText[setterName] = function(self, p1, p2, p3, p4)
            local result = self:GetObject():Set(propertyName, p1, p2, p3, p4)
            return result
        end
        
        -- Raw Setter
        local rawSetterName = GetRawSetterNameForProperty(propertyName)
        GUIMenuTruncatedText[rawSetterName] = function(self, p1, p2, p3, p4)
            local result = self:GetObject():RawSet(propertyName, p1, p2, p3, p4)
            return result
        end
        
    end
    
end

function GUIMenuTruncatedText:AnimateProperty(propertyName, value, animationParams, optionalName)
    
    if migrateProperties[propertyName] then
        self:GetObject():AnimateProperty(propertyName, value, animationParams, optionalName)
    else
        GUIObject.AnimateProperty(self, propertyName, value, animationParams, optionalName)
    end
    
end
