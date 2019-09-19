-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/NavBar/Screens/ServerBrowser/Columns/GMSBColumnPassworded.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Defines the header and contents classes for the "passworded" column of the server browser.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/menu2/NavBar/Screens/ServerBrowser/GMSBColumn.lua")
Script.Load("lua/menu2/NavBar/Screens/ServerBrowser/GMSBColumnHeadingIcon.lua")
Script.Load("lua/menu2/NavBar/Screens/ServerBrowser/GMSBPasswordedIcon.lua")
Script.Load("lua/menu2/wrappers/Tooltip.lua")

local kLockIconTexture = PrecacheAsset("ui/newMenu/server_browser/lock_dim.dds")

---@class GMSBColumnHeadingPassworded : GMSBColumnHeadingIcon
---@field public GetTooltip function @From Tooltip wrapper
---@field public SetTooltip function @From Tooltip wrapper
local baseClass = GetTooltipWrappedClass(GMSBColumnHeadingIcon)
class "GMSBColumnHeadingPassworded" (baseClass)

local function OnHeadingPressed(self)
    
    local serverBrowser = GetServerBrowser()
    assert(serverBrowser)
    
    -- If they want to sort by passworded servers, we can assume they want to see all servers
    -- (otherwise what would be the point?)
    serverBrowser:SetFilterValue("password", true)
    
    if serverBrowser:GetSortFunction() == ServerBrowserSortFunctions.PasswordedReversed then
        serverBrowser:SetSortFunction(ServerBrowserSortFunctions.Passworded)
    else
        serverBrowser:SetSortFunction(ServerBrowserSortFunctions.PasswordedReversed)
    end
    
end

function GMSBColumnHeadingPassworded:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    PushParamChange(params, "texture", kLockIconTexture)
    PushParamChange(params, "tooltip", Locale.ResolveString("SERVERBROWSER_PASSWORD_SORT_TOOLTIP"))
    baseClass.Initialize(self, params, errorDepth)
    PopParamChange(params, "tooltip")
    PopParamChange(params, "texture")
    
    self:HookEvent(self, "OnPressed", OnHeadingPressed)
    
end


---@class GMSBColumnContentsPassworded : GMSBColumnContents
class "GMSBColumnContentsPassworded" (GMSBColumnContents)

local function OnPasswordedChanged(self, passworded, prevPassworded)
    self.icon:SetVisible(passworded)
end

local function OnSelectedChanged(self, selected, prevSelected)
    self.icon:SetGlowing(selected)
end

local function ForwardOnMouseClick(self, double)
    self.entry:OnMouseClick(double)
end

local function ForwardOnMouseRelease(self)
    self.entry:OnMouseRelease()
end

local function ForwardOnMouseUp(self)
    self.entry:OnMouseUp()
end

function GMSBColumnContentsPassworded:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    GMSBColumnContents.Initialize(self, params, errorDepth)
    
    self.icon = CreateGUIObject("icon", GetTooltipWrappedClass(GMSBPasswordedIcon), self)
    self.icon:SetLayer(2)
    self.icon:AlignCenter()
    self.icon:SetTooltip(Locale.ResolveString("SERVERBROWSER_PASSWORD_TOOLTIP"))
    self:HookEvent(self.icon, "OnMouseClick", ForwardOnMouseClick)
    self:HookEvent(self.icon, "OnMouseRelease", ForwardOnMouseRelease)
    self:HookEvent(self.icon, "OnMouseUp", ForwardOnMouseUp)
    
    assert(self.entry)
    self:HookEvent(self.entry, "OnPasswordedChanged", OnPasswordedChanged)
    self:HookEvent(self.entry, "OnSelectedChanged", OnSelectedChanged)
    
    OnPasswordedChanged(self, self.entry:GetPassworded())
    OnSelectedChanged(self, self.entry:GetSelected())
    
end

RegisterServerBrowserColumnType("Passworded", GMSBColumnHeadingPassworded, GMSBColumnContentsPassworded, 86, 384)
