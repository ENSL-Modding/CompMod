-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/GUI/widgets/GUITruncatedDisplayWidget.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    A GUIObject that holds a GUIObject that is possibly wider than its display area allows.
--    For example, this can be used to display a string that is too long for the space it occupies.
--    Unlike GUIScrollPane, this widget does not have any scroll bars -- instead the scrolling is
--    performed automatically.
--    This only applies to the X axis -- no automatic scrolling is performed for the Y axis.
--  
--  Parameters (* = required)
--      cls             Class to instantiate inside this widget.
--  
--  Properties:
--      AutoScroll      Whether or not the item automatically scrolls.
--      Scroll          The current value of the item's scroll (some value between 0 and X,
--                      where X is the width of the contents that doesn't fit inside the
--                      container).
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/GUIObject.lua")

---@class GUITruncatedDisplayWidget : GUIObject
class "GUITruncatedDisplayWidget" (GUIObject)

GUITruncatedDisplayWidget:AddClassProperty("AutoScroll", false)
GUITruncatedDisplayWidget:AddClassProperty("Scroll", 0.0)

GUITruncatedDisplayWidget:AddClassProperty("_Rendered", false)
GUITruncatedDisplayWidget:AddClassProperty("_Animate", false)

local kDefaultAnimationSpeed = 80
local kDefaultAnimationDelayFront = 1 -- how many seconds to display the front of the string before movement begins.
local kDefaultAnimationDelayBack = 1 -- how many seconds to linger on end of string before jumping back to beginning.

local function UpdateScroll(self)
    self.obj:SetPosition(-self:GetScroll(), 0)
end

local function UpdateAutoScroll(self)
    
    -- Figure out if we actually need to auto scroll.
    local containerWidth = self:GetSize().x
    local contentsWidth = self.obj:GetSize().x * self.obj:GetScale().x
    local needScroll = containerWidth < contentsWidth
    local autoScroll = needScroll and self:Get_Animate()
    
    -- Add auto scroll animator if we want to auto scroll and one does not already exist.
    if autoScroll and not self.autoScrollAnimating then
        self.autoScrollAnimating = true
        self:AnimateProperty("Scroll", 0, self:GetScrollAnimationParameters(), "scroll")
    end
    
    -- Remove auto scroll animator if we should not be scrolling, and an animator is present.
    if not autoScroll and self.autoScrollAnimating then
        self.autoScrollAnimating = false
        self:ClearPropertyAnimations("Scroll")
    end
    
    UpdateScroll(self)
    
end

local function ScrollAnimationFunc(obj, time, params, currentValue, startValue, endValue, startTime)
    
    local maxScroll = obj:GetMaxScroll()
    local scrollSpeed = obj:GetAutoScrollSpeed()
    local scrollTime = maxScroll / scrollSpeed
    local delayFront = kDefaultAnimationDelayFront
    local delayBack = kDefaultAnimationDelayBack
    local delayTotal = delayFront + delayBack
    local totalCycleTime = scrollTime + delayTotal
    local ampMult = (scrollTime + delayTotal) / scrollTime
    
    local scroll = time / totalCycleTime
    scroll = scroll - math.floor(scroll)
    scroll = ampMult * scroll
    scroll = scroll - (delayFront / scrollTime)
    scroll = Clamp(scroll, 0, 1)
    scroll = scroll * maxScroll
    
    return scroll, false
    
end

function GUITruncatedDisplayWidget:GetMaxScroll()
    local result = math.max(self.obj:GetSize().x * self.obj:GetScale().x - self:GetSize().x, 0)
    return result
end

function GUITruncatedDisplayWidget:GetAutoScrollSpeed()
    return self.autoScrollSpeed
end

function GUITruncatedDisplayWidget:SetAutoScrollSpeed(speed)
    self.autoScrollSpeed = speed
end

function GUITruncatedDisplayWidget:GetScrollAnimationParameters()
    return { func = ScrollAnimationFunc, }
end

local function OnRenderingStarted(self)
    self:Set_Rendered(true)
end

local function OnRenderingStopped(self)
    self:Set_Rendered(false)
end

local function UpdateShouldAnimate(self)
    self:Set_Animate(self:Get_Rendered() and self:GetAutoScroll())
end

function GUITruncatedDisplayWidget:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    RequireClassIsa("GUIObject", params.cls, "params.cls", errorDepth)
    
    GUIObject.Initialize(self, params, errorDepth)
    
    self.autoScrollAnimating = false
    self.autoScrollSpeed = kDefaultAnimationSpeed
    
    self.obj = CreateGUIObject("obj", params.cls, self, params)
    self.obj:AlignLeft()
    
    self:TrackRenderStatus(self:GetVisibleObject())
    self:HookEvent(self, "OnRenderingStarted", OnRenderingStarted)
    self:HookEvent(self, "OnRenderingStopped", OnRenderingStopped)
    
    -- Enable cropping so the object is confined to this object's area.
    self:SetCropMin(0, 0)
    self:SetCropMax(1, 1)
    
    self:HookEvent(self, "On_AnimateChanged", UpdateAutoScroll)
    self:HookEvent(self, "OnScrollChanged", UpdateScroll)
    self:HookEvent(self, "OnSizeChanged", UpdateAutoScroll)
    self:HookEvent(self.obj, "OnSizeChanged", UpdateAutoScroll)
    
    self:HookEvent(self, "On_RenderedChanged", UpdateShouldAnimate)
    self:HookEvent(self, "OnAutoScrollChanged", UpdateShouldAnimate)
    
end

function GUITruncatedDisplayWidget:GetObject()
    return self.obj
end

function GUITruncatedDisplayWidget:GetVisibleObject()
    local result = self:GetObject()
    return result
end
