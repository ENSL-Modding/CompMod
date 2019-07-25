-- ======= Copyright (c) 2017, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/UnsortedSet.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Utility to manipulate tables that are unsorted sets, mainly as a way of avoiding calls to
--    pairs().  Ordinarily in lua, you could store say... entity id's in a table, and iterate over
--    the table with pairs(), but this is very slow with LuaJIT.  The "unsorted set" allows you to
--    iterate over an unsorted set of data with a normal for loop, or with ipairs, while retaining
--    the ability to access elements randomly, without the need for searching, in constant time.
--    This is done by using both the array and dictionary parts of the table at the same time.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

-- Creates two separate tables: one for the array part, one for the dictionary part.  We separate
-- them because sometimes we want to use numbers in the dictionary part (like entity ids), and this
-- could cause problems if we happen to use entity id's 1, 2, 3, 4,... etc.
function US_Create()
    
    return
    {
        a={}, -- array part.  Stores the elements.
        d={}, -- dictionary part.  Keys are elements, values are array indices.
    }
    
end

-- Adds the given element to the unsorted set.  Returns true if the element was added, or false
-- if the element was already present.  Always adds to the end of the array-part, so it is safe
-- to use during iteration, as long as you keep track of the end-index properly.
function US_Add(set, element)
    
    assert(set)
    assert(set.a)
    assert(set.d)
    assert(element)
    
    if not set.d[element] then
        set.d[element] = #set.a+1
        set.a[#set.a+1] = element
        return true
    end
    
    return false
    
end

-- Removes the given element from the unsorted set.  Returns true if the element was removed, or
-- false if the element was not present in the set to begin with.
-- When an element is removed from a set, the last element in the array is moved in to fill the
-- hole, so indices will get scrambled over time, therefore DO NOT use while iterating over the 
-- set.  Defer element removal to after the iteration is complete.
function US_Remove(set, element)
    
    assert(set)
    assert(set.a)
    assert(set.d)
    assert(element)
    
    if not set.d[element] then
        return false
    end
    
    local index = set.d[element]
    local lastIndex = #set.a
    set.a[index] = set.a[lastIndex]
    set.a[lastIndex] = nil
    set.d[element] = nil
    if index ~= lastIndex then
        set.d[set.a[index]] = index
    end
    
    return true
    
end

-- Returns the number of elements stored by the unsorted set.
function US_GetSize(set)
    
    assert(set)
    assert(set.a)
    assert(set.d)
    
    return #set.a
    
end

function US_GetElementExists(set, element)
    
    return set.d[element] ~= nil
    
end

-- Returns the element at the given index in the unsorted set.
function US_GetElement(set, index)
    
    return set.a[index]
    
end

-- Returns the index of the given element in the unsorted set.
function US_GetIndex(set, element)
    
    return set.d[element]
    
end

-- Returns the array part of the set.
function US_GetArray(set)
    
    return set.a
    
end

-- Returns the dict part of the set.
function US_GetDict(set)
    
    return set.d
    
end

