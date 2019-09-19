-- ======= Copyright (c) 2019, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/menu2/NavBar/Screens/ServerBrowser/GMSBColumn.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Defines the abstract base classes for the header and contents of a single column for the
--    server browser.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUI/GUIObject.lua")
Script.Load("lua/GUI/widgets/GUIButton.lua")
Script.Load("lua/GUI/GUIUtils.lua")
Script.Load("lua/GUI/wrappers/FXState.lua")

local function RegisterServerBrowserColumnTypeTooLate(name)
    error(string.format("Too late to register server browser column named '%s' -- the server column definitions have already been used!  To ensure you're not too late, load your server column script from within LoadServerBrowserColumns (extend using post load hooks on ServerBrowserColumns.lua).", name), 2)
end

-- Mapping of columnName --> { [headingClass] = ... [contentsClass] = ... }
-- Also mapping of columnIndex (creation order) --> columnName.
local columnTypes = {}
function RegisterServerBrowserColumnType(name, headingClass, contentsClass, weight, sortPriority, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    ValidateClass(headingClass)
    ValidateClass(contentsClass)
    
    RequireType("number", weight, "weight", errorDepth)
    RequireType("number", sortPriority, "sortPriority", errorDepth)
    
    if columnTypes[name] ~= nil then
        error(string.format("Column type named '%s' already exists!", name), errorDepth)
    end
    
    if weight <= 0 then
        error(string.format("Weight must be > 0, got '%s'.", weight), errorDepth)
    end
    
    columnTypes[name] =
    {
        name = name,
        headingClass = headingClass,
        contentsClass = contentsClass,
        weight = weight,
        sortPriority = sortPriority,
    }
    columnTypes[#columnTypes+1] = name
    
end

local function SortByPriority(a, b)
    return a.sortPriority < b.sortPriority
end

-- Returns a list of column type defs, sorted by priority.  Called by the server browser and the
-- server browser entry classes.
local cachedSortedTypeDefs
function GetSortedColumnTypeDefs()
    
    if cachedSortedTypeDefs then
        return cachedSortedTypeDefs
    end
    
    cachedSortedTypeDefs = {}
    for i=1, #columnTypes do
        cachedSortedTypeDefs[i] = columnTypes[ columnTypes[i] ]
    end
    table.sort(cachedSortedTypeDefs, SortByPriority)
    
    -- Replace the function used to register columns with one that will throw an error.
    RegisterServerBrowserColumnType = RegisterServerBrowserColumnTypeTooLate
    
    return cachedSortedTypeDefs
end

-------------------
-- COLUMN HEADER --
-------------------

---@class GMSBColumnHeading : GUIButton
---@field public GetFXState function @From FXState wrapper
---@field public UpdateFXStateOverride function @From FXState wrapper
---@field public AddFXReceiver function @From FXState wrapper
---@field public RemoveFXReceiver function @From FXState wrapper
local headingBaseClass = GUIButton
headingBaseClass = GetFXStateWrappedClass(headingBaseClass)
class "GMSBColumnHeading" (headingBaseClass)

local function OnPressed(self)
    PlayMenuSound("ButtonClick")
end

function GMSBColumnHeading:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    AbstractClassCheck(self, "GMSBColumnHeading", errorDepth)
    
    headingBaseClass.Initialize(self, params, errorDepth)
    
    self:HookEvent(self, "OnPressed", OnPressed)
    
end


---------------------
-- COLUMN CONTENTS --
---------------------

---@class GMSBColumnContents : GUIObject
class "GMSBColumnContents" (GUIObject)

function GMSBColumnContents:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    
    AbstractClassCheck(self, "GMSBColumnContents", errorDepth)
    
    RequireIsa("GMSBEntry", params.entry, "params.entry", errorDepth)
    
    GUIObject.Initialize(self, params, errorDepth)
    
    self.entry = params.entry
    
end

function GMSBColumnContents:GetEntry()
    
    return self.entry
    
end
