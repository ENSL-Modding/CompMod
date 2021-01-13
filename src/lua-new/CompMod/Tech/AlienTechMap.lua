kAlienTechMapYStart = 2
local function CheckHasTech(techId)

    local techTree = GetTechTree()
    return techTree ~= nil and techTree:GetHasTech(techId)

end

local function SetShellIcon(icon)

    if CheckHasTech(kTechId.ThreeShells) then
        icon:SetTexturePixelCoordinates(GUIUnpackCoords(GetTextureCoordinatesForIcon(kTechId.ThreeShells)))
    elseif CheckHasTech(kTechId.TwoShells) then
        icon:SetTexturePixelCoordinates(GUIUnpackCoords(GetTextureCoordinatesForIcon(kTechId.TwoShells)))
    else
        icon:SetTexturePixelCoordinates(GUIUnpackCoords(GetTextureCoordinatesForIcon(kTechId.Shell)))
    end

end

local function SetVeilIcon(icon)

    if CheckHasTech(kTechId.ThreeVeils) then
        icon:SetTexturePixelCoordinates(GUIUnpackCoords(GetTextureCoordinatesForIcon(kTechId.ThreeVeils)))
    elseif CheckHasTech(kTechId.TwoVeils) then
        icon:SetTexturePixelCoordinates(GUIUnpackCoords(GetTextureCoordinatesForIcon(kTechId.TwoVeils)))
    else
        icon:SetTexturePixelCoordinates(GUIUnpackCoords(GetTextureCoordinatesForIcon(kTechId.Veil)))
    end

end

local function SetSpurIcon(icon)

    if CheckHasTech(kTechId.ThreeSpurs) then
        icon:SetTexturePixelCoordinates(GUIUnpackCoords(GetTextureCoordinatesForIcon(kTechId.ThreeSpurs)))
    elseif CheckHasTech(kTechId.TwoSpurs) then
        icon:SetTexturePixelCoordinates(GUIUnpackCoords(GetTextureCoordinatesForIcon(kTechId.TwoSpurs)))
    else
        icon:SetTexturePixelCoordinates(GUIUnpackCoords(GetTextureCoordinatesForIcon(kTechId.Spur)))
    end

end

kAlienTechMap =
{
    { kTechId.Whip, 5.5, 0.5 }, { kTechId.Shift, 6.5, 0.5 }, { kTechId.Shade, 7.5, 0.5 }, { kTechId.Crag, 8.5, 0.5 },
    { kTechId.Harvester, 4, 1.5 }, { kTechId.Hive, 7, 1.5 }, { kTechId.Drifter, 10, 1.5 },
    { kTechId.ShiftHive, 4, 3 }, { kTechId.ShadeHive, 7, 3 }, { kTechId.CragHive, 10, 3 },

    { kTechId.DrifterCelerity, 5, 3 },  { kTechId.DrifterCamouflage, 8, 3 }, { kTechId.DrifterRegeneration, 11, 3 },

    { kTechId.CystCelerity, 3, 3 }, { kTechId.CystCamouflage, 6, 3 }, { kTechId.CystCarapace, 9, 3 },

    --FIXME Update and correct all icon positions
    { kTechId.Spur, 4, 4, SetSpurIcon }, { kTechId.Veil, 7, 4, SetVeilIcon }, { kTechId.Shell, 10, 4, SetShellIcon },

    { kTechId.Crush, 3, 5 },
    { kTechId.Celerity, 4, 5 },
    { kTechId.Adrenaline, 5, 5 },

    { kTechId.Focus, 6, 5 },
    { kTechId.Camouflage, 7, 5 },
    { kTechId.Aura, 8, 5 },

    { kTechId.Vampirism, 9, 5 },
    { kTechId.Carapace, 10, 5 },
    { kTechId.Regeneration, 11, 5 },

    { kTechId.BioMassOne, 3, 7, nil, "1" }, { kTechId.BabblerEgg, 3, 8 }, {kTechId.WebTech, 3, 9},
    { kTechId.BioMassTwo, 4, 7, nil, "2" }, {kTechId.Rupture, 4, 8},  { kTechId.Charge, 4, 9 }, { kTechId.BileBomb, 4, 10 }
    { kTechId.BioMassThree, 5, 7, nil, "3" }, {kTechId.BoneWall, 5, 8}, { kTechId.MetabolizeEnergy, 5, 9 },
    { kTechId.BioMassFour, 6, 7, nil, "4" }, {kTechId.Leap, 6, 8},
    { kTechId.BioMassFive, 7, 7, nil, "5" }, {kTechId.MetabolizeHealth, 7, 8},
    { kTechId.BioMassSix, 8, 7, nil, "6" }, {kTechId.Umbra, 8, 8}, {kTechId.BoneShield, 8, 9}, {kTechId.Spores, 8, 10}
    { kTechId.BioMassSeven, 9, 7, nil, "7" }, {kTechId.AdvancedSwipe, 9, 8}
    { kTechId.BioMassEight, 10, 7, nil, "8" },
    { kTechId.BioMassNine, 11, 7, nil, "9" }, {kTechId.Xenocide, 11, 8}, {kTechId.Stomp, 11, 9},
    { kTechId.BioMassTen, 12, 7, nil, "10" }, {kTechId.Contamination, 12, 8}
}

kAlienLines =
{
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Hive, kTechId.Crag),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Hive, kTechId.Shift),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Hive, kTechId.Shade),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Hive, kTechId.Whip),

    GetLinePositionForTechMap(kAlienTechMap, kTechId.Harvester, kTechId.Hive),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Hive, kTechId.Drifter),
    { 7, 1.5, 7, 2.5 },
    { 4, 2.5, 10, 2.5},
    { 4, 2.5, 4, 3},{ 7, 2.5, 7, 3},{ 10, 2.5, 10, 3},
    GetLinePositionForTechMap(kAlienTechMap, kTechId.CragHive, kTechId.Shell),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.ShadeHive, kTechId.Veil),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.ShiftHive, kTechId.Spur),

    GetLinePositionForTechMap(kAlienTechMap, kTechId.CragHive, kTechId.DrifterRegeneration),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.ShadeHive, kTechId.DrifterCamouflage),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.ShiftHive, kTechId.DrifterCelerity),

    GetLinePositionForTechMap(kAlienTechMap, kTechId.CragHive, kTechId.CystCarapace),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.ShadeHive, kTechId.CystCamouflage),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.ShiftHive, kTechId.CystCelerity),
    
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Shell, kTechId.Vampirism),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Shell, kTechId.Carapace),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Shell, kTechId.Regeneration),

    GetLinePositionForTechMap(kAlienTechMap, kTechId.Veil, kTechId.Focus),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Veil, kTechId.Camouflage),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Veil, kTechId.Aura),

    GetLinePositionForTechMap(kAlienTechMap, kTechId.Spur, kTechId.Crush),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Spur, kTechId.Celerity),
    GetLinePositionForTechMap(kAlienTechMap, kTechId.Spur, kTechId.Adrenaline),

}