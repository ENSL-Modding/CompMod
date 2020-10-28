local gResearchToWeaponIds
function GetItemTechId(researchTechId)

    if not gResearchToWeaponIds then

        gResearchToWeaponIds = { }
        gResearchToWeaponIds[kTechId.ShotgunTech] = kTechId.Shotgun
        gResearchToWeaponIds[kTechId.DemolitionsTech] = { kTechId.GrenadeLauncher, kTechId.Flamethrower }
        gResearchToWeaponIds[kTechId.WelderTech] = kTechId.Welder
        gResearchToWeaponIds[kTechId.MinesTech] = kTechId.LayMines
        gResearchToWeaponIds[kTechId.JetpackTech] = kTechId.Jetpack
        gResearchToWeaponIds[kTechId.HeavyMachineGunTech] = kTechId.HeavyMachineGun
        gResearchToWeaponIds[kTechId.ExosuitTech] = kTechId.Exosuit
        gResearchToWeaponIds[kTechId.DualMinigunTech] = kTechId.DualMinigunExosuit
        gResearchToWeaponIds[kTechId.ClawRailgunTech] = kTechId.ClawRailgunExosuit
        gResearchToWeaponIds[kTechId.DualRailgunTech] = kTechId.DualRailgunExosuit

    end

    return gResearchToWeaponIds[researchTechId]

end
