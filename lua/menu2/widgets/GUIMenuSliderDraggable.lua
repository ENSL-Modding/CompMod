-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/menu2/widgets/GUIMenuSliderDraggable.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    A GUIDraggable themed for menu sliders.
--
--  Parameters (* = required)
--      defaultColor    The color of the graphic when not highlighted or disabled.
--      highlightColor  The color of the graphic when highlighted.
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
Script.Load("lua/menu2/GUIMenuBasicBox.lua")
Script.Load("lua/menu2/MenuStyles.lua")
Script.Load("lua/GUI/wrappers/FXState.lua")

---@class GUIMenuSliderDraggable : GUIDraggable
---@field public GetFXState function @From FXState wrapper
---@field public UpdateFXStateOverride function @From FXState wrapper
---@field public AddFXReceiver function @From FXState wrapper
---@field public RemoveFXReceiver function @From FXState wrapper
local baseClass = GUIDraggable
baseClass = GetFXStateWrappedClass(baseClass)
class "GUIMenuSliderDraggable" (baseClass)

local function ClearGraphicColorAnimations(self)
    self.graphic:ClearPropertyAnimations("FillColor")
    self.graphic:ClearPropertyAnimations("StrokeColor")
end

local function SetGraphicColor(self, p1, p2, p3, p4)
    self.graphic:SetFillColor(p1, p2, p3, p4)
    self.graphic:SetStrokeColor(p1, p2, p3, p4)
end

local function AnimateGraphicColor(self, color, anim)
    self.graphic:AnimateProperty("FillColor", color, anim)
    self.graphic:AnimateProperty("StrokeColor", color, anim)
end

local function OnFXStateChanged(self, state, prevState)
    if state == "default" then
        AnimateGraphicColor(self, self.defaultColor or MenuStyle.kLightGrey, MenuAnimations.Fade)
    elseif state == "pressed" then
        ClearGraphicColorAnimations(self)
        SetGraphicColor(self, ((self.highlightColor or MenuStyle.kHighlight) + (self.defaultColor or MenuStyle.kLightGrey)) * 0.5)
    elseif state == "hover" then
        if prevState == "pressed" then
            AnimateGraphicColor(self, self.highlightColor or MenuStyle.kHighlight, MenuAnimations.Fade)
        else
            PlayMenuSound("ButtonHover")
            DoColorFlashEffect(self.graphic, "FillColor", self.highlightColor or MenuStyle.kHighlight)
            DoColorFlashEffect(self.graphic, "StrokeColor", self.highlightColor or MenuStyle.kHighlight)
        end
    end
end

local function UpdateSize(self)
    self.graphic:SetSize(self:GetSize())
end

local function OnSliderDrag()
    PlayMenuSound("SliderSound")
end

function GUIMenuSliderDraggable:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    RequireType({"Color", "nil"}, params.defaultColor, "params.defaultColor", errorDepth)
    RequireType({"Color", "nil"}, params.highlightColor, "params.highlightColor", errorDepth)
    
    baseClass.Initialize(self, params, errorDepth)
    
    if params.defaultColor   then self.defaultColor   = params.defaultColor   end
    if params.highlightColor then self.highlightColor = params.highlightColor end
    
    self.graphic = CreateGUIObject("graphic", GUIMenuBasicBox, self)
    
    SetGraphicColor(self, self.defaultColor or MenuStyle.kLightGrey)
    
    self:HookEvent(self, "OnFXStateChanged", OnFXStateChanged)
    self:HookEvent(self, "OnDrag", OnSliderDrag)
    
    self:HookEvent(self, "OnSizeChanged", UpdateSize)
    
end

-- Override for animations.
function GUIMenuSliderDraggable:SetPosition(p1, p2, p3)
    
    -- Only animate if the slider isn't being dragged, and if this call wasn't triggered by the
    -- animation system.
    if not self:GetBeingDragged() and not GetGUIAnimationManager():GetIsSettingPropertyForAnimation() then
        
        local value = ProcessVectorInput(p1, p2, p3)
        self:ConstrainPosition(value)
        local oldValue = self:GetPosition(true)
        
        if value == oldValue then
            return false -- no change.
        end
        
        self:ClearPropertyAnimations("Position")
        GUIDraggable.SetPosition(self, oldValue)
        self:AnimateProperty("Position", value, MenuAnimations.FlyIn)
        
        return true
        
    end
    
    -- Either the slider is being dragged, or this call originated from the animation system.  Just
    -- set it like normal.
    local result = GUIDraggable.SetPosition(self, p1, p2, p3)
    return result
    
end
