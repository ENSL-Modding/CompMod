-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/NavBar/Screens/ServerBrowser/Columns/GMSBColumnBlocked.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Defines the header and contents classes for the "blocked" column of the server browser.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/menu2/NavBar/Screens/ServerBrowser/GMSBColumn.lua")
Script.Load("lua/menu2/NavBar/Screens/ServerBrowser/GMSBColumnHeadingIcon.lua")
Script.Load("lua/menu2/NavBar/Screens/ServerBrowser/GMSBBlockedButton.lua")
Script.Load("lua/menu2/wrappers/Tooltip.lua")

local kBlockedIconEmptyTexture = PrecacheAsset("ui/newMenu/server_browser/blocked_dim.dds")

---@class GMSBColumnHeadingBlocked : GMSBColumnHeadingIcon
---@field public GetTooltip function @From Tooltip wrapper
---@field public SetTooltip function @From Tooltip wrapper
local baseClass = GetTooltipWrappedClass(GMSBColumnHeadingIcon)
class "GMSBColumnHeadingBlocked" (baseClass)

local function OnHeadingPressed(self)
    
    local serverBrowser = GetServerBrowser()
    assert(serverBrowser)
    
    -- If they want to sort by blocked servers, we can assume they want to see all servers
    -- (otherwise what would be the point?)
    serverBrowser:SetFilterValue("blockedServers", "show")
    
    if serverBrowser:GetSortFunction() == ServerBrowserSortFunctions.BlockedReversed then
        serverBrowser:SetSortFunction(ServerBrowserSortFunctions.Blocked)
    else
        serverBrowser:SetSortFunction(ServerBrowserSortFunctions.BlockedReversed)
    end
    
end

function GMSBColumnHeadingBlocked:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    PushParamChange(params, "texture", kBlockedIconEmptyTexture)
    PushParamChange(params, "tooltip", Locale.ResolveString("SERVERBROWSER_BLOCKED_SERVERS_SORT_TOOLTIP"))
    baseClass.Initialize(self, params, errorDepth)
    PopParamChange(params, "tooltip")
    PopParamChange(params, "texture")
    
    self:HookEvent(self, "OnPressed", OnHeadingPressed)
    
end


---@class GMSBColumnContentsBlocked : GMSBColumnContents
---@field public GetTooltip function @From Tooltip wrapper
---@field public SetTooltip function @From Tooltip wrapper
local ttWrappedCC = GetTooltipWrappedClass(GMSBColumnContents)
class "GMSBColumnContentsBlocked" (ttWrappedCC)

local function OnBlockedChanged(self, blocked, prevBlocked)
    self.button:SetValue(blocked)
    if blocked then
        self:SetTooltip(Locale.ResolveString("SERVERBROWSER_BLOCKED_TOOLTIP_1"))
    else
        self:SetTooltip(Locale.ResolveString("SERVERBROWSER_BLOCKED_TOOLTIP_2"))
    end
end

local function OnSelectedChanged(self, selected, prevSelected)
    self.button:SetGlowing(selected)
end

local function OnPressed(self)
    self.entry:SetBlocked(self.button:GetValue())
end

function GMSBColumnContentsBlocked:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    ttWrappedCC.Initialize(self, params, errorDepth)
    
    self.button = CreateGUIObject("button", GMSBBlockedButton, self)
    self.button:SetLayer(2)
    self.button:AlignCenter()
    
    assert(self.entry)
    self:HookEvent(self.entry, "OnBlockedChanged", OnBlockedChanged)
    self:HookEvent(self.entry, "OnSelectedChanged", OnSelectedChanged)
    
    self:HookEvent(self.button, "OnPressed", OnPressed)
    
    OnBlockedChanged(self, self.entry:GetBlocked())
    OnSelectedChanged(self, self.entry:GetSelected())
    
end

RegisterServerBrowserColumnType("Blocked", GMSBColumnHeadingBlocked, GMSBColumnContentsBlocked, 86, 256)
