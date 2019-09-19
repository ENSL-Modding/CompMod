-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/GUI/widgets/GUIDraggable.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    A GUIObject that can be used as a draggable in a GUIDragWidget.
--
--  Parameters (* = required)
--      constrainToParent
--      constrainToScreen
--
--  Properties:
--      BeingDragged        Whether or not this object is currently being dragged by the user.
--      Enabled             Whether or not this object can be dragged by the user.
--      ConstrainToParent   Whether or not this object should be constrained to the parent object's
--                          bounds when being dragged.  Default is true.
--      ConstrainToScreen   Whether or not this object should be constrained to the screen bounds
--                          (only applicable if it has no parent or is set to not be constrained to
--                          parent).
--  
--  Events:
--      OnDragBegin         The user has clicked on the slider to begin dragging.
--          obj             This object.
--      OnDrag              The draggable has changed position as a result of the user dragging it.
--          obj             This object.
--      OnDragEnd           The user has released the slider to end dragging.
--          obj             This object.
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/GUI/GUIObject.lua")
Script.Load("lua/GUI/wrappers/CursorInteractable.lua")

---@class GUIDraggable : GUIObject
---@field public GetMouseOver function @From CursorInteractable wrapper
---@field public GetPressed function @From CursorInteractable wrapper
local baseClass = GUIObject
baseClass = GetCursorInteractableWrappedClass(baseClass)
class "GUIDraggable" (baseClass)

GUIDraggable:AddClassProperty("BeingDragged", false)
GUIDraggable:AddClassProperty("Enabled", true)
GUIDraggable:AddClassProperty("ConstrainToParent", true)
GUIDraggable:AddClassProperty("ConstrainToScreen", true)

-- Modifies the input "position", and constrains the draggable to the parent object's bounds (or
-- the screen bounds if there is no parent object).  Returns true if a change was made, false
-- otherwise.
function GUIDraggable:ConstrainPosition(position)
    
    local parentObj = self:GetParent(true)
    if parentObj ~= nil then
        AssertIsaGUIObject(parentObj)
    end
    
    local originalPosition = Vector(position)
    
    local dragMin
    local dragMax
    if parentObj then
        if self:GetConstrainToParent() then
            dragMin = Vector(0, 0, 0)
            dragMax = parentObj:GetSize(true)
        else
            if self:GetConstrainToScreen() then
                -- Object has a parent, but we're not constraining to it.  Need to figure out what the
                -- screen-space bounds are in parent-space coordinates.
                dragMin = parentObj:ScreenSpaceToLocalSpace(0, 0)
                dragMax = parentObj:ScreenSpaceToLocalSpace(Client.GetScreenWidth(), Client.GetScreenHeight())
            else
                -- Nothing constrains this object, just bail out now.
                return
            end
        end
    else
        if self:GetConstrainToScreen() then
            dragMin = Vector(0, 0, 0)
            dragMax = Vector(Client.GetScreenWidth(), Client.GetScreenHeight(), 0)
        else
            -- Nothing constrains this object, just bail out now.
            return
        end
    end
    
    -- Adjust dragMin and dragMax to take into account the anchor.
    local anchor = self:GetAnchor(true)
    do
        local newDragMin = Vector(Lerp(dragMin.x, dragMax.x, 0 - anchor.x),
                                  Lerp(dragMin.y, dragMax.y, 0 - anchor.y), 0)
    
        local newDragMax = Vector(Lerp(dragMin.x, dragMax.x, 1 - anchor.x),
                                  Lerp(dragMin.y, dragMax.y, 1 - anchor.y), 0)
        
        dragMin = newDragMin
        dragMax = newDragMax
    end
    
    -- Adjust dragMin and dragMax to take into account the size and hotspot of this object.
    local localSize = self:GetSize(true) * self:GetScale(true)
    local hotSpot = self:GetHotSpot(true)
    dragMin = dragMin + localSize * hotSpot
    dragMax = dragMax - localSize * (Vector(1, 1, 0) - hotSpot)
    
    if position.x < dragMin.x then
        position.x = dragMin.x
    elseif position.x > dragMax.x then
        position.x = dragMax.x
    end
    
    if position.y < dragMin.y then
        position.y = dragMin.y
    elseif position.y > dragMax.y then
        position.y = dragMax.y
    end
    
    return originalPosition ~= position
    
end

local function ReConstrainDragger(self)
    
    local position = Vector(self:GetPosition(true))
    self:ConstrainPosition(position)
    self:SetPosition(position)
    
end

local function OnEnabledChanged(self, enabled)
    
    -- Force mouse to release if the draggable was just disabled and we were being dragged.
    if not enabled and self:GetBeingDragged() then
        self:OnMouseUp()
    end
    
end

-- Override SetPosition to constrain the dragger to the parent's area.
function GUIDraggable:SetPosition(p1, p2, p3)
    
    local value = ProcessVectorInput(p1, p2, p3)
    self:ConstrainPosition(value)
    local result = GUIObject.SetPosition(self, value)
    return result
    
end

local function OnParentChanged(self, newParent, oldParent)
    
    if oldParent then
        self:UnHookEvent(oldParent, "OnSizeChanged", ReConstrainDragger)
    end
    
    if newParent then
        self:HookEvent(newParent, "OnSizeChanged", ReConstrainDragger)
    end

end

function GUIDraggable:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    RequireType({"boolean", "nil"}, params.constrainToParent, "params.constrainToParent", errorDepth)
    RequireType({"boolean", "nil"}, params.constrainToScreen, "params.constrainToScreen", errorDepth)
    
    baseClass.Initialize(self, params, errorDepth)
    
    if params.constrainToParent ~= nil then
        self:SetConstrainToParent(params.constrainToParent)
    end
    
    if params.constrainToScreen ~= nil then
        self:SetConstrainToScreen(params.constrainToScreen)
    end
    
    self:HookEvent(self, "OnSizeChanged", ReConstrainDragger)
    self:HookEvent(self, "OnScaleChanged", ReConstrainDragger)
    self:HookEvent(self, "OnEnabledChanged", OnEnabledChanged)
    
    self:HookEvent(self, "OnParentChanged", OnParentChanged)
    
end

function GUIDraggable:OnMouseClick(double)
    
    baseClass.OnMouseClick(self, double)
    
    if not self:GetEnabled() then
        return
    end
    
    local parentObj = self:GetParent()
    if parentObj ~= nil then
        AssertIsaGUIObject(parentObj)
    end
    
    local mousePos = GetGlobalEventDispatcher():GetMousePosition()
    
    local localPosition = self:GetPosition()
    local localMousePosition
    if parentObj then
        localMousePosition = parentObj:ScreenSpaceToLocalSpace(mousePos)
    else
        localMousePosition = mousePos
    end
    
    self.dragOffset = localMousePosition - localPosition
    self:SetBeingDragged(true)
    self:FireEvent("OnDragBegin", self)
    
end

function GUIDraggable:OnMouseDrag()
    
    if not self:GetBeingDragged() then
        return
    end
    
    local parentObj = self:GetParent()
    if parentObj ~= nil then
        AssertIsaGUIObject(parentObj)
    end
    
    local mousePos = GetGlobalEventDispatcher():GetMousePosition()
    
    local localMousePosition
    if parentObj then
        localMousePosition = parentObj:ScreenSpaceToLocalSpace(mousePos)
    else
        localMousePosition = mousePos
    end
    
    local localPosition = localMousePosition - self.dragOffset
    
    self:ConstrainPosition(localPosition)
    
    if self:SetPosition(localPosition) then
        self:FireEvent("OnDrag", self)
    end
    
end

function GUIDraggable:EndDragging()
    
    if not self:GetBeingDragged() then
        return
    end
    
    self:SetBeingDragged(false)
    self:FireEvent("OnDragEnd", self)
    
end

function GUIDraggable:OnMouseUp()
    
    baseClass.OnMouseUp(self)
    
    self:EndDragging()
    
end


