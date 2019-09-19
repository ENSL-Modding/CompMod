-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/NavBar/Screens/ServerBrowser/ServerBrowserColumns.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Configuration for columns visible in the server browser.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

-- Loads the scripts that define server browser columns.  Extend this function to add other scripts.
function LoadServerBrowserColumns()
    Script.Load("lua/menu2/NavBar/Screens/ServerBrowser/Columns/GMSBColumnQuickPlayRank.lua")
    Script.Load("lua/menu2/NavBar/Screens/ServerBrowser/Columns/GMSBColumnFavorites.lua")
    Script.Load("lua/menu2/NavBar/Screens/ServerBrowser/Columns/GMSBColumnBlocked.lua")
    Script.Load("lua/menu2/NavBar/Screens/ServerBrowser/Columns/GMSBColumnPassworded.lua")
    Script.Load("lua/menu2/NavBar/Screens/ServerBrowser/Columns/GMSBColumnRanked.lua")
    Script.Load("lua/menu2/NavBar/Screens/ServerBrowser/Columns/GMSBColumnSkill.lua")
    Script.Load("lua/menu2/NavBar/Screens/ServerBrowser/Columns/GMSBColumnServerName.lua")
    Script.Load("lua/menu2/NavBar/Screens/ServerBrowser/Columns/GMSBColumnGameMode.lua")
    Script.Load("lua/menu2/NavBar/Screens/ServerBrowser/Columns/GMSBColumnPlayers.lua")
    Script.Load("lua/menu2/NavBar/Screens/ServerBrowser/Columns/GMSBColumnPing.lua")
end
