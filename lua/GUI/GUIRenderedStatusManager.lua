-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/GUI/GUIRenderedStatusManager.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Singleton class that keeps track of whether or not an object was rendered last frame, so we
--    can detect when it starts/stops being rendered.  This is useful for certain objects that
--    should be deactivated when not visible (eg require constant updates, or use expensive
--    resources).
--
--    Adds two events fired from the affected object(s):
--      "OnRenderingStarted"
--      "OnRenderingStopped"
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/BaseGUIManager.lua")
Script.Load("lua/UnorderedSet.lua")

---@class GUIRenderedStatusManager : BaseGUIManager
class "GUIRenderedStatusManager" (BaseGUIManager)

function GUIRenderedStatusManager:Initialize()
    
    BaseGUIManager.Initialize(self)
    
    self.objectToItemsMapSet = {}
    
    self.renderedObjects = UnorderedSet()
    self.notRenderedObjects = UnorderedSet()
    self.newlyAddedObjects = UnorderedSet()
    
end

function GUIRenderedStatusManager:OnObjectDestroyed(obj)
    
    self.renderedObjects:RemoveElement(obj)
    self.notRenderedObjects:RemoveElement(obj)
    self.newlyAddedObjects:RemoveElement(obj)
    
end

-- Iterate over the contents of a list, calling "visitorFunc" for each item.  This copies the list
-- before iteration starts.  This ensures that side effects that modify the input list do not
-- affect the iteration.
local function SafeIteration(self, list, visitorFunc, ...)
    
    local safeList = {}
    for i=1, #list do
        table.insert(safeList, list[i])
    end
    
    for i=1, #safeList do
        visitorFunc(self, safeList[i], ...)
    end
    
end

local function GetWereAnyItemsRenderedLastFrame(itemList)
    for i=1, #itemList do
        if itemList[i]:GetWasRenderedLastFrame() then
            return true
        end
    end
    return false
end

local function CheckIfNoLongerRendered(self, obj)
    if not GetWereAnyItemsRenderedLastFrame(self.objectToItemsMapSet[obj]) then
        self.renderedObjects:RemoveElement(obj)
        self.notRenderedObjects:Add(obj)
        obj:FireEvent("OnRenderingStopped")
    end
end

local function CheckIfStartedRendering(self, obj)
    if GetWereAnyItemsRenderedLastFrame(self.objectToItemsMapSet[obj]) then
        self.renderedObjects:Add(obj)
        self.notRenderedObjects:RemoveElement(obj)
        obj:FireEvent("OnRenderingStarted")
    end
end

local function CategorizeNew(self, obj)
    if obj:GetRootItem():GetWasRenderedLastFrame() then
        self.renderedObjects:Add(obj)
        obj:FireEvent("OnRenderingStarted")
    else
        self.notRenderedObjects:Add(obj)
        obj:FireEvent("OnRenderingStopped")
    end
    self.newlyAddedObjects:RemoveElement(obj)
end

function GUIRenderedStatusManager:Update(deltaTime, now)
    
    -- Iterate over objects that have been rendered to see if they were maybe not rendered last
    -- frame.
    SafeIteration(self, self.renderedObjects, CheckIfNoLongerRendered)
    
    -- Iterate over objects that haven't been rendered to see if maybe they were rendered last
    -- frame.
    SafeIteration(self, self.notRenderedObjects, CheckIfStartedRendering)
    
    -- Categorize newly added objects based on whether they were rendered last frame.
    SafeIteration(self, self.newlyAddedObjects, CategorizeNew)
    
end

-- Returns true if the item was added successfully, false if it was already present.
function GUIRenderedStatusManager:TrackRenderStatusOfObject(obj, item)
    
    if self.objectToItemsMapSet[obj] then
        -- Existing object with new item added to it.
        local result = self.objectToItemsMapSet[obj]:Add(item)
        return result
    else
        -- New object.
        self.newlyAddedObjects:Add(obj)
        self.objectToItemsMapSet[obj] = UnorderedSet()
        self.objectToItemsMapSet[obj]:Add(item)
        return true
    end
    
end

-- Returns true if the removal was successful, false if the object wasn't being tracked in the first place.
function GUIRenderedStatusManager:StopTrackingRenderStatusOfObject(obj)
    
    if self.objectToItemsMapSet[obj] then
        self.objectToItemsMapSet[obj] = nil
        self.renderedObjects:RemoveElement(obj)
        self.notRenderedObjects:RemoveElement(obj)
        self.newlyAddedObjects:RemoveElement(obj)
        return true
    else
        return false
    end
    
end

SetupGUIManager("GUIRenderedStatusManager")
