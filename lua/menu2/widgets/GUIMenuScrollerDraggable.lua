-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/menu2/widgets/GUIMenuScrollerDraggable.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    A GUIDraggable themed for menu scroll bars.
--@class GUIMenuScrollerDraggable : GUIDraggable
--
--  Properties:
--      BeingDragged    Whether or not this object is currently being dragged by the user.
--  
--  Events:
--      OnDragBegin         The user has clicked on the slider to begin dragging.
--      OnDrag              The slider has changed position as a result of the user dragging it.
--      OnDragEnd           The user has released the slider to end dragging.
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/GUI/widgets/GUIDraggable.lua")
Script.Load("lua/menu2/MenuStyles.lua")
Script.Load("lua/menu2/wrappers/MenuFX.lua")

---@class GUIMenuScrollerDraggable : GUIDraggable
---@field public GetFXState function @From FXState wrapper
---@field public UpdateFXStateOverride function @From FXState wrapper
---@field public AddFXReceiver function @From FXState wrapper
---@field public RemoveFXReceiver function @From FXState wrapper
---@field protected OnFXStateChangedOverride function @From MenuFX wrapper
local baseClass = GUIDraggable
baseClass = GetMenuFXWrappedClass(baseClass)
class "GUIMenuScrollerDraggable" (baseClass)

function GUIMenuScrollerDraggable:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    PushParamChange(params, "defaultColor", params.defaultColor or MenuStyle.kScrollBarWidgetForegroundColor)
    PushParamChange(params, "highlightColor", params.highlightColor or MenuStyle.kWhite)
    baseClass.Initialize(self, params, errorDepth)
    PopParamChange(params, "highlightColor")
    PopParamChange(params, "defaultColor")
    
end

-- Override for animations.
function GUIMenuScrollerDraggable:SetPosition(p1, p2, p3)
    
    -- Only animate if the slider isn't being dragged, and if this call wasn't triggered by the
    -- animation system.
    if not self:GetBeingDragged() and not GetGUIAnimationManager():GetIsSettingPropertyForAnimation() then
        
        local value = ProcessVectorInput(p1, p2, p3)
        self:ConstrainPosition(value)
        local oldValue = self:GetPosition()
        if value == oldValue then
            return false -- no change.
        end
        
        self:AnimateProperty("Position", value, MenuAnimations.FlyIn)
        
        return true
        
    end
    
    -- Either the slider is being dragged, or this call originated from the animation system.  Just
    -- set it like normal.
    local result = baseClass.SetPosition(self, p1, p2, p3)
    return result
    
end
