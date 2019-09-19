-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/menu2/MissionScreen/MissionDefs/NewPlayerMission.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Mission for new players to earn the "eat your greens" shoulder patch.
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

local kGreensIcon = PrecacheAsset("ui/progress/skulk.dds")

local tutorialStepConfig = CreateAchievementMissionStepConfig
{
    name = "newPlayer_tutorialStep",
    title = Locale.ResolveString("MISSION_NEW_PLAYER_TUTORIALS"),
    description = Locale.ResolveString("WELCOME_PROGRESS_ENTRY_1_TEXT"),
    achievement = "First_0_1",
    legacy = true,
    legacyTitle = Locale.ResolveString("WELCOME_PROGRESS_ENTRY_1_TITLE"),
    pressCallback = function(self)
        GetScreenManager():DisplayScreen("Training")
    end,
}

local useQuickPlayConfig = CreateAchievementMissionStepConfig
{
    name = "newPlayer_quickPlay",
    title = Locale.ResolveString("WELCOME_PROGRESS_ENTRY_2_TITLE"),
    description = Locale.ResolveString("WELCOME_PROGRESS_ENTRY_2_TEXT"),
    achievement = "First_0_2",
    legacy = true,
    pressCallback = function(self)
        DoQuickJoin()
    end,
}

local playAsMarineConfig = CreateAchievementMissionStepConfig
{
    name = "newPlayer_playAsMarine",
    title = Locale.ResolveString("WELCOME_PROGRESS_ENTRY_3_TITLE"),
    description = Locale.ResolveString("WELCOME_PROGRESS_ENTRY_3_TEXT"),
    achievement = "First_0_3",
    legacy = true,
    pressCallback = function(self)
        DoQuickJoin()
    end,
}

local playAsAlienConfig = CreateAchievementMissionStepConfig
{
    name = "newPlayer_playAsAlien",
    title = Locale.ResolveString("WELCOME_PROGRESS_ENTRY_4_TITLE"),
    description = Locale.ResolveString("WELCOME_PROGRESS_ENTRY_4_TEXT"),
    achievement = "First_0_4",
    legacy = true,
    pressCallback = function(self)
        DoQuickJoin()
    end,
}

local play3MapsConfig = CreateAchievementMissionStepConfig
{
    name = "newPlayer_play3Maps",
    title = Locale.ResolveString("WELCOME_PROGRESS_ENTRY_5_TITLE"),
    description = Locale.ResolveString("WELCOME_PROGRESS_ENTRY_5_TEXT"),
    achievement = "First_0_5",
    legacy = true,
    pressCallback = function(self)
        DoQuickJoin()
    end,
}

assert(GUIMenuMissionScreen) -- *should* have been loaded by now...
GUIMenuMissionScreen.AddMissionConfig(
{
    name = "mission_newPlayer",
    class = GUIMenuMission,
    params =
    {
        missionName = Locale.ResolveString("MISSION_NEW_PLAYER_TITLE"),
        completionCheckTex = kGreensIcon,
        completionDescription = Locale.ResolveString("MISSION_NEW_PLAYER_COMPLETION_DESCRIPTION"),
        stepConfigs =
        {
            tutorialStepConfig,
            useQuickPlayConfig,
            playAsMarineConfig,
            playAsAlienConfig,
            play3MapsConfig,
        },
        completedCallback = function()
            if not Client.GetAchievement("First_1_0") then
                Client.SetAchievement("First_1_0")
                Client.GrantPromoItems()
                InventoryNewItemNotifyPush( kRookieShoulderPatchItemId )
            end
        end,
    }
})

Script.Load("lua/GUI/GUIDebug.lua")

--DebugStuff() -- need to remove these before ship.
Event.Hook("Console_g_dbg_set_achievement", function(name)
    
    if not name then
        Log("usage: g_dbg_set_achievement achievement_code")
        return
    end
    
    Client.SetAchievement(name)
    Log("Set achievement '%s'", name)
    
end)
Event.Hook("Console_g_dbg_clear_achievement", function(name)
    
    if not name then
        Log("usage: g_dbg_clear_achievement achievement_code")
        return
    end
    
    Client.ClearAchievement(name)
    Log("Cleared achievement '%s'", name)

end)
Event.Hook("Console_g_dbg_reset_first_rookie_mission_step", function()

    Log("Reset new player tutorial step previously completed to false.")
    Client.SetOptionBoolean("menu/unlocked_newPlayer_tutorialStep", false)

end)
