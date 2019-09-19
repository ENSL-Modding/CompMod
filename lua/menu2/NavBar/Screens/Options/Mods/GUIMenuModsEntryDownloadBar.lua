-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/NavBar/Screens/Options/Mods/GUIMenuModsEntryDownloadBar.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    A nine-box used for the mod download progress bar.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/menu2/GUIMenuNineBox.lua")

---@class GUIMenuModsEntryDownloadBar : GUIMenuNineBox
class "GUIMenuModsEntryDownloadBar" (GUIMenuNineBox)

local kParams =
{
    texture = PrecacheAsset("ui/newMenu/nine_box_6.dds"),
    
    col0Width = 21,
    col1Width = 10,
    col2Width = 21,
    
    row0Height = 21,
    row1Height = 10,
    row2Height = 21,
    
    topLeftOffset = Vector(-6, -6, 0),
    bottomRightOffset = Vector(6, 6, 0),
    middleMinimumSize = Vector(1, 1, 0),
}

function GUIMenuModsEntryDownloadBar:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    GUIMenuNineBox.Initialize(self, kParams, errorDepth)

end
