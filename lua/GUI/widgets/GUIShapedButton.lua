-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/GUI/widgets/GUIShapedButton.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--    
--    A button whose shape is defined by an arbitrary polygon instead of a rectangle.
--
--  Properties:
--      Enabled             Whether or not the button can be interacted with.
--      MouseOver           Whether or not the mouse is over the button (regardless of
--                          enabled-state).
--      Pressed             Whether or not the button is being pressed in by the mouse.
--      Points              A table that is an array of Vector points that correspond to the
--                          (ordered) points of the polygon.  These points are specified in
--                          parent-local space.  This object's Position and Size will be set to
--                          the bounding box of the points.
--  
--  Events:
--      OnPressed   Whenever the button is pressed and released while enabled.
--    
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/widgets/GUIButton.lua")
Script.Load("lua/GUI/utilities/Polygon.lua")

---@class GUIShapedButton : GUIButton
class "GUIShapedButton" (GUIButton)

GUIShapedButton:AddClassProperty("Points", {}, true)

local function OnPointsChanged(self, points)
    
    assert(#points >= 3)
    
    local boundsMin = Vector(points[1])
    local boundsMax = Vector(points[1])
    
    for i=2, #points do
        boundsMin.x = math.min(boundsMin.x, points[i].x)
        boundsMax.x = math.max(boundsMax.x, points[i].x)
        boundsMin.y = math.min(boundsMin.y, points[i].y)
        boundsMax.y = math.max(boundsMax.y, points[i].y)
    end
    
    local size = boundsMax - boundsMin
    self:SetSize(size)
    self:SetPosition(boundsMin)
    
    self.adjustedPoints = {}
    for i=1, #points do
        table.insert(self.adjustedPoints, points[i] - boundsMin)
    end
    
end

function GUIShapedButton:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    GUIButton.Initialize(self, params, errorDepth)
    
    self:HookEvent(self, "OnPointsChanged", OnPointsChanged)
    
end

function GUIShapedButton:IsPointOverObject(pt)
    if not self.adjustedPoints then
        return false -- points haven't been set yet.
    end
    local localPt = self:ScreenSpaceToLocalSpace(pt)
    local result = GetIsPointInPolygon(localPt, self.adjustedPoints)
    return result
end
