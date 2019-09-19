-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/GUI/GUIAnimationManager.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Singleton class that manages all the animations of the new GUI system.
--      -- Update animated values every frame.
--      -- Allow preset animations to be defined.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/BaseGUIManager.lua")
Script.Load("lua/IterableDict.lua")

---@class GUIAnimationManager : BaseGUIManager
class "GUIAnimationManager" (BaseGUIManager)

------------
-- LOCALS --
------------

local function CopyForAnimatedValue(value)
    
    if type(value) == "table" then
        return value
    end

    local result = Copy(value)
    return result
    
end

local function AddAnimationLayerToSet(self, animationSet, value, animationParams, optionalName)
    
    local animationLayer =
    {
        startTime = Shared.GetTime(),
        startValue = CopyForAnimatedValue(animationSet.baseValue),
        endValue = CopyForAnimatedValue(value),
        params = animationParams,
        name = optionalName,
    }
    table.insert(animationSet, animationLayer)
    
    if value ~= nil then
        animationSet.baseValue = CopyForAnimatedValue(value)
    end
    
end

local function GetAnimationSet(self, guiObject, propertyName)
    
    AssertIsaGUIObject(guiObject)
    assert(type(propertyName) == "string")
    
    local objectAnimations = self.animationSetByObject[guiObject]
    if not objectAnimations then
        return
    end
    
    return objectAnimations[propertyName]
    
end

-- Create a node for the linked list that is used to iterate over the list.  The iterator becomes
-- a node in the list so that we don't lose our place while iterating if elements are added to/
-- removed from the list.
local function CreateListIterator(self)
    
    if self.animationSetListEnd == nil then
        -- no list to iterate over.
        return nil
    end
    
    local listIterator = { listIterator = true }
    
    listIterator.next = self.animationSetListStart
    
    if self.animationSetListStart then
        self.animationSetListStart.prev = listIterator
    end
    
    self.animationSetListStart = listIterator
    
    return listIterator
    
end

-- Moves the list iterator forward by swapping it with the next node.  Returns true if there are more nodes to
-- explore, false if it has reached the end of the list.
local function ListIteratorJumpForward(self, listIterator)
    
    assert(type(listIterator) == "table")
    assert(listIterator.listIterator)
    
    if listIterator.next == nil then
        
        assert(listIterator == self.animationSetListEnd)
        
        if self.animationSetListEnd == listIterator then
            self.animationSetListEnd = listIterator.prev
        end
        
        if self.animationSetListStart == listIterator then
            self.animationSetListStart = nil
        end
        
        if listIterator.prev then
            listIterator.prev.next = nil
            listIterator.prev = nil
        end
        
    else
        
        local nextNode = listIterator.next
        
        -- Swap places with next item.
        if listIterator.prev then
            listIterator.prev.next = nextNode
        end
        
        if nextNode.next then
            nextNode.next.prev = listIterator
        end
        
        listIterator.next = nextNode.next
        nextNode.prev = listIterator.prev
        
        listIterator.prev = nextNode
        nextNode.next = listIterator
        
        if nextNode == self.animationSetListEnd then
            self.animationSetListEnd = listIterator
        end
        
        if listIterator == self.animationSetListStart then
            self.animationSetListStart = nextNode
        end
        
    end
    
end

-- Returns the next element in the list, or nil if the list iterator reached the end.
-- If the list iterator reached the end, it is automatically destroyed.
local function ListIteratorGetNextElement(self, listIterator)
    
    if listIterator == nil then
        return nil
    end
    
    assert(type(listIterator) == "table")
    assert(listIterator.listIterator)
    
    -- Keep jumping forward until the next node is not a list iterator.
    while listIterator.next ~= nil and listIterator.next.listIterator do
        ListIteratorJumpForward(self, listIterator)
    end
    
    -- Jump over the element we found.
    local foundElement = listIterator.next -- could be nil
    ListIteratorJumpForward(self, listIterator)
    return foundElement
    
end

local function DestroyAnimationSet(self, animationSet)
    
    assert(type(animationSet) == "table")
    assert(animationSet.listIterator == nil)
    
    if animationSet == self.animationSetListStart then
        self.animationSetListStart = animationSet.next
    end
    
    if animationSet == self.animationSetListEnd then
        self.animationSetListEnd = animationSet.prev
    end
    
    if animationSet.next then
        animationSet.next.prev = animationSet.prev
    end
    
    if animationSet.prev then
        animationSet.prev.next = animationSet.next
    end
    
    animationSet.next = nil
    animationSet.prev = nil
    
    local objectAnimations = self.animationSetByObject[animationSet.guiObject]
    objectAnimations[animationSet.propertyName] = nil
    objectAnimations[1] = objectAnimations[1] - 1
    assert(objectAnimations[1] >= 0)
    
    -- Cleanup the set if it is now empty (reference counting)
    if objectAnimations[1] == 0 then
        -- Set is empty.
        self.animationSetByObject[animationSet.guiObject] = nil
    end
    
end

local function DestroyAllAnimationSetsForObject(self, guiObject)
    
    local listIterator = CreateListIterator(self)
    local animationSet = ListIteratorGetNextElement(self, listIterator)
    while animationSet do
        
        if animationSet.guiObject == guiObject then
            DestroyAnimationSet(self, animationSet)
        end
        
        animationSet = ListIteratorGetNextElement(self, listIterator)
       
    end
    
end

-- Creates a new animation set, and adds it to the linked list and animation set set... set.
local function CreateAnimationSet(self, guiObject, propertyName)
    
    AssertIsaGUIObject(guiObject)
    assert(type(propertyName) == "string")
    
    local objectAnimations = self.animationSetByObject[guiObject]
    if not objectAnimations then
        objectAnimations = {[1]=0} -- store key count in array-part.
        self.animationSetByObject[guiObject] = objectAnimations
    end
    
    local animationSet = objectAnimations[propertyName]
    if not animationSet then
        animationSet = {}
        animationSet.baseValue = guiObject:Get(propertyName)
        
        objectAnimations[propertyName] = animationSet
        objectAnimations[1] = objectAnimations[1] + 1
        animationSet.propertyName = propertyName
        animationSet.guiObject = guiObject
        
        -- Add to end of linked list.
        -- If there is no start yet, this set becomes the start.
        if self.animationSetListStart == nil then
            self.animationSetListStart = animationSet
        end
        
        -- Add this set to the end, if there is one.
        if self.animationSetListEnd then
            self.animationSetListEnd.next = animationSet
            animationSet.prev = self.animationSetListEnd
        end
        
        self.animationSetListEnd = animationSet
        
    end
    
    return animationSet
    
end

local function AnimateObjectPropertyActual(self, guiObject, propertyName, value, animationParams, optionalName)
    
    local animationSet = GetAnimationSet(self, guiObject, propertyName)
    if not animationSet then
        animationSet = CreateAnimationSet(self, guiObject, propertyName)
    end
    
    AddAnimationLayerToSet(self, animationSet, value, animationParams, optionalName)
    
end


-------------------------
-- FROM BaseGUIManager --
-------------------------

function GUIAnimationManager:Initialize()
    
    -- Reference to the first node of a doubly-linked list that iterates over all animationSets.
    -- Use a linked list to drastically reduce the complexity of being able to add/remove elements
    -- during iteration.
    self.animationSetListStart = nil
    self.animationSetListEnd = nil
    
    -- Provide random access to the above list (iteration must still be performed by the linked
    -- list!).
    -- self.animationSetByObject = { guiObject --> { propertyName --> animationSet } }
    self.animationSetByObject = {}
    
    -- Keep track of calls to GUIObject:Set() from within the animation system.  When an animated
    -- property is "set", it's really just adjusting the base value in the animation layer, not the
    -- actual value.  Keep track of how deep we are.
    self.setFromAnimation = 0
    
end

function GUIAnimationManager:OnObjectDestroyed(guiObject)
    
    DestroyAllAnimationSetsForObject(self, guiObject)
    
end

function GUIAnimationManager:Update(deltaTime, now)
    
    self:UpdateAnimations()
    
end


--------------------
-- PUBLIC METHODS --
--------------------

-- Animates a specific property of the given gui object.
--  guiObject -- the GUIObject the property belongs to.
--  propertyName -- the name of the property to animate, OR the name of the GUIItem field of the
--      guiObject's rootItem to be animated.  For example, GUIObjects do not themselves have a
--      property named "Position", but GUIItem's do.  Therefore, passing "Position" as the property
--      name will animate guiObject's rootItem's "Position" field.
--  value -- the input parameter to whatever animation function you are using -- usually represents
--      the value we want to animate towards.  If nil, it means this animation will only affect the
--      property while it exists -- it will not have any effects once it is destroyed.  For
--      example, a pulsing opacity effect shouldn't affect the color of the object once it has been
--      removed, and it doesn't make sense to have a target value provided since it's not moving
--      to any value, it's just oscillating over the current value.
--  animationParams -- a table of parameters for the animation to use.  This can be purpose-built
--      for this single call, or you can pass in a pre-built table to enable the creation of
--      animation "presets".  The table is treated as immutable by the animation system, so uh...
--      don't change it...
--      A field named "func" must be provided.  This is the function the animation system calls
--      to perform the animation on the value provided.  It should look something like this
--          
--          function ExponentialAnimation(guiObject, time, params, currentValue, startValue, endValue, startTime)
--              -- some animation related code goes here...
--              return newValue, animFinished
--          end
--          
--          guiObject is the object that owns whatever property this is being applied to.
--          time is the elapsed time this animation has been playing (starts at 0).
--          params is the table passed into this function as animationParams.
--          currentValue is the current value of the property (it will be either the base value if
--              this is the first animation layer, or the result of all the prior animation layers.
--          startValue is the value of the property when this animation layer was created.
--          endValue is the target value of the property this animation layer was created for.
--          startTime is the absolute time when the animation was created (so you can add this to
--              time to get the current time).
--          newValue is the value returned for this animation.
--          animFinished is a boolean value telling the animation system whether or not the
--              animation can be destroyed because it is finished.
--  optionalName -- a name for the animation layer that can be used later to manually destroy the
--      animation.
function GUIAnimationManager:AnimateObjectProperty(guiObject, propertyName, value, animationParams, optionalName)
    
    -- Validate guiObject
    AssertIsaGUIObject(guiObject, 1)
    
    -- Validate propertyName
    if type(propertyName) ~= "string" then
        error(string.format("Expected a string for propertyName, got %s-type instead!", type(propertyName)), 2)
    end
    
    if optionalItemName ~= nil then
        if type(optionalItemName) ~= "string" then
            error(string.format("Expected a string for optionalItemName, got %s-type instead!", GetTypeName(optionalItemName)), 2)
        end
        
        if guiItem[optionalItemName] == nil then
            error(string.format("Unable to find item named '%s' inside of object '%s'", optionalItemName, guiObject:GetName()), 2)
        end
    end
    
    -- Validate params
    if type(animationParams) ~= "table" then
        error(string.format("Expected a table for animationParams, got %s-type instead!", GetTypeName(animationParams)), 2)
    end
    
    -- Ensure a "func" field exists in animationParams.
    if type(animationParams.func) ~= "function" then
        error(string.format("Expected a function for animationParams.func, got %s-type instead!", GetTypeName(animationParams.func)), 2)
    end
    
    -- Validate optionalName, if exists
    if optionalName ~= nil then
        if type(optionalName) ~= "string" then
            error(string.format("Expected a string or nil for optionalName, got %s-type instead.", GetTypeName(optionalName)), 2)
        end
    end
    
    -- If this property name is being traced, log this animation.
    if guiObject.debugLogProperties and guiObject.debugLogProperties[propertyName] then
        Log("Property '%s' of '%s' is being animated towards '%s'... trace:\n%s", propertyName, guiObject:GetName(), value, Debug_GetStackTraceForEvent(true))
    end
    
    -- Animations must be applied to the bottom-most reference of a property (eg the original owner).
    -- Find the original property if this is a composite property reference.
    
    -- Check if property exists, not counting composite refs.
    if guiObject:GetPropertyExists(propertyName, true) then
        
        -- Original property location found!
        AnimateObjectPropertyActual(self, guiObject, propertyName, value, animationParams, optionalName)
        
        
    -- Property was not found (but we weren't looking at the composite property refs.
    -- See if the property is found if we include composite refs.
    elseif guiObject:GetPropertyExists(propertyName, false) then
        
        -- Property is a composite ref.  Need to find the original property.  (This might
        -- actually be the original property, as it may refer to a fake GUIItem property).
        local owner = guiObject:GetCompositePropertyOwner(propertyName)
        local propertyNameInOwner = guiObject:GetCompositePropertyRealName(propertyName)
        
        if owner:isa("GUIItem") then
            
            -- Owner is a GUIItem, therefore we have found the original owner of the property.
            AnimateObjectPropertyActual(self, guiObject, propertyName, value, animationParams, optionalName)
            
        else
            
            -- Owner is a GUIObject that may or may not be the original owner of the property.
            -- Recurse to find the original owner.
            self:AnimateObjectProperty(owner, propertyNameInOwner, value, animationParams, optionalName)
            
        end
        
        
    -- Property was not found at all in this object.
    else
        error(string.format("Property named '%s' doesn't exist in guiObject!", propertyName), 2)
    end
    
end

-- Sets the base value for the animating property.  This should be called by property setters just
-- in case the property being set is currently being animated, so that the animations can be
-- correctly blended with the updated value.  Otherwise, setting a property value that is animated
-- only have an effect for a single frame, because it will be overwritten with the old value next
-- frame.  Returns true if successful, false if the property was not being animated.
function GUIAnimationManager:SetAnimatingPropertyBaseValue(guiObject, propertyName, value)
    
    if self.setFromAnimation > 0 then
        return false -- Call to Set() was from within the animation system.  Set it like normal.
    end
    
    local animationSet = GetAnimationSet(self, guiObject, propertyName)
    if not animationSet then
        return false
    end
    
    if GetAreValuesTheSame(animationSet.baseValue, value) then
        -- value was not changed, but value WAS animating, and thus should not be changed elsewhere.
        return true
    end
    
    animationSet.baseValue = CopyForAnimatedValue(value)
    
    return true
    
end

-- Returns true if the object's property is being animated with at least one animation layer name
-- matching the given name.
function GUIAnimationManager:GetPropertyHasAnimation(guiObject, propertyName, animationName)

    local animationSet = GetAnimationSet(self, guiObject, propertyName)
    if not animationSet then
        return false
    end
    
    for i=1, #animationSet do
        if animationSet[i].name == animationName or animationName == nil then
            return true
        end
    end
    
    return false

end

-- Returns the base value for the animating property, if it exists.
function GUIAnimationManager:GetAnimatingPropertyBaseValue(guiObject, propertyName)
    
    local animationSet = GetAnimationSet(self, guiObject, propertyName)
    if not animationSet then
        return nil
    end
    
    return animationSet.baseValue
    
end

function GUIAnimationManager:ClearAnimationsForProperty(guiObject, propertyName, optionalAnimationName)
    
    
    -- Validate guiObject
    AssertIsaGUIObject(guiObject, 1)
    
    -- Validate propertyName
    if type(propertyName) ~= "string" then
        error(string.format("Expected a string for propertyName, got %s-type instead!", type(propertyName)), 2)
    end
    if not guiObject:GetPropertyExists(propertyName) then
        error(string.format("Property named '%s' doesn't exist in guiObject!", propertyName), 2)
    end
    
    local objectAnimations = self.animationSetByObject[guiObject]
    if not objectAnimations then
        return -- nothing in the object is animating.
    end
    
    local animationSet = objectAnimations[propertyName]
    if not animationSet then
        return -- property was not being animated.
    end
    
    assert(#animationSet ~= 0) -- should not have existed if it was empty.
    
    for i=#animationSet, 1, -1 do
        local animationLayer = animationSet[i]
        if optionalAnimationName == nil or animationLayer.name == optionalAnimationName then
            table.remove(animationSet, i)
        end
    end
    
    if #animationSet == 0 then
        
        -- All animation layers were removed!  Set property to base value, and remove the animation set.
        local baseValue = animationSet.baseValue
        DestroyAnimationSet(self, animationSet)
        
        self.setFromAnimation = self.setFromAnimation + 1
        guiObject:Set(propertyName, baseValue)
        self.setFromAnimation = self.setFromAnimation - 1
        
    end
    
end

-- Returns true if the current call stack contains a property being set by the animation system.
-- This is useful to know if you want to replace an object's SetProperty with a method that will
-- animate it smoothly instead.  In this case, calling SetProperty will cause a new animation to
-- be created, but we wouldn't want to create a new animation if the animation system itself is
-- calling the SetProperty method.
function GUIAnimationManager:GetIsSettingPropertyForAnimation()
    return self.setFromAnimation > 0
end

-------------
-- PRIVATE --
-------------

local cleanupAnimationSets = {}
local cleanupAnimatedObjects = {}
function GUIAnimationManager:UpdateAnimations()
    
    local now = Shared.GetTime()
    
    local listIterator = CreateListIterator(self)
    local animationSet = ListIteratorGetNextElement(self, listIterator)
    while animationSet do
        
        -- Pause all events for this object.  When an animation finishes, it fires an
        -- "OnAnimationFinished" event, within which it is totally legal (and quite common) that
        -- the object is destroyed at this point.  We need to defer this until after we're done
        -- processing this animation set.
        animationSet.guiObject:PauseEvents()
        
        -- Start with the base value...
        local value = CopyForAnimatedValue(animationSet.baseValue)
        
        -- Apply each animation layer in order (oldest evaluated first).
        local idx = 1
        while idx <= #animationSet do
            
            local valueBefore = CopyForAnimatedValue(value)
            local animationLayer = animationSet[idx]
            local finished
            value, finished = animationLayer.params.func(animationSet.guiObject, now - animationLayer.startTime, animationLayer.params, value, animationLayer.startValue, animationLayer.endValue, animationLayer.startTime)
            if finished then
                value = valueBefore
                table.remove(animationSet, idx)
                
                if animationLayer.name then
                    animationSet.guiObject:FireEvent("OnAnimationFinished", animationLayer.name)
                end
                
            elseif finished == nil then
                error("Animation function returned nil for finished!")
            else --if finished == false then
                idx = idx + 1
            end
            
        end
        
        -- Set the property of this object to the animated value.
        self.setFromAnimation = self.setFromAnimation + 1
        animationSet.guiObject:Set(animationSet.propertyName, value)
        self.setFromAnimation = self.setFromAnimation - 1
        assert(self.setFromAnimation >= 0)
        
        -- Cleanup the animation set if it's empty.  It's okay to delete it here since we're
        -- iterating over a linked list using an intrusive iteration technique.
        if #animationSet == 0 then
            DestroyAnimationSet(self, animationSet)
        end
        
        -- We're done processing this animationSet for now. It is now safe for side effects from
        -- events.  Also, this is safe even if the animation set was "destroyed" in the above
        -- statements -- this only unlinks the animation set -- our local reference is still valid.
        animationSet.guiObject:ResumeEvents()
        
        animationSet = ListIteratorGetNextElement(self, listIterator)
        
    end
    
end

SetupGUIManager("GUIAnimationManager")