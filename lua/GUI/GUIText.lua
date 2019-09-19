-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/GUI/GUIText.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    A GUIObject used for displaying text.  The text will automatically scale and change the font
--    file according to the desired font size and font family, while attempting to maintain the
--    best quality.
--  
--  Parameters (* = required)
--      font
--      fontFamily (only if font not defined)
--      fontSize (only if font not defined)
--      text
--  
--  Properties:
--      FontFamily      Whether or not this object is currently being dragged by the user.
--      FontSize        Whether or not this object can be dragged by the user.
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

Script.Load("lua/GUI/GUIObject.lua")
Script.Load("lua/GUI/FontGlobals.lua")

gGUIItemMaxCharacters = 511 -- hardcoded in the engine.

---@class GUIText : GUIObject
class "GUIText" (GUIObject)

local kNonDistanceFieldShader = PrecacheAsset("shaders/GUIBasic.surface_shader")
local kDistanceFieldShader = PrecacheAsset("shaders/DistanceFieldFont.surface_shader")

GUIText:AddClassProperty("FontFamily", FontGlobals.kDefaultFontFamily)
GUIText:AddClassProperty("FontSize", FontGlobals.kDefaultFontSize)
local function CalculateStaticAbsoluteScale(self)
    
    local currentScale = Vector(1, 1, 1)
    local currentObj = self
    
    while currentObj and currentScale.x ~= 0 and currentScale.y ~= 0 do
        currentScale = currentScale * currentObj:GetScale(true)
        currentObj = currentObj:GetParent(true)
    end
    
    return currentScale
    
end

-- Transpose the size of the text item if the angle is closest to one of the vertical axes (angle =
-- 0 or pi corresponds to regular orientation).
local function GetShouldTransposeSize(angle)
    local test = (angle - (math.pi * 0.25)) / math.pi
    test = test - math.floor(test)
    return test < 0.5
end

local function UpdateSizeFromText(self)
    
    self.text:ForceUpdateTextSize()
    
    local size = self.text:GetSize() * self.text:GetScale()
    if GetShouldTransposeSize(self:GetAngle()) then
        size.x, size.y = size.y, size.x
    end
    
    self:SetSize(size)
    
    -- Check if string is too long.  Yes, this is technically not correct as it isn't taking into
    -- account non ASCII characters' taking up more than one byte... but computing this would be a
    -- bit expensive (converting string to UTF-8 representation).
    local text = self:GetText()
    if #text > gGUIItemMaxCharacters then
        Log("WARNING: String '%s...%s' contains more than %s characters.  Only %s characters can be rendered with a single GUIItem!", string.sub(text, 1, 20), string.sub(text, #text - 19, #text), gGUIItemMaxCharacters, gGUIItemMaxCharacters)
    end
    
end

local function UpdateFontSize(self, forcedUpdate)
    
    -- To prevent an issue where the font size changes in the middle of an animation, we only ever
    -- update the font size when the scale is not animating, or if the scale is animating to a
    -- bigger value.
    local staticAbsoluteScale = CalculateStaticAbsoluteScale(self)
    local dynamicAbsoluteScale = self.currentAbsoluteScale
    
    local localFontSize = self:GetFontSize(true)
    
    local staticFontSize = math.min(math.abs(staticAbsoluteScale.x * localFontSize),
                                    math.abs(staticAbsoluteScale.y * localFontSize))
    local dynamicFontSize = math.min(math.abs(dynamicAbsoluteScale.x * localFontSize),
                                     math.abs(dynamicAbsoluteScale.y * localFontSize))
    
    if not forcedUpdate and dynamicFontSize > staticFontSize then
        -- Font size is animating to a smaller value.  Don't do anything.
        return
    end
    
    local fontFile, fallbackScaling = GetMostSuitableFont(self:GetFontFamily(), self:GetText(), staticFontSize)
    local fontActualSize = GetFontActualSize(fontFile)
    local fontScaleFactor = (staticFontSize / fontActualSize) * fallbackScaling
    
    local oldScale = self.text:GetScale()
    
    -- Cancel out parent's scale.
    if staticAbsoluteScale.x == 0 or staticAbsoluteScale.y == 0 then
        -- Will be hidden by some ancestor's 0-scale anyways... avoid the divide-by-zero.
        self.text:SetScale(0, 0)
    else
        self.text:SetScale(fontScaleFactor.x / staticAbsoluteScale.x, fontScaleFactor.y / staticAbsoluteScale.y)
    end
    
    -- Set the shader accordingly (only set it if it actually changed... setting it to the same
    -- value actually does bring along a 1-frame load lag, so avoid setting shader unnecessarily).
    local useDistanceField = GetFontFileUsesDistanceField(fontFile)
    if useDistanceField then
        if not self.wasUsingDistanceField then
            self.text:SetShader(kDistanceFieldShader)
            -- Inform the engine, so it can calculate and supply the "smoothing" material parameter.
            -- (we could do this in Lua-scope, but it'd be much more efficient to just make the engine
            -- handle it).
            self.text:SetOptionFlag(GUIItem.DistanceFieldFont)
        end
        self.wasUsingDistanceField = true
    else
        if self.wasUsingDistanceField then
            self.text:SetShader(kNonDistanceFieldShader)
            self.text:ClearOptionFlag(GUIItem.DistanceFieldFont)
        end
        self.wasUsingDistanceField = false
    end
    
    local newScale = self.text:GetScale()
    if oldScale.x ~= newScale.x or oldScale.y ~= newScale.y then
        self:FireEvent("OnInternalFontScaleChanged", newScale, oldScale)
    end
    
    local oldFontFile = self.text:GetFontName()
    self.text:SetFontName(fontFile)
    local newFontFile = fontFile
    if oldFontFile ~= newFontFile then
        self:FireEvent("OnInternalFontChanged", newFontFile, oldFontFile)
    end
    
    -- Set the size of the parent object to the size of the text.
    UpdateSizeFromText(self)
    
end

local function OnAbsoluteScaleChanged(self, scale, prevScale)
    
    self.currentAbsoluteScale = scale
    UpdateFontSize(self)
    
end

local function ForceUpdateFontSize(self)
    -- Forces font to update, regardless of scaling animation.  This is used whenever something
    -- other than scale is triggering the update (eg changing font family, font size, or text).
    UpdateFontSize(self, true)
end

local function OnTextChanged(self, text)
    
    self.text:SetText(text)
    ForceUpdateFontSize(self)
    
end

local function UpdateAngle(self)
    UpdateSizeFromText(self)
    self.text:SetAngle(self:GetAngle())
end

function GUIText:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    -- Allow text to be specified.
    RequireType({"string", "nil"}, params.text, "params.text", errorDepth)
    
    -- Allow font to be specified (table w/ family and size fields).
    RequireType({"table", "nil"}, params.font, "params.font", errorDepth)
    if params.font then
        RequireType("string", params.font.family, "params.font.family", errorDepth)
        RequireType("number", params.font.size, "params.font.size", errorDepth)
    end
    
    -- Allow font family to be specified.
    RequireType({"string", "nil"}, params.fontFamily, "params.fontFamily", errorDepth)
    
    -- Allow font size to be specified.
    RequireType({"number", "nil"}, params.fontSize, "params.fontSize", errorDepth)
    
    RequireType({"Color", "nil"}, params.color, "params.color", errorDepth)
    RequireType({"number", "nil"}, params.opacity, "params.opacity", errorDepth)
    
    -- Don't let GUIObject set color or opacity.  We'll handle that ourselves later.
    PushParamChange(params, "color", nil)
    PushParamChange(params, "opacity", nil)
    PushParamChange(params, "angle", nil)
    PushParamChange(params, "rotationOffset", nil)
    GUIObject.Initialize(self, params, errorDepth)
    PopParamChange(params, "rotationOffset")
    PopParamChange(params, "angle")
    PopParamChange(params, "opacity")
    PopParamChange(params, "color")
    
    self.text = self:CreateTextGUIItem()
    self.text:SetSnapsToPixels(false)
    self.text:AlignCenter()
    
    EnableOnAbsoluteScaleChangedEvent(self)
    self.currentAbsoluteScale = Vector(1, 1, 1)
    self:HookEvent(self, "OnAbsoluteScaleChanged", OnAbsoluteScaleChanged)
    
    self:HookEvent(self, "OnTextChanged", OnTextChanged)
    self:HookEvent(self, "OnFontSizeChanged", ForceUpdateFontSize)
    self:HookEvent(self, "OnFontFamilyChanged", ForceUpdateFontSize)
    self:HookEvent(self, "OnAngleChanged", UpdateAngle)
    
    if params.text then
        self:SetText(params.text)
    end
    
    if params.font then
        self:SetFont(params.font)
    else
        if params.fontFamily then
            self:SetFontFamily(params.fontFamily)
        end
        if params.fontSize then
            self:SetFontSize(params.fontSize)
        end
    end
    
    if params.color then
        self:SetColor(params.color)
    end
    
    if params.opacity then
        self:SetOpacity(params.opacity)
    end
    
    if params.angle then
        self:SetAngle(params.angle)
    end
    
    if params.rotationOffset then
        self:SetRotationOffset(params.rotationOffset)
    end
    
end

-- Returns the size of this object as if the text were changed to the displayed text.  Note that
-- this is not a 100% foolproof method, as setting the text of the object can trigger a font change
-- due to characters not being renderable in the current font.  This font change is _not_ taken
-- into account here for performance reasons.
function GUIText:CalculateTextSize(text)
    return self.text:CalculateTextSize(text) * self.text:GetScale()
end

function GUIText:SetFont(fontFamilyName, localSize)
    
    -- Parameters can optionally be passed in as a table with fields "family" and "size"
    if type(fontFamilyName) == "table" then
        localSize = fontFamilyName.size
        fontFamilyName = fontFamilyName.family
    end
    
    self:SetFontFamily(fontFamilyName)
    self:SetFontSize(localSize)
end

function GUIText:ForceUpdateTextSize()
    UpdateSizeFromText(self)
end

-- Re-define many of the fake properties of this object to map to the fake properties of the
-- internal text item.
do
    
    local GetGetterNameForProperty = GUIObject._GetGetterNameForProperty
    local GetSetterNameForProperty = GUIObject._GetSetterNameForProperty
    local GetRawSetterNameForProperty = GUIObject._GetRawSetterNameForProperty
    local PerformGetterDuties = GUIObject._PerformGetterDuties
    
    local GUITextCustomGetter = function(self, propertyName)
        local fakePropertyData = g_GUIItemFakeProperties[propertyName]
        assert(fakePropertyData ~= nil)
        local result = fakePropertyData.getter(self.text)
        return result
    end
    
    local migrateProperties =
    {
        "BlendTechnique",
        "ClearsStencilBuffer",
        "DropShadowColor",
        "DropShadowEnabled",
        "DropShadowOffset",
        "FontName",
        "InheritsParentStencilSettings",
        "IsStencil",
        "RotationOffset",
        --"Shader",
        "SnapsToPixels",
        "StencilFunc",
    }
    for i=1, #migrateProperties do
        local propertyName = migrateProperties[i]
        local fakePropertyData = g_GUIItemFakeProperties[propertyName]
        assert(fakePropertyData)
        
        -- Getter
        local getterName = GetGetterNameForProperty(propertyName)
        GUIText[getterName] = function(self, static)
            local result = PerformGetterDuties(self, propertyName, static, GUITextCustomGetter)
            return result
        end
        
        -- Setter
        local setterName = GetSetterNameForProperty(propertyName)
        GUIText[setterName] = GUIObject.GetAutoGeneratedSetter(propertyName, fakePropertyData.type, "text")
        
        -- Raw Setter
        local rawSetterName = GetRawSetterNameForProperty(propertyName)
        GUIText[rawSetterName] = GUIObject.GetAutoGeneratedRawSetter(propertyName, fakePropertyData.type, "text")
        
    end
    
end

-- Re-define the opacity and color setters.
do
    local colorSetterName = GUIObject._GetSetterNameForProperty("Color")
    local opacitySetterName = GUIObject._GetSetterNameForProperty("Opacity")
    local colorFieldName = GUIObject._GetInstancePropertyFieldName("Color")
    local opacityFieldName = GUIObject._GetInstancePropertyFieldName("Opacity")
    local sharedItemColorSetterFunc = function(self)
        local opacity = self:GetOpacity()
        local color = self:GetColor()
        local result = color * Color(1, 1, 1, opacity)
        self.text:SetColor(result)
    end
    local colorSetterFuncActual = function(self, propertyName, value)
        self[colorFieldName] = Copy(value)
        sharedItemColorSetterFunc(self)
    end
    local opacitySetterFuncActual = function(self, propertyName, value)
        self[opacityFieldName] = value
        sharedItemColorSetterFunc(self)
    end
    local colorSetter = function(self, p1, p2, p3, p4)
        local value = ProcessColorInput(p1, p2, p3, p4)
        local result = GUIObject._PerformSetterDuties(self, "Color", value, colorSetterFuncActual)
        return result
    end
    local opacitySetter = function(self, value)
        local result = GUIObject._PerformSetterDuties(self, "Opacity", value, opacitySetterFuncActual)
        return result
    end
    GUIText[colorSetterName] = colorSetter
    GUIText[opacitySetterName] = opacitySetter
end
