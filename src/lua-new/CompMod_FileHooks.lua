g_compModRevision = 999

-- Balance
ModLoader.SetupFileHook("lua/Balance.lua", "lua/CompMod/Balance/Balance.lua", "post")
-- ModLoader.SetupFileHook("lua/BalanceHealth.lua", "lua/CompMod/Balance/BalanceHealth.lua", "post")
-- ModLoader.SetupFileHook("lua/BalanceMisc.lua", "lua/CompMod/Balance/BalanceMisc.lua", "post")

-- Classes
ModLoader.SetupFileHook("lua/Marine.lua", "lua/CompMod/Classes/Marine/Marine.lua", "post")
ModLoader.SetupFileHook("lua/Player_Client.lua", "lua/CompMod/Classes/Player/Player_Client.lua", "post")

-- Damage Classes
ModLoader.SetupFileHook("lua/DamageTypes.lua", "lua/CompMod/Damage/DamageTypes.lua", "post")

-- GUI
ModLoader.SetupFileHook("lua/GUIFeedback.lua", "lua/CompMod/GUI/GUIFeedback.lua", "post")
ModLoader.SetupFileHook("lua/GUIPlayerStatus.lua", "lua/CompMod/GUI/GUIPlayerStatus.lua", "post")
ModLoader.SetupFileHook("lua/GUIScoreboard.lua", "lua/CompMod/GUI/GUIScoreboard.lua", "post")

-- Mixins
ModLoader.SetupFileHook("lua/MucousableMixin.lua", "lua/CompMod/Mixins/MucousableMixin.lua", "post")

-- NS2Utility
ModLoader.SetupFileHook("lua/NS2Utility_Server.lua", "lua/CompMod/NS2Utility/NS2Utility_Server.lua", "post")

-- Alien Structures
ModLoader.SetupFileHook("lua/CommAbilities/Alien/BoneWall.lua", "lua/CompMod/Structures/Alien/BoneWall.lua", "post")
ModLoader.SetupFileHook("lua/Crag.lua", "lua/CompMod/Structures/Alien/Crag.lua", "post")
ModLoader.SetupFileHook("lua/Cyst.lua", "lua/CompMod/Structures/Alien/Cyst.lua", "post")

-- Marine Structures
ModLoader.SetupFileHook("lua/Armory.lua", "lua/CompMod/Structures/Marine/Armory.lua", "post")
ModLoader.SetupFileHook("lua/CommandStructure_Server.lua", "lua/CompMod/Structures/CommandStructure_Server.lua", "post")

-- Alien Units
ModLoader.SetupFileHook("lua/Drifter.lua", "lua/CompMod/Units/Alien/Drifter/Drifter.lua", "post")
ModLoader.SetupFileHook("lua/Hallucination.lua", "lua/CompMod/Units/Alien/Hallucination/Hallucination.lua", "post")

-- Randoms
ModLoader.SetupFileHook("lua/NS2ConsoleCommands_Server.lua", "lua/CompMod/NS2ConsoleCommands_Server.lua", "replace")
