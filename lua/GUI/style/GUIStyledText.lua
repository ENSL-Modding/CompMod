-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/GUI/style/GUIStyledText.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    A GUIObject used for displaying text with one or more photoshop-like layer-style effects applied
--    to it.
--
--  Parameters (* = required)
--      style
--      font
--
--  Properties
--      Style       The style configuration table applied to the text.
--  
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/GUIObject.lua")
Script.Load("lua/GUI/GUIUtils.lua")

-- Keep track of all objects using text styling.
local styledTextObjects = UnorderedSet()

---@class GUIStyledText : GUIObject
class 'GUIStyledText' (GUIObject)

-- Multiply font render resolution by this amount to make result cleaner.
local kSuperSampleFactor = 2.0

GUIStyledText:AddClassProperty("Style", {empty=true}, true)

local function MarkRenderDirty(self)
    self.renderDirty = true
end

function GUIStyledText:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    RequireType({"Color", "nil"}, params.color, "params.color", errorDepth)
    RequireType({"number", "nil"}, params.opacity, "params.opacity", errorDepth)
    RequireType({"table", "nil"}, params.style, "params.style", errorDepth)
    RequireType({"table", "nil"}, params.font, "params.font", errorDepth)
    
    -- Don't let GUIObject set color or opacity.  We'll handle that ourselves later.
    PushParamChange(params, "color", nil)
    PushParamChange(params, "opacity", nil)
    GUIObject.Initialize(self, params, errorDepth)
    PopParamChange(params, "opacity")
    PopParamChange(params, "color")
    
    -- Use a separate graphic object so we can use SetVisible on this object.
    self.graphic = self:CreateGUIItem()
    self.graphic:SetColor(1, 1, 1, 1)
    self.graphic:SetBlendTechnique(GUIItem.Premultiplied)
    self.graphic:SetVisible(false) -- hide until rendering is done.
    
    styledTextObjects:Add(self)
    
    self:HookEvent(self, "OnStyleChanged", MarkRenderDirty)
    self:HookEvent(self, "OnTextChanged", MarkRenderDirty)
    
    MarkRenderDirty(self)
    
    if params.color then
        self:SetColor(params.color)
    end
    
    if params.opacity then
        self:SetOpacity(params.opacity)
    end
    
    if params.style then
        self:SetStyle(params.style)
    end
    
    if params.font then
        self:SetFont(params.font)
    end
    
end

function GUIStyledText:Uninitialize()
    self:ClearRenderNodes()
    styledTextObjects:RemoveElement(self)
end

-- Removes all render nodes, and destroys their GUIViews.
function GUIStyledText:ClearRenderNodes()
    if self.rootNode then
        self.rootNode:ClearAll()
        self.rootNode = nil
    end
end

function GUIStyledText:SetFont(fontFamilyName, localSize)
    
    if type(fontFamilyName) == "table" then
        localSize = fontFamilyName.size
        fontFamilyName = fontFamilyName.family
    end
    
    assert(type(fontFamilyName) == "string")
    assert(type(localSize) == "number")
    
    self.fontFamily = fontFamilyName
    self.fontSize = localSize
    
    MarkRenderDirty(self)
    
end

function GUIStyledText:UpdateRealFont()
    
    if self:GetText() == "" or not self.fontFamily or not self.fontSize then
        return false -- not all information received yet.
    end
    
    self:SetScale(1, 1)
    
    -- Accumulated scaling of all ancestors.  The screen-space scale of this guiitem as though it
    -- had no ancestors.
    local absoluteScale = self.rootItem:GetAbsoluteScale()
    
    -- The font size this font will _appear_ after the absolute scale is applied.  Since font sizes
    -- are uniformly scaled (no squashed pre-rendered fonts, sorry!), we need to pick one scale
    -- for the font size.  We pick the minimum of the x and y scales since it is easier to fight
    -- blurriness with our crispy font shader, than it is to fight minification aliasing.  Keep the
    -- 2d scaling value though, as we want to preserve the non-uniform scaling of the text for when
    -- we render it.
    local absoluteFontSize2D = Vector(math.abs(absoluteScale.x), math.abs(absoluteScale.y), 0) * self.fontSize
    local absoluteFontSize = math.min(absoluteFontSize2D.x, absoluteFontSize2D.y)
    
    -- Pick the font file closest to this font size.  Also take into account the text that will be
    -- rendered (so we only pick fonts that can render all the needed glyphs).
    local fontFile, fallbackScaling = GetMostSuitableFont(self.fontFamily, self:GetText(), absoluteFontSize)
    
    -- Get the _actual_ size of this font, so we can figure out how much we need to scale it to get
    -- it to match the desired "absolute" font size above.
    local fontActualSize = GetFontActualSize(fontFile)
    
    -- Figure out the scaling factor for making the picked font file appear the desired size.
    local fontActualToDesiredScaleFactor = (absoluteFontSize / fontActualSize) * fallbackScaling;
    
    -- Scale this object such that it will cancel-out its ancestors' scaling, so the font displays
    -- in the rendered image at the correct size.
    self:SetScale(1.0 / (absoluteScale.x * kSuperSampleFactor), 1.0 / (absoluteScale.y * kSuperSampleFactor))
    
    self.fontFile = fontFile
    self.fontScale = fontActualToDesiredScaleFactor
    self.renderScale = kSuperSampleFactor * (absoluteFontSize2D / absoluteFontSize)
    
    return true
    
end

function GUIStyledText:UpdateFontRendering()
    
    PROFILE("GUIStyledText:UpdateFontRendering")
    
    if not self.renderDirty then
        return -- no need to update, nothing was changed.
    end
    
    local style = self:GetStyle()
    
    -- If no style is specified or the font settings aren't ready, stop now.
    if style.empty or not self:UpdateRealFont() then
        self:ClearRenderNodes()
        return -- no style specified, cannot render.
    end
    
    self.renderDirty = false
    
    self:ClearRenderNodes()
    local size
    self.rootNode, size = GUIStyle.ApplyToText(self:GetStyle(), self:GetText(), self.fontFile, self.fontScale, self.renderScale)
    
    self:SetSize(size)
    
    self.graphic:SetSize(size)
    self.graphic:SetTexture(self.rootNode:GetTargetTextureName())
    self.graphic:SetVisible(false)
    
end

-- Render any un-rendered nodes with up-to-date dependencies.
function GUIStyledText:UpdateRenderTasks()
    
    self:UpdateFontRendering()
    
    if not self.rootNode then
        self.graphic:SetVisible(false)
        return
    end
    
    self.rootNode:Update()
    
    self.graphic:SetVisible(self.rootNode:GetIsDoneRendering())
    
end

-- Re-define many of the fake properties of this object to map to the fake properties of the
-- internal graphic item.
do
    
    local GetGetterNameForProperty = GUIObject._GetGetterNameForProperty
    local GetSetterNameForProperty = GUIObject._GetSetterNameForProperty
    local GetRawSetterNameForProperty = GUIObject._GetRawSetterNameForProperty
    local PerformGetterDuties = GUIObject._PerformGetterDuties
    
    local GUIStyledTextCustomGetter = function(self, propertyName)
        local fakePropertyData = g_GUIItemFakeProperties[propertyName]
        assert(fakePropertyData ~= nil)
        local result = fakePropertyData.getter(self.graphic)
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
        "Shader",
        "SnapsToPixels",
        "StencilFunc",
    }
    for i=1, #migrateProperties do
        local propertyName = migrateProperties[i]
        local fakePropertyData = g_GUIItemFakeProperties[propertyName]
        assert(fakePropertyData)
        
        -- Getter
        local getterName = GetGetterNameForProperty(propertyName)
        GUIStyledText[getterName] = function(self, static)
            local result = PerformGetterDuties(self, propertyName, static, GUIStyledTextCustomGetter)
            return result
        end
        
        -- Setter
        local setterName = GetSetterNameForProperty(propertyName)
        GUIStyledText[setterName] = GUIObject.GetAutoGeneratedSetter(propertyName, fakePropertyData.type, "graphic")
        
        -- Raw Setter
        local rawSetterName = GetRawSetterNameForProperty(propertyName)
        GUIStyledText[rawSetterName] = GUIObject.GetAutoGeneratedRawSetter(propertyName, fakePropertyData.type, "graphic")
        
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
        self.graphic:SetColor(result)
    end
    local colorSetterFuncActual = function(self, propertyName, value)
        self[colorFieldName] = Copy(value)
        sharedItemColorSetterFunc(self)
    end
    local opacitySetterFuncActual = function(self, propertyName, value)
        self[opacityFieldName] = Copy(value)
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
    GUIStyledText[colorSetterName] = colorSetter
    GUIStyledText[opacitySetterName] = opacitySetter
end

function GUIStyledText:SetFloatParameter(...)
    self.graphic:SetFloatParameter(...)
end

function GUIStyledText:SetFloatParameter2(...)
    self.graphic:SetFloat2Parameter(...)
end

function GUIStyledText:SetFloat3Parameter(...)
    self.graphic:SetFloat3Parameter(...)
end

function GUIStyledText:SetFloat4Parameter(...)
    self.graphic:SetFloat4Parameter(...)
end

-- TODO should probably stick this into a manager class... GUIStyledTextManager...
Event.Hook("UpdateClient",
function()
    for i=1, #styledTextObjects do
        styledTextObjects[i]:UpdateRenderTasks()
    end
end, "GUIStyledText")

Event.Hook("Console_re_render_gui_styled_text",
function()
    for i=1, #styledTextObjects do
        MarkRenderDirty(styledTextObjects[i])
    end
end)
