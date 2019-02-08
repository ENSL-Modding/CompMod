CompMod:AddUpgradeNode(kTechId.Consume, kTechId.None, kTechId.None, 2)
CompMod:AddTechIdToMaterialOffset(kTechId.Consume, 108)

CompMod:AddTech({
  [kTechDataId] = kTechId.Consume,
  [kTechDataDisplayName] = "Consume",
  [kTechDataCostKey] = 0,
  [kTechIDShowEnables] = false,
  [kTechDataResearchTimeKey] = kRecycleTime,
  [kTechDataHotkey] = Move.R,
  [kTechDataTooltipInfo] = "Consume the entity and return the supply cost.",
  [kTechDataMenuPriority] = 2,
})

local kConsumeMessage =
{
    techId = "enum kTechId",
}

Shared.RegisterNetworkMessage( "Consume", kConsumeMessage )

if Client then
  function OnCommandConsume(consumeTable)

      if consumeTable.techId == kTechId.Harvester then
          DeathMsgUI_AddRtsLost(kTeam2Index, 1)
      end

  end

  Client.HookNetworkMessage("Consume", OnCommandConsume)
end

Script.Load("lua/ResearchMixin.lua")

local structuresToAdd = {
  {"Crag", false},
  {"Shift", false},
  {"Shade", false},
  {"Spur", false},
  {"Shell", false},
  {"Veil", false},
  {"Harvester", false},
  {"Hive", false}, -- let's see how people break this :D
  {"Cyst", true},
  {"Drifter", true},
}

local function add(v, withResearch)
  local Structure = _G[v]
  local networkVars = {}

  if withResearch then
    AddMixinNetworkVars(ResearchMixin, networkVars)
  end
  AddMixinNetworkVars(ConsumeMixin, networkVars)

  local oldOnCreate = Structure.OnCreate
  function Structure:OnCreate()
    oldOnCreate(self)
    if withResearch then
      InitMixin(self, ResearchMixin)
    end
    InitMixin(self, ConsumeMixin)
  end

  local oldGetTechButtons = Structure.GetTechButtons
  function Structure:GetTechButtons(techId)
    local techButtons = oldGetTechButtons(self, techId)
    if techButtons then
      techButtons[8] = kTechId.Consume
    end
    return techButtons
  end
end

for _,v in ipairs(structuresToAdd) do
  add(v[1], v[2])
end

local oldGetIsUnitActive = GetIsUnitActive
function GetIsUnitActive(unit, debug)

    local isConsumed = HasMixin(unit, "Consume") and (unit:GetIsConsumed() or unit:GetIsConsuming())

    return oldGetIsUnitActive(unit, debug) and not isConsumed

end
