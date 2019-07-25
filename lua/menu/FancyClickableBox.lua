-- ======= Copyright (c) 2017, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\menu\FancyClickableBox.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Concrete type of FancyClickable.  Just a simple AABB.  Also used as a broadphase for the more
--    complex types of clickables.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/menu/FancyClickable.lua")

class 'FancyClickableBox' (FancyClickable)

function FancyClickableBox:Initialize()
    
    FancyClickable.Initialize(self)
    
    -- self.offset + self.position = upper left corner of box, in 1080p pixels
    self.offset = nil
    -- size of the box, in 1920x1080 pixels.
    self.extents = nil
    
    getmetatable(self).__tostring = FancyClickableBox.ToString
    
end

function FancyClickableBox:ToString()
    
    local str = FancyClickable.ToString(self)
    str = str .. string.format("    offset = %s\n    extents = %s\n", self.offset, self.extents)
    return str
    
end

-- setup box by providing position of upper left corner, then size, in 1920x1080-pixels
function FancyClickableBox:SetupBoxUpperLeft(position, size)
    
    self.extents = size
    self.offset = position - self.position
    
end

-- setup box by providing position of center, then size, in 1920x1080-pixels
function FancyClickableBox:SetupBoxCentered(origin, size)
    
    self.offset = (origin - (size * 0.5)) - self.position
    self.extents = size
    
end

function FancyClickableBox:GetIsMouseOver()
    
    if not self.offset or not self.extents then
        return false
    end
    
    local mouseCoords = self:GetVirtualMousePosition()
    
    -- check horizontal
    if mouseCoords.x < 0 or mouseCoords.x > self.extents.x  then
        return false
    end
    
    -- check vertical
    if mouseCoords.y < 0 or mouseCoords.y > self.extents.y then
        return false
    end
    
    return true
    
end