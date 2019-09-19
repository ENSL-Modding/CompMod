-- ======= Copyright (c) 2018, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/NavBar/Screens/ServerBrowser/GMSBFavoriteButton.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Toggleable button with a heart shaped icon to favorite a server.  Does not provide this
--    functionality directly -- this is just a themed button.
--
--  Properties:
--      Enabled     Whether or not the button can be interacted with.
--      MouseOver   Whether or not the mouse is over the button (regardless of enabled-state).
--      Pressed     Whether or not the button is being pressed in by the mouse.
--      State       The current state of the button.  Can by the following:
--                      disabled    -- The button cannot be interacted with.
--                      pressed     -- The button is currently being hovered over and pressed down
--                                         on by the user.
--                      hover       -- The mouse is hovering over the button, but not pressed.
--                      active      -- The button is enabled and not being interacted with.
--      Value       Current value of the button's toggle -- true or false.
--      Glowing     Whether or not this button is glowing (eg it glows when entry it belongs to is
--                  selected).
--  
--  Events:
--      OnPressed   Whenever the button is pressed and released while enabled.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/menu2/NavBar/Screens/ServerBrowser/GMSBColumnButton.lua")

---@class GMSBFavoriteButton : GMSBColumnButton
class "GMSBFavoriteButton" (GMSBColumnButton)

GMSBFavoriteButton.emptyTexture = PrecacheAsset("ui/newMenu/server_browser/heart_dim.dds")
GMSBFavoriteButton.filledTexture = PrecacheAsset("ui/newMenu/server_browser/heart_fill_dim.dds")
GMSBFavoriteButton.glowingEmptyTexture = PrecacheAsset("ui/newMenu/server_browser/heart_glow.dds")
GMSBFavoriteButton.glowingFilledTexture = PrecacheAsset("ui/newMenu/server_browser/heart_fill_glow.dds")
