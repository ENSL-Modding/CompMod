-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/NavBar/Screens/ServerBrowser/GMSBColumnHeadingIcon.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Base abstract class for a server browser column heading that uses a simple tinted icon for
--    the header's contents.  Two images are expected: a non-hover texture, and a hover texture.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/menu2/NavBar/Screens/ServerBrowser/GMSBColumn.lua")

---@class GMSBColumnHeadingIcon : GMSBColumnHeading
class "GMSBColumnHeadingIcon" (GMSBColumnHeading)

function GMSBColumnHeadingIcon:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    RequireType("string", params.texture, "params.texture", errorDepth)
    
    GMSBColumnHeading.Initialize(self, params, errorDepth)
    
    self.texture = params.texture
    
    self.graphic = CreateGUIObject("graphic", GUIMenuGraphic, self,
    {
        defaultColor = MenuStyle.kHeaderIconPlainColor,
    })
    self.graphic:SetTexture(self.texture)
    self.graphic:SetSizeFromTexture()
    self.graphic:AlignCenter()
    
end
