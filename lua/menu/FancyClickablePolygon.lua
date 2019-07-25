-- ======= Copyright (c) 2017, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\menu\FancyClickablePolygon.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Concrete type of FancyClickable.  Simple polygon shape, no holes... though this functionality
--    could be easily added later if really necessary.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/menu/FancyClickable.lua")

class 'FancyClickablePolygon' (FancyClickable)

function FancyClickablePolygon:Initialize()
    
    FancyClickable.Initialize(self)
    
    self.points = {}
    self.fastBox = nil
    
    getmetatable(self).__tostring = FancyClickablePolygon.ToString
    
end

function FancyClickablePolygon:ToString()
    
    local str = FancyClickable.ToString(self)
    str = str .. string.format("    points = %s\n    fastBox = %s\n", ToString(self.points), ToString(self.fastBox))
    return str
    
end

-- Accepts a table of vectors.  To be valid, it must have at least 3 points.
function FancyClickablePolygon:SetupPolygon(pointList)
    
    if not pointList then
        Log("WARNING: Attempted to call FancyClickablePolygon:SetupPolygon() with nil")
        Log("%s", debug.traceback())
        return
    end
    
    if #pointList < 3 then
        Log("WARNING: Attempted to call FancyClickablePolygon:SetupPolygon() with fewer than 3 vertices.")
        Log("%s", debug.traceback())
        return
    end
    
    self.points = pointList
    
    -- calculate the bounding box and use this as a fast early-out.
    local bMin = pointList[1] * 1.0 -- copy via mult
    local bMax = pointList[1] * 1.0
    for i=2, #pointList do
        bMin.x = math.min(bMin.x, pointList[i].x)
        bMin.y = math.min(bMin.y, pointList[i].y)
        bMax.x = math.max(bMax.x, pointList[i].x)
        bMax.y = math.max(bMax.y, pointList[i].y)
    end
    
    self.fastBox = {}
    self.fastBox.bMin = bMin
    self.fastBox.bMax = bMax
    
end

-- Returns true if the vertical (upwards) ray cast from the mouse position m intersects the line
-- segment formed by points p0 and p1.
local function RayIntersectLineSegment(m, p0, p1)
    
    -- first, early out if the point lies outside the bounding box of the two points of the
    -- line segment.
    if m.x < math.min(p0.x, p1.x) then
        return false
    end
    
    if m.x > math.max(p0.x, p1.x) then
        return false
    end
    
    if m.y < math.min(p0.y, p1.y) then
        return false
    end
    
    -- find the exact point of intersection
    local denom = p1.x - p0.x
    if denom == 0 then
        -- if the edge is perfectly vertical, there can be no intersection.
        return false
    end
    
    local fraction = (m.x - p0.x) / denom
    local hitPt = p0 * (1.0 - fraction) + p1 * fraction
    
    if hitPt.y > m.y then
        return false
    end
    
    return true
    
end

function FancyClickablePolygon:GetIsMouseOver()
    
    if not self.fastBox then
        -- if self.fastBox is nil, this indicates it has never been setup with a proper polygon.
        return false
    end
    
    -- get the mouse coordinates, relative to the clickable's location/scale
    local mouseCoords = self:GetVirtualMousePosition()
    
    if mouseCoords.x < self.fastBox.bMin.x
    or mouseCoords.x > self.fastBox.bMax.x
    or mouseCoords.y < self.fastBox.bMin.y
    or mouseCoords.y > self.fastBox.bMax.y then
        -- outside bounding box of polygon.
        return false
    end
    
    -- trace a ray from the mouse location upwards, and count the number of lines it intersects
    -- with.
    local numHits = 0
    for i=1, #self.points do
        local pt = self.points[i]
        local nextPt = self.points[(i % #self.points) + 1]
        if RayIntersectLineSegment(mouseCoords, pt, nextPt) then
            numHits = numHits + 1
        end
    end
    
    -- point hit even number of edges, it must be outside the polygon.
    if numHits % 2 == 0 then
        return false
    end
    
    return true
    
end


