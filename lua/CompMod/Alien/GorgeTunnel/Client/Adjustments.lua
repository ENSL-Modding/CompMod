CompMod:AddNewBind("Weapon6", "input", "Weapon #6", "6", "Weapon5")

CompMod:RegisterConfigOption("GorgeTunnelEntranceColour_R", 0)
CompMod:RegisterConfigOption("GorgeTunnelEntranceColour_G", 1)
CompMod:RegisterConfigOption("GorgeTunnelEntranceColour_B", 0.2)
CompMod:RegisterConfigOption("GorgeTunnelEntranceColour_A", 1)

CompMod:RegisterConfigOption("GorgeTunnelExitColour_R", 0.8)
CompMod:RegisterConfigOption("GorgeTunnelExitColour_G", 0.6)
CompMod:RegisterConfigOption("GorgeTunnelExitColour_B", 1)
CompMod:RegisterConfigOption("GorgeTunnelExitColour_A", 1)

local usage_vars = {
  "Required Arguments:",
  "  r - Red channel value: 0 to 1",
  "  b - Blue channel value: 0 to 1",
  "  g - Green channel value: 0 to 1",
  "Optional Arguments:",
  "  a - Alpha channel value: 0 to 1"
}

local defaultEntranceVars = "0 1 0.2 1"
local defaultExitVars = "0.8 0.6 1 1"

local function validate_args(r, g, b, a, cmd, default)

  assert(cmd and type(cmd) == "string")

  if not a then
    a = 1.0
  end

  if not r or not g or not b then
    CompMod:Print("Usage: " .. cmd .. " r g b [a]")
    if default then
      CompMod:Print("Default: " .. cmd .. " " .. default)
    end

    for _,v in ipairs(usage_vars) do
      CompMod:Print(v)
    end
    return false
  end

  if type(r) ~= "number" then
    r = tonumber(r)
    if not r then
      CompMod:Print("Red channel must be a number")
      return false
    end
  end

  if type(g) ~= "number" then
    g = tonumber(g)
    if not g then
      CompMod:Print("Green channel must be a number")
      return false
    end
  end

  if type(b) ~= "number" then
    b = tonumber(b)
    if not b then
      CompMod:Print("Blue channel must be a number")
      return false
    end
  end

  if type(a) ~= "number" then
    a = tonumber(a)
    if not a then
      CompMod:Print("Alpha channel must be a number")
      return false
    end
  end

  if r < 0 or r > 1 then
    CompMod:Print("Red channel out of bounds. Must be between 0 and 1")
    return false
  elseif g < 0 or g > 1 then
    CompMod:Print("Green channel out of bounds. Must be between 0 and 1")
    return false
  elseif b < 0 or b > 1 then
    CompMod:Print("Blue channel out of bounds. Must be between 0 and 1")
    return false
  elseif a < 0 or a > 1 then
    CompMod:Print("Alpha channel out of bounds. Must be between 0 and 1")
    return false
  end

  return true, r, g, b, a
end

local function ResetMinimapElements()
  local minimap = ClientUI.GetScript("GUIMinimapFrame")

  minimap:ResetAll()
end

local function ChangeEntranceColour(r, g, b, a)
  local valid, r, g, b, a = validate_args(r, g, b, a, "compmod_entrancecolour", defaultEntranceVars)

  if valid then
    CompMod:UpdateConfigOption("GorgeTunnelEntranceColour_R", r)
    CompMod:UpdateConfigOption("GorgeTunnelEntranceColour_G", g)
    CompMod:UpdateConfigOption("GorgeTunnelEntranceColour_B", b)
    CompMod:UpdateConfigOption("GorgeTunnelEntranceColour_A", a)
    ResetMinimapElements()

    CompMod:Print(string.format("Tunnel entrance colour set to (%02.2f, %02.2f, %02.2f, %02.2f)", r, g, b, a))
  end
end

local function ChangeExitColour(r, g, b, a)
  local valid, r, g, b, a = validate_args(r, g, b, a, "compmod_exitcolour", defaultExitVars)

  if valid then
    CompMod:UpdateConfigOption("GorgeTunnelExitColour_R", r)
    CompMod:UpdateConfigOption("GorgeTunnelExitColour_G", g)
    CompMod:UpdateConfigOption("GorgeTunnelExitColour_B", b)
    CompMod:UpdateConfigOption("GorgeTunnelExitColour_A", a)
    ResetMinimapElements()

    CompMod:Print(string.format("Tunnel exit colour set to (%02.2f, %02.2f, %02.2f, %02.2f)", r, g, b, a))
  end
end

Event.Hook("Console_compmod_entrancecolour", ChangeEntranceColour)
Event.Hook("Console_compmod_exitcolour", ChangeExitColour)
