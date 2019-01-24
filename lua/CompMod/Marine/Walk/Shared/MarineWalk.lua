local oldMarineInit = Marine.OnInitialized
function Marine:OnInitialized()
  oldMarineInit(self)
  InitMixin(self, WalkMixin)
end

local networkVars = { }

AddMixinNetworkVars(WalkMixin, networkVars)

Shared.LinkClassToMap("Marine", Marine.kMapName, networkVars, true)
