local oldMarineInit = Marine.OnInitialized
function Marine:OnInitialized()
  oldMarineInit(self)
  InitMixin(self, WalkMixin)
end

local networkVars = { }

AddMixinNetworkVars(WalkMixin, networkVars)

Shared.LinkClassToMap("Marine", Marine.kMapName, networkVars, true)

if Client then
  local oldTriggerFootstep = Player.TriggerFootstep
  function Player:TriggerFootstep()
    
    if HasMixin(self, "Walk") and self:GetWalking() then
      return
    end

    return oldTriggerFootstep(self)
  end
end

local oldGetPlayFootsteps = Player.GetPlayFootsteps
function Player:GetPlayFootsteps()
    if not Client then
        return false
    end
    return oldGetPlayFootsteps(self) and not (HasMixin(self, "Walk") and self:GetWalking())
end
