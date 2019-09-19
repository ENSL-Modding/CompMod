-- ======= Copyright (c) 2017, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/SortedSet.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Data structure that allows a sorted set of things to be iterated over in a JIT-friendly way.
--    In other words, instead of using a regular table of key-true pairs, and iterate over it using
--    the non-JIT-friendly pairs() method, you can use this structure instead.
--    This is similar to the UnsortedSet structure, but this set also takes a sorting function, and
--    ensures that the contents remain sorted as they are added or removed.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

--[==[
    
    Cheat sheet:
    
    SortedSet(sortFunc)                     Constructor.  Returns a new, empty, SortedSet.  The parameter
                                            sortFunc is the sorting function used to order the elements.
                                            This function should look like the following:
                                            
                                            function sortFunc(a, b)
                                                return a < b
                                            end
                                            
    SortedSet:Add(element)                  Adds an element to the set, if it isn't already present.  Returns
                                            true if it was added, false if it was already present.
                                            
    SortedSet:Clear()                       Removes all elements from the set.
                                            
    SortedSet:ElementExists(element)        Returns true if the given element exists in the set.
                                            
    SortedSet:GetAsOrderedSet()             Returns an OrderedSet copy of the SortedSet.
                                            
    SortedSet:GetAsArrayTable()             Returns the set of values as an array-style table.
                                            
    SortedSet:GetIndex(element)             Returns the index of the element, or nil if it cannot be found.
                                            
    SortedSet:GetIsValid()                  Returns true if the sorted set (to the best of its knowledge) is
                                            not in need of a full re-sort.
                                            
    SortedSet:Invalidate()                  Marks the set as invalid, meaning it is not necessarily sorted any
                                            longer.  It will automatically re-sort it self as soon as it is
                                            required (any operation that requires up-to-date indices).  Other
                                            operations, such as simply testing if an element is a member of the
                                            set, do not require sorting.  This method should be called manually
                                            whenever some external circumstance causes the sorted data to
                                            change in a non-monotonic fashion (eg a sub-tree of the gui graph
                                            is transplanted to another area of the tree).  It will un-mark
                                            itself as invalid when the automatic resort happens, or if ReSort()
                                            is called manually.
                                            
    SortedSet:RemoveElement(element)        Removes the element from the set, if it exists.  Returns true if
                                            the element was found (and removed), false if it was not found.
                                            
    SortedSet:RemoveIndex(element)          Removes the element at the specified index.  Returns true if the
                                            index was valid, false otherwise.
                                            
    SortedSet:ReplaceElement(old, new)      Replaces an old element with a new one.  This can only happen if
                                            the old element is present in the set, and the new element is not.
                                            Returns true if successful, false otherwise.
                                            
    SortedSet:ReSort()                      Re-sorts the entire set.  This should only ever be necessary when
                                            the state of the elements change with respect to the sorted property.
                                            (For example, if sorting by layer, and the layer arrangement of the
                                            objects change).
                                            
    SortedSet:SetSortingFunction(func)      Changes the sorting function used to sort elements.  Invalidates the
                                            sort of the table.
                                            
    The [] operator can be used to retrieve an element at the given index.  To retrieve the index of an element,
        use GetIndex() instead.
    The # operator can be used to get the size of the set.
    
--]==]

Script.Load("lua/OrderedSet.lua")

SortedSet = {}

function SortedSet:GetAsArrayTable()
    
    local tbl = {}
    for i=1, #self do
        table.insert(tbl, self[i])
    end
    return tbl
    
end

function SortedSet:SetSortingFunction(func)
    
    if self.__sortFunc == func then
        return
    end
    
    self.__sortFunc = func
    self.__invalid = true
    
end

function SortedSet:GetIsValid()
    return not self.__invalid
end

function SortedSet:ElementExists(element)
    return self.__dict[element] ~= nil
end

function SortedSet:GetAsOrderedSet()
    
    local oset = OrderedSet()
    for i=1, #self do
        oset:Add(self[i])
    end
    return oset
    
end

function SortedSet:Clear()
    table.clear(self.__dict)
    table.clear(self.__array)
    self.__invalid = false
end

function SortedSet:Add(element)
    
    -- Ensure element doesn't already exist in the set.
    if self.__dict[element] then
        return false
    end
    
    -- If this set has been marked as invalid, we need to re-sort anyways, so just add the element to the end.
    if self.__invalid then
        self.__dict[element] = #self.__array + 1
        self.__array[#self.__array+1] = element
        return
    end
    
    -- Find the right place to insert this element.
    
    -- If there are no elements, that's simple.
    if #self.__array == 0 then
        self.__dict[element] = 1
        self.__array[1] = element
        return true
    end
    
    -- Binary search to find the proper insertion index.
    local L = 1
    local R = #self.__array + 1
    local M = math.floor((L+R)/2)
    while R > L do
        if self.__sortFunc(self.__array[M], element) then
            L = M + 1
        else
            R = M
        end
        M = math.floor((L+R)/2)
    end
    
    -- Shift elements down to make room at the index found.
    local numElements = #self.__array
    for i=numElements, M, -1 do
        self.__array[i+1] = self.__array[i]
        self.__dict[self.__array[i]] = i+1
    end
    
    -- Add the new element.
    self.__array[M] = element
    self.__dict[element] = M
    
    return true
    
end

function SortedSet:RemoveElement(element)
    if not self.__dict[element] then
        return false
    end
    
    -- If this set has been marked as invalid, just remove the element fast, as it needs to be re-sorted anyways.
    if self.__invalid then
        local index = self.__dict[element]
        local lastIndex = #self.__array
        self.__array[index] = self.__array[lastIndex]
        self.__array[lastIndex] = nil
        self.__dict[element] = nil
        if index ~= lastIndex then
            self.__dict[self.__array[index]] = index
        end
        return
    end
    
    -- Remove a single element without the fast-remove, to keep things sorted.
    local i = self.__dict[element]
    self.__dict[element] = nil
    local n = #self.__array
    while i < n do
        self.__array[i] = self.__array[i+1]
        self.__dict[self.__array[i]] = i
        i = i + 1
    end
    self.__array[n] = nil
    
    return true
end

function SortedSet:GetContainsElement(element)
    return self.__dict[element] ~= nil
end

function SortedSet:RemoveIndex(index)
    local element = self.__array[index]
    if not element then
        return false
    end
    local result = self:RemoveElement(element)
    return result
end

function SortedSet:GetIndex(element)
    if self.__invalid then
        self:ReSort()
    end
    
    return self.__dict[element]
end

function SortedSet:ReplaceElement(old, new)
    assert(old)
    assert(new)
    
    if not self.__dict[old] or self.__dict[new] then
        return false -- old element wasn't present, or new element already was.
    end
    
    self:RemoveElement(old)
    self:Add(new)
    return true
end

function SortedSet:ReSort()
    
    table.clear(self.__dict)
    table.sort(self.__array, self.__sortFunc)
    for i=1, #self.__array do
        self.__dict[self.__array[i]] = i
    end
    self.__invalid = false
    
end

function SortedSet:Invalidate()
    self.__invalid = true
end

-- Allow # operator to be used to get size of set.
function SortedSet:__len()
    return #self.__array
end

function SortedSet:__index(key)
    if type(key) == "number" then
        if self.__invalid and key > 0 and key <= #self.__array then
            self:ReSort()
        end
        return self.__array[key]
    else
        local result = rawget(SortedSet, key)
        return result
    end
end

function SortedSet:__call(sortFunc)
    local ss = {}
    ss.__array = {}
    ss.__dict = {}
    ss.__sortFunc = sortFunc
    ss.__invalid = false
    setmetatable(ss, SortedSet)
    return ss
end

setmetatable(SortedSet, SortedSet)

-- TESTS
do
    local function TestSortFunc(a, b)
        return (a < b)
    end

    function SortedSetTest1()
        
        local ss = SortedSet(TestSortFunc)
        
        assert(#ss == 0)
        assert(ss[1] == nil)
        
        assert(ss:Add(5))
        
        assert(#ss == 1)
        assert(ss[1] == 5)
        assert(ss[2] == nil)
        
        assert(ss:Add(8))
        
        assert(#ss == 2)
        assert(ss[1] == 5)
        assert(ss[2] == 8)
        assert(ss[3] == nil)
        
        assert(ss:Add(2))
        
        assert(#ss == 3)
        assert(ss[1] == 2)
        assert(ss[2] == 5)
        assert(ss[3] == 8)
        assert(ss[4] == nil)
        
        assert(ss:RemoveElement(5))
        
        assert(#ss == 2)
        assert(ss[1] == 2)
        assert(ss[2] == 8)
        assert(ss[3] == nil)
        
        assert(ss:RemoveElement(2))
        
        assert(#ss == 1)
        assert(ss[1] == 8)
        assert(ss[2] == nil)
        
        assert(ss:RemoveElement(8))
        
        assert(#ss == 0)
        assert(ss[1] == nil)
        
    end

    local function TestSortFunc2(a, b)
        return a.value < b.value
    end

    function SortedSetTest2()
        
        local ss = SortedSet(TestSortFunc2)
        
        assert(ss:Add({value = 4, name = "one"}))
        assert(ss:Add({value = 3, name = "two"}))
        assert(ss:Add({value = 2, name = "three"}))
        assert(ss:Add({value = 1, name = "four"}))
        
        assert(ss[1].name == "four")
        assert(ss[2].name == "three")
        assert(ss[3].name == "two")
        assert(ss[4].name == "one")
        
    end

    function SortedSetTest3()
        
        local e1 = {value = 5}
        local e2 = {value = 3}
        local e3 = {value = 1}
        
        local ss = SortedSet(TestSortFunc2)
        
        assert(ss:Add(e1))
        assert(ss:Add(e2))
        
        assert(ss:GetIndex(e1) == 2)
        assert(ss:GetIndex(e2) == 1)
        
        assert(ss:ReplaceElement(e1, e3))
        
        assert(ss:GetIndex(e3) == 1)
        assert(ss:GetIndex(e2) == 2)
        
    end
    
    SortedSetTest1()
    SortedSetTest2()
    SortedSetTest3()
    
end



