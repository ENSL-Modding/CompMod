-- ======= Copyright (c) 2017, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/IterableDict.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Like the UnorderedSet, IterableDict is used to access values of a dictionary without having to
--    use non JIT-able functions.  IterableDict, stores key->value mappings, unlike UnorderedSet
--    where the keys ARE the values.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

--[==[
    
    Cheat sheet:
    
    IterableDict()              Constructor.  Returns a new, empty, iterable dictionary.
                                
    IterableDict:Clear()        Clears all elements from the dictionary.
                                
    IterableDict:GetSize()      Returns the number of elements in the dictionary.  The # operator
                                should be used instead.
                                
    IterableDict:Next(element)  Returns the element that comes after this element in the iteration.
                                If element is nil, the first element is returned.  If the element
                                is the last element, nil is returned.
                                
    Elements can be added/set/removed from the dictionary at will (eg using [] or . operators).
    Setting an element to nil removes it.  The pairs() function has been overridden for this type too, so you
    can use it in a JIT-safe manner.
    
--]==]

Script.Load("lua/UnorderedSet.lua")

IterableDict = {}

function IterableDict:Clear()
    table.clear(self.__keyToValue)
    self.__keySet:Clear()
end

function IterableDict:Next(key)
    local index
    if key == nil then
        index = 0
    else
        index = self.__keySet:GetIndex(key)
    end
    
    if index == nil then
        return nil
    end
    
    local key = self.__keySet[index+1]
    if key == nil then
        return nil
    end
    
    return key, self.__keyToValue[key]
end

function IterableDict:__pairs()
    return self.Next, self
end

-- Allow # operator to be used.
function IterableDict:__len()
    return #self.__keySet
end
IterableDict.GetSize = IterableDict.__len

function IterableDict:__index(key)
    if self.__keyToValue[key] ~= nil then
        return self.__keyToValue[key]
    else
        local result = rawget(IterableDict, key)
        return result
    end
end

function IterableDict:__newindex(key, value)
    if value == nil then
        -- remove value
        self.__keySet:RemoveElement(key)
        self.__keyToValue[key] = nil
    else
        -- add value
        self.__keySet:Add(key)
        self.__keyToValue[key] = value
    end
end

setmetatable(IterableDict,
{
    __call = function()
        local id = {}
        id.__keySet = UnorderedSet()
        id.__keyToValue = {}
        setmetatable(id, IterableDict)
        return id
    end,
})

-- Debug
--[[
local dbgDict = IterableDict()

-- debug_dict_print
Event.Hook("Console_debug_dict_print",
function()
    for key, value in pairs(dbgDict) do
        Log("[%s] = %s", key, value)
    end
end)

-- debug_dict_set(key, value)
Event.Hook("Console_debug_dict_set",
function(key, value)
    dbgDict[key] = value
end)

-- debug_dict_get(key)
Event.Hook("Console_debug_dict_get",
function(key)
    Log("[%s] = %s", key, dbgDict[key])
end)

Event.Hook("Console_debug_dict_func",
function()
    local dict1 = IterableDict()
    local dict2 = IterableDict()
    
    Log("dict1.Next = %s", dict1.Next)
    Log("dict2.Next = %s", dict2.Next)
end)
--]]


