-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Effects.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
--
-- Sound, effect and animation data to be used by the effect manager.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/EffectsGlobals.lua")
Script.Load("lua/EffectManager.lua")


-- Load effect data, adding to effect manager
Script.Load("lua/GeneralEffects.lua")
Script.Load("lua/PlayerEffects.lua")
Script.Load("lua/DamageEffects.lua")

Script.Load("lua/MarineStructureEffects.lua")
Script.Load("lua/MarineWeaponEffects.lua")
Script.Load("lua/AlienStructureEffects.lua")
Script.Load("lua/AlienWeaponEffects.lua")


-- Pre-cache effect assets AND also calculate number of shared decals for the network message...
GetEffectManager():PrecacheEffects()
