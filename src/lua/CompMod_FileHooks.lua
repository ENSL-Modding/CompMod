g_compModRevision = 9

-- Alien Buy
ModLoader.SetupFileHook("lua/AlienBuy_Client.lua", "lua/CompMod/Buy/Alien/AlienBuy_Client.lua", "post")

-- Alien Classes
ModLoader.SetupFileHook("lua/Alien_Client.lua", "lua/CompMod/Classes/Alien/Alien_Client.lua", "post")
ModLoader.SetupFileHook("lua/Alien_Server.lua", "lua/CompMod/Classes/Alien/Alien_Server.lua", "post")
ModLoader.SetupFileHook("lua/Embryo.lua", "lua/CompMod/Classes/Alien/Embryo.lua", "post")
ModLoader.SetupFileHook("lua/Fade_Server.lua", "lua/CompMod/Classes/Alien/Fade_Server.lua", "post")
ModLoader.SetupFileHook("lua/Fade.lua", "lua/CompMod/Classes/Alien/Fade.lua", "post")
ModLoader.SetupFileHook("lua/Gorge.lua", "lua/CompMod/Classes/Alien/Gorge.lua", "post")
ModLoader.SetupFileHook("lua/Lerk.lua", "lua/CompMod/Classes/Alien/Lerk.lua", "post")
ModLoader.SetupFileHook("lua/Onos.lua", "lua/CompMod/Classes/Alien/Onos.lua", "post")
ModLoader.SetupFileHook("lua/Skulk.lua", "lua/CompMod/Classes/Alien/Skulk.lua", "post")
-- Marine Classes
ModLoader.SetupFileHook("lua/Exo.lua", "lua/CompMod/Classes/Marine/Exo.lua", "post")
ModLoader.SetupFileHook("lua/Marine.lua", "lua/CompMod/Classes/Marine/Marine.lua", "post")
-- Player Classes
ModLoader.SetupFileHook("lua/Player_Client.lua", "lua/CompMod/Classes/Player/Player_Client.lua", "post")

-- Alien Comm Abilities
ModLoader.SetupFileHook("lua/CommAbilities/Alien/BoneWall.lua", "lua/CompMod/CommAbilities/Alien/BoneWall.lua", "post")
ModLoader.SetupFileHook("lua/CommAbilities/Alien/MucousMembrane.lua", "lua/CompMod/CommAbilities/Alien/MucousMembrane.lua", "post")

-- Console Commands
ModLoader.SetupFileHook("lua/NS2ConsoleCommands_Server.lua", "lua/CompMod/ConsoleCommands/NS2ConsoleCommands_Server.lua", "replace")

-- Damage Files
ModLoader.SetupFileHook("lua/DamageTypes.lua", "lua/CompMod/Damage/DamageTypes.lua", "post")

-- Alien Entities
ModLoader.SetupFileHook("lua/Babbler.lua", "lua/CompMod/Entities/Alien/Babbler.lua", "post")
-- Player Entities
ModLoader.SetupFileHook("lua/PlayerInfoEntity.lua", "lua/CompMod/Entities/Player/PlayerInfoEntity.lua", "post")
-- Base Entities
ModLoader.SetupFileHook("lua/ScriptActor.lua", "lua/CompMod/Entities/ScriptActor.lua", "post")

-- Globals
ModLoader.SetupFileHook("lua/Balance.lua", "lua/CompMod/Globals/Balance.lua", "post")
ModLoader.SetupFileHook("lua/Globals.lua", "lua/CompMod/Globals/Globals.lua", "post")

-- GUI
ModLoader.SetupFileHook("lua/GUIAuraDisplay.lua", "lua/CompMod/GUI/GUIAuraDisplay.lua", "post")
ModLoader.SetupFileHook("lua/GUIFeedback.lua", "lua/CompMod/GUI/GUIFeedback.lua", "post")
ModLoader.SetupFileHook("lua/GUIInsight_Overhead.lua", "lua/CompMod/GUI/GUIInsight_Overhead.lua", "post")
ModLoader.SetupFileHook("lua/GUIInsight_TopBar.lua", "lua/CompMod/GUI/GUIInsight_TopBar.lua", "post")
ModLoader.SetupFileHook("lua/GUIMarineBuyMenu.lua", "lua/CompMod/GUI/GUIMarineBuyMenu.lua", "post")
ModLoader.SetupFileHook("lua/Hud/GUIPlayerStatus.lua", "lua/CompMod/GUI/GUIPlayerStatus.lua", "post")
ModLoader.SetupFileHook("lua/GUIScoreboard.lua", "lua/CompMod/GUI/GUIScoreboard.lua", "post")
ModLoader.SetupFileHook("lua/GUIUpgradeChamberDisplay.lua", "lua/CompMod/GUI/GUIUpgradeChamberDisplay.lua", "post")

-- Mixins
ModLoader.SetupFileHook("lua/BabblerClingMixin.lua", "lua/CompMod/Mixins/BabblerClingMixin.lua", "post")
ModLoader.SetupFileHook("lua/BabblerOwnerMixin.lua", "lua/CompMod/Mixins/BabblerOwnerMixin.lua", "post")
ModLoader.SetupFileHook("lua/CloakableMixin.lua", "lua/CompMod/Mixins/CloakableMixin.lua", "post")
ModLoader.SetupFileHook("lua/MucousableMixin.lua", "lua/CompMod/Mixins/MucousableMixin.lua", "post")
ModLoader.SetupFileHook("lua/PlayerHallucinationMixin.lua", "lua/CompMod/Mixins/PlayerHallucinationMixin.lua", "post")
ModLoader.SetupFileHook("lua/RegenerationMixin.lua", "lua/CompMod/Mixins/RegenerationMixin.lua", "post")

-- Network
ModLoader.SetupFileHook("lua/NetworkMessages_Server.lua", "lua/CompMod/Network/NetworkMessages_Server.lua", "post")

-- NS2Utility
ModLoader.SetupFileHook("lua/NS2Utility_Server.lua", "lua/CompMod/NS2Utility/NS2Utility_Server.lua", "post")

-- Physics
ModLoader.SetupFileHook("lua/PhysicsGroups.lua", "lua/CompMod/Physics/PhysicsGroups.lua", "post")

-- Alien Structures
ModLoader.SetupFileHook("lua/Crag.lua", "lua/CompMod/Structures/Alien/Crag.lua", "post")
ModLoader.SetupFileHook("lua/Cyst.lua", "lua/CompMod/Structures/Alien/Cyst.lua", "post")
ModLoader.SetupFileHook("lua/Egg.lua", "lua/CompMod/Structures/Alien/Egg.lua", "post")
ModLoader.SetupFileHook("lua/Hive_Server.lua", "lua/CompMod/Structures/Alien/Hive_Server.lua", "post")
ModLoader.SetupFileHook("lua/TunnelEntrance.lua", "lua/CompMod/Structures/Alien/TunnelEntrance.lua", "post")
-- Marine Structures
ModLoader.SetupFileHook("lua/Armory_Server.lua", "lua/CompMod/Structures/Marine/Armory_Server.lua", "post")
ModLoader.SetupFileHook("lua/Armory.lua", "lua/CompMod/Structures/Marine/Armory.lua", "post")
ModLoader.SetupFileHook("lua/PrototypeLab.lua", "lua/CompMod/Structures/Marine/PrototypeLab.lua", "post")
ModLoader.SetupFileHook("lua/Sentry.lua", "lua/CompMod/Structures/Marine/Sentry.lua", "post")
-- Shared Structures
ModLoader.SetupFileHook("lua/CommandStructure_Server.lua", "lua/CompMod/Structures/CommandStructure_Server.lua", "post")

-- Teams
ModLoader.SetupFileHook("lua/AlienTeam.lua", "lua/CompMod/Teams/AlienTeam.lua", "post")
ModLoader.SetupFileHook("lua/MarineTeam.lua", "lua/CompMod/Teams/MarineTeam.lua", "post")
ModLoader.SetupFileHook("lua/TeamInfo.lua", "lua/CompMod/Teams/TeamInfo.lua", "post")

-- Tech
ModLoader.SetupFileHook("lua/AlienTechMap.lua", "lua/CompMod/Tech/AlienTechMap.lua", "post")
ModLoader.SetupFileHook("lua/EvolutionChamber.lua", "lua/CompMod/Tech/EvolutionChamber.lua", "post")
ModLoader.SetupFileHook("lua/MarineTechMap.lua", "lua/CompMod/Tech/MarineTechMap.lua", "post")
ModLoader.SetupFileHook("lua/TechData.lua", "lua/CompMod/Tech/TechData.lua", "post")
ModLoader.SetupFileHook("lua/TechNode.lua" , "lua/CompMod/Tech/TechNode.lua", "post")
ModLoader.SetupFileHook("lua/TechTreeButtons.lua", "lua/CompMod/Tech/TechTreeButtons.lua", "post")
ModLoader.SetupFileHook("lua/TechTreeConstants.lua", "lua/CompMod/Tech/TechTreeConstants.lua", "post")

-- Alien Units
ModLoader.SetupFileHook("lua/Drifter.lua", "lua/CompMod/Units/Alien/Drifter.lua", "post")
ModLoader.SetupFileHook("lua/Hallucination.lua", "lua/CompMod/Units/Alien/Hallucination.lua", "post")

-- Alien Weapons
ModLoader.SetupFileHook("lua/Weapons/Alien/Ability.lua", "lua/CompMod/Weapons/Alien/Ability.lua", "post")
ModLoader.SetupFileHook("lua/Weapons/Alien/BiteLeap.lua", "lua/CompMod/Weapons/Alien/BiteLeap.lua", "post")
ModLoader.SetupFileHook("lua/Weapons/Alien/BoneShield.lua", "lua/CompMod/Weapons/Alien/BoneShield.lua", "post")
ModLoader.SetupFileHook("lua/Weapons/Alien/Gore.lua", "lua/CompMod/Weapons/Alien/Gore.lua", "post")
ModLoader.SetupFileHook("lua/Weapons/Alien/LerkBite.lua", "lua/CompMod/Weapons/Alien/LerkBite.lua", "post")
ModLoader.SetupFileHook("lua/Weapons/Alien/Spit.lua", "lua/CompMod/Weapons/Alien/Spit.lua", "post")
ModLoader.SetupFileHook("lua/Weapons/Alien/SpitSpray.lua", "lua/CompMod/Weapons/Alien/SpitSpray.lua", "post")
ModLoader.SetupFileHook("lua/Weapons/Alien/StabBlink.lua", "lua/CompMod/Weapons/Alien/StabBlink.lua", "post")
ModLoader.SetupFileHook("lua/Weapons/Alien/SwipeBlink.lua", "lua/CompMod/Weapons/Alien/SwipeBlink.lua", "post")
ModLoader.SetupFileHook("lua/Weapons/Alien/Web.lua", "lua/CompMod/Weapons/Alien/Web.lua", "post")

-- Marine Weapons
ModLoader.SetupFileHook("lua/Weapons/Marine/Flame.lua", "lua/CompMod/Weapons/Marine/Flame.lua", "post")
ModLoader.SetupFileHook("lua/Weapons/Marine/Shotgun.lua", "lua/CompMod/Weapons/Marine/Shotgun.lua", "post")
-- Shared Weapons
ModLoader.SetupFileHook("lua/Weapons/DotMarker.lua", "lua/CompMod/Weapons/DotMarker.lua", "post")
ModLoader.SetupFileHook("lua/Weapons/Weapon_Server.lua", "lua/CompMod/Weapons/Weapon_Server.lua", "post")
