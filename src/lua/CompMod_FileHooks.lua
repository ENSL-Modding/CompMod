ModLoader.SetupFileHook("lua/Balance.lua", "lua/CompMod/Balance.lua", "post")
-- ModLoader.SetupFileHook("lua/BalanceHealth.lua", "lua/CompMod/BalanceHealth.lua", "post")
-- ModLoader.SetupFileHook("lua/BalanceMisc.lua", "lua/CompMod/BalanceMisc.lua", "post")

ModLoader.SetupFileHook("lua/Marine.lua", "lua/CompMod/Classes/Marine/Marine.lua", "post")
ModLoader.SetupFileHook("lua/Player_Client.lua", "lua/CompMod/Classes/Player/Player_Client.lua", "post")

ModLoader.SetupFileHook("lua/GUIFeedback.lua", "lua/CompMod/GUI/GUIFeedback.lua", "post")
ModLoader.SetupFileHook("lua/GUIPlayerStatus.lua", "lua/CompMod/GUI/GUIPlayerStatus.lua", "post")
ModLoader.SetupFileHook("lua/GUIScoreboard.lua", "lua/CompMod/GUI/GUIScoreboard.lua", "post")

ModLoader.SetupFileHook("lua/MucousableMixin.lua", "lua/CompMod/Mixins/MucousableMixin.lua", "post")

ModLoader.SetupFileHook("lua/NS2Utility_Server.lua", "lua/CompMod/NS2Utility/NS2Utility_Server.lua", "post")

ModLoader.SetupFileHook("lua/Armory.lua", "lua/CompMod/Structures/Marine/Armory.lua", "post")
ModLoader.SetupFileHook("lua/CommandStructure_Server.lua", "lua/CompMod/Structures/CommandStructure_Server.lua", "post")

ModLoader.SetupFileHook("lua/NS2ConsoleCommands_Server.lua", "lua/CompMod/NS2ConsoleCommands_Server.lua", "replace")
