-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/NavBar/Screens/ServerBrowser/GMSBNotRankedIcon.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Icon for a server that is not ranked.
--
--  Properties:
--      Glowing     Whether or not this button is glowing (eg it glows when entry it belongs to is
--                  selected).
--  
--  Events:
--      OnPressed   Whenever the button is pressed and released while enabled.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/menu2/NavBar/Screens/ServerBrowser/GMSBColumnIcon.lua")

---@class GMSBNotRankedIcon : GMSBColumnIcon
class "GMSBNotRankedIcon" (GMSBColumnIcon)

GMSBNotRankedIcon.regularTexture = PrecacheAsset("ui/newMenu/server_browser/not_ranked_dim.dds")
GMSBNotRankedIcon.glowingTexture = PrecacheAsset("ui/newMenu/server_browser/not_ranked_glow.dds")
