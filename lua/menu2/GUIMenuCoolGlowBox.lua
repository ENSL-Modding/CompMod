-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/GUIMenuCoolGlowBox.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--    
--    A cool box with drop shadow, inner glow, gradient, and a stroke effect inside.  A
--    specialization of GUIMenuNineBox.
--    
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/menu2/GUIMenuNineBox.lua")

---@class GUIMenuCoolGlowBox : GUIMenuNineBox
class "GUIMenuCoolGlowBox" (GUIMenuNineBox)

local kParams =
{
    texture = PrecacheAsset("ui/newMenu/nine_box_1.dds"),
    
    col0Width = 16,
    col1Width = 16,
    col2Width = 16,
    
    row0Height = 8,
    row1Height = 28,
    row2Height = 8,
    
    topLeftOffset = Vector(-8, -2, 0),
    bottomRightOffset = Vector(8, 18, 0),
    middleMinimumSize = Vector(12, 12, 0),
}

function GUIMenuCoolGlowBox:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    GUIMenuNineBox.Initialize(self, CombineParams(kParams, params), errorDepth)
    
end
