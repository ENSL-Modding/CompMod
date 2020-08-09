local framework_version = "0"
local framework_build = "20.2"

local frameworkModules = {
  --"ConsistencyCheck",
  "ResourceSystem",
  "TechChanges",
}

local kLogLevels = {
  fatal = {display="Fatal", level=0},
  error = {display="Error", level=1},
  warn  = {display="Warn",  level=2},
  info  = {display="Info",  level=3},
  debug = {display="Debug", level=4},
}

local configOptions = {
  {
    var             = "kLogLevel",
    expectedType    = "table",
    required        = false,
    default         = kLogLevels.info,
    displayDefault  = "info",
    warn            = true,
    validator       =
      function(tbl)
        assert(tbl)
        for k,v in pairs(kLogLevels) do
          if v == tbl then
            return true
          end
        end
        return false
      end
  },

  {
    var             = "kShowInFeedbackText",
    expectedType    = "boolean",
    required        = false,
    default         = false,
    displayDefault  = "false",
    warn            = true
  },

  {
    var             = "kModVersion",
    expectedType    = "string",
    required        = false,
    default         = "0",
    displayDefault  = "0",
    warn            = true
  },

  {
    var             = "kModBuild",
    expectedType    = "string",
    required        = false,
    default         = "1",
    displayDefault  = "1",
    warn            = true
  },

  {
    var             = "disableRanking",
    expectedType    = "boolean",
    required        = false,
    default         = false,
    displayDefault  = "false",
    warn            = true
  },

  {
    var             = "modules",
    expectedType    = "table",
    required        = true,
    default         = {},
    displayDefault  = "new table",
    warn            = true,
    validator       =
      function(tbl)
        assert(tbl)
        for k,v in ipairs(tbl) do
          if type(v) ~= "string" then
            return false
          end
        end
        return true
      end,
  },

  {
    var             = "use_config",
    expectedType    = "string",
    required        = false,
    default         = "none",
    displayDefault  = "none",
    warn            = true,
    validator       =
      function(str)
        assert(str)
        local v = str:lower()
        local validOptions = {
          "none",
          "client",
          "server",
          "both"
        }

        return table.contains(validOptions, v)
      end,
  },

  {
    var             = "techIdsToAdd",
    expectedType    = "table",
    required        = false,
    default         = {},
    displayDefault  = "new table",
    warn            = false,
  }
}

local techIdsLoaded = false
local Mod = {}

local function ValidateConfigOption(configVar, configOption)
  if type(configVar) ~= configOption.expectedType then
    return false, string.format("Expected type \"%s\" for variable \"%s\", got \"%s\" instead", configOption.expectedType, configOption.var, type(configVar))
  end

  if configOption.validator then
    local valid = configOption.validator(configVar)
    if not valid then
      return false, string.format("Validator failed for variable \"%s\"", configOption.var)
    end
  end

  return true, "pass"
end

local function LoadDefaults(config, v)
  option = v.default
  config[v.var] = option

  if v.warn then
    Shared.Message(string.format("Using default value for option \"%s\" (%s)", v.var, v.displayDefault))
  end
end

local function ValidateConfig(config)
  local configLength = table.real_length(config)
  local configOptionsLength = #configOptions

  -- is this really needed?
  if configLength > configOptionsLength then
    return false, "Too many config options set"
  end

  for _,v in ipairs(configOptions) do
    if config[v.var] ~= nil then
      local valid, reason = ValidateConfigOption(config[v.var], v)

      if not valid then
        return false, reason
      end
    else
      if v.required then
        return false, "Missing required config option \"" .. v.var .. "\""
      end

      LoadDefaults(config, v)
    end
  end

  return true, "passed"
end

local function FindModName()
  local modName = debug.getinfo(1, "S").source:gsub("@lua/", ""):gsub("/Framework/.*%.lua", "")
  assert(modName and type(modName) == "string", "Error finding mod name. Please report.")
  return modName
end

local function GetLogLevels()
  return kLogLevels
end

function GetMod()
  local kModName = FindModName()
  return _G[kModName]
end

function Mod:Initialise()
  local kModName = FindModName()
  local current_vm = Client and "Client" or Server and "Server" or Predict and "Predict" or "Unknown"

  Shared.Message(string.format("[%s - %s] Loading framework %s", kModName, current_vm, self:GetFrameworkVersionPrintable()))

  if _G[kModName] then
    Mod = _G[kModName]
    Shared.Message(string.format("[%s - %s] Skipped loading framework %s", kModName, current_vm, self:GetFrameworkVersionPrintable()))
    return
  end

  self.kLogLevels = GetLogLevels()

  Script.Load("lua/" .. kModName .. "/Config.lua")

  local config = assert(GetModConfig, "Initialise: Config.lua malformed. Missing GetModConfig function.")
  config = config(self.kLogLevels)

  assert(config, "Initialise: Config.lua malformed. GetModConfig doesn't return anything.")
  assert(type(config) == "table", "Initialise: Config.lua malformed. GetModConfig doesn't return expected type.")

  valid, reason = ValidateConfig(config)
  assert(valid, "Initialise: Config failed validation. " .. reason)

  config.kModName = kModName
  self.config, config = config, nil

  for _,v in ipairs(frameworkModules) do
    assert(type(v) == "string", "Initialise: Invalid framework module")
    table.insert(self.config.modules, "Framework/" .. v)
  end

  -- this is really bad for performance so lets do it on the client :D
  if Client then
    for _,v in ipairs(self.config.modules) do
      local Files = {}
      local dir = self:FormatDir(v)
      Shared.GetMatchingFileNames(dir, true, Files)

  	  if #Files == 0 then
        Mod:Print("No files found for module: " .. v, Mod:GetLogLevels().warn)
      end

      for _,file in ipairs(Files) do
        local followingDir = file:gsub(dir:gsub("/*.lua", ""), ""):match("^([^/]+)/.*$")
        if followingDir ~= "Post" and followingDir ~= "Replace" and followingDir ~= "Halt" and followingDir ~= "Pre" and followingDir ~= "Client" and followingDir ~= "Server" and followingDir ~= "Predict" and followingDir ~= "Shared" and followingDir ~= "NewTech" then
          Mod:Print("Invalid module: " .. v, Mod:GetLogLevels().warn)
        end
      end
    end
  end

  _G[self.config.kModName] = self
  Shared.Message(string.format("[%s - %s] Framework %s loaded", kModName, current_vm, self:GetFrameworkVersionPrintable()))
end

local kModMaxRecursionDepth = 5

local function RecurseGetLocalVariable(self, originalFunction, localName, recurse, depth)
  if not depth then
    depth = 1
  else
    depth = depth + 1
  end
  local index = 1

  while true do

      local n, v = debug.getupvalue(originalFunction, index)
      if not n then
         break
      end

      if n == localName then
          return v
      end

      index = index + 1

  end

  if not recurse then return nil end

  -- recurse into local functions within the target function
  index = 1
  while true do
    local n,v = debug.getupvalue(originalFunction, index)

    if not n then break end

    local func

    if type(n) == "function" then
      func = n
    elseif type(v) == "function" then
      func = v
    end

    if func then
      -- make sure we don't recurse too far
      if depth + 1 > kModMaxRecursionDepth then
        self:Print("GetLocalVariable: Recursion depth exceeded.", self.kLogLevels.warn)
        return nil
      end

      local var = RecurseGetLocalVariable(self, func, localName, recurse, depth)
      if var ~= nil then
        return var
      end
    end

    index = index + 1
  end

  return nil
end

-- Get local variable from function
function Mod:GetLocalVariable(originalFunction, localName, recurse)
    local funcType = originalFunction and type(originalFunction) or "nil"
    local nameType = localName and type(localName) or "nil"
    local recurseType = recurse ~= nil and type(recurse) or "nil"

    assert(funcType == "function", "GetLocalVariable: Expected first argument to be of type function, was given " .. funcType)
    assert(nameType == "string", "GetLocalVariable: Expected second argument to be of type string, was given " .. nameType)
    assert(recurseType == "boolean" or recurseType == "nil", "GetLocalVariable: Expected optional fourth argument to be of type boolean, was given " .. recurseType)

    if recurse == nil then recurse = false end

    local var = RecurseGetLocalVariable(self, originalFunction, localName, recurse)
    if var == nil then
      self:Print("GetLocalVariable: Local variable \"" .. localName .. "\" not found", self.kLogLevels.warn)
    end
    return var
end

local function RecurseReplaceLocal(self, func, upName, newUp, recurse, depth)
  if not depth then
    depth = 1
  else
    depth = depth + 1
  end

  local index = 1
  -- check if this func has the up value first
  while true do
    local n,v = debug.getupvalue(func, index)

    if not n and not v then break end

    if n == upName then
      debug.setupvalue(func, index, newUp)
      return true
    end

    index = index + 1
  end

  if not recurse then return false end

  -- recurse into local functions within the target function
  index = 1
  while true do
    local n,v = debug.getupvalue(func, index)

    if not n then break end

    local func

    if type(n) == "function" then
      func = n
    elseif type(v) == "function" then
      func = v
    end

    if func then
      -- make sure we don't recurse too far
      if depth + 1 > kModMaxRecursionDepth then
        self:Print("ReplaceLocal: Recursion depth exceeded.", self.kLogLevels.warn)
        return false
      end

      local success = RecurseReplaceLocal(self, func, upName, newUp, recurse, depth)
      if success then
        return true
      end
    end

    index = index + 1
  end

  return false
end

function Mod:ReplaceLocal(func, upName, newUp, recurse)
  local funcType = func and type(func) or "nil"
  local upNameType = upName and type(upName) or "nil"
  local upFuncType = upFunc and type(upFunc) or "nil"
  local recurseType = recurse ~= nil and type(recurse) or "nil"

  assert(funcType == "function", "ReplaceLocal: Expected first argument to be of type function, was given " .. funcType)
  assert(upNameType == "string", "ReplaceLocal: Expected second argument to be of type string, was given " .. upNameType)
  assert(newUp ~= nil, "ReplaceLocal: Missing required third argument newUp.")
  assert(recurseType == "boolean" or recurseType == "nil", "ReplaceLocal: Expected optional fourth argument to be of type boolean, was given " .. recurseType)

  if recurse == nil then recurse = false end

  local success = RecurseReplaceLocal(self, func, upName, newUp, recurse)
  if not success then
    self:Print("ReplaceLocal: Local variable \"" .. upName .. "\" not found.", self.kLogLevels.warn)
  end
  return success
end

-- Append new value to enum
function Mod:AppendToEnum(tbl, key)
  local tblType = tbl and type(tbl) or "nil"

  assert(not techIdsLoaded or tbl ~= kTechId, "AppendToEnum: Do not use AppendToEnum to add tech ids. Define in config.lua")
  assert(tbl ~= nil and type(tbl) == "table", "AppendToEnum: First argument expected to be of type table, was " .. tblType)
  assert(key ~= nil, "AppendToEnum: required second argument \"key\" missing")
  assert(rawget(tbl,key) == nil, "AppendToEnum: key already exists in enum.")

  local maxVal = 0
  if tbl == kTechId then
    maxVal = tbl.Max

    -- delete old max
    rawset(tbl, rawget(tbl, maxVal), nil)
    rawset(tbl, maxVal, nil)

    -- move max down
    rawset(tbl, 'Max', maxVal+1)
    rawset(tbl, maxVal+1, 'Max')
  else
    for k, v in next, tbl do
      if type(v) == "number" and v > maxVal then
        maxVal = v
      end
    end
    maxVal = maxVal + 1
  end

  rawset(tbl, key, maxVal)
  rawset(tbl, maxVal, key)
end

-- Update value in enum
function Mod:UpdateEnum(tbl, key, value)
  local tblType = tbl and type(tbl) or "nil"

  assert(tblType == "table", "UpdateEnum: First argument expected to be of type table, was " .. tblType)
  assert(key, "UpdateEnum: Required second argument \"key\" missing.")
  assert(value, "UpdateEnum: Required third argument \"value\" missing.")

  assert(rawget(tbl,key), "UpdateEnum: key doesn't exist in table.")

  rawset(tbl, rawget(tbl, key), value)
  rawset(tbl, key, value)
end

-- Delete key from enum
function Mod:RemoveFromEnum(tbl, key)
  local tblType = tbl ~= nil and type(tbl) or "nil"

  assert(tblType == "table", "RemoveFromEnum: First argument expected to be of type table, was " .. tblType)
  assert(key ~= nil, "RemoveFromEnum: Required second argument \"key\" missing.")
  assert(rawget(tbl,key) ~= nil, "RemoveFromEnum: key doesn't exist in table.")

  rawset(tbl, rawget(tbl, key), nil)
  rawset(tbl, key, nil)

  local maxVal = 0
  if tbl == kTechId then
    maxVal = tbl.Max

    -- delete old max
    rawset(tbl, rawget(tbl, maxVal), nil)
    rawset(tbl, maxVal, nil)

    -- move max down
    rawset(tbl, 'Max', maxVal-1)
    rawset(tbl, maxVal-1, 'Max')
  end
end

function Mod:PrintCallStack()
  Shared.Message(Script.CallStack())
end

-- Shared.Message wrapper
function Mod:Print(str, level, vm)
  local strType = str and type(str) or "nil"
  assert(strType == "string", "Print: First argument expected to be of type string, was " .. strType)

  local kLogLevels = self:GetLogLevels()
  local config = self:GetConfig()
  local logLevel = self:GetConfigLogLevel()
  local kModName = self:GetModName()

  level = level or kLogLevels.info

  local levelType = level and type(level) or "nil"
  assert(levelType == "table", "Print: Second argument expected to be of type table, was " .. levelType)

  if logLevel.level < level.level then
    return
  end

  local current_vm = Client and "Client" or Server and "Server" or Predict and "Predict" or "Unknown"

  local msg = string.format("[%s - %s] (%s) %s", kModName, current_vm, level.display, str)

  if not vm
  or vm == "Server" and Server
  or vm == "Client" and Client
  or vm == "Predict" and Predict
  or vm == "all" then

    Shared.Message(msg)
  end
end

-- Debug print
function Mod:PrintDebug(str, vm)
  local strType = str and type(str) or "nil"
  assert(strType == "string", "DebugPrint: First argument expected to be of type string, was " .. strType)
  self:Print(str, self.kLogLevels.debug, vm)
end

-- Prints the mod version to console using the given vm
function Mod:PrintVersion(vm)
  local version = self:GetVersion()
  self:Print(string.format("%s version: %s loaded", self.config.kModName, version), self.kLogLevels.info, vm)
end

-- Returns a string with the mod version
function Mod:GetVersion()
  return string.format("v%s.%s", self.config.kModVersion, self.config.kModBuild);
end

-- Returns the relative ns2 path used to find lua files
function Mod:FormatDir(module, name, file)
  local moduleType = module and type(module) or "nil"
  assert(moduleType == "string", "FormatDir: First argument expected to be of type string, was " .. moduleType)

  if name then
    if file then
      return string.format("lua/%s/%s/%s.lua", self.config.kModName, module, name)
    else
      return string.format("lua/%s/%s/%s/*.lua", self.config.kModName, module, name)
    end
  else
    return string.format("lua/%s/%s/*.lua", self.config.kModName, module)
  end
end

--[[
=====================
  Binding Functions
=====================
]]

local bindingAdditions = {}

function Mod:AddNewBind(name, type, transKey, default, afterName)
  assert(name)
  assert(type)
  assert(transKey)
  assert(default)
  assert(afterName)
  table.insert(bindingAdditions, { name, type, transKey, default, afterName })
end

--[[
======================
    Tech Functions
======================
]]

-- TODO: funcs to add tech
-- TODO: Make tech tree changes automatic
-- TODO: Autogenerate TeamInfo from TechIds
-- TODO: Auto add events to GUIEvent

local kTechIdToMaterialOffsetAdditions = {}

function Mod:AddTechIdToMaterialOffset(techId, offset)
  table.insert(kTechIdToMaterialOffsetAdditions, {techId, offset})
end

function Mod:GetLinePositionForTechMap(techMap, fromTechId, toTechId)
  Mod:PrintDebug("fromTechId: %s", fromTechId)
  Mod:PrintDebug("toTechId: %s", toTechId)

  local positions = { 0, 0, 0, 0 }
  local foundFrom = false
  local foundTo = false

  for i = 1, #techMap do

    local entry = techMap[i]
    if entry[1] == fromTechId then

      positions[1] = entry[2]
      positions[2] = entry[3]
      foundFrom = true

    elseif entry[1] == toTechId then

      positions[3] = entry[2]
      positions[4] = entry[3]
      foundTo = true

    end

    if foundFrom and foundTo then
      break
    end

  end

  return positions

end

-- alien techmap
local kAlienTechmapTechToChange = {}
local kAlienTechmapTechToAdd = {}
local kAlienTechmapTechToRemove = {}

local kAlienTechmapLinesToChange = {}
local kAlienTechmapLinesToAdd = {}
local kAlienTechmapLinesToRemove = {}
local kAlienTechmapLinesToRemoveByNodes = {}

function Mod:ChangeAlienTechmapTech(techId, x, y)
  table.insert(kAlienTechmapTechToChange, techId, { techId, x, y } )
end

function Mod:AddAlienTechmapTech(techId, x, y)
  table.insert(kAlienTechmapTechToAdd, techId, { techId, x, y } )
end

function Mod:DeleteAlienTechmapTech(techId)
  table.insert(kAlienTechmapTechToRemove, techId, true )
end

function Mod:ChangeAlienTechmapLine(oldLine, newLine)
  table.insert(kAlienTechmapLinesToChange, { oldLine, newLine } )
end

function Mod:AddAlienTechmapLine(newLine)
  table.insert(kAlienTechmapLinesToAdd, { newLine } )
end

function Mod:DeleteAlienTechmapLine(line)
  table.insert(kAlienTechmapLinesToRemove, line )
end

function Mod:DeleteAlienTechmapLineByNodes(node1, node2)
  table.insert(kAlienTechmapLinesToRemoveByNodes, {node1, node2})
end

-- marine techmap
local kMarineTechmapTechToChange = {}
local kMarineTechmapTechToAdd = {}
local kMarineTechmapTechToRemove = {}

local kMarineTechmapLinesToChange = {}
local kMarineTechmapLinesToAdd = {}
local kMarineTechmapLinesToRemove = {}

function Mod:ChangeMarineTechmapTech(techId, x, y)
  table.insert(kMarineTechmapTechToChange, techId, { techId, x, y } )
end

function Mod:AddMarineTechmapTech(techId, x, y)
  table.insert(kMarineTechmapTechToAdd, techId, { techId, x, y } )
end

function Mod:DeleteMarineTechmapTech(techId)
  table.insert(kMarineTechmapTechToRemove, techId, true )
end

function Mod:ChangeMarineTechmapLine(oldLine, newLine)
  table.insert(kMarineTechmapLinesToChange, { oldLine, newLine } )
end

function Mod:AddMarineTechmapLine(newLine)
  table.insert(kMarineTechmapLinesToAdd, { 0, newLine } )
end

function Mod:AddMarineTechmapLineWithTech(tech1, tech2)
  table.insert(kMarineTechmapLinesToAdd, { 1, tech1, tech2 })
end

function Mod:DeleteMarineTechmapLine(line)
  table.insert(kMarineTechmapLinesToRemove, { 0, line } )
end

function Mod:DeleteMarineTechmapLineWithTech(tech1, tech2)
  table.insert(kMarineTechmapLinesToRemove, { 1, tech1, tech2 } )
end

-- tech data changes
local kTechToRemove = {}
local kTechToChange = {}
local kTechToAdd = {}

function Mod:RemoveTech(techId)
  table.insert(kTechToRemove, techId, true )
end

function Mod:ChangeTech(techId, newTechData)
  table.insert(kTechToChange, techId, newTechData )
end

function Mod:AddTech(techData)
  table.insert(kTechToAdd, techData)
end

-- upgrade nodes
local kUpgradesToRemove = {}
local kUpgradesToChange = {}
local kUpgradesToAdd    = {}

function Mod:RemoveUpgrade(techId)
  table.insert(kUpgradesToRemove, techId, true)
end

function Mod:ChangeUpgrade(techId, prereq1, prereq2)
  table.insert(kUpgradesToChange, techId, { techId, prereq1, prereq2 } )
end

function Mod:AddUpgradeNode(techId, prereq1, prereq2, team)
  table.insert(kUpgradesToAdd, {techId, prereq1, prereq2, team})
end

-- research nodes
local kResearchToRemove = {}
local kResearchToChange = {}
local kResearchToAdd = {}

function Mod:RemoveResearch(techId)
  table.insert(kResearchToRemove, techId, true)
end

function Mod:ChangeResearch(techId, prereq1, prereq2, addOnTechId)
  table.insert(kResearchToChange, techId, { techId, prereq1, prereq2, addOnTechId } )
end

function Mod:AddResearchNode(techId, prereq1, prereq2, addOnTechId)
  table.insert(kResearchToAdd, { techId, prereq1, prereq2, addOnTechId } )
end

-- targeted activation
local kTargetedActivationToRemove = {}
local kTargetedActivationToChange = {}

function Mod:RemoveTargetedActivation(techId)
  table.insert(kTargetedActivationToRemove, techId, true)
end

function Mod:ChangeTargetedActivation(techId, prereq1, prereq2)
  table.insert(kTargetedActivationToChange, techId, { techId, prereq1, prereq2 } )
end

-- buy nodes
local kBuyToRemove = {}
local kBuyToChange = {}
local kBuyToAdd = {}

function Mod:RemoveBuyNode(techId)
  table.insert(kBuyToRemove, techId, true)
end

function Mod:ChangeBuyNode(techId, prereq1, prereq2, addOnTechId)
  table.insert(kBuyToChange, techId, { techId, prereq1, prereq2, addOnTechId } )
end

function Mod:AddBuyNode(techId, prereq1, prereq2, addOnTechId)
  table.insert(kBuyToAdd, { techId, prereq1, prereq2, addOnTechId } )
end

-- build nodes
local kBuildToRemove = {}
local kBuildToChange = {}
local kBuildToAdd = {}

function Mod:RemoveBuildNode(techId)
  table.insert(kBuildToRemove, techId, true)
end

function Mod:ChangeBuildNode(techId, prereq1, prereq2, isRequired)
  table.insert(kBuildToChange, techId, { techId, prereq1, prereq2, isRequired } )
end

function Mod:AddBuildNode(techId, prereq1, prereq2, isRequired)
  table.insert(kBuildToAdd, { techId, prereq1, prereq2, isRequired })
end

-- passive
local kPassiveToRemove = {}
local kPassiveToChange = {}

function Mod:RemovePassive(techId)
  table.insert(kPassiveToRemove, techId, true)
end

function Mod:ChangePassive(techId, prereq1, prereq2)
  table.insert(kPassiveToChange, techId, { techId, prereq1, prereq2 } )
end

-- special
local kSpecialToRemove = {}
local kSpecialToChange = {}

function Mod:RemoveSpecial(techId)
  table.insert(kSpecialToRemove, techId, true)
end

function Mod:ChangeSpecial(techId, prereq1, prereq2, requiresTarget)
  table.insert(kSpecialToChange, techId, { techId, prereq1, prereq2, requiresTarget } )
end

-- manufacture node
local kManufactureNodeToRemove = {}
local kManufactureNodeToChange = {}

function Mod:RemoveManufactureNode(techId)
  table.insert(kManufactureNodeToRemove, techId, true)
end

function Mod:ChangeManufactureNode(techId, prereq1, prereq2, isRequired)
  table.insert(kManufactureNodeToChange, techId, { techId, prereq1, prereq2, isRequired } )
end

-- orders
local kOrderToRemove = {}

function Mod:RemoveOrder(techId)
  table.insert(kOrderToRemove, techId, true)
end

-- activation
local kActivationToRemove= {}
local kActivationToChange = {}
local kActivationToAdd = {}

function Mod:RemoveActivation(techId)
  table.insert(kActivationToRemove, techId, true)
end

function Mod:ChangeActivation(techId, prereq1, prereq2)
  table.insert(kActivationToChange, techId, { techId, prereq1, prereq2 } )
end

function Mod:AddActivation(techId, prereq1, prereq2)
  table.insert(kActivationToAdd, { techId, prereq1, prereq2 } )
end

-- Targeted Buy Node
local kTargetedBuyToRemove = {}
local kTargetedBuyToChange = {}

function Mod:RemoveTargetedBuy(techId)
  table.insert(kTargetedBuyToRemove, techId, true)
end

function Mod:ChangeTargetedBuy(techId, prereq1, prereq2, addOnTechId)
  table.insert(kTargetedBuyToChange, techId, { techId, prereq1, prereq2, addOnTechId } )
end

function Mod:OnTechIdsAdded()
  techIdsLoaded = true
end

-- getters BOOOOO

function Mod:GetTechIdsToAdd()
  return self.config.techIdsToAdd
end

function Mod:GetBindingAdditions()
  return bindingAdditions
end

function Mod:GetFrameworkVersion()
  return framework_version
end

function Mod:GetFrameworkBuild()
  return framework_build
end

function Mod:GetFrameworkVersionPrintable()
  return string.format("v%s.%s", self:GetFrameworkVersion(), self:GetFrameworkBuild())
end

function Mod:GetTechIdToMaterialOffsetAdditions()
  return kTechIdToMaterialOffsetAdditions
end

function Mod:GetAlienTechMapChanges()
  return kAlienTechmapTechToChange
end

function Mod:GetAlienTechMapAdditions()
  return kAlienTechmapTechToAdd
end

function Mod:GetAlienTechMapDeletions()
  return kAlienTechmapTechToRemove
end

function Mod:GetAlienTechMapLineChanges()
  return kAlienTechmapLinesToChange
end

function Mod:GetAlienTechMapLineAdditions()
  return kAlienTechmapLinesToAdd
end

function Mod:GetAlienTechMapLineDeletions()
  return kAlienTechmapLinesToRemove
end

function Mod:GetAlienTechMapLineToDeleteByNodes()
  return kAlienTechmapLinesToRemoveByNodes
end

function Mod:GetMarineTechMapChanges()
  return kMarineTechmapTechToChange
end

function Mod:GetMarineTechMapAdditions()
  return kMarineTechmapTechToAdd
end

function Mod:GetMarineTechMapDeletions()
  return kMarineTechmapTechToRemove
end

function Mod:GetMarineTechMapLineChanges()
  return kMarineTechmapLinesToChange
end

function Mod:GetMarineTechMapLineAdditions()
  return kMarineTechmapLinesToAdd
end

function Mod:GetMarineTechMapLineDeletions()
  return kMarineTechmapLinesToRemove
end

function Mod:GetTechToRemove()
  return kTechToRemove
end

function Mod:GetTechToChange()
  return kTechToChange
end

function Mod:GetTechToAdd()
  return kTechToAdd
end

function Mod:GetUpgradesToRemove()
  return kUpgradesToRemove
end

function Mod:GetUpgradesToChange()
  return kUpgradesToChange
end

function Mod:GetUpgradesToAdd()
  return kUpgradesToAdd
end

function Mod:GetResearchToRemove()
  return kResearchToRemove
end

function Mod:GetResearchToChange()
  return kResearchToChange
end

function Mod:GetResearchToAdd()
  return kResearchToAdd
end

function Mod:GetTargetedActivationToRemove()
  return kTargetedActivationToRemove
end

function Mod:GetTargetedActivationToChange()
  return kTargetedActivationToChange
end

function Mod:GetBuyNodesToRemove()
  return kBuyToRemove
end

function Mod:GetBuyNodesToChange()
  return kBuyToChange
end

function Mod:GetBuyNodesToAdd()
  return kBuyToAdd
end

function Mod:GetBuildNodesToRemove()
  return kBuildToRemove
end

function Mod:GetBuildNodesToChange()
  return kBuildToChange
end

function Mod:GetBuildNodesToAdd()
  return kBuildToAdd
end

function Mod:GetPassiveToRemove()
  return kPassiveToRemove
end

function Mod:GetPassiveToChange()
  return kPassiveToChange
end

function Mod:GetSpecialToRemove()
  return kSpecialToRemove
end

function Mod:GetSpecialToChange()
  return kSpecialToChange
end

function Mod:GetManufactureNodesToRemove()
  return kManufactureNodeToRemove
end

function Mod:GetManufactureNodesToChange()
  return kManufactureNodeToChange
end

function Mod:GetOrdersToRemove()
  return kOrderToRemove
end

function Mod:GetActivationToRemove()
  return kActivationToRemove
end

function Mod:GetActivationToChange()
  return kActivationToChange
end

function Mod:GetActivationToAdd()
  return kActivationToAdd
end

function Mod:GetTargetedBuyToRemove()
  return kTargetedBuyToRemove
end

function Mod:GetTargetedBuyToChange()
  return kTargetedBuyToChange
end

function Mod:GetLogLevels()
  return self.kLogLevels
end

function Mod:GetConfig()
  return self.config
end

function Mod:GetConfigLogLevel()
  return self.config.kLogLevel
end

function Mod:GetModName()
  return self.config.kModName
end

--[[
========================
      Helper Funcs
========================
]]

-- i wish the # operator was deterministic
function table.real_length(tbl)
  local count = 0
  for k,v in pairs(tbl) do
    count = count + 1
  end
  return count
end

function table.contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

--[[
========================
      Binding Funcs
========================
]]
local function UpdateBindingData()
  -- local globalControlBindings = Mod:GetLocalVariable(BindingsUI_GetBindingsData, "globalControlBindings")
  -- local defaults = Mod:GetLocalVariable(GetDefaultInputValue, "defaults")
  -- local bindingChanges = Mod:GetBindingAdditions()

  -- for _,v in ipairs(bindingChanges) do
  --   local afterName = v[5]

  --   Mod:PrintDebug("Adding new bind \"" .. v[1].. "\" after " .. afterName)

  --   v[3] = Locale.ResolveString(v[3])

  --   local index

  --   -- globalControlBindingss

  --   for i,v in ipairs(globalControlBindings) do
  --     if v == afterName then
  --       index = i + 4
  --     end
  --   end

  --   assert(index, "BindingChanges: Binding \"" .. afterName .. "\" does not exist.")

  --   for i=0,3 do
  --     table.insert(globalControlBindings, index + i, v[i + 1])
  --   end

  --   -- defaults

  --   for i,def in pairs(defaults) do
  --     if def[1] == afterName then
  --       table.insert(defaults, i+1, {v[1], v[4]})
  --       break
  --     end
  --   end
  -- end
end

Event.Hook("LoadComplete", UpdateBindingData)

--[[
====================
    Config Funcs
====================
]]

local configOptions = {}
local defaultConfigOptions = {}

function Mod:GetConfigFileName()
  local modName = self:GetModName()

  if Server then
    return modName .. "_Server.json"
  end

  return modName .. ".json"
end

function Mod:RegisterConfigOption(name, value)
  assert(not configOptions[name], string.format("RegisterConfigOption: %q is already registered", name))
  defaultConfigOptions[name] = value
end

function Mod:GetDefaultConfigOptions()
  return defaultConfigOptions
end

function Mod:GetConfigOption(name)
  assert(configOptions[name], string.format("GetConfigOption: No config option with the name %q is registered", name))
  return configOptions[name]
end

function Mod:UpdateConfigOption(name, value)
  assert(configOptions[name], string.format("UpdateConfigOption: No config option with the name %q is registered", name))
  configOptions[name] = value
  self:SaveConfigOptions()
end

function Mod:SaveConfigOptions()
  SaveConfigFile(self:GetConfigFileName(), configOptions)
end

function Mod:LoadConfig()
  configOptions = LoadConfigFile(self:GetConfigFileName()) or defaultConfigOptions
end

--[[
=======================
    Resource System
=======================
]]

local guiTexturesToReplace = {}

function Mod:ReplaceGUITexture(old, new)
  assert(not guiTexturesToReplace[old], string.format("ReplaceGUITexture: The texture %q is already being replaced with %q.", old, guiTexturesToReplace[old]))
  guiTexturesToReplace[old] = new
end

function Mod:GetGUITexturesToReplace()
  return guiTexturesToReplace
end

-- We're finally done
-- Init the stuff

Mod:Initialise()
