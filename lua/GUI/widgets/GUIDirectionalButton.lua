-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/GUI/widgets/GUIDirectionalButton.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    GUIButton with an additional "Direction" property, that can be used to point in 4 different
--    directions.  This is used for scroll bars and slider bars (but not restricted to them).
--@class GUIDirectionalButton : GUIButton
--  
--  Parameters (* = required)
--      direction       Either an integer 0..3 or "Left", "Right", "Up", or "Down"
--      orientation     (if direction not specifiec), either "horizontal" or "vertical".
--  
--  Properties:
--      Enabled     Whether or not the button can be interacted with.
--      MouseOver   Whether or not the mouse is over the button (regardless of enabled-state).
--      Pressed     Whether or not the button is being pressed in by the mouse.
--      Direction   The direction the button points.
--  
--  Events:
--      OnPressed   Whenever the button is pressed and released while enabled.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/widgets/GUIButton.lua")

---@class GUIDirectionalButton : GUIButton
local baseClass = GUIButton
class "GUIDirectionalButton" (baseClass)

-- Which direction the button is pointing.  Available directions are dependent upon the derived
-- classes, however keep in mind that scroll bars and sliders depend on, at a minumum, having
-- "Left", "Right", "Up", and "Down".
GUIDirectionalButton:AddClassProperty("Direction", "Right")

local kDirections = 
{
    [0] = "Right",
    [1] = "Up",
    [2] = "Left",
    [3] = "Down",
}
for i=0, #kDirections do
    kDirections[kDirections[i]] = i
end

function GUIDirectionalButton:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    baseClass.Initialize(self, params, errorDepth)
    
    RequireType({"number", "string", "nil"}, params.direction, "params.direction", errorDepth)
    RequireType({"string", "nil"}, params.orientation, "params.orientation", errorDepth)
    
    if params.direction then
        if kDirections[params.direction] == nil then
            error(string.format("Expected a direction index (0..3) or direction name (Left, Right, Up, Down), got %s instead.", params.direction), errorDepth)
        end
        if type(params.direction) == "number" then
            self:SetDirection(kDirections[params.direction])
        else
            self:SetDirection(params.direction)
        end
    elseif params.orientation == "horizontal" then
        self:SetDirection("Right")
    elseif params.orientation == "vertical" then
        self:SetDirection("Down")
    end
    
end

function GUIDirectionalButton:Flip()
    self:SetDirection(self.IndexToDirection((self.DirectionToIndex(self:GetDirection()) + 2) % 4))
end

function GUIDirectionalButton.IndexToDirection(index)
    return kDirections[index]
end

function GUIDirectionalButton.DirectionToIndex(direction)
    return kDirections[direction] or 0.5 -- 45 degrees to indicate an error.
end

function GUIDirectionalButton.DirectionIndexToAngle(directionIdx)
    return directionIdx * math.pi * 0.5
end
