-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/menu2/PlayerScreen/GUIMenuSkillTierIcon.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Widget that displays a skill tier icon.  The icon displayed is automatically chosen based on
--    some properties present in the object.
--
--  Parameters (* = required)
--
--  Properties
--      SteamID64       Steam id (64 bit format, as a string) of the player using this skill badge.
--                      Optional.  If not used, should be "".  In some special circumstances, skill
--                      tier icons can be awarded regardless of skill (eg nsl tournament winners).
--      IsRookie        True/false for if the player is a rookie (they get a different badge,
--                      regardless of skill).
--      Skill           Hive skill of the player.
--      IsBot           True/false if the player is a bot.
--      AdagradSum      AdagradSum value of the player (used to reduce skill noise, prevent tier
--                      from changing too often).  Use NoAdagradSum in place of nil (property values
--                      cannot be nil).
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/menu2/GUILocalPlayerProfileData.lua")

Script.Load("lua/SpecialSkillTierRecipients.lua")

---@class GUIMenuSkillTierIcon : GUIObject
---@field public GetTooltip function @From Tooltip wrapper
---@field public SetTooltip function @From Tooltip wrapper
local baseClass = GUIObject
class "GUIMenuSkillTierIcon" (baseClass)

local kDefaultSkillTierIconShader = "shaders/GUIBasic.surface_shader"
local kDefaultSkillTierIconTexture = PrecacheAsset("ui/skill_tier_icons.dds")
local kDefaultSkillTierIconSize = Vector(100, 32, 0)

local kDefaultWidgetSize = Vector(kDefaultSkillTierIconSize)

GUIMenuSkillTierIcon:AddClassProperty("SteamID64", "")
GUIMenuSkillTierIcon:AddClassProperty("IsRookie", false)
GUIMenuSkillTierIcon:AddClassProperty("Skill", 0)
GUIMenuSkillTierIcon:AddClassProperty("IsBot", false)
GUIMenuSkillTierIcon:AddClassProperty("AdagradSum", NoAdagradSum, true)

local function UpdateIconScale(self)
    
    local widgetX = self:GetSize().x
    local widgetY = self:GetSize().y
    
    local iconX = self.icon:GetSize().x
    local iconY = self.icon:GetSize().y
    
    local scaleX = widgetX / iconX
    local scaleY = widgetY / iconY
    
    local scale
    local flipX = 1.0
    local flipY = 1.0
    if iconX == 0 then
        if iconY == 0 then
            scale = 1.0
        else
            scale = scaleY
            flipX = scaleY < 0.0 and -1.0 or 1.0
            flipY = scaleY < 0.0 and -1.0 or 1.0
        end
    elseif iconY == 0 then
        scale = scaleX
        flipX = scaleX < 0.0 and -1.0 or 1.0
        flipY = scaleX < 0.0 and -1.0 or 1.0
    else
        flipX = scaleX < 0.0 and -1.0 or 1.0
        flipY = scaleY < 0.0 and -1.0 or 1.0
        scale = math.min(math.abs(scaleX), math.abs(scaleY))
    end
    
    self.icon:SetScale(scale * flipX, scale * flipY)
    
end

function GUIMenuSkillTierIcon:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    baseClass.Initialize(self, params, errorDepth)
    
    self:SetSize(kDefaultWidgetSize)
    
    self.icon = CreateGUIObject("icon", GetTooltipWrappedClass(GUIObject), self)
    self.icon:SetColor(1, 1, 1, 1)
    self.icon:SetOpacity(1)
    self.icon:AlignCenter()
    self:HookEvent(self.icon, "OnSizeChanged", UpdateIconScale)
    self:HookEvent(self, "OnSizeChanged", UpdateIconScale)
    
    self:HookEvent(self, "OnSteamID64Changed", self.UpdateIcon)
    self:HookEvent(self, "OnIsRookieChanged", self.UpdateIcon)
    self:HookEvent(self, "OnSkillChanged", self.UpdateIcon)
    self:HookEvent(self, "OnIsBotChanged", self.UpdateIcon)
    self:HookEvent(self, "OnAdagradSumChanged", self.UpdateIcon)
    self:UpdateIcon()
    
end

function GUIMenuSkillTierIcon:GetIconObject()
    return self.icon
end

function GUIMenuSkillTierIcon:UpdateIcon()

    local iconObj = self:GetIconObject()
    
    local steamId = self:GetSteamID64()
    local isRookie = self:GetIsRookie()
    local skill = self:GetSkill()
    local isBot = self:GetIsBot()
    local adagradSum = self:GetAdagradSum()
    if adagradSum == NoAdagradSum then
        adagradSum = nil
    end
    
    local steamId32 = Client.ConvertSteamId64To32(steamId)
    local skillIconOverrideSettings = CheckForSpecialBadgeRecipient(steamId32)
    if skillIconOverrideSettings then
        
        iconObj:SetShader(skillIconOverrideSettings.shader)
        iconObj:SetTexture(skillIconOverrideSettings.tex)
        iconObj:SetSize(kDefaultSkillTierIconSize)
        iconObj:SetTooltip(skillIconOverrideSettings.tooltip)
        if skillIconOverrideSettings.texCoords then
            iconObj:SetTextureCoordinates(skillIconOverrideSettings.texCoords[1],
                    skillIconOverrideSettings.texCoords[2],
                    skillIconOverrideSettings.texCoords[3],
                    skillIconOverrideSettings.texCoords[4])
        elseif skillIconOverrideSettings.texPixCoords then
            iconObj:SetTexturePixelCoordinates(skillIconOverrideSettings.texPixCoords[1],
                    skillIconOverrideSettings.texPixCoords[2],
                    skillIconOverrideSettings.texPixCoords[3],
                    skillIconOverrideSettings.texPixCoords[4])
        end
        if skillIconOverrideSettings.frameCount then
            iconObj:SetFloatParameter("frameCount", skillIconOverrideSettings.frameCount)
        end
        
    else
    
        iconObj:SetShader(kDefaultSkillTierIconShader)
        iconObj:SetTexture(kDefaultSkillTierIconTexture)
        iconObj:SetSize(kDefaultSkillTierIconSize)
    
        local skillTier, tierTooltip = GetPlayerSkillTier(skill, isRookie, adagradSum, isBot)
        local textureIndex = skillTier + 2
        iconObj:SetTexturePixelCoordinates(0, textureIndex * 32, 100, textureIndex * 32 + 32)
        iconObj:SetTooltip(string.format(Locale.ResolveString("SKILLTIER_TOOLTIP"), Locale.ResolveString(tierTooltip), skillTier))
        
    end
    
end
