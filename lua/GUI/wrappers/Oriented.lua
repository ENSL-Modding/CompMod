-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. ============
--
-- lua/GUI/wrappers/Oriented.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Class wrapper used in widgets that have an explicit "horizontal" or "vertical" orientation.
--    This allows us to create horizontal and vertical variants of classes without having to
--    duplicate a large amount of code just for very small changes (eg using .x for horizontal
--    and .y for vertical).  In other words, this interface makes it very easy to generalize code
--    for both orientations.
--
--  Parameters (* = required)
--     *orientation         The orientation of the layout.  Expects either "horizontal" or
--                          "vertical".
--
--  Methods Added
--      GetMajorAxis    Returns a vector pointing in the direction of this widget's orientation.
--                      Ex. A vertical list layout will have a major axis pointing down (0, 1).
--      GetMinorAxis    Returns a vector pointing in the direction perpendicular to this widget's
--                      orientation.  Ex.  A vertical list layout will have a minor axis pointing
--                      right (1, 0).
--      GetOrientation  Returns the orientation of this widget.
--  
-- ========= For more information, visit us at http://www.unknownworlds.com =======================

-- Annotations (copy+paste under @class where this wrapper is used).
--[===[
---@field public GetMajorAxis function @From Oriented wrapper
---@field public GetMinorAxis function @From Oriented wrapper
---@field public GetOrientation function @From Oriented wrapper
--]===]

Script.Load("lua/GUI/wrappers/WrapperUtility.lua")

-- Define our own 2d-variant of the dot product here, to ignore the 3rd component that the built-in
-- Vector.DotProduct() function uses.  Quite often when dealing with GUI stuff, the 3rd component
-- will become nan, which causes any dot product calculations to return nan (even if the other
-- component is 0).
function Dot2D(a, b)
    return a.x * b.x + a.y * b.y
end

local kValidOrientations = { "horizontal", "vertical", }
for i=1, #kValidOrientations do kValidOrientations[kValidOrientations[i]]=i end -- make dict
local kValidOrientationsDesc = table.concat(kValidOrientations, ", ")

local kMajorAxes =
{
    horizontal = Vector(1, 0, 0),
    vertical = Vector(0, 1, 0),
}

local kMinorAxes =
{
    horizontal = Vector(0, 1, 0),
    vertical = Vector(1, 0, 0),
}

local function OrientedWrapped_GetMajorAxis(self)
    local axis = kMajorAxes[self.orientation]
    assert(axis)
    return axis
end

local function OrientedWrapped_GetMinorAxis(self)
    local axis = kMinorAxes[self.orientation]
    assert(axis)
    return axis
end

local function OrientedWrapped_GetOrientation(self)
    return self.orientation
end

-- Associate an orientation with a class (eg list layouts can be horizontal or vertical).
DefineClassWrapper
{
    name = "Oriented",
    classBuilderFunc = function(wrappedClass, baseClass)
        wrappedClass.Initialize = GetCachedExtendedMethod("Initialize", wrappedClass, baseClass,
        function(newClass, oldClass)
            
            -- Oriented Initialize()
            return function(self, params, errorDepth)
                errorDepth = (errorDepth or 1) + 1
                
                RequireType("string", params.orientation, "params.orientation", errorDepth)
                if not kValidOrientations[params.orientation] then
                    error(string.format("Unrecognized orientation!  Got '%s', expected one of '%s'", params.orientation, kValidOrientationsDesc), errorDepth)
                end
                
                self.orientation = params.orientation
                
                oldClass.Initialize(self, params, errorDepth)
                
            end
        end)
        
        wrappedClass.GetMajorAxis = OrientedWrapped_GetMajorAxis
        wrappedClass.GetMinorAxis = OrientedWrapped_GetMinorAxis
        wrappedClass.GetOrientation = OrientedWrapped_GetOrientation
        
    end,
}
