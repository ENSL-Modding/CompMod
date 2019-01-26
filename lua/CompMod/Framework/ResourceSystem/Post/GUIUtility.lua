local Mod = GetMod()
local texturesToReplace = Mod:GetGUITexturesToReplace()

local old = GUIItem.SetTexture
function GUIItem:SetTexture(tex)
  if texturesToReplace[tex] then
    return old(self, texturesToReplace[tex])
  end

  return old(self, tex)
end
