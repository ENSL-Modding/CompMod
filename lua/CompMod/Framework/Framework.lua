local framework_version = "0"
local framework_build = "8"

local kLogLevels = {
    fatal = {display="Fatal", level=0},
    error = {display="Error", level=1},
    warn  = {display="Warn",  level=2},
    info  = {display="Info",  level=3},
    debug = {display="Debug", level=4},
}

local configOptions = {
  logLevel = {
    var             = "kLogLevel",
    expectedType    = "table",
    validator       =
      function(tbl)
        assert(tbl)
        for k,v in pairs(kLogLevels) do
          if v == tbl then
            return true
          end
        end

        return false
      end,
    required        = false,
    default         = kLogLevels.info,
    displayDefault  = "info",
    warn            = true
  },

  showInFeedbackText = {
    var             = "kShowInFeedbackText",
    expectedType    = "boolean",
    required        = false,
    default         = false,
    displayDefault  = "false",
    warn            = true
  },

  modVersion = {
    var             = "kModVersion",
    expectedType    = "string",
    required        = false,
    default         = "0",
    displayDefault  = "0",
    warn            = true
  },

  modBuild = {
    var             = "kModBuild",
    expectedType    = "string",
    required        = false,
    default         = "1",
    displayDefault  = "1",
    warn            = true
  },

  modules = {
    var             = "modules",
    expectedType    = "table",
    validator       =
      function(tbl)
        assert(tbl)
        for k,v in pairs(tbl) do
          if type(v) ~= "string" then
            return false
          end
        end

        return true
      end,
    required        = false,
    default         = {},
    displayDefault  = "new table",
    warn            = true
  },
}

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

  if #config > #configOptions then
    return false, "Too many config options set"
  end

  for _,v in pairs(configOptions) do

    if config[v.var] then
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

  return true, "pass"

end

local Mod = {}

function Mod:Initialise()

    local kModName = debug.getinfo(1, "S").source:gsub("@lua/", ""):gsub("/Framework/.*%.lua", "")
    local current_vm = Client and "Client" or Server and "Server" or Predict and "Predict" or "Unknown"
    assert(kModName and type(kModName) == "string", "Initialise: Error finding mod name. Please report.")

    Shared.Message(string.format("[%s - %s] Loading framework %s", kModName, current_vm, self:GetFrameworkVersionPrintable()))

    if _G[kModName] then
        Mod = _G[kModName]
        Shared.Message(string.format("[%s - %s] Skipped loading framework %s", kModName, current_vm, self:GetFrameworkVersionPrintable()))
        return
    end

    self.kLogLevels = kLogLevels

    Script.Load("lua/" .. kModName .. "/Config.lua")

    local config = assert(GetModConfig, "Initialise: Config.lua malformed. Missing GetModConfig function.")
    config = config(kLogLevels)

    assert(config, "Initialise: Config.lua malformed. GetModConfig doesn't return anything.")
    assert(type(config) == "table", "Initialise: Config.lua malformed. GetModConfig doesn't return expected type.")

    valid, reason = ValidateConfig(config)
    assert(valid, "Initialise: Config failed validation. " .. reason)

    config.kModName = kModName
    self.config = config
    config = nil

    table.insert(self.config.modules, "Framework/Framework")

    _G[self.config.kModName] = self
    Shared.Message(string.format("[%s - %s] Framework %s loaded", kModName, current_vm, self:GetFrameworkVersionPrintable()))

end

-- Get local variable from function
function Mod:GetLocalVariable(originalFunction, localName)

    local funcType = originalFunction and type(originalFunction) or "nil"
    local nameType = localName and type(localName) == "string" or "nil"

    assert(funcType == "function", "GetLocalVariable: Expected first argument to be of type function, was given " .. funcType)
    assert(localName and type(localName) == "string", "GetLocalVariable: Expected second argument to be of type string, was given " .. funcType)

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

    self:PrintDebug("Local variable \"" .. localName .. "\" not found")

    return nil

end

-- Append new value to enum
function Mod:AppendToEnum(tbl, key)

    local tblType = tbl and type(tbl) or "nil"
    assert(tbl and type(tbl) == "table", "AppendToEnum: First argument expected to be of type table, was " .. tblType)
    assert(key, "AppendToEnum: required second argument \"key\" missing")

    assert(not rawget(tbl,key), "AppendToEnum: key already exists in enum.")

    local maxVal = 0
    if tbl == kTechId then
        maxVal = tbl.Max

        assert(maxVal - 1 ~= kTechIdMax, "AppendToEnum: Appending another value to the TechId enum would exceed network precision constraints")

        -- delete old max
        rawset(tbl, rawget(tbl, maxVal), nil)
        rawset(tbl, maxVal, nil)

        -- move max down
		rawset(tbl, 'Max', maxVal-1)
		rawset(tbl, maxVal-1, 'Max')
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

    local tblType = tbl and type(tbl) or "nil"

    assert(tblType == "table", "RemoveFromEnum: First argument expected to be of type table, was " .. tblType)
    assert(key, "RemoveFromEnum: Required second argument \"key\" missing.")

    assert(rawget(tbl,key), "RemoveFromEnum: key doesn't exist in table.")

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

    level = level or self.kLogLevels.info

    local levelType = level and type(level) or "nil"
    assert(levelType == "table", "Print: Second argument expected to be of type table, was " .. levelType)

    if self.config.kLogLevel.level < level.level then
        return
    end

    local current_vm = Client and "Client" or Server and "Server" or Predict and "Predict" or "Unknown"

    local msg = string.format("[%s - %s] (%s) %s", self.config.kModName, current_vm, level.display, str)

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

-- Returns the relative ns2 path used to find lua files from the given module and vm
function Mod:FormatDir(module, vm)

  local moduleType = module and type(module) or "nil"
  assert(moduleType == "string", "FormatDir: First argument expected to be of type string, was " .. moduleType)

  if vm then
      return string.format("lua/%s/%s/%s/*.lua", self.config.kModName, module, vm)
  else
      return string.format("lua/%s/%s/*.lua", self.config.kModName, module)
  end
end

--[[
======================
    Tech Functions
======================
]]

-- TODO: funcs to add tech
-- TODO: Make tech tree changes automatic

-- ktechids

function Mod:AddTechId(techId)
	self:PrintDebug("Adding techId: " .. techId, "all")
	self:AppendToEnum(kTechId, techId)
end

local kTechIdToMaterialOffsetAdditions = {}

function Mod:AddTechIdToMaterialOffset(techId, offset)
	table.insert(kTechIdToMaterialOffsetAdditions, {techId, offset})
end

-- alien techmap
local kAlienTechmapTechToChange = {}
local kAlienTechmapTechToAdd = {}
local kAlienTechmapTechToRemove = {}

local kAlienTechmapLinesToChange = {}
local kAlienTechmapLinesToAdd = {}
local kAlienTechmapLinesToRemove = {}

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

function Mod:RemoveUpgrade(techId)
	table.insert(kUpgradesToRemove, techId, true)
end

function Mod:ChangeUpgrade(techId, prereq1, prereq2)
	table.insert(kUpgradesToChange, techId, { techId, prereq1, prereq2 } )
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

function Mod:RemoveBuildNode(techId)
	table.insert(kBuildToRemove, techId, true)
end

function Mod:ChangeBuildNode(techId, prereq1, prereq2, isRequired)
	table.insert(kBuildToChange, techId, { techId, prereq1, prereq2, isRequired } )
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

-- getters BOOOOO

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

Mod:Initialise()
