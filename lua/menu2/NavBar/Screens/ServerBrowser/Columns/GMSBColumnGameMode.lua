-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/NavBar/Screens/ServerBrowser/Columns/GMSBColumnGameMode.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Defines the header and contents classes for the "game mode" column of the server browser.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/menu2/NavBar/Screens/ServerBrowser/GMSBColumn.lua")
Script.Load("lua/menu2/NavBar/Screens/ServerBrowser/GMSBColumnHeadingText.lua")
Script.Load("lua/menu2/wrappers/Tooltip.lua")

---@class GMSBCOlumnGameMode : GMSBColumnHeadingText
---@field public GetTooltip function @From Tooltip wrapper
---@field public SetTooltip function @From Tooltip wrapper
local baseClass = GetTooltipWrappedClass(GMSBColumnHeadingText)
class "GMSBColumnHeadingGameMode" (baseClass)

local function OnHeadingPressed(self)
    
    local serverBrowser = GetServerBrowser()
    assert(serverBrowser)
    
    if serverBrowser:GetSortFunction() == ServerBrowserSortFunctions.GameModeReversed then
        serverBrowser:SetSortFunction(ServerBrowserSortFunctions.GameMode)
    else
        serverBrowser:SetSortFunction(ServerBrowserSortFunctions.GameModeReversed)
    end
    
end

function GMSBColumnHeadingGameMode:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    PushParamChange(params, "label", Locale.ResolveString("SERVERBROWSER_GAME"))
    PushParamChange(params, "tooltip", Locale.ResolveString("SERVERBROWSER_GAME_MODE_SORT_TOOLTIP"))
    baseClass.Initialize(self, params, errorDepth)
    PopParamChange(params, "tooltip")
    PopParamChange(params, "label")
    
    self:HookEvent(self, "OnPressed", OnHeadingPressed)
    
end


---@class GMSBCOlumnContentsGameMode : GMSBCOlumnContents
class "GMSBColumnContentsGameMode" (GMSBColumnContents)

local function UpdateGameMode(self)
    
    local selected = self.entry:GetSelected()
    local exists = self.entry:GetExists()
    local gameMode = self.entry:GetGameMode()
    
    if not exists or gameMode == "" then
        self.text:SetText("???")
        self.text:SetColor(MenuStyle.kServerBrowserIconDim)
    else
        
        self.text:SetText(gameMode)
        if selected then
            self.text:SetColor(MenuStyle.kHighlight)
        else
            self.text:SetColor(MenuStyle.kServerNameColor)
        end
        
    end
    
end

function GMSBColumnContentsGameMode:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    GMSBColumnContents.Initialize(self, params, errorDepth)
    
    self.text = CreateGUIObject("text", GUIText, self)
    self.text:AlignCenter()
    self.text:SetFont(MenuStyle.kServerNameFont)
    self.text:SetColor(MenuStyle.kServerBrowserIconDim)
    self.text:SetText("???")
    
    assert(self.entry)
    self:HookEvent(self.entry, "OnGameModeChanged", UpdateGameMode)
    self:HookEvent(self.entry, "OnSelectedChanged", UpdateGameMode)
    self:HookEvent(self.entry, "OnExistsChanged", UpdateGameMode)
    
    UpdateGameMode(self)
    
end

RegisterServerBrowserColumnType("GameMode", GMSBColumnHeadingGameMode, GMSBColumnContentsGameMode, 420, 768)
