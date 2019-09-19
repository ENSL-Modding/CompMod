-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/NavBar/Screens/ServerBrowser/Columns/GMSBColumnRanked.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Defines the header and contents classes for the "ranked" column of the server browser.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/menu2/NavBar/Screens/ServerBrowser/GMSBColumn.lua")
Script.Load("lua/menu2/NavBar/Screens/ServerBrowser/GMSBColumnHeadingIcon.lua")
Script.Load("lua/menu2/NavBar/Screens/ServerBrowser/GMSBRankedIcon.lua")
Script.Load("lua/menu2/NavBar/Screens/ServerBrowser/GMSBNotRankedIcon.lua")
Script.Load("lua/menu2/wrappers/Tooltip.lua")

local kRankedIconTexture = PrecacheAsset("ui/newMenu/server_browser/ranked_dim.dds")

---@class GMSBColumnHeadingRanked : GMSBColumnHeadingIcon
---@field public GetTooltip function @From Tooltip wrapper
---@field public SetTooltip function @From Tooltip wrapper
local baseClass = GetTooltipWrappedClass(GMSBColumnHeadingIcon)
class "GMSBColumnHeadingRanked" (baseClass)

local function OnHeadingPressed(self)
    
    local serverBrowser = GetServerBrowser()
    assert(serverBrowser)
    
    -- If they want to sort by ranked servers, we can assume they want to see all servers
    -- (otherwise what would be the point?)
    serverBrowser:SetFilterValue("unranked", true)
    
    if serverBrowser:GetSortFunction() == ServerBrowserSortFunctions.Ranked then
        serverBrowser:SetSortFunction(ServerBrowserSortFunctions.RankedReversed)
    else
        serverBrowser:SetSortFunction(ServerBrowserSortFunctions.Ranked)
    end
    
end

function GMSBColumnHeadingRanked:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    PushParamChange(params, "texture", kRankedIconTexture)
    PushParamChange(params, "tooltip", Locale.ResolveString("SERVERBROWSER_RANKED_SORT_TOOLTIP"))
    baseClass.Initialize(self, params, errorDepth)
    PopParamChange(params, "tooltip")
    PopParamChange(params, "texture")
    
    self:HookEvent(self, "OnPressed", OnHeadingPressed)
    
end

---@class GMSBColumnContentsRanked : GMSBColumnContents
class "GMSBColumnContentsRanked" (GMSBColumnContents)

local function OnRankedChanged(self, ranked, prevRanked)
    self.rankedIcon:SetVisible(ranked)
    self.notRankedIcon:SetVisible(not ranked)
end

local function OnSelectedChanged(self, selected, prevSelected)
    self.rankedIcon:SetGlowing(selected)
    self.notRankedIcon:SetGlowing(selected)
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

function GMSBColumnContentsRanked:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    GMSBColumnContents.Initialize(self, params, errorDepth)
    
    self.rankedIcon = CreateGUIObject("rankedIcon", GetTooltipWrappedClass(GMSBRankedIcon), self)
    self.rankedIcon:SetLayer(2)
    self.rankedIcon:AlignCenter()
    self.rankedIcon:SetTooltip(Locale.ResolveString("SERVERBROWSER_RANKED_TOOLTIP"))
    self.rankedIcon:ListenForCursorInteractions()
    self:HookEvent(self.rankedIcon, "OnMouseClick", ForwardOnMouseClick)
    self:HookEvent(self.rankedIcon, "OnMouseRelease", ForwardOnMouseRelease)
    self:HookEvent(self.rankedIcon, "OnMouseUp", ForwardOnMouseUp)
    
    self.notRankedIcon = CreateGUIObject("notRankedIcon", GetTooltipWrappedClass(GMSBNotRankedIcon), self)
    self.notRankedIcon:SetLayer(2)
    self.notRankedIcon:AlignCenter()
    self.notRankedIcon:SetTooltip(Locale.ResolveString("SERVERBROWSER_UNRANKED_TOOLTIP"))
    self.notRankedIcon:ListenForCursorInteractions()
    self:HookEvent(self.notRankedIcon, "OnMouseClick", ForwardOnMouseClick)
    self:HookEvent(self.notRankedIcon, "OnMouseRelease", ForwardOnMouseRelease)
    self:HookEvent(self.notRankedIcon, "OnMouseUp", ForwardOnMouseUp)
    
    assert(self.entry)
    self:HookEvent(self.entry, "OnRankedChanged", OnRankedChanged)
    self:HookEvent(self.entry, "OnSelectedChanged", OnSelectedChanged)
    
    OnRankedChanged(self, self.entry:GetRanked())
    OnSelectedChanged(self, self.entry:GetSelected())
    
end

RegisterServerBrowserColumnType("Ranked", GMSBColumnHeadingRanked, GMSBColumnContentsRanked, 86, 512)
