-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/GUI/GUIItemExtras.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--    
--    Defines some additional methods for GUIItem to make things more convenient.
--    
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

assert(GUIItem)

---@class GUIItem
---@field public AddChild function
---@field public AddLine function
---@field public ClearCropRectangle function
---@field public ClearLines function
---@field public ClearOptionFlag function
---@field public ForceUpdateTextSize function
---@field public GetAbsoluteScale function
---@field public GetAnchor function
---@field public GetAngle function
---@field public GetBlendTechnique function
---@field public GetCanFontRenderString function
---@field public GetChildren function
---@field public GetClearsStencilBuffer function
---@field public GetColor function
---@field public GetCropMaxCornerNormalized function
---@field public GetCropMinCornerNormalized function
---@field public GetCropRectangle function
---@field public GetCropRectangleNormalized function
---@field public GetDropShadowColor function
---@field public GetDropShadowEnabled function
---@field public GetDropShadowOffset function
---@field public GetFontIsBold function
---@field public GetFontIsItalic function
---@field public GetFontName function
---@field public GetHotSpot function
---@field public GetInheritsParentAlpha function
---@field public GetInheritsParentPosition function
---@field public GetInheritsParentScaling function
---@field public GetInheritsParentStencilSettings function
---@field public GetIsStencil function
---@field public GetIsVisible function
---@field public GetLayer function
---@field public GetNumChildren function
---@field public GetParent function
---@field public GetPixelHotSpot function
---@field public GetPosition function
---@field public GetRotation function
---@field public GetRotationOffset function
---@field public GetRotationOffsetNormalized function
---@field public GetScale function
---@field public GetScaledSize function
---@field public GetScreenPosition function
---@field public GetShader function
---@field public GetSize function
---@field public GetSnapsToPixels function
---@field public GetStencilFunc function
---@field public GetText function
---@field public GetTextAlignmentX function
---@field public GetTextAlignmentY function
---@field public GetTextClipped function
---@field public GetTextHeight function
---@field public GetTextWidth function
---@field public GetTexture function
---@field public GetTextureHeight function
---@field public GetTextureWidth function
---@field public GetWasRenderedLastFrame function
---@field public GetWideText function
---@field public GetXAnchor function
---@field public GetYAnchor function
---@field public IsOptionFlagSet function
---@field public RemoveChild function
---@field public SetAdditionalTexture function
---@field public SetAnchor function
---@field public SetAngle function
---@field public SetBlendTechnique function
---@field public SetClearsStencilBuffer function
---@field public SetColor function
---@field public SetCropMaxCornerNormalized function
---@field public SetCropMinCornerNormalized function
---@field public SetCropRectangle function
---@field public SetCropRectangleNormalized function
---@field public SetDebugName function
---@field public SetDropShadowColor function
---@field public SetDropShadowEnabled function
---@field public SetDropShadowOffset function
---@field public SetFloat2Parameter function
---@field public SetFloat3Parameter function
---@field public SetFloat4Parameter function
---@field public SetFloatParameter function
---@field public SetFontIsBold function
---@field public SetFontIsItalic function
---@field public SetFontName function
---@field public SetFontSize function
---@field public SetHotSpot function
---@field public SetInheritsParentAlpha function
---@field public SetInheritsParentPosition function
---@field public SetInheritsParentScaling function
---@field public SetInheritsParentStencilSettings function
---@field public SetIsStencil function
---@field public SetIsVisible function
---@field public SetLayer function
---@field public SetOptionFlag function
---@field public SetPixelHotSpot function
---@field public SetPosition function
---@field public SetRotation function
---@field public SetRotationOffset function
---@field public SetRotationOffsetNormalized function
---@field public SetScale function
---@field public SetShader function
---@field public SetSize function
---@field public SetSnapsToPixels function
---@field public SetStencilFunc function
---@field public SetText function
---@field public SetTextAlignmentX function
---@field public SetTextAlignmentY function
---@field public SetTextClipped function
---@field public SetTexture function
---@field public SetTextureCoordinates function
---@field public SetTexturePixelCoordinates function
---@field public SetWideText function

g_GUIItemPropertyTypes =
{
    Anchor                          = "Vector",
    Angle                           = "number",
    BlendTechnique                  = "number",
    ClearsStencilBuffer             = "boolean",
    Color                           = "Color",
    CropMax                         = "Vector",
    CropMin                         = "Vector",
    DropShadowColor                 = "Color",
    DropShadowEnabled               = "boolean",
    DropShadowOffset                = "Vector",
    FontName                        = "string",
    HotSpot                         = "Vector",
    InheritsParentAlpha             = "boolean",
    InheritsParentScaling           = "boolean",
    InheritsParentStencilSettings   = "boolean",
    IsStencil                       = "boolean",
    Layer                           = "number",
    Position                        = "Vector",
    RotationOffset                  = "Vector",
    Scale                           = "Vector",
    Shader                          = "string",
    Size                            = "Vector",
    SnapsToPixels                   = "boolean",
    StencilFunc                     = "number",
    Text                            = "string",
    Texture                         = "string",
    Visible                         = "boolean",
}

g_GUIItemPropertyGetters =
{
    Anchor                          = GUIItem.GetAnchor,
    Angle                           = GUIItem.GetAngle,
    BlendTechnique                  = GUIItem.GetBlendTechnique,
    Color                           = GUIItem.GetColor,
    ClearsStencilBuffer             = GUIItem.GetClearsStencilBuffer,
    CropMax                         = GUIItem.GetCropMaxCornerNormalized,
    CropMin                         = GUIItem.GetCropMinCornerNormalized,
    DropShadowColor                 = GUIItem.GetDropShadowColor,
    DropShadowEnabled               = GUIItem.GetDropShadowEnabled,
    DropShadowOffset                = GUIItem.GetDropShadowOffset,
    FontName                        = GUIItem.GetFontName,
    HotSpot                         = GUIItem.GetHotSpot,
    InheritsParentAlpha             = GUIItem.GetInheritsParentAlpha,
    InheritsParentScaling           = GUIItem.GetInheritsParentScaling,
    InheritsParentStencilSettings   = GUIItem.GetInheritsParentStencilSettings,
    InheritsParentPosition          = GUIItem.GetInheritsParentPosition,
    IsStencil                       = GUIItem.GetIsStencil,
    Layer                           = GUIItem.GetLayer,
    Position                        = GUIItem.GetPosition,
    RotationOffset                  = GUIItem.GetRotationOffsetNormalized,
    Scale                           = GUIItem.GetScale,
    Shader                          = GUIItem.GetShader,
    Size                            = GUIItem.GetSize,
    SnapsToPixels                   = GUIItem.GetSnapsToPixels,
    StencilFunc                     = GUIItem.GetStencilFunc,
    Text                            = GUIItem.GetText,
    Texture                         = GUIItem.GetTexture,
    Visible                         = GUIItem.GetIsVisible,
}

g_GUIItemPropertySetters =
{
    Anchor                          = GUIItem.SetAnchor,
    Angle                           = GUIItem.SetAngle,
    BlendTechnique                  = GUIItem.SetBlendTechnique,
    Color                           = GUIItem.SetColor,
    ClearsStencilBuffer             = GUIItem.SetClearsStencilBuffer,
    CropMax                         = GUIItem.SetCropMaxCornerNormalized,
    CropMin                         = GUIItem.SetCropMinCornerNormalized,
    DropShadowColor                 = GUIItem.SetDropShadowColor,
    DropShadowEnabled               = GUIItem.SetDropShadowEnabled,
    DropShadowOffset                = GUIItem.SetDropShadowOffset,
    FontName                        = GUIItem.SetFontName,
    HotSpot                         = GUIItem.SetHotSpot,
    InheritsParentAlpha             = GUIItem.SetInheritsParentAlpha,
    InheritsParentScaling           = GUIItem.SetInheritsParentScaling,
    InheritsParentStencilSettings   = GUIItem.SetInheritsParentStencilSettings,
    InheritsParentPosition          = GUIItem.SetInheritsParentPosition,
    IsStencil                       = GUIItem.SetIsStencil,
    Layer                           = GUIItem.SetLayer,
    Position                        = GUIItem.SetPosition,
    RotationOffset                  = GUIItem.SetRotationOffsetNormalized,
    Scale                           = GUIItem.SetScale,
    Shader                          = GUIItem.SetShader,
    Size                            = GUIItem.SetSize,
    SnapsToPixels                   = GUIItem.SetSnapsToPixels,
    StencilFunc                     = GUIItem.SetStencilFunc,
    Text                            = GUIItem.SetText,
    Texture                         = GUIItem.SetTexture,
    Visible                         = GUIItem.SetIsVisible,
}

function GetIsaGUIItemProperty(propertyName)
    return propertyName ~= nil and g_GUIItemPropertyTypes[propertyName] ~= nil
end

function GetGUIItemPropertyGetter(propertyName)
    return g_GUIItemPropertyGetters[propertyName]
end

function GetGUIItemPropertySetter(propertyName)
    return g_GUIItemPropertySetters[propertyName]
end

Script.Load("lua/GUI/FontGlobals.lua")

-- Speed up isa() for GUIItem.  Don't need the c++ call.  These types have no depth -- no derived
-- members, so a simple string comparison will do.
GUIItem.isa = function(self, className)
    return className == "GUIItem"
end

function ProcessVectorInput(p1, p2, p3)
    
    local value
    if type(p1) == "number" then
        
        -- nan checks.  Nans cause non-deterministic behavior (jit vs interpreter)
        -- just replace nans with 0.
        if p1 ~= p1 then p1 = 0.0 end
        if p2 ~= p2 then p2 = 0.0 end
        if p3 ~= p3 then p3 = 0.0 end
        
        value = Vector(p1, p2, p3 or 0)
    else
        
        -- type check
        assert(type(p1) == "cdata" and assert(p1:isa("Vector")))
        
        -- nan checks.  Nans cause non-deterministic behavior (jit vs interpreter)
        -- just replace nans with 0.
        if p1.x ~= p1.x then p1.x = 0 end
        if p1.y ~= p1.y then p1.y = 0 end
        if p1.z ~= p1.z then p1.z = 0 end
        
        value = Vector(p1)
    end
    
    return value
    
end
local ProcessVectorInput = ProcessVectorInput

function ProcessColorInput(p1, p2, p3, p4)
    
    local value
    if type(p1) == "number" then
        
        -- nan checks.  Nans cause non-deterministic behavior (jit vs interpreter)
        -- just replace nans with 0.
        if p1 ~= p1 then p1 = 0.0 end
        if p2 ~= p2 then p2 = 0.0 end
        if p3 ~= p3 then p3 = 0.0 end
        if p4 ~= p4 then p4 = 0.0 end
        
        value = Color(p1, p2, p3, p4 or 1)
    else
        
        -- type check
        assert(type(p1) == "cdata" and assert(p1:isa("Color")))
        
        -- nan checks.  Nans cause non-deterministic behavior (jit vs interpreter)
        -- just replace nans with 0.
        if p1.r ~= p1.r then p1.r = 0.0 end
        if p1.g ~= p1.g then p1.g = 0.0 end
        if p1.b ~= p1.b then p1.b = 0.0 end
        if p1.a ~= p1.a then p1.a = 0.0 end
        
        value = Color(p1)
    end
    
    return value
    
end
local ProcessColorInput = ProcessColorInput

-- All GUIItem methods that take a Vector only use the x and y values.  Provide overloads that take
-- two numbers instead of a Vector.
do
    local vectorMethods =
    {
        "SetCropMaxCornerNormalized",
        "SetCropMinCornerNormalized",
        "SetDropShadowOffset",
        "SetHotSpot",
        "SetPosition",
        "SetRotationOffset",
        "SetScale",
        "SetSize",
        "SetRotationOffset",
        "SetRotationOffsetNormalized",
    }
    for i=1, #vectorMethods do
        local methodName = vectorMethods[i]
        local oldMethod = GUIItem[methodName]
        assert(oldMethod)
        GUIItem[methodName] = function(self, p1, p2, p3)
            local value = ProcessVectorInput(p1, p2, p3)
            oldMethod(self, value)
        end
    end
end

-- Make a special case for SetAnchor().  We want to allow two floats to be passed in and be
-- automatically combined into a Vector object.  Unfortunately, since lua does not distinguish
-- between floats and ints at this level, this becomes a problem.  Since the old api is
-- SetAnchor(enum int, enum int), we cannot distinguish between calls to the old api overload, and
-- calls to the new function which expects a vector, but we're allowing (float, float, <float>).
-- To get around this, we check to see if this GUIItem is part of the old api or the new api by
-- checking which flags it has set.  We will use GUIItem.CorrectScaling for this, since all
-- GUIItems created with the new system will have this flag set (among others).
local old_GUIItem_SetAnchor = GUIItem.SetAnchor
GUIItem.SetAnchor = function(self, p1, p2, p3)
    
    if self:IsOptionFlagSet(GUIItem.CorrectScaling) then
        -- new api
        local value = ProcessVectorInput(p1, p2, p3)
        old_GUIItem_SetAnchor(self, value)
    else
        -- old api
        old_GUIItem_SetAnchor(self, p1, p2)
    end
    
end

-- Provide overloads for methods that use a Color to accept a few numbers instead of a Color object.
-- Also, make alpha optional (defaults to old value if not provided).
do
    local colorMethods =
    {
        "SetColor",
        "SetDropShadowColor",
    }
    for i=1, #colorMethods do
        local methodName = colorMethods[i]
        local oldMethod = GUIItem[methodName]
        assert(oldMethod)
        GUIItem[methodName] = function(self, p1, p2, p3, p4)
            local value = ProcessColorInput(p1, p2, p3, p4)
            oldMethod(self, value)
        end
    end
end

-- These set hotspot and anchor to the same corner/edge of the object.
-- For example, AlignTop() will make the middle of this object's top edge line up with the middle
-- of its parent's top edge.
GUIItem.AlignTopLeft     = function(self) self:SetAnchor(0.0, 0.0) self:SetHotSpot(0.0, 0.0) end
GUIItem.AlignTop         = function(self) self:SetAnchor(0.5, 0.0) self:SetHotSpot(0.5, 0.0) end
GUIItem.AlignTopRight    = function(self) self:SetAnchor(1.0, 0.0) self:SetHotSpot(1.0, 0.0) end
GUIItem.AlignLeft        = function(self) self:SetAnchor(0.0, 0.5) self:SetHotSpot(0.0, 0.5) end
GUIItem.AlignCenter      = function(self) self:SetAnchor(0.5, 0.5) self:SetHotSpot(0.5, 0.5) end
GUIItem.AlignRight       = function(self) self:SetAnchor(1.0, 0.5) self:SetHotSpot(1.0, 0.5) end
GUIItem.AlignBottomLeft  = function(self) self:SetAnchor(0.0, 1.0) self:SetHotSpot(0.0, 1.0) end
GUIItem.AlignBottom      = function(self) self:SetAnchor(0.5, 1.0) self:SetHotSpot(0.5, 1.0) end
GUIItem.AlignBottomRight = function(self) self:SetAnchor(1.0, 1.0) self:SetHotSpot(1.0, 1.0) end


-- Sets the GUIItem's size to the texture dimensions.  You can optionally provide a (uniform) scale
-- factor.
GUIItem.SetSizeFromTexture = function(self, mult)
    self:SetSize(self:GetTextureWidth() * (mult or 1), self:GetTextureHeight() * (mult or 1))
end

-- Returns the dimensions of this item's texture, in a Vector.
GUIItem.GetTextureSize = function(self)
    local result = Vector(self:GetTextureWidth(), self:GetTextureHeight(), 0)
    return result
end

-- Provide alternate spelling, since the "proper" spelling breaks convention.
GUIItem.SetVisible = GUIItem.SetIsVisible
GUIItem.GetVisible = GUIItem.GetIsVisible

-- Convenience
GUIItem.SetMinCrop = GUIItem.SetCropMinCornerNormalized
GUIItem.SetMaxCrop = GUIItem.SetCropMaxCornerNormalized

-- Sets the font and scale of this GUIItem based on the font family name, the desired size of the
-- font, and the scaling of its parents.  Local scale is assumed to be 1, 1 when calculating the
-- new scale.  Also takes into account if all characters in the text can be rendered by the font,
-- and if not, uses a fallback font instead.
GUIItem.SetFont = function(self, fontFamilyName, localSize)
    
    -- Parameters can optionally be passed in as a table with fields "family" and "size"
    if type(fontFamilyName) == "table" then
        localSize = fontFamilyName.size
        fontFamilyName = fontFamilyName.family
    end
    
    -- Choose the font that is the best size for how big the text will be on screen -- not
    -- necessarily the same as its local size (eg it could have a tiny local size, but be scaled
    -- way up by parents).
    self:SetScale(1, 1)
    local absoluteScale = self:GetAbsoluteScale()
    local absoluteSize = math.min(math.abs(absoluteScale.x) * localSize, math.abs(absoluteScale.y) * localSize)
    local fontFile, fallbackScaling = GetMostSuitableFont(fontFamilyName, self:GetText(), absoluteSize)
    local fontActualSize = GetFontActualSize(fontFile)
    local fontScaleFactor = (localSize / fontActualSize) * fallbackScaling
    self:SetScale(fontScaleFactor.x / absoluteScale.x, fontScaleFactor.y / absoluteScale.y) -- cancel out parent's scale.
    self:SetFontName(fontFile)
    
end

-- Sets the alpha channel component of the GUIItem's color to the specified opacity.
GUIItem.SetOpacity = function(self, opacity)
    local color = Color(self:GetColor())
    color.a = opacity
    self:SetColor(color)
end

-- Returns the size of this GUIItem with absolute scaling applied.
GUIItem.GetAbsoluteSize = function(self)
    local size = self:GetSize()
    local scale = self:GetAbsoluteScale()
    return size * scale
end

-- Automatically fill in the screen width and height if missing.  Allow hot spot to be passed to
-- return some position other than the upper-left corner of the item.
do
    local old_GUIItem_GetScreenPosition = GUIItem.GetScreenPosition
    GUIItem.GetScreenPosition = function(self, screenSizeX, screenSizeY, hotSpot)
        screenSizeX = screenSizeX or Client.GetScreenWidth()
        screenSizeY = screenSizeY or Client.GetScreenHeight()
        local result = old_GUIItem_GetScreenPosition(self, screenSizeX, screenSizeY)
        if hotSpot == nil then
            return result
        else
            local absoluteSize = self:GetAbsoluteSize()
            return result + absoluteSize * hotSpot
        end
    end
end


-- Transform a point from screen space to local space.  Accept either a single Vector, or two numbers.
GUIItem.ScreenSpaceToLocalSpace = function(self, p1, p2)
    local screenPos = self:GetScreenPosition()
    local scale = self:GetAbsoluteScale()
    
    if type(p1) == "number" then
        assert(type(p2) == "number")
        return (p1 - screenPos.x) / scale.x, (p2 - screenPos.y) / scale.y
    else
        return (p1 - screenPos) / scale
    end
    
end

-- Transform a point from local space to screen space.  Accept either a single Vector, or two numbers.
GUIItem.LocalSpaceToScreenSpace = function(self, p1, p2)
    local screenPos = self:GetScreenPosition()
    local scale = self:GetAbsoluteScale()
    
    if type(p1) == "number" then
        assert(type(p2) == "number")
        return p1 * scale.x + screenPos.x, p2 * scale.y + screenPos.y
    else
        return p1 * scale + screenPos
    end
    
end

-- Convenience.  Calls GUI.CalculateTextSize using this GUIItem's font.
GUIItem.CalculateTextSize = function(self, text)
    local result = GUI.CalculateTextSize(self:GetFontName(), text)
    return result
end

GUIItem.GetIsPointOverItem = function(self, p1, p2)
    
    local pt = ProcessVectorInput(p1, p2)
    
    local scale = self:GetAbsoluteScale()
    if scale.x == 0 or scale.y == 0 then
        return false
    end
    
    local localPt = self:ScreenSpaceToLocalSpace(pt)
    local localSize = self:GetSize()
    
    return localPt.x >= 0 and localPt.y >= 0 and localPt.x < localSize.x and localPt.y < localSize.y
    
end

-- Make this item crop children within its bounds. (Sets crop min and max corners to 0, 0, and 1,1
-- respectively).
GUIItem.CropToBounds = function(self)
    self:SetCropMinCornerNormalized(0, 0)
    self:SetCropMaxCornerNormalized(1, 1)
end
