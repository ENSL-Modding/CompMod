-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/GUI/GUIDeferredUniqueCallbackManager.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Singleton class that manages a queue of unique callbacks.  Unique callbacks fire at most once
--    at the end of each update cycle.  This is useful for things like sounds that we don't want to
--    stack up, or for expensive callbacks that we want to call as little as possible.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/BaseGUIManager.lua")
Script.Load("lua/OrderedSet.lua")

---@class GUIDeferredUniqueCallbackManager : BaseGUIManager
class "GUIDeferredUniqueCallbackManager" (BaseGUIManager)

function GUIDeferredUniqueCallbackManager:Initialize()
    
    BaseGUIManager.Initialize(self)
    
    -- Double buffer the callback set so that more callbacks enqueued as a result of another
    -- deferred callback get deferred to the _next_ frame.
    
    -- Queue being processed.
    self.activeCallbackQueue = OrderedSet()
    
    -- Queue being added to.
    self.bufferedCallbackQueue = OrderedSet()
    
    --  mapping of param --->
    --  {
    --      mapping of callback function ---> callback
    --  }
    -- This is what we use to determine if a callback is "unique" or not, and if not, remove the
    -- old one from the set.
    self.callbackMap = {}
    
end

-- Enqueues a new, unique callback.  Callbacks are tables with two fields, "param", and
-- "callbackFunction".  If a callback with identical values already exists in the queue, it is
-- replaced.
function GUIDeferredUniqueCallbackManager:EnqueueDeferredUniqueCallback(callback)
    
    PROFILE("GUIDeferredUniqueCallbackManager:EnqueueDeferredUniqueCallback")
    
    -- Since every callback (unique or not) is packed into a unique new table, we can't just
    -- compare if the tables are unique value or not.
    local callbackMap_param = self.callbackMap
    
    if callbackMap_param[callback.param] == nil then
        callbackMap_param[callback.param] = {}
    end
    
    local callbackMap_func = callbackMap_param[callback.param]
    
    -- If there is already a callback here with the same callback function, remove that old
    -- callback from the set before adding this new one.
    local oldCallback = callbackMap_func[callback.callbackFunction]
    if oldCallback ~= nil then
        assert(self.bufferedCallbackQueue:RemoveElement(oldCallback))
    end
    
    -- Set to new callback.
    callbackMap_func[callback.callbackFunction] = callback
    
    -- Add to the queue.
    self.bufferedCallbackQueue:Add(callback)
    
end

function GUIDeferredUniqueCallbackManager:Update(deltaTime, now)
    
    PROFILE("GUIDeferredUniqueCallbackManager:Update")
    
    if #self.bufferedCallbackQueue == 0 then
        return -- no new work, bail out early to save needless garbage creation.
    end
    
    do -- buffer swap
        local temp = self.activeCallbackQueue
        self.activeCallbackQueue = self.bufferedCallbackQueue
        self.bufferedCallbackQueue = temp
    end
    
    self.callbackMap = {}
    
    -- Process the queue until it is exhausted.
    while #self.activeCallbackQueue > 0 do
        
        local callback = self.activeCallbackQueue[1]
        self.activeCallbackQueue:RemoveIndex(1)
        
        callback.callbackFunction(callback.param)
        
    end
    
end

local function RemoveObjectFromCallbackQueue(self, queue, guiObject)
    
    local callbacksToRemove = {}
    for i=1, #queue do
        if queue[i].param == guiObject then
            table.insert(callbacksToRemove, queue[i])
        end
    end
    
    for i=1, #callbacksToRemove do
        queue:RemoveElement(callbacksToRemove[i])
    end
    
end

local function RemoveObjectReferences(self, guiObject)
    
    RemoveObjectFromCallbackQueue(self, self.activeCallbackQueue, guiObject)
    RemoveObjectFromCallbackQueue(self, self.bufferedCallbackQueue, guiObject)
    
    self.callbackMap[guiObject] = nil
    
end

function GUIDeferredUniqueCallbackManager:OnObjectDestroyed(guiObject)
    
    RemoveObjectReferences(self, guiObject)
    
end

SetupGUIManager("GUIDeferredUniqueCallbackManager")
