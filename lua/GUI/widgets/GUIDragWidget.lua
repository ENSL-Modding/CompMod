-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/GUI/widgets/GUIDragWidget.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    A GUIObject that contains a GUIDraggable that can be dragged, constrained to fit inside this
--    object's bounds.
--  
--  Parameters (* = required)
--      draggableClass      GUIDraggable-based class to use as the draggable.  Defaults to
--                          GUIDraggable.
--  
--  Properties:
--      BeingDragged        Whether or not the GUIDraggable held within this object is being dragged.
--      Enabled             Whether or not the GUIDraggable can be interacted with by the user.
--  
--  Events:
--      OnDragBegin         The user has clicked on the slider to begin dragging.
--      OnDrag              The draggable has changed position as a result of the user dragging it.
--      OnDragEnd           The user has released the slider to end dragging.
--      OnMove              The draggable has changed position, regardless of user interaction.
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/GUI/GUIObject.lua")
Script.Load("lua/GUI/widgets/GUIDraggable.lua")

---@class GUIDragWidget : GUIObject
class "GUIDragWidget" (GUIObject)

GUIDragWidget:AddCompositeClassProperty("BeingDragged", "draggable")
GUIDragWidget:AddCompositeClassProperty("Enabled", "draggable")

function GUIDragWidget:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    if params.draggableClass then
        RequireClassIsa("GUIDraggable", params.draggableClass, "params.draggableClass", errorDepth)
    end
    
    GUIObject.Initialize(self, params, errorDepth)
    
    PushParamChange(params, "draggableClass", params.draggableClass or GUIDraggable)
    self.draggable = CreateGUIObject("draggable", params.draggableClass, self, params)
    PopParamChange(params, "draggableClass")
    
    self:ForwardEvent(self.draggable, "OnDragBegin")
    self:ForwardEvent(self.draggable, "OnDrag")
    self:ForwardEvent(self.draggable, "OnDragEnd")
    self:ForwardEvent(self.draggable, "OnPositionChanged", "OnMove")
    
end

function GUIDragWidget:GetDraggable()
    return self.draggable
end
