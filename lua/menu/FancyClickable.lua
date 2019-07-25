-- ======= Copyright (c) 2017, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\menu\FancyClickable.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Abstract type for FancyButton mouse detection.  Essentially an invisible shape that can be
--    hovered over with the mouse and clicked on.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUIUtility.lua")

class 'FancyClickable' (GUIScript)

function FancyClickable:Initialize()
    
    self.position = Vector(0.0, 0.0, 0.0)
    self.scale = Vector(1.0, 1.0, 1.0)
    
    self.updateInterval = 1/60 -- update @ 60fps
    self.callbackFunc = function() return false end
    self.parent = nil
    
    self.mouseOver = false -- was the mouse over the clickable last update?
    
    self.enabled = true -- tied to visibility.
    
    getmetatable(self).__tostring = FancyClickable.ToString
    
end

function FancyClickable:ToString()
    
    return string.format("%s()\n    position = %s\n    scale = %s\n    updateInterval = %s\n    mouseOver = %s\n    enabled = %s\n", self.classname, self.position, self.scale, self.updateInterval, self.mouseOver, self.enabled)
    
end

function FancyClickable:GetIsMouseOver()
    
    -- abstract... cannot be moused over.
    return false
    
end

function FancyClickable:DoCallback(callbackName)
    
    -- send callbacks to parent button, so they can be animated properly.
    if self.parent then
        self.parent:OnCallback(callbackName)
    end
    
    if self.callbackFunc then
        return self.callbackFunc(callbackName)
    end
    
    return false
    
end

function FancyClickable:Update(deltaTime)
    
    if self.enabled then
        -- Update mouseOver and mouseOut events.
        local currentMouseOver = self:GetIsMouseOver()
        if currentMouseOver and not self.mouseOver then
            self.mouseOver = true
            self:DoCallback("mouseOver")
        elseif not currentMouseOver and self.mouseOver then
            self.mouseOver = false
            self:DoCallback("mouseOut")
        end
    end
    
end

function FancyClickable:SendKeyEvent(key, down, amount)
    
    if self.enabled then
        if not self:GetIsMouseOver() then
            return false
        end
        
        if key == InputKey.MouseButton0 and down then
            return self:DoCallback("mouse0Down")
        end
    end
    
end

function FancyClickable:SetCallbackFunction(func)
    
    self.callbackFunc = func
    
end

function FancyClickable:SetPosition(position)
    
    self.position = position
    
end

-- scaling should NOT take into account screen size.  This is handled elsewhere.
function FancyClickable:SetScale(scale)
    
    self.scale = scale
    
end

-- Utility function to retrieve the mouse coordinates, converted to the "virtual" 1920x1080-pixel
-- space.  It is assumed that the anchor is in the upper-left corner of the screen.
function FancyClickable:GetVirtualMousePosition()
    
    local resizeMethod = (self.parent and self.parent.GetResizeMethod and self.parent:GetResizeMethod()) or "best-fit-center"
    
    local offset, scale = Fancy_Transform(Vector(0,0,0), 1, resizeMethod)
    
    local mouseX, mouseY = Client.GetCursorPosScreen()
    local mousePos = Vector(mouseX, mouseY, 0)
    
    -- transform mouse position into the 1080 space
    mousePos = (mousePos - offset) / scale
    mousePos = mousePos - self.position
    
    -- compensate for scaling.
    mousePos.x = mousePos.x / self.scale.x
    mousePos.y = mousePos.y / self.scale.y
    
    return mousePos
    
end

-- Set whether or not the button can be interacted with.
function FancyClickable:SetIsEnabled(state)
    
    self.enabled = state
    
    if state == false then
        -- disable mouse rollovers that might have been active
        if self.mouseOver then
            self.mouseOver = false
            self:DoCallback("mouseOut")
        end
    end
    
end

