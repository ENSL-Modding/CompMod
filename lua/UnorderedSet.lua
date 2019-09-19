-- ======= Copyright (c) 2017, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/UnorderedSet.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Data structure that allows a set of things to be iterated over in a JIT-friendly way.
--    In other words, instead of using a regular table of key-true pairs, and iterate over it using
--    the non-JIT-friendly pairs() method, you can use this structure instead.
--@class UnorderedSet
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

--[==[
    
    Cheat sheet:
    
    UnorderedSet()                          Constructor, returns a new, empty, UnorderedSet.
    
    UnorderedSet:Add(element)               Ensures the specified element is part of the set.
                                            Returns true if it was added, false if it was already
                                            present in the set.
                                            
    UnorderedSet:Clear()                    Removes all items from the set.
                                            
    UnorderedSet:GetIndex(element)          Returns the index of the element, if it can be found,
                                            or nil if not.
                                            
    UnorderedSet:GetSize()                  Returns the size of the set.  Note that you can also
                                            use the # operator for a cleaner syntax.  This method
                                            is provided for backwards compatibility, as the #
                                            operator was not always accessible in earlier versions,
                                            and thus GetSize() had to be used instead.
                                            
    UnorderedSet:RemoveElement(element)     Ensures the given element is not part of the set.
                                            Returns true if the element was found and removed,
                                            false if it was not part of the set.
                                            
    UnorderedSet:RemoveIndex(index)         Removes whatever element is found at the given index,
                                            if any.  Returns true if an element was present and
                                            removed from the index, false if the index was out of
                                            range.
                                            
    UnorderedSet:ReplaceElement(old, new)   Performs an in-place replacement of the old element
                                            with the new element. Useful if you need elements to
                                            stay in a particular order (despite the fact that this
                                            is a class named UNSORTED Set. ;) )
                                            
    UnorderedSet:Contains(element)          Returns true if the element is found in the set.
    
    The [] operator returns an element from the array part of the set.
    
--]==]

UnorderedSet = {}

function UnorderedSet:Clear()
    table.clear(self.__dict)
    local length = #self
    for i=1, length do
        self[i] = nil
    end
    return true
end

function UnorderedSet:Add(element)
    if not self.__dict[element] then
        self.__dict[element] = #self+1
        self[#self+1] = element
        return true
    end
    return false
end

function UnorderedSet:RemoveElement(element)
    if not self.__dict[element] then
        return false
    end
    
    local index = self.__dict[element]
    local lastIndex = #self
    self[index] = self[lastIndex]
    self[lastIndex] = nil
    self.__dict[element] = nil
    if index ~= lastIndex then
        self.__dict[self[index]] = index
    end
    return true
end

function UnorderedSet:RemoveIndex(index)
    local element = self[index]
    if not element then
        return false
    end
    local result = self:RemoveElement(element)
    return result
end

function UnorderedSet:GetIndex(element)
    return self.__dict[element]
end

function UnorderedSet:Contains(element)
    return self.__dict[element] ~= nil
end

function UnorderedSet:ReplaceElement(old, new)
    local index = self.__dict[old]
    if not index then return false end
    self.__dict[old] = nil
    self.__dict[new] = index
    self[index] = new
    return true
end

function UnorderedSet:GetSize()
    return #self
end

function UnorderedSet:__index(key)
    local result = rawget(UnorderedSet, key)
    return result
end

function UnorderedSet:__call()
    
    PROFILE("UnorderedSet:__call")
    
    local us = {}
    us.__dict = {}
    setmetatable(us, UnorderedSet)
    return us
end

setmetatable(UnorderedSet, UnorderedSet)

-- TESTS

if not gSkipUnorderedSetUnitTests then
    local set = UnorderedSet()
    
    assert(#set == 0)
    
    assert(set:Add("hello") == true)
    assert(#set == 1)
    assert(set[1] == "hello")
    assert(set:GetIndex("hello") == 1)
    assert(set[2] == nil)
    
    assert(set:Add("world") == true)
    assert(#set == 2)
    assert(set[1] == "hello")
    assert(set:GetIndex("hello") == 1)
    assert(set[2] == "world")
    assert(set:GetIndex("world") == 2)
    assert(set[3] == nil)
    
    assert(set:Add("cruel") == true)
    assert(#set == 3)
    assert(set[1] == "hello")
    assert(set:GetIndex("hello") == 1)
    assert(set[2] == "world")
    assert(set:GetIndex("world") == 2)
    assert(set[3] == "cruel")
    assert(set:GetIndex("cruel") == 3)
    assert(set[4] == nil)
    
    assert(set:RemoveElement("world") == true)
    assert(set:RemoveElement("elephant") == false)
    assert(#set == 2)
    assert(set[1] == "hello")
    assert(set:GetIndex("hello") == 1)
    assert(set[2] == "cruel")
    assert(set:GetIndex("cruel") == 2)
    assert(set[3] == nil)
    
    assert(set:ReplaceElement("hello", "goodbye"))
    assert(#set == 2)
    assert(set[1] == "goodbye")
    assert(set:GetIndex("goodbye") == 1)
    assert(set[2] == "cruel")
    assert(set:GetIndex("cruel") == 2)
    assert(set[3] == nil)
    
    assert(set:Add("world") == true)
    assert(#set == 3)
    assert(set[1] == "goodbye")
    assert(set:GetIndex("goodbye") == 1)
    assert(set[2] == "cruel")
    assert(set:GetIndex("cruel") == 2)
    assert(set[3] == "world")
    assert(set:GetIndex("world") == 3)
    assert(set[4] == nil)
    
    assert(set:Clear() == true)
    assert(#set == 0)
    assert(set[1] == nil)
    assert(set[2] == nil)
    assert(set[3] == nil)
    assert(set[4] == nil)
    assert(set:GetIndex("goodbye") == nil)
    assert(set:GetIndex("cruel") == nil)
    assert(set:GetIndex("world") == nil)
    
end

