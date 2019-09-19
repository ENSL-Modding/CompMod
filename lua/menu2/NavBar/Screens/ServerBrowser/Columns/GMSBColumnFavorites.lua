-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/NavBar/Screens/ServerBrowser/Columns/GMSBColumnFavorites.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Defines the header and contents classes for the "favorites" column of the server browser.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/menu2/NavBar/Screens/ServerBrowser/GMSBColumn.lua")
Script.Load("lua/menu2/NavBar/Screens/ServerBrowser/GMSBColumnHeadingIcon.lua")
Script.Load("lua/menu2/NavBar/Screens/ServerBrowser/GMSBFavoriteButton.lua")
Script.Load("lua/menu2/wrappers/Tooltip.lua")

local kHeartIconEmptyTexture = PrecacheAsset("ui/newMenu/server_browser/heart_dim.dds")

---@class GMSBColumnHeadingFavorites : GMSBColumnHeadingIcon
---@field public GetTooltip function @From Tooltip wrapper
---@field public SetTooltip function @From Tooltip wrapper
local baseClass = GetTooltipWrappedClass(GMSBColumnHeadingIcon)
class "GMSBColumnHeadingFavorites" (baseClass)

local function OnHeadingPressed(self)
    
    local serverBrowser = GetServerBrowser()
    assert(serverBrowser)
    
    if serverBrowser:GetSortFunction() == ServerBrowserSortFunctions.FavoritesReversed then
        serverBrowser:SetSortFunction(ServerBrowserSortFunctions.Favorites)
    else
        serverBrowser:SetSortFunction(ServerBrowserSortFunctions.FavoritesReversed)
    end
    
end

function GMSBColumnHeadingFavorites:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    PushParamChange(params, "texture", kHeartIconEmptyTexture)
    PushParamChange(params, "tooltip", Locale.ResolveString("SERVERBROWSER_FAVORITES_SORT_TOOLTIP"))
    baseClass.Initialize(self, params, errorDepth)
    PopParamChange(params, "tooltip")
    PopParamChange(params, "texture")
    
    self:HookEvent(self, "OnPressed", OnHeadingPressed)
    
end


---@class GMSBColumnContentsFavorites : GMSBColumnContents
---@field public GetTooltip function @From Tooltip wrapper
---@field public SetTooltip function @From Tooltip wrapper
local ttWrappedCC = GetTooltipWrappedClass(GMSBColumnContents)
class "GMSBColumnContentsFavorites" (ttWrappedCC)

local function OnFavoritedChanged(self, favorited, prevFavorited)
    self.button:SetValue(favorited)
    if favorited then
        self:SetTooltip(Locale.ResolveString("SERVERBROWSER_FAVORITE_TOOLTIP_1"))
    else
        self:SetTooltip(Locale.ResolveString("SERVERBROWSER_FAVORITE_TOOLTIP_2"))
    end
end

local function OnSelectedChanged(self, selected, prevSelected)
    self.button:SetGlowing(selected)
end

local function OnPressed(self)
    self.entry:SetFavorited(self.button:GetValue())
end

function GMSBColumnContentsFavorites:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    ttWrappedCC.Initialize(self, params, errorDepth)
    
    self.button = CreateGUIObject("button", GMSBFavoriteButton, self)
    self.button:SetLayer(2)
    self.button:AlignCenter()
    
    assert(self.entry)
    self:HookEvent(self.entry, "OnFavoritedChanged", OnFavoritedChanged)
    self:HookEvent(self.entry, "OnSelectedChanged", OnSelectedChanged)
    
    self:HookEvent(self.button, "OnPressed", OnPressed)
    
    OnFavoritedChanged(self, self.entry:GetFavorited())
    OnSelectedChanged(self, self.entry:GetSelected())
    
end

RegisterServerBrowserColumnType("Favorites", GMSBColumnHeadingFavorites, GMSBColumnContentsFavorites, 86, 128)
