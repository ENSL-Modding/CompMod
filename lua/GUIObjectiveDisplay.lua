-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\GUIObjectiveDisplay.lua
--
-- Created by: Andreas Urwalek (a_urwa@sbox.tugraz.at)
--
-- Shows enemy command structures
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

class 'GUIObjectiveDisplay' (GUIScript)

GUIObjectiveDisplay.kVisionExtents = GUIScale( Vector(100, 100, 0) )
GUIObjectiveDisplay.kVisionMinExtents = GUIScale( Vector(32, 32, 0) )
GUIObjectiveDisplay.kMaxDistance = 100
GUIObjectiveDisplay.kMinAlpha = .25 -- 0.1
GUIObjectiveDisplay.kMaxAlpha = .75 -- 0.1

local kTextures = { [kMarineTeamType] = "ui/objectives_marine.dds", [kAlienTeamType] = "ui/objectives_alien.dds" }

local function GetTextureForTeamType(teamType)
    return kTextures[teamType] or ""
end

local kPixelCoords
local function GetPixelCoordsForType(type)

    if not kPixelCoords then

        kPixelCoords = {
            [kTechId.TechPoint] = { 0, 0, 256, 256 },
            [kTechId.ResourcePoint] = { 256, 0, 512, 256 }
        }

    end

    return kPixelCoords[type] or { 0, 0, 0, 0 }

end

function GUIObjectiveDisplay:CreateVisionElement()

    local guiItem = table.remove(self.dirtyVisions)
    if not guiItem then
        guiItem = GetGUIManager():CreateGraphicItem()
    end

    guiItem:SetSize(GUIObjectiveDisplay.kVisionExtents)
    guiItem:SetBlendTechnique(GUIItem.Add)
    guiItem:SetIsVisible(self.visible)
    return guiItem

end

function GUIObjectiveDisplay:Initialize()

    self.updateInterval = 0
    self.activeVisions = {}
    self.dirtyVisions = {}
    self.screenDiagonalLength = math.sqrt(Client.GetScreenHeight()/2) ^ 2 + (Client.GetScreenWidth()/2)
    self.visible = true
    
end

function GUIObjectiveDisplay:SetIsVisible(state)
    
    self.visible = state
    for i=1, #self.activeVisions do
        self.activeVisions[i]:SetIsVisible(state)
    end
    
end

function GUIObjectiveDisplay:GetIsVisible()
    
    return self.visible
    
end

function GUIObjectiveDisplay:Uninitialize()

    for _, blip in ipairs(self.activeVisions) do
        GUI.DestroyItem(blip)
    end

    for _, blip in ipairs(self.dirtyVisions) do
        GUI.DestroyItem(blip)
    end

    self.activeVisions = { }
    self.dirtyVisions = { }

end

function GUIObjectiveDisplay:OnResolutionChanged()

    self.screenDiagonalLength = math.sqrt(Client.GetScreenHeight()/2) ^ 2 + (Client.GetScreenWidth()/2)
    GUIObjectiveDisplay.kVisionExtents = GUIScale( Vector(64, 64, 0) )

end

local kObjectiveDistanceSquared = 2500
local kMinDistanceSquared = 100
function GUIObjectiveDisplay:Update(_)

    PROFILE("GUIObjectiveDisplay:Update")

    local unitVisions = PlayerUI_GetObjectives()
    local teamType = PlayerUI_GetTeamType()

    local numActiveVisions = #self.activeVisions
    local numCurrentVisions = #unitVisions

    -- local stencilUpdated = numActiveVisions ~= numCurrentVisions

    if numCurrentVisions > numActiveVisions then

        for i = 1, numCurrentVisions - numActiveVisions do
            table.insert(self.activeVisions, self:CreateVisionElement())
        end

    elseif numActiveVisions > numCurrentVisions then

        for i = 1, numActiveVisions - numCurrentVisions do

            local vison = table.remove(self.activeVisions, #self.activeVisions)
            vison:SetIsVisible(false)
            table.insert(self.dirtyVisions, vison)

        end

    end

    numActiveVisions = #self.activeVisions

    -- Don't draw existing objective markers if we turn off hints or are in a gorge tunnel
    local playerOrigin = PlayerUI_GetOrigin()
    if Client.GetOptionBoolean( "showHints", true ) == false or GetIsPointInGorgeTunnel(playerOrigin) then
        for i = 1, numActiveVisions do
            local visionElement = self.activeVisions[i]
            visionElement:SetIsVisible(false)
        end

        return
    end

    -- update objective markers
    for  i = 1, numActiveVisions do

        local currentVision = unitVisions[i]
        local visionElement = self.activeVisions[i]

        local screenPosFraction = (math.abs( (currentVision.Position - Vector(Client.GetScreenWidth() * .5, Client.GetScreenHeight() * .5, 0)):GetLength() ) / (self.screenDiagonalLength * 0.5))
        local color = teamType == kMarineTeamType and kAlienTeamColorFloat or kMarineTeamColorFloat --show objectives in color of the other team
        color = CopyColor(color)

        color.a = GUIObjectiveDisplay.kMinAlpha + (GUIObjectiveDisplay.kMaxAlpha - GUIObjectiveDisplay.kMinAlpha) * screenPosFraction

        local distance = currentVision.DistanceSquared
        local distanceFraction = Clamp((distance - kMinDistanceSquared) / kMinDistanceSquared, 0, 1)
        color.a = color.a * distanceFraction

        local distanceFraction = 1 - Clamp(distance / kObjectiveDistanceSquared, 0, 1)
        local size = (GUIObjectiveDisplay.kVisionExtents - GUIObjectiveDisplay.kVisionMinExtents) * distanceFraction + GUIObjectiveDisplay.kVisionMinExtents

        visionElement:SetPosition(currentVision.Position - size *.5)
        visionElement:SetSize(size)
        visionElement:SetColor(color)
        visionElement:SetTexture(GetTextureForTeamType(teamType))
        visionElement:SetTexturePixelCoordinates(GUIUnpackCoords(GetPixelCoordsForType(currentVision.TechId)))
        visionElement:SetIsVisible(true)

    end

end