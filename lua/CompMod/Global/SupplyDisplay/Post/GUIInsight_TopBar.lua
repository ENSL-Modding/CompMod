local kIconTextureMarine = debug.getupvaluex(GUIInsight_TopBar.Initialize, "kIconTextureMarine")
local kIconTextureAlien = debug.getupvaluex(GUIInsight_TopBar.Initialize, "kIconTextureAlien")
local kTeamSupplyIconCoords = {280, 363, 320, 411}

local marineSupply
local alienSupply

local CreateIconTextItem = debug.getupvaluex(GUIInsight_TopBar.Initialize, "CreateIconTextItem")

local oldInitialize = GUIInsight_TopBar.Initialize
function GUIInsight_TopBar:Initialize()
    oldInitialize(self)

    local background = debug.getupvaluex(GUIInsight_TopBar.Initialize, "background")
    local yoffset = GUIScale(48)

    marineSupply = CreateIconTextItem(kTeam1Index, background, Vector(GUIScale(130),yoffset,0), kIconTextureMarine, kTeamSupplyIconCoords)

    alienSupply = CreateIconTextItem(kTeam2Index, background, Vector(-GUIScale(195),yoffset,0), kIconTextureAlien, kTeamSupplyIconCoords)
end

local oldUpdate = GUIInsight_TopBar.Update
function GUIInsight_TopBar:Update(deltaTime)
    oldUpdate(self, deltaTime)

    marineSupply:SetText('' .. GetSupplyUsedByTeam(kTeam1Index))

    alienSupply:SetText('' .. GetSupplyUsedByTeam(kTeam2Index))
end