-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/NavBar/Screens/ServerBrowser/Columns/GMSBColumnSkill.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Defines the header and contents classes for the "skill" column of the server browser.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/menu2/NavBar/Screens/ServerBrowser/GMSBColumn.lua")
Script.Load("lua/menu2/NavBar/Screens/ServerBrowser/GMSBColumnHeadingText.lua")
Script.Load("lua/menu2/NavBar/Screens/ServerBrowser/GMSBSkillIcon.lua")
Script.Load("lua/menu2/wrappers/Tooltip.lua")

---@class GMSBColumnHeadingSkill : GMSBColumnHeadingText
---@field public GetTooltip function @From Tooltip wrapper
---@field public SetTooltip function @From Tooltip wrapper
local baseClass = GetTooltipWrappedClass(GMSBColumnHeadingText)
class "GMSBColumnHeadingSkill" (baseClass)

local function OnHeadingPressed(self)
    
    local serverBrowser = GetServerBrowser()
    assert(serverBrowser)
    
    if serverBrowser:GetSortFunction() == ServerBrowserSortFunctions.Skill then
        serverBrowser:SetSortFunction(ServerBrowserSortFunctions.SkillReversed)
    else
        serverBrowser:SetSortFunction(ServerBrowserSortFunctions.Skill)
    end
    
end

function GMSBColumnHeadingSkill:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    PushParamChange(params, "label", Locale.ResolveString("SERVERBROWSER_SKILL"))
    PushParamChange(params, "tooltip", Locale.ResolveString("SERVERBROWSER_SKILL_SORT_TOOLTIP"))
    baseClass.Initialize(self, params, errorDepth)
    PopParamChange(params, "tooltip")
    PopParamChange(params, "label")
    
    self:HookEvent(self, "OnPressed", OnHeadingPressed)
    
end


---@class GMSBColumnContentsSkill : GMSBColumnContents
class "GMSBColumnContentsSkill" (GMSBColumnContents)

local function UpdateSkillTier(self)
    
    local skill = self.entry:GetSkill()
    
    local skillTier
    if self.entry:GetPlayerCount() <= 0 then
        skillTier = -2
    else
        skillTier = GetPlayerSkillTier(skill, self.entry:GetRookieOnly())
    end
    
    self.skillIcon:SetSkillTier(skillTier)
    
end

function GMSBColumnContentsSkill:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    GMSBColumnContents.Initialize(self, params, errorDepth)
    
    self.skillIcon = CreateGUIObject("skillIcon", GMSBSkillIcon, self)
    self.skillIcon:AlignCenter()
    
    assert(self.entry)
    self:HookEvent(self.entry, "OnSkillChanged", UpdateSkillTier)
    self:HookEvent(self.entry, "OnRookieOnlyChanged", UpdateSkillTier)
    self:HookEvent(self.entry, "OnPlayerCountChanged", UpdateSkillTier)
    UpdateSkillTier(self)
    
end

RegisterServerBrowserColumnType("Skill", GMSBColumnHeadingSkill, GMSBColumnContentsSkill, 150, 576)
