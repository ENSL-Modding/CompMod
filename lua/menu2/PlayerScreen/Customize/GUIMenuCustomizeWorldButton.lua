-- ======= Copyright (c) 2018, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/PlayerScreen/Customize/GUIMenuCustomizeWorldButton.lua
--
--    Created by:   Brock Gillespie (brock@naturalselection2.com)
--
--  TODO Document
--  
-- ========= For more information, visit us at http://www.unknownworlds.com =====================


Script.Load("lua/GUI/GUIUtils.lua")
Script.Load("lua/menu2/MenuStyles.lua")
Script.Load("lua/GUI/widgets/GUIButton.lua")
Script.Load("lua/menu2/wrappers/Tooltip.lua")


---@class GUIMenuCustomizeWorldButton : GUIButton
local baseClass = GUIButton
baseClass = GetTooltipWrappedClass(baseClass)
class "GUIMenuCustomizeWorldButton" (baseClass)

GUIMenuCustomizeWorldButton:AddClassProperty("BeingDragged", false)


function GUIMenuCustomizeWorldButton:Initialize( params, errorDepth )
    errorDepth = (errorDepth or 1) + 1

    baseClass.Initialize(self, params, errorDepth)

    --TODO Add param check for "min-dist" on drag-event before it triggers the cb

    self.OnPressedCallback = nil
    self.OnMouseEnterCallback = nil
    self.OnMouseExitCallback = nil
    self.OnMouseDragCallback = nil
    self.OnMouseRightClickCallback = nil

    self.dragOffset = Vector(0,0,0)
    self.lastMousePos = Vector(0,0,0) --for caching on updates to compare against current (to get direction)

    --TODO Add size change stuff?
    self.associatedSceneObject = nil

end


function GUIMenuCustomizeWorldButton:SetPressedCallback( callback )
    assert(callback and type(callback) == "function")
    self.OnPressedCallback = callback
    self:HookEvent(self, "OnPressed", self.OnPressed)
end

function GUIMenuCustomizeWorldButton:SetMouseEnterCallback( callback )
    assert(callback and type(callback) == "function")
    self.OnMouseEnterCallback = callback
    self:HookEvent(self, "OnMouseEnter", self.OnMouseEnter)
end

function GUIMenuCustomizeWorldButton:SetMouseExitCallback( callback )
    assert(callback and type(callback) == "function")
    self.OnMouseExitCallback = callback
    self:HookEvent(self, "OnMouseExit", self.OnMouseExit)
end

function GUIMenuCustomizeWorldButton:SetMouseRightClickCallback( callback )
    assert(callback and type(callback) == "function")
    self.OnMouseRightClickCallback = callback
    self:HookEvent(self, "OnKey", self.OnKey)
    self:ListenForKeyInteractions()
end

function GUIMenuCustomizeWorldButton:SetOnMouseDragCallback( callback )
    assert(callback and type(callback) == "function")
    self.OnMouseDragCallback = callback
    self:HookEvent(self, "OnMouseDrag", self.OnMouseDrag)
end

function GUIMenuCustomizeWorldButton:OnPressed()
    if self.OnPressedCallback then
        self:OnPressedCallback(self)
    end

    if self.OnMouseDragCallback then    --XX also add a "has event" like check?
    --prime data for dragging
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
    
end

function GUIMenuCustomizeWorldButton:OnMouseEnter()
    if self.mouseEntered then
        return --required as this fires every frame mouse is on an object
    end
    
    self.mouseEntered = true

    if self.OnMouseEnterCallback then
        self:OnMouseEnterCallback(self)
        return true
    end
end

function GUIMenuCustomizeWorldButton:OnMouseExit()
    self.mouseEntered = false
    
    if self.OnMouseExitCallback then
        self:OnMouseExitCallback(self)
    end
end

function GUIMenuCustomizeWorldButton:OnMouseDrag(  ) --?? params?

    if not self:GetBeingDragged() then --FIXME Need to add property for this
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
    
    --self:ConstrainPosition(localPosition) --??
    
    if self:SetPosition(localPosition) then
        self:FireEvent("OnDrag", self)
    end

    --TODO track current pos from _last_ pos

end

function GUIMenuCustomizeWorldButton:SetSceneObjectLabel( objectName )
    assert(objectName)
    assert(type(objectName) == "string" and objectName ~= "")
    self.associatedSceneObject = objectName
end

function GUIMenuCustomizeWorldButton:GetSceneObjectLabel()
    assert(self.associatedSceneObject)
    return self.associatedSceneObject
end

function GUIMenuCustomizeWorldButton:ClearSceneObjectLabel()
    self.associatedSceneObject = nil
end

function GUIMenuCustomizeWorldButton:OnKey( key, down )
    
    if self.mouseEntered then
        
        if key == InputKey.MouseButton1 and down then   --XX Add fire delay?
            if self.OnMouseRightClickCallback then
                self:OnMouseRightClickCallback(self)
                return true --?? denotes "is handled"?
            end
        end

    end

    return false
end
