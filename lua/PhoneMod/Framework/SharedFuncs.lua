-- at this point we can assume that kModName has been set both in ModShared.lua and in ModFileHooks.lua

Mod = {}
Mod.config = {}
Mod.config.kModName = kModName

Script.Load("lua/" .. Mod.config.kModName .. "/Config.lua")

table.insert(Mod.config.modules, "Framework/Framework")

-- Retrieve referenced local variable
--
-- Original author: https://forums.unknownworlds.com/discussion/comment/2178874#Comment_2178874
function Mod:GetLocalVariable(originalFunction, localName)

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

    return nil

end

-- Append new value to enum
function Mod:AppendToEnum(tbl, key)
    if rawget(tbl,key) ~= nil then
        self:PrintDebug("Key already exists in enum.")
        self.PrintCallStack()
        return
    end

    local maxVal = 0
    if tbl == kTechId then
        maxVal = tbl.Max

        if maxVal - 1 == kTechIdMax then
            self:PrintDebug( "Appending another value to the TechId enum would exceed network precision constraints" )
            self.PrintCallStack()
            return
        end

        -- move max down
		rawset( tbl, 'Max', maxVal-1 )
		rawset( tbl, maxVal-1, 'Max' )

        -- delete old max
        rawset(tbl, rawget(tbl, maxVal), nil)
        rawset( tbl, maxVal, nil )
    else
        for k, v in next, tbl do
            if type(v) == "number" and v > maxVal then
                maxVal = v
            end
        end
        maxVal = maxVal + 1
    end

    rawset( tbl, key, maxVal )
    rawset( tbl, maxVal, key )
end

-- Update value in enum
function Mod:UpdateEnum(tbl, key, value)
  if rawget(tbl, key) == nil then
    self:PrintDebug("Error updating enum: key doesn't exist in table.")
    self.PrintCallStack()
    return
  end

  rawset(tbl, rawget(tbl, key), value)
  rawset( tbl, key, value )
end

-- Delete key from enum
function Mod:DeleteFromEnum( tbl, key )
	if rawget(tbl,key) == nil then
        self:PrintDebug("Cannot delete value from enum: key doesn't exist in table.")
        self.PrintCallStack()
        return
	end

    rawset(tbl, rawget(tbl, key), nil)
    rawset( tbl, key, nil )

	local maxVal = 0
	if tbl == kTechId then
		maxVal = tbl.Max

        -- move max down
		rawset( tbl, 'Max', maxVal-1 )
		rawset( tbl, maxVal-1, 'Max' )

        -- delete old max
        rawset(tbl, rawget(tbl, maxVal), nil)
        rawset( tbl, maxVal, nil )
	end
end

function Mod:PrintCallStack()
    Shared.Message(Script.CallStack())
end

-- Shared.Message wrapper
function Mod:Print(msg, vm, debug)
	local current_vm = ""
	local debug_str = (debug and " - Debug" or "")

	if Client then
		current_vm = "Client"
	elseif Server then
		current_vm = "Server"
	elseif Predict then
		current_vm = "Predict"
	end

	assert(current_vm ~= "")

	local str = string.format("[%s (%s%s)] %s", self.config.kModName, current_vm, debug_str, msg)

	if not vm then
		Shared.Message(str)
	elseif vm == "Server" and Server
		or vm == "Client" and Client
		or vm == "Predict" and Predict
		or vm == "all" then

		Shared.Message(str)
	end
end

-- Debug print
function Mod:PrintDebug(msg, vm)
	if self.config.kAllowDebugMessages then
		Mod:Print(msg, vm, true)
	end
end

-- Prints the mod version to console using the given vm
function Mod:PrintVersion(vm)
	local version = self:GetVersion()
	self:Print("Version: " .. version .. " loaded", vm)
end

-- Returns a string with the mod version
function Mod:GetVersion()
	return "v" .. self.config.kModVersion .. "." .. self.config.kModBuild;
end

-- Returns the relative ns2 path used to find lua files from the given module and vm
function Mod:FormatDir(module, vm)
	return "lua/" .. self.config.kModName ..  "/" .. module .. "/" .. vm .. "/*.lua"
end

--[[
======================
    Tech Functions
======================
]]

-- TODO: funcs to add tech
-- TODO: Make tech tree changes automatic

-- ktechids
local kTechIdToMaterialOffsetAdditions = {}

function Mod:AddTechIdToMaterialOffset(techId, offset)
	table.insert(kTechIdToMaterialOffsetAdditions, {techId, offset})
end

function Mod:AddTechId(techId)
	self:PrintDebug("Adding techId: " .. techId, "all")
	self:AppendToEnum(kTechId, techId)
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

function Mod:RemoveBuyNode(techId)
	table.insert(kBuyToRemove, techId, true)
end

function Mod:ChangeBuyNode(techId, prereq1, prereq2, addOnTechId)
	table.insert(kBuyToChange, techId, { techId, prereq1, prereq2, addOnTechId } )
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

_G[Mod.config.kModName] = Mod
