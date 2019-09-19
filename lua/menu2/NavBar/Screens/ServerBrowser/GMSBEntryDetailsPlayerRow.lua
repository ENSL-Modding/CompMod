-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. ============
--
-- lua/menu2/NavBar/Screens/ServerBrowser/GMSBEntryDetailsPlayerRow.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    A row of player stats to appear in the details box of the server browser entry.  Contains the
--    player's name, score, and time played on the server.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =======================

Script.Load("lua/GUI/GUIObject.lua")
Script.Load("lua/GUI/GUIText.lua")

---@class GMSBEntryDetailsPlayerRow : GUIObject
class "GMSBEntryDetailsPlayerRow" (GUIObject)

GMSBEntryDetailsPlayerRow:AddCompositeClassProperty("PlayerName", "playerName", "Text")
GMSBEntryDetailsPlayerRow:AddClassProperty("Score", -1)
GMSBEntryDetailsPlayerRow:AddClassProperty("TimePlayed", -1) -- in seconds.

GMSBEntryDetailsPlayerRow.kTimeXOffset = 540
GMSBEntryDetailsPlayerRow.kScoreXOffset = 940
GMSBEntryDetailsPlayerRow.kDefaultSize = Vector(1200, 48, 0)

local function FormatTime(time)

    local seconds = math.round(time)
    local minutes = math.floor(seconds / 60)
    local hours = math.floor(minutes / 60)
    minutes = minutes - hours * 60
    seconds = seconds - minutes * 60 - hours * 3600
    local result = string.format("%d:%.2d:%.2d", hours, minutes, seconds)
    return result
    
end

local function OnTimePlayedChanged(self, timePlayed)
    self.playerTime:SetText(FormatTime(timePlayed))
end

local function OnScoreChanged(self, score)
    self.playerScore:SetText(tostring(score))
end

function GMSBEntryDetailsPlayerRow:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    GUIObject.Initialize(self, params, errorDepth)
    
    self:SetSize(self.kDefaultSize)
    
    self.playerName = CreateGUIObject("playerName", GUIText, self)
    self.playerName:SetFont(MenuStyle.kServerNameFont)
    self.playerName:SetColor(MenuStyle.kServerNameColor)
    self.playerName:AlignLeft()
    
    self.playerTime = CreateGUIObject("playerTime", GUIText, self)
    self.playerTime:SetFont(MenuStyle.kServerNameFont)
    self.playerTime:SetColor(MenuStyle.kServerBrowserHighlightDarker)
    self.playerTime:AlignLeft()
    self.playerTime:SetPosition(self.kTimeXOffset, 0)
     
    self.playerScore = CreateGUIObject("playerScore", GUIText, self)
    self.playerScore:SetFont(MenuStyle.kServerNameFont)
    self.playerScore:SetColor(MenuStyle.kServerBrowserHighlightDarker)
    self.playerScore:AlignLeft()
    self.playerScore:SetPosition(self.kScoreXOffset, 0)
    
    self:HookEvent(self, "OnScoreChanged", OnScoreChanged)
    self:HookEvent(self, "OnTimePlayedChanged", OnTimePlayedChanged)
    
end
