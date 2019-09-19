-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/GUIMenuBasicBox.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--    
--    Basic, stroked-outline box.  The stroke width is specified in screen space pixels.  The
--    "Color" property's RGB values are ignored, and the alpha channel is used for the opacity of
--    the box.
--
--  Properties:
--      FillColor               -- The color of the interior of the box.  This is separate from the
--                                 usual "Color" property so as to allow for the opacity of the
--                                 interior color to be different than the stroke opacity (eg maybe
--                                 you want the interior to be transparent, but with an opaque
--                                 stroke).
--      StrokeColor             -- The color of the stroke effect applied to the outside of the
--                                 box.
--      StrokeWidth             -- The _screen space_ width of the stroke effect.  Screen space is
--                                 used instead of local space for aesthetic reasons.
--    
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/GUIObject.lua")
Script.Load("lua/menu2/MenuStyles.lua")

---@class GUIMenuBasicBox : GUIObject
class "GUIMenuBasicBox" (GUIObject)

GUIMenuBasicBox.kShader = PrecacheAsset("shaders/GUI/menu/outlinedBox.surface_shader")

GUIMenuBasicBox:AddCompositeClassProperty("FillColor", "box", "Color")
GUIMenuBasicBox:AddClassProperty("StrokeWidth", 0)
GUIMenuBasicBox:AddClassProperty("StrokeColor", Color(0, 0, 0, 0))

local function UpdateSize(self)
    
    local surfaceSize = self:GetSize() * self.absScale + Vector(self:GetStrokeWidth(true) + 1, self:GetStrokeWidth(true) + 1, 0) * 2
    self.box:SetFloat2Parameter("surfaceSize", surfaceSize)
    
    local localSize = Vector(0, 0, 0)
    if self.absScale.x ~= 0 then localSize.x = surfaceSize.x / self.absScale.x end
    if self.absScale.y ~= 0 then localSize.y = surfaceSize.y / self.absScale.y end
    
    self.box:SetSize(localSize)
    self.box:SetFloat2Parameter("boxSize", self:GetSize() * self.absScale)
    self.box:SetFloat2Parameter("cornerOffset", Vector(self:GetStrokeWidth(true) + 1, self:GetStrokeWidth(true) + 1, 0))
    
end

local function OnStrokeWidthChanged(self, new, old)
    self.box:SetFloatParameter("strokeWidth", new)
    UpdateSize(self)
end

local function OnOpacityChanged(self, new, old)
    self.box:SetFloatParameter("opacity", self:GetOpacity())
end

local function OnStrokeColorChanged(self, new, old)
    self.box:SetFloat4Parameter("strokeColor", new)
end

local function OnAbsoluteScaleChanged(self, aScale, prevAScale)
    self.absScale = aScale
    UpdateSize(self)
end

function GUIMenuBasicBox:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    PROFILE("GUIMenuBasicBox:Initialize")
    
    GUIObject.Initialize(self, params, errorDepth)
    
    -- Create another item to use to display the actual graphics themselves.  This is necessary
    -- because the box's visuals extend outside its logical size (eg we don't count the outside
    -- stroke effect as part of the box, yet we still need an item big enough to display it).
    self.box = self:CreateGUIItem()
    self.box:SetShader(self.kShader)
    self.box:SetColor(MenuStyle.kBasicBoxBackgroundColor)
    self.box:AlignCenter()
    
    EnableOnAbsoluteScaleChangedEvent(self)
    self.absScale = self:GetAbsoluteScale()
    
    self:HookEvent(self, "OnStrokeColorChanged",        OnStrokeColorChanged)
    self:HookEvent(self, "OnOpacityChanged",            OnOpacityChanged)
    
    self:HookEvent(self, "OnAbsoluteScaleChanged",      OnAbsoluteScaleChanged)
    self:HookEvent(self, "OnStrokeWidthChanged",        OnStrokeWidthChanged)
    
    self:HookEvent(self, "OnSizeChanged",               UpdateSize)
    
    self:SetStrokeColor(MenuStyle.kBasicStrokeColor)
    self:SetStrokeWidth(MenuStyle.kStrokeWidth)
    UpdateSize(self)
    
end

function GUIMenuBasicBox:GetVisibleItem()
    return self.box
end
