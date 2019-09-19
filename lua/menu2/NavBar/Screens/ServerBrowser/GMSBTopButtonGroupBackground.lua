-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/NavBar/Screens/ServerBrowser/GMSBTopButtonGroupBackground.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    4-sided polygon used as the background of the 4 buttons at the top of the Server Browser.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/GUIObject.lua")
Script.Load("lua/GUI/utilities/Polygon.lua")

---@class GMSBTopButtonGroupBackground : GUIObject
class "GMSBTopButtonGroupBackground" (GUIObject)

GMSBTopButtonGroupBackground:AddClassProperty("Points", {}, true)

local kShader = PrecacheAsset("shaders/GUI/menu/fourGon.surface_shader")

local function UpdateShaderPoints(self)
    local offset = Vector(MenuStyle.kStrokeWidth + 1, MenuStyle.kStrokeWidth + 1, 0)
    for i=1, #self.adjustedPoints do
        self.polygon:SetFloat2Parameter("pt"..tostring(i-1), self.adjustedPoints[i] * self.absScale + offset)
    end
end

local function UpdateSize(self)
    
    local offset = Vector(MenuStyle.kStrokeWidth + 1, MenuStyle.kStrokeWidth + 1, 0)
    local surfaceSize = self:GetSize() * self.absScale + offset * 2
    self.polygon:SetFloat2Parameter("surfaceSize", surfaceSize)
    self.polygon:SetSize(surfaceSize)
    self.polygon:SetPosition(-offset)
    
    UpdateShaderPoints(self)
    
end

local function UpdateOpacity(self)
    self.polygon:SetFloatParameter("opacity", self:GetOpacity())
end

local function OnPointsChanged(self, points)
    
    assert(#points == 4)
    
    local boundsMin = Vector(points[1])
    local boundsMax = Vector(points[1])
    
    for i=2, #points do
        boundsMin.x = math.min(boundsMin.x, points[i].x)
        boundsMax.x = math.max(boundsMax.x, points[i].x)
        boundsMin.y = math.min(boundsMin.y, points[i].y)
        boundsMax.y = math.max(boundsMax.y, points[i].y)
    end
    
    self.adjustedPoints = {}
    for i=1, #points do
        table.insert(self.adjustedPoints, points[i] - boundsMin)
    end
    
    local size = boundsMax - boundsMin
    self:SetSize(size)
    self:SetPosition(boundsMin)
    
    UpdateShaderPoints(self)
    
end

local function OnAbsoluteScaleChanged(self, aScale, prevAScale)
    self.absScale = aScale
    UpdateSize(self)
end

function GMSBTopButtonGroupBackground:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    GUIObject.Initialize(self, params, errorDepth)
    
    self.adjustedPoints = {}
    
    self.polygon = self:CreateGUIItem()
    self.polygon:SetShader(kShader)
    self.polygon:SetFloatParameter("strokeWidth", MenuStyle.kStrokeWidth)
    self.polygon:SetFloat4Parameter("strokeColor", MenuStyle.kServerBrowserTopButtonGroupStrokeColor)
    self.polygon:SetFloat4Parameter("gradColor1", MenuStyle.kServerBrowserBackgroundGradientColor1)
    self.polygon:SetFloat4Parameter("gradColor2", MenuStyle.kServerBrowserBackgroundGradientColor2)
    self.polygon:SetInheritsParentScaling(false)
    
    self:HookEvent(self, "OnPointsChanged", OnPointsChanged)
    self:HookEvent(self, "OnOpacityChanged", UpdateOpacity)
    UpdateOpacity(self)
    
    EnableOnAbsoluteScaleChangedEvent(self)
    self.absScale = self:GetAbsoluteScale()
    self:HookEvent(self, "OnAbsoluteScaleChanged",      OnAbsoluteScaleChanged)
    self:HookEvent(self, "OnSizeChanged", UpdateSize)
    
end
