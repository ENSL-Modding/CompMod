-- ======= Copyright (c) 2017, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\menu\FancyElement.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Abstract(ish) element.  Concrete types inherit from this, but can itself be used
--    as an empty node (and is used as the top level node for all button "state" elements).
--    Handles all heirarchy-related tasks, such as destroying children, and propagating
--    certain events, like OnResolutionChanged.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

class 'FancyElement'

function FancyElement:Initialize()
    
    self.children = {}
    
    -- These values are the same for all members of the heirarchy.
    self.position = Vector(0,0,0)
    self.scale = Vector(1,1,1)
    
    self.layer = 6
    self.parent = nil
    self.resizeMethod = nil
    
    self.updateHookFunction = nil
    
    self:UpdateItem()
    
    getmetatable(self).__tostring = FancyElement.ToString
    
end

function FancyElement:ToString()
    
    return string.format("%s()\n    children = %s\n    position = %s\n    scale=%s\n    layer=%s\n", self.classname, ToString(self.children), self.position, self.scale, self.layer)
    
end

function FancyElement:SetResizeMethod(method)
    
    self.resizeMethod = method
    
    self:UpdateItem()
    
end

function FancyElement:GetResizeMethod()
    
    if self.resizeMethod then
        return self.resizeMethod
    end
    
    if self.parent and self.parent.GetResizeMethod then
        return self.parent:GetResizeMethod()
    end
    
    return nil
    
end

function FancyElement:Destroy()
    
    for i=1, #self.children do
        self.children[i]:Destroy()
    end
    
end

-- Adds a child to this "fancy element".  This does NOT impact render ordering, but DOES impact
-- positioning and scaling.
function FancyElement:AddChild(element)
    
    element.parent = self
    
    if not element then
        Log("WARNING: Attempted to call FancyElement:AddChild() with nil element value.")
        Log("%s", debug.traceback())
        return
    end
    
    self.children[#self.children+1] = element
    
end

function FancyElement:SetLayer(layerNum)
    
    self.layer = layerNum
    
    self:UpdateItem()
    
end

function FancyElement:OnResolutionChanged()
    
    for i=1, #self.children do
        self.children[i]:OnResolutionChanged()
    end
    
    self:UpdateItem()
    
end

-- nils-out the cached value of all descendants.
local function ClearCachedValue(self, valueName)
    
    self[valueName] = nil
    for i=1, #self.children do
        ClearCachedValue(self.children[i], valueName)
    end
    
end

-- NOTE: We deliberately do NOT provide an overload of SetSize(), as this is ambiguous.  Each
-- item in the heirarchy can potentially have a different pixel size.
-- NOTE2: This field should NOT be used to scale elements for the screen size.  Screen size
-- scaling should be handled in the child implementation as a final step.
function FancyElement:SetRelativeScale(scale)
    
    self.scale = scale
    
    ClearCachedValue(self, "cachedAbsoluteScale")
    
    self:UpdateItem()
    
end

function FancyElement:GetRelativeScale()
    
    return self.scale
    
end

function FancyElement:GetAbsoluteParentScale()
    
    local absScale = self:GetAbsoluteScale()
    local relScale = self:GetRelativeScale()
    
    local parentAbsScale = Vector(1,1,1)
    parentAbsScale.x = absScale.x / relScale.x
    parentAbsScale.y = absScale.y / relScale.y
    
    return parentAbsScale
    
end

function FancyElement:GetAbsoluteScale()
    
    if self.parent then
        if not self.cachedAbsoluteScale then
            self.cachedAbsoluteScale = Vector(1,1,1)
            self.cachedAbsoluteScale.x = self:GetRelativeScale().x * self.parent:GetAbsoluteScale().x
            self.cachedAbsoluteScale.y = self:GetRelativeScale().y * self.parent:GetAbsoluteScale().y
        end
        
        return self.cachedAbsoluteScale
    end
    
    return self:GetRelativeScale()
    
end

-- Position passed is a vector given in 1920x1080-sized pixels.  Each child is expected to make
-- the necessary conversions to real-screen coordinates.
function FancyElement:SetRelativePosition(position)
    
    self.position = position
    
    ClearCachedValue(self, "cachedAbsolutePosition")
    
    self:UpdateItem()
    
end

-- Position relative to parent.
function FancyElement:GetRelativePosition()
    
    return self.position
    
end

function FancyElement:GetAbsolutePosition()
    
    if self.parent then
        if not self.cachedAbsolutePosition then
            self.cachedAbsolutePosition = Vector(0,0,0)
            self.cachedAbsolutePosition.x = self.parent:GetAbsolutePosition().x + self:GetRelativePosition().x * self:GetAbsoluteParentScale().x
            self.cachedAbsolutePosition.y = self.parent:GetAbsolutePosition().y + self:GetRelativePosition().y * self:GetAbsoluteParentScale().y
        end
        
        return self.cachedAbsolutePosition
    end
    
    return self:GetRelativePosition()
    
end

function FancyElement:UpdateItem()
    
    for i=1, #self.children do
        self.children[i]:UpdateItem()
    end
    
    local item = self:GetDisplayedItem()
    if item then
        item:SetLayer(self.layer)
    end
    
    self:UpdateHook()
    
end

function FancyElement:GetDisplayedItem()
    
    return nil
    
end

-- Used to allow external stuff to be set that we can't really abstract out well enough.  Stuff like
-- setting up shaders for images, etc.  When called, the parameters given are dependent upon the
-- implementing class.  For example, the image may pass the gui item, the text may pass a gui item and
-- a gui-view.
function FancyElement:SetExtraSetupHook(func)
    
    self.updateHookFunction = func
    
    self:UpdateItem()
    
end

-- allows us to setup external stuff that we really can't cram in here (eg shaders, shader parameters... etc.)
function FancyElement:UpdateHook()
    
    if self.updateHookFunction then
        self.updateHookFunction(self.item)
    end
    
end

function FancyElement:RenderElement()
    
    for i=1, #self.children do
        self.children[i]:RenderElement()
    end
    
end

function FancyElement:Update()
    
    for i=1, #self.children do
        self.children[i]:Update()
    end
    
end

-- sets the visibility of itself and all children
function FancyElement:SetIsVisible(state)
    
    for i=1, #self.children do
        self.children[i]:SetIsVisible(state)
    end
    
end



