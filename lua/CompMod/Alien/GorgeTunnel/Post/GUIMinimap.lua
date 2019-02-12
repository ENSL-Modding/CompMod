local function GetColours(option, blipTeam)
  local r = CompMod:GetConfigOption(option .. "_R")
  local g = CompMod:GetConfigOption(option .. "_G")
  local b = CompMod:GetConfigOption(option .. "_B")
  local a = CompMod:GetConfigOption(option .. "_A")

  if blipTeam == kMinimapBlipTeam.InactiveAlien then
    r = r/3
    g = g/3
    b = b/3
  end

  return r,g,b,a
end

function GUIMinimap:InitMinimapIcon(item, blipType, blipTeam)

    local blipInfo = self.blipInfoTable[blipType]
    local texCoords, colorType, sizeType, layer = blipInfo[1], blipInfo[2], blipInfo[3], blipInfo[4]

    item.blipType = blipType
    item.blipSizeType = sizeType
    item.blipSize = self.blipSizeTable[item.blipSizeType]
    item.blipTeam = blipTeam

    if item.blipType == kMinimapBlipType.TunnelEntrance then
      local r,g,b,a = GetColours("GorgeTunnelEntranceColour", item.blipTeam)

      item.blipColor = Color(r, g, b, a)
    elseif item.blipType == kMinimapBlipType.TunnelExit then
      local r,g,b,a = GetColours("GorgeTunnelExitColour", item.blipTeam)

      item.blipColor = Color(r, g, b, a)
    else
      item.blipColor = self.blipColorTable[item.blipTeam][colorType]
    end

    item:SetLayer(layer)
    item:SetTexturePixelCoordinates(GUIUnpackCoords(texCoords))
    item:SetSize(item.blipSize)
    item:SetColor(item.blipColor)
    item:SetStencilFunc(self.stencilFunc)
    item:SetTexture(self.iconFileName)
    item:SetIsVisible(self.visible)

    item.resetMinimapItem = false

    return item
end
