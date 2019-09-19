-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/menu2/PlayerScreen/GUIMenuXPDisplay.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Widget that displays information about the player's level, XP, and progress to the next level.
--    Width can be set to whatever you want, but height should be fixed.
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/GUI/GUIObject.lua")
Script.Load("lua/GUI/GUIText.lua")

Script.Load("lua/menu2/PlayerScreen/GUIMenuXPBar.lua")

Script.Load("lua/PlayerRanking.lua")

---@class GUIMenuXPDisplay : GUIObject
class "GUIMenuXPDisplay" (GUIObject)

local kFixedHeight = 237

local kCurrentLevelPosition = Vector(7, 99, 0)
local kNextLevelPosition = Vector(-7, 99, 0)
local kXPBarYOffset = 144
local kXPBarHeight = 42
local kStartXPNumberPosition = Vector(7, 219, 0)
local kEndXPNumberPosition = Vector(-7, 219, 0)

local kLabelFont = ReadOnly{family = "AgencyBold", size = 55}
local kLevelNumberFont = ReadOnly{family = "AgencyBold", size = 46}
local kXPNumberFont = ReadOnly{family = "Agency", size = 37}

-- Returns an integer as a string, inserting commas around groups of 3 digits.
local function FormatInteger(n)
    local asString = tostring(n)
    for i=#asString - 3, 1, -3 do
        asString = string.sub(asString, 1, i)..","..string.sub(asString, i+1, #asString)
    end
    return asString
end

local function UpdateData(self)
    
    local level = GetLocalPlayerProfileData():GetLevel()
    local xp = GetLocalPlayerProfileData():GetXP()
    
    self.currentLevelText:SetText(FormatInteger(level))
    self.nextLevelText:SetText(FormatInteger(level+1))
    
    local currentLevelXP = PlayerRanking_GetTotalXpNeededForLevel(level)
    local nextLevelXP = PlayerRanking_GetTotalXpNeededForLevel(level+1)
    
    self.currentXPNumber:SetText(FormatInteger(xp).."xp")
    
    local barFrac = 0
    local xpDiff = nextLevelXP - currentLevelXP
    if xpDiff ~= 0 then
        barFrac = (xp - currentLevelXP) / xpDiff
    end
    barFrac = Clamp(barFrac, 0, 1)
    self.xpBar:SetBarFrac(barFrac)
    
end

local function UpdateFixedHeight(self)
    self:SetHeight(kFixedHeight)
end

function GUIMenuXPDisplay:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    GUIObject.Initialize(self, params, errorDepth)
    
    self.label = CreateGUIObject("label", GUIText, self,
    {
        font = kLabelFont,
        text = Locale.ResolveString("LEVEL"),
        align = "top",
        color = MenuStyle.kOptionHeadingColor,
    })
    
    self.currentLevelText = CreateGUIObject("currentLevelText", GUIText, self,
    {
        font = kLevelNumberFont,
        text = "",
        hotSpot = Vector(0, 0.5, 0),
        color = MenuStyle.kOptionHeadingColor,
        position = kCurrentLevelPosition,
    })
    
    self.nextLevelText = CreateGUIObject("nextLevelText", GUIText, self,
    {
        font = kLevelNumberFont,
        text = "",
        anchor = Vector(1, 0, 0),
        hotSpot = Vector(1, 0.5, 0),
        color = MenuStyle.kOptionHeadingColor,
        position = kNextLevelPosition,
    })
    
    self.xpBar = CreateGUIObject("xpBar", GUIMenuXPBar, self)
    self.xpBar:SetY(kXPBarYOffset)
    self.xpBar:SetHeight(kXPBarHeight)
    self.xpBar:HookEvent(self, "OnSizeChanged", self.xpBar.SetWidth)
    
    self.currentXPNumber = CreateGUIObject("currentXPNumber", GUIText, self,
    {
        font = kXPNumberFont,
        text = "",
        anchor = Vector(0.5, 0, 0),
        hotSpot = Vector(0.5, 0.5, 0),
        color = MenuStyle.kOptionHeadingColor,
        position = Vector(0, kEndXPNumberPosition.y, 0),
    })
    self:HookEvent(GetLocalPlayerProfileData(), "OnLevelChanged", UpdateData)
    self:HookEvent(GetLocalPlayerProfileData(), "OnXPChanged", UpdateData)
    UpdateData(self)
    
    self:HookEvent(self, "OnSizeChanged", UpdateFixedHeight)
    UpdateFixedHeight(self)
    
end
