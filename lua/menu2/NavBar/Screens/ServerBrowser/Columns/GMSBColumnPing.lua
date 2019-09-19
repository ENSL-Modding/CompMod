-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/NavBar/Screens/ServerBrowser/Columns/GMSBColumnPing.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Defines the header and contents classes for the "ping" column of the server browser.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/menu2/NavBar/Screens/ServerBrowser/GMSBColumn.lua")
Script.Load("lua/menu2/NavBar/Screens/ServerBrowser/GMSBColumnHeadingText.lua")

---@class GMSBColumnHeadingPing : GMSBColumnHeadingText
class "GMSBColumnHeadingPing" (GMSBColumnHeadingText)

local kTerriblePing = 300
local kBadPing = 200
local kOkayPing = 100
-- good ping < kOkayPing

local function OnHeadingPressed(self)
    
    local serverBrowser = GetServerBrowser()
    assert(serverBrowser)
    
    if serverBrowser:GetSortFunction() == ServerBrowserSortFunctions.Ping then
        serverBrowser:SetSortFunction(ServerBrowserSortFunctions.PingReversed)
    else
        serverBrowser:SetSortFunction(ServerBrowserSortFunctions.Ping)
    end
    
end

function GMSBColumnHeadingPing:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    PushParamChange(params, "label", Locale.ResolveString("SERVERBROWSER_PING"))
    GMSBColumnHeadingText.Initialize(self, params, errorDepth)
    PopParamChange(params, "label")
    
    self:HookEvent(self, "OnPressed", OnHeadingPressed)
    
end


---@class GMSBColumnContentsPing : GMSBColumnContents
class "GMSBColumnContentsPing" (GMSBColumnContents)

local function UpdatePing(self)
    local ping = self.entry:GetPing()
    local exists = self.entry:GetExists()
    
    if exists then
        self.text:SetText(string.format("%d", ping))
        
        local color
        if ping >= kTerriblePing then
            color = MenuStyle.kPingColorTerrible
        elseif ping >= kBadPing then
            color = MenuStyle.kPingColorBad
        elseif ping >= kOkayPing then
            color = MenuStyle.kPingColorOkay
        else
            color = MenuStyle.kPingColorGood
        end
        self.text:SetColor(color)
    else
        self.text:SetColor(MenuStyle.kServerBrowserIconDim)
        self.text:SetText("???")
    end
    
end

function GMSBColumnContentsPing:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    GMSBColumnContents.Initialize(self, params, errorDepth)
    
    self.text = CreateGUIObject("text", GUIText, self)
    self.text:SetFont(MenuStyle.kServerNameFont)
    self.text:AlignCenter()
    self.text:SetText("???")
    self.text:SetColor(MenuStyle.kServerBrowserIconDim)
    
    assert(self.entry)
    self:HookEvent(self.entry, "OnPingChanged", UpdatePing)
    self:HookEvent(self.entry, "OnExistsChanged", UpdatePing)
    UpdatePing(self)
    
end

RegisterServerBrowserColumnType("Ping", GMSBColumnHeadingPing, GMSBColumnContentsPing, 200, 1024)
