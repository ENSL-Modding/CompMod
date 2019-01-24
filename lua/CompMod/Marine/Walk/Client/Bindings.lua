local function SetupKeyBinding(_keyBinding)
  print("setup SecondaryMovementModifier")
  _keyBinding.SecondaryMovementModifier = InputKey.Capital
  return _keyBinding
end

local function UpdateMoveCommand(_keyPressed, _keyBinding, move)
  if _keyPressed[ _keyBinding.SecondaryMovementModifier ] then
    move.commands = bit.bor(move.commands, Move.ReadyRoom)
  end
  return move.commands
end

CompMod:AddNewBind("SecondaryMovementModifier", "input", "Secondary Movement Modifier", "Capital", "MovementModifier", SetupKeyBinding, UpdateMoveCommand)
