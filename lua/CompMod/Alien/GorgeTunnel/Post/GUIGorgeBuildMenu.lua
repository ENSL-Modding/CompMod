local function UpdateRowTable()
  local GetRowForTechId = CompMod:GetLocalVariable(GUIGorgeBuildMenu.Update, "GetRowForTechId", true)
  GetRowForTechId(kTechId.Hydra) -- make sure rowTable is initialised
  local rowTable = CompMod:GetLocalVariable(GetRowForTechId, "rowTable")
  rowTable[kTechId.GorgeTunnelExit] = 4
end

local oldUpdateButton = CompMod:GetLocalVariable(GUIGorgeBuildMenu.Update, "UpdateButton", true)
local function UpdateButton(button, index)

  oldUpdateButton(button, index)

  local col = 1
  local color = GUIGorgeBuildMenu.kAvailableColor

  if not GorgeBuild_GetCanAffordAbility(button.techId) then
    col = 2
    color = GUIGorgeBuildMenu.kTooExpensiveColor
  end

  if not GorgeBuild_GetIsAbilityAvailable(index) then
    col = 3
    color = GUIGorgeBuildMenu.kUnavailableColor
  end

  if button.techId == kTechId.GorgeTunnel then
    color = Color(0, 1, 0.2, 1) -- the same colour as kBlipColorType.MAC
  end

  if button.techId == kTechId.GorgeTunnelExit then
    color = Color(0.8, 0.6, 1, 1) -- the same colour as kBlipColorType.EtherealGate
  end

  button.description:SetColor(color)
  button.costIcon:SetColor(color)
  button.costText:SetColor(color)

  local numLeft = GorgeBuild_GetNumStructureBuilt(button.techId)
  if numLeft == -1 then
    button.structuresLeft:SetIsVisible(false)
  else
    button.structuresLeft:SetIsVisible(true)
    local amountString = ToString(numLeft)
    local maxNum = GorgeBuild_GetMaxNumStructure(button.techId)

    if maxNum > 0 then
      amountString = amountString .. "/" .. ToString(maxNum)
    end

    if numLeft >= maxNum then
      color = GUIGorgeBuildMenu.kTooExpensiveColor
    end

    button.structuresLeft:SetColor(color)
    button.structuresLeft:SetText(amountString)

  end

end

local function AddUpdateButtonChanges()
  ReplaceLocals(GUIGorgeBuildMenu.Update, {UpdateButton = UpdateButton})
end

local function BuildMenuChanges()
  UpdateRowTable()
  AddUpdateButtonChanges()
end

local oldInit = GUIGorgeBuildMenu.Initialize
function GUIGorgeBuildMenu:Initialize()
  oldInit(self)
  BuildMenuChanges()
end

function GUIGorgeBuildMenu:OverrideInput(input)

    -- Assume the user wants to switch the top-level weapons
  if HasMoveCommand( input.commands, Move.SelectNextWeapon )
  or HasMoveCommand( input.commands, Move.SelectPrevWeapon ) then
      GorgeBuild_OnClose()
      GorgeBuild_Close()
      return input
  end

  local weaponSwitchCommands = { Move.Weapon1, Move.Weapon2, Move.Weapon3, Move.Weapon4, Move.Weapon5, Move.ReadyRoom }

  local selectPressed = false

  for index, weaponSwitchCommand in ipairs(weaponSwitchCommands) do
    if HasMoveCommand( input.commands, weaponSwitchCommand ) then
      if GorgeBuild_GetIsAbilityAvailable(index) and GorgeBuild_GetCanAffordAbility(self.buttons[index].techId)  then
        GorgeBuild_SendSelect(index)
        input.commands = RemoveMoveCommand( input.commands, weaponSwitchCommand )
      end
      selectPressed = true
      break
    end
  end

  if selectPressed then
    GorgeBuild_OnClose()
    GorgeBuild_Close()
  elseif HasMoveCommand( input.commands, Move.SecondaryAttack )
      or HasMoveCommand( input.commands, Move.PrimaryAttack ) then
        GorgeBuild_OnClose()
        GorgeBuild_Close()

        -- leave the secondary attack command so the drop-ability can handle it
        input.commands = AddMoveCommand( input.commands, Move.SecondaryAttack )
        input.commands = RemoveMoveCommand( input.commands, Move.PrimaryAttack )
        --DebugPrint("after override: %d",input.commands)
        --DebugPrint("primary = %d secondary = %d", Move.PrimaryAttack, Move.SecondaryAttack)
  end

  return input, selectPressed

end
