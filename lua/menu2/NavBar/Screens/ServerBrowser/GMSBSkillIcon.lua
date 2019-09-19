-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/NavBar/Screens/ServerBrowser/GMSBSkillIcon.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Icon for a ranked server.
--
--  Properties:
--      SkillTier   The skill tier that this icon is currently displaying.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/GUIObject.lua")
Script.Load("lua/menu2/wrappers/Tooltip.lua")

local kTexture = PrecacheAsset("ui/skill_tier_icons.dds")
local kBadgeSize = Vector(100, 32, 0)
local kBadgeCount = 10 -- stacked vertically.

---@class GMSBSkillIcon : GUIObject
---@field public GetTooltip function @From Tooltip wrapper
---@field public SetTooltip function @From Tooltip wrapper
local baseClass = GetTooltipWrappedClass(GUIObject)
class "GMSBSkillIcon" (baseClass)

GMSBSkillIcon:AddClassProperty("SkillTier", 1)

local function UpdateDisplayedBadge(self)
    
    local skillTier = self:GetSkillTier()
    local textureIndex = skillTier + 2
    local skillTierDesc = GetSkillTierDescription(skillTier)
    
    self:SetTexturePixelCoordinates(0, textureIndex * kBadgeSize.y, kBadgeSize.x, (textureIndex + 1) * kBadgeSize.y)
    self:SetTooltip(Locale.ResolveString(skillTierDesc))
    
end

function GMSBSkillIcon:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    baseClass.Initialize(self, params, errorDepth)
    
    self:SetSize(kBadgeSize)
    self:SetTexture(kTexture)
    self:SetColor(1, 1, 1, 1)
    
    self:HookEvent(self, "OnSkillTierChanged", UpdateDisplayedBadge)
    UpdateDisplayedBadge(self)
    
end
