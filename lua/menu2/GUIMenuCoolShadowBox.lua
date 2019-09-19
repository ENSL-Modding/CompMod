-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/GUIMenuCoolShadowBox.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--    
--    A cool box with drop shadow, inner shadow, gradient, and a stroke effect inside.  A
--    specialization of GUIMenuNineBox.
--    
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/menu2/GUIMenuNineBox.lua")

---@class GUIMenuCoolShadowBox : GUIMenuNineBox
class "GUIMenuCoolShadowBox" (GUIMenuNineBox)

local kParams =
{
    texture = PrecacheAsset("ui/newMenu/nine_box_3.dds"),
    
    col0Width = 16,
    col1Width = 16,
    col2Width = 16,
    
    row0Height = 16,
    row1Height = 12,
    row2Height = 16,
    
    topLeftOffset = Vector(-8, -2, 0),
    bottomRightOffset = Vector(8, 18, 0),
    middleMinimumSize = Vector(12, 12, 0),
}

function GUIMenuCoolShadowBox:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    GUIMenuNineBox.Initialize(self, kParams, errorDepth)
    
end
