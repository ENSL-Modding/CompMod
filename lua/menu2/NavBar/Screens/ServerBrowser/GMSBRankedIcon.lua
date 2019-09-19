-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/NavBar/Screens/ServerBrowser/GMSBRankedIcon.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Icon for a ranked server.
--
--  Properties:
--      Glowing     Whether or not this button is glowing (eg it glows when entry it belongs to is
--                  selected).
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/menu2/NavBar/Screens/ServerBrowser/GMSBColumnIcon.lua")

---@class GMSBRankedIcon : GMSBColumnIcon
class "GMSBRankedIcon" (GMSBColumnIcon)

GMSBRankedIcon.regularTexture = PrecacheAsset("ui/newMenu/server_browser/ranked_dim.dds")
GMSBRankedIcon.glowingTexture = PrecacheAsset("ui/newMenu/server_browser/ranked_glow.dds")
