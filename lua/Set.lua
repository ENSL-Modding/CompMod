-- ======= Copyright (c) 2003-2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Set.lua
--
--    Created by:   Sebastian Schuck (sebastian@naturalselection2.com)
--
-- Simple set and queue datatype implementations.
-- Used to avoid having to check all elements of a table when inserting a new element.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

-- sets up metatables for datatypes
local function typedef(parent)
    local mt = {}
    mt.__index = mt

    return setmetatable( mt, {
        __call = function( self )
            return setmetatable( {}, self ):New()
        end,
        __index = parent
    } )
end

local Set = typedef()

function Set:New()
    self.list = {}
    self.map = {}

    return self
end

function Set:Insert(Value)
    if not self:Contains(Value) then
        table.insert(self.list, Value)
        self.map[Value] = #self.list

        return true
    end

    return false
end

function Set:InsertAll(Values)
    for i = 1, #Values do
        local value = Values[i]
        self:Insert(value)
    end
end

---@return boolean Returns if remove was successful
function Set:Remove(Value)
    local index = self:GetValueListIndex(Value)
    if index then
        self.map[Value] = nil

        -- we don't care about order so pop the top element off the set
        -- and check if it's the value we want to remove
        -- If it's not we just replace it with the to be removed value
        local top = table.remove(self.list)
        if index <= self:GetCount() then
            self.list[index] = top
            self.map[top] = index
        end

        return true
    end

    return false
end

function Set:ReplaceValue(OldValue, NewValue)
    if NewValue == nil then
        return self:Remove(OldValue)
    end

    local index = self:GetValueListIndex(OldValue)
    if index then
        self.map[OldValue] = nil
        self.list[index] = NewValue
        self.map[NewValue] = index

        return false
    end

    return false
end

function Set:Clear()
    table.clear(self.list)
    table.clear(self.map)
end

function Set:GetCount()
    return #self.list
end

function Set:GetList()
    return self.list
end

function Set:GetValueListIndex(Value)
    return self.map[Value]
end

---@return boolean Returns if Value is in set
function Set:Contains(Value)
    return self:GetValueListIndex(Value) ~= nil
end

function Set:GetValueAtIndex(Index)
    return self.list[Index]
end

do
    local function Iterate( state )
        state.index = state.index + 1
        return state.list[ state.index ]
    end

    -- Note: Not safe to be used to remove elements from the set, use IterateBackwards instead!
    function Set:Iterate()
        return Iterate, { list = self.list, index = 0 }
    end
end

do
    local function IterateBackwards( state )
        state.index = state.index - 1
        return state.list[ state.index ]
    end

    function Set:IterateBackwards()
        return IterateBackwards, { list = self.list, index = #self.list }
    end
end

_G.unique_set = Set -- set is allready declared in Ultility.lua. Not overriding it for backward compatibility

-- Basically a set that cares about element order. Do only use this when really neccesairy as remove is expensive (O(n))
local UniqueList = typedef(Set)

function UniqueList:Remove(Value)
    local index = self:GetValueListIndex(Value)
    if index then
        self.map[Value] = nil

        table.remove(self.list, index)
        for i = index, self:GetCount() do
            Value = self:GetValueAtIndex(i)
            self.map[Value] = i
        end

        return true
    end

    return false
end
_G.unique_list = UniqueList

-- Queue implementation with increasing front and rear indexes
local Queue = typedef()

function Queue:New()
    self.size = 0
    self.list = {}
    self.front = 1
    self.rear = 1

    return self
end

function Queue:GetCount()
    return self.size
end

function Queue:Enqueue(Value)
    if self.size == 0 then
        self.list[self.front] = Value
    else
        self.rear = self.rear + 1
        self.list[self.rear] = Value
    end

    self.size = self.size + 1
end

function Queue:Dequeue()
    if self.size == 0 then
        return nil
    end

    local Value = self.list[self.front]
    self.list[self.front] = nil

    self.front = self.front + 1
    self.size = self.size - 1

    -- resize indexes
    if self.size == 0 then
        self.front = 1
        self.rear = 1
    end

    return Value
end

function Queue:SetFront(Value)
    self.front = self.front - 1
    self.list[self.front] = Value

    self.size = self.size + 1
end

function Queue:GetFront()
    return self.list[self.front]
end

do
    local function Iterate( state )
        local i  = state.i + 1
        state.i = i
        return state.list[i]
    end

    function Queue:Iterate()
        return Iterate, { list = self.list, i = self.front - 1 }
    end

end

function Queue:Clear()
    self.size = 0
    self.front = 1
    self.rear = 1
    table.clear(self.list)
end

_G.queue = Queue

-- A queue with only unique elements
local UniqueQueue = typedef(Queue)
function UniqueQueue:New()
    Queue.New(self)

    self.map = {}

    return self
end

function UniqueQueue:Enqueue(Value)
    if self.map[Value] then return false end

    Queue.Enqueue(self, Value)
    self.map[Value] = self.rear

    return true
end

function UniqueQueue:SetFront(Value)
    if self.map[Value] then return false end

    Queue.SetFront(self, Value)
    self.map[Value] = self.front

    return true
end

function UniqueQueue:Dequeue()
    local Value = Queue.Dequeue(self)

    if Value then
        self.map[Value] = nil
    end

    return Value
end

function UniqueQueue:Contains(Value)
    return self.map[Value] ~= nil
end

function UniqueQueue:Clear()
    Queue.Clear(self)

    table.clear(self.map)
end
_G.unique_queue = UniqueQueue