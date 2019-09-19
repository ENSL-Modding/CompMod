-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/GUIMenuCoolBox.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--    
--    A cool box with drop shadow, gradient, and a stroke effect inside.  A specialization of
--    GUIMenuNineBox.
--    
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/menu2/GUIMenuNineBox.lua")

---@class GUIMenuCoolBox : GUIMenuNineBox
class "GUIMenuCoolBox" (GUIMenuNineBox)

local kParams =
{
    texture = PrecacheAsset("ui/newMenu/nine_box_2.dds"),
    
    col0Width = 17,
    col1Width = 14,
    col2Width = 17,
    
    row0Height = 6,
    row1Height = 36,
    row2Height = 6,
    
    topLeftOffset = Vector(-8, -8, 0),
    bottomRightOffset = Vector(8, 8, 0),
    middleMinimumSize = Vector(14, 14, 0),
}

function GUIMenuCoolBox:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    GUIMenuNineBox.Initialize(self, kParams, errorDepth)
    
end
