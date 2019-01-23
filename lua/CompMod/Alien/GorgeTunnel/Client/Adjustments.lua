local function SetupKeyBinding(_keyBinding)
  _keyBinding.Weapon6 = InputKey.Num6
  return _keyBinding
end

local function UpdateMoveCommand(_keyPressed, _keyBinding, move)
  if _keyPressed[ _keyBinding.Weapon6 ] then
      move.commands = bit.bor(move.commands, Move.ReadyRoom)
  end
  return move.commands
end

CompMod:AddNewBind("Weapon6", "input", "Weapon #6", "6", "Weapon5", SetupKeyBinding, UpdateMoveCommand)
