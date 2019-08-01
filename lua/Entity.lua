-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Entity.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

function EntityToString(entity)

    if (entity == nil) then
        return "nil"
    elseif (type(entity) == "number") then
        string.format("EntityToString(): Parameter is a number (%s) instead of entity ", tostring(entity))
    elseif (entity:isa("Entity")) then
        return entity:GetClassName()
    end
    
    return string.format("EntityToString(): Parameter isn't an entity but %s instead", tostring(entity))
    
end

if Predict then
    function Entity:AddTimedCallback()
    end
else
    function Entity:AddTimedCallback(callback, interval, early)
        -- default to early 
        early = early ~= false
        self:AddTimedCallbackActual(callback, interval, early)
    end
end

--
-- For debuggin; find out who is calling us and from where (can be difficult
-- due to Mixins. So wrap the code you want traced with Shared.showStackTrace
-- true/false to figure out where its being called from.
--
--local Shared_GetEntitiesWithTagInRange = Shared.GetEntitiesWithTagInRange
--local function wrap1(...)
--    if Shared.showStackTrace then
--        Log("GEWTIR:\n%s", debug.traceback())
--    end
--    return Shared_GetEntitiesWithTagInRange(...)
--end
--Shared.GetEntitiesWithTagInRange = wrap1
--
--local Shared_GetEntitiesWithClassname = Shared.GetEntitiesWithClassname
--local function wrap2(...)
--    if Shared.showStackTrace then
--        Log("GEWCName:\n%s", debug.traceback())
--    end
--    return Shared_GetEntitiesWithClassname(...)
--end
--Shared.GetEntitiesWithClassname = wrap2
--

--
--For use in Lua for statements to iterate over EntityList objects.
--
local function ientitylist_it(entityList, currentIndex)

    local numEntities = entityList:GetSize()

    while currentIndex < numEntities do
        -- Check if the entity was deleted after we created the list
        local currentEnt = entityList:GetEntityAtIndex(currentIndex)
        currentIndex = currentIndex + 1
        if currentEnt ~= nil then
            return currentIndex, currentEnt
        end
    end

    return nil

end

function ientitylist(entityList)

    return ientitylist_it, entityList, 0
    
end

function GetEntitiesWithFilter(entityList, filterFunction)

    PROFILE("Entity:GetEntitiesWithFilter")
    
    local numEntities = entityList:GetSize()
    local result = {}

    local i = 0
    while i < numEntities do
        local entity = entityList:GetEntityAtIndex(i)

        if entity and filterFunction(entity) then

            result[#result+1] = entity

        end

        i = i + 1

    end
    
    return result
    
end

function FilterEntitiesArray(ents, filter)
    local result = {}
    for i = 1, #ents do
        local ent = ents[i]
        if ent and filter(ent) then
            result[#result + 1] = ent
        end
    end
    return result
end

function EntityListToTable(entityList)

    PROFILE("EntityListToTable")
	
	local result = {}	
	
	for _, ent in ientitylist( entityList ) do
		result[#result+1] = ent		
	end
	
    return result
    
end

function GetEntitiesForTeam(className, teamNumber)

    local teamFilterFunction = CLambda [=[args ent; HasMixin(ent, "Team") and ent:GetTeamNumber() == self[1]]=] {teamNumber}
    return GetEntitiesWithFilter(Shared.GetEntitiesWithClassname(className), teamFilterFunction)

end

--Note: this only works with ScriptActor type (Entity does not have innate locationId property)
function GetEntitiesForTeamByLocation( className, teamNumber, locationId )

    local filterFunction = CLambda [=[
		HasMixin(..., "Team")
		and (...):isa("ScriptActor")
		and (...):GetTeamNumber() == self[1]
		and (...).locationId == self[2]
	]=] {teamNumber, locationId}

    return GetEntitiesWithFilter( Shared.GetEntitiesWithClassname(className), filterFunction )

end

function GetEntities(className)

    return EntityListToTable(Shared.GetEntitiesWithClassname(className))

end

function GetEntitiesForTeamWithinRange(className, teamNumber, origin, range)

    local TeamFilterFunction = CLambda [=[
		HasMixin(..., "Team")
		and (...):GetTeamNumber() == self[1]
	]=] {teamNumber}

    return FilterEntitiesArray(Shared.GetEntitiesWithTagInRange("class:" .. className, origin, range), TeamFilterFunction)

end

function GetEntitiesWithinRange(className, origin, range)

    return Shared.GetEntitiesWithTagInRange("class:" .. className, origin, range)

end

function GetEntitiesForTeamWithinXZRange(className, teamNumber, origin, range)

    local inRangeXZFilterFunction = Closure [=[
		self teamNumber origin range
		args entity
		local inRange = (entity:GetOrigin() - origin):GetLengthSquaredXZ() <= (range * range)
		return inRange and HasMixin(entity, "Team") and entity:GetTeamNumber() == teamNumber
	]=] {teamNumber, origin, range}

    return GetEntitiesWithFilter(Shared.GetEntitiesWithClassname(className), inRangeXZFilterFunction)

end


function GetEntitiesWithinXYRange(className, origin, range)

    PROFILE("Entity:GetEntitiesWithinXYRange")

    local inRangeXZFilterFunction = Closure [=[
        self origin range
		args entity
		local inRange = (entity:GetOrigin() - origin):GetLengthSquaredXZ() <= (range * range)
		return inRange
    ]=] {origin, range}

    return GetEntitiesWithFilter(Shared.GetEntitiesWithClassname(className), inRangeXZFilterFunction)

end

function GetEntitiesForTeamWithinRangeAreVisible(className, teamNumber, origin, range, visibleState)

    local teamAndVisibleStateFilterFunction = CLambda [==[
		self teamNumber visibleState
		args entity
		HasMixin(entity, "Team") and entity:GetTeamNumber() == teamNumber and entity:GetIsVisible() == visibleState
	]==] {teamNumber, visibleState}

    return FilterEntitiesArray(Shared.GetEntitiesWithTagInRange("class:" .. className, origin, range), teamAndVisibleStateFilterFunction)

end

function GetEntitiesWithinRangeAreVisible(className, origin, range, visibleState)

    local visibleStateFilterFunction = CLambda [=[
		self visibleState
		args entity
		entity:GetIsVisible() == visibleState
	]=] {visibleState}

    return FilterEntitiesArray(Shared.GetEntitiesWithTagInRange("class:" .. className, origin, range), visibleStateFilterFunction)

end

function GetEntitiesWithinXZRangeAreVisible(className, origin, range, visibleState)

    local inRangeXZFilterFunction = Closure [=[
		self visibleState origin range
		args entity
		local inRange = (entity:GetOrigin() - origin):GetLengthSquaredXZ() <= (range * range)
		return inRange and entity:GetIsVisible() == visibleState
	]=] {visibleState, origin, range}

    return GetEntitiesWithFilter(Shared.GetEntitiesWithClassname(className), inRangeXZFilterFunction)

end

function GetEntitiesWithinRangeInView(className, range, player)

    local withinViewFilter = Closure [=[
        self player
        args entity
        return GetCanSeeEntity(player, entity)
    ]=] {player}
    
    return Shared.GetEntitiesWithTagInRange("class:" .. className, player:GetOrigin(), range, withinViewFilter)
    
end

function GetEntitiesMatchAnyTypesForTeam(typeList, teamNumber)

    local teamFilter = CLambda [=[
		self teamNumber
		args entity
		HasMixin(entity, "Team") and entity:GetTeamNumber() == teamNumber
	]=] {teamNumber}

    local allMatchingEntsList = { }

    for i = 1, #typeList do

        local type = typeList[i]

        local matchingEntsForType = GetEntitiesWithFilter(Shared.GetEntitiesWithClassname(type), teamFilter)
        table.adduniquetable(matchingEntsForType, allMatchingEntsList)

    end

    return allMatchingEntsList

end

function GetEntitiesMatchAnyTypes(typeList)
    
    local allMatchingEntsList = { }
    local entIdMap = {}

    for i = 1, #typeList do
        local type = typeList[i]
        for _, entity in ientitylist(Shared.GetEntitiesWithClassname(type)) do
            local entId = entity:GetId()
            if not entIdMap[entId] then
                table.insert(allMatchingEntsList, entity)
                entIdMap[entId] = true
            end
        end
    end
    
    return allMatchingEntsList

end

function GetEntitiesWithMixin(mixinType)

    return EntityListToTable(Shared.GetEntitiesWithTag(mixinType))

end

function GetEntitiesWithMixinForTeam(mixinType, teamNumber)

    local func = CLambda [[
		self teamNumber
		args entity
		HasMixin(entity, "Team") and entity:GetTeamNumber() == teamNumber
	]] {teamNumber}

    return GetEntitiesWithFilter(Shared.GetEntitiesWithTag(mixinType), func)

end

function GetEntitiesWithMixinWithinRange(mixinType, origin, range)
    
    return Shared.GetEntitiesWithTagInRange(mixinType, origin, range)
    
end

function GetEntitiesWithMixinWithinXZRange(mixinType, origin, range)

    local filterXZRangeFunction = Closure [=[
        self origin range
		args entity
		local inRange = (entity:GetOrigin() - origin):GetLengthSquaredXZ() <= (range * range)
		return inRange
    ]=] {origin, range}

    return GetEntitiesWithFilter(Shared.GetEntitiesWithTag(mixinType), filterXZRangeFunction)

end

function GetEntitiesWithMixinForTeamWithinXZRange(mixinType, teamNumber, origin, range)

    local teamFilterXZRangeFunction = Closure [=[
        self origin range teamNumber
		args entity
		local inRange = (entity:GetOrigin() - origin):GetLengthSquaredXZ() <= (range * range)
		return inRange and HasMixin(entity, "Team") and entity:GetTeamNumber() == teamNumber
    ]=] {origin, range, teamNumber}

    return GetEntitiesWithFilter(Shared.GetEntitiesWithTag(mixinType), teamFilterXZRangeFunction)
end


function GetEntitiesWithMixinWithinRangeAreVisible(mixinType, origin, range, visibleState)

    local visibleStateFilterFunction = CLambda [=[
		self visibleState
		args entity
		entity:GetIsVisible() == visibleState
	]=] {visibleState}

    return FilterEntitiesArray(Shared.GetEntitiesWithTagInRange(mixinType, origin, range), visibleStateFilterFunction)
    
end

function GetEntitiesWithMixinForTeamWithinRange(mixinType, teamNumber, origin, range)
    local teamFilterFunction = CLambda [[
		self teamNumber
		args entity
		HasMixin(entity, "Team") and entity:GetTeamNumber() == teamNumber
	]] {teamNumber}
    
    return FilterEntitiesArray(Shared.GetEntitiesWithTagInRange(mixinType, origin, range), teamFilterFunction)
end

if jit.os == "Linux" then
    function Shared.SortEntitiesByDistance(sortOrigin, entities)
        local function compareDistance(a, b)
            local distance1 = (a:GetOrigin() - sortOrigin):GetLengthSquared()
            local distance2 = (b:GetOrigin() - sortOrigin):GetLengthSquared()

            return distance1 < distance2
        end
        table.sort(entities, compareDistance)
    end
end

-- Fades damage linearly from center point to radius (0 at far end of radius)
function RadiusDamage(entities, centerOrigin, radius, fullDamage, doer, ignoreLOS, fallOffFunc, useXZDistance)

    assert(HasMixin(doer, "Damage"))

    local radiusSquared = radius * radius

    -- Do damage to every target in range
    for _, target in ipairs(entities) do
    
        -- Find most representative point to hit
        local targetOrigin = GetTargetOrigin(target)

        local distanceVector = targetOrigin - centerOrigin

        -- Trace line to each target to make sure it's not blocked by a wall
        local wallBetween = false
        local distanceFromTarget
        if useXZDistance then
            distanceFromTarget = distanceVector:GetLengthSquaredXZ()
        else
            distanceFromTarget = distanceVector:GetLengthSquared()
        end

        if not ignoreLOS then
            wallBetween = GetWallBetween(centerOrigin, targetOrigin, target)
        end
        
        if (ignoreLOS or not wallBetween) and (distanceFromTarget <= radiusSquared) then
        
            -- Damage falloff
            local distanceFraction = distanceFromTarget / radiusSquared
            if fallOffFunc then
                distanceFraction = fallOffFunc(distanceFraction)
            end
            distanceFraction = Clamp(distanceFraction, 0, 1)

            local damage = fullDamage * (1 - distanceFraction)

            local damageDirection = distanceVector
            damageDirection:Normalize()
            
            -- we can't hit world geometry, so don't pass any surface params and let DamageMixin decide
            doer:DoDamage(damage, target, centerOrigin, damageDirection, "none")

        end
        
    end
    
end

--
-- Get list of child entities for player. Pass optional class name
-- to get only entities of that type.
--
function GetChildEntities(player, isaClassName)

    local childEntities = { }
    
    for i = 0, player:GetNumChildren() - 1 do
        local currentChild = player:GetChildAtIndex(i)
        if isaClassName == nil or currentChild:isa(isaClassName) then
            table.insert(childEntities, currentChild)
        end
    end
    
    return childEntities
    
end

--
-- Iterates over the children of the passed in entity of the passed in type
-- and calls the function passed in. All children will be iterated if the
-- childType is nil.
--
function ForEachChildOfType(entity, childType, callback)

    for i = 0, entity:GetNumChildren() - 1 do
    
        local currentChild = entity:GetChildAtIndex(i)
        if childType == nil or currentChild:isa(childType) then
            callback(currentChild)
        end
        
    end

end

--
-- For use in Lua for statements to iterate over an Entities' children.
-- Optionally pass in a string class name to only iterate children of that class.
--
function ientitychildren(parentEntity, optionalClass)

    local function ientitychildren_it(parentEntity, currentIndex)

        if currentIndex >= parentEntity:GetNumChildren() then
            return nil
        end

        local currentEnt = parentEntity:GetChildAtIndex(currentIndex)
        currentIndex = currentIndex + 1
        if optionalClass and not currentEnt:isa(optionalClass) then
            return ientitychildren_it(parentEntity, currentIndex)
        end
        return currentIndex, currentEnt

    end
    
    return ientitychildren_it, parentEntity, 0
    
end

-- Return entity number or -1 if not found
function FindNearestEntityId(className, location)

    local entityId = -1
    local shortestDistance

    for _, current in ientitylist(Shared.GetEntitiesWithClassname(className)) do

        local distance = (current:GetOrigin() - location):GetLength()
        
        if(shortestDistance == nil or distance < shortestDistance) then
        
            entityId = current:GetId()
            shortestDistance = distance
            
        end
            
    end    
    
    return entityId
    
end

--
-- Given a list of entities (representing spawn points), returns a randomly chosen
-- one which is unobstructed for the player. If none of them are unobstructed, the
-- method returns nil.
--
function GetRandomClearSpawnPoint(player, spawnPoints)

    local numSpawnPoints = table.icount(spawnPoints)
    
    -- Start with random spawn point then move up from there
    local baseSpawnIndex = NetworkRandomInt(1, numSpawnPoints)

    for i = 1, numSpawnPoints do

        local spawnPointIndex = ((baseSpawnIndex + i) % numSpawnPoints) + 1
        local spawnPoint = spawnPoints[spawnPointIndex]

        -- Check to see if the spot is clear to spawn the player.
        local spawnOrigin = Vector(spawnPoint:GetOrigin())
        local spawnAngles = Angles(spawnPoint:GetAngles())
        spawnOrigin.y = spawnOrigin.y + .5
        
        spawnAngles.pitch = 0
        spawnAngles.roll  = 0
        
        player:SpaceClearForEntity(spawnOrigin)
        
        return spawnPoint
            
    end
    
    Print("GetRandomClearSpawnPoint - No unobstructed spawn point to spawn %s (tried %d)", player:GetName(), numSpawnPoints)
    
    return nil

end

-- Look for unoccupied spawn point nearest given position
function GetClearSpawnPointNearest(player, spawnPoints, position)

    -- Build sorted list of spawns, closest to farthest
    local sortedSpawnPoints = {}
    table.copy(spawnPoints, sortedSpawnPoints)
    
    -- The comparison function must return a boolean value specifying whether the first argument should
    -- be before the second argument in the sequence (he default behavior is <).
    local function sort(spawn1, spawn2)
        return (spawn1:GetOrigin() - position):GetLength() < (spawn2:GetOrigin() - position):GetLength()
    end    
    table.sort(sortedSpawnPoints, sort)

    -- Build list of spawns in
    for i = 1, #sortedSpawnPoints do

        -- Check to see if the spot is clear to spawn the player.
        local spawnPoint = sortedSpawnPoints[i]
        local spawnOrigin = Vector(spawnPoint:GetOrigin())

        if (player:SpaceClearForEntity(spawnOrigin)) then
        
            return spawnPoint
            
        end
        
    end
    
    Print("GetClearSpawnPointNearest - No unobstructed spawn point to spawn " , player:GetName())
    
    return nil

end

--
-- Not all Entities have eyes. Play it safe.
--
function GetEntityEyePos(entity)

    if entity.GetEyePos then
        return entity:GetEyePos()
    end
    return (HasMixin(entity, "Model") and entity:GetModelOrigin()) or entity:GetOrigin()
    
end


function GetDistanceSquaredToEntity(seeingEntity, target)
    local targetOrigin = HasMixin(target, "Target") and target:GetEngagementPoint() or target:GetOrigin()
    local toEntity = targetOrigin - GetEntityEyePos(seeingEntity)
    local dist = toEntity.x * toEntity.x + toEntity.y * toEntity.y + toEntity.z * toEntity.z
    return dist
end


--
-- Not all Entities have view angles. Play it safe.
--
function GetEntityViewAngles(entity)
    return (entity.GetViewAngles and entity:GetViewAngles()) or entity:GetAngles()
end

function GetEntityInfo(entity)

    local entInfo = entity:GetClassName() .. " | " .. entity:GetId() .. "\n"
    local entMT = getmetatable(entity)
    local _, properties = entMT.__towatch(entity)
    for key, val in pairs(properties) do
        entInfo = entInfo .. key .. " = " .. ToString(val) .. "\n"
    end
    return entInfo
    
end
