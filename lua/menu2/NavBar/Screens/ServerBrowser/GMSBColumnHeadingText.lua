-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/NavBar/Screens/ServerBrowser/GMSBColumnHeadingText.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Base class for a server browser column heading that uses text for the header's contents.
--
--  Parameters (* = required)
--     *label
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/GUIText.lua")
Script.Load("lua/menu2/NavBar/Screens/ServerBrowser/GMSBColumn.lua")

---@class GMSBColumnHeadingText : GMSBColumnHeading
class "GMSBColumnHeadingText" (GMSBColumnHeading)

function GMSBColumnHeadingText:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    RequireType("string", params.label, "params.label", errorDepth)
    
    GMSBColumnHeading.Initialize(self, params, errorDepth)
    
    self.text = CreateGUIObject("text", GUIMenuText, self,
    {
        font = MenuStyle.kServerListHeaderFont,
        text = params.label,
        defaultColor = MenuStyle.kHeaderIconPlainColor,
    })
    self.text:AlignCenter()
    
end
