-- at this point we can assume that kModName has been set both in ModShared.lua and in ModFileHooks.lua

Script.Load("lua/" .. kModName .. "/Config.lua")

table.insert(Modules, "Framework/Framework")

-- Retrieve referenced local variable
--
-- Original author: https://forums.unknownworlds.com/discussion/comment/2178874#Comment_2178874
function GetLocalVariable(originalFunction, localName)

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
function AppendToEnum(tbl, key)
    if rawget(tbl,key) ~= nil then
        ModPrintDebug("Key already exists in enum.")
        Shared.Message(Script.CallStack())
        return
    end

    local maxVal = 0
    if tbl == kTechId then
        maxVal = tbl.Max

        if maxVal - 1 == kTechIdMax then
            ModPrintDebug( "Appending another value to the TechId enum would exceed network precision constraints" )
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
function UpdateEnum(tbl, key, value)
  if rawget(tbl, key) == nil then
    ModPrintDebug("Error updating enum: key doesn't exist in table.")
    Shared.Message(Script.CallStack())
    return
  end

  rawset(tbl, rawget(tbl, key), value)
  rawset( tbl, key, value )
end

-- Delete key from enum
function DeleteFromEnum( tbl, key )
	if rawget(tbl,key) == nil then
        ModPrintDebug("Cannot delete value from enum: key doesn't exist in table.")
        Shared.Message(Script.CallStack())
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

-- Shared.Message wrapper
function ModPrint(msg, vm, debug)
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

	local str = string.format("[%s (%s%s)] %s", kModName, current_vm, debug_str, msg)

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
function ModPrintDebug(msg, vm)
	if kAllowModDebugMessages then
		ModPrint(msg, vm, true)
	end
end

-- Prints the mod version to console using the given vm
function ModPrintVersion(vm)
	local version = GetModVersion()
	ModPrint("Version: " .. version .. " loaded", vm)
end

-- Returns a string with the mod version
function GetModVersion()
	return "v" .. kModVersion .. "." .. kModBuild;
end

-- Returns the relative ns2 path used to find lua files from the given module and vm
function FormatDir(module, vm)
	return "lua/" .. kModName ..  "/" .. module .. "/" .. vm .. "/*.lua"
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

function AddTechIdToMaterialOffset(techId, offset)
	table.insert(kTechIdToMaterialOffsetAdditions, {techId, offset})
end

function AddTechId(techId)
	ModPrintDebug("Adding techId: " .. techId, "all")
	AppendToEnum(kTechId, techId)
end

-- alien techmap
local kAlienTechmapTechToChange = {}
local kAlienTechmapTechToAdd = {}
local kAlienTechmapTechToRemove = {}

local kAlienTechmapLinesToChange = {}
local kAlienTechmapLinesToAdd = {}
local kAlienTechmapLinesToRemove = {}

function ChangeAlienTechmapTech(techId, x, y)
	table.insert(kAlienTechmapTechToChange, techId, { techId, x, y } )
end

function AddAlienTechmapTech(techId, x, y)
	table.insert(kAlienTechmapTechToAdd, techId, { techId, x, y } )
end

function DeleteAlienTechmapTech(techId)
	table.insert(kAlienTechmapTechToRemove, techId, true )
end

function ChangeAlienTechmapLine(oldLine, newLine)
	table.insert(kAlienTechmapLinesToChange, { oldLine, newLine } )
end

function AddAlienTechmapLine(newLine)
	table.insert(kAlienTechmapLinesToAdd, { newLine } )
end

function DeleteAlienTechmapLine(line)
	table.insert(kAlienTechmapLinesToRemove, line )
end

-- marine techmap
local kMarineTechmapTechToChange = {}
local kMarineTechmapTechToAdd = {}
local kMarineTechmapTechToRemove = {}

local kMarineTechmapLinesToChange = {}
local kMarineTechmapLinesToAdd = {}
local kMarineTechmapLinesToRemove = {}

function ChangeMarineTechmapTech(techId, x, y)
	table.insert(kMarineTechmapTechToChange, techId, { techId, x, y } )
end

function AddMarineTechmapTech(techId, x, y)
	table.insert(kMarineTechmapTechToAdd, techId, { techId, x, y } )
end

function DeleteMarineTechmapTech(techId)
	table.insert(kMarineTechmapTechToRemove, techId, true )
end

function ChangeMarineTechmapLine(oldLine, newLine)
	table.insert(kMarineTechmapLinesToChange, { oldLine, newLine } )
end

function AddMarineTechmapLine(newLine)
	table.insert(kMarineTechmapLinesToAdd, { 0, newLine } )
end

function AddMarineTechmapLineWithTech(tech1, tech2)
	table.insert(kMarineTechmapLinesToAdd, { 1, tech1, tech2 })
end

function DeleteMarineTechmapLine(line)
	table.insert(kMarineTechmapLinesToRemove, { 0, line } )
end

function DeleteMarineTechmapLineWithTech(tech1, tech2)
	table.insert(kMarineTechmapLinesToRemove, { 1, tech1, tech2 } )
end

-- tech data changes
local kTechToRemove = {}
local kTechToChange = {}
local kTechToAdd = {}

function RemoveTech(techId)
	table.insert(kTechToRemove, techId, true )
end

function ChangeTech(techId, newTechData)
	table.insert(kTechToChange, techId, newTechData )
end

function AddTech(techData)
	table.insert(kTechToAdd, techData)
end

-- upgrade nodes
local kUpgradesToRemove = {}
local kUpgradesToChange = {}

function RemoveUpgrade(techId)
	table.insert(kUpgradesToRemove, techId, true)
end

function ChangeUpgrade(techId, prereq1, prereq2)
	table.insert(kUpgradesToChange, techId, { techId, prereq1, prereq2 } )
end

-- research nodes
local kResearchToRemove = {}
local kResearchToChange = {}
local kResearchToAdd = {}

function RemoveResearch(techId)
	table.insert(kResearchToRemove, techId, true)
end

function ChangeResearch(techId, prereq1, prereq2, addOnTechId)
	table.insert(kResearchToChange, techId, { techId, prereq1, prereq2, addOnTechId } )
end

function AddResearchNode(techId, prereq1, prereq2, addOnTechId)
	table.insert(kResearchToAdd, { techId, prereq1, prereq2, addOnTechId } )
end

-- targeted activation
local kTargetedActivationToRemove = {}
local kTargetedActivationToChange = {}

function RemoveTargetedActivation(techId)
	table.insert(kTargetedActivationToRemove, techId, true)
end

function ChangeTargetedActivation(techId, prereq1, prereq2)
	table.insert(kTargetedActivationToChange, techId, { techId, prereq1, prereq2 } )
end

-- buy nodes
local kBuyToRemove = {}
local kBuyToChange = {}

function RemoveBuyNode(techId)
	table.insert(kBuyToRemove, techId, true)
end

function ChangeBuyNode(techId, prereq1, prereq2, addOnTechId)
	table.insert(kBuyToChange, techId, { techId, prereq1, prereq2, addOnTechId } )
end

-- build nodes
local kBuildToRemove = {}
local kBuildToChange = {}

function RemoveBuildNode(techId)
	table.insert(kBuildToRemove, techId, true)
end

function ChangeBuildNode(techId, prereq1, prereq2, isRequired)
	table.insert(kBuildToChange, techId, { techId, prereq1, prereq2, isRequired } )
end

-- passive
local kPassiveToRemove = {}
local kPassiveToChange = {}

function RemovePassive(techId)
	table.insert(kPassiveToRemove, techId, true)
end

function ChangePassive(techId, prereq1, prereq2)
	table.insert(kPassiveToChange, techId, { techId, prereq1, prereq2 } )
end

-- special
local kSpecialToRemove = {}
local kSpecialToChange = {}

function RemoveSpecial(techId)
	table.insert(kSpecialToRemove, techId, true)
end

function ChangeSpecial(techId, prereq1, prereq2, requiresTarget)
	table.insert(kSpecialToChange, techId, { techId, prereq1, prereq2, requiresTarget } )
end

-- manufacture node
local kManufactureNodeToRemove = {}
local kManufactureNodeToChange = {}

function RemoveManufactureNode(techId)
	table.insert(kManufactureNodeToRemove, techId, true)
end

function ChangeManufactureNode(techId, prereq1, prereq2, isRequired)
	table.insert(kManufactureNodeToChange, techId, { techId, prereq1, prereq2, isRequired } )
end

-- orders
local kOrderToRemove = {}

function RemoveOrder(techId)
	table.insert(kOrderToRemove, techId, true)
end

-- activation
local kActivationToRemove= {}
local kActivationToChange = {}
local kActivationToAdd = {}

function RemoveActivation(techId)
	table.insert(kActivationToRemove, techId, true)
end

function ChangeActivation(techId, prereq1, prereq2)
	table.insert(kActivationToChange, techId, { techId, prereq1, prereq2 } )
end

function AddActivation(techId, prereq1, prereq2)
	table.insert(kActivationToAdd, { techId, prereq1, prereq2 } )
end

-- Targeted Buy Node
local kTargetedBuyToRemove = {}
local kTargetedBuyToChange = {}

function RemoveTargetedBuy(techId)
	table.insert(kTargetedBuyToRemove, techId, true)
end

function ChangeTargetedBuy(techId, prereq1, prereq2, addOnTechId)
	table.insert(kTargetedBuyToChange, techId, { techId, prereq1, prereq2, addOnTechId } )
end

-- getters BOOOOO

function GetTechIdToMaterialOffsetAdditions()
	return kTechIdToMaterialOffsetAdditions
end

function GetAlienTechMapChanges()
	return kAlienTechmapTechToChange
end

function GetAlienTechMapAdditions()
	return kAlienTechmapTechToAdd
end

function GetAlienTechMapDeletions()
	return kAlienTechmapTechToRemove
end

function GetAlienTechMapLineChanges()
	return kAlienTechmapLinesToChange
end

function GetAlienTechMapLineAdditions()
	return kAlienTechmapLinesToAdd
end

function GetAlienTechMapLineDeletions()
	return kAlienTechmapLinesToRemove
end

function GetMarineTechMapChanges()
	return kMarineTechmapTechToChange
end

function GetMarineTechMapAdditions()
	return kMarineTechmapTechToAdd
end

function GetMarineTechMapDeletions()
	return kMarineTechmapTechToRemove
end

function GetMarineTechMapLineChanges()
	return kMarineTechmapLinesToChange
end

function GetMarineTechMapLineAdditions()
	return kMarineTechmapLinesToAdd
end

function GetMarineTechMapLineDeletions()
	return kMarineTechmapLinesToRemove
end

function GetTechToRemove()
	return kTechToRemove
end

function GetTechToChange()
	return kTechToChange
end

function GetTechToAdd()
	return kTechToAdd
end

function GetUpgradesToRemove()
	return kUpgradesToRemove
end

function GetUpgradesToChange()
	return kUpgradesToChange
end

function GetResearchToRemove()
	return kResearchToRemove
end

function GetResearchToChange()
	return kResearchToChange
end

function GetResearchToAdd()
	return kResearchToAdd
end

function GetTargetedActivationToRemove()
	return kTargetedActivationToRemove
end

function GetTargetedActivationToChange()
	return kTargetedActivationToChange
end

function GetBuyNodesToRemove()
	return kBuyToRemove
end

function GetBuyNodesToChange()
	return kBuyToChange
end

function GetBuildNodesToRemove()
	return kBuildToRemove
end

function GetBuildNodesToChange()
	return kBuildToChange
end

function GetPassiveToRemove()
	return kPassiveToRemove
end

function GetPassiveToChange()
	return kPassiveToChange
end

function GetSpecialToRemove()
	return kSpecialToRemove
end

function GetSpecialToChange()
	return kSpecialToChange
end

function GetManufactureNodesToRemove()
	return kManufactureNodeToRemove
end

function GetManufactureNodesToChange()
	return kManufactureNodeToChange
end

function GetOrdersToRemove()
	return kOrderToRemove
end

function GetActivationToRemove()
	return kActivationToRemove
end

function GetActivationToChange()
	return kActivationToChange
end

function GetActivationToAdd()
	return kActivationToAdd
end

function GetTargetedBuyToRemove()
	return kTargetedBuyToRemove
end

function GetTargetedBuyToChange()
	return kTargetedBuyToChange
end
