-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/GUILocalPlayerProfileData.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--    
--    Singleton GUI object that just serves to hold data related to the local player.  Yea, it's a
--    bit odd, wasteful to use a GUIObject for this, as there's no visual component -- just data,
--    but it's more than worth it to leverage the provided event callback system, which is super
--    convenient when dealing with async stuff.
--  
--  Properties
--      PlayerName      The player's in-game name.
--      Skill           The player's hive skill value.
--      Level           The player's hive level.
--      XP              The amount of experience the player has.
--      Score           Total amount of points player has earned.
--      AdagradSum      Not a clue what this is, but it's used in hive skill calculation.
--  
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/GUIObject.lua")
Script.Load("lua/UnorderedSet.lua")
Script.Load("lua/Badges_Client.lua")

-- Define a special value to indicate that no AdagradSum data is available (this is NOT the same as
-- 0).  We need this because property values cannot be nil.
do
    local kNoAdagradSum = {"NoAdagradSum"}
    setmetatable(kNoAdagradSum, { __tostring = function() return "{NoAdagradSum}" end })
    NoAdagradSum = ReadOnly(kNoAdagradSum)
end

---@class GUILocalPlayerProfileData : GUIObject
class "GUILocalPlayerProfileData" (GUIObject)

local kSpoofHiveLevelOptionPath = "debug/spoof-hive-level"

GUILocalPlayerProfileData:AddClassProperty("PlayerName", "")
GUILocalPlayerProfileData:AddClassProperty("Skill", -1)
GUILocalPlayerProfileData:AddClassProperty("Level", -1)
GUILocalPlayerProfileData:AddClassProperty("XP", 0)
GUILocalPlayerProfileData:AddClassProperty("Score", 0)
GUILocalPlayerProfileData:AddClassProperty("AdagradSum", NoAdagradSum, true)

local profileDataObject
function GetLocalPlayerProfileData()
    return profileDataObject
end

local function RequestDataFromHive(self)
    
    local steamId = Client.GetSteamId()
    local requestUrl = string.format("%s%s", kPlayerRankingRequestUrl, steamId)
    
    Shared.SendHTTPRequest(requestUrl, "GET", { },
        function(playerData)
            local obj, pos, err = json.decode(playerData, 1, nil)
            
            if not obj then
                return
            end
            
            -- It's possible that the server didn't send all data we want.  Fill in nil values
            -- appropriately.
            obj.skill = obj.skill or 0
            obj.level = obj.level or 0
            obj.xp    = obj.xp    or 0
            obj.score = obj.score or 0
            
            Analytics.RecordLaunch( steamId, obj.level, obj.score, obj.time_played )
            
            Badges_FetchBadges(nil, obj.badges)
    
            -- For debugging, we can spoof the level we're on.
            local level = Client.GetOptionInteger(kSpoofHiveLevelOptionPath, -1)
            if level == -1 then
                level = obj.level
            end
            
            self:SetSkill(obj.skill)
            self:SetLevel(level)
            self:SetXP(obj.xp)
            self:SetScore(obj.score)
            self:SetAdagradSum(obj.adagrad_sum or NoAdagradSum)
    
            -- Inform the badge customizer that the owned badges set might have changed.
            local badgeCustomizer = GetBadgeCustomizer()
            if badgeCustomizer then
                badgeCustomizer:UpdateOwnedBadges()
            end
            
        end)
    
end

function GUILocalPlayerProfileData:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    GUIObject.Initialize(self, params, errorDepth)
    
    profileDataObject = self
    
    UpdatePlayerNicknameFromOptions() -- ensure the nickname has been initialized.
    
    RequestDataFromHive(self)
    
end

function GUILocalPlayerProfileData:GetIsRookie()
    
    return self:GetLevel() <= kRookieLevel
    
end

function GUILocalPlayerProfileData:GetSkillTierAndName()
    
    local adagradSum = self:GetAdagradSum()
    if adagradSum == NoAdagradSum then
        adagradSum = nil
    end
    
    local skillTier, skillTierName = GetPlayerSkillTier(self:GetSkill(), self:GetIsRookie(), adagradSum)
    return skillTier, skillTierName
    
end

function GUILocalPlayerProfileData:GetSkillTier()
    
    local skillTier, skillTierName = self:GetSkillTierAndName()
    return skillTier
    
end

function GUILocalPlayerProfileData:GetSkillTierName()
    
    local skillTier, skillTierName = self:GetSkillTierAndName()
    return skillTierName
    
end

-- DEBUG
Event.Hook("Console_debug_spoof_hive_level", function(level)
    
    level = tonumber(level)
    if level and math.floor(level) ~= level then
        level = nil
    end
    
    if not level then
        Log("Usage: spoof_hive_level levelNumber")
        Log("    levelNumber must be an integer.  If negative, disables the spoof.")
        return
    end
    
    Log("Setting spoofed level to %s", level)
    Client.SetOptionInteger(kSpoofHiveLevelOptionPath, level)
    
end)

