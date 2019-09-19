-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/menu2/MissionScreen/MissionUtils.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Utilities used in defining missions.
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

gMissionScreenConfigs = {}

-- Set of step names, to catch duplicates.
local stepNames = {}

-- Creates a mission step that simply checks an achievement to see if it has been satisfied or not.
--     *name            Name of the step.  Must be unique across ALL missions, not just the one it
--                      belongs to.
--     *title           Title to display for this step.
--     *description     Description to display for this step.
--     *achievement     The achievement to associate with this step.  If the achievement is
--                      satisfied, this step is satisfied.
--      legacy          Check for old option names to determine if step was previously finished or
--                      not.  Should only be enabled for steps that existed prior to the new menu
--                      going in (all the new player steps).
--      legacyTitle     Title of the step in the old menu (for the ONE case where it changed...)
--      pressCallback   Callback function to be called when the user clicks on the achievement.
--                      Passes the GUIMenuMissionStep as the first (self) parameter.
function CreateAchievementMissionStepConfig(params)
    
    RequireType("string", params.name, "params.name", 2)
    RequireType("string", params.title, "params.title", 2)
    RequireType("string", params.description, "params.description", 2)
    RequireType("string", params.achievement, "params.achievement", 2)
    RequireType({"boolean", "nil"}, params.legacy, "params.legacy", 2)
    RequireType({"string", "nil"}, params.legacyTitle, "params.legacyTitle", 2)
    RequireType({"function", "nil"}, params.pressCallback, "params.pressCallback", 2)
    
    if stepNames[params.name] then
        error(string.format("Mission step named '%s' already exists!", params.name), 2)
    end
    stepNames[params.name] = true
    
    return
    {
        name = params.name,
        class = GUIMenuMissionStep,
        params =
        {
            title = params.title,
            legacyTitle = params.legacyTitle,
            description = params.description,
            pressCallback = params.pressCallback,
        },
        postInit = function(self)
            
            -- Determine if item is currently checked off.
            assert(Client)
            local done = Client.GetAchievement(params.achievement)
            self:SetCompleted(done)
            
            -- Have this step listen for the achievement granting/revoking events.
            self:HookEvent(GetGlobalEventDispatcher(), "OnAchievementSet",
                function(self, achievementName)
                    if achievementName == params.achievement then
                        self:SetCompleted(true)
                    end
                end)
            self:HookEvent(GetGlobalEventDispatcher(), "OnAchievementCleared",
                    function(self, achievementName)
                        if achievementName == params.achievement then
                            self:SetCompleted(false)
                        end
                    end)
        
        end,
    }
    
end
