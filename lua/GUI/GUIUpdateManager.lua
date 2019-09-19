-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/GUI/GUIUpdateManager.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Singleton class that manages GUIObjects that require constant updates.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/BaseGUIManager.lua")
Script.Load("lua/UnorderedSet.lua")

---@class GUIUpdateManager : BaseGUIManager
class "GUIUpdateManager" (BaseGUIManager)

function GUIUpdateManager:Initialize()
    
    BaseGUIManager.Initialize(self)
    
    self.objects = UnorderedSet()
    
end

function GUIUpdateManager:OnObjectDestroyed(obj)
    
    self.objects:RemoveElement(obj)
    
end

-- Iterate over the contents of a list, calling "visitorFunc" for each item.  This copies the list
-- before iteration starts.  This ensures that side effects that modify the input list do not
-- affect the iteration.
local function SafeIteration(list, visitorFunc, ...)
    
    local safeList = {}
    for i=1, #list do
        table.insert(safeList, list[i])
    end
    
    for i=1, #safeList do
        visitorFunc(safeList[i], ...)
    end
    
end

local function DispatchUpdate(obj, deltaTime, now)
    obj:OnUpdate(deltaTime, now)
end

function GUIUpdateManager:Update(deltaTime, now)
    -- Fire "OnUpdate" for all objects listening for it.
    SafeIteration(self.objects, DispatchUpdate, deltaTime, now)
end

function GUIUpdateManager:AddObjectToUpdateSet(obj)
    if not obj.OnUpdate then
        error(string.format("Cannot enable updates for class '%s', no 'OnUpdate' method found!", obj.classname), 2)
    end
    self.objects:Add(obj)
end

function GUIUpdateManager:RemoveObjectFromUpdateSet(obj)
    self.objects:RemoveElement(obj)
end

SetupGUIManager("GUIUpdateManager")
