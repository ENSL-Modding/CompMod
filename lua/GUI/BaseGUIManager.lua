-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/GUI/BaseGUIManager.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Abstract base class for all of the GUI________Manager singleton classes.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

---@class BaseGUIManager
class "BaseGUIManager"

local managers = {} -- list of all manager singletons.

-------------
-- METHODS --
-------------

-- Called when the manager is created, via a call to SetupGUIManager(className).
function BaseGUIManager:Initialize()
end

-- Called when a GUIObject is destroyed (after it is marked as destroyed, but before its fields are cleared out).
function BaseGUIManager:OnObjectDestroyed(guiObject)
end

-- Called every frame.
function BaseGUIManager:Update(deltaTime, now)
end

----------------------
-- GLOBAL FUNCTIONS --
----------------------

-- Creates and initializes the GUIManager singleton class with the given name.  Also generates a
-- global getter function for it (eg GetGUIEventManager() ).  Typically should be called at the end
-- of the script that defines the class.
function SetupGUIManager(className)
    
    if type(className) ~= "string" then
        error(string.format("Expected a class name, got %s instead", className), 2)
    end
    
    local cls = _G[className]
    if not cls then
        error(string.format("No class named '%s' was found! (Did you forget to load a script file?)", className), 2)
    end
    
    if type(cls) ~= "table" or type(getmetatable(cls).__call) ~= "function" then
        error(string.format("Value of '%s' is not a class.", className), 2)
    end
    
    local getterName = "Get"..className
    if _G[getterName] ~= nil then
        error(string.format("Unable to define getter '%s', name already taken! (Is this GUIManager already setup?)", getterName), 2)
    end
    
    local newManager = cls()
    
    -- This method should only ever be called once.  Replace the class construction method with a
    -- method that gives an error message. (It's a common mistake to do, for example:
    -- GUIEventManager():EnqueueEventCallback(...blah blah...)
    -- instead of
    -- GetGUIEventManager():EnqueueEventCallback(...blah blah...)
    -- ^^^
    getmetatable(cls).__call = function()
        error(string.format("Attempt to create a second %s! (Did you accidentally call %s instead of Get%s?)", cls.classname, cls.classname, cls.classname), 2)
    end
    
    newManager:Initialize()
    table.insert(managers, newManager)
    
    _G[getterName] = function()
        return newManager
    end
    
end

-------------
-- PRIVATE --
-------------

-- Calls a function for every manager class with the given parameters.
local function ForEveryManagerCallMethod(funcName, p1, p2, p3, p4, p5, p6, p7, p8)
    for i=1, #managers do
        local manager = managers[i]
        manager[funcName](manager, p1, p2, p3, p4, p5, p6, p7, p8)
    end
end

Event.Hook("UpdateClient", function(deltaTime)
    local now = Shared.GetTime()
    ForEveryManagerCallMethod("Update", deltaTime, now)
end, "BaseGUIManager")

-- Called by the new gui system whenever a GUIObject is destroyed.  No need to call this manually.
function OnGUIObjectDestroyed(guiObject)
    AssertIsaGUIObject(guiObject)
    ForEveryManagerCallMethod("OnObjectDestroyed", guiObject)
end
