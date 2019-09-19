-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/GUI/utilities/Polygon.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--    
--    Utilities for dealing with arbitrary polygons (eg for non-rectangular buttons).
--    
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

local function TestLineSegment(p, p0, p1)
    
    PROFILE("Polygons:TestLineSegment")
    
    -- Since we're ray-casting to the right, we can early-out if the line segment's bbox isn't to
    -- the right of us, or if the box is fully above or below the point.
    if math.max(p0.x, p1.x) < p.x
    or math.max(p0.y, p1.y) < p.y
    or math.min(p0.y, p1.y) > p.y then
        return false
    end
    
    -- Check for horizontal lines
    local denom = p1.y - p0.y
    if denom == 0 then
        return false -- can't hit a parallel line
    else
        -- Intersect line segment and ensure the hit point is to the right of the test point.
        local fraction = (p.y - p0.y) / denom
        local hitPt = p0 * (1-fraction) + p1 * fraction
        return hitPt.x >= p.x
    end
    
end

-- Returns true if the point lies inside the polygon with vertices given by the list of verts
-- (table of Vectors, don't repeat first point for the last point).
function GetIsPointInPolygon(point, verts)
    
    PROFILE("Polygons:GetIsPointInPolygon")
    
    -- Assume that the bound box has already been tested...
    
    -- Test the polygon.  We assume it is a simple polygon.  It does not need to be convex, but it
    -- shouldn't have crossing edges, double points, or any other weird crap.
    -- We test by casting a +X ray, and if it intersects an even-number of line segments, we know
    -- we're outside the polygon.
    local inside = false
    local prevPt = verts[#verts]
    for i=1, #verts do
        local pt = verts[i]
        if TestLineSegment(point, prevPt, pt) then
            inside = not inside
        end
        prevPt = pt
    end
    
    return inside
    
end