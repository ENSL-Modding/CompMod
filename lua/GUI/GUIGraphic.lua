-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/GUI/GUIGraphic.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Convenience class.  Just a GUIObject with color defaulted to opaque white, instead of
--    transparent black.
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/GUI/GUIObject.lua")

local baseClass = GUIObject
class "GUIGraphic" (baseClass)

function GUIGraphic:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    PushParamChange(params, "color", params.color or Color(1, 1, 1, 1))
    GUIObject.Initialize(self, params, errorDepth)
    PopParamChange(params, "color")
    
end
