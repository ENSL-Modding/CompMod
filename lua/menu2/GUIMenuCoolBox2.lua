-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/GUIMenuCoolBox2.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--    
--    Another variant of the GUIMenuCoolBox.  This one has a stroke, inner glow coming from the
--    top, and a gradient overlay.
--    
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/menu2/GUIMenuNineBox.lua")

---@class GUIMenuCoolBox2 : GUIMenuNineBox
class "GUIMenuCoolBox2" (GUIMenuNineBox)

local kParams =
{
    texture = PrecacheAsset("ui/newMenu/nine_box_4.dds"),
    
    col0Width = 18,
    col1Width = 12,
    col2Width = 18,
    
    row0Height = 18,
    row1Height = 12,
    row2Height = 18,
    
    topLeftOffset = Vector(-8, -8, 0),
    bottomRightOffset = Vector(8, 8, 0),
    middleMinimumSize = Vector(12, 12, 0),
}

function GUIMenuCoolBox2:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    GUIMenuNineBox.Initialize(self, kParams, errorDepth)
    
end
