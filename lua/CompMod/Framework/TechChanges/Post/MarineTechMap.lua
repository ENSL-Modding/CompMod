local Mod = GetMod()
local kMarineTechMapOrig = {}
for k,v in ipairs(kMarineTechMap) do
	kMarineTechMapOrig[k] = v
end

local techToChange = Mod:GetMarineTechMapChanges()
local techToAdd = Mod:GetMarineTechMapAdditions()
local techToRemove = Mod:GetMarineTechMapDeletions()

local linesToChange = Mod:GetMarineTechMapLineChanges()
local linesToAdd = Mod:GetMarineTechMapLineAdditions()
local linesToRemove = Mod:GetMarineTechMapLineDeletions()

-- techtree tech

-- changes
for techIndex, record in ipairs(kMarineTechMap) do
	local techId = record[1]

	if techToChange[techId] then
		Mod:PrintDebug("Changing marine techtree entry: " .. (EnumToString(kTechId, techId) or techId), "all")
		kMarineTechMap[techIndex] = techToChange[techId]
	end
end

-- deletions
for techIndex, record in ipairs(kMarineTechMap) do
	local techId = record[1]

	if techToRemove[techId] then
		Mod:PrintDebug("Deleting marine techtree entry: " .. (EnumToString(kTechId, techId) or techId), "all")
		table.remove(kMarineTechMap, techIndex)
	end
end

-- additions
for _, value in pairs(techToAdd) do
	Mod:PrintDebug("Adding marine techtree entry: " .. (EnumToString(kTechId, value[1]) or value[1]), "all")
	table.insert(kMarineTechMap, value)
end

-- lines
-- changes
for index, record in ipairs(kMarineLines) do
	for _, line in ipairs(linesToChange) do
		if  record[1] == line[1][1]
		and record[2] == line[1][2]
		and record[3] == line[1][3]
		and record[4] == line[1][4] then
			Mod:PrintDebug(string.format("Changing marine techtree line: (%f, %f, %f, %f) to (%f, %f, %f, %f)", line[1][1], line[1][2], line[1][3], line[1][4], line[2][1], line[2][2], line[2][3], line[2][4]), "all")
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

			if (line[1] == 0 and line[2] == 0) or (line[3] == 0 and line[4] == 0) then
				line = GetLinePositionForTechMap(kMarineTechMapOrig, value[2], value[3])
			end			
		end

		if  record[1] == line[1]
		and record[2] == line[2]
		and record[3] == line[3]
		and record[4] == line[4] then
			Mod:PrintDebug(string.format("Deleting marine techtree line: %f, %f, %f, %f", line[1], line[2], line[3], line[4]), "all")
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

		if (line[1] == 0 and line[2] == 0) or (line[3] == 0 and line[4] == 0) then
			line = GetLinePositionForTechMap(kMarineTechMapOrig, value[2], value[3])
		end
	end
	assert(line ~= {})
	Mod:PrintDebug(string.format("Adding marine techtree line: (%f, %f, %f, %f)", line[1], line[2], line[3], line[4]), "all")
	table.insert(kMarineLines, line)
end
