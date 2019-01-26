function GUIMinimap:InitMinimapIcon(item, blipType, blipTeam)

    local blipInfo = self.blipInfoTable[blipType]
    local texCoords, colorType, sizeType, layer = blipInfo[1], blipInfo[2], blipInfo[3], blipInfo[4]

    item.blipType = blipType
    item.blipSizeType = sizeType
    item.blipSize = self.blipSizeTable[item.blipSizeType]
    item.blipTeam = blipTeam

    if item.blipType == kMinimapBlipType.TunnelEntrance then
      local r = CompMod:GetConfigOption("GorgeTunnelEntranceColour_R")
      local g = CompMod:GetConfigOption("GorgeTunnelEntranceColour_G")
      local b = CompMod:GetConfigOption("GorgeTunnelEntranceColour_B")
      local a = CompMod:GetConfigOption("GorgeTunnelEntranceColour_A")
      local entranceColour = Color(r, g, b, a)

      item.blipColor = entranceColour
    elseif item.blipType == kMinimapBlipType.TunnelExit then
      local r = CompMod:GetConfigOption("GorgeTunnelExitColour_R")
      local g = CompMod:GetConfigOption("GorgeTunnelExitColour_G")
      local b = CompMod:GetConfigOption("GorgeTunnelExitColour_B")
      local a = CompMod:GetConfigOption("GorgeTunnelExitColour_A")
      local exitColour = Color(r, g, b, a)

      item.blipColor = exitColour
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
