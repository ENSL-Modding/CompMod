-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/GUIMenuCloseMenuButton.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--    
--    The disconnect symbol that appears in the upper right corner at the main menu while in game.
--    
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/menu2/GUIMenuExitButton.lua")

---@class GUIMenuCloseMenuButton : GUIMenuExitButton
class "GUIMenuCloseMenuButton" (GUIMenuExitButton)

GUIMenuCloseMenuButton.kTextureRegular = PrecacheAsset("ui/newMenu/closeMenu.dds")
GUIMenuCloseMenuButton.kTextureHover   = PrecacheAsset("ui/newMenu/closeMenuOver.dds")

function GUIMenuCloseMenuButton:OnPressed()
    GetMainMenu():Close()
end
