-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Table.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
--                  Max McGuire (max@unknownworlds.com)
--
-- Table related utility functions.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/TableSort.lua") --jitable version of table.sort
Script.Load("lua/Set.lua")

local type = type
local insert = table.insert
local sort = table.sort
local remove = table.remove
local random = math.random
--
-- Return all arguments as a table
--
function table.pack(...)
    return { ... }
end

--Shuffles an array randomly
function table.shuffle(t)
    local n = #t
    for i = n, 1, -1 do
        local r = random(n)
        t[i], t[r] = t[r], t[i] --swap
    end

    return t
end

--Returns the max index of given array t
local function icount(t)
    return t and #t or 0
end
table.icount = icount

function table.duplicate(t)
  local t2 = {}
  for k,v in pairs(t) do
    t2[k] = v
  end
  return t2
end

function table.iduplicate(t)
    local t2 = {}
    for k,v in ipairs(t) do
        t2[k] = v
    end
    return t2
end

local tclear = require("table.clear")

--
-- Removes all elements from a table.
--
local function clear(t)

    if(t ~= nil) then
        tclear(t)
    end

end
table.clear = clear

--
-- Only works for array type tables.
--
local function copy(srcTable, destTable, noClear)

    if not noClear then
        clear(destTable)
    end
    
    for _, element in ipairs(srcTable) do
        insert(destTable, Copy(element))
    end

end
table.copy = copy

local function tableEqualsTable(i, j)
    if #i == #j then
        for k = 1, #i do
            return i[k] == j[k] or type(i[i]) == "table" and type(j[i]) == "table" and tableEqualsTable(i, j)
        end
    end
    return false
end

local function elementEqualsElement(i, j)

    return i == j or type(i) == "table" and type(j) == "table" and tableEqualsTable(i, j)

end

--
-- Searches a table for the specified value. If the value is in the table
-- the index of the (first) matching element is returned. If its not found
-- the function returns nil.
--
local function find(findTable, value)

    assert(type(findTable) == "table")
    
    for i, element in ipairs(findTable) do
        if elementEqualsElement(element, value) then
            return i
        end
    end

    return nil

end
table.find = find

--
-- Returns true if the passed in table contains the passed in value. This
-- function can be used on any table (dictionary-like tables as well as those
-- created with table.insert()).
--
function table.contains(inTable, value)

    assert(type(inTable) == "table")
    
    for key, element in pairs(inTable) do
        if element == value then
            return true, key
        end
    end
    return false, nil
    
end

--
-- Returns random element in the given array.
--
function table.random(t)
    local max = icount(t)
    if max > 0 then
        return t[random(1, max)]
    else
        return nil    
    end
end

--
-- Choose random weighted index according. Pass in table of arrays where the first element in each
-- array is a float that indicates how often that index is chosen.
--
-- {{.9, "chooseOften"}, {.1, "chooseLessOften"}, {.001, "chooseAlmostNever}}
--
-- This returns 1 most often, 2 less often and 3 even less. It adds up all the numbers that are the
-- first elements in the table to calculate the chance. Returns -1 on error.
--
function table.chooseWeightedIndex(t)

    local weightedIndex = -1
    
    -- Calculate total weight
    local totalWeight = 0
    for _, element in ipairs(t) do
        totalWeight = totalWeight + element[1]
    end
    
    -- Choose random weighted index of input table data
    local randomFloat = random()
    local randomNumber = randomFloat * totalWeight
    local total = 0
    
    for i, element in ipairs(t) do
    
        local currentWeight = element[1]
        
        if((total + currentWeight) >= randomNumber) then
            weightedIndex = i
            break
        else
            total = total + currentWeight
        end
        
    end

    return weightedIndex
    
end

-- Helper function for table.chooseWeightedIndex
function chooseWeightedEntry(t)

    if(t ~= nil) then
        local entry = t[table.chooseWeightedIndex(t)][2]
        return entry
    end
    
    Print("chooseWeightedEntry(nil) - Table is nil.")
    return nil
    
end

--
-- Removes the specified value from the table (note only the first occurance is
-- removed). Returns true if element was found and removed, false otherwise.
-- This will not work for tables created as dictionaries.
--
local function removevalue(t, v)

    local i = find(t, v)

    if i ~= nil then

        remove(t, i)
        return true

    end

    return false

end
table.removevalue = removevalue

-- Checks if two arrays have all the same elements
function table.getIsEquivalent(origT1, origT2)

    if (origT1 == nil and origT2 == nil) then
    
        return true
        
    elseif (origT1 == nil) or (origT2 == nil) then
    
        return false
        
    elseif (icount(origT1) == icount(origT2)) then
    
        local t1 = {}
        local t2 = {}
        
        copy(origT1, t1)
        copy(origT2, t2)
    
        for _, elem in ipairs(t1) do
        
            if not find(t2, elem) then
            
                return false
                
            else
            
                removevalue(t2, elem)
                
            end
        
        end
        
        return true
        
    end
    
    return false
    
end

function entryInTable(t, entry)
    
    if(t ~= nil) then
    
        for _, subTable in ipairs(t) do
        
            if (subTable[2] == entry) then
            
                return true
                
            end
            
        end
        
    end
    
    return false
    
end

local tnew = require("table.new")

--
-- Creates a new table with an array part of the specified size
--
function table.array(size)
    return (tnew(size , 0))
end

--
-- Way to elegantly remove elements from a table according to a function.
-- Eg: table.removeConditional(t, function (elem) return elem == "test5" end)
--
function table.removeConditional(t, conditionalFunction)

    if(t ~= nil) then
    
        local numElements = icount(t)
    
        local i = 1
        while i <= numElements do
        
            local element = t[i]
            
            if element then
            
                if conditionalFunction(element) then
                
                    remove(t, i)
                    
                    numElements = numElements - 1
                    
                    i = i - 1
                    
                end
                
            end
            
            i = i + 1
            
        end
        
    end

end

function table.insertunique(t, v, p)

    assert(type(t) == "table")
    assert(v ~= nil)
    
    if(find(t, v) == nil) then

        if p then
            insert(t, p, v)
        else
            insert(t, v)
        end

        return true
        
    end
    
    return false
    
end

--
-- Adds the contents of one table to another. Duplicate elements added.
--
function table.addtable(srcTable, destTable)
    for i = 1,#srcTable do
        destTable[#destTable+1] = srcTable[i]
    end
end

--
-- Adds the contents of one array to another. Duplicate elements are not inserted.
--
function table.adduniquetable(srcTable, destTable)

    for _, element in ipairs(srcTable) do
    
        table.insertunique(destTable, element)

    end
    
end

--
-- Call specified functor with every element in the array.
--
function table.foreachfunctor(t, functor)

    if(icount(t) > 0) then
    
        for _, element in ipairs(t) do
        
            functor(element)
            
        end
        
    end
    
end

function table.count(t, logError)
    if(t ~= nil) then
        return (table.maxn(t, true))
    elseif logError then
        Print("table.count() - Nil table passed in, returning 0.")
    end
    return 0
end

--
-- Counts up the number of keys. This is different from table.count
-- because dictionaries do not have numbered keys and so won't be
-- counted correctly. It is also slower.
--
function table.countkeys(t)

    local count = 0
    for _ in pairs(t) do
        count = count + 1
    end
    return count

end

--
-- Make a copy of a dictionary
--
-- Oh, how I hate the fucked up Lua array/dictionary mess.
--
 function table.copyDict(dict)
    local result = {}
    for k,v in pairs(dict) do
        local vCopy = v
        if type(v) == "table" then
            vCopy = table.copyDict(v)
        end
        result[k] = v
    end
    return result
    
 end

--
-- Returns true if a dictionary is empty
--
function table.emptyDict(t)
    for _ in pairs(t) do
        return false
    end
    return true
end

local function removeTable(srcTable, destTable)

    for _, elem in ipairs(srcTable, destTable) do

        local index = find(destTable, elem)

        if index ~= nil then
            remove(destTable, index)
        end

    end

end

table.removeTable = removeTable

-- Returns a table full of elements that aren't found in both tables
function table.diff(t1, t2)

    local newT1 = {}
    table.copy(t1, newT1)
    
    local newT2 = {}
    table.copy(t2, newT2)
    
    removeTable(t1, newT2)
    removeTable(t2, newT1)

    local output = {}
    table.copy(newT1, output)
    table.copy(newT2, output, true)
    
    return output
    
end

--
-- Print the table to a string and returns it. Eg, "{ "element1", "element2", {1, 2} }".
--
function table.ToString(t)

    local buffer = {}
        
    insert(buffer, "{")
    
    if(type(t) == "table") then

        local numElements = table.maxn(t)
        local currentElement = 1
        
        for key, value in pairs(t) do
        
            if(type(value) == "table") then
            
                insert(buffer, string.format("%s = %s", tostring(key), table.tostring(value)))
            
            elseif(type(value) == "number") then

                --[[ For printing out lists of entity ids
                
                local className = "unknown"
                local entity = Shared.GetEntity(value)
                if(entity ~= nil) then
                    className = entity:GetMapName()
                end
                
                insert(buffer, string.format("%s (%s)", tostring(value), tostring(className)))
                --]]
                
                insert(buffer, string.format("%s = %s", tostring(key), tostring(value)))
                
            elseif(type(value) == "userdata") then
            
                if value.GetClassName then
                    insert(buffer, string.format("%s = class \"%s\"", tostring(key), value:GetClassName()))
                end
                
            else
            
                insert(buffer, string.format("%s = \"%s\"", tostring(key), tostring(value)))
                
            end
            
            -- Insert commas between elements
            if(currentElement ~= numElements) then
            
                insert(buffer, ",")
                
            end
            
            currentElement = currentElement + 1
        
        end
        
    else
    
        insert(buffer, "<data is \"" .. type(t) .. "\", not \"table\">")
        
    end
    
    insert(buffer, "}")
    
    return table.concat(buffer)

end

-- Returns the numeric median of the given array of numbers
function table.median( t )
    local temp = {}

    --deep copy all numbers
    for _, v in ipairs(t) do
        if type(v) == 'number' then
            insert( temp, v )
        end
    end

    if #temp == 0 then
        return 0
    end

    sort( temp )

    if #temp % 2 == 0 then
        return ( temp[#temp/2] + temp[(#temp/2)+1] ) / 2
    else
        return temp[math.ceil(#temp/2)]
    end
end

-- Get the mean value of the given array of numbers
function table.mean( t )
    local sum = 0
    local count = 0

    for _,v in ipairs(t) do
        if type(v) == 'number' then
            sum = sum + v
            count = count + 1
        end
    end

    return (sum / count)
end

-- Get the mode of a table. Returns a table of values.
function table.mode( t )
    local counts={}

    for _, v in pairs( t ) do
        if counts[v] == nil then
            counts[v] = 1
        else
            counts[v] = counts[v] + 1
        end
    end

    local biggestCount = 0

    for _, v  in pairs( counts ) do
        if v > biggestCount then
            biggestCount = v
        end
    end

    local temp={}

    for k,v in pairs( counts ) do
        if v == biggestCount then
            insert( temp, k )
        end
    end

    return temp
end

-- Get the standard deviation of the given array of numbers
function table.standardDeviation( t )
    if #t < 2 then return 0 end

    local m
    local vm
    local sum = 0
    local count = 0
    local result

    m = table.mean( t )

    for _,v in ipairs(t) do
        if type(v) == 'number' then
            vm = v - m
            sum = sum + (vm * vm)
            count = count + 1
        end
    end

    result = math.sqrt(sum / (count-1))

    return result
end

-- Returns if the given value exist inside given array inTable
function table.icontains(inTable, value)

    assert(type(inTable) == "table")

    for i = 1, #inTable do
        local v = inTable[i]
        if v == value then
            return true, i
        end
    end

    return false, nil

end

--Find unneeded/often usage of NYI functions in hotpaths
local NYIdebug = false
if NYIdebug then
    local minCalls = 100 --to only detect hotpaths

    local pairs = pairs
    local TableCount = table.count
    local TableICount = icount
    local TableContains = table.contains
    local TableIContains = table.icontains
    local TableMaxN = table.maxn
    local Results = {}

    local function PrintCalling(prefix)
        local info = debug.getinfo(3, "Sl")
        local found = string.format("%s:%s", info.short_src ,info.currentline)

        Results[found] = Results[found] or 0
        Results[found] =  Results[found] + 1
        if Results[found] == minCalls then
            Shared.Message(string.format("NYI Warning (%s) at %s", prefix, found))
        end
    end

    function table.contains(inTable, value)
        local a,b = TableContains(inTable, value)
        local c,d = TableIContains(inTable, value)

        if a == c and b == d then
            PrintCalling("table.contains")
        end

        return a,b
    end

    function table.count(t, logError)

        local a = TableCount(t, logError)
        local b = TableICount(t)

        if a == b then
            PrintCalling("table.count")
        end

        return a
    end

    function table.maxn(t, noLog)
        local a = TableMaxN(t)
        local b = table.icount(t)

        if a == b and not noLog then
            PrintCalling("table.maxn")
        end

        return a
    end

    -- pairs is used alot so we should try to get rid of it in hotpaths when possible to do without a major refactor
    function _G.pairs(table)
        PrintCalling("pairs")
        return pairs(table)
    end
end