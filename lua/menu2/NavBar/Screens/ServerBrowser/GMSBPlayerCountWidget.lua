-- ======= Copyright (c) 2017, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/NavBar/Screens/ServerBrowser/GMSBPlayerCountWidget.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Small counter with an icon indicating the number of players in the currently displayed
--    servers, versus the total number of players active in ns2.  This is just a display -- it only
--    displays the data it is given from the Server Browser.
--  
--  Properties
--      SearchingCount          The number of players perusing the server browser.
--      TotalPlayers            The total number of players playing NS2 at the moment.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/GUIText.lua")
Script.Load("lua/GUI/layouts/GUIListLayout.lua")
Script.Load("lua/menu2/wrappers/Tooltip.lua")

---@class GMSBPlayerCountWidget : GUIObject
class "GMSBPlayerCountWidget" (GUIObject)

GMSBPlayerCountWidget:AddClassProperty("TotalPlayers", 0)
GMSBPlayerCountWidget:AddClassProperty("SearchingCount", 0)

local kSpacing = 10
local kGroupSpacing = 20
local kPeopleIconTexture = PrecacheAsset("ui/newMenu/server_browser/people_icon.dds")
local kSearchingIconTexture = PrecacheAsset("ui/newMenu/server_browser/searching_icon.dds")
local kColor = MenuStyle.kLightGrey
local kFont = MenuStyle.kServerBrowserPopulationTextFont

local function UpdateTotalPlayersText(self)
    self.totalCount:SetText(string.format("%d", self:GetTotalPlayers()))
end

local function UpdateSearchingCountText(self)
    self.searchingCount:SetText(string.format("%d", self:GetSearchingCount()))
end

function GMSBPlayerCountWidget:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    GUIObject.Initialize(self, params, errorDepth)
    
    self.layout = CreateGUIObject("layout", GUIListLayout, self,
    {
        orientation = "horizontal",
        spacing = kGroupSpacing,
    })
    
    self:HookEvent(self.layout, "OnSizeChanged", self.SetSize)
    
    -- Create player count objects.
    self.playerCountLayout = CreateGUIObject("playerCountLayout", GetTooltipWrappedClass(GUIListLayout), self.layout,
    {
        orientation = "horizontal",
        tooltip = Locale.ResolveString("SERVERBROWSER_PLAYERCOUNT"),
        spacing = kSpacing,
    })
    self.playerCountLayout:ListenForCursorInteractions()
    
    self.totalGraphic = self.playerCountLayout:CreateGUIItem()
    self.totalGraphic:SetTexture(kPeopleIconTexture)
    self.totalGraphic:SetSizeFromTexture()
    self.totalGraphic:SetColor(kColor)
    self.totalGraphic:AlignLeft()
    
    self.totalCount = CreateGUIObject("totalCount", GUIText, self.playerCountLayout)
    self.totalCount:SetFont(kFont)
    self.totalCount:SetColor(kColor)
    self.totalCount:AlignLeft()
    self:HookEvent(self, "OnTotalPlayersChanged", UpdateTotalPlayersText)
    UpdateTotalPlayersText(self)
    
    -- Create searching count objects.
    self.searchingCountLayout = CreateGUIObject("searchingCountLayout", GetTooltipWrappedClass(GUIListLayout), self.layout,
    {
        orientation = "horizontal",
        tooltip = Locale.ResolveString("SERVERBROWSER_PLAYERS_SEARCHING"),
        spacing = kSpacing,
    })
    self.searchingCountLayout:ListenForCursorInteractions()
    
    self.searchingGraphic = self.searchingCountLayout:CreateGUIItem()
    self.searchingGraphic:SetTexture(kSearchingIconTexture)
    self.searchingGraphic:SetSizeFromTexture()
    self.searchingGraphic:SetColor(kColor)
    self.searchingGraphic:AlignLeft()
    
    self.searchingCount = CreateGUIObject("searchingCount", GUIText, self.searchingCountLayout)
    self.searchingCount:SetFont(kFont)
    self.searchingCount:SetColor(kColor)
    self.searchingCount:AlignLeft()
    self:HookEvent(self, "OnSearchingCountChanged", UpdateSearchingCountText)
    UpdateSearchingCountText(self)
    
end

