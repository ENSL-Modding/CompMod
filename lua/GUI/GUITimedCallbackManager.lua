-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/GUI/GUITimedCallbackManager.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Singleton class that manages actions scheduled to occur at a later time.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/BaseGUIManager.lua")
Script.Load("lua/UnorderedSet.lua")

---@class GUITimedCallbackManager : BaseGUIManager
class "GUITimedCallbackManager" (BaseGUIManager)

function GUITimedCallbackManager:Initialize()
    
    BaseGUIManager.Initialize(self)
    
    self.callbacks = {}
    
end

function GUITimedCallbackManager:OnObjectDestroyed(obj)
    
    for i=#self.callbacks, 1, -1 do
        if self.callbacks[i].obj == obj then
            table.remove(self.callbacks, i)
            
            -- If an object was destroyed as a result of some delayed callback, ensure we keep our
            -- iteration variable in the right spot.
            if i < self.iterationIndex then
                self.iterationIndex = self.iterationIndex - 1
            end
        end
    end
    
end

function GUITimedCallbackManager:Update(deltaTime, now)
    
    self.iterationIndex = 1
    while self.iterationIndex <= #self.callbacks do
        
        local callback = self.callbacks[self.iterationIndex]
        local removedCallback = false
        if now >= callback.fireTime then
            
            
            if callback.cycleTime then
                -- Adjust the callback fire time if it's supposed to repeat.
                callback.fireTime = callback.fireTime + callback.cycleTime
            else
                -- Remove the callback from the table if it's a one-shot callback.
                table.remove(self.callbacks, self.iterationIndex)
                removedCallback = true
            end
            
            -- Fire the callback.
            callback.callbackFunction(callback.obj)
            
        end
        
        -- Advance iteration if we didn't remove a callback.
        if not removedCallback then
            self.iterationIndex = self.iterationIndex + 1
        end
        
    end
    
end

function GUITimedCallbackManager:AddTimedCallback(obj, callbackFunction, delay, rep)
    
    local newCallback =
    {
        obj = obj,
        callbackFunction = callbackFunction,
        fireTime = Shared.GetTime() + delay,
    }
    
    -- Also store how often to repeat if applicable.
    if rep then
        newCallback.cycleTime = delay
    end
    
    table.insert(self.callbacks, newCallback)
    
    return newCallback
    
end

-- Removes a previously setup but not yet fired timed callback.  The callback parameter is expected
-- to be the return value that was received from AddTimedCallback.
function GUITimedCallbackManager:RemoveTimedCallback(callback)
    
    for i=1, #self.callbacks do
        
        if self.callbacks[i] == callback then
            table.remove(self.callbacks, i)
            
            -- If we're currently iterating over the callbacks in the update function, make sure we
            -- adjust the iteration index if necessary.
            if i < self.iterationIndex then
                self.iterationIndex = self.iterationIndex - 1
            end
            
            -- There can only be one callback found -- they are created unique.  Return true to say
            -- we found and removed it.
            return true
        end
        
    end
    
    -- Callback was not found.
    return false
    
end

SetupGUIManager("GUITimedCallbackManager")
