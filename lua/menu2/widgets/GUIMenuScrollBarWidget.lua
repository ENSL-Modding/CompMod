-- ======= Copyright (c) 2018, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/widgets/GUIMenuScrollBarWidget.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Menu themeing for GUIScrollBarWidget.
--
--  Properties:
--      BeingDragged        Whether or not the GUIDraggable held within this object is being dragged.
--      SliderLength        Length of the slider object along its major axis.  The slider object
--                          fills the available space along the minor axis.
--      ButtonGap           Amount of spacing to add between the buttons and the slider.
--      OutsidePadding      How much padding to add around the outside.
--      TotalRange          The total amount of area represented by this scroll bar.  This might
--                          correspond to the height of a page being viewed, for example.
--      ViewRange           Representation of the amount of space being viewed with this scroll
--                          bar.  This might correspond to the height of the window where a page is
--                          being displayed, for example.
--  
--  Events:
--      OnDragBegin         The user has clicked on the slider to begin dragging.
--      OnDrag              The slider has changed position as a result of the user dragging it.
--      OnDragEnd           The user has released the slider to end dragging.
--      OnJump              The value of the slider has jumped (eg the user clicked the
--                          background).
--      OnValueChanged      The slider has moved some amount, regardless of user interaction.
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/GUI/widgets/GUIScrollBarWidget.lua")
Script.Load("lua/menu2/widgets/GUIMenuScrollerWidget.lua")
Script.Load("lua/menu2/widgets/GUIMenuSliderBarWidget.lua")
Script.Load("lua/menu2/MenuStyles.lua")

---@class GUIMenuScrollBarWidget : GUIScrollBarWidget
class "GUIMenuScrollBarWidget" (GUIScrollBarWidget)

local function UpdateVisibility(self)
    
    local totalRange = self:GetTotalRange()
    local viewRange = self:GetViewRange()
    
    local shouldBeVisible = totalRange > viewRange
    
    if self.currentVisibility == nil then -- uninitialized
        
        if shouldBeVisible then
            self:SetOpacity(1)
        else
            self:SetOpacity(0)
        end
        
    else
        
        -- Determine if we need to fade in/out or do nothing.
        if shouldBeVisible == self.currentVisibility then
            return -- already where we need to be.
        else
            self:AnimateProperty("Opacity", shouldBeVisible and 1 or 0, MenuAnimations.Fade)
        end
        
    end
    
    self.currentVisibility = shouldBeVisible
    
end

local function OnOpacityChanged(self, opacity)
    self.scroller:SetOpacity(opacity)
    self.plusButton:SetOpacity(opacity)
    self.minusButton:SetOpacity(opacity)
end

function GUIMenuScrollBarWidget:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    PushParamChange(params, "scrollerWidgetClass", params.scrollerWidgetClass or GUIMenuScrollerWidget)
    PushParamChange(params, "directionalButtonClass", params.directionalButtonClass or GUIMenuScrollBarButton)
    GUIScrollBarWidget.Initialize(self, params, errorDepth)
    PopParamChange(params, "directionalButtonClass")
    PopParamChange(params, "scrollerWidgetClass")
    
    self:HookEvent(self, "OnTotalRangeChanged", UpdateVisibility)
    self:HookEvent(self, "OnViewRangeChanged", UpdateVisibility)
    
    self:HookEvent(self, "OnOpacityChanged", OnOpacityChanged)
    
    UpdateVisibility(self)
    
end
