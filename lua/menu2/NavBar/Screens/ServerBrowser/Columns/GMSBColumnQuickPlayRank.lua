-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. ============
--
-- lua/menu2/NavBar/Screens/ServerBrowser/Columns/GMSBColumnQuickPlayRank.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Defines the header and contents classes for the "quick play rank" column of the server
--    browser.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =======================

Script.Load("lua/menu2/NavBar/Screens/ServerBrowser/GMSBColumn.lua")
Script.Load("lua/menu2/NavBar/Screens/ServerBrowser/GMSBColumnHeadingText.lua")
Script.Load("lua/menu2/wrappers/Tooltip.lua")

---@class GMSBColumnHeadingQuickPlayRank : GMSBCOlumnHeadingText
---@field public GetTooltip function @From Tooltip wrapper
---@field public SetTooltip function @From Tooltip wrapper
local baseClass = GetTooltipWrappedClass(GMSBColumnHeadingText)
class "GMSBColumnHeadingQuickPlayRank" (baseClass)

local function OnHeadingPressed(self)
    
    local serverBrowser = GetServerBrowser()
    assert(serverBrowser)
    
    if serverBrowser:GetSortFunction() == ServerBrowserSortFunctions.QuickPlayRank then
        serverBrowser:SetSortFunction(ServerBrowserSortFunctions.QuickPlayRankReversed)
    else
        serverBrowser:SetSortFunction(ServerBrowserSortFunctions.QuickPlayRank)
    end
    
end

function GMSBColumnHeadingQuickPlayRank:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    PushParamChange(params, "label", "#")
    PushParamChange(params, "tooltip", Locale.ResolveString("SERVERBROWSER_QUICK_PLAY_RANK_SORT_TOOLTIP"))
    baseClass.Initialize(self, params, errorDepth)
    PopParamChange(params, "tooltip")
    PopParamChange(params, "label")
    
    self:HookEvent(self, "OnPressed", OnHeadingPressed)
    
end


---@class GMSBColumnContentsQuickPlayRank : GMSBColumnContents
class "GMSBColumnContentsQuickPlayRank" (GMSBColumnContents)

local function OnQuickPlayRankIndexChanged(self, index)
    
    self.text:SetText(string.format("%d", index))
    
end

function GMSBColumnContentsQuickPlayRank:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    GMSBColumnContents.Initialize(self, params, errorDepth)
    
    self.text = CreateGUIObject("text", GUIText, self)
    self.text:SetFont(MenuStyle.kServerNameFont)
    self.text:SetColor(MenuStyle.kServerNameColor)
    self.text:AlignCenter()
    
    assert(self.entry)
    self:HookEvent(self.entry, "OnQuickPlayRankIndexChanged", OnQuickPlayRankIndexChanged)
    
    OnQuickPlayRankIndexChanged(self, self.entry:GetQuickPlayRankIndex())
    
end

RegisterServerBrowserColumnType("QuickPlayRank", GMSBColumnHeadingQuickPlayRank, GMSBColumnContentsQuickPlayRank, 86, 64)
