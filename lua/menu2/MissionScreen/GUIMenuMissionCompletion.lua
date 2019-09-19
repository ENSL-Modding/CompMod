-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/menu2/MissionScreen/GUIMenuMissionCompletion.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Part of a mission that displays the current status of the mission, and what the reward is for
--    completing it.
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/menu2/MissionScreen/GUIMenuMissionStep.lua")

---@class GUIMenuMissionCompletion : GUIMenuMissionStep
local baseClass = GUIMenuMissionStep
class "GUIMenuMissionCompletion" (baseClass)

GUIMenuMissionCompletion.kTitleColor = HexToColor("da2815")

local function UpdateTitleText(self)
    
    if self:GetCompleted() then
        self:SetTitle(Locale.ResolveString("MISSION_COMPLETE"))
    else
        self:SetTitle(Locale.ResolveString("MISSION_INCOMPLETE"))
    end

end

function GUIMenuMissionCompletion:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    PushParamChange(params, "title", Locale.ResolveString("MISSION_INCOMPLETE"))
    baseClass.Initialize(self, params, errorDepth)
    PopParamChange(params, "title")
    
    self:HookEvent(self, "OnCompletedChanged", UpdateTitleText)
    
end
