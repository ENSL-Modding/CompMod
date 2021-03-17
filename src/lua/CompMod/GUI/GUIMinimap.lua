local kPlayerNameLayer = 7
local kPlayerNameFontSize = 8
local kPlayerNameFontName = Fonts.kAgencyFB_Tiny
local kPlayerNameOffset = Vector(11.5, -5, 0)
local kPlayerNameColorAlien = Color(1, 189/255, 111/255, 1)
local kPlayerNameColorMarine = Color(164/255, 241/255, 1, 1)

local kNameTagReuseTimeout = 0.2

local oldInit = GUIMinimap.Initialize
function GUIMinimap:Initialize()
    self.tunnelNameTagMap = unique_map()
    self.unusedTunnelNameTags = {}

    oldInit(self)
end

local oldUpdateItemsGUIScale = GUIMinimap.UpdateItemsGUIScale
function GUIMinimap:UpdateItemsGUIScale()
    oldUpdateItemsGUIScale(self)

    for _, nameTag in self.tunnelNameTagMap:Iterate() do
        GUI.DestroyItem(nameTag)
    end

    self.tunnelNameTagMap:Clear()
end

local function CreateNewTunnelNameTag(self)
    local nameTag = GUIManager:CreateTextItem()
    
    nameTag:SetFontSize(kPlayerNameFontSize)
    nameTag:SetFontIsBold(false)
    nameTag:SetFontName(kPlayerNameFontName)
    nameTag:SetInheritsParentScaling(false)
    nameTag:SetScale(GetScaledVector())
    GUIMakeFontScale(nameTag)
    nameTag:SetAnchor(GUIItem.Middle, GUIItem.Center)
    nameTag:SetTextAlignmentX(GUIItem.Align_Center)
    nameTag:SetTextAlignmentY(GUIItem.Align_Center)
    nameTag:SetLayer(kPlayerNameLayer)
    nameTag:SetIsVisible(false)
    nameTag.lastUsed = Shared.GetTime()

    self.minimap:AddChild(nameTag)

    return nameTag
end

local function GetFreeTunnelNameTag(self, entId)
    local freeNameTag = table.remove(self.unusedTunnelNameTags)

    if freeNameTag == nil then
        freeNameTag = CreateNewTunnelNameTag(self)
    end

    freeNameTag.entityId = entId
    self.tunnelNameTagMap:Insert(entId, freeNameTag)

    return freeNameTag
end

local oldHideUnusedNameTags = GUIMinimap.HideUnusedNameTags
function GUIMinimap:HideUnusedNameTags()
    oldHideUnusedNameTags(self)

    local now = Shared.GetTime()
    for entId, nameTag in self.tunnelNameTagMap:Iterate() do
        if now - nameTag.lastUsed > kNameTagReuseTimeout then
            nameTag:SetIsVisible(false)
            table.insert(self.unusedTunnelNameTags, nameTag)
            self.tunnelNameTagMap:Remove(entId)
        end
    end
end

local function GetTunnelNameTag(self, entId)
    local nameTag = self.tunnelNameTagMap:Get(entId)
    if not nameTag then
        nameTag = GetFreeTunnelNameTag(self, entId)
    end

    return nameTag
end

function GUIMinimap:DrawMinimapNameTunnel(item, blipTeam, ownerId)
    if self.showPlayerNames then
        local nameTag = GetTunnelNameTag(self, ownerId)
        local text = GetTeamInfoEntity(kTeam2Index):GetTunnelManager():GetTunnelNameTag(ownerId)

        nameTag:SetIsVisible(self.visible)
        nameTag:SetText(text)
        nameTag.lastUsed = Shared.GetTime()

        nameTag:SetColor(kPlayerNameColorAlien)
        nameTag:SetPosition(item:GetPosition() + GUIScale(kPlayerNameOffset))
    end
end
