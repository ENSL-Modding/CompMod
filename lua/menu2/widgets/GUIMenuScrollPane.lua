-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/widgets/GUIMenuScrollPane.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Menu themeing for GUIScrollPane.
--
--  Properties:
--      PaneSize    The size of the area where GUIItems and GUIObjects can be placed.  They can be
--                  placed outside of the pane bounds, but they won't be able to be scrolled-to.
--                  This just sets the size of the area that the scroll bars work with.
--      HorizontalScrollBarEnabled      Whether or not a horizontal scroll bar should be used.
--      VerticalScrollBarEnabled        Whether or not a vertical scroll bar should be used.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/widgets/GUIScrollPane.lua")
Script.Load("lua/menu2/widgets/GUIMenuScrollBarWidget.lua")
Script.Load("lua/menu2/MenuStyles.lua")

---@class GUIMenuScrollPane : GUIScrollPane
class "GUIMenuScrollPane" (GUIScrollPane)

local kScrollBarThickness = 32

function GUIMenuScrollPane:GetScrollBarThickness()
    return kScrollBarThickness
end

function GUIMenuScrollPane:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    PushParamChange(params, "scrollBarClass", params.scrollBarClass or GUIMenuScrollBarWidget)
    GUIScrollPane.Initialize(self, params, errorDepth)
    PopParamChange(params, "scrollBarClass")
    
end

-- Animate pane smoothly.
function GUIMenuScrollPane:ScrollToLocation(p1, p2, p3)
    local pos = ProcessVectorInput(p1, p2, p3)
    self:AnimateProperty("PanePosition", -pos, MenuAnimations.FlyIn)
end
