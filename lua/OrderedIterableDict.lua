-- ======= Copyright (c) 2018, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/OrderedIterableDict.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Like the OrderedSet, OrderedIterableDict is used to access values of a dictionary without having to
--    use non JIT-able functions.  OrderedIterableDict, stores key->value mappings, unlike OrderedSet
--    where the keys ARE the values.  Unlike regular IterableDict, OrderedIterableDict preserves the partial
--    ordering of elements.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

--[==[
    
    Cheat sheet:
    
    OrderedIterableDict()
        Constructor.  Returns a new, empty, iterable dictionary.
    
    OrderedIterableDict:Clear()
        Clears all elements from the dictionary.
    
    OrderedIterableDict:GetKeyAtIndex(index)
        Returns the key at the given index, or nil if it is not found.
    
    OrderedIterableDict:GetIndexOfKey(key)
        Returns the index of the element with the given key, or nil if the element is not found.
    
    OrderedIterableDict:GetSize()
        Returns the number of elements in the dictionary.  The # operator nshould be used instead.
    
    OrderedIterableDict:GetValueAtIndex(index)
        Returns the value at the given index, or nil if it is not found.
    
    OrderedIterableDict:Next(element)
        Returns the element that comes after this element in the iteration.  If element is nil, the first element is
        returned.  If the element is the last element, nil is returned.
    
    OrderedIterableDict:ReplaceKey(oldKey, newKey)
        Replaces one key with another, without changing the position of its value.  The old key must exist in the set,
        and the new key must not. The keys must be different from each other.
    
    OrderedIterableDict:ReplaceKeyValuePair(oldKey, newKey, newValue)
        Replaces one key with another, while at the same time replacing the value the old key previously held with the
        newValue, in the same place as the old value.  Old key must exist and be different than the new key, which must
        not exist in the set.
    
    Elements can be added/set/removed from the dictionary at will (eg using [] or . operators).
    Setting an element to nil removes it.  The pairs() function has been overridden for this type too, so you
    can use it in a JIT-safe manner.
    
--]==]

Script.Load("lua/OrderedSet.lua")

OrderedIterableDict = {}

function OrderedIterableDict:GetIndexOfKey(key)
    local result = self.__keySet:GetIndex(key)
    return result
end

function OrderedIterableDict:Clear()
    table.clear(self.__keyToValue)
    self.__keySet:Clear()
end

function OrderedIterableDict:Next(key)
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

function OrderedIterableDict:GetKeyAtIndex(index)
    return self.__keySet[index]
end

function OrderedIterableDict:GetValueAtIndex(index)
    local key = self.__keySet[index]
    if key == nil then return nil end
    return self.__keyToValue[key]
end

function OrderedIterableDict:__pairs()
    return self.Next, self
end

-- Allow # operator to be used.
function OrderedIterableDict:__len()
    return #self.__keySet
end

function OrderedIterableDict:__index(key)
    if self.__keyToValue[key] ~= nil then
        return self.__keyToValue[key]
    else
        local result = rawget(OrderedIterableDict, key)
        return result
    end
end

function OrderedIterableDict:ReplaceKey(oldKey, newKey)
    assert(oldKey ~= nil) -- oldKey must not be nil
    assert(newKey ~= nil) -- newKey must not be nil
    assert(oldKey ~= newKey) -- the keys must be different
    assert(self.__keyToValue[oldKey] ~= nil) -- oldKey must exist in the set
    assert(self.__keyToValue[newKey] == nil) -- newKey must not already exist in the set
    
    self.__keyToValue[newKey] = self.__keyToValue[oldKey]
    self.__keyToValue[oldKey] = nil
    self.__keySet:ReplaceElement(oldKey, newKey)
end

function OrderedIterableDict:ReplaceKeyValuePair(oldKey, newKey, newValue)
    assert(oldKey ~= nil) -- oldKey must not be nil
    assert(newKey ~= nil) -- newKey must not be nil
    assert(oldKey ~= newKey) -- the keys must be different
    assert(self.__keyToValue[oldKey] ~= nil) -- oldKey must exist in the set
    assert(self.__keyToValue[newKey] == nil) -- newKey must not already exist in the set
    assert(newValue ~= nil) -- newValue must not be nil!
    
    self:ReplaceKey(oldKey, newKey)
    self[newKey] = newValue
end

function OrderedIterableDict:__newindex(key, value)
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

setmetatable(OrderedIterableDict,
{
    __call = function()
        local id = {}
        id.__keySet = OrderedSet()
        id.__keyToValue = {}
        setmetatable(id, OrderedIterableDict)
        return id
    end,
})

-- TESTS
do
    local dbgDict = OrderedIterableDict()

    assert(#dbgDict == 0)
    assert(dbgDict:GetKeyAtIndex(1) == nil)
    assert(dbgDict:GetValueAtIndex(1) == nil)

    dbgDict['a'] = 1

    assert(dbgDict:GetKeyAtIndex(1) == 'a')
    assert(dbgDict:GetValueAtIndex(1) == 1)
    assert(#dbgDict == 1)
    assert(dbgDict['a'] == 1)
    assert(dbgDict:GetKeyAtIndex(2) == nil)
    assert(dbgDict:GetValueAtIndex(2) == nil)

    dbgDict['b'] = 2

    assert(dbgDict:GetKeyAtIndex(1) == 'a')
    assert(dbgDict:GetValueAtIndex(1) == 1)
    assert(dbgDict['a'] == 1)
    assert(dbgDict:GetKeyAtIndex(2) == 'b')
    assert(dbgDict:GetValueAtIndex(2) == 2)
    assert(#dbgDict == 2)
    assert(dbgDict['b'] == 2)
    assert(dbgDict:GetKeyAtIndex(3) == nil)
    assert(dbgDict:GetValueAtIndex(3) == nil)

    dbgDict:ReplaceKey('a', 'c')

    assert(dbgDict:GetKeyAtIndex(1) == 'c')
    assert(dbgDict:GetValueAtIndex(1) == 1)
    assert(dbgDict['c'] == 1)
    assert(dbgDict:GetKeyAtIndex(2) == 'b')
    assert(dbgDict:GetValueAtIndex(2) == 2)
    assert(dbgDict['b'] == 2)
    assert(dbgDict['a'] == nil)
    assert(dbgDict:GetKeyAtIndex(3) == nil)
    assert(dbgDict:GetValueAtIndex(3) == nil)
end





