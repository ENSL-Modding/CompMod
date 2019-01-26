local kBlipColorType = CompMod:GetLocalVariable(GUIMinimap.Initialize, "kBlipColorType", true)

CompMod:AppendToEnum(kBlipColorType, "TunnelEntrance")
CompMod:AppendToEnum(kBlipColorType, "TunnelExit")

local function preChanges(self)
  local kBlipInfo = CompMod:GetLocalVariable(GUIMinimap.Initialize, "kBlipInfo", true)
  local kBlipSizeType = CompMod:GetLocalVariable(GUIMinimap.Initialize, "kBlipSizeType", true)
  local kStaticBlipsLayer = CompMod:GetLocalVariable(GUIMinimap.Initialize, "kStaticBlipsLayer", true)

  kBlipInfo[kMinimapBlipType.TunnelEntrance] = { kBlipColorType.TunnelEntrance, kBlipSizeType.Normal, kStaticBlipsLayer }
  kBlipInfo[kMinimapBlipType.TunnelExit] = { kBlipColorType.TunnelExit, kBlipSizeType.Normal, kStaticBlipsLayer }
end

local oldInit = GUIMinimapFrame.Initialize
function GUIMinimapFrame:Initialize()
  preChanges(self)
  oldInit(self)
end
