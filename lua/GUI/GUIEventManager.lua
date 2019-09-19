-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/GUI/GUIEventManager.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Singleton class that manages event callbacks for the new gui system.  Receives inputs from
--    the InputHandler and determines which gui class should handle the event.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/GUIDebug.lua")
Script.Load("lua/GUI/BaseGUIManager.lua")
Script.Load("lua/UnorderedSet.lua")

--- @class GUIEventManager : BaseGUIManager
class "GUIEventManager" (BaseGUIManager)

-- Prevent too many events from firing in a single frame.  This should only ever occur when an
-- infinite loop is accidentally formed.  This gets reset every frame.
local kMaxEventFiresPerFrame = 100000
local eventFiringSafetyLimit = kMaxEventFiresPerFrame

-------------------------
-- FROM BaseGUIManager --
-------------------------

function GUIEventManager:Initialize()
    
    BaseGUIManager.Initialize(self)
    
    -- Callbacks are processed in a queue, rather than recursively.  However, to maintain the
    -- correct execution order, we have to store many queues in a stack.  Every time we process an
    -- event callback, the stack depth increases, and every time we return from a callback, the
    -- depth decreases.  This is to ensure that events always fire in the order in which they were
    -- enqueued.
    self.queuedCallbacks = {{}}
    
    -- Mapping of callbacks to a list of references where they are used so they can be removed with
    -- no searching.
    self.callbackRefs = {}
    
end

function GUIEventManager:Update(deltaTime, now)
    
    eventFiringSafetyLimit = kMaxEventFiresPerFrame
    
end

--------------------
-- PUBLIC METHODS --
--------------------

-- Enqueues an event callback to be performed in the next call to
-- GUIEventManager:ProcessEventQueue().  We do this with a queue, rather than immediately to ensure
-- that events fire intuitively regardless of events causing other events to fire, or destroying
-- objects, or un-hooking events in other objects.  The queue system simplifies the logic needed
-- to fire many events at once.
function GUIEventManager:EnqueueEventCallback(callback, p1, p2, p3, p4, p5, p6, p7, p8)
    
    PROFILE("GUIEventManager:EnqueueEventCallback")
    
    -- Add this callback to the top-most queue of the queued callbacks stack.
    local newCallbackRef = {callback, p1, p2, p3, p4, p5, p6, p7, p8 }
    table.insert(self.queuedCallbacks[#self.queuedCallbacks], newCallbackRef)
    
    -- Keep a record of where this callback is being used so it can be removed without searching.
    self.callbackRefs[callback] = self.callbackRefs[callback] or UnorderedSet()
    self.callbackRefs[callback]:Add(newCallbackRef)
    
    -- Store this stack trace in the callbackRef.
    if dbgStoreEventStackTraces then
        newCallbackRef.debugStackTrace = Debug_GetStackTraceForEvent()
    end
    
end

-- Returns an UnorderedSet (or nil) of queued callbacks that refer to the given callback.
function GUIEventManager:GetCallbackRefs(callback)
    return self.callbackRefs[callback]
end

function GUIEventManager:EnqueueUniqueEventCallback(callback, p1, p2, p3, p4, p5, p6, p7, p8)
    
    PROFILE("GUIEventManager:EnqueueUniqueEventCallback")
    
    -- If this callback has been queued up before, unqueue it.
    self:OnCallbackRemoved(callback)
    
    self:EnqueueEventCallback(callback, p1, p2, p3, p4, p5, p6, p7, p8)
    
end

-- Processes all the queued events.  Should be called after all simultaneous events are enqueued.
function GUIEventManager:ProcessEventQueue()
    
    PROFILE("GUIEventManager:ProcessEventQueue")
    
    local currentLevel = #self.queuedCallbacks
    if #self.queuedCallbacks[currentLevel] == 0 then
        return -- No events to process.
    end
    
    -- Keep processing events until we exhaust the stack back down to the level we started on.
    while #self.queuedCallbacks[currentLevel] > 0 and eventFiringSafetyLimit > 0 do
        
        eventFiringSafetyLimit = eventFiringSafetyLimit - 1
        
        local callbackRef = self.queuedCallbacks[#self.queuedCallbacks][1]
        
        if callbackRef then
            
            table.remove(self.queuedCallbacks[#self.queuedCallbacks], 1)
            
            if not callbackRef.removed then
                
                local callback = callbackRef[1]
                local p1 = callbackRef[2]
                local p2 = callbackRef[3]
                local p3 = callbackRef[4]
                local p4 = callbackRef[5]
                local p5 = callbackRef[6]
                local p6 = callbackRef[7]
                local p7 = callbackRef[8]
                local p8 = callbackRef[9]
                
                self:RemoveCallbackRef(callbackRef)
                
                if dbgStoreEventStackTraces then
                    -- Push the callback's saved stack trace.
                    if not dbgQueuedEventStack then
                        dbgQueuedEventStack = {}
                    end
                    
                    assert(callbackRef.debugStackTrace)
                    dbgQueuedEventStack[#dbgQueuedEventStack+1] = callbackRef.debugStackTrace
                    
                end
                
                -- Grow stack for callback function (as we may get some recursive calls of this method
                -- before returning.  Need to keep events executing in the correct order.
                self.queuedCallbacks[#self.queuedCallbacks+1] = {} -- push new queue.
                
                callback.callbackFunction(callback.receiver, p1, p2, p3, p4, p5, p6, p7, p8)
                
            end
            
        end
        
        -- If the stack is exhausted, pop it off.  We need to check because the stack might not
        -- have been exhausted if there were events queued up during the callback by objects
        -- that were paused.  These objects won't call GEM:ProcessEventQueue(), so we'll need
        -- to just keep looping.  (This is okay.  It is understood that pausing an object
        -- doesn't pause all events -- just means THAT object won't be starting the process,
        -- so in order for us to have even gotten here in the first place indicates that some
        -- other object already started the processing).
        if #self.queuedCallbacks[#self.queuedCallbacks] == 0 and #self.queuedCallbacks > currentLevel then
            self.queuedCallbacks[#self.queuedCallbacks] = nil -- pop queue.
            
            if dbgStoreEventStackTraces then
                -- Pop this callback's stack trace.
                dbgQueuedEventStack[#dbgQueuedEventStack] = nil
            end
            
        end
        
    end
    
    if eventFiringSafetyLimit == 0 then
        error("Event queue length exceeded too-damn-long threshold.  Infinite loop detected!")
    end
    
end

function GUIEventManager:RemoveCallbackRef(callbackRef)
    
    -- Easier to just mark them as removed, since it'd be much more difficult to figure out which
    -- queues the ref is stored in.
    callbackRef.removed = true
    
    -- Remove callback ref from its set of refs.
    local callback = callbackRef[1]
    assert(callback)
    local callbackRefs = self:GetCallbackRefs(callback)
    assert(callbackRefs)
    if callbackRefs then
        assert(callbackRefs:RemoveElement(callbackRef))
        
        -- Cleanup the set if it's empty.
        if #callbackRefs == 0 then
            self.callbackRefs[callback] = nil
        end
        
    end
    
end

-- Called whenever an event is un-hooked, so we can remove it from the list of queued events.
function GUIEventManager:OnCallbackRemoved(callback)
    
    PROFILE("GUIEventManager:OnCallbackRemoved")
    
    -- Invalidate callback refs that used this callback.  We simply mark them as removed, rather
    -- than perform an expensive removal from the table -- let the queue processing deal with it.
    local refs = self:GetCallbackRefs(callback)
    if not refs then
        return -- no callback refs used this callback.
    end
    
    -- Remove these callback refs.
    while #refs > 0 do
        local safetyCheck = #refs
        self:RemoveCallbackRef(refs[1])
        assert(#refs < safetyCheck)
    end
    
end

-------------
-- PRIVATE --
-------------

SetupGUIManager("GUIEventManager")
