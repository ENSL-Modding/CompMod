-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/NavBar/Screens/ServerBrowser/GMSBPasswordedIcon.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Icon for a passworded server.
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

---@class GMSBPasswordedIcon : GMSBColumnIcon
class "GMSBPasswordedIcon" (GMSBColumnIcon)

GMSBPasswordedIcon.regularTexture = PrecacheAsset("ui/newMenu/server_browser/lock_dim.dds")
GMSBPasswordedIcon.glowingTexture = PrecacheAsset("ui/newMenu/server_browser/lock_glow.dds")
