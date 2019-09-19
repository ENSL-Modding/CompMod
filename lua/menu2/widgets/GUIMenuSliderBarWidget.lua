-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/menu2/widgets/GUIMenuSliderBarWidget.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Menu themeing for GUISliderBarWidget.
--@class GUIMenuSliderBarWidget : GUISliderBarWidget
--
--  Properties:
--      BeingDragged        Whether or not the GUIDraggable held within this object is being dragged.
--      SliderLength        Length of the slider object along its major axis.  The slider object
--                          fills the available space along the minor axis.
--      ButtonGap           Amount of spacing to add between the buttons and the slider.
--      OutsidePadding      How much padding to add around the outside.
--  
--  Events:
--      OnDragBegin         The user has clicked on the slider to begin dragging.
--      OnDrag              The slider has changed position as a result of the user dragging it.
--      OnDragEnd           The user has released the slider to end dragging.
--      OnJump              The value of the slider has jumped (eg the user clicked the
--                          background).
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/GUI/widgets/GUISliderBarWidget.lua")
Script.Load("lua/menu2/widgets/GUIMenuSliderWidget.lua")
Script.Load("lua/menu2/widgets/GUIMenuArrowButton.lua")
Script.Load("lua/menu2/MenuStyles.lua")

---@class GUIMenuSliderBarWidget : GUISliderBarWidget
class "GUIMenuSliderBarWidget" (GUISliderBarWidget)

function GUIMenuSliderBarWidget:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    PushParamChange(params, "sliderWidgetClass", params.sliderWidgetClass or GUIMenuSliderWidget)
    PushParamChange(params, "directionalButtonClass", params.directionalButtonClass or GUIMenuArrowButton)
    GUISliderBarWidget.Initialize(self, params, errorDepth)
    PopParamChange(params, "directionalButtonClass")
    PopParamChange(params, "sliderWidgetClass")
    
end
