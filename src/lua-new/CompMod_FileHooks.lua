g_compModRevision = 999

-- Balance
ModLoader.SetupFileHook("lua/Balance.lua", "lua/CompMod/Balance/Balance.lua", "post")
-- ModLoader.SetupFileHook("lua/BalanceHealth.lua", "lua/CompMod/Balance/BalanceHealth.lua", "post")
-- ModLoader.SetupFileHook("lua/BalanceMisc.lua", "lua/CompMod/Balance/BalanceMisc.lua", "post")

-- Alien Buy
ModLoader.SetupFileHook("lua/AlienBuy_Client.lua", "lua/CompMod/Buy/Alien/AlienBuy_Client.lua", "post")

-- Alien Classes
ModLoader.SetupFileHook("lua/Embryo.lua", "lua/CompMod/Classes/Alien/Embryo.lua", "post")
ModLoader.SetupFileHook("lua/Fade_Server.lua", "lua/CompMod/Classes/Alien/Fade_Server.lua", "post")
-- Marine Classes
ModLoader.SetupFileHook("lua/Marine.lua", "lua/CompMod/Classes/Marine/Marine.lua", "post")
-- Player Classes
ModLoader.SetupFileHook("lua/Player_Client.lua", "lua/CompMod/Classes/Player/Player_Client.lua", "post")

-- Console Commands
ModLoader.SetupFileHook("lua/NS2ConsoleCommands_Server.lua", "lua/CompMod/ConsoleCommands/NS2ConsoleCommands_Server.lua", "replace")

-- Damage Files
ModLoader.SetupFileHook("lua/DamageTypes.lua", "lua/CompMod/Damage/DamageTypes.lua", "post")

-- Alien Entities
ModLoader.SetupFileHook("lua/Babbler.lua", "lua/CompMod/Entities/Alien/Babbler.lua", "post")

-- GUI
ModLoader.SetupFileHook("lua/GUIFeedback.lua", "lua/CompMod/GUI/GUIFeedback.lua", "post")
ModLoader.SetupFileHook("lua/GUIPlayerStatus.lua", "lua/CompMod/GUI/GUIPlayerStatus.lua", "post")
ModLoader.SetupFileHook("lua/GUIScoreboard.lua", "lua/CompMod/GUI/GUIScoreboard.lua", "post")

-- Mixins
ModLoader.SetupFileHook("lua/BabblerOwnerMixin.lua", "lua/CompMod/Mixins/BabblerOwnerMixin.lua", "post")
ModLoader.SetupFileHook("lua/MucousableMixin.lua", "lua/CompMod/Mixins/MucousableMixin.lua", "post")

-- NS2Utility
ModLoader.SetupFileHook("lua/NS2Utility_Server.lua", "lua/CompMod/NS2Utility/NS2Utility_Server.lua", "post")

-- Alien Structures
ModLoader.SetupFileHook("lua/CommAbilities/Alien/BoneWall.lua", "lua/CompMod/Structures/Alien/BoneWall.lua", "post")
ModLoader.SetupFileHook("lua/Crag.lua", "lua/CompMod/Structures/Alien/Crag.lua", "post")
ModLoader.SetupFileHook("lua/Cyst.lua", "lua/CompMod/Structures/Alien/Cyst.lua", "post")
ModLoader.SetupFileHook("lua/Egg.lua", "lua/CompMod/Structures/Alien/Egg.lua", "post")
ModLoader.SetupFileHook("lua/Hive_Server.lua", "lua/CompMod/Structures/Alien/Hive_Server.lua", "post")
-- Marine Structures
ModLoader.SetupFileHook("lua/Armory.lua", "lua/CompMod/Structures/Marine/Armory.lua", "post")
ModLoader.SetupFileHook("lua/CommandStructure_Server.lua", "lua/CompMod/Structures/CommandStructure_Server.lua", "post")

-- Teams
ModLoader.SetupFileHook("lua/AlienTeam.lua", "lua/CompMod/Teams/AlienTeam.lua", "post")
ModLoader.SetupFileHook("lua/TeamInfo.lua", "lua/CompMod/Teams/TeamInfo.lua", "post")

-- Tech
ModLoader.SetupFileHook("lua/AlienTechMap.lua", "lua/CompMod/Tech/AlienTechMap.lua", "post")
ModLoader.SetupFileHook("lua/EvolutionChamber.lua", "lua/CompMod/Tech/EvolutionChamber.lua", "post")
ModLoader.SetupFileHook("lua/TechData.lua", "lua/CompMod/Tech/TechData.lua", "post")
ModLoader.SetupFileHook("lua/TechTreeButtons.lua", "lua/CompMod/Tech/TechTreeButtons.lua", "post")

-- Alien Units
ModLoader.SetupFileHook("lua/Drifter.lua", "lua/CompMod/Units/Alien/Drifter/Drifter.lua", "post")
ModLoader.SetupFileHook("lua/Hallucination.lua", "lua/CompMod/Units/Alien/Hallucination/Hallucination.lua", "post")

-- Alien Weapons
ModLoader.SetupFileHook("lua/Weapons/Alien/SwipeBlink.lua", "lua/CompMod/Weapons/Alien/SwipeBlink.lua", "post")
