-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/NavBar/Screens/StartServer/GUIMenuStartServerScreen.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Screen that allows the user to start a new listen server.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/menu2/GUIMenuPulldownForm.lua")

Script.Load("lua/menu2/MenuData.lua")

---@class GUIMenuStartServerScreen : GUIMenuPulldownForm
class "GUIMenuStartServerScreen" (GUIMenuPulldownForm)

-- If the server was started from the menu, this changes the behavior slightly (eg bots get added).
kListenServerStartedViaMenuOptionKey = "server-started-from-menu"

function GUIMenuStartServerScreen:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    PushParamChange(params, "screenName", "StartServer")
    GUIMenuPulldownForm.Initialize(self, params, errorDepth)
    PopParamChange(params, "screenName")
    
    self:ListenForCursorInteractions() -- prevent click-through
    
    self.buttons:SetRightLabel(Locale.ResolveString("START_SERVER"))
    self:HookEvent(self.buttons, "OnRightPressed", self.OnStartServerPressed)
    
    MenuData.AddDebugInfo(MenuData.StartServerMenu,  "MenuData.StartServerMenu")
    
    self.layout = CreateGUIObjectFromConfig(MenuData.StartServerMenu, self.contents)
    self.contents:HookEvent(self.layout, "OnSizeChanged", self.contents.SetSize)
    self.contents:SetSize(self.layout:GetSize())
    
end

function GUIMenuStartServerScreen:OnStartServerPressed()
    
    -- Since we don't want the bots option to "stick" for players for _EVERY_ listen server they make,
    -- use a temporary option to state that we're starting a listen server with through this menu.
    Client.SetOptionBoolean(kListenServerStartedViaMenuOptionKey, true)
    
    HostGame(Client.GetOptionString(kStartServer_MapKey, kStartServer_DefaultMap),                  -- map name
             false,                                                                                 -- hidden
             Client.GetOptionString(kStartServer_ServerNameKey, kStartServer_DefaultServerName),    -- server name
             Client.GetOptionString(kStartServer_PasswordKey, kStartServer_DefaultPassword),        -- password
             Client.GetOptionInteger(kStartServer_PlayerLimitKey, kStartServer_DefaultPlayerLimit), -- player limit
             Client.GetOptionInteger(kStartServer_PortKey, kStartServer_DefaultPort),               -- port
             false)                                                                                 -- disable mods
    
end
