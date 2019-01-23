local function preChanges()
  local kBlipInfo = CompMod:GetLocalVariable(GUIMinimap.Initialize, "kBlipInfo", true)
  local kBlipColorType = CompMod:GetLocalVariable(GUIMinimap.Initialize, "kBlipColorType", true)
  local kBlipSizeType = CompMod:GetLocalVariable(GUIMinimap.Initialize, "kBlipSizeType", true)
  local kStaticBlipsLayer = CompMod:GetLocalVariable(GUIMinimap.Initialize, "kStaticBlipsLayer", true)

  kBlipInfo[kMinimapBlipType.TunnelEntrance] = { kBlipColorType.MAC, kBlipSizeType.Normal, kStaticBlipsLayer }
  -- kBlipInfo[kMinimapBlipType.TunnelExit] = { kBlipColorType.EtherealGate, kBlipSizeType.Normal, kStaticBlipsLayer }
end

local oldInit = GUIMinimapFrame.Initialize
function GUIMinimapFrame:Initialize()
  preChanges()
  oldInit(self)
end
