local techToChange = GetAlienTechMapChanges()
local techToAdd = GetAlienTechMapAdditions()
local techToRemove = GetAlienTechMapDeletions()

local linesToChange = GetAlienTechMapLineChanges()
local linesToAdd = GetAlienTechMapLineAdditions()
local linesToRemove = GetAlienTechMapLineDeletions()

-- techtree tech

-- changes
for techIndex, record in ipairs(kAlienTechMap) do
    local techId = record[1]

    if techToChange[techId] then
    	ModPrintDebug("Changing alien techtree entry: " .. (EnumToString(kTechId, techId) or techId), "all")
    	kAlienTechMap[techIndex] = techToChange[techId]
    end
end

-- deletions
for techIndex, record in ipairs(kAlienTechMap) do
    local techId = record[1]

    if techToRemove[techId] then
    	ModPrintDebug("Deleting alien techtree entry: " .. (EnumToString(kTechId, techId) or techId), "all")
		kAlienTechMap[techIndex] = {nil}
    end
end

-- additions
for _, value in pairs(techToAdd) do
	ModPrintDebug("Adding alien techtree entry: " .. (EnumToString(kTechId, value[1]) or value[1]), "all")
	table.insert(kAlienTechMap, value)
end

-- lines

-- changes
for index, record in ipairs(kAlienLines) do
	for _, line in ipairs(linesToChange) do
		if  record[1] == line[1][1] 
		and record[2] == line[1][2] 
		and record[3] == line[1][3] 
		and record[4] == line[1][4] then
			ModPrintDebug(string.format("Changing alien techtree line: (%f, %f, %f, %f) to (%f, %f, %f, %f)", line[1][1], line[1][2], line[1][3], line[1][4], line[2][1], line[2][2], line[2][3], line[2][4]), "all")
			kAlienLines[index] = line[2]
		end
	end
end

-- deletions
for index, record in ipairs(kAlienLines) do
	for _, line in ipairs(linesToRemove) do
		if  record[1] == line[1] 
		and record[2] == line[2] 
		and record[3] == line[3] 
		and record[4] == line[4] then
			ModPrintDebug(string.format("Deleting alien techtree line: %f, %f, %f, %f", line[1], line[2], line[3], line[4]), "all")
			table.remove(kAlienLines, index)
		end
	end
end

-- additions
for _, value in ipairs(linesToAdd) do
	ModPrintDebug(string.format("Adding alien techtree line: (%f, %f, %f, %f)", value[1], value[2], value[3], value[4]), "all")
	table.insert(kAlienLines, value)
end