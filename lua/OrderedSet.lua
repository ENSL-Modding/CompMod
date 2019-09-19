-- ======= Copyright (c) 2018, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/OrderedSet.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Same as UnorderedSet, but preserves the relative ordering of elements when they're added/removed.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

--    Cheat sheet:
--    
--    OrderedSet()                            Constructor.  Returns a new, empty, OrderedSet.
--                                            
--    OrderedSet:Add(element)                 Adds an element to the end of the set, if it isn't already present.
--                                            Returns true if it was added, false if it was already present.
--                                            
--    OrderedSet:Clear()                      Removes all elements from the set.
--                                            
--    OrderedSet:Clone()                      Returns a copy of the set.
--                                            
--    OrderedSet:GetIndex(element)            Returns the index of the element, or nil if it cannot be found.
--                                            
--    OrderedSet:Insert(element, index)       Inserts the element at the selected index, shifting all elements
--                                            at or after the index down by 1.  If the element is already present
--                                            in the set, the function does nothing, and returns false.
--                                            
--    OrderedSet:RemoveElement(element)       Removes the element from the set, if it exists.  Returns true if
--                                            the element was found (and removed), false if it was not found.
--                                            
--    OrderedSet:RemoveIndex(element)         Removes the element at the specified index.  Returns true if the
--                                            index was valid, false otherwise.
--                                            
--    OrderedSet:ReplaceElement(old, new)     Replaces an old element with a new one in the same position.
--                                            This can only happen if the old element is present in the set,
--                                            and the new element is not. Returns true if successful, false
--                                            otherwise.
--                                            
--    OrderedSet:Contains(element)            Returns true if the element is found in the set.
--                                            
--    The [] operator can be used to retrieve an element at the given index.  To retrieve the index of an element,
--        use GetIndex() instead.
--    The # operator can be used to get the size of the set.

OrderedSet = {}

function OrderedSet:Clear()
    table.clear(self.__dict)
    local length = #self
    for i=1, length do
        self[i] = nil
    end
    return true
end

function OrderedSet:Insert(element, index)
    
    assert(type(index) == "number")
    assert(element)
    
    -- Ensure element doesn't already exist in the set.
    if self.__dict[element] then
        return false
    end
    
    -- Ensure index is valid
    if index <= 0 then
        return false
    end
    
    -- If index is greater than the last index, just append the object.
    if index > #self then
        self:Add(element)
        return true
    end
    
    -- Make a hole.
    for i=#self, index, -1 do
        self[i+1] = self[i]
        self.__dict[self[i]] = i+1
    end
    
    -- Insert the object.
    self[index] = element
    self.__dict[element] = index
    
    return true
    
end

function OrderedSet:Add(element)
    
    -- Ensure element doesn't already exist in the set.
    if self.__dict[element] then
        return false
    end
    
    self.__dict[element] = #self+1
    self[#self+1] = element
    
    return true
    
end

function OrderedSet:Clone()
    local clone = OrderedSet()
    for i=1, #self do
        clone:Add(self[i])
    end
    return clone
end

function OrderedSet:RemoveElement(element)
    if not self.__dict[element] then
        return false
    end
    
    -- Remove a single element without the fast-remove, to keep things ordered.
    local i = self.__dict[element]
    self.__dict[element] = nil
    local n = #self
    while i < n do
        self[i] = self[i+1]
        self.__dict[self[i]] = i
        i = i + 1
    end
    self[n] = nil
    
    return true
end

function OrderedSet:RemoveIndex(index)
    local element = self[index]
    if not element then
        return false
    end
    local result = self:RemoveElement(element)
    return result
end

function OrderedSet:GetIndex(element)
    return self.__dict[element]
end

function OrderedSet:Contains(element)
    return self.__dict[element] ~= nil
end

function OrderedSet:ReplaceElement(old, new)
    
    assert(old)
    assert(new)
    
    if not self.__dict[old] or self.__dict[new] then
        return false -- old element wasn't present, or new element already was.
    end
    
    local index = self.__dict[old]
    self.__dict[old] = nil
    self.__dict[new] = index
    self[index] = new
    
    return true
end

function OrderedSet:__index(key)
    local result = rawget(OrderedSet, key)
    return result
end

function OrderedSet:__call()
    local oSet = {}
    oSet.__dict = {}
    setmetatable(oSet, OrderedSet)
    return oSet
end

setmetatable(OrderedSet, OrderedSet)

-- TESTS
do
    local set = OrderedSet()
    
    assert(#set == 0)
    assert(set[1] == nil)
    
    assert(set:Add(1))
    
    assert(#set == 1)
    assert(set[1] == 1)
    assert(set[2] == nil)
    
    assert(set:Add(2))
    
    assert(#set == 2)
    assert(set[1] == 1)
    assert(set[2] == 2)
    assert(set[3] == nil)
    
    assert(set:Add(3))
    
    assert(#set == 3)
    assert(set[1] == 1)
    assert(set[2] == 2)
    assert(set[3] == 3)
    assert(set[4] == nil)
    
    assert(set:RemoveElement(1))
    
    assert(#set == 2)
    assert(set[1] == 2)
    assert(set[2] == 3)
    assert(set[3] == nil)
    
    assert(set:RemoveElement(2))
    
    assert(#set == 1)
    assert(set[1] == 3)
    assert(set[2] == nil)
    
    assert(set:RemoveElement(3))
    
    assert(#set == 0)
    assert(set[1] == nil)
end

-- insert test
do
    local set = OrderedSet()
    
    assert(set:Insert("Hello", 0) == false)
    assert(set:Insert("World", -1) == false)
    
    assert(set:Insert("World", 1) == true)
    assert(#set == 1)
    assert(set[1] == "World")
    assert(set:Insert("World", 1) == false)
    
    assert(set:Insert("Hello", 1) == true)
    assert(#set == 2)
    assert(set[1] == "Hello")
    assert(set[2] == "World")
    assert(set:Insert("World", 1) == false)
    assert(set:Insert("Hello", 1) == false)
    
    assert(set:Insert("Cruel", 2) == true)
    assert(#set == 3)
    assert(set[1] == "Hello")
    assert(set[2] == "Cruel")
    assert(set[3] == "World")
    assert(set:Insert("World", 1) == false)
    assert(set:Insert("Hello", 1) == false)
    assert(set:Insert("Cruel", 1) == false)
    
    assert(set:Insert("!", 8) == true)
    assert(#set == 4)
    assert(set[1] == "Hello")
    assert(set[2] == "Cruel")
    assert(set[3] == "World")
    assert(set[4] == "!")
    assert(set:Insert("World", 1) == false)
    assert(set:Insert("Hello", 1) == false)
    assert(set:Insert("Cruel", 1) == false)
    assert(set:Insert("!", 1) == false)
    
end


