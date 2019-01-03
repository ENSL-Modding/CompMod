function recalculateTechTreeLines()
	kMarineLines =
	{
	    GetLinePositionForTechMap(kMarineTechMap, kTechId.CommandStation, kTechId.Extractor),
	    GetLinePositionForTechMap(kMarineTechMap, kTechId.CommandStation, kTechId.InfantryPortal),

	    { 7, 1, 7, 7 },
	    { 7, 4, 3.5, 4 },
	    -- observatory:
	    { 6, 5, 7, 5 },
	    { 7, 7, 9, 7 },
	    -- nano shield:
	    { 7, 4.5, 8, 4.5},
	    -- cat pack tech:
	    { 7, 5.5, 8, 5.5},

	    -- power surge tech
	    { 7, 6.5, 8, 6.5},

	    GetLinePositionForTechMap(kMarineTechMap, kTechId.Armory, kTechId.GrenadeTech),
	    GetLinePositionForTechMap(kMarineTechMap, kTechId.Armory, kTechId.MinesTech),
	    GetLinePositionForTechMap(kMarineTechMap, kTechId.Armory, kTechId.ShotgunTech),
	    GetLinePositionForTechMap(kMarineTechMap, kTechId.Armory, kTechId.Welder),

	    GetLinePositionForTechMap(kMarineTechMap, kTechId.Armory, kTechId.AdvancedArmory),
	    GetLinePositionForTechMap(kMarineTechMap, kTechId.AdvancedArmory, kTechId.AdvancedWeaponry),
	    --GetLinePositionForTechMap(kMarineTechMap, kTechId.AdvancedArmory, kTechId.HeavyMachineGunTech),
	    GetLinePositionForTechMap(kMarineTechMap, kTechId.AdvancedArmory, kTechId.PrototypeLab),

	    GetLinePositionForTechMap(kMarineTechMap, kTechId.PrototypeLab, kTechId.ExosuitTech),
	    GetLinePositionForTechMap(kMarineTechMap, kTechId.PrototypeLab, kTechId.JetpackTech),

	    GetLinePositionForTechMap(kMarineTechMap, kTechId.Observatory, kTechId.PhaseTech),
	    GetLinePositionForTechMap(kMarineTechMap, kTechId.PhaseTech, kTechId.PhaseGate),

	    GetLinePositionForTechMap(kMarineTechMap, kTechId.ArmsLab, kTechId.Weapons1),
	    GetLinePositionForTechMap(kMarineTechMap, kTechId.Weapons1, kTechId.Weapons2),
	    GetLinePositionForTechMap(kMarineTechMap, kTechId.Weapons2, kTechId.Weapons3),

	    GetLinePositionForTechMap(kMarineTechMap, kTechId.ArmsLab, kTechId.Armor1),
	    GetLinePositionForTechMap(kMarineTechMap, kTechId.Armor1, kTechId.Armor2),
	    GetLinePositionForTechMap(kMarineTechMap, kTechId.Armor2, kTechId.Armor3),

	    { 7, 3, 9, 3 },
	    GetLinePositionForTechMap(kMarineTechMap, kTechId.RoboticsFactory, kTechId.ARCRoboticsFactory),
	    GetLinePositionForTechMap(kMarineTechMap, kTechId.ARCRoboticsFactory, kTechId.ARC),

	    GetLinePositionForTechMap(kMarineTechMap, kTechId.RoboticsFactory, kTechId.MAC),
	    GetLinePositionForTechMap(kMarineTechMap, kTechId.RoboticsFactory, kTechId.SentryBattery),
	    GetLinePositionForTechMap(kMarineTechMap, kTechId.SentryBattery, kTechId.Sentry),

	}

	return kMarineLines
end

local techToChange = _G[kModName]:GetMarineTechMapChanges()
local techToAdd = _G[kModName]:GetMarineTechMapAdditions()
local techToRemove = _G[kModName]:GetMarineTechMapDeletions()

local linesToChange = _G[kModName]:GetMarineTechMapLineChanges()
local linesToAdd = _G[kModName]:GetMarineTechMapLineAdditions()
local linesToRemove = _G[kModName]:GetMarineTechMapLineDeletions()

-- techtree tech

-- changes
for techIndex, record in ipairs(kMarineTechMap) do
    local techId = record[1]

    if techToChange[techId] then
    	_G[kModName]:PrintDebug("Changing marine techtree entry: " .. (EnumToString(kTechId, techId) or techId), "all")
    	kMarineTechMap[techIndex] = techToChange[techId]
    end
end

-- deletions
for techIndex, record in ipairs(kMarineTechMap) do
    local techId = record[1]

    if techToRemove[techId] then
    	_G[kModName]:PrintDebug("Deleting marine techtree entry: " .. (EnumToString(kTechId, techId) or techId), "all")
		kMarineTechMap[techIndex] = {nil}
    end
end

-- additions
for _, value in pairs(techToAdd) do
	_G[kModName]:PrintDebug("Adding marine techtree entry: " .. (EnumToString(kTechId, value[1]) or value[1]), "all")
	table.insert(kMarineTechMap, value)
end

-- lines

kMarineLines = recalculateTechTreeLines()

-- changes
for index, record in ipairs(kMarineLines) do
	for _, line in ipairs(linesToChange) do
		if  record[1] == line[1][1]
		and record[2] == line[1][2]
		and record[3] == line[1][3]
		and record[4] == line[1][4] then
			_G[kModName]:PrintDebug(string.format("Changing marine techtree line: (%f, %f, %f, %f) to (%f, %f, %f, %f)", line[1][1], line[1][2], line[1][3], line[1][4], line[2][1], line[2][2], line[2][3], line[2][4]), "all")
			kMarineLines[index] = line[2]
		end
	end
end

-- deletions
for index, record in ipairs(kMarineLines) do
	for _, value in ipairs(linesToRemove) do
		line = {}

		if value[1] == 0 then
			line = value[2]
		elseif value[1] == 1 then
			line = GetLinePositionForTechMap(kMarineTechMap, value[2], value[3])
		end

		assert(line ~= {})

		if  record[1] == line[1]
		and record[2] == line[2]
		and record[3] == line[3]
		and record[4] == line[4] then
			_G[kModName]:PrintDebug(string.format("Deleting marine techtree line: %f, %f, %f, %f", line[1], line[2], line[3], line[4]), "all")
			table.remove(kMarineLines, index)
		end
	end
end

-- additions
for _, value in ipairs(linesToAdd) do
	line = {}
	if value[1] == 0 then
		line = value[2]
	elseif value[1] == 1 then
		line = GetLinePositionForTechMap(kMarineTechMap, value[2], value[3])
	end
	assert(line ~= {})
	_G[kModName]:PrintDebug(string.format("Adding marine techtree line: (%f, %f, %f, %f)", line[1], line[2], line[3], line[4]), "all")
	table.insert(kMarineLines, line)
end
