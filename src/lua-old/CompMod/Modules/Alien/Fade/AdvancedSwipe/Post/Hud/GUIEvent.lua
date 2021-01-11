local kUnlockIconParams

local function GetUnlockIconParams(unlockId)

    if not kUnlockIconParams then

        kUnlockIconParams = { }

        kUnlockIconParams[kTechId.FlamethrowerTech] =       { description = "EVT_FLAMETHROWER_RESEARCHED", bottomText = "EVT_BUY_AT_ARMORY" }
        kUnlockIconParams[kTechId.ShotgunTech] =            { description = "EVT_SHOTGUN_RESEARCHED", bottomText = "EVT_BUY_AT_ARMORY" }
        kUnlockIconParams[kTechId.HeavyMachineGunTech] =            { description = "EVT_HMG_RESEARCHED", bottomText = "EVT_BUY_AT_ARMORY" }
        kUnlockIconParams[kTechId.GrenadeLauncherTech] =    { description = "EVT_GRENADE_LAUNCHER_RESEARCHED", bottomText = "EVT_BUY_AT_ARMORY" }
        kUnlockIconParams[kTechId.GrenadeTech        ] =    { description = "EVT_GRENADES_RESEARCHED", bottomText = "EVT_BUY_AT_ARMORY" }
        kUnlockIconParams[kTechId.AdvancedWeaponry] =       { description = "EVT_ADVANCED_WEAPONRY_RESEARCHED", bottomText = "EVT_BUY_AT_ARMORY" }
        kUnlockIconParams[kTechId.DetonationTimeTech] =     { description = "EVT_DETONATION_TIME_RESEARCHED" }
        kUnlockIconParams[kTechId.JetpackTech] =            { description = "EVT_JETPACK_RESEARCHED", bottomText = "EVT_BUY_AT_PROTOTYPE_LAB" }
        kUnlockIconParams[kTechId.ExosuitTech] =            { description = "EVT_EXOSUIT_RESEARCHED", bottomText = "EVT_BUY_AT_PROTOTYPE_LAB" }
        kUnlockIconParams[kTechId.DualMinigunTech] =        { description = "EVT_DUALMINIGUN_RESEARCHED", bottomText = "EVT_BUY_AT_PROTOTYPE_LAB" }
        kUnlockIconParams[kTechId.ClawRailgunTech] =        { description = "EVT_CLAWRAILGUN_RESEARCHED", bottomText = "EVT_BUY_AT_PROTOTYPE_LAB" }
        kUnlockIconParams[kTechId.DualRailgunTech] =        { description = "EVT_DUALRAILGUN_RESEARCHED", bottomText = "EVT_BUY_AT_PROTOTYPE_LAB" }
        kUnlockIconParams[kTechId.WelderTech] =             { description = "EVT_WELDER_RESEARCHED", bottomText = "EVT_BUY_AT_ARMORY" }
        kUnlockIconParams[kTechId.MinesTech] =              { description = "EVT_MINES_RESEARCHED", bottomText = "EVT_BUY_AT_ARMORY" }

        kUnlockIconParams[kTechId.Armor1] = { description = "EVT_ARMOR_LEVEL_1_RESEARCHED" }
        kUnlockIconParams[kTechId.Armor2] = { description = "EVT_ARMOR_LEVEL_2_RESEARCHED" }
        kUnlockIconParams[kTechId.Armor3] = { description = "EVT_ARMOR_LEVEL_3_RESEARCHED" }

        kUnlockIconParams[kTechId.Weapons1] = { description = "EVT_WEAPON_LEVEL_1_RESEARCHED" }
        kUnlockIconParams[kTechId.Weapons2] = { description = "EVT_WEAPON_LEVEL_2_RESEARCHED" }
        kUnlockIconParams[kTechId.Weapons3] = { description = "EVT_WEAPON_LEVEL_3_RESEARCHED" }

        kUnlockIconParams[kTechId.Leap] = { description = "EVT_LEAP_RESEARCHED" }
        kUnlockIconParams[kTechId.BileBomb] = { description = "EVT_BILE_BOMB_RESEARCHED" }
        kUnlockIconParams[kTechId.Spores] = { description = "EVT_SPORES_RESEARCHED" }
        kUnlockIconParams[kTechId.Stomp] = { description = "EVT_STOMP_RESEARCHED" }
        kUnlockIconParams[kTechId.BoneShield] = { description = "EVT_BONESHIELD_RESEARCHED" }
        kUnlockIconParams[kTechId.Xenocide] = { description = "EVT_XENOCIDE_RESEARCHED" }
        kUnlockIconParams[kTechId.Umbra] = { description = "EVT_UMBRA_RESEARCHED" }
        kUnlockIconParams[kTechId.Vortex] = { description = "EVT_VORTEX_RESEARCHED" }
        --kUnlockIconParams[kTechId.GorgeTunnelTech] = { description = "EVT_GORGETUNNEL_RESEARCHED" }
        kUnlockIconParams[kTechId.WebTech] = { description = "EVT_WEBTECH_RESEARCHED" }
        kUnlockIconParams[kTechId.MetabolizeEnergy] = { description = "EVT_METABOLIZE_RESEARCHED" }
        kUnlockIconParams[kTechId.MetabolizeHealth] = { description = "EVT_METABOLIZE_ADV_RESEARCHED" }
        kUnlockIconParams[kTechId.Stab] = { description = "EVT_STAB_RESEARCHED" }
        kUnlockIconParams[kTechId.AdvancedSwipe] = { description = "EVT_SWIPE_ADV_RESEARCHED"}
        kUnlockIconParams[kTechId.Charge] = { description = "EVT_CHARGE_RESEARCHED" }
        kUnlockIconParams[kTechId.BoneShield] = { description = "EVT_BONESHIELD_RESEARCHED" }

        kUnlockIconParams[kTechId.UpgradeSkulk] = { description = "EVT_SKULK_UPGRADED" }
        kUnlockIconParams[kTechId.UpgradeGorge] = { description = "EVT_GORGE_UPGRADED" }
        kUnlockIconParams[kTechId.UpgradeLerk] = { description = "EVT_LERK_UPGRADED" }
        kUnlockIconParams[kTechId.UpgradeFade] = { description = "EVT_FADE_UPGRADED" }
        kUnlockIconParams[kTechId.UpgradeOnos] = { description = "EVT_ONOS_UPGRADED" }

    end

    if kUnlockIconParams[unlockId] then

        return Locale.ResolveString(kUnlockIconParams[unlockId].description),
        kUnlockIconParams[unlockId].bottomText and Locale.ResolveString(kUnlockIconParams[unlockId].bottomText) or nil

    end

end

function GUIEvent:UpdateUnlockDisplay(unlockId)

    local description, bottomText = GetUnlockIconParams(unlockId)

    self.unlockDescription:SetText(ConditionalValue(description ~= nil, description, ""))
    self.unlockBottomText:SetText(ConditionalValue(bottomText ~= nil, bottomText, ""))

    self.unlockIcon:SetTexturePixelCoordinates(GUIUnpackCoords(GetTextureCoordinatesForIcon(unlockId)))

end